-- Handles autoequip
-----------
eso_autoequip = {}
eso_autoequip.MainWindow = { Name = GetString("AutoEquipManager"), x = 350, y = 50, w = 250, h = 550}
eso_autoequip.visible = false
function eso_autoequip.moduleinit()


	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enableEquip"),"gAutoEquip",GetString("settings"))
	GUI_NewWindow(eso_autoequip.MainWindow.Name,eso_autoequip.MainWindow.x,eso_autoequip.y,eso_autoequip.MainWindow.w,eso_autoequip.MainWindow.h,"",true)
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("armor"),"AE_ARMOR","Armor")
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("aearmornormal"),"AE_ARMORN","Armor")
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("aelegendary"),"AE_ARMORL","Armor")
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("aeartefact"),"AE_ARMORA","Armor")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aechest"),"AE_CHEST","Armor","Heavy,Medium,Light,Warlock,Necromancer")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aebonus"),"AE_CHESTBONUS","Armor",",None,Of Magicka,Of Stamina,Of Health")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aefeets"),"AE_FEETS","Armor","Heavy,Medium,Light")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aebonus"),"AE_FEETSBONUS","Armor",",None,Of Magicka,Of Stamina,Of Health")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aehands"),"AE_HANDS","Armor","Heavy,Medium,Light")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aebonus"),"AE_HANDSBONUS","Armor",",None,Of Magicka,Of Stamina,Of Health")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aehead"),"AE_HEAD","Armor","Heavy,Medium,Light,Warlock,Necromancer")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aebonus"),"AE_HEADBONUS","Armor",",None,Of Magicka,Of Stamina,Of Health")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aelegs"),"AE_LEGS","Armor","Heavy,Medium,Light,Necromancer")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aebonus"),"AE_LEGSBONUS","Armor",",None,Of Magicka,Of Stamina,Of Health")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aeshoulders"),"AE_SHOULDERS","Armor","Heavy,Medium,Light,Necromancer")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aebonus"),"AE_SHOULDERSBONUS","Armor",",None,Of Magicka,Of Stamina,Of Health")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aewaist"),"AE_WAIST","Armor","Heavy,Medium,Light")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aebonus"),"AE_WAISTBONUS","Armor",",None,Of Magicka,Of Stamina,Of Health")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aering1"),"AE_RING1","Armor","Magicka,Stamina,Warlock")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aering2"),"AE_RING2","Armor","Magicka,Stamina,Warlock")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aeneck"),"AE_NECK","Armor","Magicka,Stamina,Warlock")
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("weapon"),"AE_WEAPON","Weapon")
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("aeweaponnormal"),"AE_WEAPONN","Weapon")
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("aelegendary"),"AE_WEAPONN","Weapon")
	GUI_NewCheckbox(eso_autoequip.MainWindow.Name,GetString("aeartefact"),"AE_WEAPONA","Weapon")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aeoffhand"),"AE_OFFHAND","Weapon","None,Shield")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aeonehand"),"AE_ONEHAND","Weapon","None,1hAxe,1hSword,1hHammer,Dagger,All1HandedMelee")
	GUI_NewComboBox(eso_autoequip.MainWindow.Name,GetString("aetwohand"),"AE_TWOHAND","Weapon","None,Bow,2hHammer,2hSword,Staff,2hAxe,All2HandedMelee")
	
	
	if ( Settings.ESOMinion.gAutoEquip == nil ) then
		Settings.ESOMinion.gAutoEquip = "0"
	end
		if ( Settings.ESOMinion.AE_ARMOR == nil ) then
		Settings.ESOMinion.AE_ARMOR = "1"
	end
	if ( Settings.ESOMinion.AE_CHEST == nil ) then
		Settings.ESOMinion.AE_CHEST =  "Light"
	end
	if ( Settings.ESOMinion.AE_FEETS == nil ) then
		Settings.ESOMinion.AE_FEETS = "Light"
	end
	if ( Settings.ESOMinion.AE_HANDS == nil ) then
		Settings.ESOMinion.AE_HANDS = "Light"
	end
	if ( Settings.ESOMinion.AE_HEAD == nil ) then
		Settings.ESOMinion.AE_HEAD = "Light"
	end
	if ( Settings.ESOMinion.AE_LEGS == nil ) then
		Settings.ESOMinion.AE_LEGS = "Light"
	end
	if ( Settings.ESOMinion.AE_SHOULDERS == nil ) then
		Settings.ESOMinion.AE_SHOULDERS = "Light"
	end
	if ( Settings.ESOMinion.AE_WAIST == nil ) then
		Settings.ESOMinion.AE_WAIST = "Light"
	end
	if ( Settings.ESOMinion.AE_RING1 == nil ) then
		Settings.ESOMinion.AE_RING1 = "Magicka"
	end
	if ( Settings.ESOMinion.AE_RING2 == nil ) then
		Settings.ESOMinion.AE_RING2 = "Magicka"
	end
	if ( Settings.ESOMinion.AE_NECK == nil ) then
		Settings.ESOMinion.AE_NECK = "Magicka"
	end
	if ( Settings.ESOMinion.AE_WEAPON == nil ) then
		Settings.ESOMinion.AE_WEAPON = "1"
	end
	if ( Settings.ESOMinion.AE_OFFHAND == nil ) then
		Settings.ESOMinion.AE_OFFHAND = "None"
	end
	if ( Settings.ESOMinion.AE_ONEHAND == nil ) then
		Settings.ESOMinion.AE_ONEHAND= "None"
	end
	if ( Settings.ESOMinion.AE_TWOHAND == nil ) then
		Settings.ESOMinion.AE_TWOHAND = "None"
	end
	if ( Settings.ESOMinion.AE_ARMORL == nil ) then
		Settings.ESOMinion.AE_ARMORL = "0"
	end
	if ( Settings.ESOMinion.AE_ARMORA == nil ) then
		Settings.ESOMinion.AE_ARMORA= "1"
	end
	if ( Settings.ESOMinion.AE_WEAPONL == nil ) then
		Settings.ESOMinion.AE_WEAPONL = "0"
	end
	if ( Settings.ESOMinion.AE_WEAPONA == nil ) then
		Settings.ESOMinion.AE_WEAPONA= "1"
	end
	if ( Settings.ESOMinion.AE_CHESTBONUS == nil ) then
		Settings.ESOMinion.AE_CHESTBONUS= "None"
	end
	if ( Settings.ESOMinion.AE_FEETSBONUS == nil ) then
		Settings.ESOMinion.AE_FEETSBONUS= "None"
	end
	if ( Settings.ESOMinion.AE_HANDSBONUS == nil ) then
		Settings.ESOMinion.AE_HANDSBONUS= "None"
	end
	if ( Settings.ESOMinion.AE_HEADBONUS == nil ) then
		Settings.ESOMinion.AE_HEADBONUS= "None"
	end
	if ( Settings.ESOMinion.AE_LEGSBONUS == nil ) then
		Settings.ESOMinion.AE_LEGSBONUS= "None"
	end
	if ( Settings.ESOMinion.AE_SHOULDERSBONUS == nil ) then
		Settings.ESOMinion.AE_SHOULDERSBONUS= "None"
	end
	if ( Settings.ESOMinion.AE_WAISTBONUS == nil ) then
		Settings.ESOMinion.AE_WAISTBONUS= "None"
	end
	if ( Settings.ESOMinion.AE_ARMORN == nil ) then
		Settings.ESOMinion.AE_ARMORN= "1"
	end

	if ( Settings.ESOMinion.AE_WEAPONN== nil ) then
		Settings.ESOMinion.AE_WEAPONN = "1"
	end


	gAutoEquip = Settings.ESOMinion.gAutoEquip
	AE_ARMOR = Settings.ESOMinion.AE_ARMOR 
	AE_CHEST = Settings.ESOMinion.AE_CHEST 
	AE_FEETS = Settings.ESOMinion.AE_FEETS 
	AE_HANDS = Settings.ESOMinion.AE_HANDS 
	AE_HEAD = Settings.ESOMinion.AE_HEAD
	AE_LEGS = Settings.ESOMinion.AE_LEGS
	AE_SHOULDERS = Settings.ESOMinion.AE_SHOULDERS
	AE_WAIST = Settings.ESOMinion.AE_WAIST
	AE_RING1  = Settings.ESOMinion.AE_RING1
	AE_RING2  = Settings.ESOMinion.AE_RING2
	AE_NECK = Settings.ESOMinion.AE_NECK
	AE_WEAPON = Settings.ESOMinion.AE_WEAPON
	AE_OFFHAND = Settings.ESOMinion.AE_OFFHAND
	AE_ONEHAND = Settings.ESOMinion.AE_ONEHAND
	AE_TWOHAND = Settings.ESOMinion.AE_TWOHAND
	AE_ARMORA = Settings.ESOMinion.AE_ARMORA
	AE_ARMORL = Settings.ESOMinion.AE_ARMORL
	AE_WEAPONA = Settings.ESOMinion.AE_WEAPONA
	AE_WEAPONL = Settings.ESOMinion.AE_WEAPONL
	AE_CHESTBONUS = Settings.ESOMinion.AE_CHESTBONUS
	AE_FEETSBONUS = Settings.ESOMinion.AE_FEETSBONUS
	AE_HANDSBONUS = Settings.ESOMinion.AE_HANDSBONUS
	AE_HEADBONUS = Settings.ESOMinion.AE_HEADBONUS
	AE_LEGSBONUS = Settings.ESOMinion.AE_LEGSBONUS
	AE_SHOULDERSBONUS = Settings.ESOMinion.AE_SHOULDERSBONUS
	AE_WAISTBONUS = Settings.ESOMinion.AE_WAISTBONUS
	AE_ARMORN = Settings.ESOMinion.AE_ARMORN
	AE_WEAPONN = Settings.ESOMinion.AE_WEAPONN
	

	GUI_WindowVisible(eso_autoequip.MainWindow.Name,false)
	
	slotchest = g("EQUIP_SLOT_CHEST")  --2
	slotfeets = g("EQUIP_SLOT_FEET") --9
	slothand = g("EQUIP_SLOT_HAND") --16
	slothead = g("EQUIP_SLOT_HEAD") --0
	slotlegs = g("EQUIP_SLOT_LEGS") --8
	slotneck = g("EQUIP_SLOT_NECK") --1
	slotoffhand = g("EQUIP_SLOT_OFF_HAND") --5
	slotring1 = g("EQUIP_SLOT_RING1") --11
	slotring2 = g("EQUIP_SLOT_RING2") --12
	slotshoulders = g("EQUIP_SLOT_SHOULDERS") --3
	slottrinket1 = g("EQUIP_SLOT_TRINKET1") --13
	slottrinket2 = g("EQUIP_SLOT_TRINKET2") --14
	slotwaist = g("EQUIP_SLOT_WAIST") --6
	slotwrist = g("EQUIP_SLOT_WRIST") --7
	slotmainhand = g("EQUIP_SLOT_MAIN_HAND") --4
	
	lastequip = 0   --timer for the inventory check
	

