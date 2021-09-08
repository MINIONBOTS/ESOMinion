c_lootbodies = inheritsFrom(ml_cause)
e_lootbodies = inheritsFrom(ml_effect)
c_lootbodies.index = 0
c_lootbodies.pos = nil
function c_lootbodies:evaluate()

	if InventoryFull() then
		return false
	end

	local isInteracting = Player.interacting	
	if (InventoryFull() or isInteracting or ml_global_information.Player_InCombat or not gLootBodies) then
		return false
	end
	
	--Reset tempvars.
	c_lootbodies.id = 0
	c_lootbodies.pos = nil
	
	local lootables = MEntityList("nearest,lootable,onmesh,maxdistance=30")
	if (ValidTable(lootables)) then
		local id,entity = next(lootables)
		if (ValidTable(entity) and not IsBlacklisted(entity)) then
			c_lootbodies.index = entity.index
			c_lootbodies.pos = entity.pos
			return true
		end
	end
	
	return false
end

function e_lootbodies:execute()
	local newTask = eso_task_movetointeract.Create()
	newTask.creator = "lootbodies"
	newTask.pos = c_lootbodies.pos
	newTask.interact = c_lootbodies.index
	newTask.interactRange = 4
	newTask.avoidPlayers = true
	newTask.checkLootable = true
	ml_task_hub:CurrentTask():AddSubTask(newTask)	
	return ml_log(false)	
end

--:======================================================================================================================================================================
--: movetorandom
--:======================================================================================================================================================================
--: added 9.7.2014
--: add this cne to move to a random position on the mesh

c_movetorandom = inheritsFrom(ml_cause)
e_movetorandom = inheritsFrom(ml_effect)
c_movetorandom.randompoint = nil
c_movetorandom.randompointreached = false
function c_movetorandom:evaluate()
	if (c_movetorandom.randompoint == nil) then
		local ppos = Player.pos
		local rpos = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,30,5000)
		
		if ValidTable(rpos) then
			local dist = Distance3D(ppos.x,ppos.y,ppos.z,rpos.x,rpos.y,rpos.z)
			
			if (rpos and dist > ml_global_information.randomdistance) then
				c_movetorandom.randompoint = rpos
				c_movetorandom.randompointreached = false
				return true
			end
		end
	else
		if (c_movetorandom.randompoint and not c_movetorandom.randompointreached) then			
			return true
		end		
	end
	
    return false
end

function e_movetorandom:execute()
	if (c_movetorandom.randompoint) then
		local ppos = Player.pos
		local rpos = c_movetorandom.randompoint
		
		if ValidTable(rpos) then
			local dist = Distance3D(ppos.x,ppos.y,ppos.z,rpos.x,rpos.y,rpos.z)
			
			if  (dist < ml_global_information.randomdistance) then
				c_movetorandom.randompointreached = true
				c_movetorandom.randompoint = nil
				return ml_log(true)
			else
				Mount()
				Sprint()
				ml_log("eso_common -> movetorandom, distance " .. math.floor(dist) .. " -> ")

				local result = Player:BuildPath(rpos.x,rpos.y,rpos.z) 
				if (tonumber(result) >= 0) then
					return ml_log(true)
				end
			end
		end
	end
	
	return ml_log(false)
end

c_dead = inheritsFrom(ml_cause)
e_dead = inheritsFrom(ml_effect)
function c_dead:evaluate()
	return Player.dead
end
function e_dead:execute()
	local haveSoulGems = select(9, e("GetDeathInfo()"))
	
	local newTask = eso_task_death.Create()
	newTask.useSoulGem = (haveSoulGems and g_usesoulgemtorevive == "1")
	ml_task_hub:Add(newTask, REACTIVE_GOAL, TP_IMMEDIATE)
	return ml_log(true)
end

