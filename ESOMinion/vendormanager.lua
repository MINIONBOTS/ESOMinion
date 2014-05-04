eso_vendormanager = {}


eso_vendormanager.profilepath = GetStartupPath() .. [[\LuaMods\ESOMinion\VendorManagerProfiles\]];
eso_vendormanager.MainWindow = { Name = GetString("vendorManager"), x = 350, y = 50, w = 250, h = 350}
eso_vendormanager.visible = false
eso_vendormanager.InventoryL = {}
eso_vendormanager.WhiteL = {}

eso_vendormanager.DefaultProfiles = {
	[1] = "Default",
}

function eso_vendormanager.ModuleInit() 	
	if (Settings.ESOMinion.gVMprofile == nil) then
		Settings.ESOMinion.gVMprofile = "Default"
	end
	if (Settings.ESOMinion.gWhiteList == nil) then
		Settings.ESOMinion.gWhiteList = "None"
	end
	if (Settings.ESOMinion.gInventory == nil) then
		Settings.ESOMinion.gInventory = "None"
	end
	if (Settings.ESOMinion.VM_ATRASH == nil) then
		Settings.ESOMinion.VM_ATRASH = 0
	end
	if (Settings.ESOMinion.VM_ANORMAL == nil) then
		Settings.ESOMinion.VM_ANORMAL = 0
	end
	if (Settings.ESOMinion.VM_AMAGIC == nil) then
		Settings.ESOMinion.VM_AMAGIC = 0
	end
	if (Settings.ESOMinion.VM_AARCANE == nil) then
		Settings.ESOMinion.VM_AARCANE = 0
	end
	if (Settings.ESOMinion.VM_AARTEFACT == nil) then
		Settings.ESOMinion.VM_AARTEFACT = 0
	end
	if (Settings.ESOMinion.VM_WTRASH == nil) then
		Settings.ESOMinion.VM_WTRASH = 0
	end
	if (Settings.ESOMinion.VM_WNORMAL == nil) then
		Settings.ESOMinion.VM_WNORMAL = 0
	end
	if (Settings.ESOMinion.VM_WMAGIC == nil) then
		Settings.ESOMinion.VM_WMAGIC = 0
	end
	if (Settings.ESOMinion.VM_WARCANE == nil) then
		Settings.ESOMinion.VM_WARCANE = 0
	end
	if (Settings.ESOMinion.VM_WARTEFACT == nil) then
		Settings.ESOMinion.VM_WARTEFACT = 0
	end
	if (Settings.ESOMinion.VM_FTRASH == nil) then
		Settings.ESOMinion.VM_FTRASH = "0"
	end
	if (Settings.ESOMinion.VM_FNORMAL == nil) then
		Settings.ESOMinion.VM_FNORMAL = "0"
	end
	if (Settings.ESOMinion.VM_FMAGIC == nil) then
		Settings.ESOMinion.VM_FMAGIC = "0"
	end
	if (Settings.ESOMinion.VM_FARCANE == nil) then
		Settings.ESOMinion.VM_FARCANE = "0"
	end
	if (Settings.ESOMinion.VM_FARTEFACT == nil) then
		Settings.ESOMinion.VM_FARTEFACT = "0"
	end
	if (Settings.ESOMinion.VM_ADDITIVE == nil) then
		Settings.ESOMinion.VM_ADDITIVE = "0"
	end
	if (Settings.ESOMinion.VM_ALCHEMYBASE == nil) then
		Settings.ESOMinion.VM_ALCHEMYBASE = "0"
	end
	if (Settings.ESOMinion.VM_ENCHANTRUNE == nil) then
		Settings.ESOMinion.VM_ENCHANTRUNE = "0"
	end
	if (Settings.ESOMinion.VM_REAGENT == nil) then
		Settings.ESOMinion.VM_REAGENT = "0"
	end
	if (Settings.ESOMinion.VM_RAWMATERIAL == nil) then
		Settings.ESOMinion.VM_RAWMATERIAL = "0"
	end
	if (Settings.ESOMinion.VM_RECIPE == nil) then
		Settings.ESOMinion.VM_RECIPE = "0"
	end
	if (Settings.ESOMinion.VM_INGREDIENT == nil) then
		Settings.ESOMinion.VM_INGREDIENT = "0"
	end
	if (Settings.ESOMinion.VM_PPOTIONS == nil) then
		Settings.ESOMinion.VM_PPOTIONS= "0"
	end
	if (Settings.ESOMinion.VM_COLLECTIBLE == nil) then
		Settings.ESOMinion.VM_COLLECTIBLE = "0"
	end
	if (Settings.ESOMinion.VM_COSTUME == nil) then
		Settings.ESOMinion.VM_COSTUME = "0"
	end
	if (Settings.ESOMinion.VM_DRINK == nil) then
		Settings.ESOMinion.VM_DRINK = "0"
	end
	if (Settings.ESOMinion.VM_LOCKPICK == nil) then
		Settings.ESOMinion.VM_LOCKPICK = "0"
	end
	if (Settings.ESOMinion.VM_LURE == nil) then
		Settings.ESOMinion.VM_LURE = "0"
	end
	if (Settings.ESOMinion.VM_SOULGEM == nil) then
		Settings.ESOMinion.VM_SOULGEM = "0"
	end
	if (Settings.ESOMinion.VM_SPICE == nil) then
		Settings.ESOMinion.VM_SPICE = "0"
	end
	if (Settings.ESOMinion.VM_STYLEMAT == nil) then
		Settings.ESOMinion.VM_STYLEMAT = "0"
	end
	if (Settings.ESOMinion.VM_ITEMTRASH == nil) then
		Settings.ESOMinion.VM_ITEMTRASH = "0"
	end
	if (Settings.ESOMinion.VM_TROPHY == nil) then
		Settings.ESOMinion.VM_TROPHY = "0"
	end
	if (Settings.ESOMinion.VM_GLYPHARMOR == nil) then
		Settings.ESOMinion.VM_GLYPHARMOR = "0"
	end
	if (Settings.ESOMinion.VM_GLYPHWEAPON == nil) then
		Settings.ESOMinion.VM_GLYPHWEAPON = "0"
	end
	if (Settings.ESOMinion.VM_GLYPHJEWELRY == nil) then
		Settings.ESOMinion.VM_GLYPHJEWELRY = "0"
	end
	if (Settings.ESOMinion.VM_CHEST == nil) then
		Settings.ESOMinion.VM_CHEST = "0"
	end
	if (Settings.ESOMinion.VM_FEET == nil) then
		Settings.ESOMinion.VM_FEET = "0"
	end
	if (Settings.ESOMinion.VM_HAND == nil) then
		Settings.ESOMinion.VM_HAND = "0"
	end
	if (Settings.ESOMinion.VM_CHEST== nil) then
		Settings.ESOMinion.VM_CHEST = "0"
	end
	if (Settings.ESOMinion.VM_HEAD == nil) then
		Settings.ESOMinion.VM_HEAD = "0"
	end
	if (Settings.ESOMinion.VM_LEGS == nil) then
		Settings.ESOMinion.VM_LEGS = "0"
	end
	if (Settings.ESOMinion.VM_SHOULDERS== nil) then
		Settings.ESOMinion.VM_SHOULDERS = "0"
	end
	if (Settings.ESOMinion.VM_WAIST== nil) then
		Settings.ESOMinion.VM_WAIST = "0"
	end
	if (Settings.ESOMinion.VM_NECK== nil) then
		Settings.ESOMinion.VM_NECK = "0"
	end
	if (Settings.ESOMinion.VM_RING== nil) then
		Settings.ESOMinion.VM_RING = "0"
	end
	if (Settings.ESOMinion.VM_OFFHAND== nil) then
		Settings.ESOMinion.VM_OFFHAND = "0"
	end
	if (Settings.ESOMinion.VM_ONEHAND== nil) then
		Settings.ESOMinion.VM_ONEHAND = "0"
	end
	if (Settings.ESOMinion.VM_TWOHAND== nil) then
		Settings.ESOMinion.VM_TWOHAND = "0"
	end

	

	
		
	GUI_NewWindow(eso_vendormanager.MainWindow.Name,eso_vendormanager.MainWindow.x,eso_vendormanager.MainWindow.y,eso_vendormanager.MainWindow.w,eso_vendormanager.MainWindow.h,"",true)
	GUI_NewComboBox(eso_vendormanager.MainWindow.Name,GetString("profile"),"gVMprofile",GetString("generalSettings"),"")
	GUI_NewComboBox(eso_vendormanager.MainWindow.Name,strings[gCurrentLanguage].inventoryl,"gInventory","WhiteList","")
	GUI_NewButton(eso_vendormanager.MainWindow.Name,GetString("addWhite"),"VMAddWhiteList","WhiteList")
	RegisterEventHandler("VMAddWhiteList",eso_vendormanager.AddWhiteList)
	GUI_NewButton(eso_vendormanager.MainWindow.Name,GetString("updInv"),"VMupdInventoryList","WhiteList")
	RegisterEventHandler("VMupdInventoryList",eso_vendormanager.UpdateInventoryList)
	GUI_NewComboBox(eso_vendormanager.MainWindow.Name,strings[gCurrentLanguage].whitelist,"gWhiteList","WhiteList","")
	GUI_NewButton(eso_vendormanager.MainWindow.Name,GetString("delWhite"),"VMDelWhiteList","WhiteList")
	RegisterEventHandler("VMDelWhiteList",eso_vendormanager.DelWhiteList)
	GUI_NewField(eso_vendormanager.MainWindow.Name,GetString("newProfileName"),"gVMnewname",GetString("generalSettings"))
	GUI_NewButton(eso_vendormanager.MainWindow.Name,GetString("newProfile"),"VMClearWhiteList",GetString("generalSettings"))
	RegisterEventHandler("VMClearWhiteList",eso_vendormanager.CreateNewProfile)
	GUI_NewButton(eso_vendormanager.MainWindow.Name,GetString("savWhite"),"VMSavWhiteList")
	RegisterEventHandler("VMSavWhiteList",eso_vendormanager.SaveProfile)


	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("trash"),"VM_ATRASH","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("normal"),"VM_ANORMAL","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("magic"),"VM_AMAGIC","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("arcane"),"VM_AARCANE","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("artefact"),"VM_AARTEFACT","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("chest"),"VM_CHEST","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("feets"),"VM_FEET","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("hands"),"VM_HAND","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("head"),"VM_HEAD","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("legs"),"VM_LEGS","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("waist"),"VM_WAIST","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("shoulders"),"VM_SHOULDERS","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("neck"),"VM_NECK","Armor")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("ring"),"VM_RING","Armor")
	

	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("trash"),"VM_WTRASH","Weapon")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("normal"),"VM_WNORMAL","Weapon")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("magic"),"VM_WMAGIC","Weapon")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("arcane"),"VM_WARCANE","Weapon")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("artefact"),"VM_WARTEFACT","Weapon")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("offhand"),"VM_OFFHAND","Weapon")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("onehand"),"VM_ONEHAND","Weapon")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("twohand"),"VM_TWOHAND","Weapon")
	

	


	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("trash"),"VM_FTRASH","Food")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("normal"),"VM_FNORMAL","Food")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("magic"),"VM_FMAGIC","Food")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("arcane"),"VM_FARCANE","Food")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("artefact"),"VM_FARTEFACT","Food")
	
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("additive"),"VM_ADDITIVE","Crafting")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("alchemybase"),"VM_ALCHEMYBASE","Crafting")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("enchantingrune"),"VM_ENCHANTRUNE","Crafting")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("reagent"),"VM_REAGENT","Crafting")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("recipe"),"VM_RECIPE","Crafting")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("rawmaterial"),"VM_RAWMATERIAL","Crafting")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("ingredient"),"VM_INGREDIENT","Crafting")

	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("potions"),"VM_PPOTIONS","Potions")

	

	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("collectible"),"VM_COLLECTIBLE","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("costume"),"VM_COSTUME","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("drink"),"VM_DRINK","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("lockpick"),"VM_LOCKPICK","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("lure"),"VM_LURE","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("soulgem"),"VM_SOULGEM","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("spice"),"VM_SPICE","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("stylematerial"),"VM_STYLEMAT","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("itemtrash"),"VM_ITEMTRASH","Misc")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("trophy"),"VM_TROPHY","Misc")


	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("glypharmor"),"VM_GLYPHARMOR","Glyph")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("glyphweapon"),"VM_GLYPHWEAPON","Glyph")
	GUI_NewCheckbox(eso_vendormanager.MainWindow.Name,GetString("glyphjewelry"),"VM_GLYPHJEWELRY","Glyph")
	

		VM_ATRASH = Settings.ESOMinion.VM_ATRASH
		VM_ANORMAL = Settings.ESOMinion.M_ANORMAL 
		VM_AMAGIC = Settings.ESOMinion.VM_AMAGIC
		VM_AARCANE = Settings.ESOMinion.VM_AARCANE	
		VM_AARTEFACT = Settings.ESOMinion.VM_AARTEFACT
		VM_WTRASH = Settings.ESOMinion.VM_WTRASH
		VM_WNORMAL = Settings.ESOMinion.VM_WNORMAL
		VM_WTRASH = Settings.ESOMinion.VM_WTRASH
		VM_WMAGIC = Settings.ESOMinion.VM_WMAGIC
		VM_WARCANE = Settings.ESOMinion.VM_WARCANE
		VM_WARTEFACT = Settings.ESOMinion.VM_WARTEFACTb
		VM_FTRASH = Settings.ESOMinion.VM_FTRASH 
		VM_FNORMAL = Settings.ESOMinion.VM_FNORMAL
		VM_FMAGIC = Settings.ESOMinion.VM_FMAGIC
		VM_FARCANE = Settings.ESOMinion.VM_FARCANE
		VM_FARTEFACT = Settings.ESOMinion.VM_FARTEFACT
		VM_ADDITIVE = Settings.ESOMinion.VM_ADDITIVE 
		VM_ALCHEMYBASE = Settings.ESOMinion.VM_ALCHEMYBASE
		VM_ENCHANTRUNE = Settings.ESOMinion.VM_ENCHANTRUNE
		VM_REAGENT = Settings.ESOMinion.VM_REAGENT
		VM_RAWMATERIAL = Settings.ESOMinion.VM_RAWMATERIAL
		VM_PPOTIONS = Settings.ESOMinion.VM_PPOTIONS
		VM_RECIPE = Settings.ESOMinion.VM_RECIPE
		VM_INGREDIENT = Settings.ESOMinion.VM_INGREDIENT 
		VM_COLLECTIBLE = Settings.ESOMinion.VM_COLLECTIBLE
		VM_COSTUME = Settings.ESOMinion.VM_COSTUME 
		VM_DRINK = Settings.ESOMinion.VM_DRINK
		VM_LOCKPICK = Settings.ESOMinion.VM_LOCKPICK
		VM_LURE = Settings.ESOMinion.VM_LURE 
		VM_SOULGEM = Settings.ESOMinion.VM_SOULGEM
		VM_SPICE = Settings.ESOMinion.VM_SPICE
		VM_STYLEMAT = Settings.ESOMinion.VM_STYLEMAT
		VM_ITEMTRASH = Settings.ESOMinion.VM_ITEMTRASH
		VM_TROPHY = Settings.ESOMinion.VM_TROPHY 
		VM_GLYPHARMOR = Settings.ESOMinion.VM_GLYPHARMOR
		VM_GLYPHWEAPON = Settings.ESOMinion.VM_GLYPHWEAPON 
		VM_GLYPHJEWELRY = Settings.ESOMinion.VM_GLYPHJEWELRY
		VM_CHEST = Settings.ESOMinion.VM_CHEST
		VM_FEET = Settings.ESOMinion.VM_FEET
		VM_HAND = Settings.ESOMinion.VM_HAND
		VM_HEAD = Settings.ESOMinion.VM_HEAD
		VM_LEGS = Settings.ESOMinion.VM_LEGS
		VM_NECK = Settings.ESOMinion.VM_NECK
		VM_OFFHAND = Settings.ESOMinion.VM_OFFHAND
		VM_ONEHAND = Settings.ESOMinion.VM_ONEHAND
		VM_RING = Settings.ESOMinion.VM_RING
		VM_SHOULDERS = Settings.ESOMinion.VM_SHOULDERS
		VM_TWOHAND = Settings.ESOMinion.VM_TWOHAND
		VM_WAIST = Settings.ESOMinion.VM_WAIST
		
		
		
	gVMprofile = Settings.ESOMinion.gVMprofile
	gVMnewname = ""
  		
	GUI_SizeWindow(eso_vendormanager.MainWindow.Name,eso_vendormanager.MainWindow.w,eso_vendormanager.MainWindow.h)
	GUI_UnFoldGroup(eso_vendormanager.MainWindow.Name,GetString("generalSettings"))
	GUI_WindowVisible(eso_vendormanager.MainWindow.Name,false)
	
	
	
	eso_vendormanager.UpdateProfiles()
	eso_vendormanager.UpdateInventoryList()
	GUI_DeleteGroup(eso_vendormanager.MainWindow.Name,"ProfileItems")
	eso_vendormanager.UpdateCurrentProfileData()	
	
	
