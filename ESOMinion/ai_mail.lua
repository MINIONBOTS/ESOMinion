--:==========================================================================================================================
--: ESOMinion [Elder Scrolls Online]
--: Mail 2.1b (6.1.2014)
--:==========================================================================================================================
--: Standalone ESO Mailer
--:==========================================================================================================================

ai_mail={}

function getArmorType(bagId,slotId)
    local icon = e("GetItemInfo("..bagId..","..slotId..")")
    if (string.find(icon, "heavy")) then
		return g("ARMORTYPE_HEAVY")
    elseif string.find(icon,"medium") then
        return g("ARMORTYPE_MEDIUM")
    elseif string.find(icon,"light") then
		return g("ARMORTYPE_LIGHT")
    else
        return g("ARMORTYPE_NONE")
    end
end

function getWeaponType(bagId,slotId)
    local icon =  e("GetItemInfo("..bagId..","..slotId..")")
    
    if (string.find(icon, "1hsword")) then
		return g("WEAPONTYPE_SWORD")
    elseif string.find(icon,"2hsword") then
        return g("WEAPONTYPE_TWO_HANDED_SWORD")
    elseif string.find(icon,"1haxe") then
        return g("WEAPONTYPE_AXE")
    elseif string.find(icon,"2haxe") then
        return g("WEAPONTYPE_TWO_HANDED_AXE")
    elseif string.find(icon,"1hhammer") then
        return g("WEAPONTYPE_HAMMER")
    elseif string.find(icon,"2hhammer") then
        return g("WEAPONTYPE_TWO_HANDED_HAMMER")
    elseif string.find(icon,"dagger") then
        return g("WEAPONTYPE_DAGGER")
    elseif string.find(icon,"shield") then
        return g("WEAPONTYPE_SHIELD")
    elseif string.find(icon,"bow") then
        return g("WEAPONTYPE_BOW")
    elseif string.find(icon,"staff") then
        return g("WEAPONTYPE_FIRE_STAFF")
    else
        return g("WEAPONTYPE_NONE")
    end
end

