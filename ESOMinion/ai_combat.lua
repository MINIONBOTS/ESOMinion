-- we'll see what we can do with this
function DoCombatMovement(target)
	-- Move a tiny step back if we are too close
	if ( target.distance < 0.85 ) then
		Player:SetMovement(1,2)
	else
		Player:Stop()
	end
end



--------------
c_usePotions = inheritsFrom(ml_cause)
e_usePotions = inheritsFrom(ml_effect)
function c_usePotions:evaluate()
	if(gPot == "0")then
		return false
	end
	if(gPotiontype == "Health")then
		if((ml_global_information.Player_InCombat == true) and (Player.hp.percent <= tonumber(gPotvalue))) then
			if(haveAndNotCoolDownPotion(16) == true)then
				d("using potion:"..gPotiontype)
				ml_log("using potion :"..gPotiontype)
				return true
			end
		end
	elseif(gPotiontype =="Magicka")then
		if((ml_global_information.Player_InCombat == true) and (ml_global_information.Player_Magicka.percent <= tonumber(gPotvalue))) then
			if (haveAndNotCoolDownPotion(16) == true) then
				d("using potion:"..gPotiontype)
				ml_log("using potion :"..gPotiontype)
				return true
			end
		end
	elseif(gPotiontype =="Stamina")then
		if((ml_global_information.Player_InCombat == true) and (ml_global_information.Player_Stamina.percent <= tonumber(gPotvalue))) then
			if(haveAndNotCoolDownPotion(16) == true)then
				d("using potion:"..gPotiontype)
				ml_log("using potion :"..gPotiontype)
				return true
			end
		end
	end
	
	return false
end

function e_usePotions:execute()
	e("OnSlotDown(16)")
	e("OnSlotUp(16)")
	return false
end

------------------------------------------------------------------------
------------------------------------------------------------------------
function haveAndNotCoolDownPotion(slotID)  
local potionCount = e("GetSlotItemCount("..tostring(slotID)..")")
local args = {e("GetSlotCooldownInfo("..tostring(slotID)..")")}
local isNotCoolDown = args[3]
local slotname = tostring(e("GetSlotName(16)"))
if(gPotiontype == "Stamina")then
	if(string.match(slotname,"Stamina") or string.match(slotname,"stamina") or string.match(slotname,"Ausdauer") or string.match(slotname,"ausdauer") or string.match(slotname,"Vigueur^m") or string.match(slotname,"vigueur")) then
		if(tonumber(potionCount)>0)then
			if(isNotCoolDown == true) then
				return true
			end
			return false
		end
		checkForNewPotions(slotID)
		return false
	end
elseif(gPotiontype =="Magicka")then
	if(string.match(slotname,"Magicka") or string.match(slotname,"magicka") or string.match(slotname,"Magie") or string.match(slotname,"magie")) then
		if(tonumber(potionCount)>0)then
			if(isNotCoolDown == true) then
				return true
			end
			return false
		end
		checkForNewPotions(slotID)
		return false
	end
elseif(gPotiontype =="Health")then
	if(string.match(slotname,"Health") or string.match(slotname,"health") or string.match(slotname,"Lebens") or string.match(slotname,"lebens") or string.match(slotname,"Sant\xc3\xa9") or string.match(slotname,"sant\xc3\xa9")) then
		if(tonumber(potionCount)>0)then
			if(isNotCoolDown == true) then
				return true
			end
			return false
		end
		checkForNewPotions(slotID)
		return false
	end
end
	checkForNewPotions(slotID)
	return false
end

function checkForNewPotions(slotID) -- place the potion in your quickslot based on your UI choice.  If stack is at 0 then it check if you have another kind of those potions.
local bagslots = { e("GetBagSize(1)")}    
local i = 0
	while(i< tonumber(bagslots))do
		if(getPotionType(i) == gPotiontype)then
			e("SelectSlotItem(1,"..tostring(i)..","..tostring(slotID)..")")
			break
		end
		i = i+1
	end
end
----------------------------------
function getPotionType(slotID)

local links = e("GetItemLink(1,"..slotID..",1)")
local color, id = string.match(tostring(links),"(%w+):item:(%w+):")
	if(tonumber(id) == 27036 )then
		return "Health"
	elseif(tonumber(id) == 27037 )then
		return "Magicka"
	elseif(tonumber(id) == 27038)then
		return "Stamina"
	end

end
