ml_global_information = { }
ml_global_information.MainWindow = { Name="MinionBot", x=50, y=50, width=220, height=350 }
ml_global_information.advwindow = { Name="AdvandedSettings", x=250, y=200 , width=200, height=170 }
ml_global_information.login = { Name="AutoLogin", x=100, y=100 , width=230, height=140 }
ml_global_information.characterselect = { Name="CharacterSelect", x=100, y=100 , width=250, height=150 }
ml_global_information.advwindowvisible = false
ml_global_information.path = GetStartupPath()
ml_global_information.Now = 0
ml_global_information.lasttick = 0
ml_global_information.running = false
ml_global_information.BotModes = {}
ml_global_information.lastgamestate = 0
ml_global_information.gamestatechanged = false
ml_global_information.MarkerMinLevel = 1
ml_global_information.MarkerMaxLevel = 50
ml_global_information.BlacklistContentID = ""
ml_global_information.WhitelistContentID = ""
ml_global_information.MarkerTime = 0
ml_global_information.Player_SprintingRecharging = false
ml_global_information.Player_Sprinting = false
ml_global_information.Player_SprintingTime = 0
ml_global_information.VendorChar = ""
ml_global_information.gatherdistance = 2.5
ml_global_information.randomdistance = 10
ml_global_information.autoStartDisabled = false
ml_global_information.CurrentClass = nil
ml_global_information.CurrentClassID = nil
ml_global_information.idlePulseCount = 0

esominion = {}

esominion.login_window		= {name = "Login",				args = { 50, 50, 220, 150, true}}
esominion.character_window 	= {name = "CharacterSelect",	args = { 50, 50, 220, 150, true}}
esominion.main_window 		= {name = "ESOMinion", 			args = { 50, 50, 220, 350 }} --not used, atm

