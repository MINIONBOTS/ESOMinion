--****************************************************************************
-- ai_vendor
--****************************************************************************
ai_vendor={}
ai_vendor.queue = nil
ai_vendor.vendored = false

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
		
		GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enableSelling"),"gVendor",GetString("settings"))
		GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enableRepair"),"gRepair",GetString("settings"))	
		gVendor = Settings.ESOMinion.gVendor
		gRepair = Settings.ESOMinion.gRepair
	end
)

ai_vendortask = inheritsFrom(ml_task)
ai_vendortask.name = "Vendoring"
function ai_vendortask.Create()
	local newinst = inheritsFrom(ai_vendortask)
    
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 
    return newinst
end

function ai_vendortask:Init()		


	-- LootAll
	--self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)		

	-- Resting
	--self:add(ml_element:create( "Resting", c_resting, e_resting, 250 ), self.process_elements)

	--Vendoring
	self:add(ml_element:create( "GetVendor", c_sellandrepair, e_sellandrepair, 225 ), self.process_elements)

	--Vendoring
	self:add(ml_element:create( "GoVendor", c_movetovend, e_movetovend, 200 ), self.process_elements)

		
    self:AddTaskCheckCEs()
end

function ai_vendortask:task_complete_eval()	
	if ( c_dead:evaluate() or c_Aggro:evaluate() or 
		(not ( (gVendor == "1" and ml_global_information.Player_InventoryNearlyFull) or
			   ( gRepair == "1" and ai_vendor:CheckDurability()== true)
			 ) and e_sellandrepair.isvendoring == false)		) then 
		Player:Stop()
		return true
	end
	return false
end
function ai_vendortask:task_complete_execute()
   self.completed = true
end


--****************************************************************************
-- Create New Vendor Task Cause/Effect
--****************************************************************************
c_vendor = inheritsFrom( ml_cause )
e_vendor = inheritsFrom( ml_effect )
c_vendor.throttle = 2500
function c_vendor:evaluate()
	if( (gVendor == "1" and ml_global_information.Player_InventoryNearlyFull) or( gRepair == "1" and ai_vendor:CheckDurability()== true))then
		return true
	end

	return false
end

function e_vendor:execute()
	ml_log("e_vendor ")
	Player:Stop()
	local newTask = ai_vendortask.Create()
	
	ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
	return ml_log(true)
end


--****************************************************************************
-- Cause/Effect
--****************************************************************************


c_movetovend = inheritsFrom( ml_cause )
e_movetovend = inheritsFrom( ml_effect )
c_movetovend.markerreachedfirsttime = false
c_movetovend.markerreached = false
function c_movetovend:evaluate()
	if( (gVendor == "1" and ml_global_information.Player_InventoryNearlyFull) or ( gRepair == "1" and ai_vendor:CheckDurability()== true))then
		local dist = -1
		local VList = EntityList("nearest,isvendor,onmesh,maxdistance=85")
		if ( TableSize( VList ) > 0 ) then		

			id,vendor = next (VList)
			if ( id and vendor ) then
				local pPos = Player.pos
				local tPos = vendor.pos
				if (pPos) then
					dist = Distance2D( tPos.x,tPos.z,pPos.x,pPos.z)
				end
			end

		else
			if ( e_movetovend.vendorMarker == nil ) then
				local VMList = ml_marker_mgr.GetList(GetString("vendorMarker"), false, false)
				if ( TableSize(VMList) > 0 ) then				
					local bestmarker = nil
					local bestdist = 9999999
					local name,marker = next ( VMList )
					while (name and marker) do
						local mPos = marker:GetPosition()
						if ( Distance2D( mPos.x,mPos.z,ml_global_information.Player_Position.x,ml_global_information.Player_Position.z) < bestdist) then
							bestdist = Distance2D( mPos.x,mPos.z,ml_global_information.Player_Position.x,ml_global_information.Player_Position.z)
							bestmarker = marker
						end
						name,maker = next ( VMList,name )
					end
					if ( marker ) then
						e_movetovend.vendorMarker = marker
						return true
					end				
				end
			end
			if ( e_movetovend.vendorMarker ~= nil ) then
				local mPos = e_movetovend.vendorMarker:GetPosition()
				local pPos = Player.pos
				dist = Distance2D( mPos.x,mPos.z,pPos.x,pPos.z)		
			end
		end

		if ( c_movetovend.markerreached == false) then			
			return true
		
		else
			
			
			if  (dist > 5) then
				d("We need to move to vendor!")
				c_movetovend.markerreached = false
				return true
			end
		end		

	end
	
    return false
