function SaveToFileX(path, ...)


local write, writeIndent, writers, refCount;

	
-- write thing (dispatcher)
write = function (file, item, level, objRefNames)
	writers[type(item)](file, item, level, objRefNames);
end;

-- write indent
writeIndent = function (file, level)
	for i = 1, level do
		file:write("\t");
	end;
end;

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1;
		else
			objRefCount[item] = 1;
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k);
				refCount(objRefCount, v);
			end;
		end;
	end;
end;

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (file, item)
			file:write("nil");
		end;
	["number"] = function (file, item)
			file:write(tostring(item));
		end;
	["string"] = function (file, item)
			file:write(string.format("%q", item));
		end;
	["boolean"] = function (file, item)
			if item then
				file:write("true");
			else
				file:write("false");
			end
		end;
	["table"] = function (file, item, level, objRefNames)
			local refIdx = objRefNames[item];
			if refIdx then
				-- Table with multiple references
				file:write("multiRefObjects["..refIdx.."]");
			else
				-- Single use table
				file:write("{\n");
				for k, v in table.pairsbykeys(item) do
					writeIndent(file, level+1);
					file:write("[");
					write(file, k, level+1, objRefNames);
					file:write("] = ");
					write(file, v, level+1, objRefNames);
					file:write(";\n");
				end
				writeIndent(file, level);
				file:write("}");
			end;
		end;
	["function"] = function (file, item)
			file:write("nil --[[function]]\n");			
		end;
	["thread"] = function (file, item)
			file:write("nil --[[thread]]\n");
		end;
	["userdata"] = function (file, item)
			file:write("nil --[[userdata]]\n");
		end;
}

	--function (path, ...)
		local file, e;
		if type(path) == "string" then
			-- Path, open a file
			file, e = io.open(path, "w");
			if not file then
				return error(e);
			end
		else
			-- Just treat it as file
			file = path;
		end
		local n = select("#", ...);
		-- Count references
		local objRefCount = {}; -- Stores reference that will be exported
		for i = 1, n do
			refCount(objRefCount, (select(i,...)));
		end;
		
		-- Export Objects with more than one ref and assign name
		-- First, create empty tables for each
		local objRefNames = {};
		local objRefIdx = 0;
		--[=[
		file:write("-- Persistent Data\n");
		file:write("local multiRefObjects = {\n");
		for obj, count in pairs(objRefCount) do
			if count > 99999999999999999 then
				objRefIdx = objRefIdx + 1;
				objRefNames[obj] = objRefIdx;
				file:write("{};"); -- table objRefIdx
			end;
		end;
		file:write("\n} -- multiRefObjects\n");
		-- Then fill them (this requires all empty multiRefObjects to exist)
		for obj, idx in pairs(objRefNames) do
			for k, v in pairs(obj) do
				file:write("multiRefObjects["..idx.."][");
				write(file, k, 0, objRefNames);
				file:write("] = ");
				write(file, v, 0, objRefNames);
				file:write(";\n");
			end;
		end;
		--]=]
		-- Create the remaining objects
		for i = 1, n do
			file:write("local ".."obj"..i.." = ");
			write(file, (select(i,...)), 0, objRefNames);
			file:write("\n");
		end
		-- Return them
		if n > 0 then
			file:write("return obj1");
			for i = 2, n do
				file:write(" ,obj"..i);
			end;
			file:write("\n");
		else
			file:write("return\n");
		end;
		file:close();
	--end;
end

function ConvertHeading(heading)
	local heading = heading -(1.5708)
	if (heading < 0) then
		return heading + 2 * math.pi
	else
		return heading
	end
end
function GetLowestValue(...)
	local lowestValue = math.huge
	
	local vals = {...}
	if (table.valid(vals)) then
		for k,value in pairs(vals) do
			if (value < lowestValue) then
				lowestValue = value
			end
		end
	end
	
	return lowestValue
end
function GetHighestValue(...)
	local highestValue = 0
	
	local vals = {...}
	if (table.valid(vals)) then
		for k,value in pairs(vals) do
			if (value > highestValue) then
				highestValue = value
			end
		end
	end
	
	return highestValue
end

function In(var,...)
	local var = var
	
	local args = {...}
	for i=1, #args do
		if (args[i] == var or (tonumber(var) ~= nil and tonumber(args[i]) == tonumber(var))) then
			return true
		end
	end
	
	return false
