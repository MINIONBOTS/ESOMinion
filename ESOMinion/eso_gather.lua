--:======================================================================================================================================================================
--: eso_gather
--:======================================================================================================================================================================

eso_gather = inheritsFrom(ml_task)
eso_gather.name = "eso_gather"

function eso_gather.Create()

	local newinst = inheritsFrom(eso_gather)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	--eso_gather members
	
    return newinst
end

function eso_gather:Init()

	--process_elements
	self:add(ml_element:create( "Dead", c_dead, e_dead, 300 ), self.process_elements)
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)	
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 250 ), self.process_elements)
	self:add(ml_element:create( "Resting", c_resting, e_resting, 225 ), self.process_elements)	
	self:add(ml_element:create( "Vendor", c_Vendor, e_Vendor, 200 ), self.process_elements)
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
	self:add(ml_element:create( "Gather", c_gather, e_gather, 125 ), self.process_elements)
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
eso_gathertask.name = "eso_gathertask"

function eso_gathertask.Create()

	local newinst = inheritsFrom(eso_gathertask)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--eso_gather members
	newinst.nodepos = nil
	newinst.nodereached = false
	
    return newinst
end

--:======================================================================================================================================================================
--: gathertask init
--:======================================================================================================================================================================

function eso_gathertask:Init()

	--overwatch_elements
	self:add(ml_element:create( "gatherupdate", c_gatherwindow, e_gatherwindow, 10 ), self.overwatch_elements)
	self:add(ml_element:create( "gatherwindow", c_gatherwindow, e_gatherwindow, 5 ), self.overwatch_elements)
	
	--process_elements
	self:add(ml_element:create( "gathernode", c_gathernode, e_gathernode, 100 ), self.process_elements)
	self:add(ml_element:create( "movetonodepos", c_movetonodepos, e_movetonodepos, 50 ), self.process_elements)
	
    self:AddTaskCheckCEs()
end

--:======================================================================================================================================================================
--: gathertask eval
--:======================================================================================================================================================================

function eso_gathertask:task_complete_eval()

	--check if player is dead
	if (e("IsUnitDead(player)")) then
		d("eso_gathertask -> task_complete_eval (player dead)")
		return true
	end

	--check if aggro
	if (c_Aggro:evaluate()) then
		d("eso_gathertask -> task_complete_eval (aggro)")
		return true
	end

	--check if players inventory is full
	if (e("CheckInventorySpaceSilently(1)") == false) then
		d("eso_gathertask -> task_complete_eval (no bagspace)")
		return true
	end

	return false
end

function eso_gathertask:task_complete_execute()
	if (ml_global_information.Player_Sprinting) then e("OnSpecialMoveKeyUp(1)") end
	self.completed = true
end

--:======================================================================================================================================================================
--: gather
--:======================================================================================================================================================================

c_gather = inheritsFrom( ml_cause )
e_gather = inheritsFrom( ml_effect )
c_gather.throttle = 2500
c_gather.node = nil

function c_gather:evaluate()
	if (not ml_global_information.Player_InventoryFull) then
		local node = eso_gather_manager.ClosestNode()
		
		if (ValidTable(node)) then
			c_gather.node = node
			return true
		end
	end
	
	c_gather.node = nil
	return false
end

function e_gather:execute()
	if (c_gather.node) then
		local task = eso_gathertask.Create()
		task.nodepos = c_gather.node.pos
		ml_task_hub:Add(task.Create(), REACTIVE_GOAL, TP_ASAP)
		
		return ml_log(true)
	end
	
	return ml_log(false)
end

--:======================================================================================================================================================================
--: gatherupdate
--:======================================================================================================================================================================

c_gatherupdate = inheritsFrom(ml_cause)
e_gatherupdate = inheritsFrom(ml_effect)

function c_gatherupdate:evaluate()
	return false
end

function e_gatherupdate:execute()

end

--:======================================================================================================================================================================
--: gatherwindow
--:======================================================================================================================================================================

c_gatherwindow = inheritsFrom(ml_cause)
e_gatherwindow = inheritsFrom(ml_effect)

function c_gatherwindow:evaluate()
	return (e("GetNumLootItems()") > 0 or e("GetLootMoney()") > 0)
end

function e_gatherwindow:execute()
	ml_log("e_gatherwindow ")
	e("LootAll()")
	ml_global_information.Wait(250)	
	return ml_log(true)
end

--:======================================================================================================================================================================
--: 
--:======================================================================================================================================================================

c_gathernode = inheritsFrom(ml_cause)
e_gathernode = inheritsFrom(ml_effect)

function c_gathernode:evaluate()

	if not ml_task_hub:CurrentTask().nodereached then
		local ppos = Player.pos
		local npos = ml_task_hub:CurrentTask().nodepos
		local distance = Distance3D(ppos.x,ppos.y,ppos.z,npos.x,npos.y,npos.z)
		
		if distance <= ml_global_information.gatherdistance then
			ml_task_hub:CurrentTask().nodereached = true
		end
	end

	return ml_task_hub:CurrentTask().nodereached
end

function e_gathernode:execute()

	ml_log("e_gathernode ")
	
	if ml_task_hub:CurrentTask().nodereached then
		local node = eso_gather_manager.ClosestNode()
		
		if node and node.distance <= ml_global_information.gatherdistance then
			if not e("IsPlayerInteractingWithObject()") then
				Player:Interact(node.id)
				ml_global_information.Wait(500)	
			end
			return ml_log(true)
		else
			ml_task_hub:CurrentTask().completed = true
		end
	end
	
	return ml_log(false)
end

--:======================================================================================================================================================================
--: 
--:======================================================================================================================================================================

c_movetonodepos = inheritsFrom(ml_cause)
e_movetonodepos = inheritsFrom(ml_effect)

function c_movetonodepos:evaluate()

	if not ml_task_hub:CurrentTask().nodereached then
		local ppos = Player.pos
		local npos = ml_task_hub:CurrentTask().nodepos
		local distance = Distance3D(ppos.x,ppos.y,ppos.z,npos.x,npos.y,npos.z)
		
		if (distance > ml_global_information.gatherdistance) then
			return true
		end
	end

	return false
end

function e_movetonodepos:execute()

	ml_log("e_movetonodepos ")
	
	Sprint()
	local npos = ml_task_hub:CurrentTask().nodepos
	
	if (Player:MoveTo(npos.x,npos.y,npos.z,ml_global_information.gatherdistance-0.5,false,true,false) >= 0) then
		return ml_log(true)
	end
	
	return ml_log(false)
end