end

function eso_vendormanager.getInventoryList()
local args = { e("GetBagInfo(1)")}    
 local numArgs = #args
 local InventoryMax = args[2]
 local i = 0
local v = 0
 while(i < tonumber(InventoryMax)) do
	if(e("GetItemName(1,"..tostring(i)..")") ~= "") then
	eso_vendormanager.InventoryL[v] = e("GetItemName(1,"..tostring(i)..")")
		v = v + 1
	end
	i = i + 1
 end
 gInventory_listitems = strings[gCurrentLanguage].inventoryl..",".."test"..",".."test"
end



function eso_vendormanager.UpdateProfiles()
	-- Grab all Profiles and enlist them in the dropdown field
	local profiles = ""
	local found = "None"	
	
	local profilelist = dirlist(eso_vendormanager.profilepath,".*lua")
	if ( TableSize(profilelist) > 0) then			
		local i,profile = next ( profilelist)
		while i and profile do				
			profile = string.gsub(profile, ".lua", "")
			
			
			local file = fileread(eso_vendormanager.profilepath..profile..".lua")
			if ( TableSize(file) > 0) then
				local i, line = next (file)					
				local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
				
				
					profiles = profiles..","..profile
					if ( Settings.ESOMinion.gVMprofile ~= nil and Settings.ESOMinion.gVMprofile == profile ) then
						d("Last Profile found : "..profile)
						found = profile					
					end					
				--end
			end
			i,profile = next ( profilelist,i)
		end		
	else
		ml_error("No Sdsfsd profiles for our current Profession found")		
	end
	gVMprofile_listitems = profiles
	
	-- try to load default profiles
	
	gVMprofile = found