function ml_global_information.moduleinit()
	
	local window;
	
	--: login_window
	window = esominion.login_window
	window = WindowManager:NewWindow(window.name,unpack(window.args))
	
	if (window) then
		window:NewCheckBox(" AutoLogin", "gAutoLogin", "Settings")
		window:NewField(" Account", "aLogin", "Settings")
		window:NewField(" Password", "aPassword", "Settings")
		window:UnFold("Settings")
		window:Hide()
		
		esominion.register_var("aLogin", "")
		esominion.register_var("aPassword", "")
		esominion.register_var("gAutoLogin", "0")
	end
	
	--: character_window
	window = esominion.character_window
	window = WindowManager:NewWindow(window.name,unpack(window.args))

	if (window) then
		window:NewCheckBox(" AutoSelect", "gAutoSelect", "Settings")
		window:NewComboBox(" Character", "gAutoCharacterSelect", "Settings", "None")
		window:UnFold("Settings")
		window:Hide()
		
		esominion.register_var("gAutoSelect", "0")
		esominion.register_var("gAutoCharacterSelect", "")
	end
	
	--: main_window
	--: not yet ^^
	
	if ( Settings.ESOMinion.gPulseTime == nil ) then
		Settings.ESOMinion.gPulseTime = "150"
	end
	if ( Settings.ESOMinion.gBotMode == nil ) then
        Settings.ESOMinion.gBotMode = GetString("grindMode")
    end
	if ( Settings.ESOMinion.gAttackRange == nil ) then
        Settings.ESOMinion.gAttackRange = GetString("aAutomatic")
    end
	if ( Settings.ESOMinion.gGather == nil ) then
		Settings.ESOMinion.gGather = "1"
	end
	if ( Settings.ESOMinion.gMount == nil ) then
		Settings.ESOMinion.gMount = "1"
	end	
	if ( Settings.ESOMinion.gPot == nil ) then
		Settings.ESOMinion.gPot = "0"
	end
	if ( Settings.ESOMinion.gPotiontype == nil ) then
		Settings.ESOMinion.gPotiontype = "Health"
	end
	if ( Settings.ESOMinion.gPotvalue == nil ) then
		Settings.ESOMinion.gPotvalue = "27"
	end
	if ( Settings.ESOMinion.gSprint == nil ) then
		Settings.ESOMinion.gSprint = "0"
 	end
    if ( Settings.ESOMinion.gSprintStopThreshold == nil ) then
 		Settings.ESOMinion.gSprintStopThreshold = "50"
	end
	if ( Settings.ESOMinion.gAutoStart == nil ) then
		Settings.ESOMinion.gAutoStart = "0"
	end
	if not Settings.ESOMinion.gVendor then 
		Settings.ESOMinion.gVendor = "0"
	end
	if not Settings.ESOMinion.gRepair then 
		Settings.ESOMinion.gRepair = "1"
	end
	if not Settings.ESOMinion.gPlaySoundOnWhisper then
		Settings.ESOMinion.gPlaySoundOnWhisper = "0"
	end
	
	if not Settings.ESOMinion.gDevTest then
		Settings.ESOMinion.gDevTest = "0"
	end
	
	if not Settings.ESOMinion.gPreventAttackingInnocents then
		Settings.ESOMinion.gPreventAttackingInnocents = "1"
	end
	
	if not Settings.ESOMinion.g_usesoulgemtorevive then Settings.ESOMinion.g_usesoulgemtorevive = "0" end
	if not Settings.ESOMinion.g_rest then Settings.ESOMinion.g_rest = "1" end
	if not Settings.ESOMinion.g_resthp then Settings.ESOMinion.g_resthp = "75" end
	if not Settings.ESOMinion.g_restmp then Settings.ESOMinion.g_restmp = "75" end
	if not Settings.ESOMinion.g_restsp then Settings.ESOMinion.g_restsp = "10" end
	
	
	-- MAIN WINDOW
	GUI_NewWindow(ml_global_information.MainWindow.Name,ml_global_information.MainWindow.x,ml_global_information.MainWindow.y,ml_global_information.MainWindow.width,ml_global_information.MainWindow.height)
	GUI_NewButton(ml_global_information.MainWindow.Name,"StartBot","ml_global_information.startStop")
	RegisterEventHandler("ml_global_information.startStop", ml_global_information.eventhandler)
	
	GUI_NewButton(ml_global_information.MainWindow.Name,GetString("showradar"),"Radar.toggle")
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("botEnabled"),"gBotRunning",GetString("botStatus"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("autoStartBot"),"gAutoStart",GetString("botStatus"))
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("botMode"),"gBotMode",GetString("botStatus"),"None")
	GUI_NewField(ml_global_information.MainWindow.Name,GetString("attackRange"),"dAttackRange",GetString("botStatus"))
	
	GUI_NewField(ml_global_information.MainWindow.Name,"MapName","dMapName",GetString("botStatus"))
	--GUI_NewField(ml_global_information.MainWindow.Name,"MapZoneIndex","dMapZoneIndex",GetString("botStatus"))
	--GUI_NewField(ml_global_information.MainWindow.Name,"LocationName","dLocationName",GetString("botStatus"))
	
	--: Dead
	GUI_NewCheckbox(ml_global_information.MainWindow.Name, " UseSoulGems", "g_usesoulgemtorevive", "Dead")
	
	--: Rest
	GUI_NewCheckbox(ml_global_information.MainWindow.Name, " Rest", "g_rest", "Rest")
	GUI_NewNumeric(ml_global_information.MainWindow.Name, " RestHP", "g_resthp", "Rest", "0", "100")
	GUI_NewNumeric(ml_global_information.MainWindow.Name, " RestMP", "g_restmp", "Rest", "0", "100")
	GUI_NewNumeric(ml_global_information.MainWindow.Name, " RestSP", "g_restsp", "Rest", "0", "100")

	GUI_NewNumeric(ml_global_information.MainWindow.Name,GetString("pulseTime"),"gPulseTime",GetString("settings"),"10","10000")
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("attackRange"),"gAttackRange",GetString("settings"),GetString("aAutomatic")..","..GetString("aRange")..","..GetString("aMelee"));
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("gatherMode"),"gGather",GetString("settings"))	
	--GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("useMount"),"gMount",GetString("settings"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("useSprint"),"gSprint",GetString("settings"))
 	GUI_NewNumeric(ml_global_information.MainWindow.Name,GetString("sprintStopThreshold"),"gSprintStopThreshold",GetString("settings"),"0","100")
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"PlaySound on Whisper","gPlaySoundOnWhisper",GetString("settings"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Enable DevTest","gDevTest",GetString("settings"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("preventAttackingInnocents"),"gPreventAttackingInnocents",GetString("settings"))
	
	--vendor, repair, vendormanager
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enableRepair"),"gRepair","Vendor and Repair")
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enableSelling"),"gVendor","Vendor and Repair")
	GUI_NewButton(ml_global_information.MainWindow.Name,GetString("vendorManager"),"eso_vendor_manager.OnGuiToggle","Vendor and Repair")
	
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("usepotion"),"gPot",GetString("potionssettings"))
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("potiontype"),"gPotiontype",GetString("potionssettings"),"Health,Stamina,Magicka")
	GUI_NewNumeric(ml_global_information.MainWindow.Name,GetString("potusebelow"),"gPotvalue",GetString("potionssettings"),"1","100")
	
	--GUI_NewButton(ml_global_information.MainWindow.Name, GetString("advancedSettings"), "AdvancedSettings.toggle")
	--RegisterEventHandler("AdvancedSettings.toggle", ml_global_information.ToggleAdvMenu)
	
	-- ADVANCED SETTINGS WINDOW
	--GUI_NewWindow(ml_global_information.advwindow.Name,ml_global_information.advwindow.x,ml_global_information.advwindow.y,ml_global_information.advwindow.width,ml_global_information.advwindow.height,"",false)
	GUI_NewButton(ml_global_information.MainWindow.Name, GetString("skillManager"), "SkillManager.toggle", "Managers")
	GUI_NewButton(ml_global_information.MainWindow.Name, GetString("meshManager"), "ToggleMeshManager", "Managers")
	GUI_NewButton(ml_global_information.MainWindow.Name, GetString("markerManager"), "ToggleMarkerMgr", "Managers")
	GUI_NewButton(ml_global_information.MainWindow.Name, GetString("blacklistManager"), "ToggleBlacklistMgr", "Managers")	
	GUI_NewButton(ml_global_information.MainWindow.Name, GetString("vendorManager"), "eso_vendor_manager.OnGuiToggle", "Managers")
	GUI_NewButton(ml_global_information.MainWindow.Name, GetString("gatherManager"), "eso_gather_manager.OnGuiToggle", "Managers")
	GUI_NewButton(ml_global_information.MainWindow.Name, GetString("AutoEquipManager"), "autoequip.toggle", "Managers")		
	GUI_UnFoldGroup(ml_global_information.MainWindow.Name,"Managers" )
	--GUI_WindowVisible(ml_global_information.advwindow.Name,false)
	
	-- setup bot mode
    local botModes = "None"
    if ( TableSize(ml_global_information.BotModes) > 0) then
        local i,entry = next ( ml_global_information.BotModes )
        while i and entry do
            botModes = botModes..","..i
            i,entry = next ( ml_global_information.BotModes,i)
        end
    end
	
    gBotMode_listitems = botModes    
    gBotMode = Settings.ESOMinion.gBotMode	
	ml_global_information.UpdateMode()
	
	gBotRunning = "0"
	gAutoStart = Settings.ESOMinion.gAutoStart
	gPulseTime = Settings.ESOMinion.gPulseTime	
	gAttackRange = Settings.ESOMinion.gAttackRange
	gVendor = Settings.ESOMinion.gVendor
	gRepair = Settings.ESOMinion.gRepair
	gGather = Settings.ESOMinion.gGather
	gMount = Settings.ESOMinion.gMount
	gPot = Settings.ESOMinion.gPot
	gPotiontype = Settings.ESOMinion.gPotiontype
	gPotlevel = Settings.ESOMinion.gPotlevel
	gPotvalue = Settings.ESOMinion.gPotvalue 
	gSprint = Settings.ESOMinion.gSprint
	gSprintStopThreshold = Settings.ESOMinion.gSprintStopThreshold
	gPlaySoundOnWhisper = Settings.ESOMinion.gPlaySoundOnWhisper
	gDevTest = Settings.ESOMinion.gDevTest
	gPreventAttackingInnocents = Settings.ESOMinion.gPreventAttackingInnocents
	
	g_usesoulgemtorevive = Settings.ESOMinion.g_usesoulgemtorevive
	g_rest   = Settings.ESOMinion.g_rest
	g_resthp = Settings.ESOMinion.g_resthp
	g_restmp = Settings.ESOMinion.g_restmp
	g_restsp = Settings.ESOMinion.g_restsp
	
	GUI_UnFoldGroup(ml_global_information.MainWindow.Name,GetString("botStatus") )
		
