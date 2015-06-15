eso_task_gather = inheritsFrom(ml_task)
eso_task_gather.name = "ESO_TASK_GATHER"
function eso_task_gather.Create()
	local newinst = inheritsFrom(eso_task_gather)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	--eso_task_gather members
	newinst.gatherid = 0
	newinst.currentMarker = false
	
    return newinst
end

function eso_task_gather:Init()
    local ke_dead = ml_element:create( "Dead", c_dead, e_dead, 300 )
    self:add( ke_dead, self.overwatch_elements )
	
	local ke_rest = ml_element:create( "Rest", c_rest, e_rest, 225 )
    self:add( ke_rest, self.overwatch_elements )
	
	local ke_aggro = ml_element:create( "Aggro", c_aggro, e_aggro, 200 )
	self:add( ke_aggro, self.overwatch_elements )
	
	--self:add(ml_element:create( "LootAll", c_lootwindow, e_lootwindow, 275 ), self.process_elements)	
	
	local ke_autoEquip = ml_element:create( "AutoEquip", c_autoequip, e_autoequip, 200 )
	self:add( ke_autoEquip, self.process_elements)
	
	local ke_vendor = ml_element:create( "Vendor", c_Vendor, e_Vendor, 200 )
	self:add(ke_vendor, self.process_elements)
	
	local ke_gather = ml_element:create( "Gather", c_gather, e_gather, 150 )
	self:add( ke_gather, self.process_elements )
	
	local ke_lootBodies = ml_element:create( "Loot", c_lootbodies, e_lootbodies, 100 )
	self:add( ke_lootBodies, self.process_elements )
	
	local ke_findGatherable = ml_element:create( "FindGatherable", c_findgatherable, e_findgatherable, 80 )
	self:add( ke_findGatherable, self.process_elements )
	
	local ke_returnToMarker = ml_element:create( "ReturnToMarker", c_returntomarker, e_returntomarker, 75 )
	self:add( ke_returnToMarker, self.process_elements )
	
	local ke_nextMarker = ml_element:create( "NextMarker", c_nextgathermarker, e_nextgathermarker, 70 )
	self:add( ke_nextMarker, self.process_elements )
	
	local ke_moveToGatherable = ml_element:create( "MoveToGatherable", c_movetogatherable, e_movetogatherable, 50 )
	self:add( ke_moveToGatherable, self.process_elements )
		
    self:AddTaskCheckCEs()
end

if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("gatherMode")] = eso_task_gather
end

--function eso_gathertask:task_complete_execute()
	--if (ml_global_information.Player_Sprinting) then e("OnSpecialMoveKeyUp(1)") end
	--self.completed = true
--end

c_findgatherable = inheritsFrom(ml_cause)
e_findgatherable = inheritsFrom(ml_effect)
c_findgatherable.nodeid = nil
function c_findgatherable:evaluate()
	local isInteracting = e("IsPlayerInteractingWithObject()")	
	if (InventoryFull() or isInteracting) then
		return false
	end
	
	local needsUpdate = false
	if ( ml_task_hub:CurrentTask().gatherid == nil or ml_task_hub:CurrentTask().gatherid == 0 ) then
		needsUpdate = true
	end
	
	local gatherable = EntityList:Get(ml_task_hub:CurrentTask().gatherid)
	if (ValidTable(gatherable)) then
		if (not eso_gather_manager.IsGatherable(gatherable) or IsBlacklisted(gatherable)) then
			needsUpdate = true
		end
	else
		needsUpdate = true
	end
	
	if (needsUpdate) then
		ml_task_hub:CurrentTask().gatherid = 0
		local node = eso_gather_manager.ClosestNode(true)
		if (ValidTable(node)) then
			c_findgatherable.nodeid = node.id
			return true
		end
	end
    
    return false
end
function e_findgatherable:execute()
	d("Updating task gatherid.")
	ml_task_hub:CurrentTask().gatherid = c_findgatherable.nodeid
end

c_gather = inheritsFrom(ml_cause)
e_gather = inheritsFrom(ml_effect)
function c_gather:evaluate()
	local numLootItems = e("GetNumLootItems()")
	local getLootMoney = e("GetLootMoney()")
	
	return (numLootItems > 0 or getLootMoney > 0)
