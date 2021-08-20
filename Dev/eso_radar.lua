--[[
	PoTD Traps/Hoards will only show with a pomander active since SE patched them. 
	To add to the Custom list use the contentid this can be found using the dev window or from another source like xivdb.
	You can also get this info automaticly using the Get target option.
	If you have any important/helpful contentid's please let me know so I can add it into the preset list :D
	Made by HusbandoMax
]]--
eso_radar = {}
eso_radar.GUI = {
	open = false,
	visible = true,
}
-- Check and load Custom List + Preset data.
local ColourAlpha = 0.8 -- Alpha value for transparent colours.
local lastupdate = 0
local RadarTable = {}
-- Colour Data
local Colours = {}
local CustomTransparency = {}
local CloseColourR,CloseColourG,CloseColourB = 1,0,0

local HPBarStyles = {"New", "Original"}
local MainWindowPosx, MainWindowPosy, MainWindowSizex, MainWindowSizey

eso_radar.Tabs = {
	["CurrentSelected"] = 1,
	["CurrentHovered"] = 0,
	["TabData"] = {"Filters","Custom List","Settings"},
	["SelectedColour"] = { ["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1 },
	["StandardColour"] = { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 },
	["HoveredColour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 0, ["a"] = 1 },
}

function eso_radar.Init()
	eso_radar.SetData()
	eso_radar.SetColours()
	eso_radar.Settings()
	eso_radar.UpdateColours()
	
	gRadarSettingsRadio = 1	
	gRadarGatherable = esominion.GetSetting("gRadarGatherable",false)
	gRadarGatherableColour = esominion.GetSetting("gRadarGatherableColour",{r = 0.0, g = 0.5, b = 0.0, a = 1.0, colour = 4294967295})
	gRadarHostile = esominion.GetSetting("gRadarHostile",false)
	gRadarHostileColour = esominion.GetSetting("gRadarHostileColour",{r = 1.0, g = 0.0, b = 0.0, a = 1.0, colour = 4294967295})
	gRadarAll = esominion.GetSetting("gRadarAll",false)
	gRadarAllColour = esominion.GetSetting("gRadarAllColour",{r = 1, g = 1, b = 1, a = 1, colour = 4294967295})
	gRadarSkyshards = esominion.GetSetting("gRadarSkyshards",false)
	gRadarSkyshardsColour = esominion.GetSetting("gRadarSkyshardsColour",{r = 0.0, g = 1.0, b = 1.0, a = 1.0, colour = 4294967040})
	gRadarTroves = esominion.GetSetting("gRadarTroves",false)
	gRadarTrovesColour = esominion.GetSetting("gRadarTrovesColour",{r = 1.0, g = 0.8, b = 0.0, a = 1.0, colour = 4278242559})
	gRadarFish = esominion.GetSetting("gRadarFish",false)
	gRadarFishColour = esominion.GetSetting("gRadarFishColour",{r = 0.8, g = 0.8, b = 0.8, a = 1.0, colour = 4291611852})
	gRadarDragonfly = esominion.GetSetting("gRadarDragonfly",false)
	gRadarDragonflyColour = esominion.GetSetting("gRadarDragonflyColour",{r = 0.5, g = 0.0, b = 0.5, a = 1.0, colour = 4286578816})
	gRadarButterfly = esominion.GetSetting("gRadarButterfly",false)
	gRadarButterflyColour = esominion.GetSetting("gRadarButterflyColour",{ r = 1.0, g = 0.4, b = 0.7, a = 1.0, colour = 4289947391})
	gRadarFletcherfly = esominion.GetSetting("gRadarFletcherfly",false)
	gRadarFletcherflyColour = esominion.GetSetting("gRadarFletcherflyColour",{r = 0.5, g = 0.0, b = 0.5, a = 1.0, colour = 4286578816})
	
	gRadarFixtures = esominion.GetSetting("gRadarFixtures",false)
	gRadarFixturesColour = esominion.GetSetting("gRadarFixturesColour",{r = 0.8, g = 0.8, b = 0.8, a = 1, colour = 4291611852})
	
end

function eso_radar.DrawCall(event, ticks )
	if not(GUI_NewWindow) then
		local gamestate = GetGameState()
		if ( gamestate == ESO.GAMESTATE.INGAME ) then 
			if ( eso_radar.GUI.open  ) then 
				GUI:SetNextWindowSize(500,340,GUI.SetCond_FirstUseEver) --SetCond_FirstUseEver
				eso_radar.GUI.visible, eso_radar.GUI.open = GUI:Begin("ESO Radar", eso_radar.GUI.open)
				if ( eso_radar.GUI.visible ) then
					MainWindowPosx, MainWindowPosy = GUI:GetWindowPos()
					MainWindowSizex, MainWindowSizey = GUI:GetWindowSize()
					
					GUI:Columns(2,"Main Tab") GUI:SetColumnOffset(1, MainWindowSizex/2)
					GUI:AlignFirstTextHeightToWidgets() GUI:Text("Show 3D Radar:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 3D radar." ) end
					GUI:SameLine()
					eso_radar.Enable3D, changed  = GUI:Checkbox("##Enable3D", eso_radar.Enable3D) if (changed) then Settings.eso_radar.Enable3D = eso_radar.Enable3D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 3D radar." ) end
					GUI:NextColumn()
					GUI:AlignFirstTextHeightToWidgets() GUI:Text("Show 2D Radar:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 2D radar." ) end
					GUI:SameLine()
					eso_radar.Enable2D, changed  = GUI:Checkbox("##Enable2D", eso_radar.Enable2D) if (changed) then Settings.eso_radar.Enable2D = eso_radar.Enable2D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 2D radar." ) end
					GUI:Columns()
					GUI:Separator()
					
					GUI:RadioButton(GetString("General"),gRadarSettingsRadio,1)
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(0)) then
							gRadarSettingsRadio = 1
						end
					end
					GUI:SameLine()GUI:Text("|") GUI:SameLine()
					GUI:RadioButton(GetString("Custom"),gRadarSettingsRadio,2)
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(0)) then
							gRadarSettingsRadio = 2
						end
					end
					GUI:SameLine()GUI:Text("|") GUI:SameLine()
					GUI:RadioButton(GetString("Settings"),gRadarSettingsRadio,3)
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(0)) then
							gRadarSettingsRadio = 3
						end
					end
					GUI:Spacing()
					GUI:Separator();
					
						-- Tab Contents.
					if gRadarSettingsRadio == 1 then
						
						gRadarGatherable, changed = GUI:Checkbox("Gatherable##gRadarGatherable", gRadarGatherable) 
						if (changed) then
							Settings.ESOMINION["gRadarGatherable"] = gRadarGatherable
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end 
						GUI:SameLine(125)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarGatherable",gRadarGatherableColour.r,gRadarGatherableColour.g,gRadarGatherableColour.b,gRadarGatherableColour.a) 
						if (changed) then 
							gRadarGatherableColour.r = eso_radar.AddColour.Colour.r
							gRadarGatherableColour.g = eso_radar.AddColour.Colour.g
							gRadarGatherableColour.b = eso_radar.AddColour.Colour.b
							gRadarGatherableColour.a = eso_radar.AddColour.Colour.a
							gRadarGatherableColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarGatherableColour"] = gRadarGatherableColour
						end
						
						GUI:SameLine(150) GUI:Text("|") GUI:SameLine()
						gRadarHostile, changed = GUI:Checkbox("Hostile##gRadarHostile", gRadarHostile) 
						if (changed) then
							Settings.ESOMINION["gRadarHostile"] = gRadarHostile
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end 
						GUI:SameLine(275)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarHostile",gRadarHostileColour.r,gRadarHostileColour.g,gRadarHostileColour.b,gRadarHostileColour.a) 
						if (changed) then 
							gRadarHostileColour.r = eso_radar.AddColour.Colour.r
							gRadarHostileColour.g = eso_radar.AddColour.Colour.g
							gRadarHostileColour.b = eso_radar.AddColour.Colour.b
							gRadarHostileColour.a = eso_radar.AddColour.Colour.a
							gRadarHostileColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarHostileColour"] = gRadarHostileColour
						end
						GUI:SameLine(300)GUI:Text("|") GUI:SameLine()
						gRadarSkyshards, changed = GUI:Checkbox("Skyshards##gRadarSkyshards", gRadarSkyshards) 
						if (changed) then
							Settings.ESOMINION["gRadarSkyshards"] = gRadarSkyshards
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(425)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarSkyshards",gRadarSkyshardsColour.r,gRadarSkyshardsColour.g,gRadarSkyshardsColour.b,gRadarSkyshardsColour.a) 
						if (changed) then 
							gRadarSkyshardsColour.r = eso_radar.AddColour.Colour.r
							gRadarSkyshardsColour.g = eso_radar.AddColour.Colour.g
							gRadarSkyshardsColour.b = eso_radar.AddColour.Colour.b
							gRadarSkyshardsColour.a = eso_radar.AddColour.Colour.a
							gRadarSkyshardsColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarSkyshardsColour"] = gRadarSkyshardsColour
						end
						
						--GUI:SameLine()GUI:Text("|") GUI:SameLine()
						gRadarTroves, changed = GUI:Checkbox("Troves/Chests##gRadarTroves", gRadarTroves) 
						if (changed) then
							Settings.ESOMINION["gRadarTroves"] = gRadarTroves
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(125)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarTroves",gRadarTrovesColour.r,gRadarTrovesColour.g,gRadarTrovesColour.b,gRadarTrovesColour.a) 
						if (changed) then 
							gRadarTrovesColour.r = eso_radar.AddColour.Colour.r
							gRadarTrovesColour.g = eso_radar.AddColour.Colour.g
							gRadarTrovesColour.b = eso_radar.AddColour.Colour.b
							gRadarTrovesColour.a = eso_radar.AddColour.Colour.a
							gRadarTrovesColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarTrovesColour"] = gRadarTrovesColour
						end
						GUI:SameLine(150)GUI:Text("|") GUI:SameLine()
						gRadarFish, changed = GUI:Checkbox("Fishing##gRadarFish", gRadarFish) 
						if (changed) then
							Settings.ESOMINION["gRadarFish"] = gRadarFish
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(275)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarFish",gRadarFishColour.r,gRadarFishColour.g,gRadarFishColour.b,gRadarFishColour.a) 
						if (changed) then 
							gRadarFishColour.r = eso_radar.AddColour.Colour.r
							gRadarFishColour.g = eso_radar.AddColour.Colour.g
							gRadarFishColour.b = eso_radar.AddColour.Colour.b
							gRadarFishColour.a = eso_radar.AddColour.Colour.a
							gRadarFishColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarFishColour"] = gRadarFishColour
						end
						--GUI:SameLine(300)GUI:Text("|") GUI:SameLine()
						gRadarButterfly, changed = GUI:Checkbox("Butterfly##gRadarButterfly", gRadarButterfly) 
						if (changed) then
							Settings.ESOMINION["gRadarButterfly"] = gRadarButterfly
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(125)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarButterfly",gRadarButterflyColour.r,gRadarButterflyColour.g,gRadarButterflyColour.b,gRadarButterflyColour.a) 
						if (changed) then 
							gRadarButterflyColour.r = eso_radar.AddColour.Colour.r
							gRadarButterflyColour.g = eso_radar.AddColour.Colour.g
							gRadarButterflyColour.b = eso_radar.AddColour.Colour.b
							gRadarButterflyColour.a = eso_radar.AddColour.Colour.a
							gRadarButterflyColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarButterflyColour"] = gRadarButterflyColour
						end
						GUI:SameLine(150)GUI:Text("|") GUI:SameLine()
						gRadarDragonfly, changed = GUI:Checkbox("Dragonfly##gRadarDragonfly", gRadarDragonfly) 
						if (changed) then
							Settings.ESOMINION["gRadarDragonfly"] = gRadarDragonfly
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(275)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarDragonfly",gRadarDragonflyColour.r,gRadarDragonflyColour.g,gRadarDragonflyColour.b,gRadarDragonflyColour.a) 
						if (changed) then 
							gRadarDragonflyColour.r = eso_radar.AddColour.Colour.r
							gRadarDragonflyColour.g = eso_radar.AddColour.Colour.g
							gRadarDragonflyColour.b = eso_radar.AddColour.Colour.b
							gRadarDragonflyColour.a = eso_radar.AddColour.Colour.a
							gRadarDragonflyColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarDragonflyColour"] = gRadarDragonflyColour
						end
						GUI:SameLine(300)GUI:Text("|") GUI:SameLine()
						gRadarFletcherfly, changed = GUI:Checkbox("Fletcherfly##gRadarFletcherfly", gRadarFletcherfly) 
						if (changed) then
							Settings.ESOMINION["gRadarFletcherfly"] = gRadarFletcherfly
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(425)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarFletcherfly",gRadarFletcherflyColour.r,gRadarFletcherflyColour.g,gRadarFletcherflyColour.b,gRadarFletcherflyColour.a) 
						if (changed) then 
							gRadarFletcherflyColour.r = eso_radar.AddColour.Colour.r
							gRadarFletcherflyColour.g = eso_radar.AddColour.Colour.g
							gRadarFletcherflyColour.b = eso_radar.AddColour.Colour.b
							gRadarFletcherflyColour.a = eso_radar.AddColour.Colour.a
							gRadarFletcherflyColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarFletcherflyColour"] = gRadarFletcherflyColour
						end
						
						gRadarAll, changed = GUI:Checkbox("All##gRadarAll", gRadarAll) 
						if (changed) then
							Settings.ESOMINION["gRadarAll"] = gRadarAll
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(125)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarAll",gRadarAllColour.r,gRadarAllColour.g,gRadarAllColour.b,gRadarAllColour.a) 
						if (changed) then 
							gRadarAllColour.r = eso_radar.AddColour.Colour.r
							gRadarAllColour.g = eso_radar.AddColour.Colour.g
							gRadarAllColour.b = eso_radar.AddColour.Colour.b
							gRadarAllColour.a = eso_radar.AddColour.Colour.a
							gRadarAllColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarAllColour"] = gRadarAllColour
						end
						
						gRadarFixtures, changed = GUI:Checkbox("Fixtures##gRadarFixtures", gRadarFixtures) 
						if (changed) then
							Settings.ESOMINION["gRadarFixtures"] = gRadarFixtures
							Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {}
						end
						GUI:SameLine(125)
						GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
						eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColourgRadarFixtures",gRadarFixturesColour.r,gRadarFixturesColour.g,gRadarFixturesColour.b,gRadarFixturesColour.a) 
						if (changed) then 
							gRadarFixturesColour.r = eso_radar.AddColour.Colour.r
							gRadarFixturesColour.g = eso_radar.AddColour.Colour.g
							gRadarFixturesColour.b = eso_radar.AddColour.Colour.b
							gRadarFixturesColour.a = eso_radar.AddColour.Colour.a
							gRadarFixturesColour.colour = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							Settings.ESOMINION["gRadarFixturesColour"] = gRadarFixturesColour
						end
						
					elseif gRadarSettingsRadio == 2 then -- Custom List Tab.
							-- Add to custom list.
							-- Column names.
							GUI:Columns(5) GUI:SetColumnOffset(1, 100) GUI:SetColumnOffset(2, 160) GUI:SetColumnOffset(3, MainWindowSizex-185) GUI:SetColumnOffset(4, MainWindowSizex-100) 	GUI:Text("contentid") GUI:NextColumn() GUI:Text("Colour") GUI:NextColumn() GUI:Text("Custom Name") GUI:NextColumn() GUI:Text("Get Target") GUI:NextColumn() GUI:Text("Add")
							GUI:NextColumn() -- Column data.
							GUI:PushItemWidth(85) eso_radar.contentid = GUI:InputText("##contentid", eso_radar.contentid) GUI:PopItemWidth() GUI:NextColumn()
							GUI:ColorEditMode(GUI.ColorEditMode_NoInputs+GUI.ColorEditMode_AlphaBar)
							eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a,changed = GUI:ColorEdit4("##AddColour",eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) 
							if (changed) then eso_radar.AddColour.ColourU32 = GUI:ColorConvertFloat4ToU32(eso_radar.AddColour.Colour.r,eso_radar.AddColour.Colour.g,eso_radar.AddColour.Colour.b,eso_radar.AddColour.Colour.a) end
							GUI:NextColumn()
							local Size = GUI:GetContentRegionAvail()
							GUI:PushItemWidth(Size) eso_radar.CustomName = GUI:InputText("##CustomName", eso_radar.CustomName) GUI:PopItemWidth() GUI:NextColumn()
							GUI:NextColumn()
							if GUI:Button("Add", 70, 20) then 
								if eso_radar.contentid ~= "" then
									eso_radar.CustomList[tonumber(eso_radar.contentid)] = { ["Name"] = eso_radar.CustomName, ["Enabled"] = true, ["Colour"] = eso_radar.AddColour.Colour, ["ColourU32"] = eso_radar.AddColour.ColourU32 }
									Settings.eso_radar.CustomList = eso_radar.CustomList
									RadarTable = {}
								end
							end
							GUI:Columns()
							-- Custom list.
							GUI:Separator() -- Column names.
							GUI:Columns(5) GUI:SetColumnOffset(1, 100) GUI:SetColumnOffset(2, 160) GUI:SetColumnOffset(3, MainWindowSizex-185) GUI:SetColumnOffset(4, MainWindowSizex-100) GUI:Text("contentid") GUI:NextColumn() GUI:Text("Colour") GUI:NextColumn() GUI:Text("Custom Name") GUI:NextColumn() GUI:Text("Enabled") GUI:NextColumn() GUI:Text("Delete") GUI:Columns()
							GUI:Separator()-- Column data.
							GUI:Columns(5) GUI:SetColumnOffset(1, 100) GUI:SetColumnOffset(2, 160) GUI:SetColumnOffset(3, MainWindowSizex-185) GUI:SetColumnOffset(4, MainWindowSizex-100)
							for i,e in pairs(eso_radar.CustomList) do
								GUI:AlignFirstTextHeightToWidgets() GUI:Text(i) GUI:NextColumn()
								-- Current colours.
								e.Colour.r,e.Colour.g,e.Colour.b,e.Colour.a,changed = GUI:ColorEdit4("##AddColour"..i,e.Colour.r,e.Colour.g,e.Colour.b,e.Colour.a) 
								if (changed) then e.ColourU32 = GUI:ColorConvertFloat4ToU32(e.Colour.r,e.Colour.g,e.Colour.b,e.Colour.a) Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {} end
								GUI:NextColumn()
								-- Set custom name.
								GUI:PushItemWidth(Size) 
								e.Name, changed = GUI:InputText("##CustomName"..i, e.Name) if (changed) then Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {} end 
								GUI:PopItemWidth() 
								GUI:NextColumn()
								-- Toggles.
								e.Enabled, changed = GUI:Checkbox("##Enabled"..i, e.Enabled) if (changed) then Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {} end 
								GUI:NextColumn()
								-- Delete entry.
								if GUI:Button("Delete##"..i, 70, 20) then eso_radar.CustomList[i] = nil Settings.eso_radar.CustomList = eso_radar.CustomList RadarTable = {} end 
								GUI:NextColumn()
							end
							GUI:Columns()
							GUI:TreePop()
						elseif gRadarSettingsRadio == 3 then -- Settings Tab
							GUI:Columns(2) GUI:SetColumnOffset(1, 250) -- Column names.
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Show HP Bars:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show HP bars on the 3D radar." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Black Behind Names:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Puts a Transparent black bar behind the names for easy reading." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - HP Bar Style:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the style of the HP Bars used on the 3D radar." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Toggle Scan Distance:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Toggle Max Distance to show on 3D radar. (Distance Set Below)" ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Scan Distance:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 3D radar. (About 120 is the max for normal entities)" ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Custom String:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Enable Custom Strings to be used on the 3D radar" ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Custom String Format:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Custom Strings formatted as below.\nName,contentid,ID,Distance,Distance2D,Type,HP" ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Show Names:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show entity names on the 2D radar." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Marker Shapes:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the shape of the markers used within the 2D radar." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Enable Click Through:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Allow clickthrough of the 2D radar.(Must be disabled to move radar)" ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Radar Scale (%%):") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Scale the size of the 2D radar." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Scan Distance:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 2D radar. (About 120 is the max for normal entities)" ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Radar Opacity:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the Opacity/Transparency of the 2D radar." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("Text Scale:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the Text Scale for the 2D and 3D radar." ) end
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("Add Presets to Custom List:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Add Presets into the Custom List, this will not overwrite existing entries." ) end
							GUI:NextColumn() -- Settings stuff.
							local Size = GUI:GetContentRegionAvail()
							eso_radar.ShowHPBars, changed = GUI:Checkbox("##ShowHPBars", eso_radar.ShowHPBars) if (changed) then Settings.eso_radar.ShowHPBars = eso_radar.ShowHPBars end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show HP bars on the 3D radar." ) end
							eso_radar.BlackBars, changed = GUI:Checkbox("##BlackBars", eso_radar.BlackBars) if (changed) then Settings.eso_radar.BlackBars = eso_radar.BlackBars end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Puts a Transparent black bar behind the names for easy reading." ) end
							GUI:PushItemWidth(Size) eso_radar.HPBarStyle, changed = GUI:Combo("##HPBarStyle", eso_radar.HPBarStyle, HPBarStyles) if (changed) then Settings.eso_radar.HPBarStyle = eso_radar.HPBarStyle end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the style of the HP Bars used on the 3D radar." ) end GUI:PopItemWidth()
							eso_radar.EnableRadarDistance3D, changed = GUI:Checkbox("##EnableRadarDistance3D", eso_radar.EnableRadarDistance3D) if (changed) then Settings.eso_radar.EnableRadarDistance3D = eso_radar.EnableRadarDistance3D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Toggle Max Distance to show on 3D radar. (Distance Set Below)" ) end
							GUI:PushItemWidth(Size) eso_radar.RadarDistance3D, changed = GUI:SliderInt("##RadarDistance3D", eso_radar.RadarDistance3D,0,300) if (changed) then Settings.eso_radar.RadarDistance3D = eso_radar.RadarDistance3D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 3D radar. (About 120 is the max for normal entities)" ) end GUI:PopItemWidth()
							eso_radar.CustomStringEnabled, changed = GUI:Checkbox("##CustomStringEnabled",eso_radar.CustomStringEnabled) if (changed) then Settings.eso_radar.CustomStringEnabled = eso_radar.CustomStringEnabled end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Enable Custom Strings to be used on the 3D radar" ) end
							GUI:PushItemWidth(Size) eso_radar.CustomString, changed = GUI:InputText("##CustomString", eso_radar.CustomString) if (changed) then Settings.eso_radar.CustomString = eso_radar.CustomString end  if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Custom Strings formatted as below.\nName,contentid,ID,Distance,Distance2D,Type,HP" ) end GUI:PopItemWidth()
							eso_radar.MiniRadarNames, changed = GUI:Checkbox("##MiniRadarNames", eso_radar.MiniRadarNames) if (changed) then Settings.eso_radar.MiniRadarNames = eso_radar.MiniRadarNames end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show entity names on the 2D radar." ) end
							eso_radar.Shape, changed = GUI:RadioButton("Circle##Shape", eso_radar.Shape,1) GUI:SameLine() if (changed) then Settings.eso_radar.Shape = eso_radar.Shape end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the shape of the markers used within the 2D radar to a Cricle." ) end
							eso_radar.Shape, changed = GUI:RadioButton("Square##Shape", eso_radar.Shape,2) if (changed) then Settings.eso_radar.Shape = eso_radar.Shape end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the shape of the markers used within the 2D radar to a Square." ) end
							eso_radar.ClickThrough, changed = GUI:Checkbox("##ClickThrough", eso_radar.ClickThrough) if (changed) then Settings.eso_radar.ClickThrough = eso_radar.ClickThrough end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Allow clickthrough of the 2D radar.(Must be disabled to move radar)" ) end
							GUI:PushItemWidth(Size) eso_radar.RadarSize, changed = GUI:SliderInt("##RadarSize", eso_radar.RadarSize,20,1000) if (changed) then Settings.eso_radar.RadarSize = eso_radar.RadarSize end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Scale the size of the 2D radar." ) end GUI:PopItemWidth()
							GUI:PushItemWidth(Size) eso_radar.RadarDistance2D, changed = GUI:SliderInt("##RadarDistance2D", eso_radar.RadarDistance2D,0,300) if (changed) then Settings.eso_radar.RadarDistance2D = eso_radar.RadarDistance2D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 2D radar. (About 120 is the max for normal entities)" ) end GUI:PopItemWidth()
							GUI:PushItemWidth(Size) eso_radar.Opacity, changed = GUI:SliderInt("##Opacity", eso_radar.Opacity,0,100) if (changed) then Settings.eso_radar.Opacity = eso_radar.Opacity eso_radar.UpdateColours() end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the Opacity/Transparency of the 2D radar." ) end GUI:PopItemWidth()
							GUI:PushItemWidth(Size) eso_radar.TextScale, changed = GUI:SliderInt("##TextScale", eso_radar.TextScale,50,250) if (changed) then Settings.eso_radar.TextScale = eso_radar.TextScale end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the Text Scale for the 2D and 3D radar." ) end GUI:PopItemWidth()
							if GUI:Button("Add Preset Data",Size,20) then eso_radar.AddPreset() end
							GUI:Columns()
						end
				end 
				GUI:End()
			end -- End of main GUI.
			
			-- Check radar toggles and form list.
			-- Overlay/Radar GUI.
			if eso_radar.Enable3D or eso_radar.Enable2D then
				eso_radar.Radar() -- Check table
			
				if eso_radar.Enable3D == true then -- 3D Overlay.
					-- GUI Data.
					local maxWidth, maxHeight = GUI:GetScreenSize()
					GUI:SetNextWindowPos(0, 0, GUI.SetCond_Always)
					GUI:SetNextWindowSize(maxWidth,maxHeight,GUI.SetCond_Always)
					local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
					GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], 0)
					flags = (GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
					GUI:Begin("eso_radar 3D Overlay", true, flags)	
					if ValidTable(RadarTable) then -- Check Radar table is valid and write to screen.
						for i,e in pairs(RadarTable) do
						local eColour = e.Colour
						local eHP = e.hp
						local eType = e.type
						local eDistance = math.huge
						if e.distance then
							eDistance = math.round(e.distance,0)
						end
						local eDistance2D = math.huge
						if e.distance then
							eDistance2D = string.format("%.1f",e.distance2d)
						end
						-- Limit render distance if enabled.
						if eso_radar.EnableRadarDistance3D and eDistance <= (eso_radar.RadarDistance3D-4) or not eso_radar.EnableRadarDistance3D then
							local Scale
							Scale = (0.9-math.round((eDistance/250),3))
							if Scale < 0.5 then Scale = (0.5*(eso_radar.TextScale/100)) else Scale = (Scale*(eso_radar.TextScale/100)) end
							GUI:SetWindowFontScale(Scale)
							local RoundedPos = { x = math.round(e.pos.x,2), y = math.round(e.pos.y,2), z = math.round(e.pos.z,2) }
							local screenPos = RenderManager:WorldToScreen(RoundedPos)
							if (table.valid(screenPos)) then
								local EntityString = ""
								if eso_radar.CustomStringEnabled then
									EntityString = ""
									StringTable = string.totable(eso_radar.CustomString,",")
									if ValidTable(StringTable) then
										for stringindex,stringval in pairs(StringTable) do
											local StringLower = string.lower(stringval)
											if StringLower == "name" then EntityString = EntityString.."["..e.name.."]"
											elseif StringLower == "distance" then EntityString = EntityString.."["..eDistance.."]"
											elseif StringLower == "id" then EntityString = EntityString.."["..e.id.."]"
											elseif StringLower == "contentid" then EntityString = EntityString.."["..e.contentid.."]"
											elseif StringLower == "distance2d" then EntityString = EntityString.."["..eDistance2D.."]"
											elseif StringLower == "type" then EntityString = EntityString.."["..eType.."]"
											elseif StringLower == "hp" then EntityString = EntityString.."["..eHP.current.."/"..eHP.max.."]"
											end
										end
									end
								else
									EntityString = "["..e.name.."] ".."["..tostring(math.round(eDistance,0)).."]"
								end
								local stringsize = (GUI:CalcTextSize(EntityString))
								local stringheight = GUI:GetWindowFontSize()+2
								-- Render GUI.
								if eso_radar.BlackBars then GUI:AddRectFilled((screenPos.x-(stringsize/2)), screenPos.y, (screenPos.x+(stringsize/2))+2, screenPos.y + stringheight, Colours.Transparent.black.colourval,3) end -- Black Behind Name.
									GUI:AddCircleFilled(screenPos.x-((stringsize)/2) - 8*Scale, screenPos.y + (stringheight/2), 5*Scale, eColour) -- Filled Point Marker (Transparent).
									GUI:AddCircle(screenPos.x-((stringsize)/2) - 8*Scale, screenPos.y + (stringheight/2), 5*Scale,eColour) -- Point Marker Outline (Solid).
									GUI:AddText(screenPos.x-((stringsize)/2), screenPos.y-1, eColour, EntityString) -- Name Text
									if (eso_radar.ShowHPBars and table.valid(eHP) and eHP.max > 0 and eHP.percent <= 100 and e.targetable and e.alive and (eType == 1 or eType == 2 or eType == 3)) then -- HP bar stuff.
										if eso_radar.HPBarStyle == 1 then
											-- Colour HP bar
											local Rectangle = {
												x1 = math.round((screenPos.x - (62*Scale)),0),
												y1 = math.round((screenPos.y + (14*Scale)+(2*Scale)),0),
												x2 = math.round((screenPos.x + (62*Scale)),0),
												y2 = math.round((screenPos.y + (30*Scale)+(2*Scale)),0),
											}
											local Rectangle2 = {
												x1 = math.round((screenPos.x - (62 * Scale)),0),
												y1 = math.round((screenPos.y + (14 * Scale)+(2*Scale)),0),
												x2 = math.round((screenPos.x + (-62 + (124 * (eHP.percent/100))) * Scale),0),
												y2 = math.round((screenPos.y + (30 * Scale)+(2*Scale)),0),
											}
											local HPBar = GUI:ColorConvertFloat4ToU32(0,1,0,0.6)
											--local HPBar = GUI:ColorConvertFloat4ToU32(math.abs((-100+eHP.percent)/100), eHP.percent/100, 0, 1) -- Different Colouring.
											if eHP.percent >= 50 then
												HPBar = GUI:ColorConvertFloat4ToU32(2-((eHP.percent/100)*2),1,0,ColourAlpha-0.2)
											else
												HPBar = GUI:ColorConvertFloat4ToU32(1,((eHP.percent*2)/100),0,ColourAlpha-0.2)
											end
											GUI:AddRectFilled(Rectangle2.x1, Rectangle2.y1, Rectangle2.x2, Rectangle2.y2, HPBar,3) -- HP Bar Coloured.
											GUI:AddRect(Rectangle.x1, Rectangle.y1, Rectangle.x2, Rectangle.y2, Colours.Transparent.white.colourval,3) -- HP Bar Outline.
											local hpsize = GUI:CalcTextSize(tostring(eHP.percent))
											GUI:AddText(screenPos.x-(hpsize/2), screenPos.y + (15*Scale)+(2*Scale), eColour, tostring(eHP.percent).."%") -- Percentage Text. eColour.colourval
										elseif eso_radar.HPBarStyle == 2 then
											-- Colour HP bar
											local Rectangle = {
												x1 = math.round((screenPos.x - (82*Scale)),0),
												y1 = math.round((screenPos.y + (17*Scale)+(2*Scale)),0),
												x2 = math.round((screenPos.x + (42*Scale)),0),
												y2 = math.round((screenPos.y + (23*Scale)+(2*Scale)),0),
											}
											local Rectangle2 = {
												x1 = math.round((screenPos.x - (82 * Scale)),0),
												y1 = math.round((screenPos.y + (17 * Scale)+(2*Scale)),0),
												x2 = math.round((screenPos.x + (-82 + (124 * (eHP.percent/100))) * Scale),0),
												y2 = math.round((screenPos.y + (23 * Scale)+(2*Scale)),0),
											}
											local HPBar = GUI:ColorConvertFloat4ToU32(0,1,0,0.6)
											--local HPBar = GUI:ColorConvertFloat4ToU32(math.abs((-100+eHP.percent)/100), eHP.percent/100, 0, 1) -- Different Colouring.
											if eHP.percent >= 50 then
												HPBar = GUI:ColorConvertFloat4ToU32(2-((eHP.percent/100)*2),1,0,ColourAlpha)
											else
												HPBar = GUI:ColorConvertFloat4ToU32(1,((eHP.percent*2)/100),0,ColourAlpha)
											end
											GUI:AddRectFilled(Rectangle2.x1, Rectangle2.y1, Rectangle2.x2, Rectangle2.y2, HPBar) -- HP Bar Coloured.
											GUI:AddRect(Rectangle.x1, Rectangle.y1, Rectangle.x2, Rectangle.y2, Colours.Transparent.white.colourval) -- HP Bar Outline.
											--if eso_radar.BlackBars then local hpsize = GUI:CalcTextSize(tostring(eHP.percent.."%%")) GUI:AddRectFilled(screenPos.x+(50*Scale), screenPos.y+(16*Scale),screenPos.x+(47*Scale)+hpsize, screenPos.y+(13*Scale)+stringheight, Colours.Transparent.black.colourval,3) end -- Black Behind Name.
											GUI:AddText(screenPos.x+(45*Scale)+2, screenPos.y+(13*Scale)+(2*Scale), eColour, tostring(eHP.percent).."%") -- Percentage Text. eColour.colourval
										end
									end
								end
							end
							GUI:SetWindowFontScale(1)
						end
					end
					GUI:End()
					GUI:PopStyleColor()
				end -- End of 3D radar GUI.
				-- 2D Radar.
				if eso_radar.Enable2D == true then
					-- GUI Data
					local maxWidth, maxHeight = GUI:GetScreenSize()
					GUI:SetNextWindowPos(0, 0, GUI.SetCond_FirstUseEver)
					GUI:SetNextWindowSize(200*(eso_radar.RadarSize/100)+100,200*(eso_radar.RadarSize/100)+100,GUI.SetCond_Always) -- Scalable GUI.
					local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
					GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], 0)
					if eso_radar.ClickThrough == true then -- 2D Radar Clickthrough toggle check.
						flags = (GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
					else
						flags = (GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
					end
					GUI:Begin("eso_radar 2D Overlay", true, flags)	
					-- Radar Math.
					local PlayerPOS = Player.pos
					local WindowPosx, WindowPosy = GUI:GetWindowPos()
					local WindowSizex, WindowSizey = GUI:GetWindowSize()
					WindowPosx, WindowPosy = WindowPosx+25, WindowPosy+50 -- Gives a little extra room to allow for names
					WindowSizex, WindowSizey = WindowSizex-100, WindowSizey-100
					local CenterX = WindowPosx+(WindowSizex/2)
					local CenterY = WindowPosy+(WindowSizey/2)
					local angle = ConvertHeading(PlayerPOS.h)-(1.5708) -- Weird compass rotation (90° Clockwise fix) o.O
					local headingx = (math.cos(angle)*-1) -- More weird compass shit (Anticlockwise fix)...
					local headingy = (math.sin(angle)) -- More weird compass shit...
					-- Radar Render.
					GUI:AddCircleFilled(CenterX, CenterY, ((WindowSizex/2)-4), CustomTransparency.black.colourval, 200) -- 2D Radar Fill (Transparent with slider).
					GUI:AddLine(WindowPosx+(WindowSizex/2), WindowPosy+4, WindowPosx+(WindowSizex/2), WindowPosy+WindowSizey-4, Colours.Transparent.red.colourval, 2.0) -- Y Axis Line (Transparent)
					GUI:AddLine(WindowPosx+4, WindowPosy+(WindowSizey/2), WindowPosx+WindowSizex-4, WindowPosy+(WindowSizey/2), Colours.Transparent.red.colourval, 2.0) -- X Axis Line (Transparent)
					GUI:AddCircle(CenterX, CenterY, ((WindowSizex/2)-4), Colours.Transparent.lightgrey.colourval, 200) -- 2D Radar Outline (Transparent).
					GUI:AddCircle(CenterX, CenterY, ((WindowSizex/2)-5), Colours.Transparent.lightgrey.colourval, 201) -- 2D Radar Outline (Transparent).
					local MouseX,MouseY = GUI:GetMousePos()
					--d("Mouse:"..MouseX..":"..MouseY)
					if ValidTable(RadarTable) then -- Check Radar table is valid and write to screen.
						for i,e in pairs(RadarTable) do
							local MouseOver = false
							local eColour = e.Colour
							local ePOS = e.pos
							local edistance2d = math.huge
							if e.distance2d then
								edistance2d = e.distance2d
							end
							-- Limit render distance slider.
							local EntityPosX = math.round(((ePOS.x-PlayerPOS.x)/eso_radar.RadarDistance2D)*(WindowSizex/2),0) + CenterX -- Entity X POS within GUI
							local EntityPosY = math.round(((ePOS.z-PlayerPOS.z)/eso_radar.RadarDistance2D)*(WindowSizey/2),0) + CenterY -- Entity Y POS within GUI
							if edistance2d > (eso_radar.RadarDistance2D) then 
							
							EntityPosX = (((ePOS.x-PlayerPOS.x)/edistance2d)*(WindowSizex/2)) + CenterX -- Entity X POS within GUI
							EntityPosY = (((ePOS.z-PlayerPOS.z)/edistance2d)*(WindowSizey/2)) + CenterY -- Entity Y POS within GUI
							end
							local PointCalculation = math.sqrt(math.pow(MouseX-EntityPosX,2) + math.pow(MouseY-EntityPosY,2))
							--if PointCalculation < (4*(eso_radar.TextScale/100)) then d("YESSS") end
							--d(EntityPosX..":"..EntityPosY)
							if eso_radar.Shape == 1 then
								GUI:AddCircleFilled(EntityPosX,EntityPosY, (4*(eso_radar.TextScale/100)), eColour) -- Filled Point Marker (Transparent).
								GUI:AddCircle(EntityPosX,EntityPosY, (4*(eso_radar.TextScale/100)), eColour) -- Point Marker Outline (Transparent).
								if PointCalculation <= (4*(eso_radar.TextScale/100)) then MouseOver = true end
							elseif eso_radar.Shape == 2 then
								local RectScale = math.round((4*(eso_radar.TextScale/100)),0)
								local Rectx1,Recty1,Rectx2,Recty2,Rectx3,Recty3,Rectx4,Recty4 = EntityPosX-RectScale, EntityPosY-RectScale, EntityPosX+RectScale, EntityPosY-RectScale, EntityPosX-RectScale, EntityPosY+RectScale, EntityPosX+RectScale, EntityPosY+RectScale
								local Pos1Dist,Pos2Dist,Pos3Dist,Pos4Dist = math.sqrt(math.pow(MouseX-Rectx1,2) + math.pow(MouseY-Recty1,2)), math.sqrt(math.pow(MouseX-Rectx2,2) + math.pow(MouseY-Recty2,2)), math.sqrt(math.pow(MouseX-Rectx3,2) + math.pow(MouseY-Recty3,2)), math.sqrt(math.pow(Rectx1-Rectx4,2) + math.pow(MouseY-Recty4,2))
								local RectHypot = math.sqrt(math.pow(Rectx1-Rectx4,2) + math.pow(Recty1-Recty4,2))
								GUI:AddRectFilled(EntityPosX-RectScale, EntityPosY-RectScale, EntityPosX+RectScale, EntityPosY+RectScale, eColour)
								GUI:AddRect(EntityPosX-RectScale, EntityPosY-RectScale, EntityPosX+RectScale, EntityPosY+RectScale, eColour)
								if Pos1Dist <= RectHypot and Pos2Dist <= RectHypot and Pos3Dist <= RectHypot and Pos4Dist <= RectHypot then MouseOver = true end
							end
							-- Name Toggle.
							if eso_radar.MiniRadarNames or (eso_radar.Shape and MouseOver) or (not eso_radar.Shape and MouseOver) then
								GUI:SetWindowFontScale((0.8*(eso_radar.TextScale/100)))
								GUI:AddText(EntityPosX+(8*(eso_radar.TextScale/100)), EntityPosY-(5*(eso_radar.TextScale/100)), eColour, e.name) -- Entity name (Transparent).
								GUI:SetWindowFontScale(1)
							end
						end
					end
					GUI:AddLine(CenterX, CenterY, CenterX+(headingx*((WindowSizex/2)-4)), CenterY+(headingy*((WindowSizey/2)-4)), Colours.Transparent.yellow.colourval, 2.0) -- Heading Line (Transparent)
					GUI:End()
					GUI:PopStyleColor()
				end -- End of 2D radar.
			end
		end
	end
end

function eso_radar.Radar() -- Table
	--if Now() > lastupdate + 25 then
	--lastupdate = Now()
		local EntityTable = EntityList("")
		if ValidTable(EntityTable) then
			-- Update/Clean table.
			if ValidTable(RadarTable) then
				for radarindex,radardata in pairs(RadarTable) do
					local GetEntityList = EntityList:Get(radardata.id)
					if ValidTable(GetEntityList) then -- Update Data.
						-- Fix for attackable targets not being attackable until closer range.
						if not radardata.attackable and GetEntityList.attackable then RadarTable[radarindex] = nil end 
						-- Fix for all nodes returning cangather regardless of class when first loaded. 
						if radardata.cangather ~= GetEntityList.cangather then RadarTable[radarindex] = nil end 
						-- Fix for friendly targets not being friendly until closer range.
						if not radardata.friendly and GetEntityList.friendly then RadarTable[radarindex] = nil end 
						-- Fix for names not showing on NPC's right away...
						if not radardata.CustomName and radardata.name ~= GetEntityList.name then radardata.name = GetEntityList.name end
						radardata.hp = GetEntityList.hp
						radardata.pos = GetEntityList.pos
						radardata.distance2d = GetEntityList.distance2d
						radardata.distance = GetEntityList.distance
						radardata.alive = GetEntityList.alive
					else -- Remove Old Data.
						RadarTable[radarindex] = nil
					end
				end
			end
			-- Add New Data.
			for i,e in pairs(EntityTable) do
				local ID = e.id
				if RadarTable[ID] == nil then
					local Colour = ""
					local Draw = false
					if (gRadarGatherable) and e.interacttype == 3 then
						Colour = gRadarGatherableColour.colour
						Draw = true
					end
					if (gRadarHostile) and e.hostile then
						Colour = gRadarHostileColour.colour
						Draw = true
					end
					if (gRadarSkyshards) and In(e.contentid,22637,22638,22639,22640,22641,22642,22643,28459,28465,28466,28467,28468) then
						Colour = gRadarSkyshardsColour.colour
						Draw = true
					end
					if (gRadarFish) and In(e.contentid,909,910,911,912) then
						Colour = gRadarFishColour.colour
						Draw = true
					end
					
					if (gRadarTroves) and In(e.contentid,20089,10079,10080,10081,10082,1811,18842,18846,18851,18852,18864,18870,18837) then
						Colour = gRadarTrovesColour.colour
						Draw = true
					end
					if (gRadarDragonfly) and In(e.contentid,74225,74226,74227) then
						Colour = gRadarDragonflyColour.colour
						Draw = true
					end
					if (gRadarFletcherfly) and In(e.contentid,74219) then
						Colour = gRadarFletcherflyColour.colour
						Draw = true
					end
					if (gRadarButterfly) and In(e.contentid,29849,48922,48923,48924,48925,48926) then
						Colour = gRadarButterflyColour.colour
						Draw = true
					end
					
					local CustomName = false
					local econtentid = e.contentid
					local gatherable = e.interacttype == 3
					local eattackable = e.hostile
					local efriendly = e.friendly
					local etype = e.type
					local ename
					if eso_radar.CustomList[econtentid] ~= nil and eso_radar.CustomList[econtentid].Enabled then -- Custom List
						Colour = eso_radar.CustomList[econtentid].ColourU32
						if eso_radar.CustomList[econtentid].Name ~= "" then 
							ename = eso_radar.CustomList[econtentid].Name 
						end
						Draw = true
						CustomName = true
					elseif gRadarAll and not Draw then
						Colour = gRadarAllColour.colour
						Draw = true
					end
					if Draw then -- Write to table.
						ename = ename or e.name
						local dataset = { CustomName = CustomName, id = ID, attackable = eattackable, contentid = econtentid, name = ename, pos = e.pos, worldpos = e.worldpos, distance2d = e.distance2d, distance = e.distance, alive = e.alive, hp = e.hp, ["type"] = etype, Colour = Colour, targetable = e.targetable, friendly = e.friendly, cangather = gatherable }
						RadarTable[ID] = dataset
					end
				end 
			end
		end
		
		local fixtureTable = FixtureList("maxdistance=50,isactive")
		if ValidTable(fixtureTable) then
			-- Update/Clean table.
			if ValidTable(RadarTable) then
				for radarindex,radardata in pairs(RadarTable) do
					local GetEntityList = FixtureList:Get(fixtureId)
					if ValidTable(GetEntityList) then -- Update Data.
						-- Fix for attackable targets not being attackable until closer range.
						if not radardata.attackable and GetEntityList.attackable then RadarTable[radarindex] = nil end 
						-- Fix for all nodes returning cangather regardless of class when first loaded. 
						if radardata.cangather ~= GetEntityList.cangather then RadarTable[radarindex] = nil end 
						-- Fix for friendly targets not being friendly until closer range.
						if not radardata.friendly and GetEntityList.friendly then RadarTable[radarindex] = nil end 
						-- Fix for names not showing on NPC's right away...
						if not radardata.CustomName and radardata.name ~= GetEntityList.name then radardata.name = GetEntityList.name end
						radardata.hp = GetEntityList.hp
						radardata.pos = GetEntityList.pos
						radardata.distance2d = GetEntityList.distance2d
						radardata.distance = GetEntityList.distance
						radardata.alive = GetEntityList.alive
					--else -- Remove Old Data.
					--	RadarTable[radarindex] = nil
					end
				end
			end
			-- Add New Data.
			for i,e in pairs(fixtureTable) do
				local ID = e.id
				if RadarTable[ID] == nil then
					local Colour = ""
					local Draw = false
					if (gRadarGatherable) and e.interacttype == 3 then
						Colour = gRadarGatherableColour.colour
						Draw = true
					end
					if (gRadarHostile) and e.hostile then
						Colour = gRadarHostileColour.colour
						Draw = true
					end
					if (gRadarSkyshards) and In(e.contentid,22637,22638,22639,22640,22641,22642,22643,28459,28465,28466,28467,28468) then
						Colour = gRadarSkyshardsColour.colour
						Draw = true
					end
					if (gRadarFish) and In(e.contentid,909,910,911,912) then
						Colour = gRadarFishColour.colour
						Draw = true
					end
					
					if (gRadarTroves) and In(e.contentid,20089,10079,10080,10081,1811) then
						Colour = gRadarTrovesColour.colour
						Draw = true
					end
					if (gRadarDragonfly) and In(e.contentid,74225,74226,74227) then
						Colour = gRadarDragonflyColour.colour
						Draw = true
					end
					if (gRadarFletcherfly) and In(e.contentid,74219) then
						Colour = gRadarFletcherflyColour.colour
						Draw = true
					end
					if (gRadarButterfly) and In(e.contentid,29849,48922,48923,48924,48925,48926) then
						Colour = gRadarButterflyColour.colour
						Draw = true
					end
					
					local CustomName = false
					local econtentid = e.contentid
					local gatherable = e.interacttype == 3
					local eattackable = e.hostile
					local efriendly = e.friendly
					local etype = e.type
					local ename
					if eso_radar.CustomList[econtentid] ~= nil and eso_radar.CustomList[econtentid].Enabled then -- Custom List
						Colour = eso_radar.CustomList[econtentid].ColourU32
						if eso_radar.CustomList[econtentid].Name ~= "" then 
							ename = eso_radar.CustomList[econtentid].Name 
						end
						Draw = true
						CustomName = true
					elseif gRadarFixtures and not Draw then
						Colour = gRadarFixturesColour.colour
						Draw = true
					end
					if Draw then -- Write to table.
						ename = ename or e.name
						local dataset = { CustomName = CustomName, id = ID, attackable = eattackable, contentid = econtentid, name = ename, pos = e.pos, worldpos = e.worldpos, distance2d = e.distance2d, distance = e.distance, alive = e.alive, hp = e.hp, ["type"] = etype, Colour = Colour, targetable = e.targetable, friendly = e.friendly, cangather = gatherable }
						RadarTable[ID] = dataset
					end
				end 
			end
		end
	--end
end

function eso_radar.AddPreset()
	local PresetData = {
		[62] = { ["Name"] = "Culumbine", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[97] = { ["Name"] = "Bugloss", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[478] = { ["Name"] = "Nirn Root", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[514] = { ["Name"] = "Blue Entolomap", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[515] = { ["Name"] = "Emetic Russula", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[517] = { ["Name"] = "Namira's Rot", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[518] = { ["Name"] = "White Cap", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[520] = { ["Name"] = "Imp Stool", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[521] = { ["Name"] = "Blessed Thistle", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[522] = { ["Name"] = "Lady's Smock", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[523] = { ["Name"] = "Wormwood", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[524] = { ["Name"] = "Corn Flower", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[525] = { ["Name"] = "Dragonthorn", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[526] = { ["Name"] = "Mountain Flower", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[527] = { ["Name"] = "Water Hyacinth", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[913] = { ["Name"] = "Flax", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1858] = { ["Name"] = "Jute", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1860] = { ["Name"] = "Maple Log", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1862] = { ["Name"] = "Iron Ore", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1957] = { ["Name"] = "Runestone", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2065] = { ["Name"] = "Oak Log", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2066] = { ["Name"] = "Flax", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2067] = { ["Name"] = "High Iron Ore", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2085] = { ["Name"] = "Pewter Seam", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2100] = { ["Name"] = "Pure Water", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2101] = { ["Name"] = "Water Skin", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[20089] = { ["Name"] = "Thieves Trove", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[22637] = { ["Name"] = "Skyshard", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
	}
	for i,e in pairs(PresetData) do
		if eso_radar.CustomList[i] == nil then eso_radar.CustomList[i] = e end
	end
	Settings.eso_radar.CustomList = eso_radar.CustomList
end

function eso_radar.SetColours()
	Colours = {
		Solid = {
			white = { r = 1.0, g = 1.0, b = 1.0, a = 1.0, name = white, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,0.7) },
			lightgrey = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = lightgrey, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,0.7) },
			silver = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = silver, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,0.7) },
			gray = { r = 0.5, g = 0.5, b = 0.5, a = 1.0, name = gray, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,0.7) },
			black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0, name = black, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,0.7) },
			maroon = { r = 0.5, g = 0.0, b = 0.0, a = 1.0, name = maroon, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,0.7) },
			brown = { r = 0.6, g = 0.2, b = 0.2, a = 1.0, name = brown, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,1.0), radar = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,0.7) },
			red = { r = 1.0, g = 0.0, b = 0.0, a = 1.0, name = red, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,0.7) },
			orange = { r = 1.0, g = 0.5, b = 0.0, a = 1.0, name = orange, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,0.7) },
			gold = { r = 1.0, g = 0.8, b = 0.0, a = 1.0, name = gold, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,0.7) },
			yellow = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, name = yellow, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,0.7) },
			limegreen = { r = 0.0, g = 1.0, b = 0.0, a = 1.0, name = limegreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,0.7) },
			emeraldgreen = { r = 0.0, g = 0.8, b = 0.3, a = 1.0, name = emeraldgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,0.7) },
			green = { r = 0.0, g = 0.5, b = 0.0, a = 1.0, name = green, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,0.7) },
			forestgreen = { r = 0.1, g = 0.5, b = 0.1, a = 1.0, name = forestgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,1.0), radar = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,0.7) },
			manganeseblue = { r = 0.0, g = 0.7, b = 0.6, a = 1.0, name = manganeseblue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,0.7) },
			turquoise = { r = 0.3, g = 0.9, b = 0.8, a = 1.0, name = turquoise, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,0.7) },
			cyan = { r = 0.0, g = 1.0, b = 1.0, a = 1.0, name = cyan, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,0.7) },
			blue = { r = 0.0, g = 0.0, b = 1.0, a = 1.0, name = blue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,0.7) },
			navy = { r = 0.0, g = 0.0, b = 0.5, a = 1.0, name = navy, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,0.7) },
			indigo = { r = 0.3, g = 0.0, b = 0.5, a = 1.0, name = indigo, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,0.7) },
			blueviolet = { r = 0.5, g = 0.2, b = 0.9, a = 1.0, name = blueviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,0.7) },
			darkviolet = { r = 0.6, g = 0.0, b = 0.8, a = 1.0, name = darkviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,0.7) },
			purple = { r = 0.5, g = 0.0, b = 0.5, a = 1.0, name = purple, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,0.7) },
			magenta = { r = 1.0, g = 0.0, b = 1.0, a = 1.0, name = magenta, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,0.7) },
			hotpink = { r = 1.0, g = 0.4, b = 0.7, a = 1.0, name = hotpink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,0.7) },
			pink = { r = 1.0, g = 0.8, b = 0.8, a = 1.0, name = pink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,0.7) },
		},
		Transparent = {
			white = { r = 1.0, g = 1.0, b = 1.0, a = ColourAlpha, name = white, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,ColourAlpha-0.2) },
			lightgrey = { r = 0.8, g = 0.8, b = 0.8, a = ColourAlpha, name = lightgrey, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha-0.2) },
			silver = { r = 0.8, g = 0.8, b = 0.8, a = ColourAlpha, name = silver, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha-0.2) },
			gray = { r = 0.5, g = 0.5, b = 0.5, a = ColourAlpha, name = gray, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,ColourAlpha-0.2) },
			black = { r = 0.0, g = 0.0, b = 0.0, a = ColourAlpha, name = black, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,ColourAlpha-0.2) },
			maroon = { r = 0.5, g = 0.0, b = 0.0, a = ColourAlpha, name = maroon, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,ColourAlpha-0.2) },
			brown = { r = 0.6, g = 0.2, b = 0.2, a = ColourAlpha, name = brown, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,ColourAlpha-0.2) },
			red = { r = 1.0, g = 0.0, b = 0.0, a = ColourAlpha, name = red, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,ColourAlpha-0.2) },
			orange = { r = 1.0, g = 0.5, b = 0.0, a = ColourAlpha, name = orange, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,ColourAlpha-0.2) },
			gold = { r = 1.0, g = 0.8, b = 0.0, a = ColourAlpha, name = gold, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,ColourAlpha-0.2) },
			yellow = { r = 1.0, g = 1.0, b = 0.0, a = ColourAlpha, name = yellow, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,ColourAlpha-0.2) },
			limegreen = { r = 0.0, g = 1.0, b = 0.0, a = ColourAlpha, name = limegreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,ColourAlpha-0.2) },
			emeraldgreen = { r = 0.0, g = 0.8, b = 0.3, a = ColourAlpha, name = emeraldgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,ColourAlpha-0.2) },
			green = { r = 0.0, g = 0.5, b = 0.0, a = ColourAlpha, name = green, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,ColourAlpha-0.2) },
			forestgreen = { r = 0.1, g = 0.5, b = 0.1, a = ColourAlpha, name = forestgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,ColourAlpha-0.2) },
			manganeseblue = { r = 0.0, g = 0.7, b = 0.6, a = ColourAlpha, name = manganeseblue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,ColourAlpha-0.2) },
			turquoise = { r = 0.3, g = 0.9, b = 0.8, a = ColourAlpha, name = turquoise, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,ColourAlpha-0.2) },
			cyan = { r = 0.0, g = 1.0, b = 1.0, a = ColourAlpha, name = cyan, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,ColourAlpha-0.2) },
			blue = { r = 0.0, g = 0.0, b = 1.0, a = ColourAlpha, name = blue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,ColourAlpha-0.2) },
			navy = { r = 0.0, g = 0.0, b = 0.5, a = ColourAlpha, name = navy, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,ColourAlpha-0.2) },
			indigo = { r = 0.3, g = 0.0, b = 0.5, a = ColourAlpha, name = indigo, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,ColourAlpha-0.2) },
			blueviolet = { r = 0.5, g = 0.2, b = 0.9, a = ColourAlpha, name = blueviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,ColourAlpha-0.2) },
			darkviolet = { r = 0.6, g = 0.0, b = 0.8, a = ColourAlpha, name = darkviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,ColourAlpha-0.2) },
			purple = { r = 0.5, g = 0.0, b = 0.5, a = ColourAlpha, name = purple, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,ColourAlpha-0.2) },
			magenta = { r = 1.0, g = 0.0, b = 1.0, a = ColourAlpha, name = magenta, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,ColourAlpha-0.2) },
			hotpink = { r = 1.0, g = 0.4, b = 0.7, a = ColourAlpha, name = hotpink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,ColourAlpha-0.2) },
			pink = { r = 1.0, g = 0.8, b = 0.8, a = ColourAlpha, name = pink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,ColourAlpha-0.2) },
		},
	}