function ai_mail:Mail()
	if  gMailEnabled and gMailEnabled == "1" and
		gMailRecipient and gMailRecipient ~= "" and
		gMailStackSize and tonumber(gMailStackSize) and
		not e("IsUnitInCombat(player)")
	then
		local bag,slots = e("GetBagInfo(1)")
		local mailslot = 1
		local mailslotmax = 6
		local attachments = 0
		local queue = {}
		ai_mail.done = true
		d("Doing Mails Now!")

		ai_mail.rand = math.random(10000,50000)

		if slots and tonumber(slots) > 0 then
			for i = slots, 1, -1 do
				local _,_,_,_,_,_,_,quality = e("GetItemInfo(1,"..tostring(i)..")")
				
				local itemtype 	 	 = e("GetItemType(1,"..tostring(i)..")")
				local itemname 	 	 = e("GetItemName(1,"..tostring(i)..")")
				local armorkind  	 = getArmorType(1,i)
				local weaponkind  	 = getWeaponType(1,i)
				local iteminfo		 = e("GetItemInfo(1,"..tostring(i)..")")
				local canattachitem  = e("CanQueueItemAttachment(1,"..tostring(i)..","..tostring(attachments+1)..")")
				local stack,maxstack = e("GetSlotStackSize(1,"..tostring(i)..")")
				local bound 		 = e("IsItemBound(1,"..tostring(i)..")")
				local isstackable	 =  (maxstack > 1)

				function filtermatch(itemtype, itemrarity)
					for group_index, group in ipairs(ai_mail.groups) do
						local types = group.types

						

							for type_index, type in pairs(types) do	
								if tonumber(itemtype) == type then
									local rarity = ai_mail.rarities[itemrarity]
									local var = "gMail".. tostring(group.name) .. tostring(rarity)

									if _G[var] and _G[var] == "1" then

										if gMailByType and gMailByType == "1" then
										--if it falls in one of the set filters, then check if it belongs to the type were currently sending
										--this checks can be done in a better way me thinks..
											if (ai_mail.typecount == 1 and (armorkind == g("ARMORTYPE_LIGHT") or armorkind == g("ARMORTYPE_MEDIUM"))) -- Clothing Stuff
												
												or (ai_mail.typecount == 2 and (armorkind == g("ARMORTYPE_HEAVY") or weaponkind == g("WEAPONTYPE_SWORD") -- Blacksmithing Stuff
													or weaponkind == g("WEAPONTYPE_TWO_HANDED_SWORD") or weaponkind == g("WEAPONTYPE_AXE") -- Blacksmithing Stuff
													or weaponkind == g("WEAPONTYPE_TWO_HANDED_AXE") or weaponkind == g("WEAPONTYPE_HAMMER") -- Blacksmithing Stuff
													or weaponkind == g("WEAPONTYPE_TWO_HANDED_HAMMER") or weaponkind == g("WEAPONTYPE_DAGGER"))) -- Blacksmithing Stuff
												
												or (ai_mail.typecount == 3 and (weaponkind == g("WEAPONTYPE_SHIELD") or weaponkind == g("WEAPONTYPE_BOW") -- Wood Stuff
													or weaponkind == g("WEAPONTYPE_FIRE_STAFF"))) -- Wood Stuff
												
												or (ai_mail.typecount == 4 and (tonumber(itemtype) == 31 or tonumber(itemtype) == 33)) -- Alchemy Mats
												
												or (ai_mail.typecount == 5 and (tonumber(itemtype) == 35 or tonumber(itemtype) == 36)) -- Blacksmithing Mats
												
												or (ai_mail.typecount == 6 and (tonumber(itemtype) == 37 or tonumber(itemtype) == 38)) -- Woodworking Mats
												
												or (ai_mail.typecount == 7 and (tonumber(itemtype) == 39 or tonumber(itemtype) == 40)) -- Clothier Mats
												
												or (ai_mail.typecount == 8 and (tonumber(itemtype) == 10 or tonumber(itemtype) == 29)) -- Provisioning Mats
												
												or (ai_mail.typecount == 9 and (tonumber(itemtype) ~= 1 and tonumber(itemtype) ~= 2 -- Everything Else
													and tonumber(itemtype) ~= 31 and tonumber(itemtype) ~= 33 -- Everything Else
													and not (tonumber(itemtype) > 34 and tonumber(itemtype) < 42))) -- Everything Else
											then
												return true
											end
										else
											return true
										end

									end
								end
							end
						
					end
					
					return false
				end
				
				-- if all checks are good then add the current item to our send queue
				if tonumber(itemtype) ~= 0 and not bound and canattachitem and filtermatch(itemtype, quality) then
					if (tonumber(stack) >= tonumber(gMailStackSize)) or (tonumber(stack) >= tonumber(maxstack)) or (not isstackable) then
						table.insert(queue,{slotid = i, iname = itemname, istack = stack}) -- the send queue
						attachments = attachments + 1	
						if attachments == 6 then
							break
						end
					end
				end
			end
		end

		-- send if more than two items are attach.. 
		if attachments > 2 then
			
			--loop through our send queue and attach them to our mail
			for index, item in pairs(queue) do
					local slotid = item["slotid"]
					local iname = item["iname"]
					local istack = item["istack"]
					e("QueueItemAttachment(1,"..tostring(slotid)..","..tostring(mailslot)..")")
					d("QueuedItemAttachment() "..tostring(istack).."X "..iname)
					mailslot = mailslot + 1
					if mailslot > 6 then
							break
					end
			end

			local gold 		= tonumber(e("GetCurrentMoney()"))
			local postage 	= tonumber(e("GetQueuedMailPostage()"))


			if gold and postage and (gold > postage) then
				local recipient = gMailRecipient
				local subject = gMailSubject
				local body = ""

				-- Set Subject For Each Type
				-- if (ai_mail.typecount == 1) then
				-- 	subject = subject.. " Cloth and Medium"
				-- elseif (ai_mail.typecount == 2) then
				-- 	subject = subject.. " Heavy"
				-- elseif (ai_mail.typecount == 3) then
				-- 	subject = subject.. " Wood Weapons"
				-- elseif (ai_mail.typecount == 4) then
				-- 	subject = subject.. " Alchemy Mats"
				-- elseif (ai_mail.typecount == 5) then
				-- 	subject = subject.. " Blacksmithing Mats"
				-- elseif (ai_mail.typecount == 6) then
				-- 	subject = subject.. " Woodworking Mats"
				-- elseif (ai_mail.typecount == 7) then
				-- 	subject = subject.. " Clothier Mats"
				-- elseif (ai_mail.typecount == 8) then
				-- 	subject = subject.. " Provisioning Stuff"
				-- elseif (ai_mail.typecount == 9) then
				-- 	subject = subject.. " Everything Else"
				-- end
 
				
				e("RequestOpenMailbox()")
				d("RequestOpenMailbox()")
				e("SendMail("..recipient..","..subject..","..body..")")
				d("SendMail("..recipient..","..subject..","..body..")")

			else
				d("SendMail(): Not enough gold for postage.")
			end
		else
			-- Not Enough Items Of The Current Type To Send! Try Next Item Type
			-- Set ai_mail.done to false so next mail is called straight away, unless this was the last type
			d("Not enough items items to send")
			ai_mail.typecount = ai_mail.typecount + 1
			ai_mail.done = false
			if ai_mail.typecount > 8 then
				ai_mail.typecount = 1
				ai_mail.done = true
			end
			e("ClearQueuedMail()")
			--d("ClearQueuedMail()")
		end

		e("CloseMailbox()")
		--d("CloseMailbox()")
	elseif e("IsUnitInCombat(player)") then
		ai_mail.done = false
	end
