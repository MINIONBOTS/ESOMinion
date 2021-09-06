esominion = {}
esominion.modes = {}
esominion.modesToLoad = {}
esominion.lootOpen = false
esominion.lootTime = 0
esominion.playerdead = false
esominion.incombat = false
esominion.lureType = 0
esominion.lureTypes = {}
esominion.activeTip = 0
esominion.petalive = nil
esominion.petalivecheck = 0
esominion.buffList = {}
esominion.currentfishinghole = {}
esominion.hooked = false
esominion.hooktimer = 0
esominion.petid = 0
esominion.lureBaitCount = 0
esominion.activeBait = 0
esominion.baits = {

	[1] = "Simple Bait",
	[2] = "Lake", --"Guts",
	[3] = "Foul", --"Crawlers",
	[4] = "River", --"Insect Parts",
	[5] = "Saltwater", --"Worms",
	[6] = "River", --"Shad",
	[7] = "Saltwater", --"Chub",
	[8] = "Lake", --"Minnow",
	[9] = "Foul", --"Fish Roe", -- 9
}
esominion.fishingNodes = {
	["Saltwater"] = "909",
	["Lake"] = "910",
	["River"] = "911",
	["Foul"] = "912",
}
esominion.reversefishingNodes = {
	[909] = "Saltwater",
	[910] = "Lake",
	[911] = "River",
	[912] = "Foul",
}
function esominion.GetSetting(strSetting,default)
	if (Settings.ESOMINION[strSetting] == nil) then
		Settings.ESOMINION[strSetting] = default
	end
	return Settings.ESOMINION[strSetting]	
end
function esominion.SetMainVars()
	-- Login
	local uuid = GetUUID()
	
	if ( Settings.Global.ESO_Login_ServiceAccounts and string.valid(uuid) and Settings.Global.ESO_Login_ServiceAccounts[uuid] ) then
		ESO_Login_ServiceAccount = Settings.Global.ESO_Login_ServiceAccounts[uuid]
	else
		ESO_Login_ServiceAccount = ""
	end
	if ( Settings.Global.ESO_Login_ServiceAccountPasswords and string.valid(uuid) and Settings.Global.ESO_Login_ServiceAccountPasswords[uuid] ) then
		ESO_Login_ServiceAccountPassword = Settings.Global.ESO_Login_ServiceAccountPasswords[uuid]
	else
		ESO_Login_ServiceAccountPassword = ""
	end
	
	ESO_Login_CharName = esominion.GetSetting("ESO_Login_CharName","")
	ESO_Login_CharIndex = esominion.GetSetting("ESO_Login_CharIndex",1)
	gAutoSelect = esominion.GetSetting("gAutoSelect",false)
	gAutoLogin = esominion.GetSetting("gAutoLogin",false)
	gBotModeIndex = 1
	gBotMode = esominion.GetSetting("gBotMode",GetString("assistMode"))
	gBotModeList = {GetString("none")}
	
	gSkillProfileNewIndex = 1
	gSMlastprofileNew = esominion.GetSetting("gSMlastprofileNew",GetString("none"))
	gSMprofile = GetString("none")
	gSMnewname = ""
	
	
	ESO_Common_BotRunning = false
end

function esominion.AddMode(name, task)
	d("added mode ["..name.."] with type ["..tostring(type(task)).."]")
	if task then
		task.friendly = name
		esominion.modesToLoad[name] = task
	else
		d("no task to load")
		d(name)
	end
end

function esominion.LoadModes()
	
	if (table.valid(esominion.modesToLoad)) then
		for modeName,task in pairs(esominion.modesToLoad) do
			d("Loading mode ["..tostring(modeName).."].")
			esominion.modes[modeName] = task
			if (task.UIInit) then
				task:UIInit()
			end
		end
		
		-- Empty out the table to prevent reloading.
		esominion.modesToLoad = {}
	end
	
	gBotModeList = {}
	if (table.valid(esominion.modes)) then
		local modes = esominion.modes
		for modeName,task in spairs(modes, function(modes,a,b) return modes[a].friendly < modes[b].friendly end) do
			table.insert(gBotModeList,modeName)
			if (modeName == gBotMode) then
				gBotModeIndex = table.size(gBotModeList)
			end
		end				
	end
	
	local modeIndex = GetKeyByValue(Retranslate(gBotMode),gBotModeList)
	if (modeIndex) then
		gBotModeIndex = modeIndex
	else
		local backupIndex = GetKeyByValue(GetString("assistMode"),gBotModeList)
		gBotModeIndex = backupIndex
		gBotMode = GetString("assistMode")
	end
	
	esominion.SwitchMode(gBotMode)