end

function eso_radar.UpdateColours() -- Transparency Slider Colours (Only used on 2D Radar background atm).
	local CustomTransparencyAlpha = (tonumber(eso_radar.Opacity)/100)
	CustomTransparency = {
		white = { r = 1.0, g = 1.0, b = 1.0, a = 1.0, name = white, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,CustomTransparencyAlpha) },
		lightgrey = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = lightgrey, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,CustomTransparencyAlpha) },
		silver = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = silver, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,CustomTransparencyAlpha) },
		gray = { r = 0.5, g = 0.5, b = 0.5, a = 1.0, name = gray, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,CustomTransparencyAlpha) },
		black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0, name = black, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,CustomTransparencyAlpha) },
		maroon = { r = 0.5, g = 0.0, b = 0.0, a = 1.0, name = maroon, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,CustomTransparencyAlpha) },
		brown = { r = 0.6, g = 0.2, b = 0.2, a = 1.0, name = brown, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,CustomTransparencyAlpha) },
		red = { r = 1.0, g = 0.0, b = 0.0, a = 1.0, name = red, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,CustomTransparencyAlpha) },
		orange = { r = 1.0, g = 0.5, b = 0.0, a = 1.0, name = orange, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,CustomTransparencyAlpha) },
		gold = { r = 1.0, g = 0.8, b = 0.0, a = 1.0, name = gold, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,CustomTransparencyAlpha) },
		yellow = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, name = yellow, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,CustomTransparencyAlpha) },
		limegreen = { r = 0.0, g = 1.0, b = 0.0, a = 1.0, name = limegreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,CustomTransparencyAlpha) },
		emeraldgreen = { r = 0.0, g = 0.8, b = 0.3, a = 1.0, name = emeraldgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,CustomTransparencyAlpha) },
		green = { r = 0.0, g = 0.5, b = 0.0, a = 1.0, name = green, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,CustomTransparencyAlpha) },
		forestgreen = { r = 0.1, g = 0.5, b = 0.1, a = 1.0, name = forestgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,CustomTransparencyAlpha) },
		manganeseblue = { r = 0.0, g = 0.7, b = 0.6, a = 1.0, name = manganeseblue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,CustomTransparencyAlpha) },
		turquoise = { r = 0.3, g = 0.9, b = 0.8, a = 1.0, name = turquoise, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,CustomTransparencyAlpha) },
		cyan = { r = 0.0, g = 1.0, b = 1.0, a = 1.0, name = cyan, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,CustomTransparencyAlpha) },
		blue = { r = 0.0, g = 0.0, b = 1.0, a = 1.0, name = blue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,CustomTransparencyAlpha) },
		navy = { r = 0.0, g = 0.0, b = 0.5, a = 1.0, name = navy, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,CustomTransparencyAlpha) },
		indigo = { r = 0.3, g = 0.0, b = 0.5, a = 1.0, name = indigo, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,CustomTransparencyAlpha) },
		blueviolet = { r = 0.5, g = 0.2, b = 0.9, a = 1.0, name = blueviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,CustomTransparencyAlpha) },
		darkviolet = { r = 0.6, g = 0.0, b = 0.8, a = 1.0, name = darkviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,CustomTransparencyAlpha) },
		purple = { r = 0.5, g = 0.0, b = 0.5, a = 1.0, name = purple, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,CustomTransparencyAlpha) },
		magenta = { r = 1.0, g = 0.0, b = 1.0, a = 1.0, name = magenta, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,CustomTransparencyAlpha) },
		hotpink = { r = 1.0, g = 0.4, b = 0.7, a = 1.0, name = hotpink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,CustomTransparencyAlpha) },
		pink = { r = 1.0, g = 0.8, b = 0.8, a = 1.0, name = pink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,CustomTransparencyAlpha) },
	}
