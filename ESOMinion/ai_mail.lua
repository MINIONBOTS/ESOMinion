--:==========================================================================================================================
--: ESOMinion [Elder Scrolls Online]
--: Mail 2.1b (6.1.2014)
--:==========================================================================================================================
--: Standalone ESO Mailer
--:==========================================================================================================================

ai_mail={}

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
		
		if slots and tonumber(slots) > 0 then
			for i = slots, 1, -1 do
				local _,_,_,_,_,_,_,quality = e("GetItemInfo(1,"..tostring(i)..")")
				
				local itemtype 	 	 = e("GetItemType(1,"..tostring(i)..")")
				local itemname 	 	 = e("GetItemName(1,"..tostring(i)..")")
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
									return true
								end
							end
						end
					end
					
					return false
				end
				
				if tonumber(itemtype) ~= 0 and not bound and canattachitem and filtermatch(itemtype, quality) then
					if (tonumber(stack) >= tonumber(gMailStackSize)) or (tonumber(stack) >= tonumber(maxstack)) or (not isstackable) then
					
						e("QueueItemAttachment(1,"..tostring(i)..","..tostring(mailslot)..")")
						table.insert(queue,stack.."x "..itemname)
						mailslot = mailslot + 1
						attachments = attachments + 1
						
						if attachments == 6 then
							break
						end
					end
				end
			end
		end

		if attachments == 6 then
			local gold 		= tonumber(e("GetCurrentMoney()"))
			local postage 	= tonumber(e("GetQueuedMailPostage()"))
			
			if gold and postage and (gold > postage) then
				local recipient = gMailRecipient
				local subject = gMailSubject
				local body = ""

				for index, item in pairs(queue) do
					d("QueuedItemAttachment() " ..item)
				end
				e("RequestOpenMailbox()")
				d("RequestOpenMailbox()")
				e("SendMail("..recipient..","..subject..","..body..")")
				d("SendMail("..recipient..","..subject..","..body..")")
			else
				d("SendMail(): Not enough gold for postage.")
			end
		else
			e("ClearQueuedMail()")
			--d("ClearQueuedMail()")
		end

		e("CloseMailbox()")
		--d("CloseMailbox()")
	end
end

--:==========================================================================================================================
--: Initialize
--:==========================================================================================================================

function ai_mail.Initialize()
	ai_mail.time = 0
	ai_mail.throttle = 10000
	
	GUI_NewButton(ml_global_information.MainWindow.Name,"MailManager","ai_mail.toggle","Managers")
	ai_mail.window = {"MailManager",270,50,220,350}
	ai_mail.visible = true
	
	GUI_NewWindow(unpack(ai_mail.window))
	GUI_NewCheckbox("MailManager","MailEnabled","gMailEnabled","Settings")
	GUI_NewField("MailManager","  Recipient","gMailRecipient","Settings")
	GUI_NewField("MailManager","  Subject","gMailSubject","Settings")
	GUI_NewNumeric("MailManager","  StackSize","gMailStackSize","Settings","0","100")
	GUI_NewComboBox("MailManager","  Filter","gEditMailFilter","Settings","")
	
	if Settings.ESOMinion.gMailEnabled == nil then
		Settings.ESOMinion.gMailEnabled = "0"
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
		elseif key == "gMailEnabled"
			or key == "gMailRecipient"
			or key == "gMailSubject"
			or key == "gMailStackSize"
		then
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
	if ml_global_information.running and ((time - ai_mail.time) > ai_mail.throttle) then
		ai_mail.time = time
		ai_mail:Mail()
	end
end

--:==========================================================================================================================
--: Register Events
--:==========================================================================================================================

RegisterEventHandler("Module.Initalize", ai_mail.Initialize)
RegisterEventHandler("ai_mail.toggle", ai_mail.ToggleGUI)
RegisterEventHandler("Gameloop.Update",ai_mail.GameloopUpdate)
RegisterEventHandler("GUI.Update",ai_mail.VarUpdate)
