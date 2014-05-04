--****************************************************************************
-- ai_vendor
--****************************************************************************
ai_vendor={}
ai_vendor.queue = nil

--****************************************************************************
-- Vendor Open Event
--****************************************************************************
RegisterForEvent("EVENT_OPEN_STORE", true)
RegisterEventHandler("GAME_EVENT_OPEN_STORE",
	function(...)
		if 	ml_global_information.running and
			ai_vendor.queue == nil and 
			e("IsPlayerInteractingWithObject()")
		then
			d("vendor opened")
			ai_vendor.queue = ai_vendor:CreateNewQueue()
		end
	end
)

--****************************************************************************
-- Vendor Close Event
--****************************************************************************
RegisterForEvent("EVENT_CLOSE_STORE", true)	
RegisterEventHandler("GAME_EVENT_CLOSE_STORE",
	function(...)
		if 	ml_global_information.running then
			d("vendor closed")
			ai_vendor.queue = nil
		end
	end
)

--****************************************************************************
-- Vendor Queue
--****************************************************************************
function ai_vendor:CreateNewQueue()
	local queue = {}
	queue.last = 0
	queue.throttle = 2500
	queue.finished = false
				
	function queue:run()
	
		queue.now = ml_global_information.Now
		queue.time = (queue.now - queue.last > queue.throttle)
		
		if not queue.time then
			return
		end
		
		queue.last = queue.now

		if not queue.repaired then
			d("Repairing items")
			e("RepairAll()")
			queue.repaired = true
			return
		end

		if not queue.autoequip and tonumber(gAutoEquip) == 1 then
			d("Auto equipping superior items")
			eso_autoequip.AutoEquip()
			queue.autoequip = true	
			return
		end
		
		if not queue.marked and tonumber(gVendor) == 1 then
			d("Marking items")
			ai_vendor.markitems()
			queue.marked = true	
			return
		end
		
		if not queue.vendored and tonumber(gVendor) == 1 and e("HasAnyJunk(1)") then
			d("Selling items")
			e("SellAllJunk()")
			queue.vendored = true	
			return
		end

		if ml_global_information.running then
			d("Closing vendor window")
			e("EndInteraction(15)")
			return
		end
		
		d("Vendor queue completed")
		queue.finished = true
		ai_vendor.queue = nil
		
	end
	
	return queue
end