end

function HasBuff(list, buffName)
	if table.valid(list) and buffName then
		if list[buffNames] then
			return true
		end
	end
	return false
end

function MissingBuff(list, buffName)
	if table.valid(list) and buffName then
		if list[buffName] then
			return false
		end
	end
	return true
end

function HasBuffs(list, buffNames)
	if table.valid(list) and (buffNames and type(buffNames) == "string") then
		for _orids in StringSplit(buffNames,",") do
			if list[_orids] then
				return true
			end
		end
	end
	return false
end

function MissingBuffs(list, buffNames)
	if table.valid(list) and (buffNames and type(buffNames) == "string") then
		for _orids in StringSplit(buffNames,",") do
			if list[_orids] then
				return false
			end
		end
	end
	return true
end
function hasPet()
	if esominion.petalive ~= nil and TimeSince(esominion.petalivecheck) < 10000 then
		return esominion.petalive
	end
	local petAlive = e("DoesUnitExist(playerpet1)")
	esominion.petalive = petAlive
	esominion.petalivecheck = Now()
	return petAlive
end
function IsLootOpen()

	return esominion.lootOpen
end
function IsDead()

	return esominion.playerdead
end
function InCombat()

	return esominion.incombat
end
function LureIsSet()

	return esominion.lureType ~= 0
end
function SetBait(pondtype)
	local baitNum = e("GetNumFishingLures()")
	if baitNum > 0 then
		d("baitNum = "..tostring(baitNum))
		local baitfound = false
		for i = 1,9 do
			if not pondtype or (esominion.baits[i] == pondtype) or i == 1 then
				local baitInfo = e("GetFishingLureInfo("..i..")") 
				if baitInfo ~= "" then
					d("bait info found")
					d(baitInfo)
					e("SetFishingLure("..i..")")
					esominion.lureType = i
					baitfound = true
				end
			end
		end
		if not baitfound then
			esominion.lureType = 0
			return false
		end
	else
		d("no baits to set")
		esominion.lureType = 0
			return false
	end
	return true
end

function GetNearestFromList(strList,pos,radius,excludelist)
	local el = EntityList(strList)
	local excludelist = IsNull(excludelist,{})
	if (table.valid(el)) then
		
		local filteredList = {}
		for i,entity in pairs(el) do
			if not excludelist[entity.id] then
				local epos = entity.pos
				if (NavigationManager:IsReachable(epos)) then
					if (not radius or (radius >= 150)) then
						table.insert(filteredList,entity)
					else
						local dist = Distance2D(pos.x,pos.z,epos.x,epos.z)
						if (dist <= radius) then
							table.insert(filteredList,entity)
						end
					end
				else
					local ppos = Player.pos
					d("[GetNearestFromList]- Entity at ["..tostring(math.round(epos.x,0))..","..tostring(math.round(epos.y,0))..","..tostring(math.round(epos.z,0)).."] not reachable from ["..tostring(math.round(ppos.x,0))..","..tostring(math.round(ppos.y,0))..","..tostring(math.round(ppos.z,0)).."]")
				end
			end
		end
		
		if (table.valid(filteredList)) then
			table.sort(filteredList,function(a,b) return a.distance2d < b.distance2d end)
			for i,e in ipairs(filteredList) do
				if (i and e) then
					return e
				end
			end
		end
	end
	
	return nil
end

function FindClosestMesh(pos,distance)
	local minDist = IsNull(distance,10)
	
	local closest,closestDistance = nil, 100
	
	local p = NavigationManager:GetClosestPointOnMesh(pos)
	if (table.valid(p)) then
		if (p.distance <= minDist) then
			if (p.distance < closestDistance) then
				closest = p
			end
		end
	end
	
	if (closest) then
		return closest
	end
	
	return nil
end
function loot_update(eventName, eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen) 
	esominion.lootOpen = true
	esominion.lootTime = Now()
end
RegisterForEvent("EVENT_LOOT_RECEIVED", true)
RegisterEventHandler("GAME_EVENT_LOOT_RECEIVED", loot_update, "Loot Open")
function loot_close(eventName, eventCode) 
	esominion.lootOpen = false
end
RegisterForEvent("EVENT_LOOT_CLOSED", true)
RegisterEventHandler("GAME_EVENT_LOOT_CLOSED", loot_close, "Loot Closed")

function death_update_alive(eventName, eventCode) 
	esominion.playerdead = false
