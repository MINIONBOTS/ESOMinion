ai_unstuck = {}
ai_unstuck.stucktimer = 0
ai_unstuck.stuckcounter = 0
ai_unstuck.idletimer = 0
ai_unstuck.idlecounter = 0
ai_unstuck.respawntimer = 0
ai_unstuck.ismoving = false
ai_unstuck.lastpos = nil
ai_unstuck.Obstacles = {}
ai_unstuck.AvoidanceAreas = {}
ai_unstuck.lastmount = 0

function ai_unstuck:OnUpdate( tick )
	
	if ( ml_global_information.Player_Dead == true) then 
		ai_unstuck.Reset()
		return
	end
	
	if 	(ai_unstuck.lastpos == nil) or (ai_unstuck.lastpos and type(ai_unstuck.lastpos) ~= "table") then
		ai_unstuck.lastpos = Player.pos
		return	
	end
	
	if ( gBotMode == GetString("assistMode") ) then return end
	
	if (ml_global_information.Now - ai_mount.lastmount < 5000) then
		ai_unstuck.Reset()
		return
	end
	
	-- Stuck check for movement stucks
	if ( Player:IsMoving()) then
		local movedirs = Player:GetMovement()
		if ( not movedirs.backward and tick - ai_unstuck.stucktimer > 500 ) then
			ai_unstuck.stucktimer = tick
			local pPos = Player.pos
			if ( pPos ) then
				--d(Distance3D ( pPos.x, pPos.y, pPos.z, ai_unstuck.lastpos.x,  ai_unstuck.lastpos.y, ai_unstuck.lastpos.z))		
				local bcheck = Distance3D ( pPos.x, pPos.y, pPos.z, ai_unstuck.lastpos.x,  ai_unstuck.lastpos.y, ai_unstuck.lastpos.z) < 2.50 --4.1 normal by foot
				if ( Player.stealthstate ~= 0 ) then
					bcheck = Distance3D ( pPos.x, pPos.y, pPos.z, ai_unstuck.lastpos.x,  ai_unstuck.lastpos.y, ai_unstuck.lastpos.z) < 1.75 --2.4 crouched
				end
				
				if ( bcheck ) then					
					if ( ai_unstuck.stuckcounter > 1 ) then
						d("Seems we are stuck?")
						--if ( Player:CanMove() ) then
							Player:Jump()
						--end
					end
					if ( ai_unstuck.stuckcounter > 10 ) then
						ai_unstuck.HandleStuck()
					end
					ai_unstuck.stuckcounter = ai_unstuck.stuckcounter + 1
				else
					ai_unstuck.stuckcounter = 0
					if ( ai_unstuck.ismoving == true ) then
						Player:Stop()
						Player:SetMovement(0,2)
						Player:SetMovement(0,3)
						Player:SetMovement(0,4)
						ai_unstuck.ismoving = false
					end
				end
				ai_unstuck.lastpos = Player.pos
			end
		end
	else
		ai_unstuck.stuckcounter = 0
				
		
		-- Idle stuck check	
		if ( tick - ai_unstuck.idletimer > 6000 ) then
			ai_unstuck.idletimer = tick
			--if ( not Player:IsConversationOpen() and not Inventory:IsVendorOpened() ) then
				local pPos = Player.pos
				
				if ( pPos ) then				
					if ( Distance2D ( pPos.x, pPos.y, ai_unstuck.lastpos.x,  ai_unstuck.lastpos.y) < 0.85 ) then
						ai_unstuck.idlecounter = ai_unstuck.idlecounter + 1
						if ( ai_unstuck.idlecounter > 12 ) then -- 60 seconds of doing nothing
							d("Our bot seems to be doing nothing anymore...")
							ai_unstuck.idlecounter = 0
							ai_unstuck.HandleStuck()							
						end
					else
						ai_unstuck.idlecounter = 0
						ai_unstuck.logoutTmr = 0
					end
				end
				ai_unstuck.lastpos = Player.pos
			--end
		end
	end	
end

function ai_unstuck.HandleStuck()	
	
	-- Setting an avoidancearea at this point to hopefully find a way around it
	local pPos = Player.pos
	if ( pPos ) then
		--TODO: add proper checks for this , like is ther already a obstacle etcetc
		table.insert(ai_unstuck.AvoidanceAreas, { x=pPos.x, y=pPos.y, z=pPos.z, r=2 })
		d("adding AvoidanceArea with size "..tostring(2))
		NavigationManager:SetAvoidanceAreas(ai_unstuck.AvoidanceAreas)
		--table.insert(Dev.Obstacles, { x=pPos.x, y=pPos.y, z=pPos.z, r=2 })
		--d("Adding new Obstacle with size "..tostring(2))
		--NavigationManager:AddNavObstacles(Dev.Obstacles)
		
	end
	Player:Stop() -- force the recreation of a new path
	
	Player:SetMovement(1,2) -- try walking backwards a bit
	ml_global_information.Wait( 1500 )
	ai_unstuck.stuckcounter = 0	
end

function ai_unstuck.stuckhandler( event, distmoved, stuckcount )
	
	if ( ml_global_information.Player_Dead == true) then 
		ai_unstuck.Reset()
		return
	end
	
	if (ml_global_information.Now - ai_mount.lastmount < 5000) then
		ai_unstuck.Reset()
		return
	end
			
	if ( tonumber(stuckcount) < 8 and tonumber(stuckcount) > 0) then
		d("Stuck? Distance Moved: "..tostring(distmoved) .. " StuckCount: "..tostring(stuckcount) )
		Player:Jump()
				
		local i = math.random(0,1)
		if ( i == 0 ) then
			Player:SetMovement(1,3)
			ai_unstuck.ismoving = true
		elseif ( i == 1 ) then
			Player:SetMovement(1,4)
			ai_unstuck.ismoving = true
		end
	end
	
	if ( tonumber(stuckcount) > 20 ) then
		ml_error("We are STUCK!")
		ai_unstuck.HandleStuck()
	end
end

function ai_unstuck.Reset()
	ai_unstuck.stucktimer = 0
	ai_unstuck.stuckcounter = 0
	ai_unstuck.idletimer = 0
	ai_unstuck.idlecounter = 0
	ai_unstuck.respawntimer = 0
	ai_unstuck.ismoving = false
	ai_unstuck.lastpos = nil
	ai_unstuck.logoutTmr = 0
	Player:SetMovement(0,2)
	Player:SetMovement(0,3)
	Player:SetMovement(0,4)
end

RegisterEventHandler("Gameloop.Stuck",ai_unstuck.stuckhandler) -- gets called by c++ when using the navigationsystem
