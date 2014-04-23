-- Grind
ai_grind = inheritsFrom(ml_task)
ai_grind.name = "GrindMode"

function ai_grind.Create()
	local newinst = inheritsFrom(ai_grind)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	newinst.markerTime = 0
    newinst.currentMarker = false
	newinst.filterLevel = true
	
    return newinst
end

function ai_grind:Init()
   -- ml_log("combatAttack_Init->")
	
	-- Dead?
	self:add(ml_element:create( "Dead", c_dead, e_dead, 300 ), self.process_elements)
	
	-- LootAll
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)	
			
	-- Aggro
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 250 ), self.process_elements) --reactive queue
			
	-- Resting
	self:add(ml_element:create( "Resting", c_resting, e_resting, 225 ), self.process_elements)	

	-- Looting
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
			
	-- Gathering
	self:add(ml_element:create( "Gathering", c_gatherTask, e_gatherTask, 125 ), self.process_elements)
	
    self:add( ml_element:create( "ReturnToMarker", c_returntomarker, e_returntomarker, 100 ), self.process_elements)
    
    self:add( ml_element:create( "NextMarker", c_nextgrindmarker, e_nextgrindmarker, 85 ), self.process_elements)
	
	-- Check for Targets
	self:add(ml_element:create( "GetNextTarget", c_CombatTask, e_CombatTask, 75 ), self.process_elements)
		
	-- Goto random point on mesh (for now, use markers later)
	self:add(ml_element:create( "GotoRandomPoint", c_randomPt, e_randomPt, 50 ), self.process_elements)
	
    self:AddTaskCheckCEs()
end

function ai_grind:task_complete_eval()	
	return false
end
function ai_grind:task_complete_execute()
    
end


-- Move to a random point on the mesh ..for now
c_randomPt = inheritsFrom( ml_cause )
e_randomPt = inheritsFrom( ml_effect )
function c_randomPt:evaluate()
	if ( not Player:IsMoving() ) then
		return true
	end
	return false
end
function e_randomPt:execute()
	ml_log("e_randomPt.. ")
	local ppos = Player.pos
	if ( TableSize(ppos)>0)then
		local p = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,30,5000)
		if ( p) then
			tb_xPos = tostring(p.x)
			tb_yPos = tostring(p.y)
			tb_zPos = tostring(p.z)				
			tb_xdist = Distance3D(p.x,p.y,p.z,ppos.x,ppos.y,ppos.z)
			if ( tb_xdist > 15 ) then
				local navResult = tostring(Player:MoveTo(p.x,p.y,p.z,0.5,false,true,false))
				if (tonumber(navResult) < 0) then
					ml_log("CombatMovement result: "..tostring(navResult))
					return ml_log(false)
				end				
				return ml_log(true)
			end
		end
	end
	return ml_log(false)
end

c_nextgrindmarker = inheritsFrom( ml_cause )
e_nextgrindmarker = inheritsFrom( ml_effect )
function c_nextgrindmarker:evaluate()
    if ( ml_task_hub:CurrentTask().currentMarker ~= nil and ml_task_hub:CurrentTask().currentMarker ~= 0 ) then
        local marker = nil
        
        -- first check to see if we have no initiailized marker
        if (ml_task_hub:CurrentTask().currentMarker == false) then --default init value
            marker = ml_marker_mgr.GetNextMarker(strings[gCurrentLanguage].grindMarker, ml_task_hub:CurrentTask().filterLevel)
        
			if (marker == nil) then
				ml_task_hub:CurrentTask().filterLevel = false
				marker = ml_marker_mgr.GetNextMarker(strings[gCurrentLanguage].grindMarker, ml_task_hub:CurrentTask().filterLevel)
			end	
		end
        
        -- next check to see if our level is out of range
        if (marker == nil) then
            if (ValidTable(ml_task_hub:CurrentTask().currentMarker)) then
                if 	(ml_task_hub:CurrentTask().filterLevel) and
					(e("GetUnitLevel(player)") < ml_task_hub:CurrentTask().currentMarker:GetMinLevel() or 
                    e("GetUnitLevel(player)") > ml_task_hub:CurrentTask().currentMarker:GetMaxLevel()) 
                then
                    marker = ml_marker_mgr.GetNextMarker(ml_task_hub:CurrentTask().currentMarker:GetType(), ml_task_hub:CurrentTask().filterLevel)
                end
            end
        end
        
        -- last check if our time has run out
        if (marker == nil) then
            local time = ml_task_hub:CurrentTask().currentMarker:GetTime()
			if (time and time ~= 0 and TimeSince(ml_task_hub:CurrentTask().markerTime) > time * 1000) then
				--ml_debug("Marker timer: "..tostring(TimeSince(ml_task_hub:CurrentTask().markerTime)) .."seconds of " ..tostring(time)*1000)
                ml_debug("Getting Next Marker, TIME IS UP!")
                marker = ml_marker_mgr.GetNextMarker(ml_task_hub:CurrentTask().currentMarker:GetType(), ml_task_hub:CurrentTask().filterLevel)
            else
                return false
            end
        end
        
        if (ValidTable(marker)) then
            e_nextgrindmarker.marker = marker
            return true
        end
    end
    
    return false
