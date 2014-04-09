-- Main config file of ESOMinion

eso_radar = {}
eso_radar.MainWindow = { Name = "Radar", x=250, y=200 , width=200, height=200 }
eso_radar.visible = false

function eso_radar.OnUpdate( event, tickcount )
    
end

-- Module Event Handler
function eso_radar.HandleInit()	
    GUI_SetStatusBar("Initalizing Radar...")
        
    if ( Settings.ESOMinion.gRadar == nil ) then
        Settings.ESOMinion.gRadar = "0"
    end		
    if ( Settings.ESOMinion.g2dRadar == nil ) then
        Settings.ESOMinion.g2dRadar = "0"
    end	
    if ( Settings.ESOMinion.g3dRadar == nil ) then
        Settings.ESOMinion.g3dRadar = "0"
    end	
    if ( Settings.ESOMinion.g2dRadarFullScreen == nil ) then
        Settings.ESOMinion.g2dRadarFullScreen = "0"
    end	
    if ( Settings.ESOMinion.gRadarShowObjects == nil ) then
        Settings.ESOMinion.gRadarShowObjects = "0"
    end		
    if ( Settings.ESOMinion.gRadarShowPlayers == nil ) then
        Settings.ESOMinion.gRadarShowPlayers = "0"
    end	
    if ( Settings.ESOMinion.gRadarShowAnchors == nil ) then
        Settings.ESOMinion.gRadarShowAnchors = "0"
    end	
    if ( Settings.ESOMinion.gRadarShowSieges == nil ) then
        Settings.ESOMinion.gRadarShowSieges = "0"
    end	
    if ( Settings.ESOMinion.gRadarShowMonsters == nil ) then
        Settings.ESOMinion.gRadarShowMonsters = "0"
    end		
	if ( Settings.ESOMinion.gRadarZoom == nil ) then
        Settings.ESOMinion.gRadarZoom = "10"
    end	
    if ( Settings.ESOMinion.gRadarX == nil ) then
        Settings.ESOMinion.gRadarX = 5
    end		
    if ( Settings.ESOMinion.gRadarY == nil ) then
        Settings.ESOMinion.gRadarY = 5
    end	
    
    GUI_NewWindow(eso_radar.MainWindow.Name,eso_radar.MainWindow.x,eso_radar.MainWindow.y,eso_radar.MainWindow.width,eso_radar.MainWindow.height)	
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("enableRadar"),"gRadar","Radar" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("enable2DRadar"),"g2dRadar","Radar" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("enable3DRadar"),"g3dRadar","Radar" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("fullscreenRadar"),"g2dRadarFullScreen","Radar" );
	GUI_NewNumeric(eso_radar.MainWindow.Name,"Zoom","gRadarZoom","Radar","1","200");    
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showPlayers"),"gRadarShowPlayers","RadarSettings" );
	GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showNPCs"),"gRadarShowMonsters","RadarSettings" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showObjects"),"gRadarShowObjects","RadarSettings" );
	GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showAnchors"),"gRadarShowAnchors","RadarSettings" );
	GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showSieges"),"gRadarShowSieges","RadarSettings" );	
        
    GUI_NewNumeric(eso_radar.MainWindow.Name,GetString("xPos"),"gRadarX","RadarSettings","0","2000" );
    GUI_NewNumeric(eso_radar.MainWindow.Name,GetString("yPos"),"gRadarY","RadarSettings","0","1280" );
    
    gRadar = Settings.ESOMinion.gRadar
    g2dRadar = Settings.ESOMinion.g2dRadar
    g3dRadar = Settings.ESOMinion.g3dRadar
    g2dRadarFullScreen = Settings.ESOMinion.g2dRadarFullScreen
	gRadarZoom = Settings.ESOMinion.gRadarZoom
    gRadarShowMonsters = Settings.ESOMinion.gRadarShowMonsters
    gRadarShowPlayers = Settings.ESOMinion.gRadarShowPlayers
    gRadarShowObjects = Settings.ESOMinion.gRadarShowObjects
	gRadarShowAnchors = Settings.ESOMinion.gRadarShowAnchors
	gRadarShowSieges = Settings.ESOMinion.gRadarShowSieges
    gRadarX = tonumber(Settings.ESOMinion.gRadarX/10)
    gRadarY = tonumber(Settings.ESOMinion.gRadarY/10)
    
    if ( gRadar == "0") then GameHacks:SetRadarSettings("gRadar",false) else GameHacks:SetRadarSettings("gRadar",true) end
    if ( g2dRadar == "0") then GameHacks:SetRadarSettings("g2dRadar",false) else GameHacks:SetRadarSettings("g2dRadar",true) end
    if ( g3dRadar == "0") then GameHacks:SetRadarSettings("g3dRadar",false) else GameHacks:SetRadarSettings("g3dRadar",true) end
    if ( g2dRadarFullScreen == "0") then GameHacks:SetRadarSettings("g2dRadarFullScreen",false) else GameHacks:SetRadarSettings("g2dRadarFullScreen",true) end
	if ( gRadarZoom == "0") then GameHacks:SetRadarSettings("gRadarZoom","5") end	
    if ( gRadarShowMonsters == "0") then GameHacks:SetRadarSettings("gRadarShowMonsters",false) else GameHacks:SetRadarSettings("gRadarShowMonsters",true) end
    if ( gRadarShowPlayers == "0") then GameHacks:SetRadarSettings("gRadarShowPlayers",false) else GameHacks:SetRadarSettings("gRadarShowPlayers",true) end
    if ( gRadarShowObjects == "0") then GameHacks:SetRadarSettings("gRadarShowObjects",false) else GameHacks:SetRadarSettings("gRadarShowObjects",true) end
	if ( gRadarShowAnchors == "0") then GameHacks:SetRadarSettings("gRadarShowAnchors",false) else GameHacks:SetRadarSettings("gRadarShowAnchors",true) end
	if ( gRadarShowSieges == "0") then GameHacks:SetRadarSettings("gRadarShowSieges",false) else GameHacks:SetRadarSettings("gRadarShowSieges",true) end
	
    if ( tonumber(gRadarX) ~= nil) then GameHacks:SetRadarSettings("gRadarX",tonumber(gRadarX)) end
    if ( tonumber(gRadarY) ~= nil) then GameHacks:SetRadarSettings("gRadarY",tonumber(gRadarY)) end
    
	GUI_NewButton(eso_radar.MainWindow.Name,"Cant See Radar? Press Me","Dev.ChangeMDepth")
	GUI_UnFoldGroup(eso_radar.MainWindow.Name,"Radar");	
    GUI_WindowVisible(eso_radar.MainWindow.Name,false)
