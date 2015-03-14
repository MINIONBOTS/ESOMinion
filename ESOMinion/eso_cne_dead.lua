--:======================================================================================================================================================================
--: dead
--:======================================================================================================================================================================

c_dead = ml_cause.Create()
e_dead = inheritsFrom(ml_effect)

--:============================================================================================
--: cause
--:============================================================================================

function c_dead:evaluate()
	return e("IsUnitDead(player)")
end

--:============================================================================================
--: effect
--:============================================================================================

function e_dead:execute()
	local havesoulgems = select(9, e("GetDeathInfo()"))
	
	if havesoulgems and g_usesoulgemtorevive == "1" then
		local task = eso_task_revive.Create()
		ml_task_hub:Add(task.Create(), REACTIVE_GOAL, TP_ASAP)
		return ml_log(true)
	else
		local task = eso_task_release.Create()
		ml_task_hub:Add(task.Create(), REACTIVE_GOAL, TP_ASAP)
		return ml_log(true)
	end
end
