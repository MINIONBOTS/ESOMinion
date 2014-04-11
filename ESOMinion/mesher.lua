-- Map & Meshmanager
mm = { }
mm.navmeshfilepath = GetStartupPath() .. [[\Navigation\]];
mm.mainwindow = { name = GetString("meshManager"), x = 350, y = 100, w = 275, h = 400}
mm.meshfiles = {}
mm.visible = false
mm.lasttick = 0
mm.mapID = 0
mm.lastSaveTime = 0
mm.reloadMeshPending = false
mm.reloadMeshTmr = 0
mm.reloadMeshName = ""
mm.OMC = 0

function mm.ModuleInit()

	if (Settings.ESOMinion.DefaultMaps == nil) then
		Settings.ESOMinion.DefaultMaps = {
		
		}
	end
	
	if (Settings.ESOMinion.gnewmeshname == nil) then
		Settings.ESOMinion.gnewmeshname = ""
	end
	
	local wnd = GUI_GetWindowInfo("MinionBot")
	GUI_NewWindow(mm.mainwindow.name,wnd.x+wnd.width,wnd.y,mm.mainwindow.w,mm.mainwindow.h,"",true)
	GUI_NewComboBox(mm.mainwindow.name,GetString("navmesh"),"gmeshname",GetString("generalSettings"),"")
	GUI_NewCheckbox(mm.mainwindow.name,GetString("showrealMesh"),"gShowRealMesh",GetString("generalSettings"))
	GUI_NewCheckbox(mm.mainwindow.name,GetString("showPath"),"gShowPath",GetString("generalSettings"))
	GUI_UnFoldGroup(mm.mainwindow.name,GetString("generalSettings"))
	
	--Grab all meshfiles in our Navigation directory
	local meshlist = "none"
	local mapid = Player.localmapid
	local meshfilelist = dirlist(mm.navmeshfilepath,".*obj")
	if ( TableSize(meshfilelist) > 0) then
		local i,meshname = next ( meshfilelist)
		while i and meshname do
			meshname = string.gsub(meshname, ".obj", "")
			table.insert(mm.meshfiles, meshname)
			meshlist = meshlist..","..meshname
			i,meshname = next ( meshfilelist,i)
		end
	end		

	GUI_NewCheckbox(mm.mainwindow.name,GetString("showMesh"),"gShowMesh",GetString("editor"))
	GUI_NewField(mm.mainwindow.name,GetString("newMeshName"),"gnewmeshname",GetString("editor"))
	GUI_NewButton(mm.mainwindow.name,GetString("newMesh"),"newMeshEvent",GetString("editor"))
	RegisterEventHandler("newMeshEvent",mm.ClearNavMesh)
	GUI_NewCheckbox(mm.mainwindow.name,GetString("recmesh"),"gMeshrec",GetString("editor"))
	GUI_NewComboBox(mm.mainwindow.name,GetString("recAreaType"),"gRecAreaType",GetString("editor"),"Road,Lowdanger,Highdanger")-- enum 1,2,3
	GUI_NewNumeric(mm.mainwindow.name,GetString("recAreaSize"),"gRecAreaSize",GetString("editor"),"1","500")
	GUI_NewCheckbox(mm.mainwindow.name,GetString("changeMesh"),"gMeshChange",GetString("editor"))
	GUI_NewComboBox(mm.mainwindow.name,GetString("changeAreaType"),"gChangeAreaType",GetString("editor"),"Delete,Road,Lowdanger,Highdanger")
	GUI_NewNumeric(mm.mainwindow.name,GetString("changeAreaSize"),"gChangeAreaSize",GetString("editor"),"1","10")
	GUI_NewButton(mm.mainwindow.name,GetString("addOffMeshSpot"),"offMeshSpotEvent",GetString("editor"))
	RegisterEventHandler("offMeshSpotEvent", mm.AddOMC)
	GUI_NewButton(mm.mainwindow.name,GetString("delOffMeshSpot"),"deleteoffMeshEvent",GetString("editor"))
	RegisterEventHandler("deleteoffMeshEvent", mm.DeleteOMC)
	GUI_NewCheckbox(mm.mainwindow.name,GetString("biDirOffMesh"),"gBiDirOffMesh",GetString("editor"))
	GUI_NewButton(mm.mainwindow.name,"CreateSingleCell","createSingleCell",GetString("editor"))
	RegisterEventHandler("createSingleCell", mm.CreateSingleCell)
	
	
	gShowMesh = "0"
	gShowRealMesh = "0"
	gShowPath = "0"
	gMeshrec = "0"
	gRecAreaType = "Lowdanger"
	gRecAreaSize = "20"
	gMeshChange = "0"
	gChangeAreaType = "Road"
	gChangeAreaSize = "5"
	gBiDirOffMesh = "0"
		
	MeshManager:SetRecordingArea(2)
	MeshManager:RecSize(gRecAreaSize)
	MeshManager:SetChangeToArea(1)
	MeshManager:SetChangeToRadius(gChangeAreaSize)
	MeshManager:SetChangeAreaMode(false)
	MeshManager:Record(false)
	
	GUI_NewButton(mm.mainwindow.name,GetString("saveMesh"),"saveMeshEvent",GetString("editor"))
	RegisterEventHandler("saveMeshEvent",mm.SaveMesh)   
		
	

	gmeshname_listitems = meshlist
	gnewmeshname = ""
	
	
	--GUI_NewButton(mm.mainwindow.name,"ChangeMeshRenderDepth","mm.ChangeMDepth")
	--RegisterEventHandler("mm.ChangeMDepth",mm.ChangeMDepth) 
		
	GUI_SizeWindow(mm.mainwindow.name,mm.mainwindow.w,mm.mainwindow.h)
	GUI_WindowVisible(mm.mainwindow.name,false)
	
	-- load default mesh if available
	if ( Settings.ESOMinion.DefaultMaps[tonumber(mapid)] ) then
		mm.ChangeNavMesh(Settings.ESOMinion.DefaultMaps[tonumber(mapid)])
	end
