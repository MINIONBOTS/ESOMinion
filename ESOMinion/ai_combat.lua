ai_combat = {}
ai_combat.combatMoveTmr = 0
ai_combat.combatEvadeTmr = 0
ai_combat.combatEvadeLastHP = 0

-- Attack Task
ai_combatAttack = inheritsFrom(ml_task)
ai_combatAttack.name = "CombatAttack"
function ai_combatAttack.Create()
    --ml_log("combatAttack:Create")
	local newinst = inheritsFrom(ai_combatAttack)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	newinst.targetID = 0
	
    return newinst
end
function ai_combatAttack:Init()
		
	-- Dead?
	--self:add(ml_element:create( "Dead", c_dead, e_dead, 225 ), self.process_elements)
		
	-- Looting
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
	
	-- Kill Target
	self:add(ml_element:create( "KillTarget", c_GotoAndKill, e_GotoAndKill, 100 ), self.process_elements)
		
	-- Check for other Targets
	self:add(ml_element:create( "GetNextTarget", c_GetNextTarget, e_GetNextTarget, 75 ), self.process_elements)
	
    self:AddTaskCheckCEs()
end
function ai_combatAttack:task_complete_eval()	
	if ( Player.isswimming == true or ( TableSize(EntityList:Get(ml_task_hub:CurrentTask().targetID)) == 0 and c_Aggro:evaluate() == false) ) then 
		Player:Stop()
		return true
	end
	return false
end
function ai_combatAttack:task_complete_execute()
   self.completed = true
end

---------
c_CombatTask = inheritsFrom( ml_cause )
e_CombatTask = inheritsFrom( ml_effect )
function c_CombatTask:evaluate()
	local target = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh")		
	return target ~= nil
end
function e_CombatTask:execute()
	ml_log("e_CombatTask ")
	local target = nil
	-- Weakest Aggro in CombatRange first	
	local TList = ( EntityList("lowesthealth,attackable,targetable,alive,aggro,nocritter,onmesh,maxdistance="..ml_global_information.AttackRange) )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			target = E
			d("Found new Aggro Target: "..(E.name).." ID:"..tostring(E.id))			
		end		
	end
		
	if ( not target ) then
		TList = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh")
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil ) then
				d("New Target: "..(E.name).." ID:"..tostring(E.id))
				
				--[[ Blacklist if we cant select it..happens sometimes when it is outside our select range
				if (e_SearchTarget.lastID == id ) then
					e_SearchTarget.count = e_SearchTarget.count+1
					if ( e_SearchTarget.count > 30 ) then
						e_SearchTarget.count = 0
						e_SearchTarget.lastID = 0
						mc_blacklist.AddBlacklistEntry(GetString("monsters"), E.contentID, E.name, ml_global_information.now + 60000)
						d("Seems we cant select/target/reach our target, blacklisting it for 60seconds..")
					end
				else
					e_SearchTarget.lastID = id
					e_SearchTarget.count = 0
				end]]
				target = E
			end		
		end
	end
	
	if (target) then
		Player:Stop()
		local newTask = ai_combatAttack.Create()
		newTask.targetID = target.id
		ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
	else
		ml_log("e_CombatTask found no target")
	end
	return ml_log(false)
end



------------
c_Aggro = inheritsFrom( ml_cause )
e_Aggro = inheritsFrom( ml_effect )
function c_Aggro:evaluate()
    return Player.isswimming == false and TableSize(EntityList("nearest,alive,aggro,attackable,maxdistance=28,onmesh")) > 0 
end
function e_Aggro:execute()
	ml_log("e_Aggro ")
	Player:Stop()
	local newTask = ai_combatAttack.Create()
	local EList = EntityList("nearest,alive,aggro,attackable,maxdistance=28,onmesh")
	if ( EList ) then
		local id,entity = next (EList)
		if (id and entity) then
			newTask.targetID = entity.id 
			ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
			return
		end		
	end
	ml_log("eAggro no target")
end