-- setup marker manager callbacks and vars
	if ( ml_marker_mgr ) then
		ml_marker_mgr.GetPosition = 	function () return Player.pos end
		ml_marker_mgr.GetLevel = 		function () return e("GetUnitLevel(player)") end
		ml_marker_mgr.DrawMarker =		ml_globals.DrawMarker
		ml_marker_mgr.parentWindow = { Name="MinionBot" }
		ml_marker_mgr.markerPath = ml_global_information.path.. [[\Navigation\]]
		ml_globals.RegisterLuaEventCallbackHandlers()
	end
	
-- setup meshmanager
	if ( ml_mesh_mgr ) then
		ml_mesh_mgr.parentWindow.Name = "MinionBot"
		ml_mesh_mgr.GetMapID = function () return ml_global_information.CurrentMapID end
		ml_mesh_mgr.GetMapName = function () return ml_global_information.CurrentMapName end
		ml_mesh_mgr.GetPlayerPos = function () return ml_global_information.Player_Position end
		ml_mesh_mgr.averagegameunitsize = 2
		
	-- Set default meshes SetDefaultMesh(mapid, filename)
		ml_mesh_mgr.SetDefaultMesh(2,"Glenumbra")
				
	-- Setup the marker types we wanna use		
		local grindMarker = ml_marker:Create("grindTemplate")
		grindMarker:SetType(GetString("grindMarker"))
		grindMarker:AddField("string", strings[gCurrentLanguage].contentIDEquals, "")
		grindMarker:AddField("string", strings[gCurrentLanguage].NOTcontentIDEquals, "")
		grindMarker:SetTime(300)
		grindMarker:SetMinLevel(1)
		grindMarker:SetMaxLevel(50)
		ml_marker_mgr.AddMarkerTemplate(grindMarker)
			
		local gatherMarker = ml_marker:Create("gatherTemplate")
		gatherMarker:SetType("GatherMarker")
		gatherMarker:SetTime(300)
		gatherMarker:SetMinLevel(1)
		gatherMarker:SetMaxLevel(50)
		ml_marker_mgr.AddMarkerTemplate(gatherMarker)
		
		local vendorMarker = ml_marker:Create("vendorTemplate")
		vendorMarker:SetType(GetString("vendorMarker"))
		vendorMarker:SetMinLevel(1)
		vendorMarker:SetMaxLevel(50)
		ml_marker_mgr.AddMarkerTemplate(vendorMarker)
		
		--local mapMarker = ml_marker:Create("mapTemplate")
		--mapMarker:SetType(strings[gCurrentLanguage].mapMarker)
		--mapMarker:AddField("string", "toMapID", "")
		--mapMarker:SetTime(300)
		--mapMarker:SetMinLevel(1)
		--mapMarker:SetMaxLevel(50)
		--ml_marker_mgr.AddMarkerTemplate(mapMarker)
			
	-- refresh the manager with the new templates
		ml_marker_mgr.RefreshMarkerTypes()
		ml_marker_mgr.RefreshMarkerNames()
				
		ml_mesh_mgr.InitMarkers() -- Update the Markers-group in the mesher UI
	end


	
