eso_gather_manager = {}
eso_gather_manager.profilepath = GetStartupPath() .. [[\LuaMods\ESOMinion\SharedProfiles\]]
eso_gather_manager.window = { name = GetString("gatherManager"), coords = {270,50,250,550}, visible = false }
eso_gather_manager.version = 2.2
eso_gather_manager.profile = {}

function eso_gather_manager:LoadProfile()
	eso_gather_manager.profile, err = persistence.load(eso_gather_manager.profilepath .. "gather.profile")
	
	local requiresUpdate = false
	local requiresInitialize = false
	
	if (ValidTable(eso_gather_manager.profile)) then
		local profile = eso_gather_manager.profile
		local version = tonumber(profile.version)
		
		if (not version) then
			requiresInitialize = true
		elseif (version and version ~= eso_gather_manager.version) then
			requiresUpdate = true
		end
	else
		requiresInitialize = true
	end
	
	if (requiresInitialize) then
		eso_gather_manager.profile = {}
		local profile = eso_gather_manager.profile
		profile.types = {}
		
		for typeIndex,typeName in pairs(eso_gather_manager.types) do
			profile.types[typeIndex] = true
		end
		profile.version = eso_gather_manager.version
		eso_gather_manager.SaveProfile()

		d("GatherManager : Profile Initialized") 
	elseif (requiresUpdate) then
		local profile = eso_gather_manager.profile
		if (not profile.types) then
			profile.types = {}
		end
		
		for typeIndex,typeName in pairs(eso_gather_manager.types) do
			if (profile.types[typeIndex] == nil) then
				profile.types[typeIndex] = true
			end
		end
		
		profile.version = eso_gather_manager.version
		eso_gather_manager.SaveProfile()
		
		d("GatherManager : Profile Version Updated") 
	end
	
	d("GatherManager : Profile Load Complete") 
end

function eso_gather_manager.SaveProfile()
	local err = persistence.store(eso_gather_manager.profilepath .. "gather.profile", eso_gather_manager.profile)
	if err then
		d("GatherManager : Error encountered during SaveProfile() [" .. err .. "]")
	else
		d("GatherManager : Profile Saved")
	end
end

function eso_gather_manager.ClosestNode(noplayers)
	
	local gatherlist;
	local gatherables = {}
	
	if (noplayers == true) then
		gatherlist = EntityList("onmesh,gatherable,noplayersaround=10")
	else
		gatherlist = EntityList("onmesh,gatherable")
	end
	
	if (ValidTable(gatherlist)) then
		local id,node = next(gatherlist)
		while (id and node) do
			if (eso_gather_manager.IsGatherable(node)) then
				table.insert(gatherables,node)
			end
			id,node = next(gatherlist,id)
		end
	end

	table.sort(gatherables,
		function(a,b)
			return a.pathdistance < b.pathdistance
		end
	)

	if (ValidTable(gatherables)) then
		local id,node = next(gatherables)
		if (id and node) then
			return node
		end
	end

	return nil
end

function eso_gather_manager.IsGatherable(node)
	local gathertype = eso_gather_manager.GetType(node)
	if (gathertype and eso_gather_manager.profile.types[gathertype] == false) then
		return false
	end
	
	return true
end

function eso_gather_manager.GetType(node)
	for type = 1, #eso_gather_manager.types do
		for language = 1, #eso_gather_manager.languages do
		
			for index,name in pairs(eso_gather_manager.data[type][language]) do
				if (node.name == name) then
					return type
				end
			end
		end
	end
	
	return nil
end

function eso_gather_manager.ToggleAllTypes(switch)
	local f = _G
	for k,v in pairs(f) do
		if (k:find("module = GatherManager")) then
			f[k] = (switch and "1") or "0"
		end
	end
end

function eso_gather_manager.OnGuiToggle()
	eso_gather_manager.window.visible = not eso_gather_manager.window.visible
	GUI_WindowVisible(eso_gather_manager.window.name, eso_gather_manager.window.visible)
end

function eso_gather_manager.OnGuiVarUpdate(event,data,...)
	for key,value in pairs(data) do
		if key:find("GatherManager") then
			local handler = assert(loadstring("return " .. key))()
			
			if type(handler) == "table" then
				if (eso_gather_manager.profile and eso_gather_manager.profile.types) then
					eso_gather_manager.profile.types[handler.gathertype] = (value == "1")
					eso_gather_manager.SaveProfile()
				end
			end
		end
	end
end


function eso_gather_manager.OnGuiToggle()
	eso_gather_manager.window.visible = not eso_gather_manager.window.visible
	GUI_WindowVisible(eso_gather_manager.window.name, eso_gather_manager.window.visible)
end


