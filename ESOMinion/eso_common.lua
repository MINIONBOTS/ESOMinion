--:======================================================================================================================================================================
--: eso_common
--:======================================================================================================================================================================
--: edited 9.8.2014
--: commonly used cne's used by multiple modes/ other cne's

--:===============================================================================================================
--: LootAll
--:===============================================================================================================  
-- original code

c_LootAll = inheritsFrom( ml_cause )
e_LootAll = inheritsFrom( ml_effect )
c_LootAll.ignoreLoot = false
c_LootAll.ignoreLootTmr = 0

function c_LootAll:evaluate()
	-- this is needed in order to make the loot window close when we cannot loot something, this is set in globals.lua event
    if ( c_LootAll.ignoreLootTmr ~= 0 ) then
		if ( ml_global_information.Now - c_LootAll.ignoreLootTmr > 1500 ) then
			c_LootAll.ignoreLootTmr = 0
			c_LootAll.ignoreLoot = false
		end
	end
	return c_LootAll.ignoreLoot == false and not ml_global_information.Player_InventoryFull and (
		tonumber(e("GetNumLootItems()")) > 0 or tonumber(e("GetLootMoney()")) > 0)
end

function e_LootAll:execute()
	ml_log("e_LootAll")
	e("LootAll()")
	return ml_log(false)	
end

--:===============================================================================================================
--: Loot
--:=============================================================================================================== 
-- original code

c_Loot = inheritsFrom( ml_cause )
e_Loot = inheritsFrom( ml_effect )

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
		local dist = Distance3D(ppos.x,ppos.y,ppos.z,rpos.x,rpos.y,rpos.z)
		
		if (rpos and dist > ml_global_information.randomdistance) then
			c_movetorandom.randompoint = rpos
			c_movetorandom.randompointreached = false
			return true
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
	
	return ml_log(false)
end

--:======================================================================================================================================================================
--: sprint
--:======================================================================================================================================================================
--: added 9.7.2014
--: add this function to any movement cne's that require a sprint option

function Sprint()
	if (ml_global_information.Player_Stamina.percent >= 99) then
		ml_global_information.Player_SprintingRecharging = false
	end
	
	if (gSprint == "1") then
		-- sprint is enabled
		if (not ml_global_information.Player_Sprinting) then
			if (ml_global_information.Player_Stamina.percent >= tonumber(gSprintStopThreshold) and not ml_global_information.Player_SprintingRecharging) then
				e("OnSpecialMoveKeyDown(1)")
				d("eso_common - > starting sprint")
				ml_global_information.Player_Sprinting = true
				ml_global_information.Player_SprintingRecharging = false
			end
		elseif (ml_global_information.Player_Sprinting) then
			if (ml_global_information.Player_Stamina.percent < tonumber(gSprintStopThreshold)) then
				e("OnSpecialMoveKeyUp(1)")
				d("eso_common - > stopping sprint, recharging")
				ml_global_information.Player_Sprinting = false
				ml_global_information.Player_SprintingRecharging = true
			end
			--derp check
			if  (ml_global_information.Player_Stamina.percent == 100 and Player:IsMoving() and not e("IsUnitInCombat(player)")) and (
				(ml_global_information.Now - ml_global_information.Player_SprintingTime) > 5000)
			then
				ml_global_information.Player_SprintingTime = ml_global_information.Now
				e("OnSpecialMoveKeyDown(1)")
				d("eso_common - > checking sprint")
				ml_global_information.Player_Sprinting = true
				ml_global_information.Player_SprintingRecharging = false
			end
		end
	else
		-- sprint is disabled
		if (ml_global_information.Player_Sprinting or ml_global_information.Player_SprintingRecharging) then
			e("OnSpecialMoveKeyUp(1)")
			d("eso_common - > stopping sprint, sprint disabled")
			ml_global_information.Player_Sprinting = false
			ml_global_information.Player_SprintingRecharging = false
		end
	end
end

--:======================================================================================================================================================================
--: mount
--:======================================================================================================================================================================
--: not added yet (todo)
--: add this function to any movement cne's that require a mount option

function Mount()
	return
end

--:======================================================================================================================================================================
--: dismount
--:======================================================================================================================================================================
--: not added yet (todo)
--: add this function to any movement cne's that require a dismount

function Dismount()
	return
end