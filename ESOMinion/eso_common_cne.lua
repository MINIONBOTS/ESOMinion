
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