function eso_gather_manager.Initialize() 
	eso_gather_manager:LoadProfile()
	
	GUI_NewWindow(eso_gather_manager.window.name, unpack(eso_gather_manager.window.coords))
	GUI_NewButton(eso_gather_manager.window.name, "Select All", "GatherManagerSelectAll", GetString("generalSettings"))
	GUI_NewButton(eso_gather_manager.window.name, "De-Select All", "GatherManagerUnselectAll", GetString("generalSettings"))
	
	for index,gathertype in pairsByKeys(eso_gather_manager.types) do
		local handler = "{ module = GatherManager, gathertype = " .. tostring(index) .. " } "
		GUI_NewCheckbox(eso_gather_manager.window.name, gathertype, handler, GetString("generalSettings"))
		if (eso_gather_manager.profile.types[index]) then
			_G[handler] = (eso_gather_manager.profile.types[index] == false and "0") or "1"
		end
	end
	
	GUI_UnFoldGroup(eso_gather_manager.window.name, GetString("generalSettings"))
	GUI_WindowVisible(eso_gather_manager.window.name, eso_gather_manager.window.visible)
end

function eso_gather_manager.HandleButtons( Event, Button )	
	if ( Event == "GUI.Item" and string.find(Button,"GatherManager") ~= nil ) then
		d(Button)
		if (Button == "GatherManagerSelectAll") then
			eso_gather_manager.ToggleAllTypes(true)
		elseif (Button == "GatherManagerUnselectAll") then
			eso_gather_manager.ToggleAllTypes(false)
		end
	end
end

--:===============================================================================================================
--: register event handlers
--:===============================================================================================================  

RegisterEventHandler("eso_gather_manager.OnGuiToggle", eso_gather_manager.OnGuiToggle)
RegisterEventHandler("GUI.Update", eso_gather_manager.OnGuiVarUpdate)
RegisterEventHandler("Module.Initalize", eso_gather_manager.Initialize)
RegisterEventHandler("GUI.Item", eso_gather_manager.HandleButtons)

--:===============================================================================================================
--: data
--:===============================================================================================================

eso_gather_manager.types = {
	[1] = "Blacksmithing",
	[2] = "Clothing",
	[3] = "Woodworking",
	[4] = "Pure Water",
	[5] = "Water Skin",
	[6] = "AspectRune",
	[7] = "EssenceRune",
	[8] = "PotencyRune",
	[9] = "Blessed Thistle",
	[10] = "Entoloma",
	[11] = "Bugloss",
	[12] = "Columbine",
	[13] = "Corn Flower",
	[14] = "Dragonthorn",
	[15] = "Emetic Russula",
	[16] = "Imp Stool",
	[17] = "Lady\'s Smock",
	[18] = "Luminous Russula",
	[19] = "Mountain Flower",
	[20] = "Namira\'s Rot",
	[21] = "Nirnroot",
	[22] = "Stinkhorn",
	[23] = "Violet Copninus",
	[24] = "Water Hyacinth",
	[25] = "White Cap",
	[26] = "Wormwood",
}

eso_gather_manager.languages = {
	[1] = "en",
	[2] = "de",
	[3] = "fr",
}

