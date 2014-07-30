--:===============================================================================================================
--: ESOMinion [Elder Scrolls Online]
--: VendorManager 2.0a (7.19.2014)
--:===============================================================================================================

eso_vendormanager = {}

--:===============================================================================================================
--: profile: initialize
--:===============================================================================================================  
--: loads profile, and alternately, creates a blank profile, in case the default profile can't be found

function eso_vendormanager:InitializeProfile()

	local blankprofile 		= {}
	blankprofile.itemtypes 	= {}
	blankprofile.qualities 	= {}
	blankprofile.data 		= {}
	
	local function nonzero(number)
		return number ~= 0
	end
	
	local itemtypes,excludeditemtypes = ITEMTYPES,ITEMTYPES_EXCLUDE
	local qualities,excludedqualities = ITEMQUALITIES,ITEMQUALITIES_EXCLUDE
	
	local itemtype,index = next(itemtypes)
	while itemtype and index do
		if not blankprofile.itemtypes[index] and nonzero(index) then
			blankprofile.itemtypes[index] 			= {}
			blankprofile.itemtypes[index].id 		= index
			blankprofile.itemtypes[index].name 		= itemtype
			blankprofile.itemtypes[index].label 	= eso_vendormanager:CreateLabel(itemtype)
			blankprofile.itemtypes[index].show		= not excludeditemtypes[itemtype]
		end
		
		if not blankprofile.data[index] and nonzero(index) then
			blankprofile.data[index] = {}
		end
			
		local quality,qindex = next(qualities)
		while quality and qindex do
			if not blankprofile.qualities[qindex] and nonzero(qindex) then
				blankprofile.qualities[qindex] 			= {}
				blankprofile.qualities[qindex].id 		= qindex
				blankprofile.qualities[qindex].name 	= quality
				blankprofile.qualities[qindex].label 	= eso_vendormanager:CreateLabel(quality)
				blankprofile.qualities[qindex].show		= not excludedqualities[quality]
			end
			if nonzero(index) and nonzero(qindex) then
				blankprofile.data[index][qindex] = false
			end
			quality,qindex = next(qualities,quality)
		end
		itemtype,index = next(itemtypes,itemtype)
	end
	
	local loadedprofile,error = persistence.load(eso_vendormanager.profilepath .. "default.profile")
	
	if error or not ValidTable(loadedprofile) then
		local error = persistence.store(eso_vendormanager.profilepath .. "default.profile", blankprofile)
	end

	return loadedprofile or blankprofile
end

--:===============================================================================================================
--: profile: save
--:===============================================================================================================  

function eso_vendormanager.SaveProfile()
	if ValidTable(eso_vendormanager.profile) then
		local err = persistence.store(eso_vendormanager.profilepath .. "default.profile", eso_vendormanager.profile)
		if err then
			d("VendorManager : Error Saving Profile -> " .. tostring(err))
		end
	end
	d("VendorManager : Profile saved")
end

--:===============================================================================================================
--: gui: initialize
--:===============================================================================================================  

function eso_vendormanager.InitializeGui() 
		
	local window = { name = "VendorManager", coords = {270,50,250,350}, visible = false }
	local section = "ItemType"
	
	GUI_NewWindow(window.name, unpack(window.coords))
	GUI_NewComboBox(window.name, " Type", "vmItemTypeFilter", section, "")
	--GUI_NewButton(window.name, "Save Profile", "eso_vendormanager.SaveProfile")
	--RegisterEventHandler("eso_vendormanager.SaveProfile", eso_vendormanager.SaveProfile)

	if ValidTable(eso_vendormanager.profile) then
		local itemtypes = eso_vendormanager.profile.itemtypes
		table.sort(itemtypes, function(a,b) return a.id < b.id end)
		local listitems = ""
		for index,itemtype in ipairs(itemtypes) do
			if itemtype.show == true then
				listitems = listitems .. itemtype.label .. ","
			end
		end
		listitems = listitems .. ", "
		vmItemTypeFilter_listitems = listitems
	end
	
	GUI_UnFoldGroup(window.name,"ItemType")
	GUI_WindowVisible(window.name, window.visible)
	return window
end

--:===============================================================================================================
--: gui: toggle
--:===============================================================================================================  

function eso_vendormanager.OnGuiToggle()
	eso_vendormanager.window.visible = not eso_vendormanager.window.visible
	GUI_WindowVisible(eso_vendormanager.window.name, eso_vendormanager.window.visible)
end

--:===============================================================================================================
--: gui: vars update
--:===============================================================================================================  