end
RegisterEventHandler("Module.Initalize",eso_autoequip.moduleinit)


function eso_autoequip.guivarupdate(Event, NewVals, OldVals)

	
	for k,v in pairs(NewVals) do
		if (k == "gAutoEquip" or
			k == "AE_ARMOR" or
			k == "AE_CHEST" or
			k == "AE_HANDS" or
			k == "AE_HEAD" or
			k == "AE_LEGS" or
			k == "AE_FEETS" or
			k == "AE_SHOULDERS" or
			k == "AE_WAIST" or
			k == "AE_RING1" or
			k == "AE_RING2" or
			k == "AE_WEAPON" or
			k == "AE_OFFHAND" or
			k == "AE_ONEHAND" or
			k == "AE_TWOHAND" or
			k == "AE_ARMORA" or
			k == "AE_ARMORL" or
			k == "AE_WEAPONA" or
			k == "AE_CHESTBONUS" or
			k == "AE_FEETSBONUS" or
			k == "AE_HANDSBONUS" or
			k == "AE_HEADBONUS" or
			k == "AE_LEGSBONUS" or
			k == "AE_WAISTBONUS" or
			k == "AE_SHOULDERSBONUS" or
			k == "AE_ARMORN" or
			k == "AE_WEAPONN" or
			k == "AE_WEAPONL"
		)						
		then
			Settings.ESOMinion[tostring(k)] = v

		end
	end
	GUI_RefreshWindow(eso_autoequip.MainWindow.Name)
