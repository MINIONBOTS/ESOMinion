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
ai_unstuck.mesh = {} -- off mesh related
ai_unstuck.path = {} -- stuck while using ml_navigation.path and moving

function ai_unstuck:OnUpdate( tick )
	d("check unstuck")
	if ( Player.health.current < 1 ) then 
		ai_unstuck.Reset()
		return
	end
	
	if 	(ai_unstuck.lastpos == nil) or (ai_unstuck.lastpos and type(ai_unstuck.lastpos) ~= "table") then
		ai_unstuck.lastpos = Player.pos
		return	
	end
	
	if ( gBotMode == GetString("assistMode") ) then 
		return 
	end
	
	if (ml_global_information.Now - ai_mount.lastmount < 5000) then
		ai_unstuck.Reset()
		return
	end
	
	local hasCurrentPath = table.valid(ml_navigation.path)
	d("hasCurrentPath = "..tostring(hasCurrentPath))
	-- Stuck check for movement stucks
	if ( hasCurrentPath and Player.ismoving) then
		if ( not Player.ismovingbackward and tick - ai_unstuck.stucktimer > 500 ) then
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
		local size = 2
		--TODO: add proper checks for this , like is ther already a obstacle etcetc
		table.insert(ai_unstuck.AvoidanceAreas, { x=pPos.x, y=pPos.y, z=pPos.z, r=size })
		d("adding AvoidanceArea with size "..tostring(size))
		NavigationManager:SetAvoidanceAreas(ai_unstuck.AvoidanceAreas)
		--table.insert(Dev.Obstacles, { x=pPos.x, y=pPos.y, z=pPos.z, r=2 })
		--d("Adding new Obstacle with size "..tostring(2))
		--NavigationManager:AddNavObstacles(Dev.Obstacles)
		
	end
	Player:Stop() -- force the recreation of a new path
	
	--Player:SetMovement(1,2) -- try walking backwards a bit
	if ml_task_hub:CurrentTask() then
		ml_task_hub:CurrentTask():SetDelay(math.random(1500,1750))
	end
	ai_unstuck.stuckcounter = 0	
end

function ai_unstuck.HandleOffMesh(status)
    if (status == 1 or status == 7) then
        if Player.health.current == 0 then
            ud("Player is dead??")
            ai_unstuck.Reset()
            return
        end

        if ai_unstuck.enabled then
            --ml_navigation:MoveToNextNode(playerpos, lastnode, nextnode)
            -- local ms = Player:GetMovementType() / (ms ~= "Falling" and ms ~= "Jumping")  /  Player:IsOnMesh()  already considered
            ai_unstuck.mesh.count = (not ai_unstuck.mesh.count and 1) or (ai_unstuck.mesh.count + 1)
            if ai_unstuck.mesh.count > 5 then
                -- todo: add check object through RayCast later
                d("[Unstuck]: Player not on mesh. count: " .. tostring(ai_unstuck.mesh.count))
                if not table.valid(ai_unstuck.mesh.lastnode) then
                    ai_unstuck.mesh.lastnode = Player.pos
                    ai_unstuck.mesh.nextnode = NavigationManager:GetClosestPointOnMesh(Player.pos)
                    ud("assigned off-mesh-moveto")
                end
                local dist = math.distance2d(Player.pos, ai_unstuck.mesh.nextnode)
                if dist < 2 then
                    ud("reached. closest mesh position. (should be)")
                    if Player:IsMoving() then
                        Player:StopMovement()
                    end
                else
                    ml_navigation:MoveToNextNode(Player.pos, ai_unstuck.mesh.lastnode, ai_unstuck.mesh.nextnode)
                end
            else
                d("[Unstuck]: Player not on mesh. Move to closest mesh active. count: " .. tostring(ai_unstuck.mesh.count))
            end
        else
            d("[Unstuck]: Handle Off Mesh. status -1 or -7. enable: " .. tostring(ai_unstuck.enabled))
        end
        return true
    elseif ai_unstuck.mesh.lastnode then
        ai_unstuck.mesh.lastnode = false
        ai_unstuck.mesh.nextnode = false
    end
end