end

function eso_radar.GUIVarUpdate(Event, NewVals, OldVals)
    for k,v in pairs(NewVals) do
        if (k == "gRadar" or
            k == "g2dRadar" or 			
            k == "g3dRadar" or
            k == "g2dRadarFullScreen" or
            k == "gRadarShowMonsters" or
            k == "gRadarShowPlayers" or
            k == "gRadarShowObjects" or	
			k == "gRadarShowAnchors" or
			k == "gRadarShowSieges")
        then
            Settings.ESOMinion[tostring(k)] = v
            if ( v == "0") then
                GameHacks:SetRadarSettings(k,false)
            else
                GameHacks:SetRadarSettings(k,true)
            end
        end
        if ( k == "gRadarX" and tonumber(v) ~= nil and tonumber(v) < 2000 and tonumber(v) >= 0) then
            Settings.ESOMinion[tostring(k)] = v*10
            GameHacks:SetRadarSettings(k,tonumber(v*10))
        end
        if ( k == "gRadarY" and tonumber(v) ~= nil and tonumber(v) < 2000 and tonumber(v) >= 0) then
            Settings.ESOMinion[tostring(k)] = v*10
            GameHacks:SetRadarSettings(k,tonumber(v*10))
        end
		if ( k == "gRadarZoom" and tonumber(v) ~= nil) then
            Settings.ESOMinion[tostring(k)] = v
            GameHacks:SetRadarSettings(k,tonumber(v))
        end
		
    end
    GUI_RefreshWindow(eso_radar.MainWindow.Name)
end

function eso_radar.ToggleMenu()
    if (eso_radar.visible) then
        GUI_WindowVisible(eso_radar.MainWindow.Name,false)	
        eso_radar.visible = false
    else
		local wnd = GUI_GetWindowInfo("MinionBot")	
        GUI_MoveWindow( eso_radar.MainWindow.Name, wnd.x,wnd.y+wnd.height)
		GUI_WindowVisible(eso_radar.MainWindow.Name,true)	
        eso_radar.visible = true
    end
end

-- Register Event Handlers
RegisterEventHandler("Module.Initalize",eso_radar.HandleInit)
RegisterEventHandler("Radar.toggle", eso_radar.ToggleMenu)
RegisterEventHandler("GUI.Update",eso_radar.GUIVarUpdate)