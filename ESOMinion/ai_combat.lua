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
	newinst.targetPos = {}
	
    return newinst
end
function ai_combatAttack:Init()
		
	-- Dead?
	self:add(ml_element:create( "Dead", c_dead, e_dead, 300 ), self.process_elements)
	
	-- LootAll
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)	
	
	--Vendoring
	self:add(ml_element:create( "GetVendor", c_movetovendor, e_movetovendor, 200 ), self.process_elements)
	
	-- Looting
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
	
	-- use Mount
	self:add(ml_element:create( "UseMount", c_UseMount, e_UseMount,120 ), self.process_elements)
	
	-- Kill Target
	self:add(ml_element:create( "KillTarget", c_GotoAndKill, e_GotoAndKill, 100 ), self.process_elements)
		
	-- Check for other Targets
	self:add(ml_element:create( "GetNextTarget", c_GetNextTarget, e_GetNextTarget, 75 ), self.process_elements)
	
	
    self:AddTaskCheckCEs()
end
function ai_combatAttack:task_complete_eval()
	if ( Player.isswimming == true or (c_GotoAndKill:evaluate() == false and c_Aggro:evaluate() == false)) then 
		Player:Stop()
		return true
	end
	return false
end
function ai_combatAttack:task_complete_execute()
   self.completed = true
end

--------- Creates a new REACTIVE_GOAL subtask to kill an enemy
c_CombatTask = inheritsFrom( ml_cause )
e_CombatTask = inheritsFrom( ml_effect )
function c_CombatTask:evaluate()
	local target = EntityList("attackable,targetable,alive,nocritter,nearest,maxdistance=60,onmesh")		
	return Player.isswimming == false and target ~= nil and TableSize(target) > 0
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
		TList = EntityList("attackable,targetable,alive,nocritter,nearest,maxdistance=60,onmesh")
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil ) then
				d("New Target: "..(E.name).." ID:"..tostring(E.id).." Distance: "..tostring(E.distance))
				
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
		newTask.targetPos = target.pos		
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
    return Player.isswimming == false and TableSize(EntityList("nearest,alive,aggro,attackable,targetable,maxdistance=28,onmesh")) > 0 and ml_global_information.Player_InCombat
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
			newTask.targetPos = entity.pos			
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
	
	eso_skillmanager.Heal( Player.id )
	return
end


---------
c_UseMount = inheritsFrom( ml_cause )
e_UseMount = inheritsFrom( ml_effect )

function c_UseMount:evaluate()
	if(gMount == "1") then
		if ( (Player.isswimming == false) and (e("IsMounted()") == false) and (Player.iscasting == false) and e("GetNumStableSlots()") > 0 ) then
			local pPos = ml_global_information.Player_Position
			if ( Distance3D(ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y,ml_task_hub:CurrentTask().targetPos.z,ppos.x,ppos.y,ppos.z) > 35 ) then
				return true
			end
		end	
	end
	return false
end
function e_UseMount:execute()
	ml_log("e_useMount.. ")
		
	if ( Player:IsMoving() ) then
		Player:Stop()
	end
	e("ToggleMount()")
	ml_global_information.Wait(500)
	return
end


---------
c_GotoAndKill = inheritsFrom( ml_cause )
e_GotoAndKill = inheritsFrom( ml_effect )
e_GotoAndKill.ismoving = false
function c_GotoAndKill:evaluate()
	-- Check if the enemy is within the "data range" then check for the guy, else it can cause a back n forth spinning
	local ppos = ml_global_information.Player_Position
	if ( Distance3D(ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y,ml_task_hub:CurrentTask().targetPos.z,ppos.x,ppos.y,ppos.z) > 40 ) then
		-- IF the enemy is in our Elist, update our task position
		local target = EntityList:Get(ml_task_hub:CurrentTask().targetID)
		if ( TableSize( target ) > 0 ) then
			ml_task_hub:CurrentTask().targetPos = target.pos
		end			
		return true
	end
	-- We should be within the range and the target should be in our Elist
	local target = EntityList:Get(ml_task_hub:CurrentTask().targetID)
	if ( TableSize( target ) > 0 ) then
		return (Player.isswimming == false and target.alive and target.attackable and target.onmesh)		
	end	
	return false