end

--:==========================================================================================================================
--: Initialize
--:==========================================================================================================================

function ai_mail.Initialize()
	ai_mail.time = 0
	ai_mail.throttle = 100000
	ai_mail.rand = math.random(10000,50000)
	ai_mail.done = false
	ai_mail.lasttime = 0
	ai_mail.typecount = 1


	GUI_NewButton(ml_global_information.MainWindow.Name,"MailManager","ai_mail.toggle","Managers")
	ai_mail.window = {"MailManager",270,50,220,350}
	ai_mail.visible = true
	
	GUI_NewWindow(unpack(ai_mail.window))
	GUI_NewCheckbox("MailManager","MailEnabled","gMailEnabled","Settings")
	GUI_NewCheckbox("MailManager","SendByType","gMailByType","Settings")
	GUI_NewField("MailManager","  Recipient","gMailRecipient","Settings")
	GUI_NewField("MailManager","  Subject","gMailSubject","Settings")
	GUI_NewNumeric("MailManager","  StackSize","gMailStackSize","Settings","0","100")
	GUI_NewComboBox("MailManager","  Filter","gEditMailFilter","Settings","")
	
	if Settings.ESOMinion.gMailEnabled == nil then
		Settings.ESOMinion.gMailEnabled = "0"
	end
	if Settings.ESOMinion.gMailByType == nil then
		Settings.ESOMinion.gMailByType = "0"
	end
	if Settings.ESOMinion.gMailRecipient == nil then
		Settings.ESOMinion.gMailRecipient = ""
	end
	if Settings.ESOMinion.gMailSubject == nil then
		Settings.ESOMinion.gMailSubject = ""
	end
	if Settings.ESOMinion.gMailStackSize == nil then
		Settings.ESOMinion.gMailStackSize = "100"
	end
	
	gMailEnabled = Settings.ESOMinion.gMailEnabled
	gMailByType = Settings.ESOMinion.gMailByType
	gMailRecipient = Settings.ESOMinion.gMailRecipient
	gMailSubject = Settings.ESOMinion.gMailSubject
	gMailStackSize = Settings.ESOMinion.gMailStackSize

	local li = "None"
	for group_index, group in ipairs(ai_mail.groups) do
		li = li .. "," .. tostring(group.name)

		for rarity_index, rarity in ipairs(ai_mail.rarities) do
			local var = "gMail".. tostring(group.name) .. tostring(rarity)
			if Settings.ESOMinion[var] == nil then
				Settings.ESOMinion[var] = "0"
			end
			_G[var] = Settings.ESOMinion[var]
		end
	end

	gEditMailFilter_listitems = li
	GUI_UnFoldGroup("MailManager","Settings")

	ai_mail.ToggleGUI()
