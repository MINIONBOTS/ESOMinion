ml_globals = {}
ml_globals.level1Timer = 0
ml_globals.level2Timer = 0
ml_globals.level3Timer = 0

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
	--RegisterForEvent("EVENT_CHAT_MESSAGE_CHANNEL", true)
	--RegisterForEvent("EVENT_AGENT_CHAT_REQUESTED", true)
	
	-- Register a handler on our side:
	RegisterEventHandler("GAME_EVENT_PLAYER_COMBAT_STATE",LuaEventHandler)
	--RegisterEventHandler("GAME_EVENT_CHARACTER_LIST_RECEIVED",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_INVENTORY_IS_FULL",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_LOOT_ITEM_FAILED",LuaEventHandler)
	RegisterEventHandler("GAME_EVENT_DISPLAY_ACTIVE_COMBAT_TIP",LuaEventHandler)
	

	--RegisterEventHandler("GAME_EVENT_CHAT_MESSAGE_CHANNEL",
		--function(event, eventnumber, messagetype, messagefrom, message)
			--if (gPlaySoundOnWhisper == "1" and tonumber(messagetype) == g("CHAT_CHANNEL_WHISPER")) then
				--d("eso_social -> new whisper: [" .. e("zo_strformat(<<1>>,"..messagefrom..")") .. "] " .. message)
				--PlaySound(GetStartupPath() .. [[\MinionFiles\Sounds\Alarm1.wav]])
			--end
		--end
	--)
	
	--RegisterEventHandler("GAME_EVENT_AGENT_CHAT_REQUESTED",
		--function(event, eventnumber)
			--if (gPlaySoundOnWhisper == "1" and e("IsAgentChatActive()")) then
				--d("eso_social -> new agent request: [" .. e("zo_strformat(<<1>>,"..event..")") .. "] " .. eventnumber)
				--PlaySound(GetStartupPath() .. [[\MinionFiles\Sounds\Alarm1.wav]])
			--end
		--end
	--)

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
		
		if ( not ml_global_information.Player_InCombat and not InventoryFull() ) then
			if ( TableSize(EList) > 0 ) then			
				local id, entry = next ( EList )
				if ( id and entry ) then
					d("Cannot loot "..entry.name..", blacklisting it")
					ml_blacklist.AddBlacklistEntry(GetString("monsters"), entry.id, entry.name, ml_global_information.Now+180000)
				end
			end
			c_lootwindow.ignoreLootTimer = ml_global_information.Now
			c_lootwindow.ignoreLoot = true
		end
	
	elseif ( args[1] == "GAME_EVENT_DISPLAY_ACTIVE_COMBAT_TIP" ) then
		local tips = {
			[1] = "BLOCK",
			[2] = "OFF-BALANCE/EXPLOIT",
			[3] = "INTERRUPT",
			[4] = "DODGE/AVOID",
			[18] = "BREAK CC",
		}
		
		d("Combat Tip : "..tostring(args[3]).." : "..tostring(tips[tonumber(args[3])]))
	end
end

-- Global vars which are used very often and we can just reduce the hammering by getting them once per frame
function ml_globals.UpdateGlobals()
	if ( Player ~= nil and ml_global_information.lastgamestate == 2) then
		
		ml_global_information.Player_Health = Player.hp or { current = 0, max = 0, percent = 0 }
		ml_global_information.CurrentMapID = Player.worldid
		ml_global_information.Player_Position = Player.pos
		
		ml_global_information.Player_Magicka = {} 
		local powertypeMagicka = 0		
		ml_global_information.Player_Magicka.current,ml_global_information.Player_Magicka.max,ml_global_information.Player_Magicka.effectiveMax = e("GetUnitPower(player,"..powertypeMagicka..")")
		ml_global_information.Player_Magicka.percent = ml_global_information.Player_Magicka.current*100/ml_global_information.Player_Magicka.effectiveMax
		
		ml_global_information.Player_Stamina = {} 
		local powertypeStamina = 6
		ml_global_information.Player_Stamina.current,ml_global_information.Player_Stamina.max,ml_global_information.Player_Stamina.effectiveMax = e("GetUnitPower(player,"..powertypeStamina..")")
		ml_global_information.Player_Stamina.percent = ml_global_information.Player_Stamina.current*100/ml_global_information.Player_Stamina.effectiveMax
		
		ml_global_information.Player_Ultimate = {} 
		local powertypeUltimate = 10
		ml_global_information.Player_Ultimate.current,ml_global_information.Player_Ultimate.max,ml_global_information.Player_Ultimate.effectiveMax = e("GetUnitPower(player,"..powertypeUltimate..")")
		ml_global_information.Player_Ultimate.percent = ml_global_information.Player_Ultimate.current*100/ml_global_information.Player_Ultimate.effectiveMax
		
		if (TimeSince(ml_globals.level1Timer) > 500 or ml_globals.level1Timer == 0) then
			ml_global_information.Player_InCombat = e("IsUnitInCombat(player)")
		end
		
		if (TimeSince(ml_globals.level2Timer) > 1500 or ml_globals.level1Timer == 0) then
			ml_global_information.Player_InventorySlots = e("GetBagSize(1)")
			ml_global_information.Player_InventoryFreeSlots = e("GetNumBagFreeSlots(1)")
			ml_global_information.CurrentMapName = e("GetPlayerLocationName()")
		end
		
		if (TimeSince(ml_globals.level3Timer) > 5000 or ml_globals.level1Timer == 0) then
			ml_global_information.Player_Level = e("GetUnitLevel(player)")			
		end
		
		-- needs to be here ,else some of the needed globals are not yet set
		if (eso_skillmanager) then 	
			ml_global_information.AttackRange = eso_skillmanager.GetAttackRange() 
		end
		
		-- Update Debug fields			
		dAttackRange = ml_global_information.AttackRange
		dMapName = ml_global_information.CurrentMapName
		gStatusMapID = Player.worldid
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