end

---------
--Mesh
---------

function mm.ClearNavMesh()
	-- Unload old Mesh
	if ( gnewmeshname ~= nil and gnewmeshname ~= "" ) then
		if (NavigationManager:GetNavMeshName() ~= "") then
			d("Unloading ".. NavigationManager:GetNavMeshName() .." NavMesh.")
		end
		d("Result: "..tostring(NavigationManager:UnloadNavMesh()))
	else
		ml_error("Please enter a NEW navmesh-filename first!")
	end
end

function mm.SaveMesh()
	if (eso_global.now- mm.lastSaveTime > 5000) then
		mm.lastSaveTime = eso_global.now
		d("Saving NavMesh...")	
		gMeshrec = "0"
		gMeshChange = "0"
		MeshManager:Record(false)
		MeshManager:SetChangeAreaMode(false)
				
		local filename = ""
		-- If a new Meshname is given, create a new file and save it in there
		if ( gnewmeshname ~= nil and gnewmeshname ~= "" ) then
			-- Make sure file doesnt exist
			local found = false
			local meshfilelist = dirlist(mm.navmeshfilepath,".*obj")
			if ( TableSize(meshfilelist) > 0) then
				local i,meshname = next ( meshfilelist)
				while i and meshname do
					meshname = string.gsub(meshname, ".obj", "")
					if (meshname == gnewmeshname) then
						d("Mesh with that Name exists already...")
						found = true
						break
					end
					i,meshname = next ( meshfilelist,i)
				end
			end
			if ( not found) then
				-- add new file to list
				gmeshname_listitems = gmeshname_listitems..","..gnewmeshname
			end
			filename = gnewmeshname
			
		-- Else we save it under the selected name
		elseif (gmeshname ~= nil and gmeshname ~= "" and gmeshname ~= "none") then
			filename = gmeshname
		end	
		if ( filename ~= "" and filename ~= "none" ) then
			d("SAVING UNDER: "..tostring(filename))
			d("Result: "..tostring(NavigationManager:SaveNavMesh(filename)))
			mm.reloadMeshPending = true
			mm.reloadMeshTmr = mm.lasttick
			mm.reloadMeshName = filename
			gnewmeshname = ""
			gmeshname = filename
		else
			ml_error("Enter a proper Navmesh name!")
		end
	end
end


