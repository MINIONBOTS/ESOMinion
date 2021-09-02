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
function SafeStop()
	if (Player.issprinting) then
		e("OnSpecialMoveKeyUp(1)")
	end
	Player:StopMovement()
end
function IsSwimming()
	return Player.isswimming == 1
end
	
function InventoryNearlyFull()
	return (ml_global_information.Player_InventoryFreeSlots <= 5)
end

function InventoryFull()
	return (ml_global_information.Player_InventoryFreeSlots < 1)
end

function InCombatRange(targetid)
	if (not ESO_Common_BotRunning) then
		return false
	end
	
	if IsSwimming() then
		return false
	end
	local target = {}
	--Quick change here to allow passing of a target or just the ID.
	if (type(targetid) == "table") then
		local id = targetid.index
		target = EntityList:Get(id)
		if not table.valid(target) then
			return false
		end
	else
		target = EntityList:Get(targetid)
		if not table.valid(target) then
		d("combat range false 2")
			return false
		end
	end
	
	--If we're casting on the target, consider the player in-range, so that it doesn't attempt to move and interrupt the cast.
	--[[local myTarget = Player:GetTarget()
	if (myTarget.id == target.id and Player.ischanneling) then
		return true
	end]]
	
	local attackRange = ml_global_information.AttackRange or 5
	return (target.distance <= (attackRange * .9))
end

function CanAttack(targetid)

	if IsSwimming() then
		return false
	end
		
	local target = {}
	--Quick change here to allow passing of a target or just the ID.
	if (type(targetid) == "table") then
		local id = targetid.index
		target = EntityList:Get(id)
		if not table.valid(target) then
			return false
		end
	else
		target = EntityList:Get(targetid)
		if not table.valid(target) then
			return false
		end
	end
	
	local canCast = false
	if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then				
		for k,v in pairs(eso_skillmanager.SkillProfile) do					
			-- Get Max Attack Range for global use
			if (v.skilltype == GetString("smsktypedmg")) then
				local skillid = eso_skillmanager.GetRealSkillID(v.skillID)
				if (AbilityList:IsTargetInRange(skillid,target.id) and AbilityList:CanCast(skillid,target.id) == 10) then
					canCast = true
					if canCast then break end
				end
			end				
		end
	end
	
	d("[CanCast()]:"..tostring(canCast))
	return canCast
end

function IsBlacklisted(entity)
	--local blacklisted = EntityList:GetBlacklist()
	if (ValidTable(blacklisted)) then
		for id,timeremaining in pairs(blacklisted) do
			if (id == entity.id) then
				return true
			end
		end
	end
	
	return false
end

function GetPosFromDistanceHeading(startPos, distance, heading)
	local head = math.rad(heading)
	local newX = distance * math.sin(head) + startPos.x
	local newZ = distance * math.cos(head) + startPos.z
	return {x = newX, y = startPos.y, z = newZ}
end

function GetNewDirection(strDirection)
	local ppos = Player.pos
	local h = ppos.facingangle
	
	local playerRight = (h - 90)
	local playerLeft = (h + 90)
	local playerRear = (h + 180)
	
	local playerRight = ((playerRight >= 0 and playerRight <= 360) and playerRight) or (playerRight + 360)
	local playerLeft = ((playerLeft >= 0 and playerLeft <= 360) and playerLeft) or (playerLeft - 360)
	local playerRear = ((playerRear >= 0 and playerRear <= 360) and playerRear) or (playerRear - 360)
	
	if (strDirection == "left") then
		return playerLeft
	elseif (strDirection == "right") then
		return playerRight
	elseif (strDirection == "backward") then
		return playerRear
	elseif (strDirection == "forward") then
		return h
	else
		return 0
	end
end

function IsMeshDirectionValid(strDirection, distance)	
	local distance = tonumber(distance) or 10
	local newHeading = GetNewDirection(strDirection)
	local newPos = GetPosFromDistanceHeading(Player.pos, distance, newHeading)
	
	local p,dist = NavigationManager:GetClosestPointOnMesh(newPos,false)
	if (p and dist < 6) then
		return true
	end
	
	return false
end

function GetValidRollDirections()
	local directions = {
		["forward"] = 1,
		["backward"] = 2,
		["left"] = 4,
		["right"] = 5,
	}
	
	if (gBotMode ~= GetString("assistMode")) then
		for direction,enum in pairs(directions) do
			if (not IsMeshDirectionValid(direction, 10)) then
				directions[direction] = nil
			end
		end
	end
	
	return directions