end

--:=========================================================================================================================================
--: GUI Toggle
--:=========================================================================================================================================

function ai_mail.ToggleGUI()
	ai_mail.visible = not ai_mail.visible
	GUI_WindowVisible("MailManager",ai_mail.visible)
end

--:=========================================================================================================================================
--: GUI Update
--:=========================================================================================================================================

function ai_mail.VarUpdate(event,data,olddata)

	for key,value in pairs(data) do	
		if key == "gEditMailFilter" then
			--GUI_NewCheckbox("MailManager",  "  Normal (White)","gMail".. tostring(value) .."Normal", "Filter")
			GUI_DeleteGroup("MailManager", "Filter")
			
			if value and value ~= "None" then
				GUI_NewCheckbox("MailManager",  "  Normal (White)","gMail".. tostring(value) .."Normal", "Filter")
				GUI_NewCheckbox("MailManager",  "  Magic (Green)","gMail".. tostring(value) .."Magic", "Filter")
				GUI_NewCheckbox("MailManager",  "  Arcane (Blue)","gMail".. tostring(value) .."Arcane", "Filter")
				GUI_NewCheckbox("MailManager",  "  Artifact (Purple)","gMail".. tostring(value) .."Artifact", "Filter")
				GUI_NewCheckbox("MailManager",  "  Legendary (Yellow)","gMail".. tostring(value) .."Legendary", "Filter")
				_G["gMail".. tostring(value) .."Normal"] = Settings.ESOMinion["gMail".. tostring(value) .."Normal"]
				_G["gMail".. tostring(value) .."Magic"] = Settings.ESOMinion["gMail".. tostring(value) .."Magic"]
				_G["gMail".. tostring(value) .."Arcane"] = Settings.ESOMinion["gMail".. tostring(value) .."Arcane"]
				_G["gMail".. tostring(value) .."Artifact"] = Settings.ESOMinion["gMail".. tostring(value) .."Artifact"]
				_G["gMail".. tostring(value) .."Legendary"] = Settings.ESOMinion["gMail".. tostring(value) .."Legendary"]
				GUI_UnFoldGroup("MailManager", "Filter")
			end
		else
			Settings.ESOMinion[tostring(key)] = tostring(value)
		end
	end
end

--:=========================================================================================================================================
--: Data
--:=========================================================================================================================================

ai_mail.groups = {
	[1] = { name = "Weapons", 		types = {1} 				},
	[2] = { name = "Armor", 		types = {2} 				},
	[3] = { name = "Glyphs", 		types = {20,21,26} 			},
	[4] = { name = "Runes", 		types = {32} 				},
	[5] = { name = "Gatherables", 	types = {35,37,39,31,33} 	},
}

ai_mail.rarities = {
	[1] = "Normal",
	[2] = "Magic",
	[3] = "Arcane",
	[4] = "Artifact",
	[5] = "Legendary", 
}

