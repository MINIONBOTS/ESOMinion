-- Extends the ml_mesh_mgr.lua
-- Game specific OffMeshConnection Handling
-- Handler for different OMC types
function ml_mesh_mgr.HandleOMC( ... )
	if (Now() > ml_mesh_mgr.OMCThrottle and not ml_mesh_mgr.OMCStartPositionReached) then
		local args = {...}
		local OMCType = args[2]	
		local OMCStartPosition,OMCEndposition,OMCFacingDirection = ml_mesh_mgr.UnpackArgsForOMC( args )
		d("OMC REACHED : "..tostring(OMCType))
		
		if ( ValidTable(OMCStartPosition) and ValidTable(OMCEndposition) and ValidTable(OMCFacingDirection) ) then
			ml_mesh_mgr.OMCStartPosition = OMCStartPosition
			ml_mesh_mgr.OMCEndposition = OMCEndposition
			ml_mesh_mgr.OMCFacingDirection = OMCFacingDirection
			ml_mesh_mgr.OMCType = OMCType
			ml_mesh_mgr.OMCIsHandled = true -- Turn on omc handler
		end
	end
end

ml_mesh_mgr.OMCStartPosition = nil
ml_mesh_mgr.OMCEndposition = nil
ml_mesh_mgr.OMCFacingDirection = nil
ml_mesh_mgr.OMCType = nil
ml_mesh_mgr.OMCIsHandled = false
ml_mesh_mgr.OMCStartPositionReached = false
ml_mesh_mgr.OMCJumpStartedTimer = 0
ml_mesh_mgr.OMCThrottle = 0
ml_mesh_mgr.OMCLastDistance = 0
ml_mesh_mgr.OMCStartingDistance = 0
ml_mesh_mgr.OMCMeshDistance = 0
ml_mesh_mgr.OMCTarget = 0
ml_mesh_mgr.delayTimer = 0

function ml_mesh_mgr.OMC_Handler_OnUpdate( tickcount ) 
	if ( ml_mesh_mgr.OMCIsHandled ) then
		ml_global_information.lastrun = Now()
		
		if (Now() > ml_mesh_mgr.OMCThrottle) then
			-- Update IsMoving with exact data
			ml_global_information.Player_IsMoving = Player:IsMoving() or false
			ml_global_information.Player_Position = shallowcopy(Player.pos)
			-- Set all position data, pPos = Player pos, sPos = start omc pos and heading, ePos = end omc pos
			local pPos = ml_global_information.Player_Position
			local mPos,mDist = NavigationManager:GetClosestPointOnMesh(pPos)
			local sPos = {
							x = tonumber(ml_mesh_mgr.OMCStartPosition[1]), y = tonumber(ml_mesh_mgr.OMCStartPosition[2]), z = tonumber(ml_mesh_mgr.OMCStartPosition[3]),
							h = tonumber(ml_mesh_mgr.OMCFacingDirection[1]),
						}
			local ePos = {
							x = tonumber(ml_mesh_mgr.OMCEndposition[1]), y = tonumber(ml_mesh_mgr.OMCEndposition[2]), z = tonumber(ml_mesh_mgr.OMCEndposition[3]),
						}
			
			if ( ml_mesh_mgr.OMCStartPositionReached == false ) then
				if ( ValidTable(sPos) ) then
					if (ml_mesh_mgr.OMCType == "OMC_INTERACT") then						
						Player:Stop()
						-- Check for inanimate objects, use those as first guess.
						if (ml_mesh_mgr.OMCTarget == 0) then
							local interacts = EntityList("nearest,interacttype=13,maxdistance=5")
							d("Scanning for objects to interact with.")
							if (interacts) then
								local i, interact = next(interacts)
								if (interact and interact.id and interact.id ~= 0) then
									d("Chose object : "..interact.name)
									ml_mesh_mgr.OMCTarget = interact.id
								end
							end
						end
						
						-- If our target isn't 0 anymore, select it, and attempt to interact with it.
						if (ml_mesh_mgr.OMCTarget ~= 0) then
							local target = Player:GetTarget()
							if (not target or (target and target.id ~= ml_mesh_mgr.OMCTarget)) then
								local interact = EntityList:Get(tonumber(ml_mesh_mgr.OMCTarget))
								if (interact and interact.targetable) then
									d("Setting target for interaction : "..interact.name)
									Player:SetTarget(ml_mesh_mgr.OMCTarget)
									ml_mesh_mgr.OMCStartingDistance = interact.distance
									ml_mesh_mgr.OMCThrottle = Now() + 100
									return
								end		
							end
							
							ml_mesh_mgr.OMCStartPositionReached = true
							d("Starting state reached for INTERACT OMC.")
							ml_mesh_mgr.OMCThrottle = Now() + 100
						end
					end
				end
			else
				local meshdist = ml_mesh_mgr.OMCMeshDistance
				
				if ( ml_mesh_mgr.OMCType == "OMC_INTERACT" ) then
					ml_mesh_mgr.OMCThrottle = Now() + 100
					
					-- If we're now not on the starting spot, we were moved somewhere.
					local movedDistance = Distance3D(sPos.x,sPos.y,sPos.z,mPos.x,mPos.y,mPos.z)
					if (movedDistance > 3) then
						ml_mesh_mgr.OMCThrottle = Now() + 100
						ml_mesh_mgr.ResetOMC()
						return
					end
					
					if(ml_mesh_mgr.OMCTarget) then
						local interact = EntityList:Get(tonumber(ml_mesh_mgr.OMCTarget))
						if (interact) then
							Player:Interact(interact.id)
							ml_task_hub:CurrentTask():SetDelay(5000)
							ml_mesh_mgr.OMCThrottle = Now() + 500
						end
					end
					
					--if (not target or not target.targetable or target.distance > 5) then
					--	ml_mesh_mgr.OMCThrottle = Now() + 100
					--	ml_mesh_mgr.ResetOMC()
					--	return
					--end
				end
			end
		end
	end
end

function ml_mesh_mgr.ResetOMC()
	d("OMC was reset.")
	ml_mesh_mgr.OMCStartPosition = nil
	ml_mesh_mgr.OMCEndposition = nil
	ml_mesh_mgr.OMCFacingDirection = nil
	ml_mesh_mgr.OMCType = nil
	ml_mesh_mgr.OMCIsHandled = false
	ml_mesh_mgr.OMCStartPositionReached = false
	ml_mesh_mgr.OMCThrottle = 0
	ml_mesh_mgr.OMCLastDistance = 0
	ml_mesh_mgr.OMCStartingDistance = 0
	ml_mesh_mgr.OMCTarget = 0
end

function ml_mesh_mgr.UnpackArgsForOMC( args )
	if ( tonumber(args[3]) ~= nil and tonumber(args[4]) ~= nil and tonumber(args[5]) ~= nil -- OMC Start point
	 and tonumber(args[6]) ~= nil and tonumber(args[7]) ~= nil and tonumber(args[8]) ~= nil -- OMC END point
	 and tonumber(args[9]) ~= nil and tonumber(args[10]) ~= nil and tonumber(args[11]) ~= nil -- OMC Start point-Facing direction
	) then
		return {tonumber(args[3]),tonumber(args[4]),tonumber(args[5]) },{ tonumber(args[6]),tonumber(args[7]),tonumber(args[8])},{tonumber(args[9]),tonumber(args[10]),tonumber(args[11])}
	 else
		d("No valid positions for OMC reveived! ")
	 end
end


RegisterEventHandler("Gameloop.OffMeshConnectionReached",ml_mesh_mgr.HandleOMC)