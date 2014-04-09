eso_global = { }
eso_global.window = { name="MinionBot", x=50, y=50, width=200, height=300 }
eso_global.advwindow = { name="AdvandedSettings", x=250, y=200 , width=200, height=170 }
eso_global.advwindowvisible = false
eso_global.path = GetStartupPath()
eso_global.now = 0
eso_global.lasttick = 0
eso_global.running = false
eso_global.BotModes = {}


function eso_global.moduleinit()
	
	if ( Settings.ESOMinion.gPulseTime == nil ) then
		Settings.ESOMinion.gPulseTime = "150"
	end
	if ( Settings.ESOMinion.gBotMode == nil ) then
        Settings.ESOMinion.gBotMode = GetString("grindMode")
    end
	
	-- MAIN WINDOW
	GUI_NewWindow(eso_global.window.name,eso_global.window.x,eso_global.window.y,eso_global.window.width,eso_global.window.height)
	GUI_NewButton(eso_global.window.name,GetString("startStop"),"eso_global.startStop")
		
	GUI_NewButton(eso_global.window.name,GetString("showradar"),"Radar.toggle")
	RegisterEventHandler("eso_global.startStop", eso_global.eventhandler)
	GUI_NewCheckbox(eso_global.window.name,GetString("botEnabled"),"gBotRunning",GetString("botStatus"))
	GUI_NewComboBox(eso_global.window.name,GetString("botMode"),"gBotMode",GetString("botStatus"),"None")
			
	GUI_NewNumeric(eso_global.window.name,GetString("pulseTime"),"gPulseTime",GetString("settings"),"10","10000")
	
	GUI_NewButton(eso_global.window.name, GetString("advancedSettings"), "AdvancedSettings.toggle")
	RegisterEventHandler("AdvancedSettings.toggle", eso_global.ToggleAdvMenu)
	
	-- ADVANCED SETTINGS WINDOW
	GUI_NewWindow(eso_global.advwindow.name,eso_global.advwindow.x,eso_global.advwindow.y,eso_global.advwindow.width,eso_global.advwindow.height,"",false)
	GUI_NewButton(eso_global.advwindow.name, GetString("meshManager"), "ToggleMeshmgr")
	
	GUI_WindowVisible(eso_global.advwindow.name,false)
	
	-- setup bot mode
    local botModes = "None"
    if ( TableSize(eso_global.BotModes) > 0) then
        local i,entry = next ( eso_global.BotModes )
        while i and entry do
            botModes = botModes..","..i
            i,entry = next ( eso_global.BotModes,i)
        end
    end
	
    gBotMode_listitems = botModes    
    gBotMode = Settings.ESOMinion.gBotMode	
	eso_global.UpdateMode()
	
	gBotRunning = "0"
	gPulseTime = Settings.ESOMinion.gPulseTime	
	
	GUI_UnFoldGroup(eso_global.window.name,GetString("botStatus") );		
end

function eso_global.onupdate( event, tickcount )
	eso_global.now = tickcount
	
	if ( eso_global.running ) then		
		if ( tickcount - eso_global.lasttick > tonumber(gPulseTime) ) then
			eso_global.lasttick = tickcount
			
			-- Update global variables
			eso_global.UpdateGlobals()
			
			
			-- Let the bot tick ;)
			if ( eso_global.BotModes[gBotMode] ) then
												
				if( ml_task_hub:CurrentTask() ~= nil) then
					ml_log(ml_task_hub:CurrentTask().name.." :")
				end
				
				if ( ml_task_hub.shouldRun ) then
				
					if (not ml_task_hub:Update() ) then
						ml_error("No task queued, please select a valid bot mode in the Settings drop-down menu")
					end
				end
				
				GUI_SetStatusBar(ml_GetTraceString())
			end
		end
	
	elseif ( eso_global.running == false and gAutostartbot == "1" ) then
		eso_global.togglebot(1)
	else
		GUI_SetStatusBar("BOT: Not Running")
	end
	
end


function eso_global.eventhandler(arg)
	if ( arg == "eso_global.startStop" or arg == "ESOMinion.toggle") then
		if ( gBotRunning == "1" ) then
			gAutostartbot = "0"
			eso_global.togglebot("0")			
		else
			gAutostartbot = "1"
			eso_global.togglebot("1")
		end
	end
end

function eso_global.guivarupdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "gEnableLog" )
						
		then
			Settings.ESOMinion[tostring(k)] = v
		
		elseif ( k == "gBotRunning" ) then
			eso_global.togglebot(v)			
		elseif ( k == "gBotMode") then        
			Settings.ESOMinion[tostring(k)] = v
			eso_global.UpdateMode()
			--mm.NavMeshUpdate()
		
		end
	end
	GUI_RefreshWindow(eso_global.window.name)
end

function eso_global.UpdateMode()
	if (gBotMode == "None") then	
		ml_task_hub:ClearQueues()
	else	
		local task = eso_global.BotModes[gBotMode]
		if (task ~= nil) then
			ml_task_hub:Add(task.Create(), LONG_TERM_GOAL, TP_ASAP)
		end
    end
end

function eso_global.togglebot(arg)
	if arg == "0" then	
		d("Stopping Bot..")
		eso_global.running = false
		ml_task_hub.shouldRun = false		
		gBotRunning = "0"
		eso_global.ResetBot()
		ml_task_hub:ClearQueues()
		eso_global.UpdateMode()
	else
		d("Starting Bot..")
		eso_global.running = true
		ml_task_hub.shouldRun = true
		gBotRunning = "1"
		mc_meshrotation.currentMapTime = eso_global.now
	end
end

function eso_global.UpdateGlobals()
	--eso_global.AttackRange = mc_skillmanager.GetAttackRange()
	
	
	
	-- Update Debug fields	
	dAttackRange = eso_global.AttackRange	
end

function eso_global.ResetBot()

	--Player:StopMovement()
	--Player:ClearTarget()
end

function eso_global.Wait( seconds ) 
	eso_global.lasttick = eso_global.lasttick + seconds
end

function eso_global.ToggleAdvMenu()
    if (eso_global.advwindowvisible) then
        GUI_WindowVisible(eso_global.advwindow.name,false)	
        eso_global.advwindowvisible = false
    else
		local wnd = GUI_GetWindowInfo("MinionBot")	
        GUI_MoveWindow( eso_global.advwindow.name, wnd.x,wnd.y+wnd.height)
		GUI_WindowVisible(eso_global.advwindow.name,true)	
        eso_global.advwindowvisible = true
    end
end

RegisterEventHandler("Module.Initalize",eso_global.moduleinit)
RegisterEventHandler("Gameloop.Update",eso_global.onupdate)
RegisterEventHandler("GUI.Update",eso_global.guivarupdate)
RegisterEventHandler("ESOMinion.toggle", eso_global.eventhandler)