function ai_unstuck.HandlePathStuck(playerpos, lastnode, nextnode)
    if not ai_unstuck.enabled then
        return
    end

    if Player.health.current == 0 then
        ud("Player is dead??")
        ai_unstuck.Reset()
        return
    end

    if not ai_unstuck.path then
        ai_unstuck.ResetPathStuck()
    end


    --todo: add immobilize and stun handler here before check unstuck



    local data = ai_unstuck.path
    ---record position changed each tick
    if data.next_tick < Now() then
        data.next_tick = Now() + math.random(700, 1200)
        local stage = 0  -- means behavior stage max  1:jump
        if data.prepos then
            local now = Now()
            local threshold, removal_th = 1, 2 --todo: add threshold setting i guess.. but 1 is ok?
            local th_check = math.distance2d(playerpos, data.prepos) < threshold
            local ch
            ---add history // incase the shit is moving around somewhat// make history and compare each of them
            local active_pos
            ---consider this is as not moving // palyerpos should have unique memory address in each minion pulse due to it is called by c++ minion core
            if table.valid(data.history) then
                for pos, b in pairs(data.history) do
                    local d2 = math.distance2d(playerpos, pos)
                    if th_check and not ch and d2 < threshold then
                        ch = true
                    end
                    if d2 < removal_th then
                        data.history[pos].stage = data.history[pos].stage - 1
                        if data.history[pos].stage < 0 then
                            data.history[pos] = nil
                        end
                    else
                        data.history[pos].stage = data.history[pos].stage + 1
                        if data.history[pos].stage > stage then
                            stage = data.history[pos].stage
                            active_pos = b
                        end
                    end
                end
            end
            ---detected max unstuck stage


            if stage >= 2 then
                -- todo: add collision getter and path genereator

                ---save stuck data to file
                local rec_key
                if Settings.ESOMINION.record_unstuck then
                    if not ai_unstuck.rec_init then
                        ai_unstuck.rec_init = true
                        if not FolderExists(ai_unstuck.folderpath) then
                            FolderCreate(ai_unstuck.folderpath)
                        end
                        eso_uncstuck.rec_filename = os.date("%c", os.time()) .. ".lua"
                        eso_uncstuck.rec_data = {}
                        eso_uncstuck.rec_path = ai_unstuck.folderpath .. eso_uncstuck.rec_filename
                    end
                    rec_key = "X:" .. math.floor(active_pos.x) .. " Y:" .. math.floor(active_pos.y) .. " Z:" .. math.floor(active_pos.z)
                    if not eso_uncstuck.rec_data[rec_key] then
                        eso_uncstuck.rec_data[rec_key] = {
                            time_stamp = os.time(),
                            stuck_stage = stage,
                        }
                        FileSave(eso_uncstuck.rec_path, eso_uncstuck.rec_data)
                    end
                end

                ---need to check object infront of pc before jump
                local front_entities = ai_unstuck.CheckEntitiesInfront()
                if table.valid(front_entities) then
                    --dodge forward
                    --Search on ESOUI Source Code This function is private and cannot be used in addons :( RollDodgeStart()
                    --Search on ESOUI Source Code This function is private and cannot be used in addons :( RollDodgeStop()
                    if Player.ismounted then
                        ud("dismount / npc stuck")
                        Player:Dismount()
                        return true
                    end
                    if not data.dodge_timer or data.dodge_timer < now then
                        data.dodge_timer = now + 2000
                        ud("dodge / npc stuck")
                        Player:DodgeForward()
                        ai_unstuck.dodge_active = true
                        SettingsUUID.activations.dodge = true
                    end
                    ud("dodge / npc stuck / on timer")
                    return true
                end
                ai_unstuck.OffTriggerDodge()

                if data.jump_count <= 2 then
                    if not Player.isjumping then
                        ---check collision front line for jump
                        local front_collisions = ai_unstuck.CheckRayCastInfrontLine()
                        if not table.valid(front_collisions) then
                            Player:Jump()
                            data.jump_count = data.jump_count + 1
                            ud("unstuck and try jump")
                            return true
                        end
                    end
                end

                if stage > 5 then
                    if rec_key then
                        if eso_uncstuck.rec_data[rec_key].stuck_stage > 5 then
                            eso_uncstuck.rec_data[rec_key].stuck_stage = stage
                            FileSave(eso_uncstuck.rec_path, eso_uncstuck.rec_data)
                        end
                    end

                    EsoCommon.StopTaskWithPopUp("Bot stop due to mesh stuck")
                    if Settings.ESOMINION.use_unstuck_alarming then
                        ESOLib.Madao.AlarmWithSound(GetStartupPath() .. "\\LuaMods\\ESOminion\\Sound\\Stuck.wav")
                    end
                    return true
                end

            else
                ai_unstuck.OffTriggerDodge()
            end

        end
        data.prepos = playerpos
    end


end

function ai_unstuck.ResetPathStuck()
    ---reached next path position
    ai_unstuck.path = {
        next_tick = 0,
        history = {},
        jump_timer = 0,
        jump_count = 0,
    } -- stuck while using ml_navigation.path and moving
end
function ai_unstuck.stuckhandler( event, distmoved, stuckcount )
	
	if ( Player.dead ) then 
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
		
		--[[
		local i = math.random(0,1)
		if ( i == 0 ) then
			Player:SetMovement(1,3)
			ai_unstuck.ismoving = true
		elseif ( i == 1 ) then
			Player:SetMovement(1,4)
			ai_unstuck.ismoving = true
		end
		--]]
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