end

function esominion.Init()
	-- Register Button 
	esominion.SetMainVars()
	esominion.AddMode(GetString("assistMode"), eso_task_assist)
	esominion.AddMode(GetString("fishMode"), eso_task_fish)
	esominion.AddMode(GetString("gatherMode"), eso_task_gather)
	esominion.AddMode(GetString("grindMode"), eso_task_grind)
	
	if (table.valid(esominion.modesToLoad)) then
		esominion.LoadModes()
		ESO_Common_BotRunning = false
	end
	
	-- set settings on startup
		
	gEnableLog = false
end

esominion.GUI = {
	main = {
		name = "ESOMinion",
		open = true,
		visible = true,
		x = 0, y = 0, width = 0, height = 0,
	},
	main_task = {
		name = "ESOMINION_TASK_SECTION",
		open = true,
		visible = true,
		x = 0, y = 0, width = 0, height = 0,
	},
	main_bottom = {
		name = "ESOMINION_BOTTOM_BUTTONS",
		open = true,
		visible = true,
	},
	small = {
		name = "ESOMINION_MAIN_WINDOW_MINIMIZED",
		open = false,
		visible = true,
	},
	settings = {
		name = "Advanced Settings",
		open = false,
		visible = true,
	},
	login = {
		name = "Login",
		open = true,
		visible = true,
	},
	CharWindow = {
		name = "Character Name",
		open = true,
		visible = true,
	},
	help = {
		name = "Help Window",
		open = false,
		visible = true,
	},
	informational = {
		name = "Information Window",
		open = false,
		visible = true,
		message = "",
		open_until = 0,
		colors = { r = 1, g = 1, b = 1, a = 1 },
	},
	
	lockpicking = {
		name = "Lockpick Window",
		open = false,
		visible = true,
		message = "",
		open_until = 0,
		colors = { r = 1, g = 1, b = 1, a = 1 },
	},
	fishingedit = {
		name = "Position Window",
		open = false,
		visible = true,
		colors = { r = 1, g = 1, b = 1, a = 1 },
	},
	grindedit = {
		name = "Position Window",
		open = false,
		visible = true,
		colors = { r = 1, g = 1, b = 1, a = 1 },
	},
	gatheredit = {
		name = "Position Window",
		open = false,
		visible = true,
		colors = { r = 1, g = 1, b = 1, a = 1 },
	},
	current_tab = 1,
	draw_mode = 1,
}
function ml_global_information.GetMainIcon()
	local iconPath = ml_global_information.path.."\\GUI\\UI_Textures\\"
	if (ml_global_information.drawMode == 1) then
		return iconPath.."collapse.png"
	else
		return iconPath.."expand.png"
	end
end

function esominion.SwitchMode(mode)	
	local task = esominion.modes[mode]
    if (task ~= nil) then
		--esominion.SetModeOptions(mode)
		ml_global_information.mainTask = task
		
		if (ESO_Common_BotRunning) then
			--ml_global_information:ToggleRun()
		end
	end
end