ai_mail.types = {
	[0] = "ITEMTYPE_NONE",
	[1] = "ITEMTYPE_WEAPON",
	[2] = "ITEMTYPE_ARMOR",
	[3] = "ITEMTYPE_PLUG",
	[4] = "ITEMTYPE_FOOD",
	[5] = "ITEMTYPE_TROPHY",
	[6] = "ITEMTYPE_SIEGE",
	[7] = "ITEMTYPE_POTION",
	[8] = "ITEMTYPE_SCROLL",
	[9] = "ITEMTYPE_TOOL",
	[10] = "ITEMTYPE_INGREDIENT",
	[11] = "ITEMTYPE_ADDITIVE",
	[12] = "ITEMTYPE_DRINK",
	[13] = "ITEMTYPE_COSTUME",
	[14] = "ITEMTYPE_DISGUISE",
	[15] = "ITEMTYPE_TABARD",
	[16] = "ITEMTYPE_LURE",
	[17] = "ITEMTYPE_RAW_MATERIAL",
	[18] = "ITEMTYPE_CONTAINER",
	[19] = "ITEMTYPE_SOUL_GEM",
	[20] = "ITEMTYPE_GLYPH_WEAPON",
	[21] = "ITEMTYPE_GLYPH_ARMOR",
	[22] = "ITEMTYPE_LOCKPICK",
	[23] = "ITEMTYPE_WEAPON_BOOSTER",
	[24] = "ITEMTYPE_ARMOR_BOOSTER",
	[25] = "ITEMTYPE_ENCHANTMENT_BOOSTER",
	[26] = "ITEMTYPE_GLYPH_JEWELRY",
	[27] = "ITEMTYPE_SPICE",
	[28] = "ITEMTYPE_FLAVORING",
	[29] = "ITEMTYPE_RECIPE",
	[30] = "ITEMTYPE_POISON",
	[31] = "ITEMTYPE_REAGENT",
	[32] = "ITEMTYPE_ENCHANTING_RUNE",
	[33] = "ITEMTYPE_ALCHEMY_BASE",
	[34] = "ITEMTYPE_COLLECTIBLE",
	[35] = "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL",
	[36] = "ITEMTYPE_BLACKSMITHING_MATERIAL",
	[37] = "ITEMTYPE_WOODWORKING_RAW_MATERIAL",
	[38] = "ITEMTYPE_WOODWORKING_MATERIAL",
	[39] = "ITEMTYPE_CLOTHIER_RAW_MATERIAL",
	[40] = "ITEMTYPE_CLOTHIER_MATERIAL",
	[41] = "ITEMTYPE_BLACKSMITHING_BOOSTER",
	[42] = "ITEMTYPE_WOODWORKING_BOOSTER",
	[43] = "ITEMTYPE_CLOTHIER_BOOSTER",
	[44] = "ITEMTYPE_STYLE_MATERIAL",
	[45] = "ITEMTYPE_ARMOR_TRAIT",
	[46] = "ITEMTYPE_WEAPON_TRAIT",
	[47] = "ITEMTYPE_AVA_REPAIR",
	[48] = "ITEMTYPE_TRASH", 
}

--:==========================================================================================================================
--: Gameloop Update
--:==========================================================================================================================

function ai_mail.GameloopUpdate(event,time)

	if ml_global_information.running and (  ai_mail.done == false or  ((time - ai_mail.time) > (ai_mail.throttle  + ai_mail.rand)) ) then
		ai_mail.time = time
		ai_mail:Mail()
	else
		if (time > ai_mail.lasttime + 30000) then

		ai_mail.lasttime = time
		d("Next Mail : ".. tostring(((ai_mail.throttle  + ai_mail.rand)-(time - ai_mail.time))/60000))
		end
	end
end

--:==========================================================================================================================
--: Register Events
--:==========================================================================================================================

RegisterEventHandler("Module.Initalize", ai_mail.Initialize)
RegisterEventHandler("ai_mail.toggle", ai_mail.ToggleGUI)
RegisterEventHandler("Gameloop.Update",ai_mail.GameloopUpdate)
RegisterEventHandler("GUI.Update",ai_mail.VarUpdate)

--.------..------..------..------..------..------..------..------..------..------.
--|I.--. ||N.--. ||K.--. ||T.--. ||R.--. ||O.--. ||C.--. ||I.--. ||T.--. ||Y.--. |
--| (\/) || :(): || :/\: || :/\: || :(): || :/\: || :/\: || (\/) || :/\: || (\/) |
--| :\/: || ()() || :\/: || (__) || ()() || :\/: || :\/: || :\/: || (__) || :\/: |
--| '--'I|| '--'N|| '--'K|| '--'T|| '--'R|| '--'O|| '--'C|| '--'I|| '--'T|| '--'Y|
--`------'`------'`------'`------'`------'`------'`------'`------'`------'`------'