end
RegisterEventHandler("GUI.Update",eso_autoequip.guivarupdate)


function eso_autoequip.HandleAutoEquip()
	if ( ml_global_information.running ) then
		if(tonumber(gAutoEquip) ==1) then
			ml_log("Checking for new items")
			eso_autoequip.AutoEquip()
		end
	end
end

----- --------
--------------
c_autoequip = inheritsFrom( ml_cause )
e_autoequip = inheritsFrom( ml_effect )
c_autoequip.wait = 20000

 
function c_autoequip:evaluate()
      if ( (ml_global_information.Now) >= (lastequip + c_autoequip.wait + math.random(0,10000))) then
			if((Player.iscasting == false) and (isInCombat() == false))then
				lastequip =  ml_global_information.Now
				return true
			end
      end
      return false
end
 
function e_autoequip:execute()
ml_log("e_autoequip.. ")
	eso_autoequip.HandleAutoEquip()
	ml_global_information.Wait(500)
end

function isInCombat()
local player = "player"
	if(e("IsUnitInCombat("..player..")")) then
		return true
	else
	return false
	end

end


function getARMORNype(bagId,slotId)
    local icon = e("GetItemInfo("..bagId..","..slotId..")")
    if (string.find(icon, "heavy")) then
      return g("ARMORNYPE_HEAVY")
    elseif string.find(icon,"medium") then
        return g("ARMORNYPE_MEDIUM")
    elseif string.find(icon,"light") then
       return g("ARMORNYPE_LIGHT")
    else
        return g("ARMORNYPE_NONE")
    end
