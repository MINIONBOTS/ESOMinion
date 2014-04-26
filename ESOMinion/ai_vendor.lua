-- Handles vendoring and repairs
-----------
ai_vendor = {}

function ai_vendor.moduleinit()
	if ( Settings.ESOMinion.gArmorT == nil ) then
		Settings.ESOMinion.gArmorT = "1"
	end	
	if ( Settings.ESOMinion.gArmorN == nil ) then
		Settings.ESOMinion.gArmorN = "1"
	end	
	if ( Settings.ESOMinion.gArmorM == nil ) then
		Settings.ESOMinion.gArmorM = "0"
	end	
	if ( Settings.ESOMinion.gArmorA == nil ) then
		Settings.ESOMinion.gArmorA = "0"
	end	
	if ( Settings.ESOMinion.gWeapT == nil ) then
		Settings.ESOMinion.gWeapT = "1"
	end	
	if ( Settings.ESOMinion.gWeapN == nil ) then
		Settings.ESOMinion.gWeapN = "1"
	end	
	if ( Settings.ESOMinion.gWeapM == nil ) then
		Settings.ESOMinion.gWeapM = "0"
	end	
	if ( Settings.ESOMinion.gWeapA == nil ) then
		Settings.ESOMinion.gWeapA = "0"
	end	
	if ( Settings.ESOMinion.gConsT == nil ) then
		Settings.ESOMinion.gConsT = "1"
	end	
	if ( Settings.ESOMinion.gConsN == nil ) then
		Settings.ESOMinion.gConsN = "1"
	end	
	if ( Settings.ESOMinion.gConsM == nil ) then
		Settings.ESOMinion.gConsM = "0"
	end	
	if ( Settings.ESOMinion.gConsA == nil ) then
		Settings.ESOMinion.gConsA = "0"
	end	
	if ( Settings.ESOMinion.gCraftT == nil ) then
		Settings.ESOMinion.gCraftT = "1"
	end	
	if ( Settings.ESOMinion.gCraftN == nil ) then
		Settings.ESOMinion.gCraftN = "1"
	end	
	if ( Settings.ESOMinion.gCraftM == nil ) then
		Settings.ESOMinion.gCraftM = "0"
	end	
	if ( Settings.ESOMinion.gCraftA == nil ) then
		Settings.ESOMinion.gCraftA = "0"
	end
	if ( Settings.ESOMinion.gVendor == nil ) then
		Settings.ESOMinion.gVendor = "1"
	end
	if ( Settings.ESOMinion.gRepair == nil ) then
		Settings.ESOMinion.gRepair = "1"
	end		
	
	--GUI_NewCheckbox(ml_global_information.window.name,GetString("armor"),"gArmor",GetString("settings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("enabled"),"gVendor",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("enableRepair"),"gRepair",GetString("vendorSettings"))	
	GUI_NewCheckbox(ml_global_information.window.name,GetString("armorTrash"),"gArmorT",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("armorNormal"),"gArmorN",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("armorMagic"),"gArmorM",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("armorArtefact"),"gArmorA",GetString("vendorSettings"))
	
	GUI_NewCheckbox(ml_global_information.window.name,GetString("weaponTrash"),"gWeapT",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("weaponNormal"),"gWeapN",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("weaponMagic"),"gWeapM",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("weaponArtefact"),"gWeapA",GetString("vendorSettings"))
	
	GUI_NewCheckbox(ml_global_information.window.name,GetString("consumTrash"),"gConsT",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("consumNormal"),"gConsN",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("consumMagic"),"gConsM",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("consumArtefact"),"gConsA",GetString("vendorSettings"))
	
	GUI_NewCheckbox(ml_global_information.window.name,GetString("craftTrash"),"gCraftT",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("craftNormal"),"gCraftN",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("craftMagic"),"gCraftM",GetString("vendorSettings"))
	GUI_NewCheckbox(ml_global_information.window.name,GetString("craftArtefact"),"gCraftA",GetString("vendorSettings"))
	
	gArmorT = Settings.ESOMinion.gArmorT
	gArmorN = Settings.ESOMinion.gArmorN
	gArmorM = Settings.ESOMinion.gArmorM
	gArmorA = Settings.ESOMinion.gArmorA
	gWeapT = Settings.ESOMinion.gWeapT
	gWeapN = Settings.ESOMinion.gWeapN
	gWeapM = Settings.ESOMinion.gWeapM
	gWeapA = Settings.ESOMinion.gWeapA
	gConsT = Settings.ESOMinion.gConsT
	gConsN = Settings.ESOMinion.gConsN
	gConsM = Settings.ESOMinion.gConsM
	gConsA = Settings.ESOMinion.gConsA
	gCraftT = Settings.ESOMinion.gCraftT
	gCraftN = Settings.ESOMinion.gCraftN
	gCraftM = Settings.ESOMinion.gCraftM
	gCraftA = Settings.ESOMinion.gCraftA
	gVendor = Settings.ESOMinion.gVendor
	gRepair = Settings.ESOMinion.gRepair
end

RegisterEventHandler("Module.Initalize",ai_vendor.moduleinit)


function ai_vendor.HandleVendoring()
	if ( ml_global_information.running ) then
		if(tonumber(gVendor) ==1) then
			ml_log("Selling Junk")
			markItemsJunk()
			if(e("HasAnyJunk(1)"))then
				e("SellAllJunk()")
			end
		end
		if ( gRepair == "1" ) then
			ml_log("Repairing items")
			e("RepairAll()")
		end
		ml_log("Closing Vendor window")
		e("EndInteraction(15)")
	end
end

--------
c_movetovendor = inheritsFrom( ml_cause )
e_movetovendor = inheritsFrom( ml_effect )
e_movetovendor.vendorMarker = nil
function c_movetovendor:evaluate()
	if( gVendor == "1" and ml_global_information.Player_InventoryNearlyFull)then
		local VList = EntityList("nearest,isvendor")
		if ( TableSize( VList ) > 0 ) then			
			return true
		end
		
		-- check if there is a vendormarker setup , if so, go there
		if ( e_movetovendor.vendorMarker == nil ) then
			-- get closest vendormarker
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
				-- Set this closest vendor to our local variable
				if ( marker ) then
					e_movetovendor.vendorMarker = marker
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
		if ( VList ) then	
			if ( TableSize( VList ) > 0)then	
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
							e("SelectChatterOption(1)")
							return ml_log(true)
						end
					end				
				end
			end
		
		-- goto vendormarker
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

-- Sets the Items in our inventory as junk 
function markItemsJunk()
	local junk = "true"
	local args = { e("GetBagInfo(1)")}    
	local numArgs = #args
	local InventoryMax = args[2]
	local i = 1

	while(i <= tonumber(InventoryMax)) do

		if( (e("IsItemJunk(1,"..tostring(i)..")")) == false) then
			local argsItemQ = {e("GetItemInfo( 1,"..tostring(i)..")") } 
			local numArgsItemQ = #argsItemQ
			local quality = argsItemQ[8]  
			local itemType = e("GetItemFilterTypeInfo(1,"..tostring(i)..")")
		
-- Armor Trash
			if(tonumber(itemType) == 2) then
				if(tonumber(quality) == 1) then
					if(tonumber(gArmorT) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Armor Normal	
			if(tonumber(itemType) == 2) then
				if(tonumber(quality) == 2) then
					if(tonumber(gArmorN) == 1) then
					d("test")
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Armor Magic	
			if(tonumber(itemType) == 2) then
				if(tonumber(quality) == 3) then
					if(tonumber(gArmorM) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Armor Artefact
			if(tonumber(itemType) == 2) then
				if(tonumber(quality) == 4) then
					if(tonumber(gArmorA) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Weapon Trash
			if(tonumber(itemType) == 1) then
				if(tonumber(quality) == 1) then
					if(tonumber(gWeapT) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Weapon Normal
			if(tonumber(itemType) == 1) then
				if(tonumber(quality) == 2) then
					if(tonumber(gWeapN) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Weapon Magic
			if(tonumber(itemType) == 1) then
				if(tonumber(quality) == 3) then
					if(tonumber(gWeapM) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Weapon Artefact
			if(tonumber(itemType) == 1) then
				if(tonumber(quality) == 4) then
					if(tonumber(gWeapA) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Consumable Trash
			if(tonumber(itemType) == 4) then
				if(tonumber(quality) == 1) then
					if(tonumber(gConsT) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Consumable Normal
			if(tonumber(itemType) == 4) then
				if(tonumber(quality) == 2) then
					if(tonumber(gConsN) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Consumable Magic
			if(tonumber(itemType) == 4) then
				if(tonumber(quality) == 3) then
					if(tonumber(gConsM) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Consumable Artefact
			if(tonumber(itemType) == 4) then
				if(tonumber(quality) == 4) then
					if(tonumber(gConsA) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Consumable Legendary
			if(tonumber(itemType) == 4) then
				if(tonumber(quality) == 5) then
					if(tonumber(gConsL) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Consumable Legendary
			if(tonumber(itemType) == 4) then
				if(tonumber(quality) == 5) then
					if(tonumber(gConsL) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Crafting Trash
			if(tonumber(itemType) == 5) then
				if(tonumber(quality) == 1) then
					if(tonumber(gCraftT) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Crafting Normal
			if(tonumber(itemType) == 5) then
				if(tonumber(quality) == 2) then
					if(tonumber(gCraftN) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Crafting Magic
			if(tonumber(itemType) == 5) then
				if(tonumber(quality) == 3) then
					if(tonumber(gCraftM) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
-- Crafting Artefact
			if(tonumber(itemType) == 5) then
				if(tonumber(quality) == 4) then
					if(tonumber(gCraftA) ==1) then
					e("SetItemIsJunk(1,"..tostring(i)..","..junk..")")
					end
				end
			end
		end
		i = i + 1
	end
end