c_rest = inheritsFrom(ml_cause)
e_rest = inheritsFrom(ml_effect)
function c_rest:evaluate()
	if  g_rest == "1" and
		not Player.dead and
		not ml_global_information.Player_InCombat and
		not IsSwimming() and
		not Player.iscasting
	then
		local hpp = ml_global_information.Player_Health.percent
		local mpp = ml_global_information.Player_Magicka.percent
		local spp = ml_global_information.Player_Stamina.percent
		
		if ((tonumber(g_resthp) > 0 and hpp < tonumber(g_resthp)) or
			(tonumber(g_restmp) > 0 and mpp < tonumber(g_restmp)) or
			(tonumber(g_restsp) > 0 and spp < tonumber(g_restsp)))
		then
			return true
		end
	end
	
	return false
end
function e_rest:execute()
	local newTask = eso_task_rest.Create()
	ml_task_hub:Add(newTask, REACTIVE_GOAL, TP_IMMEDIATE)
	return ml_log(true)
end

c_lockpick = inheritsFrom(ml_cause)
e_lockpick = inheritsFrom(ml_effect)
function c_lockpick:evaluate()
	if (gBotMode == GetString("assistMode") and gAssistDoLockpick == "0") then
		return false
	end
	
	local isInteracting = Player.interacting
	local lockTime = e("GetLockpickingTimeLeft()")
	
	return (isInteracting and lockTime > 0)
end
function e_lockpick:execute()
	local newTask = eso_task_lockpick.Create()
	ml_task_hub:Add(newTask, REACTIVE_GOAL, TP_IMMEDIATE)
end

c_walktopos = inheritsFrom( ml_cause )
e_walktopos = inheritsFrom( ml_effect )
c_walktopos.pos = 0
function c_walktopos:evaluate()
	
    if (ValidTable(ml_task_hub:CurrentTask().pos)) then		
		local myPos = Player.pos
		local gotoPos = ml_task_hub:CurrentTask().pos
		
		--Attempt to find better position
		local p,dist = NavigationManager:GetClosestPointOnMesh(gotoPos)
		if (p and p.distance < 5) then
			gotoPos = p
		end
		
		local range = ml_task_hub:CurrentTask().range or 0
		if (range > 0) then
			local distance = 0.0
			if(ml_task_hub:CurrentTask().use3d) then
				distance = Distance3D(myPos.x, myPos.y, myPos.z, gotoPos.x, gotoPos.y, gotoPos.z)
			else
				distance = Distance2D(myPos.x, myPos.z, gotoPos.x, gotoPos.z)
			end
		
			if (distance > ml_task_hub:CurrentTask().range) then
				c_walktopos.pos = gotoPos
				return true
			end
		else
			c_walktopos.pos = gotoPos
			return true
		end
    end
	
    return false
end
function e_walktopos:execute()
	if (ValidTable(c_walktopos.pos)) then
		local gotoPos = c_walktopos.pos
		local useFollow = ml_task_hub:CurrentTask().useFollowMovement or false
		local randomizePath = ml_task_hub:CurrentTask().useRandomPaths or false
		local smoothTurns = ml_task_hub:CurrentTask().smoothTurns or true
		
		local path = Player:MoveTo(tonumber(gotoPos.x),tonumber(gotoPos.y),tonumber(gotoPos.z),1.5,useFollow,randomizePath,smoothTurns)
		if (not tonumber(path)) then
			ml_debug("[e_walktopos] An error occurred in creating the path.")
		elseif (path >= 0) then
			ml_debug("[e_walktopos] A path with " .. path .. " points was created.")
		elseif (path <= -1 and path >= -10) then
			ml_debug("[e_walktopos] A path could not be created towards the goal.")
		end
	end
	c_walktopos.pos = 0
end

c_returntomarker = inheritsFrom( ml_cause )
e_returntomarker = inheritsFrom( ml_effect )
function c_returntomarker:evaluate()	
    if (ml_task_hub:CurrentTask().currentMarker ~= false and ml_task_hub:CurrentTask().currentMarker ~= nil) then
		local markerType = ml_task_hub:ThisTask().currentMarker:GetType()
        local myPos = Player.pos
        local pos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
        local distance = Distance2D(myPos.x, myPos.z, pos.x, pos.z)
		
		if (gBotMode == GetString("grindMode")) then
			local targetid = ml_task_hub:CurrentTask().targetid or 0
			local gatherid = ml_task_hub:CurrentTask().gatherid or 0
			if ((targetid == 0 and (gatherid == 0 or not gGather) and distance > 25)) then
				return true
			end
		end
		
        if (gBotMode == GetString("gatherMode")) then
			local gatherid = ml_task_hub:CurrentTask().gatherid or 0
			if ((gatherid == 0 and distance > 25)) then
				return true
			end
        end
	else
		d("Can't return, no marker set.")
    end
    
    return false