end

function e_movetovend:execute()
	ml_log(" e_movetovend ")
	local dist =-1
	local tPos =-1
	local pPos = Player.pos

		-- Check for coordinate of nearest vendor, otherwise check coord for vendor marker
		local VList = EntityList("nearest,isvendor,onmesh,maxdistance=85")
		if ( VList and TableSize( VList ) > 0 ) then	
			
			id,vendor = next (VList)
			if ( id and vendor ) then
				tPos = vendor.pos	
			end
		elseif (e_movetovend.vendorMarker ~= nil) then
				tPos = e_movetovend.vendorMarker:GetPosition()
		end

		-- Ride the sunset!
		if(pPos and tPos) then
			if (pPos) then
				dist = Distance2D( tPos.x,tPos.z,pPos.x,pPos.z)
			end	


			if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
				ai_mount:Mount()
			elseif gUseMount == "1" and tonumber(gUseMountRange) > dist then
				ai_mount:Dismount()
			end
			
			
			if  ( dist < 5) then
				-- We reached our Vending Machine
				c_movetovend.markerreached = true
				d("Reached current Vendor...")
				return ml_log(true)		
			else
				-- We need to reach our Vending Machine			
				local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,10,false,true,false))
				if (tonumber(navResult) < 0) then
					ml_log("e_movetovend result: "..tostring(navResult))
					return ml_log(false)
				end
				return ml_log(true)
			end
		end

	return ml_log(false)
end





c_sellandrepair = inheritsFrom( ml_cause )
e_sellandrepair = inheritsFrom( ml_effect )
e_sellandrepair.vendorMarker = nil
e_sellandrepair.isvendoring = false
function c_sellandrepair:evaluate()
	if (e_sellandrepair.isvendoring) then
		return true
	end

	if( (gVendor == "1" and ml_global_information.Player_InventoryNearlyFull) or( gRepair == "1" and ai_vendor:CheckDurability()== true))then
		
		--if no vendors within 10 steps then fuck all! we ain't bending! protects our back!
		local VList = EntityList("nearest,isvendor,onmesh,maxdistance=10")
		if ( TableSize( VList ) > 0 ) then			
			return true
		else
			return false
		end
	end

	e_sellandrepair.vendorMarker = nil
	return false
end

