--:===============================================================================================================
--: LootAll
--:===============================================================================================================  

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

--:===============================================================================================================
--: movetorandom
--:===============================================================================================================  

c_MoveToRandomPoint = inheritsFrom( ml_cause )
e_MoveToRandomPoint = inheritsFrom( ml_effect )
c_MoveToRandomPoint.randomPoint = nil
c_MoveToRandomPoint.randomPointreached = false

function c_MoveToRandomPoint:evaluate()
	
	-- We dont have a current randomPoint to goto
	if ( c_MoveToRandomPoint.randomPoint == nil ) then
		local ppos = ml_global_information.Player_Position
		if ( TableSize(ppos)>0)then
			local p = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,30,5000)
			if ( p ) then
				if ( Distance3D(p.x,p.y,p.z,ppos.x,ppos.y,ppos.z) > 25 ) then
					c_MoveToRandomPoint.randomPoint = p
					c_MoveToRandomPoint.randomPointreached = false
					return true
				end
			end
		end
				
	else
		-- We haven't reached the current randomPoint
		if ( c_MoveToRandomPoint.randomPointreached == false) then			
			return true
		end		
	end			
    return false
end

function e_MoveToRandomPoint:execute()
	ml_log(" e_MoveToRandomPoint ")
		
	-- Move to our random Point
	if ( c_MoveToRandomPoint.randomPoint ~= nil ) then
		local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.z, c_MoveToRandomPoint.randomPoint.x, c_MoveToRandomPoint.randomPoint.z)

		if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
			ai_mount:Mount()
		end
		
		if  ( dist < 10) then
			-- We reached our random Point
			c_MoveToRandomPoint.randomPointreached = true
			c_MoveToRandomPoint.randomPoint = nil
			d("Reached Random Point...")
			return ml_log(true)
		else
			-- We need to reach our random Point yet
			local navResult = tostring(Player:MoveTo(c_MoveToRandomPoint.randomPoint.x,c_MoveToRandomPoint.randomPoint.y,c_MoveToRandomPoint.randomPoint.z,10,false,true,false))
			if (tonumber(navResult) < 0) then
				ml_log("e_MoveToRandomPoint result: "..tostring(navResult))
				return ml_log(false)
			end
			return ml_log(true)
		end
	
	else
		d("BUG in e_MoveToRandomPoint ... I guess..")
	end
	
	return ml_log(false)
end