end
function e_returntomarker:execute()	
    local newTask = eso_task_movetopos.Create()
    local markerPos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
    local markerType = ml_task_hub:CurrentTask().currentMarker:GetType()
    newTask.pos = markerPos
    newTask.range = math.random(5,15)
	newTask.remainMounted = true
	newTask.abortFunction = function()
		if (gBotMode == GetString("grindMode")) then
			local newTarget = GetNearestGrind()
			if (ValidTable(newTarget)) then
				return true
			end
			
			if (gGather) then
				local node = eso_gather_manager.ClosestNode(true)
				if (ValidTable(node)) then
					return true
				end
			end
		end
		if (gBotMode == GetString("gatherMode")) then
			local node = eso_gather_manager.ClosestNode(true)
			if (ValidTable(node)) then
				return true
			end
		end
		return false
	end
    ml_task_hub:CurrentTask():AddSubTask(newTask)
end

c_aggro = inheritsFrom(ml_cause)
e_aggro = inheritsFrom(ml_effect)
c_aggro.targetid = 0
function c_aggro:evaluate()
	if (IsSwimming()) then
		return false
	end
	
	--Reset tempvars.
	c_aggro.targetid = 0
	
	local taskTarget = ml_task_hub:CurrentTask().targetid or 0
	
	local aggrolist = nil
	aggrolist = MEntityList("lowesthealth,alive,aggro,attackable,maxdistance=28,onmesh")
	
	if (not ValidTable(aggrolist)) then
		aggrolist = MEntityList("shortestpath,alive,aggro,attackable,maxdistance=28,onmesh")
	end
	
	if (not ValidTable(aggrolist)) then
		 aggrolist = MEntityList("nearest,alive,aggro,attackable,maxdistance=28,onmesh")
	end
	
	if (ValidTable(aggrolist)) then
		local id,entity = next(aggrolist)
		if (ValidTable(entity)) then
			if (taskTarget == 0 or taskTarget ~= entity.id) then
				c_aggro.targetid = entity.id
				return true
			end
		end
	end
	
    return false
end
function e_aggro:execute()
	d("Creating Aggro task.")
	ml_log("e_aggro ")
	
	SafeStop()
	local newTask = eso_task_combat.Create()
	newTask.targetID = c_aggro.targetid
	ml_task_hub:Add(newTask, REACTIVE_GOAL, TP_IMMEDIATE)
	
	ml_log("eAggro no target")
end

c_mount = inheritsFrom(ml_cause)
e_mount = inheritsFrom(ml_effect)
function c_mount:evaluate()
	--[[if (gUseMount == "1" and ai_mount:CanMount()) then
		local ppos = ml_global_information.Player_Position
		local pos = ml_task_hub:CurrentTask().pos
		local dist = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return dist > tonumber(gUseMountRange)
	end]]
	
	--[[if (ai_mount:CanDismount()) then
		local ppos = ml_global_information.Player_Position
		local pos = ml_task_hub:CurrentTask().pos
		local dist = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		local remainMounted = ml_task_hub:CurrentTask().remainMounted or false
		local dismountDistance = ml_task_hub:CurrentTask().dismountDistance or 15
		if (not remainMounted) then
			if (dist < dismountDistance) then
				return true
			end
		end
	end]]	
	
	return false
end
function e_mount:execute()
	if (ai_mount:CanMount()) then
		ai_mount:Mount()
	else
		ai_mount:Dismount()
	end
end

