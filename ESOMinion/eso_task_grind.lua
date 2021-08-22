-- Grind
eso_task_grind = inheritsFrom(ml_task)
eso_task_grind.name = "ESO_TASK_GRIND"
function eso_task_grind.Create()
	local newinst = inheritsFrom(eso_task_grind)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	newinst.markerTime = 0
    newinst.currentMarker = false
	newinst.filterLevel = true
	
	newinst.targetid = 0
	newinst.gatherid = 0
	newinst.movementDelay = 0
	newinst.lastMovement = 0
	
    return newinst
end

function eso_task_grind:UIInit()
	if (Settings.ESOMinion.gAssistTargetMode == nil) then
		Settings.ESOMinion.gAssistTargetMode = "None"
	end
	gGather = esominion.GetSetting("gGather",false)
end
--[[
function eso_task_grind.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "gGather")						
		then
			Settings.ESOMinion[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(ml_global_information.MainWindow.Name)
end]]

function eso_task_grind:Init()
    local ke_dead = ml_element:create( "Dead", c_dead, e_dead, 300 )
    self:add( ke_dead, self.overwatch_elements )
	
	local ke_rest = ml_element:create( "Rest", c_rest, e_rest, 250 )
    self:add( ke_rest, self.overwatch_elements )
	
	local ke_aggro = ml_element:create( "Aggro", c_aggro, e_aggro, 200 )
	self:add( ke_aggro, self.overwatch_elements )
	
	local ke_autoEquip = ml_element:create( "AutoEquip", c_autoequip, e_autoequip, 200 )
	self:add( ke_autoEquip, self.process_elements)
	
	local ke_vendor = ml_element:create( "Vendor", c_Vendor, e_Vendor, 195 )
	self:add(ke_vendor, self.process_elements)
	
	--self:add(ml_element:create( "GetPotions", c_usePotions, e_usePotions, 190 ), self.process_elements)
		
	local ke_lootBodies = ml_element:create( "Loot", c_lootbodies, e_lootbodies, 100 )
	self:add( ke_lootBodies, self.process_elements )
	
	local ke_findGrindable = ml_element:create( "FindGrindable", c_findgrindable, e_findgrindable, 85 )
	self:add( ke_findGrindable, self.process_elements )
	
	local ke_findnode = ml_element:create( "FindGatherable", c_findgatherable, e_findgatherable, 80 )
	self:add( ke_findnode, self.process_elements )
	
	local ke_nextMarker = ml_element:create( "NextMarker", c_nextgrindmarker, e_nextgrindmarker, 75 )
    self:add( ke_nextMarker, self.process_elements )
    
	local ke_returnToMarker = ml_element:create( "ReturnToMarker", c_returntomarker, e_returntomarker, 70 )
    self:add( ke_returnToMarker, self.process_elements)
	
	local ke_nextGrindObjective = ml_element:create( "NextGrindObjective", c_nextgrindobjective, e_nextgrindobjective, 50 )
	self:add( ke_nextGrindObjective, self.process_elements )
	
	-- Move to a Randompoint if there is nothing to fight around us
	--self:add( ml_element:create( "movetorandom", c_movetorandom, e_movetorandom, 25 ), self.process_elements)	
			
    self:AddTaskCheckCEs()
end

function eso_task_grind:Draw()
	local MarkerOrProfileWidth = (GUI:GetContentRegionAvail() - 10)
	--local tabindex, tabname = GUI_DrawTabs(self.GUI.main_tabs)
	GUI:AlignFirstTextHeightToWidgets() 
	
	gGather, changed = GUI:Checkbox("Gather##gGather", gGather) 
	if (changed) then
		Settings.ESOMINION["gGather"] = gGather
	end 
