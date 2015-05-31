function GetNextCombatTip(tipType)
	local firstTip = nil

	if(tipType) then
		firstTip = ml_global_information.lastCombatTip[tipType]
	else
		for cType, cTime in pairs(ml_global_information.lastCombatTip) do
			if(firstTip == nil or cTime < firstTip.time) then
				firstTip = {["type"] = cType, ["time"] = cTime}
			end
		end
	end
	
	if(firstTip) then
		ml_global_information.lastCombatTip[firstTip.type] = nil
	end
	
	return firstTip
end

function GetPosFromDistanceHeading(startPos, distance, heading)
	local newX = distance * math.sin(heading) + startPos.x
	local newZ = distance * math.cos(heading) + startPos.z
	return {x = newX, y = startPos.y, z = newZ}
end