end


function getWEAPONNype(bagId,slotId)
    local icon =  e("GetItemInfo("..bagId..","..slotId..")")
    
    if (string.find(icon, "1hsword")) then
      return g("WEAPONNYPE_SWORD")
    elseif string.find(icon,"2hsword") then
        return g("WEAPONNYPE_TWO_HANDED_SWORD")
    elseif string.find(icon,"1haxe") then
        return g("WEAPONNYPE_AXE")
    elseif string.find(icon,"2haxe") then
        return g("WEAPONNYPE_TWO_HANDED_AXE")
    elseif string.find(icon,"1hhammer") then
        return g("WEAPONNYPE_HAMMER")
    elseif string.find(icon,"2hhammer") then
        return g("WEAPONNYPE_TWO_HANDED_HAMMER")
    elseif string.find(icon,"dagger") then
        return g("WEAPONNYPE_DAGGER")
    elseif string.find(icon,"shield") then
        return g("WEAPONNYPE_SHIELD")
    elseif string.find(icon,"bow") then
        return g("WEAPONNYPE_BOW")
    elseif string.find(icon,"staff") then
        return g("WEAPONNYPE_FIRE_STAFF")
    else
        return g("WEAPONNYPE_NONE")
    end
end

function getArmorBonusType(bagID,slotID)

	local iname = e("GetItemName("..tostring(bagID)..","..tostring(slotID)..")")
	if(string.match(iname,"Warlock"))then
		return "Warlock"
	elseif(string.match(iname,"Necromancer"))then
		return "Necromancer"
	elseif(string.match(iname,"of stamina"))then
		return "Stamina"
	elseif(string.match(iname,"of health"))then
		return "Health"
	elseif(string.match(iname,"of magicka"))then
		return "Magicka"
	end

end

function getitemstat(slotID)
d(e("GetItemStatValue(0,"..tostring(slotID)..")"))
d(e("GetItemCondition(0,"..tostring(slotID)..")"))
end
function eso_autoequip.getAccessoryStat(linkitem)

local color, id ,random1,itemlevel,statbonustype =string.match(tostring(linkitem),"(%w+):item:(%w+):(%w+):(%w+):(%w+):")

return statbonustype
--bonus 45870 = Magicka type
--bonus 45871 = Stamina type

end

function eso_autoequip.getItemLevel(linkitem)

local color, id ,random1,itemlevel,statbonustype =string.match(tostring(linkitem),"(%w+):item:(%w+):(%w+):(%w+):(%w+):")

return itemlevel

end


--------