eso_gather_manager.data = {
	[1] = {
		[1] = {
			"Iron Ore",
			"High Iron Ore",
			"Orichalc Ore",
			"Orichalcum Ore",
			"Dwarven Ore",
			"Ebony Ore",
			"Calcinium Ore",
			"Galatite Ore",
			"Quicksilver Ore",
			"Voidstone Ore",
		},
		[2] = {
			"Eisenerz",
			"Feineisenerz",
			"Orichalc Ore",
			"Oreichalkoserz",
			"Dwemererz",
			"Ebenerz",
			"Kalciniumerz",
			"Galatiterz",
			"Quicksilver Ore",
			"Leerensteinerz",
		},
		[3] = {
			"Minerai de Fer",
			"Minerai de Fer Noble",
			"Orichalc Ore",
			"Minerai D\'orichalque",
			"Minerai Dwemer",
			"Minerai d\'Ebonite",
			"Minerai de Calcinium",
			"Minerai de Galatite",
			"Quicksilver Ore",
			"Minerai de Pierre de Vide",
		},
	},
	[2] = {
		[1] = {
			"Cotton",
			"Ebonthread",
			"Flax",
			"Ironweed",
			"Jute",
			"Kreshweed",
			"Silverweed",
			"Spidersilk",
			"Void Bloom",
			"Silver Weed",
			"Kresh Weed",
		},
		[2] = {
			"Baumwolle",
			"Ebenseide",
			"Flachs",
			"Eisenkraut",
			"Jute",
			"Kreshweed",
			"Silverweed",
			"Spinnenseide",
			"Leere Blüte",
			"Silver Weed",
			"Kresh Weed",
		},
		[3] = {
			"Coton",
			"Fil d\'Ebonite",
			"Lin",
			"Herbe de fer",
			"Jute",
			"Kreshweed",
			"Silverweed",
			"Toile D\'araignée",
			"Tissu de Vide",
			"Silver Weed",
			"Kresh Weed",
		},
	},
	[3] = {
		[1] = {
			"Ashtree",
			"Beech",
			"Birch",
			"Hickory",
			"Mahogany",
			"Maple",
			"Nightwood",
			"Oak",
			"Yew",
		},
		[2] = {
			"Eschenholz",
			"Buche",
			"Birkenholz",
			"Hickoryholz",
			"Mahagoniholz",
			"Ahornholz",
			"Nachtholz",
			"Eiche",
			"Eibenholz",
		},
		[3] = {
			"Frêne",
			"Hêtre",
			"Bouleau",
			"Hickory",
			"Acajou",
			"Érable",
			"Bois de nuit",
			"Chêne",
			"If",
		},
	},
	[4] = {
		[1] = {
			"Pure Water",
		},
		[2] = {
			"Reines Wasser",
		},
		[3] = {
			"Eau Pure",

		},
	},
	[5] = {
		[1] = {
			"Water Skin",
		},
		[2] = {	
			"Wasserhaut",
		},
		[3] = {	
			"Outre d\'Eau",
		},
	},
	[6] = {
		[1] = {
			"Aspect Rune",
		},
		[2] = {
			"Aspektrune",
		},
		[3] = {
			"Rune d\'Aspect",
		},
	},
	[7] = {
		[1] = {
			"Essence Rune",
		},
		[2] = {
			"Essenzrune",
		},
		[3] = {
			"Rune D\'essence",
		},
	},
	[8] = {
		[1] = {
			"Potency Rune",
		},
		[2] = {
			"Machtrune",
		},
		[3] = {
			"Rune de Puissance",
		},
	},
	[9] = {
		[1] = {
			"Blessed Thistle",
		},
		[2] = {
			"Benediktenkraut",
		},
		[3] = {
			"Chardon Béni",
		},
	},
	[10] = {
		[1] = {
			"Entoloma",
		},
		[2] = {
			"Glöckling",
		},
		[3] = {
			"Entoloma",
		},
	},
	[11] = {
		[1] = {
			"Bugloss",
		},
		[2] = {
			"Wolfsauge",
		},
		[3] = {
			"Noctuelle",
		},
	},
	[12] = {
		[1] = {
			"Columbine",
		},
		[2] = {
			"Akelei",
		},
		[3] = {
			"Ancolie",
		},
	},
	[13] = {
		[1] = {
			"Corn Flower",
		},
		[2] = {
			"Kornblume",
		},
		[3] = {
			"Bleuet",
		},
	},
	[14] = {
		[1] = {
			"Dragonthorn",
		},
		[2] = {
			"Drachendorn",
		},
		[3] = {
			"Épine-de-Dragon",
		},
	},
	[15] = {
		[1] = {
			"Emetic Russula",
		},
		[2] = {
			"Brechtäubling",
		},
		[3] = {
			"Russule Emetique",
		},
	},
	[16] = {
		[1] = {
			"Imp Stool",
		},
		[2] = {
			"Koboldschemel",
		},
		[3] = {
			"Pied-de-Lutin",
		},
	},
	[17] = {
		[1] = {
			"Lady\'s Smock",
		},
		[2] = {
			"Wiesenschaumkraut",
		},
		[3] = {
			"Cardamine des Prés",
		},
	},
	[18] = {
		[1] = {
			"Luminous Russula",
		},
		[2] = {
			"Leuchttäubling",
		},
		[3] = {
			"Russule Phosphorescente",
		},
	},
	[19] = {
		[1] = {
			"Mountain Flower",
		},
		[2] = {
			"Bergblume",
		},
		[3] = {
			"Lys des Cimes",
		},
	},
	[20] = {
		[1] = {
			"Namira\'s Rot",
		},
		[2] = {
			"Namiras Fäulnis",
		},
		[3] = {
			"Truffe de Namira",
		},
	},
	[21] = {
		[1] = {
			"Nirnroot",
		},
		[2] = {
			"Nirnwurz",
		},
		[3] = {
			"Nirnrave",
		},
	},
	[22] = {
		[1] = {
			"Stinkhorn",
		},
		[2] = {
			"Stinkmorchel",
		},
		[3] = {
			"Mutinus Elégans",
		},
	},
	[23] = {
		[1] = {
			"Violet Copninus",
		},
		[2] = {
			"Violetter Tintling",
		},
		[3] = {
			"Coprin Violet",
		},
	},
	[24] = {
		[1] = {
			"Water Hyacinth",
		},
		[2] = {
			"Wasserhyazinthe",
		},
		[3] = {
			"Jacinthe D\'eau",
		},
	},
	[25] = {
		[1] = {
			"White Cap",
		},
		[2] = {
			"Weißkappe",
		},
		[3] = {
			"Chapeau Blanc",
		},
	},
	[26] = {
		[1] = {
			"Wormwood",
		},
		[2] = {
			"Wermut",
		},
		[3] = {
			"Absinthe",
		},
	},
}
