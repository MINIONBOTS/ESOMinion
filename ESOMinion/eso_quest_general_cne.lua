c_movetointeract = ml_cause.Create()
e_movetointeract = ml_effect.Create()
function c_movetointeract:evaluate()
	local pos = self.task.pos
	if(ValidTable(pos)) then
		local ppos = Player.pos
		local distance = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return distance > 5
	end
	
	return false
end
function e_movetointeract:execute()	
	local moveTask = eso_task_moveto_interact.Create()
	if(ValidTable(moveTask)) then
		moveTask.pos = self.task.pos
		self.task:AddSubTask(moveTask)
	end
end

c_movetomap = ml_cause.Create()
e_movetomap = ml_effect.Create()
function c_movetomap:evaluate()
	return false
end
function e_movetomap:execute()
	-- add movetomap task
end

c_mount = ml_cause.Create()
e_mount = ml_effect.Create()
function c_mount:evaluate()
	if(gUseMount == "1" and ai_mount:CanMount() and not ai_mount:IsMounted()) then
		local ppos = ml_global_information.Player_Position
		local pos = self.task.pos
		local dist = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return dist > tonumber(gUseMountRange)
	end
	
	return false
	
end
function e_mount:execute()
	ai_mount:Mount()
end

c_walktopos = ml_cause.Create()
e_walktopos = ml_effect.Create()
function c_walktopos:evaluate()
	--[[if (IsLoading() or IsPositionLocked()) then
		return false
	end
	
	if ((ActionList:IsCasting() and not ml_task_hub:CurrentTask().interruptCasting) or IsMounting()) then
		return false
	end]]
	 
	local myPos = Player.pos
	local gotoPos = self.task.pos
	local distance = Distance3D(myPos.x, myPos.y, myPos.z, gotoPos.x, gotoPos.y, gotoPos.z)
	--d("Bot Position: ("..tostring(myPos.x)..","..tostring(myPos.y)..","..tostring(myPos.z)..")")
	--d("MoveTo Position: ("..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..")")
	--d("Current Distance: "..tostring(distance))
	--d("Execute Distance: "..tostring(ml_task_hub:CurrentTask().range))
	
	if (distance > self.task.range) then
		return true
	end
	
    return false
end
function e_walktopos:execute()
	local gotoPos = self.task.pos
	--d("Moving to ("..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..")")	
	--d("Move To vars"..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..","..tostring(ml_task_hub:CurrentTask().range *0.75)..","..tostring(ml_task_hub:CurrentTask().useFollowMovement or false)..","..tostring(gRandomPaths=="1"))
	local PathSize = Player:MoveTo(tonumber(gotoPos.x),tonumber(gotoPos.y),tonumber(gotoPos.z),tonumber(range), self.task.useFollowMovement or false, false)
	--d(tostring(PathSize))
end

c_handleaggro = ml_cause.Create()
e_handleaggro = ml_effect.Create()
function c_handleaggro:evaluate()
	if(self.task.ignoreAggro) then
		return false
	end
	
	return Player.isswimming == false and TableSize(EntityList("nearest,alive,aggro,attackable,hostile,targetable,maxdistance=28,onmesh")) > 0
end
function e_handleaggro:execute()
	Player:Stop()
	local newTask = eso_task_killtarget.Create()
	local EList = EntityList("nearest,alive,aggro,hostile,attackable,maxdistance=28,onmesh")
	if ( EList ) then
		local id,entity = next (EList)
		if (id and entity) then
			newTask.targetID = entity.id 
			newTask.targetPos = entity.pos
			e("OnSpecialMoveKeyUp(1)")
			ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
			return
		end		
	end
end

c_updatetarget = ml_cause.Create()
e_updatetarget = ml_effect.Create()
function c_updatetarget:evaluate()
	local target = EntityList:Get(self.task.targetid)
	if(ValidTable(target)) then
		local distance = Distance3D(target.pos.x, target.pos.y, target.pos.z, self.task.pos.x, self.task.pos.z)
		if(distance > 0) then
			self.element.newPos = target.pos
			return distance > 0
		end
	end
end
function e_updatetarget:execute()
	self.task.pos = self.element.newPos
	self.element.newPos = nil
end

c_movetotarget = ml_cause.Create()
e_movetotarget = ml_effect.Create()
function c_movetotarget:evaluate()
	local target = EntityList:Get(self.task.targetid)
	if(ValidTable(target)) then
		local tpos = target.pos
		if ( target.distance > ml_global_information.AttackRange or not target.los ) then		
			self.task.targetpos = tpos
			return true
		end
	end
end
function e_movetotarget:execute()	
	local rndPath = false
    if (target.distance>20) then rndPath = true else rndPath = false end					
	Player:MoveTo(tpos.x,tpos.y,tpos.z,0.5+(target.radius),false,rndPath,false)
end

c_attacktarget = ml_cause.Create()
e_attacktarget = ml_effect.Create()
function c_attacktarget:evaluate()
	local target = EntityList:Get(self.task.targetid)
	if(ValidTable(target)) then
		local tpos = target.pos
		if ( target.distance <= ml_global_information.AttackRange and target.los ) then	
			return true
		end
	end
	
	return false
end
function e_attacktarget:execute()
	Player:SetFacing(tpos.x,tpos.y,tpos.z,false)
	Player:SetTarget(target.id)
	
	if ( not eso_skillmanager.Heal( Player.id ) ) then

		--[[if not ml_task_hub:CurrentTask().timestarted then
			ml_task_hub:CurrentTask().timestarted = ml_global_information.Now
		end
	
		local timediff = ml_global_information.Now - ml_task_hub:CurrentTask().timestarted
		
		if  timediff > 30000
			and target.alive
			and target.hp.current == 0
		then
			d("Blacklisting Target " .. target.id)
			EntityList:AddToBlacklist(target.id, 300000)
			ml_task_hub:CurrentTask().completed = true
			return ml_log(false)
		end]]

		eso_skillmanager.AttackTarget( target.id )
	end
end

c_endinteract = ml_cause.Create()
e_endinteract = ml_effect.Create()
function c_endinteract:evaluate()
	local interactionType = e("GetInteractionType()")
	if(tonumber(interactionType) > 0) then
		self.element.interactionType = interactionType
		return true
	end
	
	return false
end
function e_endinteract:execute()	
	e("EndInteraction("..tostring(self.element.interactionType)..")")
end