end

function eso_radar.Settings()
	AddColour = Colours.Solid.white
	-- Radar Settings.
	if Settings.eso_radar.ShowHPBars == nil then Settings.eso_radar.ShowHPBars = true end
	eso_radar.ShowHPBars = Settings.eso_radar.ShowHPBars
	if Settings.eso_radar.BlackBars == nil then Settings.eso_radar.BlackBars = true end
	eso_radar.BlackBars = Settings.eso_radar.BlackBars
	eso_radar.EnableRadarDistance3D = Settings.eso_radar.EnableRadarDistance3D or false
	eso_radar.RadarDistance3D = Settings.eso_radar.RadarDistance3D or 100
	eso_radar.MiniRadarNames = Settings.eso_radar.MiniRadarNames or false
	eso_radar.Shape = Settings.eso_radar.Shape or 1
	eso_radar.ClickThrough = Settings.eso_radar.ClickThrough or false
	eso_radar.RadarSize = Settings.eso_radar.RadarSize or 100
	eso_radar.RadarDistance2D = Settings.eso_radar.RadarDistance2D or 100
	eso_radar.Opacity = Settings.eso_radar.Opacity or 70
	eso_radar.TextScale = Settings.eso_radar.TextScale or 100
	eso_radar.HPBarStyle = Settings.eso_radar.HPBarStyle or 1
	eso_radar.CustomStringEnabled = Settings.eso_radar.CustomStringEnabled or false
	eso_radar.CustomString = Settings.eso_radar.CustomString or "Name,Distance"
	-- General Filter Toggles.
	eso_radar.Gatherables = Settings.eso_radar.Gatherables or false
	eso_radar.All = Settings.eso_radar.All or false
	-- Radar Togglea.
	eso_radar.Enable3D = Settings.eso_radar.Enable3D or false
	eso_radar.Enable2D = Settings.eso_radar.Enable2D or false
	-- General Filter Colour Values.
	eso_radar.GatherablesColour = Settings.eso_radar.GatherablesColour or Colours.Solid.green 
	eso_radar.AllColour = Settings.eso_radar.AllColour or Colours.Solid.gray