function eso_vendormanager.OnGuiVarUpdate(event,data,...)
	for key,value in pairs(data) do
	
		if key == "vmItemTypeFilter" then
			eso_vendormanager.OnNewItemTypeSelected(value)
		end
		
		if key:find("VendorManager") then
			local handler = assert(loadstring("return " .. key))()
			
			if type(handler) == "table" then
				if eso_vendormanager.profile then
					local itemtype 	= handler.itemtype
					local quality	= handler.quality
					local ilabel	= eso_vendormanager.profile.itemtypes[itemtype].label
					local qlabel	= eso_vendormanager.profile.qualities[quality].label
					
					local old = eso_vendormanager.profile.data[handler.itemtype][handler.quality]
					local new = value == "1"
					eso_vendormanager.profile.data[handler.itemtype][handler.quality] = new
					
					local debugstr = "VendorManager : " .. ilabel .. " (" .. qlabel .. ") -> " ..
					tostring(eso_vendormanager.profile.data[handler.itemtype][handler.quality])
					d(debugstr)
					eso_vendormanager.SaveProfile()
				end
			end
		end
	end
end

--:===============================================================================================================
--: gui: new item type
--:===============================================================================================================  
--: new item type was selected from the combobox, updating checkboxes accordingly

function eso_vendormanager.OnNewItemTypeSelected(itemtypelabel)

	if eso_vendormanager.profile and eso_vendormanager.profile.itemtypes then
		local newitemtype = nil
		local itemtypes = eso_vendormanager.profile.itemtypes
		local qualities = eso_vendormanager.profile.qualities
		local index,itemtype = next(itemtypes)
		
		while index and itemtype do
			if itemtype.label == itemtypelabel then
				newitemtype = index
				break
			end
			index,itemtype = next(itemtypes,index)
		end
		
		if newitemtype then
			GUI_DeleteGroup("VendorManager", "ItemQuality")
			table.sort(qualities, function(a,b) return a.id < b.id end)
			
			for index,quality in ipairs(qualities) do
				if quality.show then
					local handler = "{ " ..
						"module = VendorManager, " ..
						"itemtype = " .. tostring(newitemtype) .. ", " ..
						"quality  = " .. tostring(index) .. " }"
					GUI_NewCheckbox("VendorManager", " " .. quality.label, handler, "ItemQuality")
					
					if 	eso_vendormanager.profile.data[newitemtype] then
						local checked = "0"
						if eso_vendormanager.profile.data[newitemtype][index] == true then
							checked = "1"
						end
						_G[handler] = checked
					end
				end
			end
			GUI_UnFoldGroup("VendorManager", "ItemQuality")
		end
	end
end

--:===============================================================================================================
--: create label
--:===============================================================================================================
--: cleans then _G keys ie, "ITEMTYPE_GLYPH_WEAPON" returns "GlyphWeapon"

function eso_vendormanager:CreateLabel(label)
	label = string.gsub(label,"ITEMTYPE_","")
	label = string.gsub(label,"ITEM_QUALITY_","")
	label = string.gsub(label,"ENCHANTING_","")
	label = string.gsub(label,"_"," ")
	label = string.gsub(" " .. string.lower(label), "%W%l", string.upper):sub(2)
	label = string.gsub(label," ", "")
	return label
end

--:===============================================================================================================
--: constants
--:===============================================================================================================  

ITEMTYPES = {
	ITEMTYPE_NONE = 0,
	ITEMTYPE_WEAPON = 1,
	ITEMTYPE_ARMOR = 2,
	ITEMTYPE_PLUG = 3,
	ITEMTYPE_FOOD = 4,
	ITEMTYPE_TROPHY = 5,
	ITEMTYPE_SIEGE = 6,
	ITEMTYPE_POTION = 7,
	ITEMTYPE_RACIAL_STYLE_MOTIF = 8,
	ITEMTYPE_TOOL = 9,
	ITEMTYPE_INGREDIENT = 10,
	ITEMTYPE_ADDITIVE = 11,
	ITEMTYPE_DRINK = 12,
	ITEMTYPE_COSTUME = 13,
	ITEMTYPE_DISGUISE = 14,
	ITEMTYPE_TABARD = 15,
	ITEMTYPE_LURE = 16,
	ITEMTYPE_RAW_MATERIAL = 17,
	ITEMTYPE_CONTAINER = 18,
	ITEMTYPE_SOUL_GEM = 19,
	ITEMTYPE_GLYPH_WEAPON = 20,
	ITEMTYPE_GLYPH_ARMOR = 21,
	ITEMTYPE_LOCKPICK = 22,
	ITEMTYPE_WEAPON_BOOSTER = 23,
	ITEMTYPE_ARMOR_BOOSTER = 24,
	ITEMTYPE_ENCHANTMENT_BOOSTER = 25,
	ITEMTYPE_GLYPH_JEWELRY = 26,
	ITEMTYPE_SPICE = 27,
	ITEMTYPE_FLAVORING = 28,
	ITEMTYPE_RECIPE = 29,
	ITEMTYPE_POISON = 30,
	ITEMTYPE_REAGENT = 31,
	ITEMTYPE_DEPRECATED = 32,
	ITEMTYPE_ALCHEMY_BASE = 33,
	ITEMTYPE_COLLECTIBLE = 34,
	ITEMTYPE_BLACKSMITHING_RAW_MATERIAL = 35,
	ITEMTYPE_BLACKSMITHING_MATERIAL = 36,
	ITEMTYPE_WOODWORKING_RAW_MATERIAL = 37,
	ITEMTYPE_WOODWORKING_MATERIAL = 38,
	ITEMTYPE_CLOTHIER_RAW_MATERIAL = 39,
	ITEMTYPE_CLOTHIER_MATERIAL = 40,
	ITEMTYPE_BLACKSMITHING_BOOSTER = 41,
	ITEMTYPE_WOODWORKING_BOOSTER = 42,
	ITEMTYPE_CLOTHIER_BOOSTER = 43,
	ITEMTYPE_STYLE_MATERIAL = 44,
	ITEMTYPE_ARMOR_TRAIT = 45,
	ITEMTYPE_WEAPON_TRAIT = 46,
	ITEMTYPE_AVA_REPAIR = 47,
	ITEMTYPE_TRASH = 48,
	ITEMTYPE_SPELLCRAFTING_TABLET = 49,
	ITEMTYPE_MOUNT = 50,
	ITEMTYPE_ENCHANTING_RUNE_POTENCY = 51,
	ITEMTYPE_ENCHANTING_RUNE_ASPECT = 52,
	ITEMTYPE_ENCHANTING_RUNE_ESSENCE = 53,
}

