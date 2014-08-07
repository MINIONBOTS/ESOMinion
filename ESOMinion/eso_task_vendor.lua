--:===============================================================================================================
--: ESOMinion [Elder Scrolls Online]
--: eso_task_vendor (7.25.2014)
--:=============================================================================================================== 

eso_vendortask = inheritsFrom(ml_task)
eso_vendortask.name = "Vendoring"

function eso_vendortask.Create()
	local newinst = inheritsFrom(eso_vendortask)
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 
	newinst.vendor = nil
	newinst.marker = nil
    return newinst
end

function eso_vendortask:Init()
	self:add(ml_element:create( "VendorUpdate", c_VendorUpdate, e_VendorUpdate, 100 ), self.process_elements)
	self:add(ml_element:create( "VendorAndRepair", c_VendorAndRepair, e_VendorAndRepair, 75 ), self.process_elements)
	self:add(ml_element:create( "MoveToVendor", c_MoveToVendor, e_MoveToVendor, 50 ), self.process_elements)
	self:AddTaskCheckCEs()
end

function eso_vendortask:task_complete_eval()
	if c_dead:evaluate() or c_Aggro:evaluate() then
		return true
	end
	return false
end

function eso_vendortask:task_complete_execute()
	d("eso_vendortask -> Ending Vendor Task")
	self.completed = true
end

c_Vendor = inheritsFrom( ml_cause )
e_Vendor = inheritsFrom( ml_effect )
e_Vendor.throttle = 2500

function c_Vendor:evaluate()
	if not c_dead:evaluate() and not c_Aggro:evaluate() then
		if (gVendor == "1" and NeedToVendor()) or (gRepair == "1" and NeedToRepair()) then
			if GetVendor() or GetVendorMarker() then
				return true
			end
		end
	end
	return false
end

function e_Vendor:execute()
	Player:Stop()
	d("eso_vendortask -> Creating Vendor Task")
	local task = eso_vendortask.Create()
	ml_task_hub:Add(task.Create(), REACTIVE_GOAL, TP_ASAP)
	return ml_log(true)
end

--:===============================================================================================================
--: VendorUpdate
--:===============================================================================================================  

c_VendorUpdate = inheritsFrom( ml_cause )
e_VendorUpdate = inheritsFrom( ml_effect )

function c_VendorUpdate:evaluate()
	ml_task_hub:CurrentTask().vendor = GetVendor()
	ml_task_hub:CurrentTask().marker = GetVendorMarker()
	return false
end

function e_VendorUpdate:execute()

end

--:===============================================================================================================
--: MoveToVendor
--:===============================================================================================================  

c_MoveToVendor = inheritsFrom( ml_cause )
e_MoveToVendor = inheritsFrom( ml_effect )

function c_MoveToVendor:evaluate()
	if (gVendor == "1" and NeedToVendor()) or (gRepair == "1" and NeedToRepair()) then
		if ml_task_hub:CurrentTask().vendor then
			if ml_task_hub:CurrentTask().vendor.distance > INTERACT_RANGE.VENDOR then
				return true
			end
		elseif ml_task_hub:CurrentTask().marker then
			if ml_task_hub:CurrentTask().marker.distance > INTERACT_RANGE.MARKER then
				return true
			end
		end
	end
	return false
end

function e_MoveToVendor:execute()
	if ml_task_hub:CurrentTask().vendor then
		if ml_task_hub:CurrentTask().vendor.distance >= INTERACT_RANGE.VENDOR then
			local pos = ml_task_hub:CurrentTask().vendor.pos
			local result = tostring(Player:MoveTo(pos.x,pos.y,pos.z,INTERACT_RANGE.VENDOR-1,false,true,true))
			if tonumber(result) >= 0 then
				ml_log("eso_vendortask -> MoveToVendor "..ml_task_hub:CurrentTask().vendor.distance)
				return ml_log(true)
			end
		end
	elseif ml_task_hub:CurrentTask().marker then
		if ml_task_hub:CurrentTask().marker.distance > INTERACT_RANGE.MARKER then
			local pos = ml_task_hub:CurrentTask().marker:GetPosition()
			local result = tostring(Player:MoveTo(pos.x,pos.y,pos.z,INTERACT_RANGE.MARKER-1,false,true,true))
			if tonumber(result) >= 0 then
				ml_log("eso_vendortask -> MoveToVendorMarker "..ml_task_hub:CurrentTask().marker.distance)
				return ml_log(true)
			end
		end
	end
	return
end
	
--:===============================================================================================================
--: VendorAndRepair
--:===============================================================================================================  

c_VendorAndRepair = inheritsFrom( ml_cause )
e_VendorAndRepair = inheritsFrom( ml_effect )
e_VendorAndRepair.throttle = math.random(1000,2000)

function c_VendorAndRepair:evaluate()
	if ml_task_hub:CurrentTask().vendor and ml_task_hub:CurrentTask().vendor.distance <= INTERACT_RANGE.VENDOR then
		ml_log("eso_vendortask -> Vendoring ")
		return true
	end
	return false
end