end
function e_GotoAndKill:execute()
	ml_log("e_GotoAndKill ")

	-- Walk within a certain distance first before checking the enemy data in our Elist
	local ppos = ml_global_information.Player_Position
	if ( Distance3D(ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y,ml_task_hub:CurrentTask().targetPos.z,ppos.x,ppos.y,ppos.z) > 40 ) then
		ml_log(" Walking to Target ")
		-- Player:MoveTo(x,y,z,stoppingdistance,navsystem(normal/follow),navpath(straight/random),smoothturns)
		local navResult = tostring(Player:MoveTo(ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y,ml_task_hub:CurrentTask().targetPos.z,0.5,false,true,false))
		if (tonumber(navResult) < 0) then
			ml_log("Movement result: "..tostring(navResult))
			return ml_log(false)
		end
		return ml_log(true)
	end
	
	
	-- Goto n Attack our main target
	local target = EntityList:Get(ml_task_hub:CurrentTask().targetID)
	if ( TableSize( target ) > 0 ) then	
	
		local tpos = target.pos
		ml_task_hub:CurrentTask().targetPos = tpos
		
		if ( target.distance > ml_global_information.AttackRange or not target.los ) then		
			
			-- Check for better target while we walk towards out primary target
			local EList = EntityList("nearest,alive,aggro,attackable,targetable,los,maxdistance=12,onmesh,exclude="..ml_task_hub:CurrentTask().targetID)
			if ( EList ) then
				local id,entity = next (EList)
				if (id and entity) then
					-- switch to better target
					d("Switching to better target : "..entity.name.." "..tostring(entity.id))
					ml_task_hub:CurrentTask().targetID = entity.id
					target = entity
					tpos = target.pos
					ml_task_hub:CurrentTask().targetPos = tpos
				end
			end
			
			-- Player:MoveTo(x,y,z,stoppingdistance,navsystem(normal/follow),navpath(straight/random),smoothturns)
			local navResult = tostring(Player:MoveTo(tpos.x,tpos.y,tpos.z,0.5+(target.radius),false,true,false))
			if (tonumber(navResult) < 0) then
				ml_log("CombatMovement result: "..tostring(navResult))
				return ml_log(false)
			end
			e_GotoAndKill.ismoving = true
			return ml_log(true)
		else
			if ( e_GotoAndKill.ismoving == true )then				
				Player:Stop()
				e_GotoAndKill.ismoving = false
			end
			Player:SetFacing(tpos.x,tpos.y,tpos.z,false)
			Player:SetTarget(target.id)
			--Player:SetFacing(tpos.x,tpos.y+(tpos.height/2),tpos.z)
			eso_skillmanager.AttackTarget( target.id )
			return ml_log(true)
			--DoCombatMovement()
				
		end
	end
	ml_log(false)
end



---------
c_GetNextTarget = inheritsFrom( ml_cause )
e_GetNextTarget = inheritsFrom( ml_effect )
function c_GetNextTarget:evaluate()
	local minLevel = ml_global_information.MarkerMinLevel
    local maxLevel = ml_global_information.MarkerMaxLevel
    local whitelist = ml_global_information.WhitelistContentID --GetWhitelistIDString()
    local blacklist = ml_global_information.BlacklistContentID --GetBlacklistIDString()
	
	local el = nil;
	if (whitelist and whitelist ~= "") then
		el = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh,maxdistance=35,minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..whitelist)
    elseif (blacklist and blacklist ~= "") then
		el = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh,maxdistance=35,minlevel="..minLevel..",maxlevel="..maxLevel..",exclude_contentid="..blacklist)		
	else
		el = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh,maxdistance=35,minlevel="..minLevel..",maxlevel="..maxLevel)
	end
	
	return(ValidTable(el))
end

-------
function e_GetNextTarget:execute()
	ml_log("e_GetNextTarget ")
		
	local minLevel = ml_global_information.MarkerMinLevel
    local maxLevel = ml_global_information.MarkerMaxLevel
    local whitelist = ml_global_information.WhitelistContentID --GetWhitelistIDString()
    local blacklist = ml_global_information.BlacklistContentID --GetBlacklistIDString()
	local TList = nil
	
	-- Weakest Aggro in CombatRange first
	if (whitelist and whitelist ~= "") then	
		TList = EntityList("lowesthealth,attackable,targetable,alive,aggro,nocritter,onmesh,maxdistance="..ml_global_information.AttackRange..",minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..whitelist)
	elseif (blacklist and blacklist ~= "") then
		TList = EntityList("lowesthealth,attackable,targetable,alive,aggro,nocritter,onmesh,maxdistance="..ml_global_information.AttackRange..",minlevel="..minLevel..",maxlevel="..maxLevel..",exclude_contentid="..blacklist)
	else
		TList = EntityList("lowesthealth,attackable,targetable,alive,aggro,nocritter,onmesh,maxdistance="..ml_global_information.AttackRange..",minlevel="..minLevel..",maxlevel="..maxLevel)		
	end
	
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("Found new Aggro Target: "..(E.name).." ID:"..tostring(E.id))
			ml_task_hub:CurrentTask().targetID = E.id		
			ml_task_hub:CurrentTask().targetPos = E.pos
			return ml_log(true)			
		end		
	end
		
	-- Then nearest attackable Target
	if (whitelist and whitelist ~= "") then	
		TList = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh,maxdistance=35,minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..whitelist)
	elseif (blacklist and blacklist ~= "") then
		TList = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh,maxdistance=35,minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..blacklist)
	else
		TList = EntityList("attackable,targetable,alive,nocritter,nearest,onmesh,maxdistance=35,minlevel="..minLevel..",maxlevel="..maxLevel)	
	end
	--TList = ( EntityList("attackable,alive,nearest,onmesh,maxdistance=3500,exclude_contentid="..mc_blacklist.GetExcludeString(GetString("monsters"))))

	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("Next Target: "..(E.name).." ID:"..tostring(E.id) .." Distance: "..tostring(E.distance))
			
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
			ml_task_hub:CurrentTask().targetPos = E.pos
			return ml_log(true)
		end		
	end
	return ml_log(false)
end