end


function eso_vendormanager.RefreshWhiteList()
	gWhiteList_listitems = ""
	local myitems = gWhiteList_listitems
	if ( TableSize(eso_vendormanager.WhiteL) > 0) then			
		local i,item = next ( eso_vendormanager.WhiteL)
			while i and item do	
				myitems = myitems..","..item
				i,item = next ( eso_vendormanager.WhiteL ,i)
		end
	end
	gWhiteList_listitems = myitems
	
	

end


function eso_vendormanager.UpdateInventoryList()
	--Grab all items in inventory and add them to a dropdown list
	local myitems = ""
	
	eso_vendormanager.getInventoryList()
	if ( TableSize(eso_vendormanager.InventoryL ) > 0) then			
		local i,myitem = next (eso_vendormanager.InventoryL)
		 while i and myitem do			
		
				myitems = myitems..","..myitem
				
			i,myitem = next ( eso_vendormanager.InventoryL ,i)
		end		
	else
		ml_error("No item found in your inventory")		
	end
	gInventory_listitems = myitems
	
end



function eso_vendormanager.CreateNewProfile()
	--reset all fields 
    gVMprofile = "None"
    Settings.ESOMinion.gVMprofile = gVMprofile
	eso_vendormanager.InventoryL = {}
	eso_vendormanager.WhiteL = {}
		
	eso_vendormanager.RefreshWhiteList()
	gWhiteList_listitems = ""
	VM_ATRASH="0"
	VM_ANORMAL="0"
	VM_AMAGIC="0"
	VM_AARCANE="0"
	VM_AARTEFACT="0"
	VM_WTRASH="0"
	VM_WNORMAL="0"
	VM_WMAGIC="0"
	VM_WARCANE="0"
	VM_WARTEFACT="0"
	VM_FTRASH="0"
	VM_FNORMAL="0"
	VM_FMAGIC="0"
	VM_FARCANE="0"
	VM_FARTEFACT="0"
	VM_ADDITIVE="0"
	VM_ALCHEMYBASE="0"
	VM_ENCHANTRUNE="0"
	VM_REAGENT="0"
	VM_RAWMATERIAL="0"
	VM_RECIPE="0"
	VM_INGREDIENT="0"
	VM_PPOTIONS="0"
	VM_COLLECTIBLE="0"
	VM_COSTUME="0"
	VM_DRINK="0"
	VM_LOCKPICK="0"
	VM_LURE="0"
	VM_SOULGEM="0"
	VM_SPICE="0"
	VM_STYLEMAT="0"
	VM_ITEMTRASH="0"
	VM_TROPHY="0"
	VM_GLYPHARMOR="0"
	VM_GLYPHWEAPON="0"
	VM_GLYPHJEWELRY="0"
	VM_CHEST = "0"
	VM_FEET = "0"
	VM_HAND = "0"
	VM_HEAD = "0"
	VM_LEGS = "0"
	VM_NECK = "0"
	VM_OFFHAND = "0"
	VM_ONEHAND = "0"
	VM_RING = "0"
	VM_SHOULDERS = "0"
	VM_TWOHAND = "0"
	VM_WAIST = "0"
		