ITEMTYPES_EXCLUDE = {
	ITEMTYPE_NONE = 0,					--nothing
	ITEMTYPE_PLUG = 3,					--nothing
	ITEMTYPE_SIEGE = 6,					--soulbound
	ITEMTYPE_RACIAL_STYLE_MOTIF = 8,	--protected
	ITEMTYPE_TOOL = 9,					--protected
	ITEMTYPE_ADDITIVE = 11,				--nothing
	ITEMTYPE_TABARD = 15,				--soulbound
	ITEMTYPE_SOUL_GEM = 19,				--protected
	ITEMTYPE_LOCKPICK = 22,				--protected
	ITEMTYPE_WEAPON_BOOSTER = 23,		--nothing
	ITEMTYPE_ARMOR_BOOSTER = 24,		--nothing
	ITEMTYPE_ENCHANTMENT_BOOSTER = 25,	--nothing
	ITEMTYPE_SPICE = 27,				--nothing
	ITEMTYPE_FLAVORING = 28,			--nothing
	ITEMTYPE_POISON = 30,				--nothing
	ITEMTYPE_DEPRECATED = 32,			--nothing
	ITEMTYPE_BLACKSMITHING_BOOSTER = 41,--tempers(protected)
	ITEMTYPE_WOODWORKING_BOOSTER = 42,	--tanins(protected)
	ITEMTYPE_CLOTHIER_BOOSTER = 43,		--resins(protected)
	ITEMTYPE_AVA_REPAIR = 47,			--soulbound
	ITEMTYPE_TRASH = 48,				--nothing
	ITEMTYPE_SPELLCRAFTING_TABLET = 49,	--nothing
	ITEMTYPE_MOUNT = 50,				--soulbound
}

ITEMQUALITIES = {
	ITEM_QUALITY_TRASH = 0,
	ITEM_QUALITY_NORMAL = 1,
	ITEM_QUALITY_MAGIC = 2,
	ITEM_QUALITY_ARCANE = 3,
	ITEM_QUALITY_ARTIFACT = 4,
	ITEM_QUALITY_LEGENDARY = 5,
}

ITEMQUALITIES_EXCLUDE = {
	ITEM_QUALITY_TRASH = 0,				--nothing
	ITEM_QUALITY_LEGENDARY = 5,			--only ferenz vendors handmade legendaries
}

--:===============================================================================================================
--: module: initialize
--:===============================================================================================================  

function eso_vendormanager.Initialize() 
	eso_vendormanager.profilepath = GetStartupPath() .. [[\LuaMods\ESOMinion\VendorManagerProfiles\]];
	eso_vendormanager.profile = eso_vendormanager:InitializeProfile()
	eso_vendormanager.window  = eso_vendormanager.InitializeGui() 
end

--:===============================================================================================================
--: register event handlers
--:===============================================================================================================  

RegisterEventHandler("eso_vendormanager.OnGuiToggle", eso_vendormanager.OnGuiToggle)
RegisterEventHandler("GUI.Update", eso_vendormanager.OnGuiVarUpdate)
RegisterEventHandler("Module.Initalize", eso_vendormanager.Initialize)