end
function e_nextgrindmarker:execute()
    ml_task_hub:CurrentTask().currentMarker = e_nextgrindmarker.marker
    ml_task_hub:CurrentTask().markerTime = ml_global_information.Now
	ml_global_information.MarkerTime = ml_global_information.Now
    ml_global_information.MarkerMinLevel = ml_task_hub:CurrentTask().currentMarker:GetMinLevel()
    ml_global_information.MarkerMaxLevel = ml_task_hub:CurrentTask().currentMarker:GetMaxLevel()
    ml_global_information.BlacklistContentID = ml_task_hub:CurrentTask().currentMarker:GetFieldValue(strings[gCurrentLanguage].NOTcontentIDEquals)
    ml_global_information.WhitelistContentID = ml_task_hub:CurrentTask().currentMarker:GetFieldValue(strings[gCurrentLanguage].contentIDEquals)
	gStatusMarkerName = ml_task_hub:CurrentTask().currentMarker:GetName()
end

c_returntomarker = inheritsFrom( ml_cause )
e_returntomarker = inheritsFrom( ml_effect )
function c_returntomarker:evaluate()
    if (ml_task_hub:CurrentTask().currentMarker ~= false and ml_task_hub:CurrentTask().currentMarker ~= nil) then
        local myPos = Player.pos
        local pos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
        local distance = Distance2D(myPos.x, myPos.z, pos.x, pos.z)
        if  (gBotMode == GetString("grindMode") and distance > 200) then
            return true
        end
    end
    
    return false
end
function e_returntomarker:execute()
	local pos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
	local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,0.5,false,true,false))
	if (tonumber(navResult) < 0) then
		ml_log("ReturnToMarker result: "..tostring(navResult))
		return ml_log(false)
	end

	return ml_log(false)
end


function ai_grind.SetupMarkers()
    -- add marker templates for grinding
    local grindMarker = ml_marker:Create("grindTemplate")
	grindMarker:SetType(strings[gCurrentLanguage].grindMarker)
	grindMarker:AddField("string", strings[gCurrentLanguage].contentIDEquals, "")
	grindMarker:AddField("string", strings[gCurrentLanguage].NOTcontentIDEquals, "")
    grindMarker:SetTime(300)
    grindMarker:SetMinLevel(1)
    grindMarker:SetMaxLevel(50)
    ml_marker_mgr.AddMarkerTemplate(grindMarker)
    
    -- refresh the manager with the new templates
    ml_marker_mgr.RefreshMarkerTypes()
	ml_marker_mgr.RefreshMarkerNames()
end

function ai_grind.moduleinit()
	ai_grind.SetupMarkers()
	
end
if ( ml_global_information.BotModes) then
	ml_global_information.BotModes[GetString("grindMode")] = ai_grind
end
RegisterEventHandler("Module.Initalize",ai_grind.moduleinit)