end

function eso_vendormanager.AddWhiteList()

	if ( TableSize(eso_vendormanager.WhiteL ) > 0) then
		local i,whiteitem = next (eso_vendormanager.WhiteL)
		while i and whiteitem do
			if(whiteitem == gInventory) then
				d("Item is allready on list!")
				return
			end
			i,whiteitem = next ( eso_vendormanager.WhiteL ,i)
		end
	end
local myitems = gWhiteList_listitems
		
	myitems = myitems..","..gInventory
	gWhiteList_listitems = myitems

	
	table.insert(eso_vendormanager.WhiteL,TableSize(gInventory)+1,gInventory)

end



function eso_vendormanager.DelWhiteList()
	if ( TableSize(eso_vendormanager.WhiteL ) > 0) then	
		local i,myitem = next (eso_vendormanager.WhiteL)
		while(myitem ~= nil)do
			if(myitem == gWhiteList)then
				table.remove(eso_vendormanager.WhiteL,i,gWhiteList)
			end
			i,myitem = next (eso_vendormanager.WhiteL,i)
		end
	end
	
	eso_vendormanager.RefreshWhiteList()
end
		

function eso_vendormanager.SaveProfile()
    -- Save under new name if one was entered
		local isnew = false
		
		if((gVMnewname ~= "" ) and (gVMnewname ~= nil)) then
			filename = gVMnewname
			isnew = true
		else
			filename = gVMprofile
		end
		--prevent from breaking the code
		if(filename == "None")then
			ml_error("Enter a valid profile name")
			return
		end
	
	 -- Save current Profiledata into the Profile-file 
    if ( filename ~= "" ) then

		local string2write = ""
		local i,item = next (eso_vendormanager.WhiteL)
			while i and item do
			d(item)
			local itemname  = eso_vendormanager.WhiteL[i]
			string2write = string2write.."VM_NAME="..tostring(itemname).."\n"	
			i,item = next (eso_vendormanager.WhiteL,i)
		end	

			string2write = string2write.."VM_ATRASH="..tostring(VM_ATRASH).."\n"
			string2write = string2write.."VM_ANORMAL="..tostring(VM_ANORMAL).."\n"
			string2write = string2write.."VM_AMAGIC="..tostring(VM_AMAGIC).."\n"
			string2write = string2write.."VM_AARCANE="..tostring(VM_AARCANE).."\n"
			string2write = string2write.."VM_AARTEFACT="..tostring(VM_AARTEFACT).."\n"
			string2write = string2write.."VM_WTRASH="..tostring(VM_WTRASH).."\n"
			string2write = string2write.."VM_WNORMAL="..tostring(VM_WNORMAL).."\n"
			string2write = string2write.."VM_WMAGIC="..tostring(VM_WMAGIC).."\n"
			string2write = string2write.."VM_WARCANE="..tostring(VM_WARCANE).."\n"
			string2write = string2write.."VM_WARTEFACT="..tostring(VM_WARTEFACT).."\n"
			string2write = string2write.."VM_FTRASH="..tostring(VM_FTRASH).."\n"
			string2write = string2write.."VM_FNORMAL="..tostring(VM_FNORMAL).."\n"
			string2write = string2write.."VM_FMAGIC="..tostring(VM_FMAGIC).."\n"
			string2write = string2write.."VM_FARCANE="..tostring(VM_FARCANE).."\n"
			string2write = string2write.."VM_FARTEFACT="..tostring(VM_FARTEFACT).."\n"
			string2write = string2write.."VM_ADDITIVE="..tostring(VM_ADDITIVE).."\n"
			string2write = string2write.."VM_ALCHEMYBASE="..tostring(VM_ALCHEMYBASE).."\n"
			string2write = string2write.."VM_ENCHANTRUNE="..tostring(VM_ENCHANTRUNE).."\n"
			string2write = string2write.."VM_REAGENT="..tostring(VM_REAGENT).."\n"
			string2write = string2write.."VM_RAWMATERIAL="..tostring(VM_RAWMATERIAL).."\n"
			string2write = string2write.."VM_RECIPE="..tostring(VM_RECIPE).."\n"
			string2write = string2write.."VM_INGREDIENT="..tostring(VM_INGREDIENT).."\n"
			string2write = string2write.."VM_PPOTIONS="..tostring(VM_PPOTIONS).."\n"
			string2write = string2write.."VM_COLLECTIBLE="..tostring(VM_COLLECTIBLE).."\n"
			string2write = string2write.."VM_COSTUME="..tostring(VM_COSTUME).."\n"
			string2write = string2write.."VM_DRINK="..tostring(VM_DRINK).."\n"
			string2write = string2write.."VM_LOCKPICK="..tostring(VM_LOCKPICK).."\n"
			string2write = string2write.."VM_LURE="..tostring(VM_LURE).."\n"
			string2write = string2write.."VM_SOULGEM="..tostring(VM_SOULGEM).."\n"
			string2write = string2write.."VM_SPICE="..tostring(VM_SPICE).."\n"
			string2write = string2write.."VM_STYLEMAT="..tostring(VM_STYLEMAT).."\n"
			string2write = string2write.."VM_ITEMTRASH="..tostring(VM_ITEMTRASH).."\n"
			string2write = string2write.."VM_TROPHY="..tostring(VM_TROPHY).."\n"
			string2write = string2write.."VM_GLYPHARMOR="..tostring(VM_GLYPHARMOR).."\n"
			string2write = string2write.."VM_GLYPHWEAPON="..tostring(VM_GLYPHWEAPON).."\n"
			string2write = string2write.."VM_GLYPHJEWELRY="..tostring(VM_GLYPHJEWELRY).."\n"
			string2write = string2write.."VM_CHEST="..tostring(VM_CHEST).."\n"
			string2write = string2write.."VM_FEET="..tostring(VM_FEET).."\n"
			string2write = string2write.."VM_HAND="..tostring(VM_HAND).."\n"
			string2write = string2write.."VM_HEAD="..tostring(VM_HEAD).."\n"
			string2write = string2write.."VM_LEGS="..tostring(VM_LEGS).."\n"
			string2write = string2write.."VM_NECK="..tostring(VM_NECK).."\n"
			string2write = string2write.."VM_OFFHAND="..tostring(VM_OFFHAND).."\n"
			string2write = string2write.."VM_ONEHAND="..tostring(VM_ONEHAND).."\n"
			string2write = string2write.."VM_RING="..tostring(VM_RING).."\n"
			string2write = string2write.."VM_SHOULDERS="..tostring(VM_SHOULDERS).."\n"
			string2write = string2write.."VM_TWOHAND="..tostring(VM_TWOHAND).."\n"
			string2write = string2write.."VM_WAIST="..tostring(VM_WAIST).."\n"
			d(filewrite(eso_vendormanager.profilepath ..filename..".lua",string2write))

	else
		ml_error("You need to enter a new Filename first!!")
	end
		if(isnew ==true)then
			gVMprofile = gVMnewname
			Settings.ESOMinion.gVMprofile = gVMnewname
			 eso_vendormanager.UpdateProfiles()
			 gVMnewname = ""
			 Settings.ESOMinion.gVMprofile = ""
		end
		
