function SafeStop()
	if (Player.issprinting) then
		e("OnSpecialMoveKeyUp(1)")
	end
	Player:Stop()
end

function InventoryNearlyFull()
	return (ml_global_information.Player_InventoryFreeSlots <= 5)
end

function InventoryFull()
	return (ml_global_information.Player_InventoryFreeSlots < 1)
end

function InCombatRange(targetid)
	if (gBotRunning == "0") then
		return false
	end
	
	local target = {}
	--Quick change here to allow passing of a target or just the ID.
	if (type(targetid) == "table") then
		local id = targetid.id
		target = EntityList:Get(id)
		if (TableSize(target) == 0) then
			return false
		end
	else
		target = EntityList:Get(targetid)
		if (TableSize(target) == 0) then
			return false
		end
	end
	
	--If we're casting on the target, consider the player in-range, so that it doesn't attempt to move and interrupt the cast.
	local myTarget = Player:GetTarget()
	if (myTarget.id == target.id and Player.ischanneling) then
		return true
	end
	
	local attackRange = ml_global_information.AttackRange or 5
	return (target.distance <= (attackRange * .9))
end

function CanAttack(targetid)
	local target = {}
	--Quick change here to allow passing of a target or just the ID.
	if (type(targetid) == "table") then
		local id = targetid.id
		target = EntityList:Get(id)
		if (TableSize(target) == 0) then
			return false
		end
	else
		target = EntityList:Get(targetid)
		if (TableSize(target) == 0) then
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
	local blacklisted = EntityList:GetBlacklist()
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
			nearestAggro = entity.id
		end
	end
	
	return nearestAggro
end

function GetNearestGrind()
	local minLevel = ml_global_information.MarkerMinLevel
    local maxLevel = ml_global_information.MarkerMaxLevel
    local whitelist = ml_global_information.WhitelistContentID --GetWhitelistIDString()
    local blacklist = ml_global_information.BlacklistContentID --GetBlacklistIDString()
	
	local target = nil
	local el = nil
	-- Start out with aggro'd mobs.
	el = EntityList("lowesthealth,alive,aggro,attackable,maxdistance=28,onmesh")
	if (not ValidTable(el)) then
		el = EntityList("shortestpath,alive,aggro,attackable,maxdistance=28,onmesh")
	end
	if (not ValidTable(el)) then
		 el = EntityList("nearest,alive,aggro,attackable,maxdistance=28,onmesh")
	end
	
	if (not ValidTable(el)) then
		if (whitelist and whitelist ~= "") then
			d("Checking whitelist section.")
			el = EntityList("shortestpath,attackable,alive,nocritter,targeting=0,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..whitelist)
			if (not ValidTable(el)) then
				el = EntityList("nearest,attackable,alive,nocritter,targeting=0,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",contentid="..whitelist)
			end
		elseif (blacklist and blacklist ~= "") then
			d("Checking blacklist section.")
			local filterstring = "shortestpath,attackable,alive,nocritter,targeting=0,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",exclude_contentid="..blacklist
			if (gPreventAttackingInnocents == "1") then
				filterstring = filterstring..",hostile"
			end
			el = EntityList(filterstring)
			if (not ValidTable(el)) then
				filterstring = "nearest,attackable,alive,nocritter,targeting=0,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel..",exclude_contentid="..blacklist
				if (gPreventAttackingInnocents == "1") then
					filterstring = filterstring..",hostile"
				end
				el = EntityList(filterstring)
			end
		else
			local filterstring = "shortestpath,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel
			if (gPreventAttackingInnocents == "1") then
				filterstring = filterstring..",hostile"
			end
			el = EntityList(filterstring)
			if (not ValidTable(el)) then
				filterstring = "nearest,attackable,alive,nocritter,onmesh,minlevel="..minLevel..",maxlevel="..maxLevel
				if (gPreventAttackingInnocents == "1") then
					filterstring = filterstring..",hostile"
				end
				el = EntityList(filterstring)
			end
		end
	end
	
	if (ValidTable(el)) then
		local id,entity = next(el)
		if (ValidTable(entity)) then
			target = entity
		end
	else
		d("el was not valid.")
	end
	
	return target
end
