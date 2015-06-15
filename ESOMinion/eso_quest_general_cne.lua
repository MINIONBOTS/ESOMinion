c_movetomap = inheritsFrom(ml_cause)
e_movetomap = inheritsFrom(ml_effect)
function c_movetomap:evaluate()
	return false
end
function e_movetomap:execute()
	-- add movetomap task
end

c_handleaggro = inheritsFrom(ml_cause)
e_handleaggro = inheritsFrom(ml_effect)
function c_handleaggro:evaluate()
	if(self.ignoreAggro) then
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
			ml_global_information.Player_Sprinting = false
			ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
			return
		end		
	end
end

c_updatetarget = inheritsFrom(ml_cause)
e_updatetarget = inheritsFrom(ml_effect)
function c_updatetarget:evaluate()
	local target = EntityList:Get(self.targetid)
	if(ValidTable(target)) then
		local distance = Distance3D(target.pos.x, target.pos.y, target.pos.z, self.pos.x, self.pos.z)
		if(distance > 0) then
			self.newPos = target.pos
			return distance > 0
		end
	end
end
function e_updatetarget:execute()
	self.pos = self.newPos
	self.newPos = nil
end

c_movetotarget = inheritsFrom(ml_cause)
e_movetotarget = inheritsFrom(ml_effect)
function c_movetotarget:evaluate()
	local target = EntityList:Get(self.targetid)
	if(ValidTable(target)) then
		local tpos = target.pos
		if ( target.distance > ml_global_information.AttackRange or not target.los ) then		
			self.targetpos = tpos
			return true
		end
	end
end
function e_movetotarget:execute()	
	local rndPath = false
    if (target.distance>20) then rndPath = true else rndPath = false end					
	Player:MoveTo(tpos.x,tpos.y,tpos.z,0.5+(target.radius),false,rndPath,false)
end

c_attacktarget = inheritsFrom(ml_cause)
e_attacktarget = inheritsFrom(ml_effect)
function c_attacktarget:evaluate()
	local target = EntityList:Get(self.targetid)
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
	eso_skillmanager.Cast( target )
end