-- setup/load blacklist tables
	if ( ml_blacklist_mgr ) then
		ml_blacklist_mgr.parentWindow = ml_global_information.MainWindow	
		ml_blacklist_mgr.path = GetStartupPath() .. [[\LuaMods\ESOMinion\blacklist.info]]
		ml_blacklist_mgr.ReadBlacklistFile(ml_blacklist_mgr.path)
		 
		if not ml_blacklist.BlacklistExists(GetString("monsters")) then
			ml_blacklist.CreateBlacklist(GetString("monsters"))
		end
	end

	Player:ClearTarget()
	if gAutoStart == "1" and not ml_global_information.running then
		ml_global_information.togglebot(1)
	end	
	
	if(gDevTest == "1") then
		gEnableLog = "1"
		gLogCNE = "1"
	end
	
end

function test()
	mycode = [[
	function getmapid()
		return GetCurrentMapZoneIndex()
	end
	]]
	eDoString(mycode)
end

function ml_global_information.onupdate( event, tickcount )
	ml_global_information.Now = tickcount
	
	local gamestate = GetGameState()
	
	if (ml_global_information.lastgamestate ~= gamestate) then
		ml_global_information.lastgamestate = gamestate
		ml_global_information.gamestatechanged = true
		
		--: hide all windows
		GUI_ToggleConsole(false)
		local windows = WindowManager:GetWindowNames()
		if (windows) then
			for index,title in pairs(windows) do
				local window = WindowManager:GetWindow(title)
				if (window) then
					window:Hide()
				end
			end
		end
	end
	
	-- Switch according to the gamestate
	if ( gamestate == 2 ) then --GAMESTATE_INGAME
		ml_global_information.InGameOnUpdate( event, tickcount )
	elseif (gamestate == 3 ) then --GAMESTATE_INCHARACTERSELECTSCREEN
		ml_global_information.InCharacterSelectScreenOnUpdate( event, tickcount )
	elseif (gamestate == 4 ) then --GAMESTATE_INTITLESCREEN
		ml_global_information.InTitleScreenOnUpdate( event, tickcount )
	elseif (gamestate == 5 ) then --GAMESTATE_INLOADINGSCREEN
		ml_log("GAMESTATE_INLOADINGSCREEN")
	elseif (gamestate == 1 ) then --GAMESTATE_UNKNOWN
		ml_log("GAMESTATE_UNKNOWN")
	end
	
