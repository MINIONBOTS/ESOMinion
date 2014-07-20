--:===============================================================================================================
--: ESOMinion [Elder Scrolls Online]
--: Vendor 2.0a (7.19.2014) (work in progress)
--:===============================================================================================================

ai_vendor={}
ai_vendor.vendored = false
ai_vendor.debugging = false
	
--:===============================================================================================================
--: ai_vendor: SellItem
--:=============================================================================================================== 

function ai_vendor:SellItem(slot)

	local itemname 	 	 		= e("GetItemName(1,"..tostring(slot)..")")
	local itemtype				= e("GetItemType(1,"..tostring(slot)..")")
	local soulbound				= e("IsItemBound(1,"..tostring(slot)..")")
	local _,_,_,_,_,_,_,quality = e("GetItemInfo(1,"..tostring(slot)..")")
	local stack,maxstack 		= e("GetSlotStackSize(1,"..tostring(slot)..")")
	
	if itemtype and quality then
		if eso_vendormanager.profile
			and eso_vendormanager.profile.data
			and eso_vendormanager.profile.data[itemtype]
			and eso_vendormanager.profile.data[itemtype][quality]
		then
			if eso_vendormanager.profile.data[itemtype][quality] == true then
				d("Vendor: Selling Item " .. itemname)
				e("SellInventoryItem(1,"..tostring(slot)..","..tostring(stack)..")")
				return
			elseif quality == g("ITEM_QUALITY_TRASH") or 0 then
				d("Vendor: Marking Item " .. itemname .. " as Junk")
				e("SetItemIsJunk(1,"..tostring(slot)..",true)")
				return
			end
		end
	end
end

--:===============================================================================================================
--: cause/effect
--:===============================================================================================================  
--: TODO: split this in to seperate c/e

c_movetovendor = inheritsFrom(ml_cause)
e_movetovendor = inheritsFrom(ml_effect)
e_movetovendor.vendorMarker = nil
e_movetovendor.isvendoring = false

function c_movetovendor:evaluate()
	if e_movetovendor.isvendoring then
		return true
	end

	if 	(gVendor == "1" and ai_vendor:NeedToVendor()) or
		(gRepair == "1" and ai_vendor:NeedToRepair()) or
		ai_vendor.debugging == true
	then
		local vendor = EntityList("nearest,isvendor,onmesh")
		if ValidTable(vendor) then			
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

--: TODO: split this in to seperate c/e

e_movetovendor.merchantstep = 0
e_movetovendor.throttle = math.random(1000,2000)