end

function eso_vendormanager.UpdateCurrentProfileData()

--Read all datas from the profile in directory
    if ( gVMprofile ~= nil and gVMprofile ~= "" and gVMprofile ~= "None" ) then


        local profile = fileread(eso_vendormanager.profilepath..gVMprofile..".lua")
        if ( TableSize(profile) > 0) then
            local unsortedItemList = {}			
            local newitem = {}            
			local i, line = next (profile)
			local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")

				
				if ( line ) then   
					while i and line do
						local _, key, value = string.match(line, "(%w+)_(%w+)=(.*)")
					
						if ( key and value ) then
							value = string.gsub(value, "\r", "")																			
								newitem = {}
							if ( key == "NAME" )then 
						    newitem = value
							 table.insert(unsortedItemList,tonumber(i),newitem)
								elseif ( key == "ATRASH" )then VM_ATRASH = tonumber(value)
								elseif ( key == "ANORMAL" )then VM_ANORMAL = tonumber(value)
								elseif ( key == "AMAGIC" )then VM_AMAGIC = tonumber(value)
								elseif ( key == "AARCANE" )then VM_AARCANE = tonumber(value)
								elseif ( key == "AARTEFACT" )then VM_AARTEFACT = tonumber(value)
								elseif ( key == "ANORMAL" )then VM_ANORMAL = tonumber(value)
								elseif ( key == "WTRASH" )then VM_WTRASH = tonumber(value)
								elseif ( key == "WNORMAL" )then VM_WNORMAL = tonumber(value)
								elseif ( key == "WMAGIC" )then VM_WMAGIC = tonumber(value)
								elseif ( key == "WARCANE" )then VM_WARCANE = tonumber(value)
								elseif ( key == "WARTEFACT" )then VM_WARTEFACT = tonumber(value)
								elseif ( key == "FTRASH" )then VM_FTRASH = tonumber(value)
								elseif ( key == "FNORMAL" )then VM_FNORMAL = tonumber(value)
								elseif ( key == "FMAGIC" )then VM_FMAGIC = tonumber(value)
								elseif ( key == "FARCANE" )then VM_FARCANE = tonumber(value)
								elseif ( key == "FARTEFACT" )then VM_FARTEFACT = tonumber(value)
								elseif ( key == "ADDITIVE" )then VM_ADDITIVE = tonumber(value)
								elseif ( key == "ALCHEMYBASE" )then VM_ALCHEMYBASE = tonumber(value)
								elseif ( key == "ENCHANTRUNE" )then VM_ENCHANTRUNE = tonumber(value)
								elseif ( key == "REAGENT" )then VM_REAGENT = tonumber(value)
								elseif ( key == "RAWMATERIAL" )then VM_RAWMATERIAL = tonumber(value)
								elseif ( key == "RECIPE" )then VM_RECIPE = tonumber(value)
								elseif ( key == "INGREDIENT" )then VM_INGREDIENT = tonumber(value)
								elseif ( key == "PPOTIONS" )then VM_PPOTIONS = tonumber(value)
								elseif ( key == "COLLECTIBLE" )then VM_COLLECTIBLE = tonumber(value)
								elseif ( key == "COSTUME" )then VM_COSTUME = tonumber(value)
								elseif ( key == "DRINK" )then VM_DRINK = tonumber(value)
								elseif ( key == "LOCKPICK" )then VM_LOCKPICK = tonumber(value)
								elseif ( key == "LURE" )then VM_LURE = tonumber(value)
								elseif ( key == "SOULGEM" )then VM_SOULGEM = tonumber(value)
								elseif ( key == "SPICE" )then VM_SPICE = tonumber(value)
								elseif ( key == "STYLEMAT" )then VM_STYLEMAT = tonumber(value)
								elseif ( key == "ITEMTRASH" )then VM_ITEMTRASH = tonumber(value)
								elseif ( key == "TROPHY" )then VM_TROPHY = tonumber(value)
								elseif ( key == "GLYPHARMOR" )then VM_GLYPHARMOR = tonumber(value)
								elseif ( key == "GLYPHWEAPON" )then VM_GLYPHWEAPON = tonumber(value)
								elseif ( key == "GLYPHJEWELRY" )then VM_GLYPHJEWELRY = tonumber(value)
								elseif ( key == "CHEST" )then VM_CHEST = tonumber(value)
								elseif ( key == "FEET" )then VM_FEET = tonumber(value)
								elseif ( key == "HAND" )then VM_HAND = tonumber(value)
								elseif ( key == "HEAD" )then VM_HEAD = tonumber(value)
								elseif ( key == "LEGS" )then VM_LEGS = tonumber(value)
								elseif ( key == "NECK" )then VM_NECK = tonumber(value)
								elseif ( key == "OFFHAND" )then VM_OFFHAND = tonumber(value)
								elseif ( key == "ONEHAND" )then VM_ONEHAND = tonumber(value)
								elseif ( key == "RING" )then VM_RING = tonumber(value)
								elseif ( key == "SHOULDERS" )then VM_SHOULDERS = tonumber(value)
								elseif ( key == "TWOHAND" )then VM_TWOHAND = tonumber(value)
								elseif ( key == "WAIST" )then VM_WAIST = tonumber(value)
							end

						else
							ml_error("Error loading inputline:")
						end				
						i, line = next (profile,i)
					end
				end
				
				
				for i = 0,TableSize(unsortedItemList),1 do	
					if (unsortedItemList[i] ~= nil ) then						
						eso_vendormanager.CreateNewItemEntry(unsortedItemList[i])
					end
				end		
      
        else
            d("Profile is empty..")			
        end		
    else
		gVMprofile = "None"
    end
