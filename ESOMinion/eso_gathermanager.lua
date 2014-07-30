--:===============================================================================================================
--: ESOMinion [Elder Scrolls Online]
--: GatherManager (7.24.2014)
--:===============================================================================================================

eso_gathermanager = {}
eso_gathermanager.profilepath = GetStartupPath() .. [[\LuaMods\ESOMinion\GatherManagerProfiles\]]
eso_gathermanager.window = { name = GetString("gatherManager"), coords = {270,50,250,350}, visible = false }

--:===============================================================================================================
--: load profile
--:===============================================================================================================  

function eso_gathermanager:LoadProfile()
	eso_gathermanager.profile, error = persistence.load(eso_gathermanager.profilepath .. "gather.profile")
	if error then
		eso_gathermanager.profile = {}
		for typeIndex,typeName in pairs(eso_gathermanager.types) do
			eso_gathermanager.profile[typeIndex] = true
		end
		eso_gathermanager.SaveProfile()
	end
	d("GatherManager : Profile Loaded")
end

--:===============================================================================================================
--: save profile
--:===============================================================================================================  

function eso_gathermanager.SaveProfile()
	local error = persistence.store(eso_gathermanager.profilepath .. "gather.profile", eso_gathermanager.profile)
	if error then
		d("GatherManager : " .. error)
	end
	d("GatherManager : Profile Saved")
end

--:===============================================================================================================
--: entity list
--:===============================================================================================================

function eso_gathermanager.NearestGatherable()
	
	local gatherables = {}
	local gatherlist = EntityList("onmesh,gatherable")
	
	if ValidTable(gatherlist) then
		local id,node = next(gatherlist)
		while (id and node) do
			if eso_gathermanager.IsGatherable(node) then
				table.insert(gatherables,node)
			end
			id,node = next(gatherlist,id)
		end
	end

	table.sort(gatherables,
		function(a,b)
			return a.distance < b.distance
		end
	)

	if ValidTable(gatherables) then
		local id,node = next(gatherables)
		if (id and node) then
			return node
		end
	end

	return nil
end

--:===============================================================================================================
--: is gatherable
--:===============================================================================================================  

function eso_gathermanager.IsGatherable(node)
	local gathertype = eso_gathermanager.GetType(node)
	
	if (gathertype and eso_gathermanager.profile[gathertype] == false) then
		return false
	end
	
	return true
end

--:===============================================================================================================
--: get type
--:===============================================================================================================

function eso_gathermanager.GetType(node)
	for type = 1, #eso_gathermanager.types do
		for language = 1, #eso_gathermanager.languages do
		
			for index,name in pairs(eso_gathermanager.data[type][language]) do
				if (node.name == name) then
					return type
				end
			end
		end
	end
	
	return nil
end

--:===============================================================================================================
--: toggle gui
--:===============================================================================================================  

function eso_gathermanager.OnGuiToggle()
	eso_gathermanager.window.visible = not eso_gathermanager.window.visible
	GUI_WindowVisible(eso_gathermanager.window.name, eso_gathermanager.window.visible)
end

--:===============================================================================================================
--: vars update
--:===============================================================================================================  

function eso_gathermanager.OnGuiVarUpdate(event,data,...)
	for key,value in pairs(data) do
	
		if key:find("GatherManager") then
			local handler = assert(loadstring("return " .. key))()
			
			if type(handler) == "table" then
				if eso_gathermanager.profile then
					eso_gathermanager.profile[handler.gathertype] = (value == "1")
					eso_gathermanager.SaveProfile()
					
					local gathertype = eso_gathermanager.types[handler.gathertype]
					local debugstr = "GatherManager : " .. gathertype .. " -> " ..
					tostring(eso_gathermanager.profile[handler.gathertype])
					--d(debugstr)
				end
			end
		end
	end
end

--:===============================================================================================================
--: initialize
--:===============================================================================================================  