end

function ml_global_information.InTitleScreenOnUpdate( event, tickcount )
	ml_global_information.Now = tickcount
	
	-- show/hide correct windows for gamestate
	if ( ml_global_information.gamestatechanged == true ) then
		local window = WindowManager:GetWindow(esominion.login_window.name)
	
		if (window and not window.visible) then
			window:Show()
		end
		
		ml_global_information.gamestatechanged = false		
	end	
				
	if ( tickcount - ml_global_information.lasttick > 10000 ) then
		ml_global_information.lasttick = tickcount
		
		local currentState = tostring(e("PregameStateManager_GetCurrentState()"))
		if ( currentState == "GammaAdjust" ) then
			e("PregameStateManager_ReenterLoginState()")
			return
		
		-- There are 4 different agreement screens and the agree functions for the three other than
		-- the EULA dialog are not defined in the ESO LUA. For now just force the user to agree to
		-- these after install or client update, maybe do it automatically later when there is more
		-- time to spend looking
		
		--elseif ( currentstate == "ShowEULA" ) then
		--	e("AgreeToEULA()")
			
		elseif ( currentState == "AccountLogin" ) then
			ml_log("AccountLogin... ")
			
			if ( aLogin ~= "" and aPassword ~= "" and gAutoLogin == "1") then
				d("Trying to login....")			
				if ( not e("ZO_Dialogs_IsShowingDialog()") ) then
					e("PregameLogin("..aLogin..","..aPassword..")")
				else
					ml_log("Login Error detected....trying again in 10 seconds..")
					e("ZO_Dialogs_ReleaseAllDialogs(true)")
				end
				
			end	
		
		end
		-- Update the Statusbar on the left/bottom screen
		GUI_SetStatusBar(ml_GetTraceString())
	end
end

function ml_global_information.InCharacterSelectScreenOnUpdate( event, tickcount )
	ml_global_information.Now = tickcount
	
	-- show/hide correct windows for gamestate
	if ( ml_global_information.gamestatechanged == true ) then
	
		local window = WindowManager:GetWindow(esominion.character_window.name)
	
		if (window and not window.visible) then
			window:Show()
		end
		
		ml_global_information.gamestatechanged = false
		
		local charcount = e("GetNumCharacters()")
		
		-- populate char-dropdown-list				
		local charList = ""
		local LoginCharFound = false
		local SettingsCharFound = false
		for i = 1, e("GetNumCharacters()") do
			local charName = TrimString(e("GetCharacterInfo("..tostring(i)..")"),3)
			if(charList == "") then
				charList = charName
			else
				charList = charList..","..charName
			end
			
			if ml_global_information.VendorChar == charName then 
				LoginCharFound = true
			elseif Settings.ESOMinion.gAutoCharacterSelect == charName then 
				SettingsCharFound = true 
			end
		end
	
		gAutoCharacterSelect_listitems = charList
		if LoginCharFound then 
			gAutoCharacterSelect = ml_global_information.VendorChar
		elseif SettingsCharFound then
			gAutoCharacterSelect = Settings.ESOMinion.gAutoCharacterSelect
		end
	end	
				
	if ( tickcount - ml_global_information.lasttick > 10000 ) then
		ml_global_information.lasttick = tickcount
		ml_log("InCharacterSelectScreen: ")
		
		if ( gAutoSelect == "1" and tostring(e("PregameStateManager_GetCurrentState()")) == "CharacterSelect") then
			if ( not e("ZO_Dialogs_IsShowingDialog()") ) then
				ml_log("Select character and login! ")
				for i = 1, e("GetNumCharacters()") do
					local charName = TrimString(e("GetCharacterInfo("..tostring(i)..")"),3)
					if (charName == gAutoCharacterSelect) then
						e("SelectCharacterToView("..tostring(i)..")")
					end
				end
				e("ZO_CharacterSelect_Login(false)")
			else
				ml_log("Login Error detected....trying again in 10 seconds..")
				e("RequestCharacterList()")
			end
		end		
		
		-- Update the Statusbar on the left/bottom screen
		GUI_SetStatusBar(ml_GetTraceString())		
	end