function eso_autoequip.AutoEquip()

	local InventoryList = {}
	local args = { e("GetBagInfo(1)")}    
	local numArgs = #args
	local InventoryMax = args[2]
	local i = 0
	local v = 0
		while(i < tonumber(InventoryMax)) do
				local item = {}
				if(e("GetItemName(1,"..tostring(i)..")") ~= "") then

					item.itemtype = e("GetItemType(1,"..tostring(i)..")")
					item.ArmorKind = getARMORNype(1,i)
					item.WeaponKind = getWEAPONNype(1,i)
					local argsItemQ = {e("GetItemInfo( 1,"..tostring(i)..")") } 
					local numArgsItemQ = #argsItemQ
					item.EquipType = argsItemQ[6]
					item.quality = argsItemQ[8] 
					item.statvalue = e("GetItemStatValue(1,"..tostring(i)..")")
					item.bagslot = i
					itemlink = e("GetItemLink(1,"..tostring(i)..",1)")

					item.statbonustype =  eso_autoequip.getAccessoryStat(itemlink)
					item.itemlevel = eso_autoequip.getItemLevel(itemlink)
					if((item.ArmorKind ~= 0) or (item.WeaponKind ~= 0 ) or(item.EquipType ==g("EQUIP_TYPE_NECK")) or (item.EquipType == g("EQUIP_TYPE_RING")) or (item.EquipType == g("EQUIP_TYPE_OFF_HAND"))) then 
					table.insert(InventoryList,TableSize(InventoryList)+1,item)
						v = v + 1
					end
				end	
				i = i + 1
		end		
			
				local EquippedList = {}    -- yes i know !
				local itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotchest..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotchest..")")
				local argsItemQEQ = {e("GetItemInfo(0,"..slotchest..")") } 
				local numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8]
				itemEQ.EquipType = argsItemQEQ[6]
				local itemEQlink = e("GetItemLink(0,"..slotchest..",1)")
				local EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel		
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end				
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
						
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotfeets..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotfeets..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotfeets..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotfeets..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slothand..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slothand..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slothand..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slothand..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slothead..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slothead..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slothead..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slothead..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotlegs..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotlegs..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotlegs..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotlegs..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotneck..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotneck..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotneck..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotneck..",1)")
				itemEQ.statbonustype =  eso_autoequip.getAccessoryStat(itemEQlink)	
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotoffhand..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotoffhand..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotoffhand..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotoffhand..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotring1..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotring1..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotring1..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotring1..",1)")
				itemEQ.statbonustype =  eso_autoequip.getAccessoryStat(itemEQlink)
				itemEQlink = e("GetItemLink(0,"..slotring1..",1)")				
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotring2..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotring2..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotring2..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotring2..",1)")
				itemEQ.statbonustype =  eso_autoequip.getAccessoryStat(itemEQlink)	
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotshoulders..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotshoulders..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotshoulders..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotshoulders..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slottrinket1..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slottrinket1..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slottrinket1..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slottrinket1..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slottrinket2..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slottrinket2..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slottrinket2..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slottrinket2..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotwaist..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotwaist..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotwaist..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotwaist..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotwrist..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotwrist..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotwrist..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8] 
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotwrist..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)
				
				itemEQ = {}
				itemEQ.itemtype = e("GetItemType(0,"..slotmainhand..")")
				itemEQ.statvalue = e("GetItemStatValue(0,"..slotmainhand..")")
				argsItemQEQ = {e("GetItemInfo(0,"..slotmainhand..")") } 
				numArgsItemQEQ = #argsItemQEQ
				itemEQ.quality = argsItemQEQ[8]
				itemEQ.EquipType = argsItemQEQ[6]
				itemEQlink = e("GetItemLink(0,"..slotmainhand..",1)")
				EQitemlevel = eso_autoequip.getItemLevel(itemEQlink)
				itemEQ.itemlevel = EQitemlevel	
				if (itemEQ.itemlevel == nil)then
					itemEQ.itemlevel = 0
				end				
				table.insert(EquippedList,TableSize(EquippedList)+1,itemEQ)

			
				if( TableSize(InventoryList ) > 0) then
					local c,inventoryWA = next (InventoryList)
					while c and inventoryWA do
						if(e("IsEquipable(1,"..tostring(inventoryWA.bagslot)..")")) then
							if((inventoryWA.itemtype == g("ITEMTYPE_WEAPON") and ( (AE_WEAPON == 1) or (AE_WEAPON == "1")))) then
									if(AE_TWOHAND ~= "None") then
										if(AE_TWOHAND == "Staff") then
											if(inventoryWA.WeaponKind == g("WEAPONNYPE_FIRE_STAFF"))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_TWOHAND == "2hHammer") then
											if(inventoryWA.WeaponKind == g("WEAPONNYPE_TWO_HANDED_HAMMER"))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_TWOHAND == "2hAxe") then
											if(inventoryWA.WeaponKind == g("WEAPONNYPE_TWO_HANDED_AXE"))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_TWOHAND == "Bow") then
											if(inventoryWA.WeaponKind == g("WEAPONNYPE_BOW"))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_TWOHAND == "2hSword") then
											if(inventoryWA.WeaponKind == g("WEAPONNYPE_TWO_HANDED_SWORD"))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_TWOHAND == "All2HandedMelee") then
											if((inventoryWA.WeaponKind == g("WEAPONNYPE_TWO_HANDED_SWORD")) or( inventoryWA.WeaponKind == g("WEAPONNYPE_TWO_HANDED_AXE")) or (inventoryWA.WeaponKind == g("WEAPONNYPE_TWO_HANDED_HAMMER")))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										end
									end
									if(AE_ONEHAND ~= "None") then
										if(AE_ONEHAND == "1hSword") then
											if(inventoryWA.WeaponKind == g("WEAPONNYPE_SWORD"))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_ONEHAND == "1hAxe") then
											if(inventoryWA.WeaponKind == g("WEAPONNYPE_AXE"))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
												
										elseif(AE_ONEHAND == "1hHammer") then
												if(inventoryWA.WeaponKind == g("WEAPONNYPE_HAMMER"))then
													if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
														if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
															if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														end
													end
												end
										elseif(AE_ONEHAND == "Dagger") then
												if(inventoryWA.WeaponKind == g("WEAPONNYPE_DAGGER"))then
													if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
														if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
															if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														end
													end
												end
										elseif(AE_ONEHAND == "All1HandedMelee") then
											if((inventoryWA.WeaponKind == g("WEAPONNYPE_DAGGER")) or( inventoryWA.WeaponKind == g("WEAPONNYPE_HAMMER")) or (inventoryWA.WeaponKind == g("WEAPONNYPE_AXE")) or(inventoryWA.WeaponKind == g("WEAPONNYPE_SWORD")))then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[15].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[15].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end			
										end
									end
									
							end
							if(inventoryWA.EquipType == g("EQUIP_TYPE_OFF_HAND"))then
								if(AE_OFFHAND == "Shield")then
									if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[7].itemlevel)) then
										if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[7].statvalue) )then
											if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
												e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
											elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_WEAPONN == 1) or ( AE_WEAPONN == "1") )) then
												e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
											elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_WEAPONA == 1) or ( AE_WEAPONA == "1") )) then 
												e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
											elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_WEAPONL == 1) or ( AE_WEAPONL == "1") )) then
												e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
											end
										end
									end
								end
							end
							if((inventoryWA.itemtype == g("ITEMTYPE_ARMOR") and ((AE_ARMOR == 1) or (AE_ARMOR == "1")))) then	
								if(inventoryWA.EquipType == g("EQUIP_TYPE_CHEST"))then
									if(AE_CHEST == "Light")then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[1].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[1].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_CHESTBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_CHESTBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_CHESTBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_CHESTBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_CHEST == "Medium") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_MEDIUM")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[1].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[1].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_CHESTBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_CHESTBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_CHESTBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_CHESTBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_CHEST == "Heavy") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_HEAVY")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[1].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[1].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_CHESTBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_CHESTBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_CHESTBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_CHESTBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")													
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_CHEST == "Warlock") then	
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT"))then			
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Warlock")then
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[1].itemlevel) )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
									elseif(AE_CHEST == "Necromancer") then	
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT"))then			
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Necromancer")then
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[1].itemlevel) )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
										
									end
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_FEET"))then
									if(AE_FEETS == "Light")then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[2].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[2].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_FEETSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_FEETSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_FEETSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_FEETSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_FEETS == "Medium") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_MEDIUM")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[2].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[2].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_FEETSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_FEETSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_FEETSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_FEETSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_FEETS == "Heavy") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_HEAVY")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[2].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[2].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_FEETSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_FEETSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_FEETSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_FEETSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									end
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_HAND"))then
									if(AE_HANDS == "Light")then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[3].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[3].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and(inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and (inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL"))) then
														if((AE_HANDSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HANDSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HANDSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_HANDSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														d("wtf")
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_HANDS == "Medium") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_MEDIUM")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[3].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[3].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and(inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and (inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL"))) then
														if((AE_HANDSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HANDSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HANDSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_HANDSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_HANDS == "Heavy") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_HEAVY")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[3].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[3].statvalue) )then
													--d(inventoryWA.quality)
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and (inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and (inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL"))) then
														if((AE_HANDSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HANDSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HANDSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_HANDSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														d("wtf")
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									end
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_HEAD"))then
									if(AE_HEAD == "Light")then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[4].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[4].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_HEADBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HEADBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HEADBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_HEADBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_HEAD == "Medium") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_MEDIUM")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[4].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[4].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_HEADBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HEADBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HEADBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_HEADBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_HEAD == "Heavy") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_HEAVY")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[4].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[4].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_HEADBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HEADBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_HEADBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_HEADBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_HEAD == "Warlock") then	
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT"))then			
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Warlock")then
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[4].itemlevel) )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
									elseif(AE_HEAD == "Necromancer") then	
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT"))then			
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Necromancer")then
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[4].itemlevel) )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
									end
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_LEGS"))then
									if(AE_LEGS == "Light")then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[5].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[5].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_LEGSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_LEGSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_LEGSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_LEGSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")	
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_LEGS == "Medium") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_MEDIUM")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[5].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[5].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_LEGSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_LEGSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_LEGSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_LEGSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")	
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_LEGS == "Heavy") then
										if(inventoryWA.ArmorKind == g("ARMORNYPE_HEAVY")) then
											if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[5].itemlevel)) then
												if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[5].statvalue) )then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
														if((AE_LEGSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_LEGSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((AE_LEGSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif(AE_LEGSBONUS == "None")then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")	
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
									elseif(AE_LEGS == "Necromancer") then	
										if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT"))then			
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Necromancer")then
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[5].itemlevel) )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
									end
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_NECK"))then
										if(AE_NECK == "Magicka")then
											if(inventoryWA.statbonustype == "45870") then  -- magicka stat bonus (not set items)
												local Inecklevel = tonumber(e("GetItemLevel(1,"..inventoryWA.bagslot..")"))
												local Enecklevel = tonumber(e("GetItemLevel(1,"..slotneck..")"))
												if(Inecklevel > Enecklevel) then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")))) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										elseif(AE_NECK == "Stamina")then
											if(inventoryWA.statbonustype == "45871") then  -- stamina stat bonus (not set items)
												local Inecklevel = tonumber(e("GetItemLevel(1,"..inventoryWA.bagslot..")"))
												local Enecklevel = tonumber(e("GetItemLevel(1,"..slotneck..")"))
												if(Inecklevel > Enecklevel) then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")))) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
											
											
										elseif(AE_NECK == "Warlock") then	
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Warlock")then
												if(Inecklevel > Enecklevel )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
										
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_RING"))then
										if(AE_RING1 == "Magicka")then
											if(inventoryWA.statbonustype == "45870") then  -- magicka stat bonus (not set items)
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[8].itemlevel)) then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")))) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										elseif(AE_RING1 == "Stamina")then
											if(inventoryWA.statbonustype == "45871") then  -- stamina stat bonus (not set items)
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[8].itemlevel)) then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")))) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										elseif(AE_RING1 == "Warlock") then	
										local Iringlevel = tonumber(e("GetItemLevel(1,"..inventoryWA.bagslot..")"))
										local Eringlevel = tonumber(e("GetItemLevel(1,"..slotring1..")"))
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Warlock")then
												if(Iringlevel > Eringlevel )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
										if(AE_RING2 == "Magicka")then
											if(inventoryWA.statbonustype == "45870") then  -- magicka stat bonus (not set items)
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[9].itemlevel)) then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")))) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										elseif(AE_RING2 == "Stamina")then
											if(inventoryWA.statbonustype == "45871") then  -- stamina stat bonus (not set items)
												if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[9].itemlevel)) then
													if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")))) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										elseif(AE_RING2 == "Warlock") then	
											local Iringlevel = tonumber(e("GetItemLevel(1,"..inventoryWA.bagslot..")"))
											local Eringlevel = tonumber(e("GetItemLevel(1,"..slotring2..")"))
											if(getArmorBonusType(1,inventoryWA.bagslot) == "Warlock")then
												if(Iringlevel > Eringlevel )then
													e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
												end
											end
										end
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_SHOULDERS"))then
										if(AE_SHOULDERS == "Light")then
											if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT")) then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[10].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[10].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															if((AE_SHOULDERSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_SHOULDERSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_SHOULDERSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif(AE_SHOULDERSBONUS == "None")then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_SHOULDERS == "Medium") then
											if(inventoryWA.ArmorKind == g("ARMORNYPE_MEDIUM")) then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[10].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[10].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															if((AE_SHOULDERSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_SHOULDERSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_SHOULDERSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif(AE_SHOULDERSBONUS == "None")then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_SHOULDERS == "Heavy") then
											if(inventoryWA.ArmorKind == g("ARMORNYPE_HEAVY")) then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[10].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[10].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															if((AE_SHOULDERSBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_SHOULDERSBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_SHOULDERSBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif(AE_SHOULDERSBONUS == "None")then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_SHOULDERS == "Necromancer") then	
											if(inventoryWA.ArmorKind == g("ARMORNYPE_LIGHT"))then			
												if(getArmorBonusType(1,inventoryWA.bagslot) == "Necromancer")then
													if(tonumber(inventoryWA.itemlevel) > tonumber(EquippedList[10].itemlevel) )then
														e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
													end
												end
											end
										end
								elseif(inventoryWA.EquipType == g("EQUIP_TYPE_WAIST"))then
										if(AE_WAIST == "Light")then
											if(inventoryWA.WA == g("ARMORNYPE_LIGHT")) then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[13].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[13].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															if((AE_WAISTBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_WAISTBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_WAISTBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif(AE_WAISTBONUS == "None")then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_WAIST == "Medium") then
											if(inventoryWA.ArmorKind == g("ARMORNYPE_MEDIUM")) then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[13].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[13].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															if((AE_WAISTBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_WAISTBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_WAISTBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif(AE_WAISTBONUS == "None")then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										elseif(AE_WAIST == "Heavy") then
											if(inventoryWA.ArmorKind == g("ARMORNYPE_HEAVY")) then
												if(tonumber(inventoryWA.itemlevel) >= tonumber(EquippedList[13].itemlevel)) then
													if(tonumber(inventoryWA.statvalue) > tonumber(EquippedList[13].statvalue) )then
														if((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT")) and((inventoryWA.quality ~= g("ITEM_QUALITY_ARTIFACT"))) and ((inventoryWA.quality ~= g("ITEM_QUALITY_NORMAL")))) then
															if((AE_WAISTBONUS == "Of Magicka") and (getArmorBonusType(1,inventoryWA.bagslot) == "Magicka") )then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_WAISTBONUS == "Of Stamina") and (getArmorBonusType(1,inventoryWA.bagslot) == "Stamina"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif((AE_WAISTBONUS == "Of Health") and (getArmorBonusType(1,inventoryWA.bagslot) == "Health"))then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															elseif(AE_WAISTBONUS == "None")then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
															end
														elseif((inventoryWA.quality == g("ITEM_QUALITY_NORMAL")) and (( AE_ARMORN == 1) or ( AE_ARMORN == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_ARTIFACT")) and (( AE_ARMORA == 1) or ( AE_ARMORA == "1") )) then 
															e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														elseif((inventoryWA.quality == g("ITEM_QUALITY_LEGENDARY")) and (( AE_ARMORL == 1) or ( AE_ARMORL == "1") )) then
																e("EquipItem(1,"..tostring(inventoryWA.bagslot)..")")
														end
													end
												end
											end
										end
								end
							end
					end
					c, inventoryWA = next ( InventoryList ,c)
					end
				end	
			
		
end

function eso_autoequip.ToggleMenu()
	if (eso_autoequip.visible) then
		GUI_WindowVisible(eso_autoequip.MainWindow.Name,false)	
		
		eso_autoequip.visible = false
	else
		local wnd = GUI_GetWindowInfo("MinionBot")	
		GUI_MoveWindow( eso_autoequip.MainWindow.Name, wnd.x+wnd.width,wnd.y) 
		GUI_WindowVisible(eso_autoequip.MainWindow.Name,true)	
		eso_autoequip.visible = true
	end
end


RegisterEventHandler("autoequip.toggle", eso_autoequip.ToggleMenu)