c_sprint = inheritsFrom(ml_cause)
e_sprint = inheritsFrom(ml_effect)
c_sprint.timer = 0
c_sprint.setRecharging = false
function c_sprint:evaluate()
	if (ml_global_information.Player_Stamina.percent > math.random(90,99) and ml_global_information.Player_SprintingRecharging) then
		ml_global_information.Player_SprintingRecharging = false
	end
	
	if (Now() < c_sprint.timer) then
		return false
	end
	
	if (Player.issprinting) then
		if (ml_global_information.Player_Stamina.percent < tonumber(gSprintStopThreshold)) then
			c_sprint.setRecharging = true
			return true
		elseif (ml_global_information.Player_InCombat or not Player:IsMoving() --[[or ai_mount:IsMounted()]]) then
			c_sprint.setRecharging = false
			return true
		end		
	else
		if (gSprint == "1" and not ai_mount:IsMounted()) then
			if (ml_global_information.Player_Stamina.percent >= tonumber(gSprintStopThreshold)) then
				if (not ml_global_information.Player_SprintingRecharging and not ml_global_information.Player_InCombat) then
					c_sprint.setRecharging = false
					return true
				end
			end
		end
	end
end
function e_sprint:execute()
	if (Player.issprinting) then
		d("Release the sprint key.")
		e("OnSpecialMoveKeyUp(1)")
	else
		d("Use the sprint key.")
		e("OnSpecialMoveKeyDown(1)")
	end
	ml_global_information.Player_SprintingRecharging = c_sprint.setRecharging
	c_sprint.timer = Now() + 1000
end

c_usepotion = inheritsFrom(ml_cause)
e_usepotion = inheritsFrom(ml_effect)
c_usepotion.slot = 0
e_usepotion.timer = 0
function c_usepotion:evaluate()
	if (Player.dead or 
		gPotionUse == "0" or 
		(gBotMode == GetString("assistMode") and gAssistUsePotions == "0") or
		not ml_global_information.Player_InCombat or
		Now() < e_usepotion.timer) 
	then
		return false
	end
	
	--Reset tempvars.
	c_usepotion.slot = 0
	
	local hpp = ml_global_information.Player_Health.percent
	local mpp = ml_global_information.Player_Magicka.percent
	local spp = ml_global_information.Player_Stamina.percent
	
	if (tonumber(IsNull(gPotionHP,0)) > 0 and hpp <= tonumber(IsNull(gPotionHP,0))) then
		local slot = FindHealthPotion()
		if (slot) then
			c_usepotion.slot = slot
			return true
		end
	end
	
	if (tonumber(IsNull(gPotionMP,0)) > 0 and mpp <= tonumber(IsNull(gPotionMP,0))) then
		local slot = FindMagickaPotion()
		if (slot) then
			c_usepotion.slot = slot
			return true
		end
	end
	
	if (tonumber(IsNull(gPotionSP,0)) > 0 and spp <= tonumber(IsNull(gPotionSP,0))) then
		local slot = FindStaminaPotion()
		if (slot) then
			c_usepotion.slot = slot
			return true
		end
	end
	
	return false
end
function e_usepotion:execute()
	local slot = tostring(c_usepotion.slot)
	e("OnSlotDown("..slot..")")
	e("OnSlotUp("..slot..")")
	e_usepotion.timer = Now() + 3000
end
c_loot = inheritsFrom( ml_cause )
e_loot = inheritsFrom( ml_effect )
c_loot.lootattempt = false
c_loot.timesince = 0
function c_loot:evaluate()
	if TimeSince(esominion.lootTime) < 500 then
		return false
	end
	if not gAssistLoot and (gBotMode == GetString("assistMode")) then
		return false
	end
	if c_loot.lootattempt then
		return true
	end
	return (Player.interacting and Player.interacttype == 2)
end
function e_loot:execute()
	if not c_loot.lootattempt then
		e("LootAll(true)")
		c_loot.lootattempt = true
		return 
	else
		e("EndLooting()")
	end
	c_loot.lootattempt = false
end