e_sellandrepair.merchantstep = 0
function e_sellandrepair:execute()
	ml_log("e_gotovendor")
	local VList = EntityList("nearest,isvendor,onmesh,maxdistance=85")
	if ( VList and TableSize( VList ) > 0 ) then	
		
		id,vendor = next (VList)
		if ( id and vendor ) then
			local pPos = Player.pos
			local tPos = vendor.pos
			if (pPos) then
				local dist = Distance3D( tPos.x,tPos.y,tPos.z,pPos.x,pPos.y,pPos.z)
				ml_log("("..tostring(math.floor(dist))..")")
	
				if ( dist > 4 and tonumber(e("GetChatterOptionCount()"))==0) then
					local navResult = tostring(Player:MoveTo( tPos.x,tPos.y,tPos.z,2,false,true,true))
					if (tonumber(navResult) < 0) then		
						ml_error("e_sellandrepair result: "..tonumber(navResult))
						return ml_log(false)							
					end	
					return ml_log(true)
				end
				if(vendor.distance <= 4 or tonumber(e("GetChatterOptionCount()")) > 0 or e("GetNumStoreItems()") > 0) then
					Player:Stop()
					
					-- I KNOW this should go in seperate cause & effects, but then a whole new task would also have to be written for vendoring, I'm waaay to lazy now
					
					-- If sell window is already open, sell & repair
					if ( e("GetNumStoreItems()") > 0 ) then
						
						e_sellandrepair.isvendoring = true
						-- Repair
						if (e_sellandrepair.merchantstep == 0) then
							e_sellandrepair.merchantstep = 1
							if ( gRepair == "1" and ai_vendor.CheckDurability()== true ) then
								d("Repairing items")
								e("RepairAll()")
								ml_global_information.Wait(1000)
								return ml_log(true)
							end								
						end
						
						--Autoequip
						if (e_sellandrepair.merchantstep == 1) then
							e_sellandrepair.merchantstep = 2
							if ( gAutoEquip == "1" ) then
								d("Auto equipping superior items")
								eso_autoequip.AutoEquip()
								ml_global_information.Wait(1000)
								return ml_log(true)
							end								
						end
						
						-- Mark Junk items
						if (e_sellandrepair.merchantstep == 2) then
							e_sellandrepair.merchantstep = 3
							if ( gVendor == "1" ) then
								d("Marking items as junk")
								ai_vendor.markitems()
								ml_global_information.Wait(1000)
								return ml_log(true)
							end								
						end
						
						--Sell Items
						if (e_sellandrepair.merchantstep == 3) then
							e_sellandrepair.merchantstep = 4
							if ( gVendor == "1" and e("HasAnyJunk(1)") ) then
								d("Selling items")				
								e("SellAllJunk()")
								ml_global_information.Wait(4000)
								return ml_log(true)
							end								
						end
						
						--Close Store
						if (e_sellandrepair.merchantstep == 4) then
							e_sellandrepair.merchantstep = 0
							e_sellandrepair.isvendoring = false
							d("Closing vendor window")
							e("EndInteraction(15)")								
							ml_global_information.Wait(1000)
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
						e_sellandrepair.merchantstep = 0
					else
						-- switch to vendoring
						for i=0,chatoptionscount, 1 do									
							local args = { e("GetChatterOption("..tostring(i)..")")}
							local convstring = args[1]
							if ( convstring ~= nil and convstring ~= "" ) then
								if(string.match(tostring(convstring),"Store") or string.match(tostring(convstring),"H\xc3\xa4ndler") or string.match(tostring(convstring),"Magasin"))then
									d("Selecting Merchant conversation option..")
									e("SelectChatterOption("..tostring(i)..")")
									break
								end
							else
								d("Unknown Merchant conversation options..trying to make him chat lol")
								e("SelectChatterOption("..tostring(1)..")")
							end
						end
					end
					ml_global_information.Wait(1000)
					return ml_log(true)
				end									
			end
		end
	
	end
	return ml_log(false)
end