function ml_global_information.DrawMainFull()
	local gamestate = GetGameState()
	if (gamestate == 3) then
		if (esominion.GUI.main.open) then
			if (ml_global_information.drawMode == 1) then
			
				GUI:SetNextWindowSize(350,300,GUI.SetCond_FirstUseEver) --set the next window size, only on first ever	
				GUI:SetNextWindowCollapsed(false,GUI.SetCond_Once)
				
				local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
				GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
				
				esominion.GUI.main.visible, esominion.GUI.main.open = GUI:Begin(esominion.GUI.main.name, esominion.GUI.main.open)
				if ( esominion.GUI.main.visible ) then 
				
					local x, y = GUI:GetWindowPos()
					local width, height = GUI:GetWindowSize()
					local contentwidth = GUI:GetContentRegionAvailWidth()
					
					esominion.GUI.x = x; esominion.GUI.y = y; esominion.GUI.width = width; esominion.GUI.height = height;
			
					if (ESO_Common_BotRunning) then
						GUI:Text(GetString("Bot Status:")) GUI:SameLine()
						GUI:TextColored(.1,1,.2,1,GetString("RUNNING"))
					else
						GUI:Text(GetString("Bot Status:")) GUI:SameLine()
						GUI:TextColored(1,.1,.2,1,GetString("NOT RUNNING"))
					end
					GUI:SameLine((contentwidth - 20),5)
					GUI:Image(ml_global_information.GetMainIcon(),14,14)
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(0)) then
							if (ml_global_information.drawMode == 1) then
								ml_global_information.drawMode = 0
							else
								ml_global_information.drawMode = 1
							end
						end
					end
					GUI:AlignFirstTextHeightToWidgets()
					--GUI:BeginGroup()
					GUI:Text(GetString("botMode")) 
					GUI:SameLine(110)
					GUI:PushItemWidth(contentwidth - 165)
					local modeChanged = GUI_Combo("##"..GetString("botMode"), "gBotModeIndex", "gBotMode", gBotModeList)
					GUI:PopItemWidth()
					if (modeChanged) then
						esominion.SwitchMode(gBotMode)
						local uuid = GetUUID()
						if ( string.valid(uuid) ) then
							if  ( Settings.ESOMINION.gBotModes == nil ) then Settings.ESOMINION.gBotModes = {} end
							Settings.ESOMINION.gBotModes[uuid] = gBotMode
							Settings.ESOMINION.gBotModes = Settings.ESOMINION.gBotModes
						end
					end
					GUI:Text(GetString("Skill Profile"))
					GUI:SameLine(110)
					GUI:PushItemWidth(contentwidth - 165)
					
					local newval,changed = GUI:Combo("##"..GetString("skillprofile"), gSkillProfileNewIndex, eso_skillmanager.SkillProfiles )
					GUI:PopItemWidth()
					--d(newval)
					--d("gSkillProfileNewIndex = "..tostring(gSkillProfileNewIndex))
					if (changed or newval ~= gSkillProfileNewIndex) then
						gSkillProfileNewIndex = newval
						Settings.ESOMINION.gSkillProfileNewIndex = newval
						Settings.ESOMINION.gSMlastprofileNew = eso_skillmanager.SkillProfiles[newval]
						
						eso_skillmanager.UseProfile(eso_skillmanager.SkillProfiles[newval])
						eso_skillmanager.SetDefaultProfile(eso_skillmanager.SkillProfiles[newval])
					end
					GUI:SameLine()
					
					local contentwidth = GUI:GetContentRegionAvailWidth()
					GUI:PushItemWidth(contentwidth)
					if ( GUI:Button("Create")) then
						eso_skillmanager.AddProfilePrompt()
					end
					GUI:PopItemWidth()
					
					local contentwidth = GUI:GetContentRegionAvailWidth()
					GUI:Spacing()
					GUI:Separator()
					GUI:Spacing()
					if esominion.smartrecord then
						if (GUI:Button(GetString("Stop Record"),contentwidth,20)) then
							esominion.smartrecord = not esominion.smartrecord
						end
						if (GUI:Button(GetString("Delete area"),contentwidth,20)) then
							ml_mesh_mgr.data.flooreditormode = 10
							NavigationManager.FloorEditorMode = 10
							NavigationManager.RecordDistance = 0
							NavigationManager.PreciseRecordDistance = 50
							ml_mesh_mgr.data.running = true
						end
					else
						if (GUI:Button(GetString("Sebbs Record"),contentwidth,20)) then
							esominion.smartrecord = not esominion.smartrecord
						end
					end
					GUI:Spacing()
					GUI:Separator()
					GUI:Spacing()
					if (GUI:Button(GetString("Start / Stop"),contentwidth,20)) then
						ml_global_information.ToggleRun()	
					end
					if (GUI:Button(GetString("Skill Manager"),contentwidth,20)) then
						eso_skillmanager.GUI.skillbook.open = not eso_skillmanager.GUI.skillbook.open
					end
					if (GUI:Button(GetString("Advanced Settings"),contentwidth,20)) then
						esominion.GUI.settings.open = not esominion.GUI.settings.open
					end
					if (GUI:Button(GetString("Debug"),contentwidth,20)) then
						gEnableLog = not gEnableLog
					end
					
					local mainTask = ml_global_information.mainTask
					if (mainTask) then
						if (mainTask.Draw) then
							mainTask:Draw()
						end
					end
				end
				GUI:End()
				GUI:PopStyleColor()
			end
		end
	end
end