function e_movetovendor:execute()
ml_log("e_gotovendor")
	e_movetovendor.throttle = math.random(1000,2000)
	local VList = EntityList("nearest,isvendor,onmesh,maxdistance=85")
		if ( VList and TableSize( VList ) > 0 ) then	
			
			id,vendor = next (VList)
			if ( id and vendor ) then
				local pPos = Player.pos
				local tPos = vendor.pos
				if (pPos) then
					local dist = Distance3D( tPos.x,tPos.y,tPos.z,pPos.x,pPos.y,pPos.z)
					ml_log("("..tostring(math.floor(dist))..")")
					
					if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
						ai_mount:Mount()
					elseif gUseMount == "1" and tonumber(gUseMountRange) > dist then
						ai_mount:Dismount()
					end
		
					if ( dist > 4 and tonumber(e("GetChatterOptionCount()"))==0) then
						local navResult = tostring(Player:MoveTo( tPos.x,tPos.y,tPos.z,2,false,true,true))
						if (tonumber(navResult) < 0) then		
							ml_error("e_movetovendor result: "..tonumber(navResult))
							return ml_log(false)							
						end	
						return ml_log(true)
					end
					if(vendor.distance <= 4 or tonumber(e("GetChatterOptionCount()")) > 0 or e("GetNumStoreItems()") > 0) then
						Player:Stop()
						
						-- I KNOW this should go in seperate cause & effects, but then a whole new task would also have to be written for vendoring, I'm waaay to lazy now
						
						-- If sell window is already open, sell & repair
						if ( e("GetNumStoreItems()") > 0 ) then
							
							e_movetovendor.isvendoring = true
							-- Repair
							if (e_movetovendor.merchantstep == 0) then
								e_movetovendor.merchantstep = 1
								if ( gRepair == "1" and ai_vendor:NeedToRepair()== true ) then
									d("Repairing items")
									e("RepairAll()")
									--ml_global_information.Wait(1000)
									return ml_log(true)
								end								
							end
							
							--Autoequip
							if (e_movetovendor.merchantstep == 1) then
								e_movetovendor.merchantstep = 2
								if ( gAutoEquip == "1" ) then
									d("Auto equipping superior items")
									eso_autoequip.AutoEquip()
									--ml_global_information.Wait(1000)
									return ml_log(true)
								end								
							end
							
							-- Mark Junk items
							--if (e_movetovendor.merchantstep == 2) then
							--	e_movetovendor.merchantstep = 3
							--	if ( gVendor == "1" ) then
							--		d("Marking items as junk")
							--		--ai_vendor.markitems()
							--		ml_global_information.Wait(1000)
							--		return ml_log(true)
							--	end								
							--end
							
							if e_movetovendor.merchantstep == 2 then
								if gVendor == "1" then
									if e_movetovendor.slotstocheck == nil then
										local slots = {}
										local bag,maxslots = e("GetBagInfo(1)")
										for slot = 1, maxslots do
											local itemtype = e("GetItemType(1,"..tostring(slot)..")")
											if itemtype > 0 then
												slots[slot] = true
											end
										end
										e_movetovendor.slotstocheck = slots
									end
									
									if ValidTable(e_movetovendor.slotstocheck) then
										local slot,check = next(e_movetovendor.slotstocheck)
										if slot and check then
											ai_vendor:SellItem(slot)
											e_movetovendor.slotstocheck[slot] = nil
											return ml_log(true)
										end
									end
								end
								e_movetovendor.merchantstep = 3
							end
							
							--Sell Items
							if (e_movetovendor.merchantstep == 3) then
								e_movetovendor.merchantstep = 4
								if ( gVendor == "1" and e("HasAnyJunk(1)") ) then
									d("Selling Junk Items")				
									e("SellAllJunk()")
									--ml_global_information.Wait(1000)
									return ml_log(true)
								end								
							end
							
							--Close Store
							if (e_movetovendor.merchantstep == 4) then
								e_movetovendor.merchantstep = 0
								e_movetovendor.isvendoring = false
								e_movetovendor.slotstocheck = nil
								ai_vendor.debugging = false
								d("Closing vendor window")
								e("EndInteraction(15)")								
								--ml_global_information.Wait(1000)
								return ml_log(true)
							end
							
							d("Bug ? Didnt handle merchant correctly..")
							return ml_log(false)
						end
						
						-- Open store when it is not yet opened
						local chatoptionscount = tonumber(e("GetChatterOptionCount()"))						
						if ( chatoptionscount == 0) then
							d("Interacting with Merchant..")
							Player:Interact(vendor.id)
							e_movetovendor.merchantstep = 0
						else
							-- switch to vendoring
							for index = 0,chatoptionscount do		
								local optionstring,optiontype = e("GetChatterOption("..tostring(index)..")")
								if optiontype == g("CHATTER_START_SHOP") then
									d("Selecting Merchant conversation option..")
									e("SelectChatterOption("..tostring(index)..")")
									break
								end
							end
						end
						--ml_global_information.Wait(1000)
						return ml_log(true)
					end									
				end
			end
		else
			if ( e_movetovendor.vendorMarker ~= nil ) then
				local mPos = e_movetovendor.vendorMarker:GetPosition()
				local pPos = Player.pos
				local dist = Distance3D( mPos.x,mPos.y,mPos.z,pPos.x,pPos.y,pPos.z)
				
				if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
					ai_mount:Mount()
				elseif gUseMount == "1" and dist < 5 then
					ai_mount:Dismount()
				end
				
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

--:===============================================================================================================
--: ai_vendor: NeedToRepair
--:===============================================================================================================  

function ai_vendor:NeedToRepair()
	local slots = EQUIP_SLOT
	for slot,index in pairs(slots) do
		local item,equipped	= e("GetEquippedItemInfo("..tostring(index)..")") 
		local condition 	= e("GetItemCondition(0,"..tostring(index)..")")
		if equipped and (condition <= 10)then
			return true
		end
	end
	return false
end

--:===============================================================================================================
--: ai_vendor: NeedToVendor
--:===============================================================================================================  

function ai_vendor:NeedToVendor()
	return not e("CheckInventorySpaceSilently(5)")
end

--:===============================================================================================================
--: constants
--:===============================================================================================================  

EQUIP_SLOT = {
	EQUIP_SLOT_CHEST = 2,
	EQUIP_SLOT_HEAD = 0,
	EQUIP_SLOT_SHOULDERS = 3,
	EQUIP_SLOT_WAIST = 6,
	EQUIP_SLOT_LEGS = 8,
	EQUIP_SLOT_FEET = 9,
	EQUIP_SLOT_HAND = 16,
}
