ml_global_information = { }
ml_global_information.window = { name="MinionBot", x=50, y=50, width=200, height=300 }
ml_global_information.advwindow = { name="AdvandedSettings", x=250, y=200 , width=200, height=170 }
ml_global_information.login = { name="AutoLogin", x=100, y=100 , width=230, height=140 }
ml_global_information.advwindowvisible = false
ml_global_information.path = GetStartupPath()
ml_global_information.Now = 0
ml_global_information.lasttick = 0
ml_global_information.running = false
ml_global_information.BotModes = {}
ml_global_information.lastgamestate = 0
ml_global_information.gamestatechanged = false


function ml_global_information.moduleinit()
	
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
	
	if ( Settings.ESOMinion.aLogin == nil ) then
		Settings.ESOMinion.aLogin = ""
	end
	if ( Settings.ESOMinion.aPassword == nil ) then
		Settings.ESOMinion.aPassword = ""
	end
	if ( Settings.ESOMinion.gAutoLogin == nil ) then
		Settings.ESOMinion.gAutoLogin = ""
	end	
	
	-- MAIN WINDOW
	GUI_NewWindow(ml_global_information.window.name,ml_global_information.window.x,ml_global_information.window.y,ml_global_information.window.width,ml_global_information.window.height)
	GUI_NewButton(ml_global_information.window.name,GetString("startStop"),"ml_global_information.startStop")
			
	GUI_NewButton(ml_global_information.window.name,GetString("showradar"),"Radar.toggle")
	RegisterEventHandler("ml_global_information.startStop", ml_global_information.eventhandler)
	GUI_NewCheckbox(ml_global_information.window.name,GetString("botEnabled"),"gBotRunning",GetString("botStatus"))
	GUI_NewComboBox(ml_global_information.window.name,GetString("botMode"),"gBotMode",GetString("botStatus"),"None")
	GUI_NewField(ml_global_information.window.name,GetString("attackRange"),"dAttackRange",GetString("botStatus"))
	
	
	GUI_NewNumeric(ml_global_information.window.name,GetString("pulseTime"),"gPulseTime",GetString("settings"),"10","10000")
	GUI_NewComboBox(ml_global_information.window.name,GetString("attackRange"),"gAttackRange",GetString("settings"),GetString("aAutomatic")..","..GetString("aRange")..","..GetString("aMelee"));
	GUI_NewCheckbox(ml_global_information.window.name,GetString("gatherMode"),"gGather",GetString("settings"))
	
	GUI_NewButton(ml_global_information.window.name, GetString("advancedSettings"), "AdvancedSettings.toggle")
	RegisterEventHandler("AdvancedSettings.toggle", ml_global_information.ToggleAdvMenu)
	
	-- ADVANCED SETTINGS WINDOW
	GUI_NewWindow(ml_global_information.advwindow.name,ml_global_information.advwindow.x,ml_global_information.advwindow.y,ml_global_information.advwindow.width,ml_global_information.advwindow.height,"",false)
	GUI_NewButton(ml_global_information.advwindow.name, GetString("skillManager"), "SkillManager.toggle")
	GUI_NewButton(ml_global_information.advwindow.name, GetString("meshManager"), "ToggleMeshmgr")
	
	GUI_WindowVisible(ml_global_information.advwindow.name,false)
	
	-- LOGIN WINDOW
	GUI_NewWindow(ml_global_information.login.name,ml_global_information.login.x,ml_global_information.login.y,ml_global_information.login.width,ml_global_information.login.height,"",true)
	GUI_NewField(ml_global_information.login.name,GetString("aLogin"),"aLogin",GetString("settings"))
	GUI_NewField(ml_global_information.login.name,GetString("aPassword"),"aPassword",GetString("settings"))
	GUI_NewCheckbox(ml_global_information.login.name,GetString("aAutologin"),"gAutoLogin",GetString("settings"))
	
	GUI_UnFoldGroup(ml_global_information.login.name,GetString("settings") )	
	
	aLogin = Settings.ESOMinion.aLogin	
	aPassword = Settings.ESOMinion.aPassword	
	gAutoLogin = Settings.ESOMinion.gAutoLogin	
	
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
	gPulseTime = Settings.ESOMinion.gPulseTime	
	gAttackRange = Settings.ESOMinion.gAttackRange
	gGather = Settings.ESOMinion.gGather
	
	GUI_UnFoldGroup(ml_global_information.window.name,GetString("botStatus") )
	
	
	--d("TEST")
	--local ev = g("EVENT_MANAGER")
	--d("Tablesize:"..tostring(TableSize(ev)))
	--d(tostring(type(ev)))
	--d(tostring(ev))
	
	--local eee = RegisterForEvent("test")

	--d(tostring(type(eee)))
	--d(tostring(eee))
	--tt = {}
	--setmetatable (tt, eee) 
	--DT(tt)
	--local ev = e("ZO_Debug_EventNotification(0,true,true)")
	
	
end
function tttt()
	d("DOWN LOL")
end
	