c_findaggro = inheritsFrom( ml_cause )
e_findaggro = inheritsFrom( ml_effect )
function c_findaggro:evaluate()

	if eso_gather.killtargetid ~= 0 then
		return false
	end
	if ml_task_hub:CurrentTask() then
		if IsNull(ml_task_hub:CurrentTask().targetID,0) ~= 0 then
			return false
		end
	end
	local targetList = EntityList("maxdistance=50,hostile,aggro")
	if table.valid(targetList) then
		local best = nil
		local lowestHP = math.huge
		for i,e in pairs(targetList) do
			if e.health.current > 0 then
				if not best or e.health.current < lowestHP then
					lowestHP = e.health.current
					best = e
				end
			end
		end
		if best then
			--eso_gather.killtargetid = best.index
			local target = MGetEntity(best.index)
			if table.valid(target) then
				local newTask = eso_task_combat.Create()
				newTask.targetID = target.index
				c_nextgrindobjective.task = newTask
				d("kill task")
				ml_task_hub:CurrentTask():AddSubTask(newTask)
				return true
			end
		end
	end
	
	return false
end
function e_findaggro:execute()
end
c_killaggro = inheritsFrom( ml_cause )
e_killaggro = inheritsFrom( ml_effect )
function c_killaggro:evaluate()
	if eso_gather.killtargetid == 0 then
		return false
	end
	if not table.valid(MGetEntity(eso_gather.killtargetid)) then
		eso_gather.killtargetid = 0
		return false
	end
	if IsSwimming() then
		return false
	end
	return true
end
function e_killaggro:execute()
	d("KILL!!!")
	if Player:IsMoving() then
		Player:StopMovement()
	end
	eso_gather.thisPosition = {}
	local target = MGetEntity(eso_gather.killtargetid)
	if target and target.health.current > 0 then
		local newTask = eso_task_combat.Create()
		newTask.targetID = target.index
		c_nextgrindobjective.task = newTask
		d("kill task 2")
		ml_task_hub:CurrentTask():AddSubTask(newTask)	
	else
		eso_gather.killtargetid = 0
	end
end

