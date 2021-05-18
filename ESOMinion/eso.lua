esominion = {}
esominion.modes = {}
esominion.modesToLoad = {}

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
	
	if (table.valid(esominion.modesToLoad)) then
		esominion.LoadModes()
		ESO_Common_BotRunning = false
	end
	
	-- set settings on startup
	gAssistDoLockpick = esominion.GetSetting("gAssistDoLockpick",true)
	gAssistUsePotions = esominion.GetSetting("gAssistUsePotions",true)
	gPreventAttackingInnocents = esominion.GetSetting("gPreventAttackingInnocents",true)
	gSKMWeaving = esominion.GetSetting("gSKMWeaving",false)
		
	
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
					local modeChanged = GUI:Combo("##"..GetString("botMode"), gBotModeIndex, gBotModeList )
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
	
	if (table.valid(esominion.modesToLoad)) then
		esominion.LoadModes()
		ESO_Common_BotRunning = false
	end
	
	if (ml_global_information.autoStartQueued) then
		ml_global_information.autoStartQueued = false
		ml_global_information:ToggleRun() -- convert
	end
	
	if (Now() >= ml_global_information.nextRun) then
		
		ml_global_information.lastPulse = math.random(300,400)
		ml_global_information.nextRun = tickcount + ml_global_information.lastPulse
		--ml_global_information.lastPulseShortened = false
				
       --[[ if (ml_task_hub:CurrentTask() ~= nil) then
            FFXIV_Core_ActiveTaskName = ml_task_hub:CurrentTask().name
        end]]
		
		--[[if Lockpicker.OnUpdate() then
			return true
		end]]
		
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

function GUI_Capture(newVal,varName,onChange,forceSave)
	local forceSave = IsNull(forceSave,false)
	local needsSave = false
	
	local currentVal = _G[varName]
	if (forceSave or currentVal ~= newVal or (type(newVal) == "table" and not deepcompare(currentVal,newVal))) then
		_G[varName] = newVal
		needsSave = true
		if (onChange and type(onChange) == "function") then
			onChange()
		end
	end
		
	if (needsSave) then
		Settings.ESOMINION[varName] = newVal
	end

	return newVal
end

function SaveToFileX(path, ...)


local write, writeIndent, writers, refCount;

	
-- write thing (dispatcher)
write = function (file, item, level, objRefNames)
	writers[type(item)](file, item, level, objRefNames);
end;

-- write indent
writeIndent = function (file, level)
	for i = 1, level do
		file:write("\t");
	end;
end;

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1;
		else
			objRefCount[item] = 1;
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k);
				refCount(objRefCount, v);
			end;
		end;
	end;
end;

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (file, item)
			file:write("nil");
		end;
	["number"] = function (file, item)
			file:write(tostring(item));
		end;
	["string"] = function (file, item)
			file:write(string.format("%q", item));
		end;
	["boolean"] = function (file, item)
			if item then
				file:write("true");
			else
				file:write("false");
			end
		end;
	["table"] = function (file, item, level, objRefNames)
			local refIdx = objRefNames[item];
			if refIdx then
				-- Table with multiple references
				file:write("multiRefObjects["..refIdx.."]");
			else
				-- Single use table
				file:write("{\n");
				for k, v in table.pairsbykeys(item) do
					writeIndent(file, level+1);
					file:write("[");
					write(file, k, level+1, objRefNames);
					file:write("] = ");
					write(file, v, level+1, objRefNames);
					file:write(";\n");
				end
				writeIndent(file, level);
				file:write("}");
			end;
		end;
	["function"] = function (file, item)
			file:write("nil --[[function]]\n");			
		end;
	["thread"] = function (file, item)
			file:write("nil --[[thread]]\n");
		end;
	["userdata"] = function (file, item)
			file:write("nil --[[userdata]]\n");
		end;
}

	--function (path, ...)
		local file, e;
		if type(path) == "string" then
			-- Path, open a file
			file, e = io.open(path, "w");
			if not file then
				return error(e);
			end
		else
			-- Just treat it as file
			file = path;
		end
		local n = select("#", ...);
		-- Count references
		local objRefCount = {}; -- Stores reference that will be exported
		for i = 1, n do
			refCount(objRefCount, (select(i,...)));
		end;
		
		-- Export Objects with more than one ref and assign name
		-- First, create empty tables for each
		local objRefNames = {};
		local objRefIdx = 0;
		--[=[
		file:write("-- Persistent Data\n");
		file:write("local multiRefObjects = {\n");
		for obj, count in pairs(objRefCount) do
			if count > 99999999999999999 then
				objRefIdx = objRefIdx + 1;
				objRefNames[obj] = objRefIdx;
				file:write("{};"); -- table objRefIdx
			end;
		end;
		file:write("\n} -- multiRefObjects\n");
		-- Then fill them (this requires all empty multiRefObjects to exist)
		for obj, idx in pairs(objRefNames) do
			for k, v in pairs(obj) do
				file:write("multiRefObjects["..idx.."][");
				write(file, k, 0, objRefNames);
				file:write("] = ");
				write(file, v, 0, objRefNames);
				file:write(";\n");
			end;
		end;
		--]=]
		-- Create the remaining objects
		for i = 1, n do
			file:write("local ".."obj"..i.." = ");
			write(file, (select(i,...)), 0, objRefNames);
			file:write("\n");
		end
		-- Return them
		if n > 0 then
			file:write("return obj1");
			for i = 2, n do
				file:write(" ,obj"..i);
			end;
			file:write("\n");
		else
			file:write("return\n");
		end;
		file:close();
	--end;
end

function GetLowestValue(...)
	local lowestValue = math.huge
	
	local vals = {...}
	if (table.valid(vals)) then
		for k,value in pairs(vals) do
			if (value < lowestValue) then
				lowestValue = value
			end
		end
	end
	
	return lowestValue
end
function GetHighestValue(...)
	local highestValue = 0
	
	local vals = {...}
	if (table.valid(vals)) then
		for k,value in pairs(vals) do
			if (value > highestValue) then
				highestValue = value
			end
		end
	end
	
	return highestValue
end
RegisterEventHandler("Module.Initalize",esominion.Init, "esominion.Init")
RegisterEventHandler("Gameloop.Update",ml_global_information.OnUpdate,"esominion OnUpdate")
RegisterEventHandler("Gameloop.Draw", ml_global_information.Draw,"esominion Draw")