end

function ml_global_information.InGameOnUpdate( event, tickcount )
	ml_global_information.Now = tickcount
	

	-- show/hide correct windows for gamestate
	if ( ml_global_information.gamestatechanged == true ) then
		GUI_WindowVisible(ml_global_information.MainWindow.Name,true)
		ml_global_information.gamestatechanged = false
	end
	
	if ( tickcount - ml_global_information.lasttick > tonumber(gPulseTime) ) then
		ml_global_information.lasttick = tickcount
		
		-- Update global variables \\ THIS MUST REMAIN THE FIRST UPDATE, OTHERWISE THERE WILL BE MISSING GLOBALS.
		ml_globals.UpdateGlobals()
		
		ml_global_information.CheckClass()
		
		-- Mesher OnUpdate
		ml_mesh_mgr.OnUpdate( tickcount )
		
		-- PartyManager OnUpdate
		--mc_multibotmanager.OnUpdate( tickcount )
		
		-- ml_blacklist.lua
		ml_blacklist.ClearBlacklists()
		
		-- ml_blacklist_mgr.lua
		ml_blacklist_mgr.UpdateEntryTime()
		ml_blacklist_mgr.UpdateEntries(tickcount)

		-- Run the Bot
		if ( NavigationManager:GetNavMeshState() == GLOBAL.MESHSTATE.MESHBUILDING ) then
			GUI_SetStatusBar("Loading Navigation Mesh...")
			
		elseif ( ml_global_information.running ) then		
					
			-- Update Marker status
			if ( gBotMode == GetString("grindMode") and ValidTable(GetCurrentMarker()) and ml_task_hub.shouldRun )then
				ml_log("Current Marker:"..GetCurrentMarker():GetName())
				
				local timesince = TimeSince(ml_global_information.MarkerTime)
				local timeleft = ((GetCurrentMarker():GetTime() * 1000) - timesince) / 1000
				ml_log("("..tostring(round(timeleft, 1)).."sec) | ")
			end
			
			-- Let the bot tick ;)
			if ( ml_global_information.BotModes[gBotMode] ) then
												
				if( ml_task_hub:CurrentTask() ~= nil) then
					ml_log(ml_task_hub:CurrentTask().name.." :")
				end
				
				if ( ml_task_hub.shouldRun ) then
										
					if (not ml_task_hub:Update() ) then
						ml_error("No task queued, please select a valid bot mode in the Settings drop-down menu")
					end
				end
				
				-- Unstuck OnUpdate
				--ai_unstuck:OnUpdate( tickcount )
					
				-- Update the Statusbar on the left/bottom screen
				GUI_SetStatusBar(ml_GetTraceString())					
			end
				
		elseif ( ml_global_information.running == false and gAutoStart == "1" and not ml_global_information.autoStartDisabled) then
			ml_global_information.togglebot(1)
		else
			GUI_SetStatusBar("BOT: Not Running")
		end
	end
end




function ml_global_information.eventhandler(arg)
	if ( arg == "ml_global_information.startStop" or arg == "MINION.toggle") then
		if ( gBotRunning == "1" ) then
			gBotRunning = "0"
			ml_global_information.togglebot("0")
		else
			gBotRunning = "1"
			ml_global_information.togglebot("1")
		end
	end
end