end




function eso_vendormanager.CreateNewItemEntry(item)	
	if (item ~= nil ) then
		if (item ~= "" ) then
		local myitems = gWhiteList_listitems
		
	myitems = myitems..","..item
		gWhiteList_listitems = myitems
		table.insert(eso_vendormanager.WhiteL,TableSize(Settings.ESOMinion.gInventory)+1,item)
		end
	end

end  


function eso_vendormanager.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do

		if ( k == "gVMprofile" ) then					
			GUI_DeleteGroup(eso_vendormanager.MainWindow.Name,"ProfileItems")
			eso_vendormanager.WhiteL = {}
			Settings.ESOMinion.gWhiteList = "None"
			gWhiteList_listitems = ""
			eso_vendormanager.UpdateCurrentProfileData()
			Settings.ESOMinion.gVMprofile = tostring(v)
		elseif (k == "gEnableLog" or
			k == "VM_ATRASH" or
			k == "VM_ANORMAL" or	
			k == "VM_AMAGIC" or
			k == "VM_AARCANE" or
			k == "VM_AARTEFACT" or
			k == "VM_WTRASH" or
			k == "VM_WNORMAL" or	
			k == "VM_WMAGIC" or
			k == "VM_WARCANE" or
			k == "VM_WARTEFACT" or
			k == "VM_FTRASH" or
			k == "VM_FNORMAL" or	
			k == "VM_FMAGIC" or
			k == "VM_FARCANE" or
			k == "VM_FARTEFACT" or
			k == "VM_ADDITIVE" or
			k == "VM_PPOTIONS" or	
			k == "VM_ENCHANTRUNE" or
			k == "VM_REAGENT" or
			k == "VM_RAWMATERIAL" or
			k == "VM_RECIPE" or
			k == "VM_INGREDIENT" or
			k == "VM_COLLECTIBLE" or
			k == "VM_COSTUME" or
			k == "VM_DRINK" or
			k == "VM_LOCKPICK" or
			k == "VM_LURE" or
			k == "VM_SPICE" or
			k == "VM_SOULGEM" or
			k == "VM_STYLEMAT" or
			k == "VM_ITEMTRASH" or
			k == "VM_TROPHY" or
			k == "VM_GLYPHARMOR" or
			k == "VM_GLYPHWEAPON" or
			k == "VM_GLYPHJEWELRY" or
			k == "VM_CHEST" or
			k == "VM_FEET" or
			k == "VM_HAND" or
			k == "VM_HEAD" or
			k == "VM_LEGS" or
			k == "VM_NECK" or
			k == "VM_OFFHAND" or
			k == "VM_RING" or
			k == "VM_SHOULDERS" or
			k == "VM_TWOHAND" or
			k == "VM_WAIST"
			

		)						
		then
			Settings.ESOMinion[tostring(k)] = v
		end
		GUI_RefreshWindow(eso_vendormanager.MainWindow.Name)
	end
end
function eso_vendormanager.ToggleMenu()
	if (eso_vendormanager.visible) then
		GUI_WindowVisible(eso_vendormanager.MainWindow.Name,false)	
		
		eso_vendormanager.visible = false
	else
		local wnd = GUI_GetWindowInfo("MinionBot")	
		GUI_MoveWindow( eso_vendormanager.MainWindow.Name, wnd.x+wnd.width,wnd.y) 
		GUI_WindowVisible(eso_vendormanager.MainWindow.Name,true)	
		eso_vendormanager.visible = true
	end
end



RegisterEventHandler("VendorManager.toggle", eso_vendormanager.ToggleMenu)
RegisterEventHandler("GUI.Update",eso_vendormanager.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",eso_vendormanager.ModuleInit)