--****************************************************************************
-- Mark Items
--****************************************************************************
function ai_vendor.markitems()
	local junk = "true"
	local args = { e("GetBagInfo(1)")}    
	local numArgs = #args
	local InventoryMax = args[2]
	local i = 0
	
	-- Just to make sure a profile is loaded, else all gets sold -.-
	if ( gVMprofile ~= nil and gVMprofile ~= "" and gVMprofile ~= "None" ) then
	
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
				--d(EquipType)
				--Check if the item is in whitelist first
				if(eso_vendormanager.isWhiteListed(itemToCheck) == false) then
					if(tonumber(itemType) == 2) then  --it is Armor
						if((VM_ATRASH == "1") or ( VM_ANORMAL == "1") or ( VM_AMAGIC == "1") or ( VM_AARCANE == "1")) then			
							-- Armor Trash
							if(tonumber(quality) == 0) then		
								if((VM_ATRASH == "1") ) then					
									if( (EquipType == g("EQUIP_TYPE_CHEST")) and(VM_CHEST == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_FEET")) and(VM_FEET == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HAND")) and(VM_HAND == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and(VM_HEAD == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and(VM_LEGS == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_NECK")) and(VM_NECK == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_RING")) and(VM_RING == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and(VM_SHOULDERS == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and(VM_WAIST == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and(VM_OFFHAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end	
									
								end
							end
							-- Armor Normal	
							if(tonumber(quality) == 1) then
								if((VM_ANORMAL == "1") ) then
									if( (EquipType == g("EQUIP_TYPE_CHEST")) and(VM_CHEST == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_FEET")) and(VM_FEET == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HAND")) and(VM_HAND == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and(VM_HEAD == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and(VM_LEGS == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_NECK")) and(VM_NECK == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_RING")) and(VM_RING == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and(VM_SHOULDERS == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and(VM_WAIST == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and(VM_OFFHAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end

								end
							end
							-- Armor Magic	
							if(tonumber(quality) == 2) then
								if((VM_AMAGIC == "1") ) then
									if( (EquipType == g("EQUIP_TYPE_CHEST")) and(VM_CHEST == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_FEET")) and(VM_FEET == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HAND")) and(VM_HAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and(VM_HEAD == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and(VM_LEGS == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_NECK")) and(VM_NECK == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_RING")) and(VM_RING == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and(VM_SHOULDERS == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and(VM_WAIST == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and(VM_OFFHAND == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end
								end
							end
							-- Armor Arcane
							if(tonumber(quality) == 3) then
								if((VM_AARCANE == "1") ) then
									if( (EquipType == g("EQUIP_TYPE_CHEST")) and(VM_CHEST == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_FEET")) and(VM_FEET == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HAND")) and(VM_HAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_HEAD")) and(VM_HEAD == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_LEGS")) and(VM_LEGS == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_NECK")) and(VM_NECK == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_RING")) and(VM_RING == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_SHOULDERS")) and(VM_SHOULDERS == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_WAIST")) and(VM_WAIST == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_OFF_HAND")) and(VM_OFFHAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end
								end
							end
						end
					end		
					if(tonumber(itemType) == 1) then -- it is Weapon
						if((VM_WTRASH == "1") or ( VM_WNORMAL == "1") or ( VM_WMAGIC == "1") or ( VM_WARCANE == "1")) then
							--Weapon Trash			
							if(tonumber(quality) == 0) then
								if((VM_WTRASH == "1") ) then
									if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and(VM_TWOHAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and(VM_ONEHAND == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end
								end
							end
							-- Weapon Normal
							if(tonumber(quality) == 1) then
								if((VM_WNORMAL == "1")) then
									if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and(VM_TWOHAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and(VM_ONEHAND == "1"))then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end
								end
							end
							-- Weapon Magic
							if(tonumber(quality) == 2) then
								if((VM_WMAGIC == "1") ) then
									if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and(VM_TWOHAND == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")") 
									elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and(VM_ONEHAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end
								end
							end
							-- Weapon Arcane
							if(tonumber(quality) == 3) then
								if((VM_WARCANE == "1") ) then
									if( (EquipType == g("EQUIP_TYPE_TWO_HAND")) and(VM_TWOHAND == "1")) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")") 
									elseif( (EquipType == g("EQUIP_TYPE_ONE_HAND")) and(VM_ONEHAND == "1") ) then
										e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
									end
								end
							end
						end
					end	
					
					if((itemKind == g("ITEMTYPE_INGREDIENT")) and (VM_INGREDIENT == "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_ADDITIVE")) and (VM_ADDITIVE== "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")	 
					elseif((itemKind == g("ITEMTYPE_ALCHEMY_BASE")) and (VM_ALCHEMYBASE == "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_ENCHANTING_RUNE")) and (VM_ENCHANTRUNE == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_STYLE_MATERIAL")) and (VM_STYLEMAT == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_REAGENT")) and (VM_REAGENT == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_RECIPE")) and (VM_RECIPE == "1") ) then
						if(tonumber(quality) == 2) then
							if((VM_RMAGIC == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 3) then
							if((VM_RARCANE == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
					elseif((itemKind == g("ITEMTYPE_RAW_MATERIAL") and (VM_RAWMATERIAL == "1") )) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_BLACKSMITHING_RAW_MATERIAL")) and (VM_RAWMATERIAL == "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_WOODWORKING_RAW_MATERIAL")) and (VM_RAWMATERIAL == "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_CLOTHIER_RAW_MATERIAL")) and (VM_RAWMATERIAL == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_POTION")) and (VM_PPOTIONS == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_DRINK")) and (VM_DRINK == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_GLYPH_ARMOR")) and (VM_GLYPHARMOR == "1") ) then
						if(tonumber(quality) == 0) then
							if((VM_GTRASH == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 1) then
							if((VM_GNORMAL == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 2) then
							if((VM_GMAGIC == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 3) then
							if((VM_GARCANE == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
					elseif((itemKind == g("ITEMTYPE_GLYPH_WEAPON")) and (VM_GLYPHWEAPON == "1")) then
						if(tonumber(quality) == 0) then
							if((VM_GTRASH == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 1) then
							if((VM_GNORMAL == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 2) then
							if((VM_GMAGIC == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 3) then
							if((VM_GARCANE == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
					elseif((itemKind == g("ITEMTYPE_GLYPH_JEWELRY")) and (VM_GLYPHJEWELRY == "1") ) then
						if(tonumber(quality) == 0) then
							if((VM_GTRASH == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 1) then
							if((VM_GNORMAL == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 2) then
							if((VM_GMAGIC == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 3) then
							if((VM_GARCANE == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
					elseif((itemKind == g("ITEMTYPE_TRASH")) and (VM_ITEMTRASH == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_COLLECTIBLE")) and (VM_COLLECTIBLE == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_COSTUME")) and (VM_COSTUME == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_LOCKPICK")) and (VM_LOCKPICK == "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_LURE")) and (VM_LURE == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_SOUL_GEM")) and (VM_SOULGEM == "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_SPICE")) and (VM_SPICE == "1") ) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif((itemKind == g("ITEMTYPE_TROPHY")) and (VM_TROPHY == "1")) then
						e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					elseif(itemKind == g("ITEMTYPE_FOOD")) then
						if(tonumber(quality) == 0) then
							if((VM_FTRASH == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 1) then
							if((VM_FNORMAL == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 2) then
							if((VM_FMAGIC == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
						if(tonumber(quality) == 3) then
							if((VM_FARCANE == "1") ) then	
								e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
							end
						end
					end
				end
			end
			i = i + 1
		end
	end
end


--****************************************************************************
-- Check if equipped gear is broken
--****************************************************************************
function ai_vendor.CheckDurability()
	local chestdurabilty = e("GetItemCondition(0,2)")  -- return gear condition in %
	local handsdurability = e("GetItemCondition(0,16)")
	local waistdurability = e("GetItemCondition(0,6)")
	local feetdurability = e("GetItemCondition(0,9)")
	local shoulderdurability = e("GetItemCondition(0,3)")
	local headdurability = e("GetItemCondition(0,0)")
	local legsdurability = e("GetItemCondition(0,8)")
	local args = nil
	local numArgs = nil


	if(tonumber(chestdurabilty) <= 2)then  -- if the durability is lower or equal to 2%
		args = { e("GetEquippedItemInfo(2)")}     
		if(args[2] == true)then --we check if something is equipped in this slot
			return true
		end
	end
	if(tonumber(handsdurability) <= 2)then
		args = { e("GetEquippedItemInfo(16)")}    
		if(args[2] == true)then 
			return true
		end
	end
	if(tonumber(waistdurability) <= 2)then
		args = { e("GetEquippedItemInfo(6)")}    
		if(args[2] == true)then 
			return true
		end
	end
	if(tonumber(feetdurability) <= 2)then
		args = { e("GetEquippedItemInfo(9)")}    
		if(args[2] == true)then 
			return true
		end
	end
	if(tonumber(shoulderdurability) <= 2)then
		args = { e("GetEquippedItemInfo(3)")}    
		if(args[2] == true)then
			return true
		end
	end
	if(tonumber(headdurability) <= 2)then
		args = { e("GetEquippedItemInfo(0)")}    
		if(args[2] == true)then 
			return true
		end
	end
	if(tonumber(legsdurability) <= 2)then
		args = { e("GetEquippedItemInfo(8)")}    
		if(args[2] == true)then
			return true
		end
	end
	return false
end


