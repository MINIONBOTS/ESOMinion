c_movetomap = inheritsFrom(ml_cause)
e_movetomap = inheritsFrom(ml_effect)
function c_movetomap:evaluate()
	return false
end
function e_movetomap:execute()
	-- add movetomap task
end

c_mount = inheritsFrom(ml_cause)
e_mount = inheritsFrom(ml_effect)
function c_mount:evaluate()
	if(gUseMount == "1" and ai_mount:CanMount() and not ai_mount:IsMounted()) then
		local ppos = ml_global_information.Player_Position
		local pos = self.pos
		local dist = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return dist > tonumber(gUseMountRange)
	end
	
	return false
	
end
function e_mount:execute()
	ai_mount:Mount()
end

c_walktopos = inheritsFrom(ml_cause)
e_walktopos = inheritsFrom(ml_effect)
function c_walktopos:evaluate()
	--[[if (IsLoading() or IsPositionLocked()) then
		return false
	end
	
	if ((ActionList:IsCasting() and not ml_task_hub:CurrentTask().interruptCasting) or IsMounting()) then
		return false
	end]]
	 
	local myPos = Player.pos
	local gotoPos = self.pos
	local distance = Distance3D(myPos.x, myPos.y, myPos.z, gotoPos.x, gotoPos.y, gotoPos.z)
	--d("Bot Position: ("..tostring(myPos.x)..","..tostring(myPos.y)..","..tostring(myPos.z)..")")
	--d("MoveTo Position: ("..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..")")
	--d("Current Distance: "..tostring(distance))
	--d("Execute Distance: "..tostring(ml_task_hub:CurrentTask().range))
	
	if (distance > self.range) then
		return true
	end
	
    return false
end
function e_walktopos:execute()
	local gotoPos = self.pos
	--d("Moving to ("..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..")")	
	--d("Move To vars"..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..","..tostring(ml_task_hub:CurrentTask().range *0.75)..","..tostring(ml_task_hub:CurrentTask().useFollowMovement or false)..","..tostring(gRandomPaths=="1"))
	local PathSize = Player:MoveTo(tonumber(gotoPos.x),tonumber(gotoPos.y),tonumber(gotoPos.z),tonumber(range), useFollowMovement or false, false)
	--d(tostring(PathSize))
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

		eso_skillmanager.Cast( target )
	end
end



