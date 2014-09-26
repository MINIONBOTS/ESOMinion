--:======================================================================================================================================================================
--: eso_gather
--:======================================================================================================================================================================
--: added 9.7.2014
--: gathering botmode and associated cne's

eso_gather = inheritsFrom(ml_task)
eso_gather.name = "Gather"

function eso_gather.Create()

	local newinst = inheritsFrom(eso_gather)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	--eso_gather members
	newinst.currentMarker = nil
	
    return newinst
end

function eso_gather:Init()

	--process_elements
	self:add(ml_element:create( "Dead", c_dead, e_dead, 300 ), self.process_elements)
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)	
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 250 ), self.process_elements) --reactive queue
	self:add(ml_element:create( "Resting", c_resting, e_resting, 225 ), self.process_elements)	
	self:add(ml_element:create( "Vendor", c_Vendor, e_Vendor, 200 ), self.process_elements)
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
	self:add(ml_element:create( "Gathering", c_gather, e_gather, 125 ), self.process_elements)
	self:add( ml_element:create( "GatherMarker", c_MoveToGatherMarker, e_MoveToGatherMarker, 100 ), self.process_elements)
	self:add( ml_element:create( "movetorandom", c_movetorandom, e_movetorandom, 50 ), self.process_elements)
		
    self:AddTaskCheckCEs()
end

function eso_gather:task_complete_eval()	
	return false
end

function eso_gather:task_complete_execute()
    
end

if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("gatherMode")] = eso_gather
end

--:======================================================================================================================================================================
--: gathertask create
--:======================================================================================================================================================================

eso_gathertask = inheritsFrom(ml_task)
eso_gathertask.name = "eso_gather -> "

function eso_gathertask.Create()

	local newinst = inheritsFrom(eso_gathertask)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--eso_gather members
	newinst.pos = {}
	newinst.node = nil
	newinst.distance = nil
	newinst.pathdistance = nil
	
	newinst.interacting = nil
	newinst.interacttime = nil
	newinst.interacttimemax = 7500
	newinst.timedout = nil
	
	newinst.playeraround = nil
	newinst.nodegathered = nil
	newinst.nodemissing = nil
	
    return newinst
end

--:======================================================================================================================================================================
--: gathertask init
--:======================================================================================================================================================================

function eso_gathertask:Init()

	--overwatch_elements
	self:add(ml_element:create( "gatherupdate", c_gatherupdate, e_gatherupdate, 50 ), self.overwatch_elements)
	self:add(ml_element:create( "gatherwindow", c_gatherwindow, e_gatherwindow, 25 ), self.overwatch_elements)
	
	--process_elements
	self:add(ml_element:create( "gathernode", c_gathernode, e_gathernode, 100 ), self.process_elements)
	self:add(ml_element:create( "movetonode", c_movetonode, e_movetonode, 50 ), self.process_elements)
	
    self:AddTaskCheckCEs()
end

--:======================================================================================================================================================================
--: gathertask eval
--:======================================================================================================================================================================

function eso_gathertask:task_complete_eval()
	
	--end task if player is dead
	if (e("IsUnitDead(player)")) then
		d("eso_gather -> ending gather task, player is dead and needs to revive/release")
		return true
	end

	--end task if player is in combat
	if (e("IsUnitInCombat(player)")) then
		d("eso_gather -> ending gather task, player is in combat or has aggro")
		return true
	end

	--end task if player has no bagspace
	if (not e("CheckInventorySpaceSilently(1)")) then
		d("eso_gather -> ending gather task, player has no bag space")
		return true
	end
	
	--end task if time expired on the node
	if (ml_task_hub:CurrentTask().timedout) then
		d("eso_gather -> ending gather task, time expired")
		EntityList:AddToBlacklist(ml_task_hub:CurrentTask().node.id, 60000)	
		return true
	end
	
	--end task if node is occupied by another player
	if (ml_task_hub:CurrentTask().playeraround) then
		d("eso_gather -> ending gather task, node occupied")
		EntityList:AddToBlacklist(ml_task_hub:CurrentTask().node.id, 60000)	
		return true
	end
	
	--end task if node is already gathered
	if (ml_task_hub:CurrentTask().nodegathered) then
		d("eso_gather -> ending gather task, node gathered")
		EntityList:AddToBlacklist(ml_task_hub:CurrentTask().node.id, 60000)	
		return true
	end
	
	--end task if node is missing from entitylist
	if (ml_task_hub:CurrentTask().nodemissing) then
		d("eso_gather -> ending gather task, node is gone")
		EntityList:AddToBlacklist(ml_task_hub:CurrentTask().node.id, 60000)	
		return true
	end
	
	return false
