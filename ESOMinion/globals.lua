ml_globals = {}


-- our version of EVENT_MANAGER:RegisterForEvent("Globals_Common", EVENT_GLOBAL_MOUSE_DOWN, OnGlobalMouseDown)
function ml_globals.RegisterLuaEventCallbackHandlers()
	d("Registering Events..")	
	--mycode = [[
	--function test()
	--	local name,slots = e("GetBagSize()")
		
	--	return slots
	--end]]
	--eDoString(mycode)
		
	-- Register for the ESO Event:
	RegisterForEvent("EVENT_PLAYER_COMBAT_STATE", true)
	--RegisterForEvent("EVENT_CHARACTER_LIST_RECEIVED", true)
	RegisterForEvent("EVENT_INVENTORY_IS_FULL", true)
	RegisterForEvent("EVENT_LOOT_ITEM_FAILED", true)
	RegisterForEvent("EVENT_DISPLAY_ACTIVE_COMBAT_TIP", true)
	
	-- Register a handler on our side:
	RegisterEventHandler("GAME_EVENT_PLAYER_COMBAT_STATE",LuaEventHandler)
	--RegisterEventHandler("GAME_EVENT_CHARACTER_LIST_RECEIVED",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_INVENTORY_IS_FULL",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_LOOT_ITEM_FAILED",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_DISPLAY_ACTIVE_COMBAT_TIP",LuaEventHandler)


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
	
	elseif (args[1] == "GAME_EVENT_LOOT_ITEM_FAILED" ) then
		d("LOOT FAILED: Reason "..tostring(args[3]).." ItemName "..args[4])
		-- Blacklisting the closest entity which we were trying to loot
		local blackliststring = ml_blacklist.GetExcludeString(GetString("monsters")) or ""
		local EList = EntityList("nearest,lootable,onmesh,maxdistance=3,exclude="..blackliststring)
		
		if ( not ml_global_information.Player_InCombat and not ml_global_information.Player_InventoryFull ) then
			
			if ( TableSize(EList) > 0 ) then			
				local id, entry = next ( EList )
				if ( id and entry ) then
					d("Cannot loot "..entry.name..", blacklisting it")
					ml_blacklist.AddBlacklistEntry(GetString("monsters"), entry.id, entry.name, ml_global_information.Now+180000)
				end
			end
			c_LootAll.ignoreLootTmr = ml_global_information.Now
			c_LootAll.ignoreLoot = true
		end
	
	elseif ( args[1] == "GAME_EVENT_DISPLAY_ACTIVE_COMBAT_TIP" ) then
		d("Combat Tip ID : "..tostring(args[3]))
		-- ID 1 - Block
		
	end
end

-- Global vars which are used very often and we can just reduce the hammering by getting them once per frame
function ml_globals.UpdateGlobals()
	
	if ( Player ~= nil ) then
		if (eso_skillmanager) then 	ml_global_information.AttackRange = eso_skillmanager.GetAttackRange() end
				
		ml_global_information.Player_Health = Player.hp or { current = 0, max = 0, percent = 0 }
		ml_global_information.Player_InCombat = e("IsUnitInCombat(player)")
		ml_global_information.Player_InventorySlots = e("GetBagSize()")
		ml_global_information.Player_InventoryNearlyFull = (e("CheckInventorySpaceSilently(5)") == false)
		ml_global_information.Player_InventoryFull = (e("CheckInventorySpaceSilently(1)") == false)			
		ml_global_information.Player_Level = e("GetUnitLevel(player)")
		ml_global_information.Player_Dead = e("IsUnitDead(player)")
		
		ml_global_information.CurrentMapID = e("GetCurrentMapZoneIndex()")
		ml_global_information.CurrentMapName = e("GetMapName()")
		ml_global_information.Player_Position = Player.pos
		
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
end

-- Drawing the Markers
function ml_globals.DrawMarker(marker)
	local markertype = marker:GetType()
	local pos = marker:GetPosition()

    local color = 0
    local s = 1 -- size
    local h = 5 -- height
	
    if ( markertype == GetString("grindMarker") ) then
        color = 1 -- red
    elseif ( markertype == "GatherMarker" ) then
        color = 6 -- green
    elseif ( markertype == GetString("vendorMarker") ) then
        color = 8 -- orange
    end
    --Building the vertices for the object
    local t = { 
        [1] = { pos.x-s, pos.y+s+h, pos.z-s, color },
        [2] = { pos.x+s, pos.y+s+h, pos.z-s, color  },	
        [3] = { pos.x,   pos.y-s+h,   pos.z, color  },
        
        [4] = { pos.x+s, pos.y+s+h, pos.z-s, color },
        [5] = { pos.x+s, pos.y+s+h, pos.z+s, color  },	
        [6] = { pos.x,   pos.y-s+h,   pos.z, color  },
        
        [7] = { pos.x+s, pos.y+s+h, pos.z+s, color },
        [8] = { pos.x-s, pos.y+s+h, pos.z+s, color  },	
        [9] = { pos.x,   pos.y-s+h,   pos.z, color  },
        
        [10] = { pos.x-s, pos.y+s+h, pos.z+s, color },
        [11] = { pos.x-s, pos.y+s+h, pos.z-s, color  },	
        [12] = { pos.x,   pos.y-s+h,   pos.z, color  },
    }
    
    local id = RenderManager:AddObject(t)
    return id
end


-- Init all variables before the rest of the bot loads
ml_globals.UpdateGlobals()