function ml_global_information.guivarupdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "gEnableLog" or
			k == "gGather" or
			k == "gMount" or
			k == "gVendor" or
			k == "gRepair" or
			k == "aLogin" or
			k == "aPassword" or
			k == "gPot" or
			k == "gPotiontype" or
			k == "gSprint" or
 			k == "gSprintStopThreshold" or
			k == "gPotvalue" or
			k == "gAutoStart" or 
			k == "gAutoCharacterSelect" or
			k == "gPlaySoundOnWhisper" or
			k == "g_usesoulgemtorevive" or 
			k == "g_rest" or 
			k == "g_resthp" or 
			k == "g_restmp" or 
			k == "g_restsp" or
			k == "gPlaySoundOnWhisper" or
			k == "gDevTest" or 
			k == "gPreventAttackingInnocents"
		)						
		then
			Settings.ESOMinion[tostring(k)] = v
		elseif ( k == "gAutoLogin" or k == "gAutoSelect") then
			ml_global_information.lasttick = 0
			Settings.ESOMinion[tostring(k)] = v		
		elseif ( k == "gBotRunning" ) then
			ml_global_information.togglebot(v)			
		elseif ( k == "gBotMode") then        
			Settings.ESOMinion[tostring(k)] = v
			ml_global_information.UpdateMode()
		elseif ( k == "gDevTest") then
			gEnableLog = v
			gLogCNE = v
			Settings.ESOMinion[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(ml_global_information.MainWindow.Name)
end

function ml_global_information.UpdateMode()
	if (gBotMode == "None") then	
		ml_task_hub:ClearQueues()
	else	
		local task = ml_global_information.BotModes[gBotMode]
		if (task ~= nil) then
			ml_task_hub:Add(task.Create(), LONG_TERM_GOAL, TP_ASAP)
		end
    end
end

function ml_global_information.CheckClass()
	if (ml_globals) then
		if (not ml_global_information.CurrentClass or (ml_global_information.CurrentClass and ml_global_information.CurrentClass ~= Player.class)) then
			ml_global_information.CurrentClass = Player.class
			ml_global_information.CurrentClassID = e("GetUnitClassId(player)")
			eso_skillmanager.UseDefaultProfile()
		end
	end
end

function ml_global_information.togglebot(arg)
	if arg == "0" then	
		d("Stopping Bot..")
		ml_global_information.running = false
		ml_task_hub.shouldRun = false		
		gBotRunning = "0"
		ml_global_information.ResetBot()
		ml_task_hub:ClearQueues()
		ml_global_information.UpdateMode()
		if(gAutoStart == "1" and ml_global_information.autoStartDisabled == false) then
			ml_global_information.autoStartDisabled = true
		end
	else
		d("Starting Bot..")
		ml_global_information.running = true
		ml_task_hub.shouldRun = true
		gBotRunning = "1"
		--mc_meshrotation.currentMapTime = ml_global_information.Now
	end
	
	local window = WindowManager:GetWindow(ml_global_information.MainWindow.Name)

	if (window) then
		local button = window:GetControl("StartBot") or window:GetControl("StopBot")
		if (button) then
			button:SetToggleState(ml_task_hub.shouldRun)
			if (ml_task_hub.shouldRun) then
				button:SetText("StopBot")
			else
				button:SetText("StartBot")
			end
		end
	end
end



function ml_global_information.ResetBot()
	Player:Stop()
	c_MoveToMarker.markerreachedfirsttime = false
	c_MoveToMarker.markerreached = false
	c_MoveToMarker.allowedToFight = false
	c_movetorandom.randompoint = nil
	c_movetorandom.randompointreached = false
	Player:ClearTarget()
end

function ml_global_information.Wait( seconds ) 
	ml_global_information.lasttick = ml_global_information.lasttick + seconds
end

function ml_global_information.ToggleAdvMenu()
    if (ml_global_information.advwindowvisible) then
        GUI_WindowVisible(ml_global_information.advwindow.Name,false)	
        ml_global_information.advwindowvisible = false
    else
		local wnd = GUI_GetWindowInfo("MinionBot")	
        GUI_MoveWindow( ml_global_information.advwindow.Name, wnd.x,wnd.y+wnd.height)
		GUI_WindowVisible(ml_global_information.advwindow.Name,true)	
        ml_global_information.advwindowvisible = true
    end
end

function esominion.register_var(setting, default)
	if (setting and default) then
		Settings.ESOMinion[setting] = (
		Settings.ESOMinion[setting] or default)
		
		_G[setting] = Settings.ESOMinion[setting]
	end
end

RegisterEventHandler("Module.Initalize",ml_global_information.moduleinit)
RegisterEventHandler("Gameloop.Update",ml_global_information.onupdate)
RegisterEventHandler("GUI.Update",ml_global_information.guivarupdate)
RegisterEventHandler("MINION.toggle", ml_global_information.eventhandler)