end
c_findgatherable = inheritsFrom(ml_cause)
e_findgatherable = inheritsFrom(ml_effect)
c_findgatherable.node = nil
function c_findgatherable:evaluate()
	local isInteracting = Player.interacting
	if (InventoryFull() or isInteracting) then
		return false
	end
	
	local needsUpdate = false
	if not ml_task_hub:CurrentTask() or (ml_task_hub:CurrentTask().gatherid == nil or ml_task_hub:CurrentTask().gatherid == 0 ) then
		needsUpdate = true
	end
		
	--[[local gatherable = EntityList:Get(ml_task_hub:CurrentTask().gatherid)
	if (not ValidTable(gatherable)) then
		needsUpdate = true
	end]]
	
	if (needsUpdate) then
	
		local whitelist = ESOLib.Common.BuildWhitelist()
		local radius = 100
		local filter = ""
		if whitelist == "" then
			return false
		end
		filter = "onmesh,contentid="..whitelist

		local gatherable = nil				
		if (gatherable == nil) then
			gatherable = GetNearestFromList(filter,Player.pos,radius,eso_gather.lockoutids)
		end
		
		if (table.valid(gatherable)) then
			c_findgatherable.node = gatherable
			return true
		else
			--d("no gatherables")
		end
		--d("failed out")
	end
    
    return false
end
function e_findgatherable:execute()
	d("Updating task gatherid.")
	d(c_findgatherable.node)
	ml_task_hub:CurrentTask().gatherid = c_findgatherable.node.index