---------
c_resting = inheritsFrom( ml_cause )
e_resting = inheritsFrom( ml_effect )
c_resting.hpPercent = math.random(55,95)
function c_resting:evaluate()
	if ( Player.isswimming == false and Player.hp.percent < c_resting.hpPercent ) then		
		return true
	end	
	return false
end
function e_resting:execute()
	ml_log("e_resting.. ")
	c_resting.hpPercent = math.random(45,85)
		
	if ( Player:IsMoving() ) then
		Player:Stop()
	end
	
	mc_skillmanager.HealMe()
	return
end



---------
c_GotoAndKill = inheritsFrom( ml_cause )
e_GotoAndKill = inheritsFrom( ml_effect )
e_GotoAndKill.ismoving = false
function c_GotoAndKill:evaluate()
	local target = EntityList:Get(ml_task_hub:CurrentTask().targetID)
	if ( TableSize( target ) > 0 ) then
		return (Player.isswimming == false and target.alive and target.attackable and target.onmesh)
	end	
	return false
end
function e_GotoAndKill:execute()
	ml_log("e_GotoAndKill ")
	local target = EntityList:Get(ml_task_hub:CurrentTask().targetID)
	if ( TableSize( target ) > 0 ) then	
	
		local tpos = target.pos
		
		if ( target.distance > ml_global_information.AttackRange or not target.los or not eso_skillmanager.CanAttackTarget( target.id )) then
			-- Player:MoveTo(x,y,z,stoppingdistance,navsystem(normal/follow),navpath(straight/random),smoothturns)
			local navResult = tostring(Player:MoveTo(tpos.x,tpos.y,tpos.z,0.25+(target.radius/2),false,true,false))
			if (tonumber(navResult) < 0) then
				ml_log("CombatMovement result: "..tostring(navResult))
			end
			e_GotoAndKill.ismoving = true
			
		else
			if ( e_GotoAndKill.ismoving == true )then
				Player:SetTarget(target.id)
				Player:Stop()
				e_GotoAndKill.ismoving = false
			end
			
			Player:SetFacing(tpos.x,tpos.y,tpos.z)
			eso_skillmanager.AttackTarget( target.id )
			ml_log(true)
			--DoCombatMovement()
				
		end
	end
	ml_log(false)
end



---------
c_GetNextTarget = inheritsFrom( ml_cause )
e_GetNextTarget = inheritsFrom( ml_effect )
function c_GetNextTarget:evaluate()
	local target = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh")		
	return target ~= nil
end

function e_GetNextTarget:execute()
	ml_log("e_GetNextTarget ")
	-- Weakest Aggro in CombatRange first	
	local TList = ( EntityList("lowesthealth,attackable,targetable,alive,aggro,nocritter,onmesh,maxdistance="..ml_global_information.AttackRange) )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("Found new Aggro Target: "..(E.name).." ID:"..tostring(E.id))
			ml_task_hub:CurrentTask().targetID = E.id			
			return ml_log(true)			
		end		
	end
		
	-- Then nearest attackable Target
	--TList = ( EntityList("attackable,alive,nearest,onmesh,maxdistance=3500,exclude_contentid="..mc_blacklist.GetExcludeString(GetString("monsters"))))
	TList = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh")
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("New Target: "..(E.name).." ID:"..tostring(E.id))
			
			--[[ Blacklist if we cant select it..happens sometimes when it is outside our select range
			if (e_SearchTarget.lastID == id ) then
				e_SearchTarget.count = e_SearchTarget.count+1
				if ( e_SearchTarget.count > 30 ) then
					e_SearchTarget.count = 0
					e_SearchTarget.lastID = 0
					mc_blacklist.AddBlacklistEntry(GetString("monsters"), E.contentID, E.name, ml_global_information.now + 60000)
					d("Seems we cant select/target/reach our target, blacklisting it for 60seconds..")
				end
			else
				e_SearchTarget.lastID = id
				e_SearchTarget.count = 0
			end]]
			ml_task_hub:CurrentTask().targetID = E.id
			return ml_log(true)
		end		
	end
	return ml_log(false)
end
