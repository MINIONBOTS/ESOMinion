ml_globals = {}



-- our version of EVENT_MANAGER:RegisterForEvent("Globals_Common", EVENT_GLOBAL_MOUSE_DOWN, OnGlobalMouseDown)
function ml_globals.RegisterLuaEventCallbackHandlers()
	d("Registering Events..")	
	--mycode = [[
	--function test()
	--	local name,slots = GetBagInfo(1)
		
	--	return slots
	--end]]
	--eDoString(mycode)
		
	-- Register for the ESO Event:
	RegisterForEvent("EVENT_PLAYER_COMBAT_STATE", true)
	RegisterForEvent("EVENT_CHARACTER_LIST_RECEIVED", true)
	-- Register a handler on our side:
	RegisterEventHandler("GAME_EVENT_PLAYER_COMBAT_STATE",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_CHARACTER_LIST_RECEIVED",LuaEventHandler)
	d("Done registering Event..")
end

-- Callback function for Events from ESO
function LuaEventHandler(...)
	local args = { ... }    
    local numArgs = #args
	
	--for i=1,#args do
	--	d(args[i])
	--end
	
	if ( args[1] == "GAME_EVENT_PLAYER_COMBAT_STATE" ) then
		--d("EVENT_PLAYER_COMBAT_STATE : "..tostring( args[3] ))
		ml_global_information.Player_InCombat = args[3]

	end
end

-- Global vars which are used very often and we can just reduce the hammering by getting them once per frame
function ml_globals.UpdateGlobals()
	
	if (eso_skillmanager) then 	ml_global_information.AttackRange = eso_skillmanager.GetAttackRange() end
	ml_global_information.CurrentMapID = e("GetCurrentMapIndex()")
	
	ml_global_information.Player_InCombat = e("IsUnitInCombat(player)")
	ml_global_information.Player_InventorySlots = e("GetBagInfo(1)")
	
	ml_global_information.Player_Magicka = {} 
		local magickaID = g("POWERTYPE_MAGICKA")
		ml_global_information.Player_Magicka.current,ml_global_information.Player_Magicka.max,ml_global_information.Player_Magicka.effectiveMax = e("GetUnitPower(player,"..magickaID..")")
	
	ml_global_information.Player_Stamina = {} 
		local magickaID = g("POWERTYPE_STAMINA")
		ml_global_information.Player_Stamina.current,ml_global_information.Player_Stamina.max,ml_global_information.Player_Stamina.effectiveMax = e("GetUnitPower(player,"..magickaID..")")
	
	ml_global_information.Player_Ultimate = {} 
		local magickaID = g("POWERTYPE_ULTIMATE")
		ml_global_information.Player_Ultimate.current,ml_global_information.Player_Ultimate.max,ml_global_information.Player_Ultimate.effectiveMax = e("GetUnitPower(player,"..magickaID..")")
	
	
	
	-- Update Debug fields	
	dAttackRange = ml_global_information.AttackRange	
end

-- Init all variables before the rest of the bot loads
ml_globals.UpdateGlobals()