end
c_nextgrindmarker = inheritsFrom( ml_cause )
e_nextgrindmarker = inheritsFrom( ml_effect )
function c_nextgrindmarker:evaluate()	
	if (gMarkerMgrMode == GetString("singleMarker")) then
		ml_task_hub:CurrentTask().filterLevel = false
	else
		ml_task_hub:CurrentTask().filterLevel = true
	end
	
    if ( ml_task_hub:CurrentTask().currentMarker ~= nil and ml_task_hub:CurrentTask().currentMarker ~= 0 ) then
		
        local marker = nil
        local ppos = Player.pos
		
        -- first check to see if we have no initiailized marker
       --[[ if (ml_task_hub:CurrentTask().currentMarker == false) then --default init value
            --marker = ml_marker_mgr.GetNextMarker(GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
			marker = ml_marker_mgr.GetClosestMarker( ppos.x, ppos.y, ppos.z, 300, GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
		end]]
        
		local targetid = ml_task_hub:CurrentTask().targetid
		local gatherid = ml_task_hub:CurrentTask().gatherid
		if (gatherid == 0 and targetid == 0) then
			-- next check to see if our level is out of range
			if (marker == nil) then
				if (ValidTable(ml_task_hub:CurrentTask().currentMarker)) then
					if 	(ml_task_hub:CurrentTask().filterLevel) and
						(ml_global_information.Player_Level < ml_task_hub:CurrentTask().currentMarker:GetMinLevel() or 
						ml_global_information.Player_Level > ml_task_hub:CurrentTask().currentMarker:GetMaxLevel()) 
					then
						--marker = ml_marker_mgr.GetNextMarker(GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
						marker = ml_marker_mgr.GetClosestMarker( ppos.x, ppos.y, ppos.z, 300, GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
					end
				end
			end
			
			-- last check if our time has run out
			if (marker == nil) then
				if (ValidTable(ml_task_hub:CurrentTask().currentMarker)) then
					if (ml_task_hub:CurrentTask().currentMarker:GetTime() ~= 0) then
						local expireTime = ml_task_hub:CurrentTask().markerTime
						if (Now() > expireTime) then
							ml_debug("Getting Next Marker, TIME IS UP!")
							--marker = ml_marker_mgr.GetNextMarker(GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
							marker = ml_marker_mgr.GetClosestMarker( ppos.x, ppos.y, ppos.z, 300, GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
						end
					end
				end
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
	ml_global_information.currentMarker = e_nextgrindmarker.marker
    ml_task_hub:CurrentTask().currentMarker = e_nextgrindmarker.marker
    ml_task_hub:CurrentTask().markerTime = Now() + (ml_task_hub:CurrentTask().currentMarker:GetTime() * 1000)
	ml_global_information.MarkerTime = Now() + (ml_task_hub:CurrentTask().currentMarker:GetTime() * 1000)
    ml_global_information.MarkerMinLevel = ml_task_hub:CurrentTask().currentMarker:GetMinLevel()
    ml_global_information.MarkerMaxLevel = ml_task_hub:CurrentTask().currentMarker:GetMaxLevel()
	ml_global_information.BlacklistContentID = ml_task_hub:CurrentTask().currentMarker:GetFieldValue(GetUSString("NOTcontentIDEquals"))
	ml_global_information.WhitelistContentID = ml_task_hub:CurrentTask().currentMarker:GetFieldValue(GetUSString("contentIDEquals"))
	--gStatusMarkerName = ml_task_hub:ThisTask().currentMarker:GetName()
end

c_findgrindable = inheritsFrom(ml_cause)
e_findgrindable = inheritsFrom(ml_effect)
c_findgrindable.targetid = nil
function c_findgrindable:evaluate()	

	if c_aggro:evaluate() then
		return false
	end
	
	local needsUpdate = false
	if ( ml_task_hub:CurrentTask().targetid == nil or ml_task_hub:CurrentTask().targetid == 0 ) then
		needsUpdate = true
	end
	
	local target = EntityList:Get(ml_task_hub:CurrentTask().targetid)
	if (ValidTable(target)) then
		if (target.health.current < 1) then
			needsUpdate = true
		end
	else
		needsUpdate = true
	end
	
	if (needsUpdate) then
		ml_task_hub:CurrentTask().targetid = 0
		local newTarget = GetNearestGrind()
		if (ValidTable(newTarget)) then
			c_findgrindable.targetid = newTarget.index
			return true
		end
	end	
    
    return false
end
function e_findgrindable:execute()
	ml_task_hub:CurrentTask().targetid = c_findgrindable.targetid
end

c_nextgrindobjective = inheritsFrom( ml_cause )
e_nextgrindobjective = inheritsFrom( ml_effect )
c_nextgrindobjective.task = nil
function c_nextgrindobjective:evaluate()
	c_nextgrindobjective.task = nil
	
	local gatherdistance = 9999
	local targetdistance = 9999
	
	local gatherid = ml_task_hub:CurrentTask().gatherid or 0
	local targetid = ml_task_hub:CurrentTask().targetid or 0
	
	local gatherable = nil
	local target = nil
	
	if (gatherid > 0 and gGather) then
		gatherable = EntityList:Get(gatherid)
		if (ValidTable(gatherable)) then
			gatherdistance = math.distance2d(Player.pos,gatherable.pos)
			d("gatherable path dist = "..tostring(gatherdistance))
		end
	end
	
	if (targetid > 0) then
		target = EntityList:Get(targetid)
		if (ValidTable(target)) then
			targetdistance = math.distance2d(Player.pos,target.pos)
			d("target path dist = "..tostring(targetdistance))
		end
	end
	d("gatherdistance = "..tostring(gatherdistance))
	d("targetdistance = "..tostring(targetdistance))
	if (targetdistance < gatherdistance) then
		if (ValidTable(target)) then
			local newTask = eso_task_combat.Create()
			newTask.targetID = targetid
			c_nextgrindobjective.task = newTask
			return true
		end
	else
		if (ValidTable(gatherable)) then
			local newTask = eso_task_movetointeract.Create()
			newTask.creator = "nextgrindobjective"
			newTask.pos = gatherable.pos
			newTask.interact = gatherid
			newTask.interactRange = 8
			newTask.avoidPlayers = true
			newTask.postDelay = 4000	
			c_nextgrindobjective.task = newTask
			return true
		end
	end
	
	return false
end
function e_nextgrindobjective:execute()
	if (ValidTable(c_nextgrindobjective.task)) then
		ml_task_hub:Add(c_nextgrindobjective.task, REACTIVE_GOAL, TP_IMMEDIATE)
	end
end

if ( ml_global_information.BotModes) then
	ml_global_information.BotModes[GetString("grindMode")] = eso_task_grind
end

RegisterEventHandler("GUI.Update",eso_task_grind.GUIVarUpdate)