function mm.ChangeNavMesh(newmesh)
	-- Set the new mesh for the local map
	if ( NavigationManager:GetNavMeshName() ~= newmesh and NavigationManager:GetNavMeshName() ~= "") then
		d("Unloading current Navmesh: "..tostring(NavigationManager:UnloadNavMesh()))

		mm.reloadMeshPending = true
		mm.reloadMeshTmr = mm.lasttick
		mm.reloadMeshName = newmesh
		return
	else
		-- Load the mesh for our Map
		if (newmesh ~= nil and newmesh ~= "" and newmesh ~= "none") then
			d("Loading Navmesh " ..newmesh)
			if (not NavigationManager:LoadNavMesh(mm.navmeshfilepath..newmesh)) then
				d("Error loading Navmesh: "..path)
			else
				mm.reloadMeshPending = false
				local mapid = Player.localmapid
				if ( mapid ~= nil and mapid~=0 ) then
					d("Setting default Mesh for this Zone..(ID :"..tostring(mapid).." Meshname: "..newmesh)
					Settings.ESOMinion.DefaultMaps[mapid] = newmesh
					mm.mapID = mapid
				end
			end
		end
	end
	gmeshname = newmesh
	Settings.ESOMinion.gmeshname = newmesh
end


function mm.ToggleMenu()
	if (mm.visible) then
		GUI_WindowVisible(mm.mainwindow.name,false)
		mm.visible = false
	else
		local wnd = GUI_GetWindowInfo("MinionBot")
		GUI_MoveWindow( mm.mainwindow.name, wnd.x+wnd.width,wnd.y) 
		GUI_WindowVisible(mm.mainwindow.name,true)
		mm.visible = true
	end
end