end

function eso_gathertask:task_complete_execute()
	if (ml_global_information.Player_Sprinting) then e("OnSpecialMoveKeyUp(1)") end
	self.completed = true
end

--:======================================================================================================================================================================
--: gather(task)
--:======================================================================================================================================================================
--: adds the gather task to reactive queue
--: this should only be used in gather mode, there is a seperate "add task function" for grind mode

c_gather = inheritsFrom( ml_cause )
e_gather = inheritsFrom( ml_effect )
c_gather.throttle = 2500
c_gather.node = nil

function c_gather:evaluate()
	if (not ml_global_information.Player_InventoryFull) then
		local node = eso_gather_manager.ClosestNode()
		
		if ValidTable(node) then
			c_gather.node = node
			return true
		end
	end
	
	c_gather.node = nil
	return false
end

function e_gather:execute()
	ml_log("e_gather ")
	Player:Stop()
	
	local task = eso_gathertask.Create()
	
	if (c_gather.node) then
		task.node = c_gather.node
		task.id = c_gather.node.id
		task.pos = c_gather.node.pos
		task.interacting = false
		
		local dstr = (
			"eso_gather -> creating new gather task for " .. task.node.name .. ", " ..
			"id = " .. task.id .. ", " ..
			"distance = " .. math.floor(c_gather.node.distance) .. ", " ..
			"pathdistance = " .. math.floor(c_gather.node.pathdistance) .. "  "
		)
		
		d(dstr)
	end
	
	ml_task_hub:Add(task.Create(), REACTIVE_GOAL, TP_ASAP)
	return ml_log(true)
end

--:======================================================================================================================================================================
--: gatherupdate
--:======================================================================================================================================================================
--: updates the mathmatical information in overwatch in a single cne to be used in other cne's without recalculating (performance)

c_gatherupdate = inheritsFrom(ml_cause)
e_gatherupdate = inheritsFrom(ml_effect)

function c_gatherupdate:evaluate()

	--update the task distance
	if (ml_task_hub:CurrentTask().pos and Player.pos) then
		local tpos = ml_task_hub:CurrentTask().pos
		ml_task_hub:CurrentTask().distance = Distance3D(Player.pos.x,Player.pos.y,Player.pos.z,tpos.x,tpos.y,tpos.z)
	else
		ml_task_hub:CurrentTask().distance = nil
	end
	
	--update the task pathdistance
	if (ml_task_hub:CurrentTask().node and EntityList:Get(ml_task_hub:CurrentTask().node.id) and ml_task_hub:CurrentTask().node.pathdistance) then
		ml_task_hub:CurrentTask().pathdistance = ml_task_hub:CurrentTask().node.pathdistance
	else
		ml_task_hub:CurrentTask().pathdistance = nil
	end
	
	--update the task time information
	if (ml_task_hub:CurrentTask().interacttime and (ml_global_information.Now - ml_task_hub:CurrentTask().interacttime) > ml_task_hub:CurrentTask().interacttimemax) then 
		ml_task_hub:CurrentTask().timedout = true
	else
		ml_task_hub:CurrentTask().timedout = nil
	end
	
	--check if node is gathered
	if ((ml_task_hub:CurrentTask().pathdistance and ml_task_hub:CurrentTask().pathdistance <= ml_global_information.gatherdistance) or
		(ml_task_hub:CurrentTask().distance and ml_task_hub:CurrentTask().distance <= ml_global_information.gatherdistance)) and (EntityList:Get(ml_task_hub:CurrentTask().node.id) == nil)
	then
		ml_task_hub:CurrentTask().nodegathered = true
	else
		ml_task_hub:CurrentTask().nodegathered = false
	end
	
	--check if node is gone
	if ((ml_task_hub:CurrentTask().pathdistance and ml_task_hub:CurrentTask().pathdistance <= 15) or
		(ml_task_hub:CurrentTask().distance and ml_task_hub:CurrentTask().distance <= 15)) and (EntityList:Get(ml_task_hub:CurrentTask().node.id) == nil)
	then
		ml_task_hub:CurrentTask().nodemissing = true
	else
		ml_task_hub:CurrentTask().nodemissing = false
	end
	
	--check if players around
	if 	((ml_task_hub:CurrentTask().pathdistance and ml_task_hub:CurrentTask().pathdistance <= 15) or
		(ml_task_hub:CurrentTask().distance and ml_task_hub:CurrentTask().distance <= 15)) and (not ml_task_hub:CurrentTask().interacting)
	then
		local playeraround = false
		local players = EntityList("player,alive,friendly,maxdistance=30")
		if (TableSize(players) > 0) then
			local index,player = next(players)
			if (index and player) then
				if (player.type == g("UNIT_TYPE_PLAYER")) then
					local apos = player.pos
					local tpos = ml_task_hub:CurrentTask().pos
					local dist = Distance3D(apos.x,apos.y,apos.z,tpos.x,tpos.y,tpos.z)
					
					if (dist and dist <=5) then
						playeraround = true
					end
				end
			end
		end
		
		ml_task_hub:CurrentTask().playeraround = playeraround
	else
		ml_task_hub:CurrentTask().playeraround = false
	end
