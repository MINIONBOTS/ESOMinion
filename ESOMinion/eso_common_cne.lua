c_lootbodies = inheritsFrom(ml_cause)
e_lootbodies = inheritsFrom(ml_effect)
c_lootbodies.id = 0
c_lootbodies.pos = nil
function c_lootbodies:evaluate()
	local isInteracting = e("IsPlayerInteractingWithObject()")	
	if (InventoryFull() or isInteracting or ml_global_information.Player_InCombat or gLootBodies == "0") then
		return false
	end
	
	--Reset tempvars.
	c_lootbodies.id = 0
	c_lootbodies.pos = nil
	
	local lootables = EntityList("nearest,lootable,onmesh,maxdistance=30")
	if (ValidTable(lootables)) then
		local id,entity = next(lootables)
		if (ValidTable(entity) and not IsBlacklisted(entity)) then
			c_lootbodies.id = entity.id
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
	newTask.interact = c_lootbodies.id
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

				local result = tostring(Player:MoveTo(rpos.x,rpos.y,rpos.z,ml_global_information.randomdistance-1,false,false,false))
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
		not Player.isswimming and
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
c_lockpick.chamber = 0
function c_lockpick:evaluate()
	if (gBotMode == GetString("assistMode") and gAssistDoLockpick == "0") then
		return false
	end
	local isInteracting = e("IsPlayerInteractingWithObject()")
	local lockTime = e("GetLockpickingTimeLeft()")
	
	return (isInteracting and lockTime > 0)
end
function e_lockpick:execute()
	if c_lockpick.chamber == 0 then
		for i = 1,5 do
			local isChamberSolved = e("IsChamberSolved(" .. i .. ")")
			if (not isChamberSolved) then
				d("Start setting Chamber "..tostring(i)..".")
				e("StartSettingChamber(" .. i .. ")")
				e("PlaySound(Lockpicking_lockpick_contact)")
				e("PlaySound(Lockpicking_chamber_start)")
				c_lockpick.chamber = i
				ml_global_information.Await(500)
				return true
			end
		end
	else
		local chamberStress = e("GetSettingChamberStress()")
		if (chamberStress >= 0.2) then
			e("PlaySound(Lockpicking_chamber_stress)")
			e("StopSettingChamber()")
			d("Chamber "..tostring(c_lockpick.chamber).." is solved.")
			c_lockpick.chamber = 0
			ml_global_information.Await(1000)
			return true
		end
	end
end

c_walktopos = inheritsFrom( ml_cause )
e_walktopos = inheritsFrom( ml_effect )
c_walktopos.pos = 0
function c_walktopos:evaluate()
	--[[ -- FFXIV STUFF
	if (IsPositionLocked() or IsLoading() or IsMounting() or ControlVisible("SelectString") or ControlVisible("SelectIconString") or IsShopWindowOpen() or
		(ActionList:IsCasting() and not ml_task_hub:CurrentTask().interruptCasting)) 
	then
		return false
	end
	--]]
	
    if (ValidTable(ml_task_hub:CurrentTask().pos)) then		
		local myPos = Player.pos
		local gotoPos = ml_task_hub:CurrentTask().pos
		
		--Attempt to find better position
		local p,dist = NavigationManager:GetClosestPointOnMesh(gotoPos)
		if (p and dist < 5) then
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
			if ((targetid == 0 and (gatherid == 0 or gGather == "0") and distance > 25)) then
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
			
			if (gGather == "1") then
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
	if (Player.isswimming) then
		return false
	end
	
	--Reset tempvars.
	c_aggro.targetid = 0
	
	local taskTarget = ml_task_hub:CurrentTask().targetid or 0
	
	local aggrolist = nil
	aggrolist = EntityList("lowesthealth,alive,aggro,attackable,maxdistance=28,onmesh")
	
	if (not ValidTable(aggrolist)) then
		aggrolist = EntityList("shortestpath,alive,aggro,attackable,maxdistance=28,onmesh")
	end
	
	if (not ValidTable(aggrolist)) then
		 aggrolist = EntityList("nearest,alive,aggro,attackable,maxdistance=28,onmesh")
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
	if (gUseMount == "1" and ai_mount:CanMount()) then
		local ppos = ml_global_information.Player_Position
		local pos = ml_task_hub:CurrentTask().pos
		local dist = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return dist > tonumber(gUseMountRange)
	end
	
	if (ai_mount:CanDismount()) then
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
	end	
	
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
		elseif (ml_global_information.Player_InCombat or not Player:IsMoving() or ai_mount:IsMounted()) then
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
	
	if (tonumber(gPotionHP) > 0 and hpp <= tonumber(gPotionHP)) then
		local slot = FindHealthPotion()
		if (slot) then
			c_usepotion.slot = slot
			return true
		end
	end
	
	if (tonumber(gPotionMP) > 0 and mpp <= tonumber(gPotionMP)) then
		local slot = FindMagickaPotion()
		if (slot) then
			c_usepotion.slot = slot
			return true
		end
	end
	
	if (tonumber(gPotionSP) > 0 and spp <= tonumber(gPotionSP)) then
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