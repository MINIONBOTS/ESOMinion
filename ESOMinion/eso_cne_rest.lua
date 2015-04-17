--:======================================================================================================================================================================
--: rest
--:======================================================================================================================================================================

c_rest = ml_cause.Create()
e_rest = ml_effect.Create()

--:============================================================================================
--: cause
--:============================================================================================

function c_rest:evaluate()
	if  g_rest == "1" and
		not e("IsUnitDead(player)") and
		not e("IsUnitInCombat(player)") and
		not Player.isswimming and
		not Player.iscasting
	then
		local hp = {e("GetUnitPower(player,"..tostring(g("POWERTYPE_HEALTH"))..")")}
		hp.percent = hp[1]*100/hp[3]
		local mp = {e("GetUnitPower(player,"..tostring(g("POWERTYPE_MAGICKA"))..")")}
		mp.percent = mp[1]*100/mp[3]
		local sp = {e("GetUnitPower(player,"..tostring(g("POWERTYPE_STAMINA"))..")")}
		sp.percent = sp[1]*100/sp[3]
		
		if  hp.percent < tonumber(g_resthp) or
			mp.percent < tonumber(g_restmp) or
			sp.percent < tonumber(g_restsp)
		then
			return true
		end
	end
	
	return false
end

--:============================================================================================
--: effect
--:============================================================================================

function e_rest:execute()
	local task = eso_task_rest.Create()
	ml_task_hub:Add(task.Create(), REACTIVE_GOAL, TP_ASAP)
	return ml_log(true)
end