end

function e_gatherupdate:execute()

end

--:======================================================================================================================================================================
--: gatherwindow
--:======================================================================================================================================================================
--: gathers all items from the gatherwindow, even if autoloot is off in eso settings
--: todo: add advanced looting from gatherwindow (ignore junk)

c_gatherwindow = inheritsFrom(ml_cause)
e_gatherwindow = inheritsFrom(ml_effect)

function c_gatherwindow:evaluate()
	return (e("GetNumLootItems()") > 0 or e("GetLootMoney()") > 0)
end

function e_gatherwindow:execute()
	ml_log("e_gatherwindow, looting " .. ml_task_hub:CurrentTask().node.name .. " -> ")
	e("LootAll()")
	return ml_log(true)
end

--:======================================================================================================================================================================
--: gathernode
--:======================================================================================================================================================================
--: gathers the node when the bot is in interact range (set in ml_global_information)

c_gathernode = inheritsFrom(ml_cause)
e_gathernode = inheritsFrom(ml_effect)

function c_gathernode:evaluate()
	if 	(ml_task_hub:CurrentTask().pathdistance and ml_task_hub:CurrentTask().pathdistance <= ml_global_information.gatherdistance) or
		(ml_task_hub:CurrentTask().distance and ml_task_hub:CurrentTask().distance <= ml_global_information.gatherdistance)
	then
		return true
	end

	return false
end

function e_gathernode:execute()
	ml_log("e_gathernode, interacting with " .. ml_task_hub:CurrentTask().node.name .. " -> ")
	
	if (not e("IsPlayerInteractingWithObject()")) then	
		if (not ml_task_hub:CurrentTask().interacting) then
			ml_task_hub:CurrentTask().interacting = true
			ml_task_hub:CurrentTask().interacttime = ml_global_information.Now
		end
		
		Player:Interact(ml_task_hub:CurrentTask().node.id)
		ml_global_information.Wait(500)					
	end
	
	return ml_log(true)
end

--:======================================================================================================================================================================
--: movetonode
--:======================================================================================================================================================================

c_movetonode = inheritsFrom(ml_cause)
e_movetonode = inheritsFrom(ml_effect)

function c_movetonode:evaluate()
	if 	(ml_task_hub:CurrentTask().pathdistance and ml_task_hub:CurrentTask().pathdistance > ml_global_information.gatherdistance) or
		(ml_task_hub:CurrentTask().distance and ml_task_hub:CurrentTask().distance > ml_global_information.gatherdistance)
	then
		return true
	end

	return false
end