c_getmovementpath = inheritsFrom( ml_cause )
e_getmovementpath = inheritsFrom( ml_effect )
c_getmovementpath.lastFallback = 0
c_getmovementpath.lastGoal = {}
c_getmovementpath.lastOptimalPath = 0
function c_getmovementpath:evaluate()
	if not Player.onmesh then
		return false
	end
	if (table.valid(ml_task_hub:CurrentTask().pos) or table.valid(ml_task_hub:CurrentTask().gatePos)) then		
		local gotoPos = nil
		if (ml_task_hub:CurrentTask().gatePos) then
			gotoPos = ml_task_hub:CurrentTask().gatePos
			ml_debug("[c_getmovementpath]: Position adjusted to gate position.", "gLogCNE", 3)
		else
			gotoPos = ml_task_hub:CurrentTask().pos
			ml_debug("[c_getmovementpath]: Position left as original position.", "gLogCNE", 3)
		end
		
		if (table.valid(gotoPos)) then
			if (table.valid(ml_task_hub:CurrentTask().gatePos)) then
				local meshpos = FindClosestMesh(gotoPos,6,true)
				if (meshpos and meshpos.distance ~= 0 and meshpos.distance < 6) then
					ml_task_hub:CurrentTask().gatePos = meshpos
				end
			end
			
			local pathLength = 0
			local navid = IsNull(ml_task_hub:CurrentTask().navid,0)
			if not In(navid,0) then
				local getEntity = EntityList:Get(navid)
				if table.valid(getEntity) then
					gotoPos = getEntity.pos
				end
			end
			local targetid1 = IsNull(ml_task_hub:CurrentTask().targetid,0)
			if not In(targetid1,0) then
				local getEntity = EntityList:Get(targetid1)
				if table.valid(getEntity) then
					gotoPos = getEntity.pos
				end
			end
			local targetid2 = IsNull(ml_task_hub:CurrentTask().targetID,0)
			if not In(targetid2,0) then
				local getEntity = EntityList:Get(targetid2)
				if table.valid(getEntity) then
					gotoPos = getEntity.pos
				end
			end
			
			local dist = math.distance2d(gotoPos,Player.pos)
			if (table.valid(c_getmovementpath.lastGoal)) then
				ml_debug("new goal distance:"..tostring(math.distance3d(c_getmovementpath.lastGoal,gotoPos)))
			end
			
			if (pathLength <= 0) then
				-- attempt to get a path with no avoidance first
				if (TimeSince(c_getmovementpath.lastFallback) > 10000 or not table.valid(c_getmovementpath.lastGoal) or math.distance3d(c_getmovementpath.lastGoal,gotoPos) > 2) then
					pathLength = Player:BuildPath(tonumber(gotoPos.x), tonumber(gotoPos.y), tonumber(gotoPos.z),12,0,navid)
					if (pathLength > 0) then
						ml_debug("found optimal path")
						c_getmovementpath.lastOptimalPath = Now()
						--d("Pulled a path with no avoids: Last Fallback ["..tostring(TimeSince(c_getmovementpath.lastFallback)).."], goal dist ["..tostring(math.distance3d(c_getmovementpath.lastGoal,gotoPos)).."]")
						ml_debug("[GetMovementPath]: pathLength with no avoids and no borders = "..tostring(pathLength))
					end
				end
				if (pathLength <= 0) then
					pathLength = Player:BuildPath(tonumber(gotoPos.x), tonumber(gotoPos.y), tonumber(gotoPos.z),4,0,navid)
					if (pathLength > 0) then
						--d("found optimal path 2")
						c_getmovementpath.lastOptimalPath = Now()
						--d("Pulled a path with no avoids: Last Fallback ["..tostring(TimeSince(c_getmovementpath.lastFallback)).."], goal dist ["..tostring(math.distance3d(c_getmovementpath.lastGoal,gotoPos)).."]")
						ml_debug("[GetMovementPath]: pathLength with no borders = "..tostring(pathLength))
					end
				end
				
				if (TimeSince(c_getmovementpath.lastOptimalPath) > 2000 or not table.valid(c_getmovementpath.lastGoal) or math.distance3d(c_getmovementpath.lastGoal,gotoPos) > 2) then
					if (pathLength <= 0) then
						--d("found non-optimal path")
						ml_debug("[GetMovementPath]: rebuild last resort path..")
						pathLength = Player:BuildPath(tonumber(gotoPos.x), tonumber(gotoPos.y), tonumber(gotoPos.z),0,0,navid)
						c_getmovementpath.lastFallback = Now()
						c_getmovementpath.lastGoal = gotoPos
						ml_debug("[GetMovementPath]: pathLength cube path = "..tostring(pathLength))
					end
				end
			end
			
			if (pathLength > 0 or ml_navigation:HasPath()) then
				ml_debug("[GetMovementPath]: Path length returned ["..tostring(pathLength).."]")
				return false
			end
		else
			d("[GetMovementPath]: Invalid gotopos in current Task")
		end
	else
		d("[GetMovementPath]: Current Task does not have a valid position !")
	end
	
	d("[GetMovementPath]: We could not get a path to our destination.")
    return true
end
function e_getmovementpath:execute()
	-- Logic is reversed here, if we successfully updated the path, there's no reason to do anything.
	-- If no path was pulled, we should Stop() the character, because there's no reason to try mount/stealth/walk without any path.
	if (Player:IsMoving()) then
		Player:Stop()
	end
end

c_findnode = inheritsFrom( ml_cause )
e_findnode = inheritsFrom( ml_effect )
e_findnode.blockOnly = false
function c_findnode:evaluate()
	if table.valid(eso_gather.currenttask) then
		return false
	end
		
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
		eso_gather.currenttask = MGetEntity(gatherable.index)
		return true
	else
		--d("no gatherables")
	end
	--d("failed out")
	return false
end
function e_findnode:execute()
end

c_requiresstealth = inheritsFrom( ml_cause )
e_requiresstealth = inheritsFrom( ml_effect )
function c_requiresstealth:evaluate()
	if not ml_global_information.Player_Stealthed then
		if ml_task_hub:CurrentTask() and ml_task_hub:CurrentTask().requiresStealth then
			return true
		end
	else
		if ml_task_hub:CurrentTask() and not ml_task_hub:CurrentTask().requiresStealth then
			return true
		end
	end	
	return false
end
function e_requiresstealth:execute()



end
