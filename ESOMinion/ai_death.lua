--:===============================================================================================================
--: Death
--:===============================================================================================================

ai_death = {}

c_dead = inheritsFrom( ml_cause )
e_dead = inheritsFrom( ml_effect )

e_dead.lastseenalive = 0
e_dead.wait = 5000

--:===============================================================================================================
--: API Usage
--:===============================================================================================================  
-- func: e("GetDeathInfo()")
-- func: e("Revive()")
-- func: e("Release()")

--:===============================================================================================================
--: Evaluate
--:===============================================================================================================

function c_dead:evaluate()
	if ml_global_information.Player_Dead then
		return true
	end
	
	e_dead.lastseenalive = ml_global_information.Now
	return false
end

--:===============================================================================================================
--: Execute
--:===============================================================================================================

function e_dead:execute()
	ml_log("e_dead")
	_,_,_,_,_,_,_, releaseOnly, soulGemAvailable,_ = e("GetDeathInfo()")
	
	if ml_global_information.Now - e_dead.lastseenalive > e_dead.wait then
	
		ml_global_information.ResetBot()
		
		if gUseSoulGems and gUseSoulGems == "1" and soulGemAvailable then
			e("Revive()")
			return
			
			--[[ No Longer Needed
			
			local bag,slots =	e("GetBagInfo(1)")
			local soulgemtype =	g("ITEMTYPE_SOUL_GEM")
			
			if slots and tonumber(slots) > 0 then
				for i = slots, 1, -1 do
					local itemtype = e("GetItemType(1,"..tostring(i)..")")
					
					if itemtype == soulgemtype then
						e("Revive()")
						return
					end
				end
			end
			]]			
		end	
		
		e("Release()")
		return
	end
end

--:===============================================================================================================
--: Initialize
--:===============================================================================================================

function ai_death.Initialize()
	if Settings.ESOMinion.gUseSoulGems == nil then Settings.ESOMinion.gUseSoulGems = "0" end
	
	local window  =	ml_global_information.MainWindow
	local section =	GetString("settings")
	GUI_NewCheckbox(window.Name,"UseSoulGems","gUseSoulGems",section)
	gUseSoulGems = Settings.ESOMinion.gUseSoulGems
end

--:===============================================================================================================
--: GuiUpdate
--:===============================================================================================================

function ai_death.GuiUpdate(event,newvars,oldvars)
	for key,value in pairs(newvars) do
		if 	key == "gUseSoulGems" then
			Settings.ESOMinion[tostring(key)] = value
		end
	end
end

--:===============================================================================================================
--: EventHandlers
--:===============================================================================================================

RegisterEventHandler("Module.Initalize",ai_death.Initialize)
RegisterEventHandler("GUI.Update",ai_death.GuiUpdate)
