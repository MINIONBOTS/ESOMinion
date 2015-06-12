function Sprint()
	if (ml_global_information.Player_Stamina.percent >= 99) then
		ml_global_information.Player_SprintingRecharging = false
	end
	
	if (gSprint == "1") then
		-- sprint is enabled
		if (not ml_global_information.Player_Sprinting) then
			if (ml_global_information.Player_Stamina.percent >= tonumber(gSprintStopThreshold) and not ml_global_information.Player_SprintingRecharging and not e("IsUnitInCombat(player)")) then
				e("OnSpecialMoveKeyDown(1)")
				--d("eso_common - > starting sprint")
				ml_global_information.Player_Sprinting = true
				ml_global_information.Player_SprintingRecharging = false
			end
		elseif (ml_global_information.Player_Sprinting) then
			if (ml_global_information.Player_Stamina.percent < tonumber(gSprintStopThreshold) or e("IsUnitInCombat(player)")) then
				e("OnSpecialMoveKeyUp(1)")
				--d("eso_common - > stopping sprint, recharging")
				ml_global_information.Player_Sprinting = false
				ml_global_information.Player_SprintingRecharging = true
			end
			--derp check
			if  (ml_global_information.Player_Stamina.percent == 100 and Player:IsMoving() and not e("IsUnitInCombat(player)")) and (
				(ml_global_information.Now - ml_global_information.Player_SprintingTime) > 5000)
			then
				ml_global_information.Player_SprintingTime = ml_global_information.Now
				e("OnSpecialMoveKeyDown(1)")
				--d("eso_common - > checking sprint")
				ml_global_information.Player_Sprinting = true
				ml_global_information.Player_SprintingRecharging = false
			end
		end
	else
		-- sprint is disabled
		if (ml_global_information.Player_Sprinting or ml_global_information.Player_SprintingRecharging) then
			e("OnSpecialMoveKeyUp(1)")
			--d("eso_common - > stopping sprint, sprint disabled")
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