function ml_global_information.DrawSmall()
	local gamestate = GetGameState()
	if (gamestate == 3) then
		if (esominion.GUI.main.open) then		
			if (ml_global_information.drawMode ~= 1) then
			
				GUI:SetNextWindowSize(190,50,GUI.SetCond_Always)
				local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
				GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .35)
				
				local flags = (GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
				GUI:Begin("ESO_MAIN_WINDOW_MINIMIZED", true, flags)
				local x, y = GUI:GetWindowPos()
				local width, height = GUI:GetWindowSize()
				local contentwidth = GUI:GetContentRegionAvailWidth()
				
				local child_color = (ESO_Common_BotRunning == true and { r = 0, g = .10, b = 0, a = .75 }) or { r = .10, g = 0, b = 0, a = .75 }
				GUI:PushStyleVar(GUI.StyleVar_ChildWindowRounding,10)
				GUI:PushStyleColor(GUI.Col_ChildWindowBg, child_color.r, child_color.g, child_color.b, child_color.a)
				
				GUI:BeginChild("##label-"..gBotMode,120,35,true)
				GUI:AlignFirstTextHeightToWidgets()
				GUI:Text(gBotMode)
				GUI:EndChild()
				if (GUI:IsItemHovered()) then
					if (GUI:IsMouseClicked(0)) then
						ml_global_information.ToggleRun()
					end
				end	
				GUI:SameLine(contentwidth-35);
				
				GUI:PopStyleColor()
				GUI:PopStyleVar()
				
				GUI:BeginChild("##style-switch",35,35,false)
				GUI:Text("");
				GUI:Image(ml_global_information.GetMainIcon(),14,14)
				if (GUI:IsItemHovered()) then
					if (GUI:IsMouseClicked(0)) then
						if (ml_global_information.drawMode == 1) then
							ml_global_information.drawMode = 0
						else
							ml_global_information.drawMode = 1
						end
					end
				end
				GUI:EndChild()		
				GUI:End()
				GUI:PopStyleColor()
			end
		end
	end
end

function ml_global_information.Draw( event, ticks ) 
	
	ml_global_information.DrawMainFull()
	ml_global_information.DrawSmall()
	ml_global_information.DrawLoginHandler()
	ml_global_information.DrawCharHandler()
end

function ml_global_information.OnUpdate( event, tickcount )
    ml_global_information.Now = tickcount
	
	local gamestate = GetGameState()
	
	--ml_global_information.Queueables()
	if (ml_global_information.IsYielding()) then
		--d("stuck in yield")
		return false
	end
	-- Switch according to the gamestate
	if (gamestate == ESO.GAMESTATE.INGAME) then
		--ml_global_information.ResetLoginVars()
		ml_global_information.InGameOnUpdate( event, tickcount );
	elseif (gamestate == ESO.GAMESTATE.MAINMENUSCREEN) then
		ml_global_information.MainMenuScreenOnUpdate( event, tickcount )
	elseif (gamestate == ESO.GAMESTATE.CHARACTERSCREEN) then
		ml_global_information.CharacterSelectScreenOnUpdate( event, tickcount )
	--[[elseif (gamestate == ESO.GAMESTATE.ERROR) then
		ml_global_information.ResetLoginVars()
		ml_global_information.ErrorScreenOnUpdate( event, tickcount )]]
	end
end

ml_global_information.throttleTick = 0
ml_global_information.lastPulse = 0
ml_global_information.lasttick = 0
esominion.smartrecord = false
function ml_global_information.InGameOnUpdate( event, tickcount )	
	if (ml_global_information.throttleTick > tickcount) or not Player then
		return false
	end
	ml_global_information.throttleTick = tickcount + 35
	
	memoize = {}
	if (table.valid(esominion.modesToLoad)) then
		ml_globals.UpdateGlobals()
		esominion.LoadModes()
		loadEvents()
		ESO_Common_BotRunning = false
	end
	
	if (ml_global_information.autoStartQueued) then
		ml_global_information.autoStartQueued = false
		ml_global_information:ToggleRun() -- convert
	end
	
	if (Now() >= ml_global_information.nextRun) then
		if esominion.hooked and TimeSince(esominion.hooktimer) > 5000 then
			esominion.hooked = false
		end
		-- Update global variables \\ THIS MUST REMAIN THE FIRST UPDATE, OTHERWISE THERE WILL BE MISSING GLOBALS.
		ml_globals.UpdateGlobals()
		
		esominion.buffList = {}
		BuildBuffsByIndex(Player.index)
		if ml_task_hub:CurrentTask() and IsNull(ml_task_hub:CurrentTask().targetID,0) ~= 0 then
			local target = EntityList:Get(ml_task_hub:CurrentTask().targetID)
			if table.valid(target) then
				eso_skillmanager.Cast( target )
			end
		end
		if esominion.smartrecord and not NavigationManager.ProcessingFloorMesh then
			--if Player.isswimming == 1 then
			if ml_mesh_mgr.data.flooreditormode ~= 5 then
					ml_mesh_mgr.data.flooreditormode = 5
					NavigationManager.FloorEditorMode = 5
					NavigationManager.RecordDistance = 0
					NavigationManager.RenderDistance = 1
					NavigationManager.PreciseRecordDistance = 50
					NavigationManager.UseMouseEditor = false
					NavigationManager.AutoSaveMesh = false
					ml_mesh_mgr.data.running = true
				--end
			elseif ml_mesh_mgr.data.flooreditormode ~= 3 then
				ml_mesh_mgr.data.flooreditormode = 3
				NavigationManager.FloorEditorMode = 3
				NavigationManager.RecordDistance = 0
				NavigationManager.RenderDistance = 1
				NavigationManager.PreciseRecordDistance = 50
				NavigationManager.UseMouseEditor = false
				NavigationManager.AutoSaveMesh = false
				ml_mesh_mgr.data.running = true
			end
		end
		ml_global_information.lastPulse = math.random(300,500)
		ml_global_information.nextRun = tickcount + ml_global_information.lastPulse
		
		if eso_skillmanager.needsrebuild then
			eso_skillmanager.BuildSkillsList()
		end
		if eso_skillmanager.roll then
			e("RollDodgeStop()")
		end
		
		if (ESO_Common_BotRunning) then
			local breakable = esominion.activeTip == eso_skillmanager.TIP_BREAK
			if (breakable) then
				if (not isAssistMode or (isAssistMode and gAssistDoBreak)) then
					if (TimeSince(eso_skillmanager.lastBreak) > 1000) then
						e("RollDodgeStart()")
						eso_skillmanager.roll = true
						eso_skillmanager.latencyTimer = Now() + 300
						eso_skillmanager.lastBreak = Now()
						d("Attempting to break CC.")
						return true
					end
				end
			end
			
			local avoidable = esominion.activeTip == eso_skillmanager.TIP_AVOID
			if (avoidable) then
				if (not isAssistMode or (isAssistMode and gAssistDoAvoid)) then
					if (TimeSince(eso_skillmanager.lastAvoid) > 2000) then
						if (Player.stamina.percent > 50) then
							e("RollDodgeStart()")
							eso_skillmanager.roll = true
							eso_skillmanager.latencyTimer = Now() + 300
							eso_skillmanager.lastAvoid = Now()
							d("Attempting to avoid.")
							return true
						end
					end
				end
			end
		end
	
		if (ml_task_hub.shouldRun) then
			if (not ml_task_hub:Update()) then
				d("No task queued, please select a valid bot mode in the Settings drop-down menu")
			end
		end
	end
end

function ml_global_information.MainMenuScreenOnUpdate( event, tickcount )	

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
			d("AccountLogin... ")
			
			if ( ESO_Login_ServiceAccount ~= "" and ESO_Login_ServiceAccountPassword ~= "" and gAutoLogin) then
				d("Trying to login....")			
				if ( not e("ZO_Dialogs_IsShowingDialog()") ) then
					e("PregameLogin("..ESO_Login_ServiceAccount..","..ESO_Login_ServiceAccountPassword..")")
				else
					ml_log("Login Error detected....trying again in 10 seconds..")
					e("ZO_Dialogs_ReleaseAllDialogs(true)")
				end
				
			end	
		
		end
		-- Update the Statusbar on the left/bottom screen
		--GUI_SetStatusBar(ml_GetTraceString())
	end

end
ml_global_information.charList = {}
function ml_global_information.CharacterSelectScreenOnUpdate( event, tickcount )
	ml_global_information.Now = tickcount
	-- show/hide correct windows for gamestate		
	if ( ml_global_information.gamestatechanged == true or not table.valid(ml_global_information.charList) ) then
	
		ml_global_information.gamestatechanged = false
		ml_global_information.charList = {}
		local charcount = e("GetNumCharacters()")
		-- populate char-dropdown-list
		for i = 1, charcount do
			local charName = TrimString(e("GetCharacterInfo("..tostring(i)..")"),3)
			table.insert(ml_global_information.charList,charName)
		end
	end	
	if table.valid(ml_global_information.charList) then
		if not ml_global_information.charList[ESO_Login_CharIndex] then
			ESO_Login_CharIndex = 1
		end
	end
			
	if ( tickcount - ml_global_information.lasttick > 10000 ) then
		ml_global_information.lasttick = tickcount
		d("InCharacterSelectScreen: ")
		
		if ( gAutoSelect and tostring(e("PregameStateManager_GetCurrentState()")) == "CharacterSelect") then
			if ( not e("ZO_Dialogs_IsShowingDialog()") ) then
				d("Select character and login! ")
				for i = 1, e("GetNumCharacters()") do
					local charName = TrimString(e("GetCharacterInfo("..tostring(i)..")"),3)
					if (charName == ESO_Login_CharName) then
						e("SelectCharacterToView("..tostring(i)..")")
					end
				end
				e("ZO_CharacterSelect_Login(false)")
			else
				d("Login Error detected....trying again in 10 seconds..")
				e("RequestCharacterList()")
			end
		end		
		
		-- Update the Statusbar on the left/bottom screen
		--GUI_SetStatusBar(ml_GetTraceString())		
	end
end


function ml_global_information.DrawLoginHandler()
	local gamestate = GetGameState()
	if (gamestate == 2) then
		if (esominion.GUI.login.open) then
			GUI:SetNextWindowSize(250,125,GUI.SetCond_Always) --set the next window size, only on first ever	
			GUI:SetNextWindowCollapsed(false,GUI.SetCond_Always)
			
			local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
			GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
			esominion.GUI.login.visible, esominion.GUI.login.open = GUI:Begin(esominion.GUI.login.name, esominion.GUI.login.open)
						
			GUI:PushItemWidth(150)
			
			local uuid = GetUUID()
				
			local val,changed = GUI:InputText(GetString("Account Name"),ESO_Login_ServiceAccount)
			if (changed and ESO_Login_ServiceAccount ~= val) then
				ESO_Login_ServiceAccount = val
				if not Settings.Global.ESO_Login_ServiceAccounts then
					Settings.Global.ESO_Login_ServiceAccounts = {}
				end
				Settings.Global.ESO_Login_ServiceAccounts[uuid] = val
				Settings.Global.ESO_Login_ServiceAccounts = Settings.Global.ESO_Login_ServiceAccounts
				
			end
			
			local val,changed = GUI:InputText(GetString("Password"),ESO_Login_ServiceAccountPassword)
			if (changed and ESO_Login_ServiceAccountPassword ~= val) then
				ESO_Login_ServiceAccountPassword = val
				if not Settings.Global.ESO_Login_ServiceAccountPasswords then
					Settings.Global.ESO_Login_ServiceAccountPasswords = {}
				end
				Settings.Global.ESO_Login_ServiceAccountPasswords[uuid] = val
				Settings.Global.ESO_Login_ServiceAccountPasswords = Settings.Global.ESO_Login_ServiceAccountPasswords
			end
					
			GUI_Capture(GUI:Checkbox(GetString("Auto Login"),gAutoLogin),"gAutoLogin");
			
			GUI:PopItemWidth()
			GUI:End()
			GUI:PopStyleColor()
		end
	end
end
function ml_global_information.DrawCharHandler()
	local gamestate = GetGameState()
	if (gamestate == 1) then
		if (esominion.GUI.login.open) then
			GUI:SetNextWindowSize(250,125,GUI.SetCond_Always) --set the next window size, only on first ever	
			GUI:SetNextWindowCollapsed(false,GUI.SetCond_Always)
			
			local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
			GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
			esominion.GUI.CharWindow.visible, esominion.GUI.CharWindow.open = GUI:Begin(esominion.GUI.CharWindow.name, esominion.GUI.CharWindow.open)
						
			GUI:PushItemWidth(150)
			
			local uuid = GetUUID()
				
			local val,changed = GUI:Combo("Select Char", ESO_Login_CharIndex, ml_global_information.charList )
			if (changed and ESO_Login_CharIndex ~= val) then
				ESO_Login_CharIndex = val
				Settings.ESOMINION["ESO_Login_CharIndex"] = ESO_Login_CharIndex
				ESO_Login_CharName = ml_global_information.charList[val]
				Settings.ESOMINION["ESO_Login_CharName"] = ESO_Login_CharName
			end
			GUI_Capture(GUI:Checkbox(GetString("Auto Select"),gAutoSelect),"gAutoSelect");
			
			GUI:PopItemWidth()
			GUI:End()
			GUI:PopStyleColor()
		end
	end
end

function ml_global_information.DrawAccountDetails()

			
	GUI:SetNextWindowSize(350,300,GUI.SetCond_FirstUseEver) --set the next window size, only on first ever	
	GUI:SetNextWindowCollapsed(false,GUI.SetCond_Once)
	
	local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
	GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
	
	esominion.GUI.main.visible, esominion.GUI.main.open = GUI:Begin(esominion.GUI.main.name, esominion.GUI.main.open)
	local x, y = GUI:GetWindowPos()
	local width, height = GUI:GetWindowSize()
	local contentwidth = GUI:GetContentRegionAvailWidth()
	
	esominion.GUI.x = x; esominion.GUI.y = y; esominion.GUI.width = width; esominion.GUI.height = height;
	
	
			
			

end
function ml_global_information.UpdateMode()
	if (gBotMode == GetString("none")) then	
		ml_task_hub:ClearQueues()
	else	
		local task = ml_global_information.BotModes[gBotMode]
		if (task ~= nil) then
			ml_task_hub:Add(task.Create(), LONG_TERM_GOAL, TP_ASAP)
		end
    end
end
function ml_global_information.ToggleRun()	
	if (ESO_Common_BotRunning) then
		--ml_task_hub.shouldRun = false
		ESO_Common_BotRunning = false
		d("Stopping Bot..")
		ml_global_information.running = false
		ml_task_hub.shouldRun = false		
		ml_task_hub:ClearQueues()
		ml_global_information.UpdateMode()
		
		if Player:IsMoving() then
			Player:StopMovement()
		end	
	else
		--ml_task_hub.shouldRun = true
		ESO_Common_BotRunning = true
		d("Starting Bot..")
		ml_global_information.running = true
		ml_task_hub.shouldRun = true
		ml_global_information.UpdateMode()
	end	
	
	-- Do some resets here.
	--ml_marker_mgr.currentMarker = nil
end
function ml_global_information.UpdateMode()
	if (gBotMode == GetString("none")) then	
		ml_task_hub:ClearQueues()
	else	
		local task = esominion.modes[gBotMode]
		if (task ~= nil) then
			ml_task_hub:Add(task.Create(), LONG_TERM_GOAL, TP_ASAP)
		end
    end
end
function esominion.SetMode(mode)
    local task = esominion.modes[mode]
    if (task ~= nil) then
		Hacks:SkipCutscene(gSkipCutscene)
		ml_task_hub:Add(task.Create(), LONG_TERM_GOAL, TP_ASAP)
    end
end

RegisterEventHandler("Module.Initalize",esominion.Init, "esominion.Init")
RegisterEventHandler("Gameloop.Update",ml_global_information.OnUpdate,"esominion OnUpdate")
RegisterEventHandler("Gameloop.Draw", ml_global_information.Draw,"esominion Draw")

Lockpicker = {}
Lockpicker.delay = 0
Lockpicker.chamber = 0
Lockpicker.timer = 0
Lockpicker.interactType = 0
function Lockpicker.timeRemaining()

	if Lockpicker.timer > 0  then
		return  Lockpicker.timer - Now() 
	end
	return 0
end
Lockpicker.Chamber1 = ""
Lockpicker.Chamber2 = ""
Lockpicker.Chamber3 = ""
Lockpicker.Chamber4 = ""
Lockpicker.Chamber5 = ""
function Lockpicker.OnUpdate()
	if (GetGameState() == ESO.GAMESTATE.INGAME) then
	
		--[[if not ESO_Common_BotRunning then
			return false
		end]]
		if (gBotMode == GetString("assistMode") and not gAssistDoLockpick) then
			return false
		end
		if Now() > Lockpicker.delay then
			if Player.interacting then
				if Player.interacttype == 20 then
					if Lockpicker.timer == 0 then
						Lockpicker.timer = Now() + e("GetLockpickingTimeLeft()")
					end
					local timeRemaining = Lockpicker.timeRemaining()
					if (timeRemaining > 0) then
						esominion.GUI.lockpicking.open = true
						if Lockpicker.chamber == 0 then
							for i = 1,5 do
								local isChamberSolved = e("IsChamberSolved(" .. i .. ")")
								if (not isChamberSolved) then
									d("Start setting Chamber "..tostring(i)..".")
									e("StartSettingChamber(" .. i .. ")")
									e("PlaySound(Lockpicking_Lockpicker_contact)")
									e("PlaySound(Lockpicking_chamber_start)")
									Lockpicker.chamber = i
									ml_global_information.Await(math.random(400,600))
									return true
								else
									if i == 1 then
										Lockpicker.Chamber1 = "Set"
									elseif i == 2 then
										Lockpicker.Chamber2 = "Set"
									elseif i == 3 then
										Lockpicker.Chamber3 = "Set"
									elseif i == 4 then
										Lockpicker.Chamber4 = "Set"
									elseif i == 5 then
										Lockpicker.Chamber5 = "Set"
									end
								end
							end
						else
							local chamberStress = e("GetSettingChamberStress()")
							--d("chamberStress = "..tostring(chamberStress))
							if (chamberStress >= 0.2) then
								e("PlaySound(Lockpicking_chamber_stress)")
								e("StopSettingChamber()")
								d("Chamber "..tostring(Lockpicker.chamber).." is solved.")
								Lockpicker.chamber = 0
								ml_global_information.Await(math.random(800,1000))
							end
							return true
						end
					end
				end
			else
				Lockpicker.timer = 0
				Lockpicker.Chamber1 = ""
				Lockpicker.Chamber2 = ""
				Lockpicker.Chamber3 = ""
				Lockpicker.Chamber4 = ""
				Lockpicker.Chamber5 = ""
			end
			Lockpicker.delay = Now() + math.random(400,600)
		end
		Lockpicker.Chamber1 = ""
		Lockpicker.Chamber2 = ""
		Lockpicker.Chamber3 = ""
		Lockpicker.Chamber4 = ""
		Lockpicker.Chamber5 = ""
		esominion.GUI.lockpicking.open = false
	end
	return false
end
function Lockpicker.Draw()

	if (esominion.GUI.lockpicking.open) then
		GUI:SetNextWindowSize(250,125,GUI.SetCond_Always) --set the next window size, only on first ever	
		GUI:SetNextWindowCollapsed(false,GUI.SetCond_Always)
		
		local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
		GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
		
		local flags = (GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
		esominion.GUI.lockpicking.visible, esominion.GUI.lockpicking.open = GUI:Begin(esominion.GUI.lockpicking.name, esominion.GUI.lockpicking.open, flags)
		if ( esominion.GUI.lockpicking.visible ) then 
		
			local x, y = GUI:GetWindowPos()
			local width, height = GUI:GetWindowSize()
			local contentwidth = GUI:GetContentRegionAvailWidth()
			
			esominion.GUI.x = x; esominion.GUI.y = y; esominion.GUI.width = width; esominion.GUI.height = height;
	
	
			GUI:Separator()
			
			GUI:AlignFirstTextHeightToWidgets() 
			GUI:Text(GetString("Chamber 1"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber1 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 1 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 2"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber2 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 2 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 3"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber3 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 3 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 4"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber4 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 4 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 5"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber5 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 5 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
		end
		GUI:End()
		GUI:PopStyleColor()
	end
end
RegisterEventHandler("Gameloop.Draw",Lockpicker.Draw,"Lockpicker Draw")
RegisterEventHandler("Gameloop.Update",Lockpicker.OnUpdate,"Lockpicker OnUpdate")


AdvancedSettings = {}
AdvancedSettings.shouldUseSoulGem = true
function AdvancedSettings.Draw()
	if (esominion.GUI.settings.open) then
		GUI:SetNextWindowSize(600,500,GUI.SetCond_FirstUseEver)	
		GUI:SetNextWindowCollapsed(false,GUI.SetCond_Once)
		local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
		GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
		esominion.GUI.settings.visible, esominion.GUI.settings.open = GUI:Begin(esominion.GUI.settings.name, esominion.GUI.settings.open)
		if ( esominion.GUI.settings.visible ) then
			GUI:BeginChild("main-sidebar", 150, 0, true)
			local tabindex, tabname = GUI_DrawVerticalTabs(esominion.GUI.settings.main_tabs)
			GUI:EndChild()
			GUI:SameLine(170)
			GUI:BeginChild("main-content", 0, 0, false)
			if (tabindex == 1) then
				GUI:BeginChild("##main-header-general", 0, GUI_GetFrameHeight(10), true)
				AdvancedSettings.shouldUseSoulGem = GUI:Checkbox("Use SoulGem on death", AdvancedSettings.shouldUseSoulGem)
				GUI:EndChild()
			end
			GUI:EndChild()
		end
		GUI:End()
		GUI:PopStyleColor()
	end
end

function AdvancedSettings.Init()
	esominion.GUI.settings.main_tabs = GUI_CreateTabs("General", true)
end
RegisterEventHandler("Module.Initalize", AdvancedSettings.Init,"AdvancedSettings Init")
RegisterEventHandler("Gameloop.Draw", AdvancedSettings.Draw,"AdvancedSettings Draw")
