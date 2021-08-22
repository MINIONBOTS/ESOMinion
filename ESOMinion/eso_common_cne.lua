
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

function get_aggro_list()
	local targetList = MEntityList("maxdistance=20,hostile,aggro")
	if not table.valid(targetList) then
		targetList = MEntityList("maxdistance=20,hostile,targetingme")
	end
	if not table.valid(targetList) and hasPet() then
		if esominion.petid ~= 0 then
			targetList = MEntityList("maxdistance=20,hostile,targeting="..tostring(esominion.petid))
		end
	end
	return targetList
end

c_findaggro = inheritsFrom( ml_cause )
e_findaggro = inheritsFrom( ml_effect )
function c_findaggro:evaluate()
	if eso_gather.killtargetid ~= 0 then
		return false
	end
	
	local targetList = get_aggro_list()
	if table.valid(targetList) then
		local best = nil
		local lowestHP = math.huge
		for i,e in pairs(targetList) do
			if e.health.current > 0 then
				if e.health.current < lowestHP then
					lowestHP = e.health.current
					best = e
				end
			end
		end
		if best then
			eso_gather.killtargetid = best.index
			return best
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

	local targetList = get_aggro_list()
	if not table.valid(targetList) then
		eso_gather.killtargetid = 0
		return false
	else
		for _, target in pairs(targetList) do
			if target.index == eso_gather.killtargetid then
				return true
			else
				eso_gather.killtargetid = 0
				return false
			end
		end
	end
	if Player.isswimming ~= 0 then
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
		Player:SetFacing(target.id,true)
		eso_skillmanager.Cast( target )
	else
		eso_gather.killtargetid = 0
	end
end

c_checkspace = inheritsFrom( ml_cause )
e_checkspace = inheritsFrom( ml_effect )
function c_checkspace:evaluate()
	return not e("CheckInventorySpaceSilently(1)")
end
function e_checkspace:execute()
	d("Inventory space full, stopping bot...")
	ml_global_information.ToggleRun()
end

c_isdead = inheritsFrom( ml_cause )
e_isdead = inheritsFrom( ml_effect )

function c_isdead:evaluate()
	return e("IsUnitDead(player)")
end

-- Use soulgem to revive if ticked, else just respawn to shrine
function e_isdead:execute()
	local targetLevel = e("GetUnitEffectiveLevel(player)")
	local stackCount = select(3, e("GetSoulGemInfo(1," .. tostring(targetLevel) .. ")"))
	if AdvancedSettings.shouldUseSoulGem and stackCount > 0 then
		e("Revive()")
	else 
		-- 'R' key is the default to respawn on shrine, maybe change this in the future
		KeyDown(82)
		KeyUp(82)
	end
end