end
function e_gather:execute()
	ml_log("e_gather")
	e("LootAll()")
	ml_task_hub:CurrentTask():SetDelay(math.random(500,1000))
	return ml_log(true)
end

c_movetogatherable = inheritsFrom(ml_cause)
e_movetogatherable = inheritsFrom(ml_effect)
e_movetogatherable.pos = {}
function c_movetogatherable:evaluate()
	local isInteracting = e("IsPlayerInteractingWithObject()")	
	if (InventoryFull() or isInteracting) then
		return false
	end
	
	--Reset tempvars.
	e_movetogatherable.pos = {}
	
	if ( ml_task_hub:CurrentTask().gatherid ~= nil and ml_task_hub:CurrentTask().gatherid ~= 0 ) then
        local gatherable = EntityList:Get(ml_task_hub:CurrentTask().gatherid)
        if (ValidTable(gatherable) and eso_gather_manager.IsGatherable(gatherable)) then	
			e_movetogatherable.pos = gatherable.pos
            return true
        end
    end

	return false
end
function e_movetogatherable:execute()
	local newTask = eso_task_movetointeract.Create()
	newTask.pos = e_movetogatherable.pos
	newTask.interact = ml_task_hub:CurrentTask().gatherid
	newTask.interactRange = 8
	newTask.avoidPlayers = true
	newTask.postDelay = 4000
	ml_task_hub:CurrentTask():AddSubTask(newTask)	
	
	return ml_log(false)
end

c_nextgathermarker = inheritsFrom( ml_cause )
e_nextgathermarker = inheritsFrom( ml_effect )
function c_nextgathermarker:evaluate()	
	if (gMarkerMgrMode == GetString("singleMarker")) then
		ml_task_hub:CurrentTask().filterLevel = false
	else
		ml_task_hub:CurrentTask().filterLevel = true
	end
	
    if ( ml_task_hub:CurrentTask().currentMarker ~= nil and ml_task_hub:CurrentTask().currentMarker ~= 0 ) then
		
        local marker = nil
        
        -- first check to see if we have no initiailized marker
        if (ml_task_hub:CurrentTask().currentMarker == false) then --default init value
            marker = ml_marker_mgr.GetNextMarker("GatherMarker", ml_task_hub:CurrentTask().filterLevel)
			if (marker == nil) then
				return false
			end	
		end
        
        -- next check to see if our level is out of range
        if (marker == nil) then
            if (ValidTable(ml_task_hub:CurrentTask().currentMarker)) then
                if 	(ml_task_hub:CurrentTask().filterLevel) and
					(ml_global_information.Player_Level < ml_task_hub:CurrentTask().currentMarker:GetMinLevel() or 
                    ml_global_information.Player_Level > ml_task_hub:CurrentTask().currentMarker:GetMaxLevel()) 
                then
                    marker = ml_marker_mgr.GetNextMarker("GatherMarker", ml_task_hub:CurrentTask().filterLevel)
                end
            end
        end
        
        -- last check if our time has run out
        if (marker == nil) then
			if (ValidTable(ml_task_hub:CurrentTask().currentMarker)) then
				local expireTime = ml_task_hub:CurrentTask().markerTime
				if (Now() > expireTime) then
					ml_debug("Getting Next Marker, TIME IS UP!")
					marker = ml_marker_mgr.GetNextMarker("GatherMarker", ml_task_hub:CurrentTask().filterLevel)
				else
					return false
				end
			end
        end
        
        if (ValidTable(marker)) then
            e_nextgathermarker.marker = marker
            return true
        end
    end
    
    return false
end
function e_nextgathermarker:execute()
	ml_global_information.currentMarker = e_nextgathermarker.marker
    ml_task_hub:CurrentTask().currentMarker = e_nextgathermarker.marker
    ml_task_hub:CurrentTask().markerTime = Now() + (ml_task_hub:CurrentTask().currentMarker:GetTime() * 1000)
	ml_global_information.MarkerTime = Now() + (ml_task_hub:CurrentTask().currentMarker:GetTime() * 1000)
    ml_global_information.MarkerMinLevel = ml_task_hub:CurrentTask().currentMarker:GetMinLevel()
    ml_global_information.MarkerMaxLevel = ml_task_hub:CurrentTask().currentMarker:GetMaxLevel()
	--gStatusMarkerName = ml_task_hub:ThisTask().currentMarker:GetName()
end