function ml_global_information.onupdate( event, tickcount )
	ml_global_information.Now = tickcount
	
	local gamestate = GetGameState()
	
	if (ml_global_information.lastgamestate ~= gamestate) then
		d("GameState changed...")
		ml_global_information.lastgamestate = gamestate
		ml_global_information.gamestatechanged = true
		GUI_WindowVisible(ml_global_information.advwindow.name,false)
		GUI_WindowVisible(ml_global_information.window.name,false)
		GUI_WindowVisible(mm.mainwindow.name,false)
		GUI_WindowVisible("Dev",false)
		GUI_ToggleConsole(false)
		GUI_WindowVisible(ml_global_information.login.name,false)
	end
	
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
		GUI_WindowVisible(ml_global_information.login.name,true)		
		ml_global_information.gamestatechanged = false			
	end	
				
	if ( tickcount - ml_global_information.lasttick > 10000 ) then
		ml_global_information.lasttick = tickcount
		
		ml_log("InTitleScreen: ")

			
		if ( aLogin ~= "" and aPassword ~= "" and gAutoLogin == "1") then
			d("Trying to login....")			
			if ( not e("ZO_Dialogs_IsShowingDialog()") ) then
				e("PregameLogin("..aLogin..","..aPassword..")")
			else
				ml_log("Login Error detected....trying again..")
				e("ZO_Dialogs_ReleaseAllDialogs(true)")
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
		GUI_WindowVisible(ml_global_information.login.name,true)		
		ml_global_information.gamestatechanged = false			
	end	
				
	if ( tickcount - ml_global_information.lasttick > 10000 ) then
		ml_global_information.lasttick = tickcount
		ml_log("InCharacterSelectScreen: ")

		
		ml_log("TODO: Select character and login! ")
		
		
		-- Update the Statusbar on the left/bottom screen
		GUI_SetStatusBar(ml_GetTraceString())		
	end
end

function ml_global_information.InGameOnUpdate( event, tickcount )
	ml_global_information.Now = tickcount
	
	-- show/hide correct windows for gamestate
	if ( ml_global_information.gamestatechanged == true ) then
		GUI_WindowVisible(ml_global_information.window.name,true)
		ml_global_information.gamestatechanged = false
	end

	if ( ml_global_information.running ) then		
		if ( tickcount - ml_global_information.lasttick > tonumber(gPulseTime) ) then
			ml_global_information.lasttick = tickcount
		
			-- Update global variables
			ml_global_information.UpdateGlobals()
			
			
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
				ai_unstuck:OnUpdate( tickcount )
					
				-- Update the Statusbar on the left/bottom screen
				GUI_SetStatusBar(ml_GetTraceString())					
			end
		end
	
	elseif ( ml_global_information.running == false and gAutostartbot == "1" ) then
		ml_global_information.togglebot(1)
	else
		GUI_SetStatusBar("BOT: Not Running")
	end
	
	-- Mesher OnUpdate
	mm.OnUpdate( tickcount )
		
	-- SkillManager OnUpdate
	eso_skillmanager.OnUpdate( tickcount )
	
	-- PartyManager OnUpdate
	--mc_multibotmanager.OnUpdate( tickcount )
	
	-- BlackList OnUpdate
	--mc_blacklist.OnUpdate( tickcount )
	
	-- FollowBot OnUpdate
	--mc_followbot.OnUpdate( tickcount )
end




function ml_global_information.eventhandler(arg)
	if ( arg == "ml_global_information.startStop" or arg == "MINION.toggle") then
		if ( gBotRunning == "1" ) then
			gAutostartbot = "0"
			ml_global_information.togglebot("0")			
		else
			gAutostartbot = "1"
			ml_global_information.togglebot("1")
		end
	end
end

function ml_global_information.guivarupdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "gEnableLog" or
			k == "gGather" or
			k == "aLogin" or
			k == "aPassword" or
			k == "gAutoLogin"
		)						
		then
			Settings.ESOMinion[tostring(k)] = v
		
		elseif ( k == "gBotRunning" ) then
			ml_global_information.togglebot(v)			
		elseif ( k == "gBotMode") then        
			Settings.ESOMinion[tostring(k)] = v
			ml_global_information.UpdateMode()
			--mm.NavMeshUpdate()
		
		end
	end
	GUI_RefreshWindow(ml_global_information.window.name)
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

function ml_global_information.togglebot(arg)
	if arg == "0" then	
		d("Stopping Bot..")
		ml_global_information.running = false
		ml_task_hub.shouldRun = false		
		gBotRunning = "0"
		ml_global_information.ResetBot()
		ml_task_hub:ClearQueues()
		ml_global_information.UpdateMode()
	else
		d("Starting Bot..")
		ml_global_information.running = true
		ml_task_hub.shouldRun = true
		gBotRunning = "1"
		--mc_meshrotation.currentMapTime = ml_global_information.Now
	end
end

function ml_global_information.UpdateGlobals()
	ml_global_information.AttackRange = eso_skillmanager.GetAttackRange()
	
	
	
	-- Update Debug fields	
	dAttackRange = ml_global_information.AttackRange	
end

function ml_global_information.ResetBot()

	Player:Stop()
	--Player:ClearTarget()
end

function ml_global_information.Wait( seconds ) 
	ml_global_information.lasttick = ml_global_information.lasttick + seconds
end

function ml_global_information.ToggleAdvMenu()
    if (ml_global_information.advwindowvisible) then
        GUI_WindowVisible(ml_global_information.advwindow.name,false)	
        ml_global_information.advwindowvisible = false
    else
		local wnd = GUI_GetWindowInfo("MinionBot")	
        GUI_MoveWindow( ml_global_information.advwindow.name, wnd.x,wnd.y+wnd.height)
		GUI_WindowVisible(ml_global_information.advwindow.name,true)	
        ml_global_information.advwindowvisible = true
    end
end

RegisterEventHandler("Module.Initalize",ml_global_information.moduleinit)
RegisterEventHandler("Gameloop.Update",ml_global_information.onupdate)
RegisterEventHandler("GUI.Update",ml_global_information.guivarupdate)
RegisterEventHandler("MINION.toggle", ml_global_information.eventhandler)