function e_movetonode:execute()
	if (ml_task_hub:CurrentTask().pathdistance) then
		ml_log("e_movetonode, " .. ml_task_hub:CurrentTask().node.name .. ", pathdistance " .. math.floor(ml_task_hub:CurrentTask().pathdistance) .. " -> ")
	else
		ml_log("e_movetonode, " .. ml_task_hub:CurrentTask().node.name .. ", distance " .. math.floor(ml_task_hub:CurrentTask().distance) .. " -> ")
	end
	
	Sprint()
	
	local tpos = ml_task_hub:CurrentTask().pos
	local result = tostring(Player:MoveTo(tpos.x,tpos.y,tpos.z,ml_global_information.gatherdistance-0.5,false,false,false))
	
	if (tonumber(result) >= 0) then
		return ml_log(true)
	end
	
	return ml_log(false)
end

--:======================================================================================================================================================================
--: movetogathermarker
--:======================================================================================================================================================================

c_movetogathermarker = inheritsFrom(ml_cause)
e_movetogathermarker = inheritsFrom(ml_effect)
c_movetogathermarker.reached = false
c_movetogathermarker.returned = false

function c_movetogathermarker:evaluate()
	return false
end

function e_movetogathermarker:execute()

end

--:======================================================================================================================================================================
--: gathermarker (need/want to redo this asap)
--:======================================================================================================================================================================

c_MoveToGatherMarker = inheritsFrom( ml_cause )
e_MoveToGatherMarker = inheritsFrom( ml_effect )
e_MoveToGatherMarker.reached = false
e_MoveToGatherMarker.returned = false

function c_MoveToGatherMarker:evaluate()
	
	local needmarker = false
	
	-- haven't reached, or reached and did not return to the marker
	if (ml_task_hub:CurrentTask().currentMarker and (not e_MoveToGatherMarker.reached or not e_MoveToGatherMarker.returned)) then
		return true
	end
	
	-- already reached and returned to the marker once
	if (ml_task_hub:CurrentTask().currentMarker and (e_MoveToGatherMarker.reached or e_MoveToGatherMarker.returned)) then
		needmarker = true
	end
	
	--check the timer
	local timeexpired = false
	if (ml_task_hub:CurrentTask().currentMarker) then
		if (ml_task_hub:CurrentTask().currentMarker:GetTime() and ml_task_hub:CurrentTask().currentMarker:GetTime() ~= 0) then
			if (TimeSince(ml_task_hub:CurrentTask().markerTime) > ml_task_hub:CurrentTask().currentMarker:GetTime() * 1000) then
				needmarker = true
			end
		end
	end
	
	--get a marker, if needed (and available)
	if (ml_task_hub:CurrentTask().currentMarker == nil or needmarker == true) then
		local newmarker = ml_marker_mgr.GetNextMarker("GatherMarker", false)
		if ValidTable(newmarker) then
			d("new marker")
			ml_task_hub:CurrentTask().currentMarker = newmarker
			ml_task_hub:CurrentTask().markerTime = ml_global_information.Now
			ml_global_information.MarkerTime = ml_global_information.Now
			e_MoveToGatherMarker.reached = false
			e_MoveToGatherMarker.returned = false
			return true
		end
	end

	return false
end

function e_MoveToGatherMarker:execute()
	ml_log(" e_MoveToGatherMarker ")

	if (ml_task_hub:CurrentTask().currentMarker ~= false and ml_task_hub:CurrentTask().currentMarker ~= nil) then
		
		local pos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
		local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.z, pos.x, pos.z)
		
		if  ( dist < 10 ) then
			if not e_MoveToGatherMarker.reached then
				e_MoveToGatherMarker.reached = true
			elseif e_MoveToGatherMarker.reached then
				if not e_MoveToGatherMarker.returned then
					e_MoveToGatherMarker.returned = true
				end
			end
			d("Reached current Marker...")
			return ml_log(true)		
		else
			Sprint()			
			local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,10,false,true,false))
			if (tonumber(navResult) < 0) then
				ml_log("e_MoveToMarker result: "..tostring(navResult))
				return ml_log(false)
			end
			
			return ml_log(true)
		end
	end
	
	return ml_log(false)
end
