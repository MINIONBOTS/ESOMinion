eso_quest_helpers = {}

function eso_quest_helpers.GetNearestObjective()
	local nearestObjective = {}
	local nearestDistance = 0.0
	local playerPos = ml_global_information.Player_Position

	--first get the nearest quest condition from the client
	local cVals = QuestManager:GetNearestQuestCondition()
	if(ValidTable(conditionVals)) then
		local condition = QuestManager:GetQuestCondition(cVals.journalindex, cVals.stepindex, cVals.conditionindex)
		if(ValidTable(condition)) then
			if(NavigationManager:IsOnMesh(condition.pos)) then
				d("Nearest quest condition at ("..tostring(condition.pos.x)..","..tostring(condition.pos.y)..","..tostring(condition.pos.z)..")")
				nearestObjective = condition
				
				local distance = PathDistance(playerPos.x, playerPos.y, playerPos.z, condition.pos.x, condition.pos.y, condition.pos.z)
				nearestDistance = distance
			end
		end
	end
	
	--now look for stuff that is not a quest condition
	--most important is quest start pins for now
	local nearestOfferPos = nil
	local pl = PinList("nearest,onmesh,type="..tostring(g("MAP_PIN_TYPE_QUEST_OFFER")))
	if ( pl ) then
		local p = pl[1]
		if(ValidTable(p)) then
			-- the 'd' command is a global command for printing out information into the console
			nearestOfferPos = p.pinpos
			d("Nearest quest offer at ("..tostring(nearestOfferPos.x)..","..tostring(nearestOfferPos.y)..","..tostring(nearestOfferPos.z)..")")
			
			local distance = PathDistance(playerPos.x, playerPos.y, playerPos.z, nearestOfferPos.x, nearestOfferPos.y, nearestOfferPos.z)
			if(distance < nearestDistance or nearestDistance == 0.0) then
				nearestObjective = {["type"] = "offer", ["pos"] = nearestOfferPos}
				nearestDistance = distance
			end
		end  
	end
	
	if(ValidTable(nearestObjective)) then
		d("Found objective of type "..tostring(nearestObjective.type).." at ("..tostring(nearestObjective.x)..","..tostring(nearestObjective.y)..","..tostring(nearestObjective.z)..")")
		return nearestObjective
	else
		d("No suitable quest objective found")
	end
end