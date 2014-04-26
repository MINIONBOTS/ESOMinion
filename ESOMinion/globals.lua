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
	--RegisterForEvent("EVENT_CHARACTER_LIST_RECEIVED", true)
	RegisterForEvent("EVENT_INVENTORY_IS_FULL", true)
	RegisterForEvent("EVENT_OPEN_STORE", true)
	
	-- Register a handler on our side:
	RegisterEventHandler("GAME_EVENT_PLAYER_COMBAT_STATE",LuaEventHandler)
	--RegisterEventHandler("GAME_EVENT_CHARACTER_LIST_RECEIVED",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_INVENTORY_IS_FULL",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_OPEN_STORE",LuaEventHandler)
	
	
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
	
	elseif( args[1] == "GAME_EVENT_INVENTORY_IS_FULL" ) then
		d("INVENTORY FULL!") --(integer numSlotsRequested, integer numSlotsFree) 
	
	elseif(args[1] == "GAME_EVENT_OPEN_STORE" ) then
		ai_vendor.HandleVendoring()
	end
end

-- Global vars which are used very often and we can just reduce the hammering by getting them once per frame
function ml_globals.UpdateGlobals()
	
	if (eso_skillmanager) then 	ml_global_information.AttackRange = eso_skillmanager.GetAttackRange() end
	ml_global_information.CurrentMapID = e("GetCurrentMapZoneIndex()")
	
	ml_global_information.Player_Position = Player.pos
	ml_global_information.Player_InCombat = e("IsUnitInCombat(player)")
	ml_global_information.Player_InventorySlots = e("GetBagInfo(1)")
	ml_global_information.Player_InventoryNearlyFull = (e("CheckInventorySpaceSilently(5)") == false)
	ml_global_information.Player_InventoryFull = (e("CheckInventorySpaceSilently(1)") == false)	
	ml_global_information.Player_Health = Player.hp or { current = 0, max = 0, percent = 0 }
		
	ml_global_information.Player_Magicka = {} 
		local magickaID = g("POWERTYPE_MAGICKA")
		ml_global_information.Player_Magicka.current,ml_global_information.Player_Magicka.max,ml_global_information.Player_Magicka.effectiveMax = e("GetUnitPower(player,"..magickaID..")")
		ml_global_information.Player_Magicka.percent = ml_global_information.Player_Magicka.current*100/ml_global_information.Player_Magicka.effectiveMax
	ml_global_information.Player_Stamina = {} 
		local magickaID = g("POWERTYPE_STAMINA")
		ml_global_information.Player_Stamina.current,ml_global_information.Player_Stamina.max,ml_global_information.Player_Stamina.effectiveMax = e("GetUnitPower(player,"..magickaID..")")
		ml_global_information.Player_Stamina.percent = ml_global_information.Player_Stamina.current*100/ml_global_information.Player_Stamina.effectiveMax
	ml_global_information.Player_Ultimate = {} 
		local magickaID = g("POWERTYPE_ULTIMATE")
		ml_global_information.Player_Ultimate.current,ml_global_information.Player_Ultimate.max,ml_global_information.Player_Ultimate.effectiveMax = e("GetUnitPower(player,"..magickaID..")")
		ml_global_information.Player_Ultimate.percent = ml_global_information.Player_Ultimate.current*100/ml_global_information.Player_Ultimate.effectiveMax
	
	
	-- Update Debug fields	
	dAttackRange = ml_global_information.AttackRange
	dMapName = e("GetMapName()")
	dMapZoneIndex = e("GetCurrentMapZoneIndex()")
	dLocationName = e("GetPlayerLocationName()")
	
end

-- Init all variables before the rest of the bot loads
ml_globals.UpdateGlobals()