function mm.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gmeshname") then
			mm.ChangeNavMesh(v)
		elseif( k == "gShowRealMesh") then
			if (v == "1") then
				NavigationManager:ShowNavMesh(true)
			else
				NavigationManager:ShowNavMesh(false)
			end
		elseif( k == "gShowPath") then
			if (v == "1") then
				NavigationManager:ShowNavPath(true)
			else
				NavigationManager:ShowNavPath(false)
			end			
		elseif( k == "gShowMesh") then
			if (v == "1") then
				MeshManager:ShowTriMesh(true)
			else
				MeshManager:ShowTriMesh(false)
			end				
		elseif( k == "gMeshrec") then
			if (v == "1") then
				MeshManager:Record(true)
			else
				MeshManager:Record(false)
			end
		elseif( k == "gRecAreaType") then
			if (v == "Road") then
				MeshManager:SetRecordingArea(1)
			elseif (v == "Lowdanger") then
				MeshManager:SetRecordingArea(2)
			elseif (v == "Highdanger") then
				MeshManager:SetRecordingArea(3)
			end
		elseif( k == "gRecAreaSize") then
			MeshManager:RecSize(tonumber(gRecAreaSize))
		elseif( k == "gMeshChange") then
			if (v == "1") then
				MeshManager:SetChangeAreaMode(true)
			else
				MeshManager:SetChangeAreaMode(false)
			end
		elseif( k == "gChangeAreaType") then
			if (v == "Road") then
				MeshManager:SetChangeToArea(1)
			elseif (v == "Lowdanger") then
				MeshManager:SetChangeToArea(2)
			elseif (v == "Highdanger") then
				MeshManager:SetChangeToArea(3)
			elseif (v == "Delete") then	
				MeshManager:SetChangeToArea(255)
			end
		elseif( k == "gChangeAreaSize") then
			MeshManager:SetChangeToRadius(tonumber(gChangeAreaSize))
		elseif( k == "gnewmeshname" ) then
			Settings.ESOMinion[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(mm.mainwindow.name)
end

function mm.OnUpdate( tickcount )
	if ( tickcount - mm.lasttick > 250 ) then
		mm.lasttick = tickcount
		
		if ( gMeshrec == "1") then
			-- 162 = Left CTRL + Left Mouse
			if ( MeshManager:IsKeyPressed(162) and MeshManager:IsKeyPressed(1)) then --162 is the integervalue of the virtualkeycode (hex)
				MeshManager:RecForce(true)
			else
				MeshManager:RecForce(false)
			end
			
			-- 162 = Left CTRL 
			if ( MeshManager:IsKeyPressed(162) ) then --162 is the integervalue of the virtualkeycode (hex)
				MeshManager:RecSteeper(true)
			else
				MeshManager:RecSteeper(false)
			end
			
			-- 160 = Left Shift
			if ( MeshManager:IsKeyPressed(160) ) then
				MeshManager:RecSize(2*tonumber(gRecAreaSize))
			else
				MeshManager:RecSize(tonumber(gRecAreaSize))
			end		 
		end
		
		
		--18 + 2 = ALT + right mouse button to Delete Triangles under mouse
			if ( MeshManager:IsKeyPressed(18) and MeshManager:IsKeyPressed(2)) then
				local mousepos = MeshManager:GetMousePos()
				d("Deleting cell "..tostring(mousepos.x).." "..tostring(mousepos.z).. " "..tostring(mousepos.y))
				if ( TableSize(mousepos) > 0 ) then
					d("Deleting cell result: "..tostring(MeshManager:DeleteRasterTriangle(mousepos)))
				end
			end	
			
		--(re-)Loading Navmesh
		if (mm.reloadMeshPending and mm.lasttick - mm.reloadMeshTmr > 2000 and mm.reloadMeshName ~= "") then
			mm.reloadMeshTmr = mm.lasttick
			mm.ChangeNavMesh(mm.reloadMeshName)
		end
		
		-- Check if we switched maps
		local mapid = Player.localmapid
		if ( not mm.reloadMeshPending and mapid ~= nil and mm.mapID ~= mapid ) then
			if (Settings.ESOMinion.DefaultMaps[mapid] ~= nil and (Settings.ESOMinion.DefaultMaps[mapid] ~= "none")) then
				d("Autoloading Navmesh for this Zone: "..Settings.ESOMinion.DefaultMaps[mapid])
				mm.reloadMeshPending = true
				mm.reloadMeshTmr = mm.lasttick
				mm.reloadMeshName = Settings.ESOMinion.DefaultMaps[mapid]
			end
		end
	end
end

-- Gets called when a navmesh is done loading/building
function mm.NavMeshUpdate()
	d("New Mesh loaded..")
		
	--[[ try loading questprofile
	if ( gBotMode == GetString("grindMode") or gBotMode == GetString("exploreMode")) then
		local mapname = mc_datamanager.GetMapName( Player.localmapid)
		if ( mapname ~= nil and mapname ~= "" and mapname ~= "none" ) then
			mapname = mapname:gsub('%W','') -- only alphanumeric
			if ( mapname ~= nil and mapname ~= "" ) then
				gQMprofile = mapname
				ml_quest_mgr.UpdateCurrentProfileData()
			end
		end
	end]]
	
	if ( TableSize(ml_quest_mgr.QuestList) == 0 and (gBotMode == GetString("grindMode") or gBotMode == GetString("exploreMode"))) then
		--mc_questmanager.GenerateMapExploreProfile()
	end
	
	eso_global.ResetBot()
	if ( Maprotation_Active == "1") then
		ml_task_hub:ClearQueues()
	end
	eso_global.UpdateMode()	
end

-- add offmesh connection
function mm.AddOMC()
	local pos = Player.pos
	
	mm.OMC = mm.OMC+1
	if (mm.OMC == 1 ) then
		mm.OMCP1 = pos
		mm.OMCP1.y = mm.OMCP1.y
	elseif (mm.OMC == 2 ) then
		mm.OMCP2 = pos
		mm.OMCP2.y = mm.OMCP2.y
		if ( gBiDirOffMesh == "0" ) then
			d(MeshManager:AddOffMeshConnection(mm.OMCP1,mm.OMCP2,false))
		else
			d(MeshManager:AddOffMeshConnection(mm.OMCP1,mm.OMCP2,true))
		end
		mm.OMC = 0
	end	
end
-- delete offmesh connection
function mm.DeleteOMC()
	local pos = Player.pos
	MeshManager:DeleteOffMeshConnection(pos)
	mm.OMC = 0
end

function mm.CreateSingleCell()
	d("Creating a single cell outside the raster!")
	local pPos = Player.pos
	local newVertexCenter = { x=pPos.x, y=pPos.y, z=pPos.z }
	d(MeshManager:CreateSingleCell( newVertexCenter))
end

function mm.ChangeMDepth()
	d(RenderManager:ChangeMeshDepth())
end

RegisterEventHandler("ToggleMeshmgr", mm.ToggleMenu)
RegisterEventHandler("GUI.Update",mm.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",mm.ModuleInit)
RegisterEventHandler("Gameloop.NavmeshLoaded",mm.NavMeshUpdate)


