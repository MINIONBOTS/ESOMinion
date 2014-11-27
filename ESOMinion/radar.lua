-- Main config file of ESOMinion

eso_radar = {}
eso_radar.MainWindow = { Name = "Radar", x=250, y=200 , width=200, height=300 }
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
	if ( Settings.ESOMinion.gRadarZoom == nil ) then
        Settings.ESOMinion.gRadarZoom = "10"
    end	
    if ( Settings.ESOMinion.gRadarX == nil ) then
        Settings.ESOMinion.gRadarX = "50"
    end		
    if ( Settings.ESOMinion.gRadarY == nil ) then
        Settings.ESOMinion.gRadarY = "50"
    end
    if ( Settings.ESOMinion.gRadarSize == nil ) then
        Settings.ESOMinion.gRadarSize = "300"
    end
	if ( Settings.ESOMinion.gRadar2dBackground == nil ) then
        Settings.ESOMinion.gRadar2dBackground = "1"
    end
	if ( Settings.ESOMinion.gRadarCentered == nil ) then
		Settings.ESOMinion.gRadarCentered = "1"
    end
	
	
	if ( Settings.ESOMinion.gRadarShowObjects == nil ) then
        Settings.ESOMinion.gRadarShowObjects = "0"
    end		
    if ( Settings.ESOMinion.gRadarShowPlayers == nil ) then
        Settings.ESOMinion.gRadarShowPlayers = "0"
    end	
    if ( Settings.ESOMinion.gRadarShowOnlyGatherables == nil ) then
        Settings.ESOMinion.gRadarShowOnlyGatherables = "0"
    end	
    if ( Settings.ESOMinion.gRadarShowSieges == nil ) then
        Settings.ESOMinion.gRadarShowSieges = "0"
    end	
    if ( Settings.ESOMinion.gRadarShowMonsters == nil ) then
        Settings.ESOMinion.gRadarShowMonsters = "0"
    end		
    
    GUI_NewWindow(eso_radar.MainWindow.Name,eso_radar.MainWindow.x,eso_radar.MainWindow.y,eso_radar.MainWindow.width,eso_radar.MainWindow.height)	
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("enableRadar"),"gRadar","Radar" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("enable2DRadar"),"g2dRadar","Radar" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("enable3DRadar"),"g3dRadar","Radar" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("RadarCentered"),"gRadarCentered","Radar" );
	GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("enable2DRadarBackground"),"gRadar2dBackground","Radar" );	
	GUI_NewNumeric(eso_radar.MainWindow.Name,"Zoom","gRadarZoom","Radar","1","200");  
    GUI_NewNumeric(eso_radar.MainWindow.Name,GetString("xPos"),"gRadarX","RadarSettings","0","2000" );
    GUI_NewNumeric(eso_radar.MainWindow.Name,GetString("yPos"),"gRadarY","RadarSettings","0","1280" );
	GUI_NewNumeric(eso_radar.MainWindow.Name,GetString("Size"),"gRadarSize","RadarSettings","0","1000" );
	
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showPlayers"),"gRadarShowPlayers","RadarSettings" );
	GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showNPCs"),"gRadarShowMonsters","RadarSettings" );
    GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showObjects"),"gRadarShowObjects","RadarSettings" );
	GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showOnlyGatherables"),"gRadarShowOnlyGatherables","RadarSettings" );
	GUI_NewCheckbox(eso_radar.MainWindow.Name,GetString("showSieges"),"gRadarShowSieges","RadarSettings" );	

    
    gRadar = Settings.ESOMinion.gRadar
    g2dRadar = Settings.ESOMinion.g2dRadar
    g3dRadar = Settings.ESOMinion.g3dRadar
    gRadarCentered = Settings.ESOMinion.gRadarCentered
	gRadar2dBackground = Settings.ESOMinion.gRadar2dBackground
	gRadarZoom = Settings.ESOMinion.gRadarZoom
    gRadarX = Settings.ESOMinion.gRadarX
    gRadarY = Settings.ESOMinion.gRadarY
	gRadarSize = Settings.ESOMinion.gRadarSize
	
	gRadarShowMonsters = Settings.ESOMinion.gRadarShowMonsters
    gRadarShowPlayers = Settings.ESOMinion.gRadarShowPlayers
    gRadarShowObjects = Settings.ESOMinion.gRadarShowObjects
	gRadarShowOnlyGatherables = Settings.ESOMinion.gRadarShowOnlyGatherables
	gRadarShowSieges = Settings.ESOMinion.gRadarShowSieges
    
	-- Set values
	if ( RadarManager ) then		
		RadarManager.x = tonumber(gRadarX)
		RadarManager.y = tonumber(gRadarY)
		RadarManager.size = tonumber(gRadarSize)
		RadarManager.zoom = tonumber(gRadarZoom)
		RadarManager.show2d = (g2dRadar == "1")
		RadarManager.show3d = (g3dRadar == "1")
		RadarManager.centered = (gRadarCentered == "1")
		RadarManager.showbackground = (gRadar2dBackground == "1")		
		RadarManager.show = (gRadar == "1")
		
		
		-- Set Filters
		eso_radar.UpdateFilters()
			
	end
	    
	--GUI_NewButton(eso_radar.MainWindow.Name,"Cant See Radar? Press Me","Dev.ChangeMDepth")
	GUI_UnFoldGroup(eso_radar.MainWindow.Name,"Radar");
	GUI_UnFoldGroup(eso_radar.MainWindow.Name,"RadarSettings");
    GUI_WindowVisible(eso_radar.MainWindow.Name,false)
