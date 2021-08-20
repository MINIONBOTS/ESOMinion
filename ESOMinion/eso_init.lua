dev = {}
ml_global_information.MainWindow = { Name="MinionBot", x=50, y=50, width=220, height=350 }
ml_global_information.advwindow = { Name="AdvandedSettings", x=250, y=200 , width=200, height=170 }
ml_global_information.login = { Name="AutoLogin", x=100, y=100 , width=230, height=140 }
ml_global_information.characterselect = { Name="CharacterSelect", x=100, y=100 , width=250, height=150 }
ml_global_information.drawMode = 1
ml_global_information.AttackRange = 5
ml_global_information.Now = 0
ml_global_information.yield = {}
ml_global_information.nextRun = 0
ml_global_information.BotModes = {}
ml_global_information.lastWeaponCheck = 0
ml_global_information.idlePulseCount = 0
function ml_global_information.Init()
	-- Update default meshes.
	do
		BehaviorManager:ToggleMenu()
		ml_mesh_mgr.averagegameunitsize = 1
		ml_mesh_mgr.useQuaternion = false
		
		-- default meshes
		--ml_mesh_mgr.SetDefaultMesh(130, "Ul'dah - Steps of Nald", enforce)
	   
	end
  
    do
		-- setup marker manager callbacks and vars
		ml_marker_mgr.GetPosition = 	function () return Player.pos end
		ml_marker_mgr.GetLevel = 		function () return Player.level end
		ml_marker_mgr.DrawMarker =		ml_global_information.DrawMarker
		ml_node.ValidNeighbors = 		ml_global_information.NodeNeighbors
		ml_node.GetClosestNeighborPos = ml_global_information.NodeClosestNeighbor
		
		-- setup meshmanager
		if ( ml_mesh_mgr ) then
			--ml_mesh_mgr.parentWindow.Name = ml_global_information.MainWindow.Name
			ml_mesh_mgr.GetMapID = function () return Player.mapid end
			ml_mesh_mgr.GetMapName = function (mapid)
			local mapid = IsNull(mapid,Player.mapid)
			return GetMapName(mapid) 
			end
			ml_mesh_mgr.GetPlayerPos = function () return Player.pos end
		  
		  
			ml_global_information.meshTranslations = {}
			local defaultMaps = Settings.minionlib.DefaultMaps
			if (table.valid(defaultMaps)) then
				for mapid,meshname in pairs(defaultMaps) do
					ml_global_information.meshTranslations[meshname] = GetMapName(mapid)
				end
			end
		  
			ml_mesh_mgr.GetString = function (meshname)
			local returnstring = meshname
			if (ml_global_information.meshTranslations[meshname]) then
			  returnstring = returnstring.." - ["..ml_global_information.meshTranslations[meshname].."]"
			end
			return returnstring
			end
			
			ml_mesh_mgr.GetFileName = function (inputString) 
				if (ValidString(inputString)) then
				  if (string.contains(inputString,'%s%-%s%[.+%]')) then
					inputString = string.gsub(inputString,'%s%-%s%[.+%]',"")
				  end
				end
				return inputString 
			end
		end
	end
	
	local eso_mainmenu = {
		header = { id = "ESOMINION##MENU_HEADER", expanded = false, name = "ESOMinion", texture = GetStartupPath().."\\GUI\\UI_Textures\\ffxiv_shiny.png"},
		members = {	
			--{ id = "ESOMINION##MENU_MAINMENU", name = "Windows", sort = true },
			{ id = "ESOMINION##MENU_MAINMENU", name = "Main Task", onClick = function() esominion.GUI.main.open = true end, tooltip = "Open the Main Task window." },
			{ id = "ESOMINION##MENU_DEV", name = "Dev Tools", onClick = function() Dev.GUI.open = not Dev.GUI.open end, tooltip = "Open the Developer tools." },
		}
	}
	ml_gui.ui_mgr:AddComponent(eso_mainmenu)
end



RegisterEventHandler("Module.Initalize",ml_global_information.Init, "ml_global_information.Init")