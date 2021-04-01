esominion = {}

function esominion.Init()
	-- Register Button 
	local esomainmenu = {
		header = { id = "ESOMINION##MENU_HEADER", expanded = false, name = "ESOMinion", texture = GetStartupPath().."\\GUI\\UI_Textures\\eso.png"},
		members = {{ id = "ESOMINION##MENU_ADDONS", name = "Addons", tooltip = "Installed Lua Addons.", texture = GetStartupPath().."\\GUI\\UI_Textures\\addon.png"}	}
	} 
	ml_gui.ui_mgr:AddComponent(esomainmenu)
	if(BehaviorManager:IsOpen()) then BehaviorManager:ToggleMenu() end
end

RegisterEventHandler("Module.Initalize",esominion.Init, "esominion.Init")