--****************************************************************************
-- Mark Items
--****************************************************************************
function ai_vendor:markitems()
	local junk = "true"
	local args = { e("GetBagInfo(1)")}    
	local numArgs = #args
	local InventoryMax = args[2]
	local i = 0
	
	while(i <= tonumber(InventoryMax)) do
		
		if( (e("IsItemJunk(1,"..tostring(i)..")")) == false) then
			local argsItemQ = {e("GetItemInfo( 1,"..tostring(i)..")") } 
			local numArgsItemQ = #argsItemQ
			local quality = argsItemQ[8]  
			local itemType = e("GetItemFilterTypeInfo(1,"..tostring(i)..")")
			local itemToCheck = e("GetItemName(1,"..tostring(i)..")")
			local itemKind = e("GetItemType(1,"..tostring(i)..")")
			local link = e("GetItemLink(1,"..tostring(i)..",0)")
			local argsEquipType = { e("GetItemLinkInfo("..tostring(link)..")")}    
			local numArgsEquipType = #argsEquipType
			local value = argsEquipType[2]
			local EquipType = argsEquipType[4]
			d(EquipType)
			--Check if the item is in whitelist first
			if(ai_vendor:isWhiteListed(itemToCheck) == false) then
				if(tonumber(itemType) == 2) then  --it is Armor
					if((VM_ATRASH ~= "0") or ( VM_ANORMAL ~= "0") or ( VM_AMAGIC ~= "0") or ( VM_AARTEFACT ~= "0")) then			
						-- Armor Trash
						if(tonumber(quality) == 0) then		
							if((VM_ATRASH == "1") or (tonumber(VM_ATRASH) == 1)) then					
								if( (EquipType == g("EQUIP_TYPE_CHEST")) and((VM_CHEST == "1") or (tonumber(VM_CHEST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_FEET")) and((VM_FEET == "1") or (tonumber(VM_FEET) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HAND")) and((VM_HAND == "1") or (tonumber(VM_HAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and((VM_HEAD == "1") or (tonumber(VM_HEAD) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and((VM_LEGS == "1") or (tonumber(VM_LEGS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_NECK")) and((VM_NECK == "1") or (tonumber(VM_NECK) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_RING")) and((VM_RING == "1") or (tonumber(VM_RING) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and((VM_SHOULDERS == "1") or (tonumber(VM_SHOULDERS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and((VM_WAIST == "1") or (tonumber(VM_WAIST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and((VM_OFFHAND == "1") or (tonumber(VM_OFFHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end	
								
							end
						end
						-- Armor Normal	
						if(tonumber(quality) == 1) then
							if((VM_ANORMAL == "1") or (tonumber(VM_ANORMAL) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_CHEST")) and((VM_CHEST == "1") or (tonumber(VM_CHEST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_FEET")) and((VM_FEET == "1") or (tonumber(VM_FEET) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HAND")) and((VM_HAND == "1") or (tonumber(VM_HAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and((VM_HEAD == "1") or (tonumber(VM_HEAD) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and((VM_LEGS == "1") or (tonumber(VM_LEGS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_NECK")) and((VM_NECK == "1") or (tonumber(VM_NECK) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_RING")) and((VM_RING == "1") or (tonumber(VM_RING) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and((VM_SHOULDERS == "1") or (tonumber(VM_SHOULDERS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and((VM_WAIST == "1") or (tonumber(VM_WAIST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and((VM_OFFHAND == "1") or (tonumber(VM_OFFHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end

							end
						end
						-- Armor Magic	
						if(tonumber(quality) == 2) then
							if((VM_AMAGIC == "1") or (tonumber(VM_AMAGIC) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_CHEST")) and((VM_CHEST == "1") or (tonumber(VM_CHEST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_FEET")) and((VM_FEET == "1") or (tonumber(VM_FEET) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HAND")) and((VM_HAND == "1") or (tonumber(VM_HAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and((VM_HEAD == "1") or (tonumber(VM_HEAD) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and((VM_LEGS == "1") or (tonumber(VM_LEGS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_NECK")) and((VM_NECK == "1") or (tonumber(VM_NECK) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_RING")) and((VM_RING == "1") or (tonumber(VM_RING) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and((VM_SHOULDERS == "1") or (tonumber(VM_SHOULDERS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and((VM_WAIST == "1") or (tonumber(VM_WAIST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and((VM_OFFHAND == "1") or (tonumber(VM_OFFHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end
							end
						end
						-- Armor Arcane
						if(tonumber(quality) == 3) then
							if((VM_AARCANE == "1") or (tonumber(VM_AARCANE) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_CHEST")) and((VM_CHEST == "1") or (tonumber(VM_CHEST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_FEET")) and((VM_FEET == "1") or (tonumber(VM_FEET) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HAND")) and((VM_HAND == "1") or (tonumber(VM_HAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and((VM_HEAD == "1") or (tonumber(VM_HEAD) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and((VM_LEGS == "1") or (tonumber(VM_LEGS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_NECK")) and((VM_NECK == "1") or (tonumber(VM_NECK) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_RING")) and((VM_RING == "1") or (tonumber(VM_RING) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and((VM_SHOULDERS == "1") or (tonumber(VM_SHOULDERS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and((VM_WAIST == "1") or (tonumber(VM_WAIST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and((VM_OFFHAND == "1") or (tonumber(VM_OFFHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end
							end
						end
						-- Armor Artefact
						if(tonumber(quality) == 4) then
							if((VM_AARTEFACT == "1") or (tonumber(VM_AARTEFACT) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_CHEST")) and((VM_CHEST == "1") or (tonumber(VM_CHEST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_FEET")) and((VM_FEET == "1") or (tonumber(VM_FEET) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HAND")) and((VM_HAND == "1") or (tonumber(VM_HAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and((VM_HEAD == "1") or (tonumber(VM_HEAD) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and((VM_LEGS == "1") or (tonumber(VM_LEGS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_NECK")) and((VM_NECK == "1") or (tonumber(VM_NECK) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_RING")) and((VM_RING == "1") or (tonumber(VM_RING) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and((VM_SHOULDERS == "1") or (tonumber(VM_SHOULDERS) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and((VM_WAIST == "1") or (tonumber(VM_WAIST) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and((VM_OFFHAND == "1") or (tonumber(VM_OFFHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								
								end
							end
						end
					end
				end		
				if(tonumber(itemType) == 1) then -- it is Weapon
					if((VM_WTRASH ~= "0") or ( VM_WNORMAL ~= "0") or ( VM_WMAGIC ~= "0") or ( VM_WARTEFACT ~= "0")) then
						--Weapon Trash			
						if(tonumber(quality) == 0) then
							if((VM_WTRASH == "1") or  (tonumber(VM_WTRASH) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and((VM_TWOHAND == "1") or (tonumber(VM_TWOHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and((VM_ONEHAND == "1") or (tonumber(VM_ONEHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end
							end
						end
						-- Weapon Normal
						if(tonumber(quality) == 1) then
							if((VM_WNORMAL == "1") or  (tonumber(VM_WNORMAL) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and((VM_TWOHAND == "1") or (tonumber(VM_TWOHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and((VM_ONEHAND == "1") or (tonumber(VM_ONEHAND) ==1)))then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end
							end
						end
						-- Weapon Magic
						if(tonumber(quality) == 2) then
							if((VM_WMAGIC == "1") or (tonumber(VM_WMAGIC) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and((VM_TWOHAND == "1") or (tonumber(VM_TWOHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")") 
								elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and((VM_ONEHAND == "1") or (tonumber(VM_ONEHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end
							end
						end
						-- Weapon Arcane
						if(tonumber(quality) == 3) then
							if((VM_WARCANE == "1") or (tonumber(VM_WARCANE) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and((VM_TWOHAND == "1") or (tonumber(VM_TWOHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")") 
								elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and((VM_ONEHAND == "1") or (tonumber(VM_ONEHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end
							end
						end
						-- Weapon Artefact
						if(tonumber(quality) == 4) then
							if((VM_WARTEFACT == "1") or(tonumber(VM_WARTEFACT) == 1)) then
								if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and((VM_TWOHAND == "1") or (tonumber(VM_TWOHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and((VM_ONEHAND == "1") or (tonumber(VM_ONEHAND) ==1))) then
									e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
								end
							end
						end
					end
				end	
				
				if((itemKind == g("ITEMTYPE_INGREDIENT")) and ((VM_INGREDIENT == "1") or (tonumber(VM_INGREDIENT) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_ADDITIVE")) and ((VM_ADDITIVE== "1") or (tonumber(VM_ADDITIVE) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")	 
				elseif((itemKind == g("ITEMTYPE_ALCHEMY_BASE")) and ((VM_ALCHEMYBASE == "1") or (tonumber(VM_ALCHEMYBASE) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_ENCHANTING_RUNE")) and ((VM_ENCHANTRUNE == "1") or (tonumber(VM_ENCHANTRUNE) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_STYLE_MATERIAL")) and ((VM_STYLEMAT == "1") or (tonumber(VM_STYLEMAT) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_REAGENT")) and ((VM_REAGENT == "1") or (tonumber(VM_REAGENT) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_RECIPE")) and ((VM_RECIPE == "1") or (tonumber(VM_RECIPE) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_RAW_MATERIAL") and (VM_RAWMATERIAL == "1") or (tonumber(VM_RAWMATERIAL) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_BLACKSMITHING_RAW_MATERIAL") and (VM_RAWMATERIAL == "1") or (tonumber(VM_RAWMATERIAL) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_WOODWORKING_RAW_MATERIAL") and (VM_RAWMATERIAL == "1") or (tonumber(VM_RAWMATERIAL) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_CLOTHIER_RAW_MATERIAL") and (VM_RAWMATERIAL == "1") or (tonumber(VM_RAWMATERIAL) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_POTION")) and ((VM_PPOTIONS == "1") or (tonumber(VM_PPOTIONS) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_DRINK")) and ((VM_DRINK == "1") or (tonumber(VM_DRINK) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_GLYPH_ARMOR")) and ((VM_GLYPHARMOR == "1") or (tonumber(VM_GLYPHARMOR) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_GLYPH_WEAPON")) and ((VM_GLYPHWEAPON == "1") or (tonumber(VM_GLYPHWEAPON) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_GLYPH_JEWELRY")) and ((VM_GLYPHJEWELRY == "1") or (tonumber(VM_GLYPHJEWELRY) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_TRASH")) and ((VM_ITEMTRASH == "1") or (tonumber(VM_ITEMTRASH) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_COLLECTIBLE")) and ((VM_COLLECTIBLE == "1") or (tonumber(VM_COLLECTIBLE) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_COSTUME")) and ((VM_COSTUME == "1") or (tonumber(VM_COSTUME) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_LOCKPICK")) and ((VM_LOCKPICK == "1") or (tonumber(VM_LOCKPICK) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_LURE")) and ((VM_LURE == "1") or (tonumber(VM_LURE) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_SOUL_GEM")) and ((VM_SOULGEM == "1") or (tonumber(VM_SOULGEM) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_SPICE")) and ((VM_SPICE == "1") or (tonumber(VM_SPICE) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif((itemKind == g("ITEMTYPE_TROPHY")) and ((VM_TROPHY == "1") or (tonumber(VM_TROPHY) == 1))) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
				elseif(itemKind == g("ITEMTYPE_FOOD")) then
					if(tonumber(quality) == 0) then
						if((VM_FTRASH == "1") or (tonumber(VM_FTRASH) == 1)) then	
							e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
						end
					end
					if(tonumber(quality) == 1) then
						if((VM_FNORMAL == "1") or (tonumber(VM_FNORMAL) == 1)) then	
							e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
						end
					end
					if(tonumber(quality) == 2) then
						if((VM_FMAGIC == "1") or (tonumber(VM_FMAGIC) == 1)) then	
							e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
						end
					end
					if(tonumber(quality) == 3) then
						if((VM_FARCANE == "1") or (tonumber(VM_FARCANE) == 1)) then	
							e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
						end
					end
					if(tonumber(quality) == 4) then
						if((VM_FARTEFACT== "1") or (tonumber(VM_FARTEFACT) == 1)) then	
							e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
						end
					end
				end
			end
		end
		i = i + 1
	end

end
--****************************************************************************
-- Select Conversation Option
--****************************************************************************
function ai_vendor:selectvendorconv()
local convcount = tonumber(e("GetChatterOptionCount()"))
local args = nil
local numArgs = nil
local convstring = nil
local i = 0
		while(i < convcount+1) do
		
			args = { e("GetChatterOption("..tostring(i)..")")}    
			numArgs = #args
			convstring = args[1]
			convoption = args[3]
			d(convstring)
			if(string.match(tostring(convstring),"Store"))then
				e("SelectChatterOption("..tostring(i)..")")
				break
			end
			i = i+1
		end
		
	
end


--****************************************************************************
-- Check if equipped gear is broken
--****************************************************************************
function ai_vendor:CheckDurability()
local convcount = tonumber(e("GetChatterOptionCount()"))
local args = nil
local numArgs = nil
local convstring = nil
local i = 0
		while(i < convcount+1) do
		
			args = { e("GetChatterOption("..tostring(i)..")")}    
			numArgs = #args
			convstring = args[1]
			convoption = args[3]
			d(convstring)
			if(string.match(tostring(convstring),"Store"))then
				e("SelectChatterOption("..tostring(i)..")")
				break
			end
			i = i+1
		end
		
	
end

--****************************************************************************
-- White List
--****************************************************************************
function ai_vendor:isWhiteListed(inventoryitem)
	local itemtest = tostring(inventoryitem)
	if ( TableSize(eso_vendormanager.WhiteL) > 0) then			
		local i,item = next ( eso_vendormanager.WhiteL)
		while i and item do	
			if( item == inventoryitem) then
			return true
			end
			i,item = next (eso_vendormanager.WhiteL,i)
		end
	end
	return false
end

--****************************************************************************
-- Initialize
--****************************************************************************
RegisterEventHandler("Module.Initalize",
	function()
		if ( Settings.ESOMinion.gVendor == nil ) then
			Settings.ESOMinion.gVendor = "0"
		end
		if ( Settings.ESOMinion.gRepair == nil ) then
			Settings.ESOMinion.gRepair = "1"
		end		
		
		GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enabled"),"gVendor",GetString("vendorSettings"))
		GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enableRepair"),"gRepair",GetString("vendorSettings"))	
		gVendor = Settings.ESOMinion.gVendor
		gRepair = Settings.ESOMinion.gRepair
	end
)

--****************************************************************************
-- Cause/Effect
--****************************************************************************
c_movetovendor = inheritsFrom( ml_cause )
e_movetovendor = inheritsFrom( ml_effect )
e_movetovendor.vendorMarker = nil

function c_movetovendor:evaluate()
	if( gVendor == "1" and ml_global_information.Player_InventoryNearlyFull)then
		local VList = EntityList("nearest,isvendor,onmesh")
		if ( TableSize( VList ) > 0 ) then			
			return true
		end
		if ( e_movetovendor.vendorMarker == nil ) then
			local VMList = ml_marker_mgr.GetList(GetString("vendorMarker"), false, false)
			if ( TableSize(VMList) > 0 ) then				
				local bestmarker = nil
				local bestdist = 9999999
				local name,marker = next ( VMList )
				while (name and marker) do
					local mPos = marker:GetPosition()
					if ( Distance3D( mPos.x,mPos.y,mPos.z,ml_global_information.Player_Position.x,ml_global_information.Player_Position.y,ml_global_information.Player_Position.z) < bestdist) then
						bestdist = Distance3D( mPos.x,mPos.y,mPos.z,ml_global_information.Player_Position.x,ml_global_information.Player_Position.y,ml_global_information.Player_Position.z)
						bestmarker = marker
					end
					name,maker = next ( VMList,name )
				end
				if ( marker ) then
					e_movetovendor.vendorMarker = marker
					return true
				end				
			end
		else
			return true
		end
	end
	e_movetovendor.vendorMarker = nil
	return false
end

function e_movetovendor:execute()
ml_log("e_gotovendor")
	local VList = EntityList("nearest,isvendor,maxdistance=85")
		if ( VList and TableSize( VList ) > 0 ) then	
			
			id,vendor = next (VList)
			if ( id and vendor ) then
				local pPos = Player.pos
				local tPos = vendor.pos
				if (pPos) then
					local dist = Distance3D( tPos.x,tPos.y,tPos.z,pPos.x,pPos.y,pPos.z)
					ml_log("("..tostring(math.floor(dist))..")")
					if ( dist > 4 ) then
						local navResult = tostring(Player:MoveTo( tPos.x,tPos.y,tPos.z,2,false,true,true))
						if (tonumber(navResult) < 0) then		
							ml_error("e_movetovendor result: "..tonumber(navResult))
							return ml_log(false)							
						end	
						return ml_log(true)
					end
					if(vendor.distance < 3) then
						Player:Stop()
						Player:Interact(vendor.id)
						ai_vendor:selectvendorconv()
						return ml_log(true)
					end									
				end
			end
		else
			if ( e_movetovendor.vendorMarker ~= nil ) then
				local mPos = e_movetovendor.vendorMarker:GetPosition()
				ml_log( "Moving to vendorMarker ")
				local navResult = tostring(Player:MoveTo( mPos.x,mPos.y,mPos.z,10,false,true,true))
				if (tonumber(navResult) < 0) then		
					ml_error("e_movetovendorMarker result: "..tonumber(navResult))
					return ml_log(false)							
				end	
				return ml_log(true)	
				
			end		
		end
	return ml_log(false)
end

--****************************************************************************
-- Game Loop
--****************************************************************************
RegisterEventHandler("Gameloop.Update",
	function()
		if 	ml_global_information.running and
			ai_vendor.queue and
			not ai_vendor.queue.finished
		then
			ai_vendor.queue:run()
		end
	end
)
