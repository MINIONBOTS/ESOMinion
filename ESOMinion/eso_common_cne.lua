--:======================================================================================================================================================================
--: eso_common
--:======================================================================================================================================================================
--: edited 9.8.2014
--: commonly used cne's used by multiple modes/ other cne's

--:===============================================================================================================
--: LootAll
--:===============================================================================================================  
-- original code

c_lootcorpses = inheritsFrom(ml_cause)
e_lootcorpses = inheritsFrom(ml_effect)
c_lootcorpses.ignoreLoot = false
c_lootcorpses.ignoreLootTimer = 0
function c_lootcorpses:evaluate()
	-- this is needed in order to make the loot window close when we cannot loot something, this is set in globals.lua event
    if ( c_lootcorpses.ignoreLootTimer ~= 0 ) then
		if ( TimeSince(c_lootcorpses.ignoreLootTimer) > 1500 ) then
			c_lootcorpses.ignoreLootTimer = 0
			c_lootcorpses.ignoreLoot = false
		end
	end
	
	local money = e("GetLootMoney()")
	
	return (c_lootcorpses.ignoreLoot == false and 
		((not ml_global_information.Player_InventoryFull and tonumber(e("GetNumLootItems()")) > 0) or
		tonumber(money) > 0))
end

function e_lootcorpses:execute()
	ml_log("e_lootcorpses")
	e("LootAll()")
	return ml_log(false)	
end

--:===============================================================================================================
--: Loot
--:=============================================================================================================== 
-- original code

c_Loot = inheritsFrom(ml_cause)
e_Loot = inheritsFrom(ml_effect)

function c_Loot:evaluate()
	local blackliststring = ml_blacklist.GetExcludeString(GetString("monsters")) or ""
    return not ml_global_information.Player_InCombat and not ml_global_information.Player_InventoryFull and
		TableSize(EntityList("nearest,lootable,onmesh,maxdistance=50,exclude="..blackliststring)) > 0
end

function e_Loot:execute()
	ml_log("e_Loot")
	local CharList = EntityList("lootable,shortestpath,onmesh")
	if ( TableSize(CharList) > 0 ) then
		local id,entity = next (CharList)
		if ( id and entity ) then
			local tPos = entity.pos
			
			if ( entity.distance > 2) then
				-- MoveIntoInteractRange				
				if ( tPos ) then					
					local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,1.5,false,false,false))		
					if (tonumber(navResult) < 0) then
						d("e_Loot.MoveIntoCombatRange result: "..tonumber(navResult))					
					end
					ml_log("MoveToLootable..")
					return ml_log(true)
				end
			else
				-- Grab that thing
				Player:Stop()				
				Player:Interact( entity.id )
				ml_log("Looting..")
				ml_global_information.Wait(500)
				return ml_log(true)
			end
		end
	end
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
	return e("IsUnitDead(player)")
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
		not e("IsUnitDead(player)") and
		not e("IsUnitInCombat(player)") and
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
function c_lockpick:evaluate()
	if (gBotMode == GetString("assistMode") and gAssistDoLockpick == "0") then
		return false
	end
	
	local isInteracting = e("IsPlayerInteractingWithObject()")
	local lockTime = e("GetLockpickingTimeLeft()")
	
	return (isInteracting and lockTime > 0)
end
function e_lockpick:execute()
	local newTask = eso_task_lockpick.Create()
	ml_task_hub:Add(newTask, REACTIVE_GOAL, TP_IMMEDIATE)
end