function e_VendorAndRepair:execute()
	e_VendorAndRepair.throttle = math.random(1000,2000)
	if IsVendorStoreOpen() == false then 
		if IsVendorChatterOpen() == true then
			local optionCount = e("GetChatterOptionCount()")
			for option = 1, optionCount do
				local optionString,optionType = e("GetChatterOption("..tostring(option)..")")
				if optionType == g("CHATTER_START_SHOP") then
					e("SelectChatterOption("..tostring(option)..")")
					d("eso_vendortask ->  SelectChatterOption "..optionString)
					ml_log("SelectChatterOption "..optionString)
					return ml_log(true)
				end
			end
			return ml_log(true)
		else
			if ml_task_hub:CurrentTask().vendor and ml_task_hub:CurrentTask().vendor.id then
				Player:Interact(ml_task_hub:CurrentTask().vendor.id)
				d("eso_vendortask -> Interacting With "..ml_task_hub:CurrentTask().vendor.name)
				ml_log("eso_vendortask -> Interacting With "..ml_task_hub:CurrentTask().vendor.name)
				return ml_log(true)
			end
			return ml_log(false)
		end
	end
	
	if not ml_task_hub:CurrentTask().inventory then
		ml_task_hub:CurrentTask().inventory = {}
		local bagSlots = e("GetBagSize(1)")
		for bagSlot = 0, bagSlots, 1 do
			local name 	 	 			= e("GetItemName(1,"..tostring(bagSlot)..")")
			local itemType				= e("GetItemType(1,"..tostring(bagSlot)..")")
			local _,_,_,_,_,_,_,quality = e("GetItemInfo(1,"..tostring(bagSlot)..")")
			local stack,maxStack 		= e("GetSlotStackSize(1,"..tostring(bagSlot)..")")
			if itemType ~= 0 then
				if eso_vendormanager.profile ~= nil and
					eso_vendormanager.profile.data ~= nil and
					eso_vendormanager.profile.data[itemType] ~= nil and
					eso_vendormanager.profile.data[itemType][quality] ~= nil
				then
					if eso_vendormanager.profile.data[itemType][quality] == true then
						ml_task_hub:CurrentTask().inventory[bagSlot] = {}
						ml_task_hub:CurrentTask().inventory[bagSlot].name = name
						ml_task_hub:CurrentTask().inventory[bagSlot].stack = stack
					end
				elseif (quality == g("ITEM_QUALITY_TRASH")) then
					ml_task_hub:CurrentTask().inventory[bagSlot] = {}
					ml_task_hub:CurrentTask().inventory[bagSlot].name = name
					ml_task_hub:CurrentTask().inventory[bagSlot].stack = stack
				end
			end
		end
		return ml_log(true)
	end
	
	if ValidTable(ml_task_hub:CurrentTask().inventory) then
		local bagSlot,contents = next(ml_task_hub:CurrentTask().inventory)
		if bagSlot and contents then
			d("eso_vendortask -> Selling "..contents.name)
			e("SellInventoryItem(1,"..tostring(bagSlot)..","..tostring(contents.stack)..")")
			ml_task_hub:CurrentTask().inventory[bagSlot] = nil
			return ml_log(true)
		end
	end
	
	if gVendor == "1" and not ml_task_hub:CurrentTask().junksold then
		d("eso_vendortask -> SellingJunk ") e("SellAllJunk()")
		ml_task_hub:CurrentTask().junksold = true
		return ml_log(true)
	end
	
	if gRepair == "1" and not ml_task_hub:CurrentTask().repaired then
		d("eso_vendortask -> Repairing ") e("RepairAll()")
		ml_task_hub:CurrentTask().repaired = true
		return ml_log(true)
	end

	e("EndInteraction(15)")
	ml_task_hub:CurrentTask().completed = true
	d("eso_vendortask -> Vendor Completed")
	return
end

--:===============================================================================================================
--: helper functions
--:===============================================================================================================  

function IsVendorChatterOpen()
	return e("GetNumStoreItems()") == 0 and e("GetChatterOptionCount()") > 0
end

function IsVendorStoreOpen()
	return e("GetNumStoreItems()") > 0
end

function IsPlayerVendoring()
	return IsVendorStoreOpen() or IsVendorChatterOpen()
end

function NeedToVendor()
	return not e("CheckInventorySpaceSilently(5)")
end

function NeedToRepair()
	for slot,index in pairs(EQUIP_SLOT) do
		local item,equipped	= e("GetEquippedItemInfo("..tostring(index)..")") 
		local condition 	= e("GetItemCondition(0,"..tostring(index)..")")
		if equipped and (condition <= 10)then
			return true
		end
	end
	return false
end

function GetVendor()
	local vendorlist = EntityList("nearest,isvendor,onmesh,maxdistance=85")
	if ValidTable(vendorlist) then
		local id,vendor = next(vendorlist)
		if ( id and vendor ) then
			return vendor
		end
	end
	return nil
end

function GetVendorMarker()
	local markerlist = ml_marker_mgr.GetList(GetString("vendorMarker"), false, false)
	local markers = {}
	if ValidTable(markerlist) then
		local name,marker = next(markerlist)
		while ( name and marker ) do
			local ppos = Player.pos
			local mpos = marker:GetPosition()
			local dist = Distance3D(ppos.x,ppos.y,ppos.z,mpos.x,mpos.y,mpos.z)
			markers[name] = marker
			markers[name].distance = dist
			name,marker = next(markerlist,name)
		end
		table.sort(markers,function(a,b) return a.distance < b.distance end)
		local name,marker = next(markers)
		if name and marker then
			return marker
		end
	end
	return nil
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

INTERACT_RANGE = {
	VENDOR = 4,
	MARKER = 10,
}
