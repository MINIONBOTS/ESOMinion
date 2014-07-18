--:===============================================================================================================
--: Resting
--:===============================================================================================================

ai_resting = {}

c_resting = inheritsFrom( ml_cause )
e_resting = inheritsFrom( ml_effect )

--:===============================================================================================================
--: Evaluate
--:===============================================================================================================  
-- THIS NEEDS AN AGGRO CHECK!
function c_resting:evaluate()
	
	if gRest == "0" or ml_global_information.Player_Dead or Player.isswimming then
		return false
	end
	
	local hp = tonumber(gRestHP) or 75
	local mp = tonumber(gRestMP) or 75
	local sp = tonumber(gRestSP) or 10
	
	if 	ml_global_information.Player_Health.percent < hp or
		ml_global_information.Player_Magicka.percent < mp or
		ml_global_information.Player_Stamina.percent < sp
	then
		return true
	end

	return false
end

--:===============================================================================================================
--: Execute
--:===============================================================================================================

function e_resting:execute()
	ml_log(" Resting.. ")

	if Player:IsMoving() then
		Player:Stop()
	end
	
	eso_skillmanager.Heal(Player.id)
	return
end

--:===============================================================================================================
--: Initialize
--:===============================================================================================================

function ai_resting.Initialize()
	if Settings.ESOMinion.gRest == nil then Settings.ESOMinion.gRest = "1" end
	if Settings.ESOMinion.gRestHP == nil then Settings.ESOMinion.gRestHP = "75" end
	if Settings.ESOMinion.gRestMP == nil then Settings.ESOMinion.gRestMP = "75" end
	if Settings.ESOMinion.gRestSP == nil then Settings.ESOMinion.gRestSP = "10" end
	
	local window  =	ml_global_information.MainWindow
	local section =	GetString("settings")
	GUI_NewCheckbox(window.Name,"Rest","gRest",section)
	GUI_NewNumeric(window.Name,"  RestHP","gRestHP",GetString("settings"),"0","100")
	GUI_NewNumeric(window.Name,"  RestMP","gRestMP",GetString("settings"),"0","100")
	GUI_NewNumeric(window.Name,"  RestSP","gRestSP",GetString("settings"),"0","100")

	gRest   = Settings.ESOMinion.gRest
	gRestHP = Settings.ESOMinion.gRestHP
	gRestMP = Settings.ESOMinion.gRestMP
	gRestSP = Settings.ESOMinion.gRestSP
end

--:===============================================================================================================
--: GuiUpdate
--:===============================================================================================================

function ai_resting.GuiUpdate(event,newvars,oldvars)
	for key,value in pairs(newvars) do
		if 	key == "gRest" or
			key == "gRestHP" or
			key == "gRestMP" or
			key == "gRestSP"
		then
			Settings.ESOMinion[tostring(key)] = value
		end
	end
end

--:===============================================================================================================
--: EventHandlers
--:===============================================================================================================

RegisterEventHandler("Module.Initalize",ai_resting.Initialize)
RegisterEventHandler("GUI.Update",ai_resting.GuiUpdate)