end

function GetRandomEntry(t)
	assert(ValidTable(t),"Table was not valid, or empty.")
	
	local tableSize = TableSize(t)
	local pick = math.random(1,tableSize)
	
	local index = 1
	for k,v in pairs(t) do
		if (index == pick) then
			return v
		end
		index = index + 1
	end
	
	return nil
end

function GetNearestAggro()
	local nearestAggro = nil
	
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
			nearestAggro = entity.id
		end
	end
	
	return nearestAggro
end

function GetNearestGrind()
	local minLevel = 1
    local maxLevel = ml_global_information.CurrentLevel + 2
    local whitelist = ml_global_information.WhitelistContentID
    local blacklist = ml_global_information.BlacklistContentID
	
	local target = nil
	local el = nil
	-- Start out with aggro'd mobs.
	el = MEntityList("lowesthealth,alive,aggro,attackable,maxdistance=28,onmesh")
	if (not ValidTable(el)) then
		el = MEntityList("shortestpath,alive,aggro,attackable,maxdistance=28,onmesh")
	end
	if (not ValidTable(el)) then
		 el = MEntityList("nearest,alive,aggro,attackable,maxdistance=28,onmesh")
	end
	
	if (not ValidTable(el)) then
		if (whitelist and whitelist ~= "") then
			el = MEntityList("shortestpath,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..whitelist)
			if (not ValidTable(el)) then
				el = MEntityList("nearest,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..whitelist)
			end
		elseif (blacklist and blacklist ~= "") then
			local filterstring = "shortestpath,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",exclude_contentid="..blacklist
			if (gPreventAttackingInnocents) then
				filterstring = filterstring..",hostile"
			end
			el = MEntityList(filterstring)
			if (not ValidTable(el)) then
				filterstring = "nearest,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",exclude_contentid="..blacklist
				if (gPreventAttackingInnocents) then
					filterstring = filterstring..",hostile"
				end
				el = MEntityList(filterstring)
			end
		else
			d("Checking other section.")
			local filterstring = "shortestpath,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel
			if (gPreventAttackingInnocents) then
				filterstring = filterstring..",hostile"
			end
			el = MEntityList(filterstring)
			if (not ValidTable(el)) then
				filterstring = "nearest,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel
				if (gPreventAttackingInnocents) then
					filterstring = filterstring..",hostile"
				end
				el = MEntityList(filterstring)
			end
			if (not ValidTable(el)) then
				filterstring = "nearest,attackable,alive,nocritter,onmesh"
				if (gPreventAttackingInnocents) then
					filterstring = filterstring..",hostile"
				end
				el = MEntityList(filterstring)
			end
		end
	end
	local best = nil
	local closest = math.huge
	local ppos = Player.pos
	if (ValidTable(el)) then
		for i,e in pairs(el) do
			if e.health.current > 0 then
				local dist = math.distance2d(ppos,e.pos)
				if dist < closest then
					closest = dist
					best = e
				end
			end
		end
		if best then
			target = best
		end
	else
		d("[GetNearestGrind]:Was unable to find valid targets.")
	end
	
	return target
end

function GetWeightedPotionTable(t, ideal)		
	local tSize = TableSize(t)
	local increments = (1 / tSize)
	
	--Need to determine if the ideal value's place in the list.
	local place = 0
	for i,value in pairsByKeys(t) do
		place = place + 1
		if (ideal == i) then
			break
		end
	end
	
	if (place == 1) then
		for i,weight in pairsByKeys(t) do
			local decrement = (i - place) * increments
			t[i] = (weight - decrement)
		end
	elseif (place == tSize) then
		for i,weight in pairsByKeys(t) do
			local decrement = (place - i) * increments
			t[i] = (1 - decrement)
		end
	else
		local wrapExtra = ((tSize - place) * increments)
		for i,weight in pairsByKeys(t) do
			if (i > place) then
				local decrement = (i - place) * increments
				t[i] = (weight - decrement)
			end
			if (i < place) then
				local decrement = (place - i) * increments
				t[i] = (weight - decrement - wrapExtra)
			end
		end
	end
	
	return t
end

function GetIdealPotion(percentage,available)
	--For now, since I'm a scrub, I'm just guessing that each level heals 10% more than the last, 
	--which should be a decent basis with 5 levels.
	--Will re-adjust as necessary
	local unweightedOptions = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
	}
	
	local weightedTable = nil
	if (percentage >= 90) then
		weightedTable = GetWeightedPotionTable(unweightedOptions, 1)
	elseif (percentage >= 75) then
		weightedTable = GetWeightedPotionTable(unweightedOptions, 2)
	elseif (percentage >= 60) then
		weightedTable = GetWeightedPotionTable(unweightedOptions, 3)
	elseif (percentage >= 45) then
		weightedTable = GetWeightedPotionTable(unweightedOptions, 4)
	else
		weightedTable = GetWeightedPotionTable(unweightedOptions, 5)
	end
	
	for strength,weight in pairsByKeys(weightedTable,function(a,b) return weightedTable[a] > weightedTable[b] end) do
		if (available[strength]) then
			return available[strength]
		end
	end
	
	return nil
end

function FindHealthPotion()
	local slots = {}
	
	for i = 9,16 do
		local slotIcon = e("GetSlotTexture("..tostring(i)..")")
		if (slotIcon:find("consumable_potion_001") ~= nil) then
			local strength = string.gsub(slotIcon,"/esoui/art/icons/consumable_potion_001_type_00","")
			strength = string.gsub(strength,".dds","")
			strength = tonumber(strength) or 1
			
			if (slots[strength] == nil) then
				local slotUsable = e("IsSlotUsable("..tostring(i)..")")
				local slotCooldownRemain, slotCooldownDuration, slotGlobal = e("GetSlotCooldownInfo("..tostring(i)..")")
				local slotItemCount = e("GetSlotItemCount("..tostring(i)..")")
				
				if (slotItemCount > 0 and slotUsable and slotCooldownRemain == 0) then
					slots[strength] = i
				end
			end
		end
	end
	
	if (ValidTable(slots)) then
		local hpp = ml_global_information.Player_Health.percent
		local idealSlot = GetIdealPotion(hpp,slots)
		return idealSlot
	end
	
	return nil
end

function FindMagickaPotion()
	local slots = {}
	
	for i = 9,16 do
		local slotIcon = e("GetSlotTexture("..tostring(i)..")")
		if (slotIcon:find("consumable_potion_002") ~= nil) then
			local strength = string.gsub(slotIcon,"/esoui/art/icons/consumable_potion_002_type_00","")
			strength = string.gsub(strength,".dds","")
			strength = tonumber(strength) or 1
			
			if (slots[strength] == nil) then
				local slotUsable = e("IsSlotUsable("..tostring(i)..")")
				local slotCooldownRemain, slotCooldownDuration, slotGlobal = e("GetSlotCooldownInfo("..tostring(i)..")")
				local slotItemCount = e("GetSlotItemCount("..tostring(i)..")")
				
				if (slotItemCount > 0 and slotUsable and slotCooldownRemain == 0) then
					slots[strength] = i
				end
			end
		end
	end
	
	if (ValidTable(slots)) then
		local hpp = ml_global_information.Player_Health.percent
		local idealSlot = GetIdealPotion(hpp,slots)
		return idealSlot
	end
	
	return nil
end

function FindStaminaPotion()
	local slots = {}
	
	for i = 9,16 do
		local slotIcon = e("GetSlotTexture("..tostring(i)..")")
		if (slotIcon:find("consumable_potion_003") ~= nil) then
			local strength = string.gsub(slotIcon,"/esoui/art/icons/consumable_potion_003_type_00","")
			strength = string.gsub(strength,".dds","")
			strength = tonumber(strength) or 1
			
			if (slots[strength] == nil) then
				local slotUsable = e("IsSlotUsable("..tostring(i)..")")
				local slotCooldownRemain, slotCooldownDuration, slotGlobal = e("GetSlotCooldownInfo("..tostring(i)..")")
				local slotItemCount = e("GetSlotItemCount("..tostring(i)..")")
				
				if (slotItemCount > 0 and slotUsable and slotCooldownRemain == 0) then
					slots[strength] = i
				end
			end
		end
	end
	
	if (ValidTable(slots)) then
		local hpp = ml_global_information.Player_Health.percent
		local idealSlot = GetIdealPotion(hpp,slots)
		return idealSlot
	end
	
	return nil
end

function BuildBuffsByIndex(index)
	local target = EntityList:Get(index)
	if table.valid(target) then
		if not esominion.buffList[index] then
			esominion.buffList[index] = {}
		end
		local buffCount = e("GetNumBuffs("..tostring(index)..")")
		if buffCount > 0 then
			for buff = 1 , buffCount do
				local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = e("GetUnitBuffInfo("..tostring(index)..", "..buff..")")
				esominion.buffList[index][abilityId] = buffName
			end
		end
	end
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
	if petAlive then
		local pet = EntityList:Get("playerpet1")
		if table.valid(pet) then
			esominion.petid = pet.id
		end
	end
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
		--d("baitNum = "..tostring(baitNum))
		local baitfound = false
		for i = 1,9 do
			if not pondtype or (esominion.baits[i] == pondtype) or i == 1 then
				local baitInfo = e("GetFishingLureInfo("..i..")") 
				if baitInfo ~= "" then
					e("SetFishingLure("..i..")")
					esominion.lureType = i
					baitfound = true
				end
			end
		end
		if not baitfound then
			esominion.lureType = 0
			d("no baits available")
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
	local el = MEntityList(strList)
	local excludelist = IsNull(excludelist,{})
	if (table.valid(el)) then
		
		local filteredList = {}
		for i,entity in pairs(el) do
			if not excludelist[entity.index] then
				local epos = entity.pos
				if (NavigationManager:IsReachable(epos)) and (entity.meshpos and entity.meshpos.meshdistance < 4) then
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
			else
				d("entity is excluded")
				d(entity.contentid)
				d(entity.index)
				
			end
		end
		
		if (table.valid(filteredList)) then
			table.sort(filteredList,function(a,b) return a.distance2d < b.distance2d end)
			for i,e in ipairs(filteredList) do
			d(e)
			d(e.name)
			d(e.contentid)
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
function loot_close(eventName, eventCode) 
	esominion.lootOpen = false
end

function death_update_alive(eventName, eventCode) 
	esominion.playerdead = false
end
function death_update_dead(eventName, eventCode) 
	esominion.playerdead = true
end

function changeCombatState(eventName, eventCode, inCombat)
d("in combat state changed")
	Player.incombat = toboolean(inCombat)
	esominion.incombat = toboolean(inCombat)
end

function addCombatTip(eventName, eventCode, activeCombatTipId)
	esominion.activeTip = tonumber(activeCombatTipId)
end
function removeCombatTip(eventName, eventCode, activeCombatTipId)
	esominion.activeTip = 0
end


function addLure(eventName, eventCode, fishingLure)
	esominion.lureType = tonumber(fishingLure)
end
function clearLure(eventName, eventCode)
	esominion.lureType = 0
	d("event clear bait")
end

function fish_bite(eventName, eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if itemSoundCategory == "39" then
		esominion.hooked = true
		esominion.hooktimer = Now()
	end
end
function loadEvents()

RegisterForEvent("EVENT_LOOT_RECEIVED", true)
RegisterEventHandler("GAME_EVENT_LOOT_RECEIVED", loot_update, "Loot Open")
RegisterForEvent("EVENT_LOOT_CLOSED", true)
RegisterEventHandler("GAME_EVENT_LOOT_CLOSED", loot_close, "Loot Closed")
RegisterForEvent("EVENT_PLAYER_ALIVE", true)
RegisterEventHandler("GAME_EVENT_PLAYER_ALIVE", death_update_alive, "Death Update Alive")
RegisterForEvent("EVENT_PLAYER_DEAD", true)
RegisterEventHandler("GAME_EVENT_PLAYER_DEAD", death_update_dead, "Death Update Dead")
RegisterForEvent("EVENT_PLAYER_COMBAT_STATE", true)
RegisterEventHandler("GAME_EVENT_PLAYER_COMBAT_STATE", changeCombatState, "CombatState")
RegisterForEvent("EVENT_DISPLAY_ACTIVE_COMBAT_TIP", true)
RegisterEventHandler("GAME_EVENT_DISPLAY_ACTIVE_COMBAT_TIP", addCombatTip, "CombatTipActive")
RegisterForEvent("EVENT_REMOVE_ACTIVE_COMBAT_TIP", true)
RegisterEventHandler("GAME_EVENT_REMOVE_ACTIVE_COMBAT_TIP", removeCombatTip, "CombatTipRemove")
RegisterForEvent("EVENT_FISHING_LURE_SET", true)
RegisterEventHandler("GAME_EVENT_FISHING_LURE_SET", addLure, "Lure Set")
RegisterForEvent("EVENT_FISHING_LURE_CLEARED", true)
RegisterEventHandler("GAME_EVENT_FISHING_LURE_CLEARED", clearLure, "Lure Clear")
RegisterForEvent("EVENT_INVENTORY_SINGLE_SLOT_UPDATE", true)
RegisterEventHandler("GAME_EVENT_INVENTORY_SINGLE_SLOT_UPDATE", fish_bite, "fish Bite")
end