function eso_gathermanager.Initialize() 
	eso_gathermanager:LoadProfile()
	GUI_NewWindow(eso_gathermanager.window.name, unpack(eso_gathermanager.window.coords))
	for index,gathertype in ipairs(eso_gathermanager.types) do
		local handler = "{ module = GatherManager, gathertype = " .. tostring(index) .. " } "
		GUI_NewCheckbox(eso_gathermanager.window.name, " " .. gathertype, handler, GetString("generalSettings"))
		if eso_gathermanager.profile[index] then
			if (eso_gathermanager.profile[index] == false) then
				_G[handler] = "0"
			else
				_G[handler] = "1"
			end
		end

	end
	GUI_UnFoldGroup(eso_gathermanager.window.name, GetString("generalSettings"))
	GUI_WindowVisible(eso_gathermanager.window.name, eso_gathermanager.window.visible)
end

--:===============================================================================================================
--: register event handlers
--:===============================================================================================================  

RegisterEventHandler("eso_gathermanager.OnGuiToggle", eso_gathermanager.OnGuiToggle)
RegisterEventHandler("GUI.Update", eso_gathermanager.OnGuiVarUpdate)
RegisterEventHandler("Module.Initalize", eso_gathermanager.Initialize)

--:===============================================================================================================
--: data
--:===============================================================================================================

eso_gathermanager.types = {
	[1] = "Blacksmithing",
	[2] = "Clothing",
	[3] = "Woodworking",
	[4] = "Reagents",
	[5] = "Solvents",
	[6] = "AspectRune",
	[7] = "EssenceRune",
	[8] = "PotencyRune",
}

eso_gathermanager.languages = {
	[1] = "en",
	[2] = "de",
	[3] = "fr",
}

eso_gathermanager.data = {
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
			"Minerai D'orichalque",
			"Minerai Dwemer",
			"Minerai d'Ebonite",
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
			"Fil d'Ebonite",
			"Lin",
			"Herbe de fer",
			"Jute",
			"Kreshweed",
			"Silverweed",
			"Toile D'araignée",
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
			"Blessed Thistle",
			"Entoloma",
			"Bugloss",
			"Columbine",
			"Corn Flower",
			"Dragonthorn",
			"Emetic Russula",
			"Imp Stool",
			"Lady's Smock",
			"Luminous Russula",
			"Mountain Flower",
			"Namira's Rot",
			"Nirnroot",
			"Stinkhorn",
			"Violet Copninus",
			"Water Hyacinth",
			"White Cap",
			"Wormwood",
		},
		[2] = {
			"Benediktenkraut",
			"Glöckling",
			"Wolfsauge",
			"Akelei",
			"Kornblume",
			"Drachendorn",
			"Brechtäubling",
			"Koboldschemel",
			"Wiesenschaumkraut",
			"Leuchttäubling",
			"Bergblume",
			"Namiras Fäulnis",
			"Nirnwurz",
			"Stinkmorchel",
			"Violetter Tintling",
			"Wasserhyazinthe",
			"Weißkappe",
			"Wermut",
		},
		[3] = {
			"Chardon Béni",
			"Entoloma",
			"Noctuelle",
			"Ancolie",
			"Bleuet",
			"Épine-de-Dragon",
			"Russule Emetique",
			"Pied-de-Lutin",
			"Cardamine des Prés",
			"Russule Phosphorescente",
			"Lys des Cimes",
			"Truffe de Namira",
			"Nirnrave",
			"Mutinus Elégans",
			"Coprin Violet",
			"Jacinthe D'eau",
			"Chapeau Blanc",
			"Absinthe",
		},
	},
	[5] = {
		[1] = {
			"Pure Water",
			"Water Skin",
		},
		[2] = {
			"Reines Wasser",
			"Wasserhaut",
		},
		[3] = {
			"Eau Pure",
			"Outre d'Eau",
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
			"Rune d'Aspect",
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
			"Rune D'essence",
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
}