end

function eso_radar.SetData()
	eso_radar.AddColour = { ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 }
	eso_radar.contentid = ""
	eso_radar.CustomName = ""
	eso_radar.CustomList = {
		[62] = { ["Name"] = "Culumbine", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[97] = { ["Name"] = "Bugloss", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[478] = { ["Name"] = "Nornroot", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[514] = { ["Name"] = "Blue Entolomap", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[515] = { ["Name"] = "Emetic Russula", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[517] = { ["Name"] = "Namira's Rot", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[518] = { ["Name"] = "White Cap", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[520] = { ["Name"] = "Imp Stool", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[521] = { ["Name"] = "Blessed Thistle", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[522] = { ["Name"] = "Lady's Smock", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[523] = { ["Name"] = "Wormwood", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[524] = { ["Name"] = "Corn Flower", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[525] = { ["Name"] = "Dragonthorn", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[526] = { ["Name"] = "Mountain Flower", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[527] = { ["Name"] = "Water Hyacinth", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[913] = { ["Name"] = "Flax", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1858] = { ["Name"] = "Jute", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1860] = { ["Name"] = "Maple Log", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1862] = { ["Name"] = "Iron Ore", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[1957] = { ["Name"] = "Runestone", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2065] = { ["Name"] = "Oak Log", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2066] = { ["Name"] = "Flax", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2067] = { ["Name"] = "High Iron Ore", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2085] = { ["Name"] = "Pewter Seam", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2100] = { ["Name"] = "Pure Water", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[2101] = { ["Name"] = "Water Skin", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[20089] = { ["Name"] = "Thieves Trove", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
		[22637] = { ["Name"] = "Skyshard", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
	}
	-- New Options List
	eso_radar.Options = {
		[1] = {
			["CategoryName"] = "General",
			[1] = { ["Name"] = "Gatherables", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 },
			[2] = { ["Name"] = "All", ["Enabled"] = false, ["Colour"] = { ["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1 }, ["ColourU32"] = 4294967295 }
		},
	}
	if Settings.eso_radar.Options == nil then 
		Settings.eso_radar.Options = eso_radar.Options 
	else
		for i,e in pairs(eso_radar.Options) do
			if Settings.eso_radar.Options[i] == nil then
				Settings.eso_radar.Options[i] = e
				d("[Radar] - Settings Missing Group, Adding...")
			else
				for k,v in pairs(e) do
					if Settings.eso_radar.Options[i][k] == nil then
						Settings.eso_radar.Options[i][k] = v
						d("[Radar] - Settings Missing Data, Adding...")
					end
				end
			end
		end
	end
	eso_radar.Options = Settings.eso_radar.Options
	if Settings.eso_radar.CustomList == nil then Settings.eso_radar.CustomList = eso_radar.CustomList end
	-- Import Old RadarList
	if table.valid(Settings.eso_radar.RadarList) == true then
		d("[Radar] - Importing Old Custom Radar List...")
		for i,e in pairs(Settings.eso_radar.RadarList) do
			local CurrentData = table.deepcopy(e)
			Settings.eso_radar.CustomList[i] = { ["Name"] = e.CustomName, ["Enabled"] = e.Enabled, ["Colour"] = { ["r"] = e.Colour.r, ["g"] = e.Colour.g, ["b"] = e.Colour.b, ["a"] = e.Colour.a }, ["ColourU32"] = e.Colour.colourval }
		end
		Settings.eso_radar.CustomList = Settings.eso_radar.CustomList
		Settings.eso_radar.RadarList = {}
	end
	eso_radar.CustomList = Settings.eso_radar.CustomList
end

function eso_radar.ToggleMenu()
	eso_radar.GUI.open = not eso_radar.GUI.open
end

-- Register Event Handlers
RegisterEventHandler("Module.Initalize",eso_radar.Init,"eso_radar.Init")
RegisterEventHandler("Gameloop.Draw", eso_radar.DrawCall,"eso_radar.DrawCall")
RegisterEventHandler("Radar.toggle", eso_radar.ToggleMenu,"eso_radar.ToggleMenu")