end

function eso_radar.UpdateFilters()
	RadarManager:ClearFilter()
	
	if ( gRadarShowPlayers == "1") then RadarManager:AddFilter("player,alive") end
	
	if ( gRadarShowMonsters == "1") then RadarManager:AddFilter("npc,alive") end
	
	if ( gRadarShowObjects == "1") then RadarManager:AddFilter("type=3;4;7;8") end
	
	if ( gRadarShowOnlyGatherables == "1") then RadarManager:AddFilter("gatherable") end
	
	if ( gRadarShowSieges == "1") then RadarManager:AddFilter("type=6") end
	
end

function eso_radar.GUIVarUpdate(Event, NewVals, OldVals)
    for k,v in pairs(NewVals) do
        if (k == "gRadar") then Settings.ESOMinion[tostring(k)] = v RadarManager.show = (v == "1") 
		elseif (k == "g2dRadar") then Settings.ESOMinion[tostring(k)] = v RadarManager.show2d = (v == "1") 
		elseif (k == "g3dRadar") then Settings.ESOMinion[tostring(k)] = v RadarManager.show3d = (v == "1") 
		elseif (k == "gRadarCentered") then Settings.ESOMinion[tostring(k)] = v RadarManager.centered = (v == "1")
		elseif (k == "gRadar2dBackground") then Settings.ESOMinion[tostring(k)] = v RadarManager.showbackground = (v == "1")		
        elseif ( k == "gRadarX" and tonumber(v) ~= nil and tonumber(v) < 2000 and tonumber(v) >= 0) then
            Settings.ESOMinion[tostring(k)] = v
            RadarManager.x = tonumber(v)
        
        elseif ( k == "gRadarY" and tonumber(v) ~= nil and tonumber(v) < 2000 and tonumber(v) >= 0) then
            Settings.ESOMinion[tostring(k)] = v
            RadarManager.y = tonumber(v)
        
		elseif ( k == "gRadarSize" and tonumber(v) ~= nil and tonumber(v) < 2000 and tonumber(v) >= 0) then
            Settings.ESOMinion[tostring(k)] = v
            RadarManager.size = tonumber(v)
        
		elseif ( k == "gRadarZoom" and tonumber(v) ~= nil) then
            Settings.ESOMinion[tostring(k)] = v
			RadarManager.zoom = tonumber(v)
        
		elseif (k == "gRadarShowPlayers" or
				k == "gRadarShowMonsters" or
				k == "gRadarShowObjects" or
				k == "gRadarShowOnlyGatherables" or
				k == "gRadarShowSieges" )
		then 
			Settings.ESOMinion[tostring(k)] = v
			eso_radar.UpdateFilters()
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