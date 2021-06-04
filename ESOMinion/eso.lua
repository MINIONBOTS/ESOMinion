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
esominion.playerbuffs = {}
esominion.targetbuffs = {}
esominion.currentfishinghole = {}
esominion.hooked = false
esominion.hooktimer = 0
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
	local esomainmenu = {
		header = { id = "ESOMINION##MENU_HEADER", expanded = false, name = "ESOMinion", texture = GetStartupPath().."\\GUI\\UI_Textures\\eso.png"},
		members = {{ id = "ESOMINION##MENU_ADDONS", name = "Addons", tooltip = "Installed Lua Addons.", texture = GetStartupPath().."\\GUI\\UI_Textures\\addon.png"}	}
	} 
	esominion.SetMainVars()
	esominion.AddMode(GetString("assistMode"), eso_task_assist)
	esominion.AddMode(GetString("fishMode"), eso_task_fish)
	esominion.AddMode(GetString("gatherMode"), eso_task_gather)
	
	if (table.valid(esominion.modesToLoad)) then
		esominion.LoadModes()
		ESO_Common_BotRunning = false
	end
	
	-- set settings on startup
		
	gEnableLog = false
	ml_gui.ui_mgr:AddComponent(esomainmenu)
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
		open = false,
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
					if (GUI:Button(GetString("Start / Stop"),contentwidth,20)) then
						ml_global_information.ToggleRun()	
					end
					if (GUI:Button(GetString("Skill Manager"),contentwidth,20)) then
						eso_skillmanager.GUI.skillbook.open = not eso_skillmanager.GUI.skillbook.open
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
	--[[elseif (gamestate == ESO.GAMESTATE.MAINMENUSCREEN) then
		ml_global_information.MainMenuScreenOnUpdate( event, tickcount )
	elseif (gamestate == ESO.GAMESTATE.CHARACTERSCREEN) then
		ml_global_information.CharacterSelectScreenOnUpdate( event, tickcount )
	elseif (gamestate == ESO.GAMESTATE.ERROR) then
		ml_global_information.ResetLoginVars()
		ml_global_information.ErrorScreenOnUpdate( event, tickcount )]]
	end
end

ml_global_information.throttleTick = 0
ml_global_information.lastPulse = 0
function ml_global_information.InGameOnUpdate( event, tickcount )	
	if (ml_global_information.throttleTick > tickcount) or not Player then
		return false
	end
	ml_global_information.throttleTick = tickcount + 35
	
	memoize = {}
	if (table.valid(esominion.modesToLoad)) then
		esominion.LoadModes()
		ESO_Common_BotRunning = false
	end
	
	if (ml_global_information.autoStartQueued) then
		ml_global_information.autoStartQueued = false
		ml_global_information:ToggleRun() -- convert
	end
	
	if (Now() >= ml_global_information.nextRun) then
		
		ml_global_information.lastPulse = math.random(300,500)
		ml_global_information.nextRun = tickcount + ml_global_information.lastPulse
		
		if eso_skillmanager.roll then
			e("RollDodgeStop()")
		end
		
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
	
		if (ml_task_hub.shouldRun) then
			if (not ml_task_hub:Update()) then
				d("No task queued, please select a valid bot mode in the Settings drop-down menu")
			end
		end
	end
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