end
RegisterForEvent("EVENT_PLAYER_ALIVE", true)
RegisterEventHandler("GAME_EVENT_PLAYER_ALIVE", death_update_alive, "Death Update Alive")
function death_update_dead(eventName, eventCode) 
	esominion.playerdead = true
end
RegisterForEvent("EVENT_PLAYER_DEAD", true)
RegisterEventHandler("GAME_EVENT_PLAYER_DEAD", death_update_dead, "Death Update Dead")

function BuildBuffs(eventName, eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if In(changeType,"1","2") then
		if In(unitTag,"player") then
			esominion.playerbuffs = {}
			local pBuffCount = e("GetNumBuffs(player)")
			if pBuffCount > 0 then
				for buff = 1 , pBuffCount do
					local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = e("GetUnitBuffInfo(player, "..buff..")")
					esominion.playerbuffs[abilityId] = buffName
				end
			end
		end
		
		if In(unitTag,"reticleover") then
			esominion.targetbuffs = {}
			local tBuffCount = e("GetNumBuffs(reticleover)")
			if tBuffCount > 0 then
				for buff = 1, tBuffCount do
					local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer  = e("GetUnitBuffInfo(reticleover, "..buff..")")
					esominion.targetbuffs[abilityId] = buffName
				end
			end
		end
	end
end
RegisterForEvent("EVENT_EFFECT_CHANGED", true)
RegisterEventHandler("GAME_EVENT_EFFECT_CHANGED", BuildBuffs, "BuffChecks")
function changeCombatState(eventName, eventCode, inCombat)
d("in combat state changed")
	Player.incombat = toboolean(inCombat)
	esominion.incombat = toboolean(inCombat)
end
RegisterForEvent("EVENT_PLAYER_COMBAT_STATE", true)
RegisterEventHandler("GAME_EVENT_PLAYER_COMBAT_STATE", changeCombatState, "CombatState")

function addCombatTip(eventName, eventCode, activeCombatTipId)
	esominion.activeTip = tonumber(activeCombatTipId)
end
function removeCombatTip(eventName, eventCode, activeCombatTipId)
	esominion.activeTip = 0
end

RegisterForEvent("EVENT_DISPLAY_ACTIVE_COMBAT_TIP", true)
RegisterEventHandler("GAME_EVENT_DISPLAY_ACTIVE_COMBAT_TIP", addCombatTip, "CombatTipActive")
RegisterForEvent("EVENT_REMOVE_ACTIVE_COMBAT_TIP", true)
RegisterEventHandler("GAME_EVENT_REMOVE_ACTIVE_COMBAT_TIP", removeCombatTip, "CombatTipRemove")

function addLure(eventName, eventCode, fishingLure)
	esominion.lureType = tonumber(fishingLure)
end
function clearLure(eventName, eventCode)
	esominion.lureType = 0
	d("event clear bait")
end
RegisterForEvent("EVENT_FISHING_LURE_SET", true)
RegisterEventHandler("GAME_EVENT_FISHING_LURE_SET", addLure, "Lure Set")
RegisterForEvent("EVENT_FISHING_LURE_CLEARED", true)
RegisterEventHandler("GAME_EVENT_FISHING_LURE_CLEARED", clearLure, "Lure Clear")

function fish_bite(eventName, eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if itemSoundCategory == "39" then
		esominion.hooked = true
		esominion.hooktimer = Now()
	end
end
RegisterForEvent("EVENT_INVENTORY_SINGLE_SLOT_UPDATE", true)
RegisterEventHandler("GAME_EVENT_INVENTORY_SINGLE_SLOT_UPDATE", fish_bite, "fish Bite")

--[[
function update_skill_bar(eventName, eventCode, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory) 
	eso_skillmanager.needsrebuild = true
	d("rebuild due to slot change")
end
RegisterForEvent("EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED", true)
RegisterEventHandler("GAME_EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED", update_skill_bar, "update_skill_bar")

function update_skill_bar2(eventName, eventCode, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory) 
	eso_skillmanager.needsrebuild = true
	d("rebuild due to slot change 2")
end
RegisterForEvent("EVENT_HOTBAR_SLOT_CHANGE_REQUESTED", true)
RegisterEventHandler("GAME_EVENT_HOTBAR_SLOT_CHANGE_REQUESTED", update_skill_bar2, "update_skill_bar2")]]