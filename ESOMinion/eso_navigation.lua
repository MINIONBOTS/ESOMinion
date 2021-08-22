-- Extends minionlib's ml_navigation.lua by adding the game specific navigation handler

-- Since we have different "types" of movement, add all types and assign a value to them. Make sure to include one entry for each of the 4 kinds below per movement type!
-- todo: modify stop distance along with movement speed
-- todo: make minionlib uuid setup UI for copy existing value

ml_navigation.NavPointReachedDistances = { ["Walk"] = 2, ["Diving"] = 2, ["Mounted"] = 2, ["Swimming"] = 2 }      -- Distance to the next node in the path at which the ml_navigation.pathindex is iterated
ml_navigation.PathDeviationDistances = { ["Walk"] = 2, ["Diving"] = 2, ["Mounted"] = 2, ["Swimming"] = 2 }      -- The max. distance the playerposition can be away from the current path. (The Point-Line distance between player and the last & next pathnode)
ml_navigation.GameStates = { [1] = "CHARACTERSCREEN", [2] = "MAINMENUSCREEN", [3] = "INGAME", [4] = "ERROR", [6] = "LOADING" }
ml_navigation.lastMount = 0
ml_navigation.movement_status = 0
ml_navigation.skills = {}
ml_navigation.ticks = {
    favorite_mount = 0,
    mount = 0,
    obstacle_check = 0,
    sync = 0,
    mount_leap = 0,
}

ml_navigation.thresholds = {
    mount = 2500,
    obstacle_check = 25,
    sync = 25,
}

-- gw2_obstacle_manager has control over this now
ml_navigation.avoidanceareasize = 50
ml_navigation.avoidanceareas = { }   -- TODO: make a proper API in c++ for handling a list and accessing single entries
ml_navigation.previous = {}
ml_navigation.obstacles = {
    left = {},
    right = {},
}

-- all mount related variables
ml_navigation.lastMountOMCID = nil

-----------------------------
-- ESO original
-----------------------------
--function ml_navigation.Init()
--    ml_navigation.acc_name = GetAccountName()
--end
--RegisterEventHandler("Module.Initalize", ml_navigation.Init, "ml_navigation.Init")

--[[
MOVEMENTSTATE : (cant get exact from reversed value. some may be aquirable from api)
"Walk","Falling","Jumping","Swimming","Moving","Standing"

MoveForwardStart() > MoveBackwardStart() : forward is stronger than backward (still the state assigned until undo)
the movement direction depends on camera


]]--

-- todo: need to check moutable or not somehow later
if not SettingsUUID.MountActivation.default then
    SettingsUUID.MountActivation.default = false
end

function ml_navigation.SettingUI()
    if GetGameState() == 3 and table.valid(Player) then
        local name, ch = Player.name
        if not SettingsUUID.MountActivation[name] then
            SettingsUUID.ESOMINION.MountActivation[name] = false
        end
        Settings.ESOMINION.MountActivation[name], ch = GUI:Checkbox(GetString("Use Mount (Character Bound)"), Settings.ESOMINION.MountActivation[name])
        if ch then
            Settings.ESOMINION.MountActivation = Settings.ESOMINION.MountActivation
        end
    end
end
ml_navigation.memorize_api = {}
function ml_navigation:UseApi(api, freq)
    if not self.memorize_api[api] or self.memorize_api[api].timer < Now() then
        local v1, v2, v3 = e(api)
        self.memorize_api[api] = {
            timer = Now() + (tonumber(freq) or math.random(300, 500)),
            v1 = v1,
            v2 = v2,
            v3 = v3,
        }
        d("[EsoAPI] Use API. " .. tostring(api))
        return v1, v2, v3
    else
        d("[EsoAPI] API not ready. " .. tostring(api))
        if self.memorize_api[api] then
            local data = self.memorize_api[api]
            return data.v1, data.v2, data.v3
        end
    end
end
ml_navigation.now_state = "Walk"
ml_navigation.active_timer = 0 --when call move from api
--check last time movement activated through API
ml_navigation.active_directions = {
    Forward = 0,
    Backward = 0,
    TurnLeft = 0,
    TurnRight = 0,
    StrafeLeft = 0,
    StrafeRight = 0,
}
ml_navigation.set_move_api = {
    Forward = { start = "MoveForwardStart()", stop = "MoveForwardStop()", checker = "ismovingforward", },
    Backward = { start = "MoveBackwardStart()", stop = "MoveBackwardStop()", checker = "ismovingbackward" },
    TurnLeft = { start = "TurnLeftStart()", stop = "TurnLeftStop()", checker = "ismovingleft" },
    TurnRight = { start = "TurnRightStart()", stop = "TurnRightStop()", checker = "ismovingright" },
    --StrafeLeft = { start = "StrafeLeftStart()", stop = "StrafeLeftStop()", checker = "ismovingleft" },
    --StrafeRight = { start = "StrafeRightStart()", stop = "StrafeRightStop()", checker = "ismovingright" },
}
function Player.SetMovement_API(tag, facing)
    local data = ml_navigation.set_move_api[tag]
    if data then
        if facing then
            if tonumber(facing) then
                -- todo:Calculate short distance ahead cordinate from player. ventor handling
            elseif table.valid(facing) and tonumber(facing.x) then
                Player:SetFacing(facing.x, facing.y, facing.z)
            end
        end
        if not Player[data.checker] then
            ml_navigation:UseApi(data.start)
        end
        --[[
                if ml_navigation.active_directions[tag] < Now() and not Player[ml_navigation.set_move_api[tag].checker] then
                    --if not ml_navigation.active_directions[tag] or
                    for i, b in pairs(ml_navigation.set_move_api) do
                        if i ~= tag then
                            if ml_navigation.active_directions[i] > 0 then
                                ml_navigation.active_directions[i] = 0
                                d("[Navigation Manager] Stop Assigned Movement. Direction:" .. tostring(tag))
                                e(b.stop)
                            end
                        end
                    end
                    --prevent spam
                    ml_navigation.active_directions[tag] = Now() + math.random(200, 300)
                    ---need to set camera direction before move
                    d("[Navigation Manager] Activate move. Tag:" .. tostring(tag) .. " Direction:" .. tostring(facing))
                    e(ml_navigation.set_move_api[tag].start)
                end
        ]]--
    end
end

function Player.UnSetMovement_API(tag)
    local data = ml_navigation.set_move_api[tag]
    if data and Player[data.checker] then
        ml_navigation:UseApi(data.stop)
    end
    --[[
        if ml_navigation.set_move_api[tag] and
                ml_navigation.active_directions[tag] > 0 then
            ml_navigation.active_directions[tag] = 0
            d("[Navigation Manager] Stop Assigned Movement. Direction:" .. tostring(tag))
            e(ml_navigation.set_move_api[tag].stop)
        end
    ]]--
end

--this wont stop player handling
function Player:MakeSureFowarding()
    for i, b in pairs(ml_navigation.set_move_api) do
        if i ~= "Forward" and self[b.checker] then
            self.UnSetMovement_API(i)
        end
    end
end
function Player:Stop()
    for i, b in pairs(ml_navigation.set_move_api) do
        if self[b.checker] then
            d("[Navigation Manager] stop movement. " .. tostring(i))
            self.UnSetMovement_API(i)
        end
    end
end

-- Resets Path and Stops the BotMovement
function Player:StopMovement()
    ml_navigation.obstacles = {
        left = {},
        right = {},
    }
    ml_navigation.navconnection = nil
    ml_navigation.navconnection_start_tmr = nil
    ml_navigation.pathindex = 0
    ml_navigation.turningOnMount = nil
    ml_navigation:ResetCurrentPath()
    ml_navigation:ResetOMCHandler()
    --gw2_unstuck.SoftReset()
    Player:Stop()
    NavigationManager:ResetPath()
    ml_navigation.path = {}
    ml_navigation.debug = true
    --gw2_combat_movement:StopCombatMovement()
end

ml_navigation.now_state_tick = 0
ml_navigation.mount_toggled = 0
---cant spam their api for some reason
function Player:GetMovementState()
    if self.isfalling then
        return "Falling"
    elseif self.isjumping then
        return "Jumping"
    elseif self:IsMoving() then
        if self.isswimming then
            return "WaterMoving"
        else
            return "GroundMoving"
        end
    else
        if self.isswimming then
            return "WaterStanding"
        else
            return "GroundStanding"
        end
    end
end

function Player:GetMovementType()
    if self.isswimming then
        return "Swimming"
    elseif self.ismounted then
        return "Mounted"
    else
        return "Walk"
    end
end

function Player:IsMoving()
    local tags = { "ismovingforward", "ismovingbackward", "ismovingleft", "ismovingright", }
    for _, b in pairs(tags) do
        if self[b] then
            return true
        end
    end
    return false
end
function Player:Dismount()
    if self.ismounted then
        ml_navigation:UseApi("ToggleMount()")
    end
end
function Player:IsMountMap(mapid)
    local okmaps = {

    }
    return okmaps[mapid or self.mapid] or false
end
function Player:Mount()
    if not self.ismounted then
        if self:IsMountMap() then
            ml_navigation:UseApi("ToggleMount()")
        else
            d("[Navigation Manager] - This map is not mountable. " .. tostring(self.mapid))
        end
    end
end
function Player:Jump()
    if not self.isjumping then
        ml_navigation:UseApi("JumpAscendStart()")
    end
end

function Player:IsOnMesh()
    if table.valid(Player.meshpos) then
        return NavigationManager:IsOnMeshExact(Player.meshpos)
    end
    return false
end

--e("JumpAscendStart()")
--e("TurnRightStart()")

-----------------------------
-- Movement // still need to add unstuck behaviors
-----------------------------
-- Main function to move the player. 'targetid' is optional but should be used as often as possible, if there is no target, use 0
function Player:MoveTo(x, y, z, staymounted, targetid, stoppingdistance, randommovement, smoothturns)
    -- get movement state // cant get this every pulse
    local ms = Player:GetMovementType()
    local last_dest = ml_navigation.path and ml_navigation.path[table.size(ml_navigation.path)]

    --- Check if we are synced with the world due to teleports or what not; added here to handle everything movement related.
    if (ms ~= "Falling" and ms ~= "Jumping") or not table.valid(ml_navigation.path) or
        (last_dest and math.distance3d(last_dest, { x = x, y = y, z = z }) > 5) then
		
        ml_navigation.stoppingdistance = stoppingdistance or 154
        ml_navigation.randommovement = randommovement
        ml_navigation.smoothturns = smoothturns or true
        ml_navigation.targetid = targetid or 0
        ml_navigation.staymounted = staymounted or false
        ml_navigation.debug = nil --disable debug mode
        ml_navigation.targetposition = { x = x, y = y, z = z }

        ---check npc collision here and generate evasive path
        --- mainly for npc entities
		

        if (not ml_navigation.navconnection or ml_navigation.navconnection.type == 5) then
            -- We are not currently handling a NavConnection / ignore MacroMesh Connections, these have to be replaced with a proper path by calling this exact function here
            if (ml_navigation.navconnection) then
                ---need to make unstuck
                eso_unstuck.Reset()
            end
            ml_navigation.navconnection = nil

            ---generate ml_navigation.path here
            local status = ml_navigation:MoveTo(x, y, z, targetid)
            ml_navigation.movement_status = status

            if status > 0 then
                if ms == 0 then
                    d("[Navigation] - Players Movement Mode is 0. This is mostly caused by teleports. Stepping backwards to fix.")
                    ml_navigation.Sync()
                end
            end

            -- Handle stuck if we start off mesh
            if eso_unstuck.HandleOffMesh(status) then
                -- status -7 or -1
                -- We're starting off the mesh, so return 0 (valid) to let unstuck handle moving without failing the moveto
                return 0
            end
            return status

        else
            return table.size(ml_navigation.path)
        end
    else
        if table.valid(ml_navigation.path) then
            return table.size(ml_navigation.path)
        else
            return ml_navigation.movement_status
        end
    end
end
ml_navigation.characterid = "empty"

ml_navigation.lastPathUpdate = 0
ml_navigation.lastconnectiontimer = 0
ml_navigation.pathchanged = false
function Player:BuildPath(x, y, z, floorfilters, cubefilters, targetid)
	ml_navigation.debug = nil -- this is just for being able to click "Get Path to target" in the navmanager, so you see the current path and can check  the nodes / manually optimize that path without actually start flying
	local floorfilters = IsNull(floorfilters,0,true)
	local cubefilters = IsNull(cubefilters,0,true)
	if (targetid == 0) then
		targetid = nil
	end

	--[[if (MPlayerDriving()) then
		d("[NAVIGATION]: Releasing control to Player..")
		ml_navigation:ResetCurrentPath()
		return -1337
	end]]
	
	if (x == nil or y == nil or z == nil) then -- yes this happens regularly inside fates, because some of the puzzle code calls moveto nil/nil/nil
		d("[NAVIGATION]: Invalid Move To Position :["..tostring(x)..","..tostring(y)..","..tostring(z).."]")
		return 0
	end
	
	local ppos = Player.pos	
	local newGoal = { x = x, y = y, z = z }
	
	local hasCurrentPath = table.valid(ml_navigation.path)
	local currentPathSize = table.size(ml_navigation.path)
	local sametarget = ml_navigation.lasttargetid and targetid and ml_navigation.lasttargetid == targetid -- needed, so it doesnt constantly pull a new path n doing a spinny dance on the navcon startpoint when following a moving target 
	local hasPreviousPath = hasCurrentPath and table.valid(newGoal) and table.valid(ml_navigation.targetposition) and ( (not sametarget and math.distance3d(newGoal,ml_navigation.targetposition) < 1) or sametarget )
	--if (hasPreviousPath and (ml_navigation.lastconnectionid ~= 0 or TimeSince(ml_navigation.lastPathUpdate) < 2000)) then
	if (hasPreviousPath and (ml_navigation.lastconnectionid ~= 0) and (TimeSince(ml_navigation.lastconnectiontimer) < 5000)) then
		d("[NAVIGATION]: We are currently using a Navconnection / ascending / descending, wait until we finish to pull a new path.")
		return currentPathSize
	end
	
	local distanceToGoal = math.distance2d(newGoal.x,newGoal.z,ppos.x,ppos.z)
	-- Filter things for special tasks/circumstances
	if (Player.incombat and (not Player.ismounted or not Player.mountcanfly)) 
	then
		cubefilters = bit.bor(cubefilters, GLOBAL.CUBE.AIR)
	end
	
	NavigationManager:SetExcludeFilter(GLOBAL.NODETYPE.CUBE, cubefilters)
	NavigationManager:SetExcludeFilter(GLOBAL.NODETYPE.FLOOR, floorfilters)
	
	--d("building path to ["..tostring(newGoal.x)..","..tostring(newGoal.y)..","..tostring(newGoal.z)..",floor:"..tostring(floorfilters)..",cube:"..tostring(cubefilters)..",tid:"..tostring(targetid))
	local ret = ml_navigation:MoveTo(newGoal.x,newGoal.y,newGoal.z, targetid)
	ml_navigation.lastPathUpdate = Now()
	ml_navigation.lastconnectionid = 0
	ml_navigation.lastconnectiontimer = 0
	
	if (ret <= 0) then
		if (hasPreviousPath) then
			d("[NAVIGATION]: Encountered an issue on path pull, using previous path, errors may be encountered here.")
			return currentPathSize
		else
			ml_navigation:ResetCurrentPath()
		end
		local ppos = Player.pos
		ml_navigation.startposition = { x=0, y=0, z=0 }
		ml_navigation.targetposition = { x=0, y=0, z=0 }
		ml_navigation.lasttargetid = nil
	else
		ml_navigation.startposition = { x=ppos.x, y=ppos.y, z=ppos.z }
		ml_navigation.targetposition = newGoal
		ml_navigation.lasttargetid = targetid	
	end
	
	if (ret > 0 and hasCurrentPath) then
		for _,node in pairs(ml_navigation.path) do
			ml_navigation.TagNode(node)
		end
	end
	
	--table.print(ml_navigation.path)
	return ret
end
--- Handles the Navigation along the current Path. Is not supposed to be called manually.
function ml_navigation.Navigate(event, ticks)
    if ((ticks - (ml_navigation.lastupdate or 0)) > 10) then

        if GetGameState() == 3 then
            ml_navigation.lastupdate = ticks
            local playerpos = Player.pos
            local ms = Player:GetMovementType()
            local name = Player.name
            ---init navigation
            if name ~= "" and ml_navigation.now_name ~= name then
                d("[[Navigation Manager] character init")
                local id = ml_navigation:UseApi("GetCurrentCharacterId()")
                if tonumber(id) then
                    ml_navigation.characterid = id
                    ml_navigation.now_name = name
                    if not Settings.ESOMINION[ml_navigation.characterid] then
                        Settings.ESOMINION[ml_navigation.characterid] = {}
                    end
                    if Settings.ESOMINION[ml_navigation.characterid].use_mount == nil then
                        Settings.ESOMINION[ml_navigation.characterid].use_mount = true
                    end
                else
                    d("invalid account id?")
                end
            end
            if playerpos then
                -- todo:needs to be added
                if (ml_navigation.forcereset) then
                    ml_navigation.forcereset = nil
                    Player:StopMovement()
                    return
                end

                -- todo:Sync in case we are not // mainly for mount case in gw2 (not sure need this one inside eso)
                if ml_navigation.sync ~= nil then
                    local moving = Player.ismoving
                    if ml_navigation.sync == true or not moving then
                        Player.SetMovement_API("Backward")
                        ml_navigation.sync = false
                    elseif moving then
                        Player:StopMovement()
                        ml_navigation.sync = nil
                    end
                end

                --- moveTo main
                if (not ml_navigation.debug) then
                    local allowMount = Player:IsMountMap()
                    ml_navigation.pathindex = NavigationManager.NavPathNode   -- gets the current path index which is saved in c++ ( and changed there on updating / adjusting the path, which happens each time MoveTo() is called. Index starts at 1 and 'usually' is 2 whne running
                    local pathsize = table.size(ml_navigation.path)
                    if (pathsize > 0) then
                        if (ml_navigation.pathindex <= pathsize) then
                            local lastnode = ml_navigation.pathindex > 1 and ml_navigation.path[ml_navigation.pathindex - 1] or nil
                            local nextnode = ml_navigation.path[ml_navigation.pathindex]
                            local nextnextnode = ml_navigation.path[ml_navigation.pathindex + 1]
                            local totalpathdistance = ml_navigation.path[1].pathdistance or 0
                            local movementstate = Player:GetMovementType()
                            local path_distance, check_obstacle, smooth_dismount, next_mount = 0, true

                            --- Ensure Position: Takes a second to make sure the player is really stopped at the wanted position (used for precise OMC bunnyhopping)
                            if (table.valid(ml_navigation.ensureposition) and ml_navigation:EnsurePosition(playerpos)) then
                                return
                            end

                            --- Handle Current NavConnections
                            --- nav connection 'MUST' be 'Zero' stuck since they added manually by hands so ofc
                            if (ml_navigation.navconnection) then
                                -- Temp solution to cancel navcon handling after 10 sec
                                if allowMount and
                                        (ml_navigation.navconnection_start_tmr and (ml_global_information.Now - ml_navigation.navconnection_start_tmr > 10000)) then
                                    d("[Navigation] - We did not complete the Navconnection handling in 10 seconds, something went wrong ?...Resetting Path..")
                                    ml_navigation.currentMountOMC = nil
                                    allowMount = false
                                    Player:StopMovement()
                                    return
                                end


                                --d("ml_navigation.navconnection ID " ..tostring(ml_navigation.navconnection.id))
                                --CubeCube & PolyPoly && Floor-Cube -> go straight to the end node
                                if (ml_navigation.navconnection.type == 1 or ml_navigation.navconnection.type == 2 or ml_navigation.navconnection.type == 3) then
                                    lastnode = nextnode
                                    nextnode = ml_navigation.path[ml_navigation.pathindex + 1]

                                    -- Custom OMC
                                elseif (ml_navigation.navconnection.type == 4) then

                                    local ncsubtype
                                    local ncradius
                                    local ncdirectionFromA
                                    if (ml_navigation.navconnection.details) then
                                        ncsubtype = ml_navigation.navconnection.details.subtype
                                        if (nextnode.navconnectionsideA == true) then
                                            ncradius = ml_navigation.navconnection.sideB.radius -- yes , B , not A
                                            ncdirectionFromA = true
                                        else
                                            ncradius = ml_navigation.navconnection.sideA.radius
                                            ncdirectionFromA = false
                                        end
                                    end
                                    if (ncsubtype == 1) then
                                        -- JUMP
                                        if (Player.ismounted) then
                                            Player:Dismount()
                                        end
                                        lastnode = nextnode
                                        nextnode = ml_navigation.path[ml_navigation.pathindex + 1]
                                        if (movementstate == "Jump") then
                                            if (not ml_navigation.omc_startheight) then
                                                ml_navigation.omc_startheight = playerpos.z
                                            end
                                            -- Additionally check if we are "above" the target point already, in that case, stop moving forward
                                            local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                                            Player:SetFacing(nextnode.x, nextnode.y, nextnode.z, true)
                                            if ((nodedist) < ml_navigation.NavPointReachedDistances["Walk"] or (playerpos.z < nextnode.z and (math.distance2d(playerpos, nextnode) - ncradius * 32) < ml_navigation.NavPointReachedDistances["Walk"])) then
                                                d("[Navigation] - We are above the OMC_END Node, stopping movement. (" .. tostring(math.round(nodedist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances["Walk"]) .. ")")
                                                Player:Stop()
                                                if (ncradius < 1.0) then
                                                    ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                                end
                                            else
                                                Player.SetMovement_API("Forward")
                                                --Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                                            end


                                        elseif (movementstate == "Falling" and ml_navigation.omc_startheight) then
                                            -- If Playerheight is lower than 4*omcreached dist AND Playerheight is lower than 4* our Startposition -> we fell below the OMC START & END Point
                                            if ((playerpos.z > (nextnode.z + 4 * ml_navigation.NavPointReachedDistances["Walk"])) and (playerpos.z > (ml_navigation.omc_startheight + 4 * ml_navigation.NavPointReachedDistances["Walk"]))) then
                                                if (ml_navigation.omcteleportallowed and math.distance3d(playerpos, nextnode) < ml_navigation.NavPointReachedDistances["Walk"] * 10) then
                                                    if (ncradius < 1.0) then
                                                        ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                                    end
                                                else
                                                    d("[Navigation] - We felt below the OMC start & END height, missed our goal...")
                                                    ml_navigation.StopMovement()
                                                end
                                            else
                                                -- Additionally check if we are "above" the target point already, in that case, stop moving forward
                                                local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                                                if ((nodedist) < ml_navigation.NavPointReachedDistances["Walk"] or (playerpos.z < nextnode.z and (math.distance2d(playerpos, nextnode) - ncradius * 32) < ml_navigation.NavPointReachedDistances["Walk"])) then
                                                    d("[Navigation] - We are above the OMC END Node, stopping movement. (" .. tostring(math.round(nodedist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances["Walk"]) .. ")")
                                                    Player:Stop()
                                                    if (ncradius < 1.0) then
                                                        ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                                    end
                                                else
                                                    Player:SetFacing(nextnode.x, nextnode.y, nextnode.z, true)
                                                    Player.SetMovement_API("Forward")
                                                end
                                            end

                                        else
                                            -- We are still before our Jump
                                            if (not ml_navigation.omc_startheight) then
                                                if (Player:CanMove() and ml_navigation.omc_starttimer == 0) then
                                                    ml_navigation.omc_starttimer = ticks
                                                    Player:SetFacing(nextnode.x, nextnode.y, nextnode.z, true)
                                                    Player.SetMovement_API("Forward")
                                                elseif (Player:IsMoving() and ticks - ml_navigation.omc_starttimer > 100) then
                                                    Player:Jump()
                                                end

                                            else
                                                -- We are after the Jump and landed already
                                                local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                                                if ((nodedist - ncradius * 32) < ml_navigation.NavPointReachedDistances["Walk"]) then
                                                    d("[Navigation] - We reached the OMC END Node (Jump). (" .. tostring(math.round(nodedist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances["Walk"]) .. ")")
                                                    local nextnode = nextnextnode
                                                    local nextnextnode = ml_navigation.path[ml_navigation.pathindex + 2]
                                                    if (ncradius < 1.0) then
                                                        ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                                    end
                                                    ml_navigation.pathindex = ml_navigation.pathindex + 1
                                                    NavigationManager.NavPathNode = ml_navigation.pathindex
                                                    ml_navigation.navconnection = nil

                                                else
                                                    Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
                                                    Player.SetMovement_API("Forward")
                                                end
                                            end
                                        end
                                        return

                                    elseif (ncsubtype == 2) then
                                        -- WALK
                                        lastnode = nextnode      -- OMC start
                                        nextnode = ml_navigation.path[ml_navigation.pathindex + 1]   -- OMC end

                                        local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                                        local enddist = nodedist - ncradius * 32
                                        if (enddist < ml_navigation.NavPointReachedDistances[Player:GetMovementType()]) then
                                            d("[Navigation] - We reached the OMC END Node (Walk). (" .. tostring(math.round(enddist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances[Player:GetMovementType()]) .. ")")
                                            ml_navigation.pathindex = ml_navigation.pathindex + 1
                                            NavigationManager.NavPathNode = ml_navigation.pathindex
                                            ml_navigation.navconnection = nil
                                        end
                                    elseif (ncsubtype == 3) then
                                        -- TELEPORT
                                        --                                        nextnode = ml_navigation.path[ml_navigation.pathindex + 1]
                                        --                                        --HackManager:Teleport(nextnode.x, nextnode.y, nextnode.z)
                                        --                                        ml_navigation.pathindex = ml_navigation.pathindex + 1
                                        --                                        NavigationManager.NavPathNode = ml_navigation.pathindex
                                        --                                        ml_navigation.navconnection = nil
                                        ml_error("teleport omc is invalid for eso")
                                        return

                                    elseif (ncsubtype == 4) then
                                        -- INTERACT
                                        Player:Stop()
                                        -- delay getting on mount, this can cancel whatever interacter needs to take place
                                        ml_navigation.PauseMountUsage(2000)
                                        if (not Player.ismounted and movementstate ~= ml_navigation.MOVEMENTSTATE.Jumping and movementstate ~= ml_navigation.MOVEMENTSTATE.Falling) then
                                            -- todo:check Player:interact exist
                                            Player:Interact()
                                            ml_navigation.lastupdate = ml_navigation.lastupdate + 1000
                                            ml_navigation.pathindex = ml_navigation.pathindex + 1
                                            NavigationManager.NavPathNode = ml_navigation.pathindex
                                            ml_navigation.navconnection = nil
                                        elseif (Player.ismounted) then
                                            Player:Dismount()
                                            ml_navigation.PauseMountUsage(3000)
                                        end
                                        return
                                    elseif (ncsubtype == 5) then
                                        -- PORTAL
                                        -- Check if we have reached the portal end position
                                        local portalend = ml_navigation.path[ml_navigation.pathindex + 1]
                                        if (ml_navigation:NextNodeReached(playerpos, portalend, nextnextnode)) then
                                            ml_navigation.pathindex = ml_navigation.pathindex + 1
                                            NavigationManager.NavPathNode = ml_navigation.pathindex
                                            ml_navigation.navconnection = nil

                                        else
                                            -- We need to face and move
                                            if (nextnode.navconnectionsideA == true) then
                                                Player:SetFacing(ml_navigation.navconnection.details.headingA_x, ml_navigation.navconnection.details.headingA_y, ml_navigation.navconnection.details.headingA_z)
                                            else
                                                Player:SetFacing(ml_navigation.navconnection.details.headingB_x, ml_navigation.navconnection.details.headingB_y, ml_navigation.navconnection.details.headingB_z)
                                            end
                                        end
                                        return

                                    elseif (ncsubtype == 6) then
                                        -- Custom Lua Code
                                        lastnode = nextnode      -- OMC start
                                        nextnode = nextnextnode   -- OMC end
                                        local result

                                        if (ml_navigation.navconnection.details.luacode and ml_navigation.navconnection.details.luacode and ml_navigation.navconnection.details.luacode ~= "" and ml_navigation.navconnection.details.luacode ~= " ") then

                                            if (not ml_navigation.navconnection.luacode_compiled and not ml_navigation.navconnection.luacode_bugged) then
                                                local execstring = 'return function(self,startnode,endnode) ' .. ml_navigation.navconnection.details.luacode .. ' end'
                                                local func = loadstring(execstring)
                                                if (func) then
                                                    result = func()(ml_navigation.navconnection, lastnode, nextnode)
                                                    if (ml_navigation.navconnection) then
                                                        -- yeah happens, crazy, riught ?
                                                        ml_navigation.navconnection.luacode_compiled = func
                                                    else
                                                        --ml_error("[Navigation] - Cannot set luacode_compiled, ml_navigation.navconnection is nil !?")
                                                    end
                                                else
                                                    ml_navigation.navconnection.luacode_compiled = nil
                                                    ml_navigation.navconnection.luacode_bugged = true
                                                    ml_error("[Navigation] - A NavConnection ahead in the path of type 'Lua Code' has a BUG !")
                                                    assert(loadstring(execstring)) -- print out the actual error
                                                end
                                            else
                                                --executing the already loaded function
                                                if (ml_navigation.navconnection.luacode_compiled) then
                                                    result = ml_navigation.navconnection.luacode_compiled()(ml_navigation.navconnection, lastnode, nextnode)
                                                end
                                            end

                                        else
                                            d("[Navigation] - ERROR: A 'Custom Lua Code' MeshConnection has NO lua code!...")
                                        end

                                        -- continue to walk to the omc end
                                        if (result) then
                                            -- moving on to the omc end
                                        else
                                            -- keep calling the MeshConnection
                                            return
                                        end
                                    end


                                    -- Macromesh node
                                elseif (ml_navigation.navconnection.type == 5) then
                                    -- we should not be here in the first place..c++ should have replaced any macromesh node with walkable paths. But since this is on a lot faster timer than the main bot pulse, it can happen that 4-5 pathnodes are "reached" and then a macronode appears.
                                    d("[Navigation] - Reached a Macromesh node... waiting for a path update...")
                                    Player:Stop()
                                    return

                                else
                                    d("[Navigation] - OMC BUT UNKNOWN TYPE !? WE SHOULD NOT BE HERE!!!")
                                end
                            end

                            --- Move to next node in our path
                            if (ml_navigation:NextNodeReached(playerpos, nextnode, nextnextnode)) then
                                ml_navigation.pathindex = ml_navigation.pathindex + 1
                                NavigationManager.NavPathNode = ml_navigation.pathindex
                                eso_unstuck.ResetPathStuck()
                            else
                                --- unstuck here // stuck checker
                                local unstuck = eso_unstuck.HandlePathStuck(playerpos, lastnode, nextnode)
                                -- todo:mount behavior // below is for gw2 behavior
                                --[[
                                 -- Dismount when we are close to our target position, so we can get to the actual point and not overshooting it or similiar unprecise stuff
                                -- if (pathsize - ml_navigation.pathindex < 5 and   Player.ismounted and ml_navigation.staymounted == false)then
                                if (Player.ismounted and ml_navigation.staymounted == false) then
                                    local remainingPathLenght = ml_navigation:GetRemainingPathLenght()
                                    if (remainingPathLenght ~= 0 and remainingPathLenght < 3) then
                                        d("[Navigation] - Target position reached almost and staymounted == false .")
                                        Player:Dismount()
                                    end
                                end
                                ]]

                                if unstuck then

                                else
                                    ml_navigation:MoveToNextNode(playerpos, lastnode, nextnode)
                                end
                            end
                            return
                        else
                            d("[Navigation] - Path end reached.")
                            if (Player.ismounted and ml_navigation.staymounted == false) then
                                Player:Dismount()
                            end
                            Player:StopMovement()
                            -- todo: need to make unstuck
                            eso_unstuck.Reset()
                        end
                    end
                end

                -- stoopid case catch
                if (ml_navigation.navconnection) then
                    if GetGameState() ~= 3 then
                        d("[Navigation] - Stop Player Movement. GameState: " .. tostring(ml_navigation.GameStates[GetGameState()]))
                    else
                        ml_error("[Navigation] - Breaking out of not handled NavConnection.")
                    end
                    Player:StopMovement()
                end
            end
        end
    end
end
RegisterEventHandler("Gameloop.Draw", ml_navigation.Navigate, "ml_navigation.Navigate") -- TODO: navigate on draw loop?

-- Checks if the next node in our path was reached, takes differen movements into account ( swimming, walking, riding etc. )
-- todo: UNSTUCK handler need
function ml_navigation:NextNodeReached(playerpos, nextnode, nextnextnode)

    -- take into account navconnection radius, to randomize the movement on places where precision is not needed
    local navcon
    local navconradius = 0
    if (nextnode.navconnectionid and nextnode.navconnectionid ~= 0) then
        navcon = NavigationManager:GetNavConnection(nextnode.navconnectionid)
        if (navcon) then
            if (nextnode.navconnectionsideA == true) then
                navconradius = navcon.sideA.radius -- meshspace to gamespace is *32 in GW2
            else
                navconradius = navcon.sideB.radius -- meshspace to gamespace is *32 in GW2
            end
        end
    end

    local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)

    -- local nodedist = math.distance3d(playerpos,nextnode)
    local movementstate = Player.movementstate
    local nodeReachedDistance = (movementstate == "Jumping" or movementstate == "Falling") and
            ml_navigation.NavPointReachedDistances[Player:GetMovementType()] * 2 or
            ml_navigation.NavPointReachedDistances[Player:GetMovementType()]
    --ml_error(" nodedist "..tostring(nodedist).."   nodeReachedDistance "..tostring(nodeReachedDistance))
    if ((nodedist - navconradius) < nodeReachedDistance) then

        -- d("[Navigation] - Node reached. ("..tostring(math.round(nodedist - navconradius*32,2)).." < "..tostring(ml_navigation.NavPointReachedDistances[Player:GetMovementType()])..")")
        -- We arrived at a NavConnection Node

        --self:CallCustomLuaNavConnectionsAhead(5) TEST THIS FIRST

        if (navcon) then
            d("[Navigation] -  Arrived at NavConnection ID: " .. tostring(nextnode.navconnectionid))
            ml_navigation:ResetOMCHandler()
            --gw2_unstuck.SoftReset()
            ml_navigation.navconnection = navcon
            if (not ml_navigation.navconnection) then
                ml_error("[Navigation] -  No NavConnection Data found for ID: " .. tostring(nextnode.navconnectionid))
                return false
            end
            if (navconradius > 0 and navconradius < 1.0) then
                -- kinda shitfix for the conversion of the old OMCs to the new NavCons, I set all precise connections to have a radius of 0.5
                ml_navigation:SetEnsureStartPosition(nextnode, nextnextnode, playerpos, ml_navigation.navconnection)
            end
            -- Add for now a timer to cancel the shit after 10 seconds if something really went crazy wrong
            ml_navigation.navconnection_start_tmr = ml_global_information.Now

        else
            if (ml_navigation.navconnection) then
                --gw2_unstuck.Reset()
            end
            ml_navigation.navconnection = nil
            return true
        end
    end

    return false
end

function ml_navigation:MoveToNextNode(playerpos, lastnode, nextnode)
    self.turningOnMount = nil
    -- Only check unstuck when we are not handling a navconnection
    if true then  --or ml_navigation.navconnection
        -- todo:add unstuck is on handling check for this check
        -- or (not ml_navigation.navconnection and not gw2_unstuck.HandleStuck())
        -- We have not yet reached our next node

        -- todo:waiting for powders camera distance
        local anglediff = 0 --math.angle({ x = playerpos.hx, y = playerpos.hy, z = 0 }, { x = nextnode.x - playerpos.x, y = nextnode.y - playerpos.y, z = 0 })
        local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
        if (ml_navigation.smoothturns and anglediff < 75 and nodedist > 2 * ml_navigation.NavPointReachedDistances[Player:GetMovementType()]) then
            Player:SetFacing(nextnode.x, nextnode.y, nextnode.z)
        else
            local ncsubtype = ml_navigation.navconnection and ml_navigation.navconnection.details and ml_navigation.navconnection.details.subtype
            if not ml_global_information.Player_InCombat or not ncsubtype or (ncsubtype ~= 7 and ncsubtype ~= 8 and ncsubtype ~= 9) then
                Player:SetFacing(nextnode.x, nextnode.y, nextnode.z, true)
            end
        end

        -- Make sure we are not strafing away (happens sometimes after being dead + movement was set)
        Player:MakeSureFowarding()
        local ncsubtype = ml_navigation.navconnection and ml_navigation.navconnection.details and
                ml_navigation.navconnection.details.subtype
        if not ncsubtype or
                (ncsubtype ~= 7 and ncsubtype ~= 8 and ncsubtype ~= 9) or
                (nodedist > ml_navigation.NavPointReachedDistances["Walk"]) then
            Player.SetMovement_API("Forward")
            self:IsStillOnPath(playerpos, lastnode, nextnode, ml_navigation.PathDeviationDistances[Player:GetMovementType()])
        end

        ---perhaps need handling below
        --[[
                if (Player.mounted) then
                    -- Calc heading difference between player and next node
                    local ppos = Player.pos
                    local radianA = math.atan2(ppos.hx, ppos.hy)
                    local radianB = math.atan2(nextnode.x - ppos.x, nextnode.y - ppos.y)
                    local twoPi = 2 * math.pi
                    local diff = (radianB - radianA) % twoPi
                    local s = diff < 0 and -1.0 or 1.0
                    local res = diff * s < math.pi and diff or (diff - s * twoPi)

                    --Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                    Player.SetMovement_API("Forward")
                    self:IsStillOnPath(playerpos, lastnode, nextnode, ml_navigation.PathDeviationDistances[Player:GetMovementType()])



                    if (res > 0.75 or res < -0.75) then
                        self.turningOnMount = true
                        local mountSpeed = HackManager:GetSpeed()
                        if (mountSpeed > 450) then
                            Player:SetMovement(GW2.MOVEMENTTYPE.Backward)
                        elseif (mountSpeed > 400) then
                            Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward) -- stopping forward movement until we are facing the node
                            Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                        elseif (mountSpeed > 350) then
                            Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                        end
                        --d("TURNING : "..tostring(res))
                        gw2_unstuck.stucktick = ml_global_information.Now + 500 -- the unstuck kicks in too often when we are still turning on our sluggish slow mount...
                    else
                        Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                        self:IsStillOnPath(playerpos, lastnode, nextnode, ml_navigation.PathDeviationDistances[Player:GetMovementType()])
                    end


                else
                    local ncsubtype = ml_navigation.navconnection and ml_navigation.navconnection.details and ml_navigation.navconnection.details.subtype
                    if not ncsubtype or (ncsubtype ~= 7 and ncsubtype ~= 8 and ncsubtype ~= 9) or (ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode) > ml_navigation.NavPointReachedDistances["Walk"]) then
                        Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                        self:IsStillOnPath(playerpos, lastnode, nextnode, ml_navigation.PathDeviationDistances[Player:GetMovementType()])
                    end
                end
        ]]--

    end
    return false
end
--[[  UNTESTED AND NEEDS MOST LIKELY FIXING
function ml_navigation:CallCustomLuaNavConnectionsAhead(maxAheadCount)
	local pathsize = table.size(ml_navigation.path)
	local pstartindex = ml_navigation.pathindex
	local pindex = ml_navigation.pathindex
	if ( pathsize > 0 ) then
		while ( pindex < pathsize and pindex < (pstartindex + maxAheadCount)) do
			local lastnode = ml_navigation.path[ pindex ]	-- OMC start
			local nextnode = ml_navigation.path[ ml_navigation.pathindex + 1]	-- OMC end

			if( nextnode.navconnectionid and nextnode.navconnectionid ~= 0) then
				local navcon = NavigationManager:GetNavConnection(nextnode.navconnectionid)
				if ( navcon and navcon.type == 4 and navcon.details and navcon.details.subtype == 6) then -- Custom OMC / -- Custom Lua Code

					if ( navcon.details.luacode and navcon.details.luacode and navcon.details.luacode ~= "" ) then
						local execstring = 'return function(self,startnode,endnode) '..navcon.details.luacode..' end'
						local func = loadstring(execstring)
						if ( func ) then
							func()(ml_navigation.navconnection, lastnode, nextnode)
						else
							ml_error("[Navigation] - A 'Custom Lua Code' NavConnection ahead in the path has a BUG !")
							assert(loadstring(execstring)) -- print out the actual error
						end
					else
						d("[Navigation] - ERROR: A 'Custom Lua Code' NavConnection ahead in the path has NO lua code!...")
					end
				end
			end
			pindex = pindex + 1
		end
	end
end]]

function ml_navigation:GetRemainingPathLenght()
    local pathLength = 0
    local pathNodeCount = #self.path
    local lastNodePosition = Player.pos

    if (self.pathindex < pathNodeCount) then
        for pathNodeID = self.pathindex + 1, pathNodeCount do
            local pathNode = self.path[pathNodeID]
            pathLength = pathLength + math.distance3d(lastNodePosition, pathNode)
            lastNodePosition = pathNode
        end

    else
        if (self.pathindex == pathNodeCount) and self.path[pathNodeCount] and lastNodePosition then
            pathLength = math.distance3d(lastNodePosition, self.path[pathNodeCount])
        end
    end

    return pathLength
end

function ml_navigation:DistanceToNextNavConnection()
    local pathLength = 0
    local pathNodeCount = #self.path
    local lastNodePosition = Player.pos

    if (self.pathindex < pathNodeCount) then
        for pathNodeID = self.pathindex + 1, pathNodeCount do
            local pathNode = self.path[pathNodeID]
            pathLength = pathLength + math.distance3d(lastNodePosition, pathNode)
            lastNodePosition = pathNode
            if (pathNode.navconnectionid ~= 0) then
                return pathLength
            end
        end
    end

    return 999999
end


-- Calculates the Point-Line-Distance between the PlayerPosition and the last and the next PathNode. If it is larger than the treshold, it returns false, we left our path.
function ml_navigation:IsStillOnPath(ppos, lastnode, nextnode, deviationthreshold)
    if (lastnode) then
        -- Dont use this when we crossed / crossing a navcon
        if (lastnode.navconnectionid == 0) then


            local from = { x = lastnode.x, y = lastnode.y, z = 0 }
            local to = { x = nextnode.x, y = nextnode.y, z = 0 }
            local playerpos = { x = ppos.x, y = ppos.y, z = 0 }
            local movstate = Player:GetMovementState()
            if (movstate ~= "Jumping" and movstate ~= "Falling" and math.distancepointline(from, to, playerpos) > deviationthreshold) then
                d("[Navigation] - Player left the path - 2D-Distance to Path: " .. tostring(math.distancepointline(from, to, playerpos)) .. " > " .. tostring(deviationthreshold))
                --NavigationManager:UpdatePathStart()  -- this seems to cause some weird twitching loops sometimes..not sure why
                NavigationManager:ResetPath()
                ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                return false
            end
            ---when comes to handling 3d
            --[[
                        if (Player.swimming ~= GW2.SWIMSTATE.Diving2) then
                            -- Ignoring up vector, since recast's string pulling ignores that as well

                        else
                            -- Under water, using 3D
                            if (movstate ~= ml_navigation.MOVEMENTSTATE.Jumping and movstate ~= ml_navigation.MOVEMENTSTATE.Falling and math.distancepointline(lastnode, nextnode, ppos) > deviationthreshold) then
                                d("[Navigation] - Player not on Path anymore. - Distance to Path: " .. tostring(math.distancepointline(lastnode, nextnode, ppos)) .. " > " .. tostring(deviationthreshold))
                                --NavigationManager:UpdatePathStart()
                                NavigationManager:ResetPath()
                                ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                                return false
                            end
                        end
            ]]--
        end
    end
    return true
end

-- Tries to use RayCast to determine the exact floor height from Player and Node, and uses that to calculate the correct distance.
function ml_navigation:GetRaycast_Player_Node_Distance(ppos, node)
    -- Raycast from "top to bottom" @PlayerPos and @NodePos
    local P_hit, P_hitx, P_hity, P_hitz = RenderManager:RayCast(ppos.x, ppos.y - 1.2, ppos.z, ppos.x, ppos.y + 2.5, ppos.z)
    local N_hit, N_hitx, N_hity, N_hitz = RenderManager:RayCast(node.x - 0.25, node.y - 1.2, node.z - 0.25, node.x, node.y + 2.5, node.z)
    local dist = math.distance3d(ppos, node)

    -- To prevent spinny dancing when we are unable to reach the 3D targetposition due to whatever reason , a little safety check here
    if (not self.lastpathnode or self.lastpathnode.x ~= node.x or self.lastpathnode.y ~= node.y or self.lastpathnode.z ~= node.z) then
        self.lastpathnode = node
        self.lastpathnodedist = nil
        self.lastpathnodecloser = 0
        self.lastpathnodefar = 0
    else

        if Player:IsMoving() then
            -- we are still moving towards the same node
            local dist2d = ml_navigation:GetRemainingPathLenght()
            if (dist2d < 5 * ml_navigation.NavPointReachedDistances[Player:GetMovementType()]) then
                -- count / record if we are getting closer to it or if we are spinning around
                if (self.lastpathnodedist) then
                    if (dist2d <= self.lastpathnodedist) then
                        self.lastpathnodecloser = self.lastpathnodecloser + 1
                    else
                        if (self.lastpathnodecloser > 1) then
                            -- start counting after we actually started moving closer, else turns or at start of moving fucks the logic
                            d("self.lastpathnodedist = " .. tostring(self.lastpathnodedist))
                            d("current dist = " .. tostring(dist2d))
                            --self.lastpathnodefar = self.lastpathnodefar + 1
                        end
                    end
                end
                self.lastpathnodedist = dist2d
            end

            if (self.lastpathnodefar > 3) then
                d("[Navigation] - Loop detected, going back and forth too often - reset navigation.. " .. tostring(dist2d) .. " ---- " .. tostring(self.lastpathnodefar))
                ml_navigation.forcereset = true
                return 0 -- should make the calling logic "arrive" at the node
            end
        end
    end

    if (P_hit and N_hit) then
        local raydist = math.distance3d(P_hitx, P_hity, P_hitz, N_hitx, N_hity, N_hitz)
        if (raydist < dist) then
            -- d("return ray dist")
            return raydist
        end
    end
    -- d("return dist")
    return dist
end

-- Sets the position and heading which the main call will make sure that it has before continuing the movement. Used for NavConnections / OMC
function ml_navigation:SetEnsureStartPosition(currentnode, nextnode, playerpos, navconnection)
    Player:Stop()
    self.ensureposition = { x = currentnode.x, y = currentnode.y, z = currentnode.z }

    if (navconnection.details) then
        if (currentnode.navconnectionsideA == true) then
            self.ensureheading = { hx = navconnection.details.headingA_x, hy = navconnection.details.headingA_y, hz = navconnection.details.headingA_z }
        else
            self.ensureheading = { hx = navconnection.details.headingB_x, hy = navconnection.details.headingB_y, hz = navconnection.details.headingB_z }
        end
        self.ensureheadingtargetpos = nil

    else
        -- this still a thing ?
        -- TODO: Is this ever showing up? if so, then leave it. probs old nav crap
        ml_error("DO NOT REMOVE ME!!!")
        if (currentnode.navconnectionsideA == true) then
            self.ensureheadingtargetpos = { x = navconnection.sideA.x, y = navconnection.sideA.y, z = navconnection.sideA.z }
        else
            self.ensureheadingtargetpos = { x = navconnection.sideB.x, y = navconnection.sideB.y, z = navconnection.sideB.z }
        end
        self.ensureheading = nil
    end

    self:EnsurePosition(playerpos)
end
function ml_navigation:SetEnsureEndPosition(currentnode, nextnode, playerpos)
    Player:Stop()
    self.ensureposition = { x = currentnode.x, y = currentnode.y, z = currentnode.z }
    if (nextnode) then
        self.ensureheadingtargetpos = { x = nextnode.x, y = nextnode.y, z = nextnode.z }
    end
    self:EnsurePosition(playerpos)
end


-- Ensures that the player is really at a specific position, stopped and facing correctly. Used for NavConnections / OMC
function ml_navigation:EnsurePosition(playerpos)
    if (Player.ismounted) then
        Player:Dismount()
        ml_navigation.PauseMountUsage(5000)
    end
    if (not self.ensurepositionstarttime) then
        self.ensurepositionstarttime = ml_global_information.Now
    end

    --[[
        local dist = self:GetRaycast_Player_Node_Distance(playerpos, self.ensureposition)
        if (dist > 15) then
            HackManager:Teleport(self.ensureposition.x, self.ensureposition.y, self.ensureposition.z)
        end
    ]]--

    if ((ml_global_information.Now - self.ensurepositionstarttime) < 750 and
            ((self.ensureheading and Player:IsFacing(self.ensureheading.hx, self.ensureheading.hy, self.ensureheading.hz) ~= 0) or
                    (self.ensureheadingtargetpos and Player:IsFacing(self.ensureheadingtargetpos.x, self.ensureheadingtargetpos.y, self.ensureheadingtargetpos.z) ~= 0))) then

        if (Player:IsMoving()) then
            Player:Stop()
        end
        --[[
        local dist = self:GetRaycast_Player_Node_Distance(playerpos, self.ensureposition)

        if (dist > 15) then
            HackManager:Teleport(self.ensureposition.x, self.ensureposition.y, self.ensureposition.z)
        end
        ]]--

        if (self.ensureheading) then
            Player:SetFacing(self.ensureheading.hx, self.ensureheading.hy, self.ensureheading.hz)
        elseif (self.ensureheadingtargetpos) then
            Player:SetFacing(self.ensureheadingtargetpos.x, self.ensureheadingtargetpos.y, self.ensureheadingtargetpos.z, true)
        end

        return true

    else
        -- We waited long enough
        self.ensureposition = nil
        self.ensureheading = nil
        self.ensureheadingtargetpos = nil
        self.ensurepositionstarttime = nil
    end
    return false
end

-- lookahead, number of nodes to look ahead for an omc
-- returns true if there is an omc on our path
function ml_navigation:OMCOnPath(lookahead)
    lookahead = lookahead or 3

    local pathsize = table.size(ml_navigation.path)

    lookahead = lookahead > pathsize and pathsize or lookahead

    if (pathsize > 0) then
        for i = 1, lookahead do
            local node = ml_navigation.path[i]
            if (node.navconnectionid ~= 0) then
                return true
            end
        end
    end

    return false
end


-- param = {mindist, raycast, path, startpos}
-- mindist, minimum distance to get a position
-- raycast, set to false to disable los checks
-- path, provide an alternate path then the current navigation path
-- startpos, provide an alternate starting position. player position by default
-- returns a pos nearest to the minimum distance or nil
function ml_navigation:GetPointOnPath(param)
    local startpos = param.startpos ~= nil and param.startpos or ml_global_information.Player_Position

    local raycast = true
    if (param.raycast ~= nil) then
        raycast = param.raycast
    end

    local mindist = param.mindist ~= nil and param.mindist or 0
    local path = param.path ~= nil and param.path or ml_navigation.path
    local pathsize = table.size(path)
    local prevnode = Player.pos

    if (pathsize > 0 and mindist > 0) then
        local traversed
        for i = 1, pathsize do
            local node = path[i]
            local dist = math.distance3d(node, startpos)

            if (dist >= mindist) then
                local disttoprev = math.distance3d(prevnode, node)
                local newpos = {
                    x = prevnode.x + (traversed / disttoprev) * (node.x - prevnode.x);
                    y = prevnode.y + (traversed / disttoprev) * (node.y - prevnode.y);
                    z = prevnode.z + (traversed / disttoprev) * (node.z - prevnode.z);
                }

                if (not raycast) then
                    return newpos
                end

                local hit, hitx, hity, hitz = RenderManager:RayCast(startpos.x, startpos.y, startpos.z, newpos.x, newpos.y, newpos.z)
                if (not hit) then
                    return newpos
                end
            end

            prevnode = node
            traversed = mindist - dist
        end
    end

    return nil
end

-- Get a node that is further away then min distance
function ml_navigation:GetNearestNodeToDistance(mindist, startpos)
    startpos = startpos or ml_global_information.Player_Position

    local pathsize = table.size(ml_navigation.path)

    if (pathsize > 0) then
        for i = 1, pathsize do
            local node = ml_navigation.path[i]
            local pos = { x = node.x, y = node.y, z = node.z }
            if (math.distance3d(startpos, pos) >= mindist) then
                return pos, i
            end
        end
    end

    return nil
end


-- Resets all OMC related variables
function ml_navigation:ResetOMCHandler()
    self.omc_id = nil
    self.omc_traveltimer = nil
    self.ensureposition = nil
    self.ensureheading = nil
    self.ensureheadingtargetpos = nil
    self.ensurepositionstarttime = nil
    self.omc_starttimer = 0
    self.omc_startheight = nil
    self.navconnection = nil
    self.turningOnMount = nil
end

function ml_navigation.PauseMountUsage(time)
    time = type(time) == "number" and time or 500
    ml_navigation.lastMount = ml_global_information.Now + time
end

---this one is for gw2 not modified to eso
function ml_navigation.ObstacleCheck(input_distance, amount, front, front_amount)
    local hit = {
        left = 0,
        right = 0,
        frontal = 0,
    }
    local no_hit = {
        frontal = {},
    }
    local size = Player.height + 5
    local width = Player.radius + 2
    amount = amount == nil and 8 or amount
    front_amount = front_amount or 15
    local p = Player.pos
    local staymounted, ray_distance = true

    local nav_node = ml_navigation.path[ml_navigation.pathindex]
    if nav_node then
        local dis = math.distance3d(p, nav_node)
        local vec = {
            x = (nav_node.x - p.x) / dis,
            y = (nav_node.y - p.y) / dis,
            z = (nav_node.z - p.z) / dis
        }
        local vech = math.atan2(vec.y, vec.x)
        local vec_perp_L = {
            hx = -math.sin(vech),
            hy = math.cos(vech)
        }
        local vec_perp_R = {
            hx = math.sin(vech),
            hy = -math.cos(vech)
        }
        local distance = input_distance
        hit.frontal = 0
        no_hit.frontal = {}
        local ahead_loc = {
            x = p.x + (distance * vec.x),
            y = p.y + (distance * vec.y),
            z = p.z + (distance * vec.z)
        }

        local frontal = {
            x = p.x + ((distance + 25) * vec.x),
            y = p.y + ((distance + 25) * vec.y),
            z = p.z + ((distance + 25) * vec.z)
        }

        local frontal_dis = math.distance3d(p, frontal)
        if frontal_dis > dis then
            frontal = {
                x = p.x + ((dis + 25) * vec.x),
                y = p.y + ((dis + 25) * vec.y),
                z = p.z + ((dis + 25) * vec.z),
            }
        end

        --- RayCasts
        local Rays = {
            down = {},
            up = {},
            left = {},
            right = {},
            frontal = {}
        }

        Rays.down.hit, Rays.down.x, Rays.down.y, Rays.down.z = RenderManager:RayCast(ahead_loc.x, ahead_loc.y, ahead_loc.z - (size / 2), ahead_loc.x, ahead_loc.y, ahead_loc.z + (size / 2))
        if Rays.down.hit then
            local z = {
                feet = Rays.down.z - 25,
                head = Rays.down.z - size,
            }

            Rays.up.hit, Rays.up.x, Rays.up.y, Rays.up.z = RenderManager:RayCast(ahead_loc.x, ahead_loc.y, z.feet, ahead_loc.x, ahead_loc.y, z.head)

            local left = {
                x = ahead_loc.x + (width * 2 * vec_perp_L.hx),
                y = ahead_loc.y + (width * 2 * vec_perp_L.hy)
            }
            local right = {
                x = ahead_loc.x + (width * 2 * vec_perp_R.hx),
                y = ahead_loc.y + (width * 2 * vec_perp_R.hy)
            }

            if amount then
                local step = -(z.feet - z.head) / amount

                for height = z.feet, z.head, step do
                    local l = {
                        ray = {},
                        start = {
                            x = ahead_loc.x,
                            y = ahead_loc.y,
                            z = height,
                        },
                        dest = {
                            x = left.x,
                            y = left.y,
                            z = height,
                        },
                    }
                    l.ray.hit, l.ray.x, l.ray.y, l.ray.z = RenderManager:RayCast(ahead_loc.x, ahead_loc.y, height, left.x, left.y, height)
                    hit.left = hit.left + (l.ray.hit and 1 or 0)
                    ray_distance = math.distance2d(l.ray, ahead_loc)
                    if l.ray.hit and (not ml_navigation.obstacles.right[ml_global_information.Now] or ml_navigation.obstacles.right[ml_global_information.Now].distance > ray_distance) then
                        ml_navigation.obstacles.right[ml_global_information.Now] = { x = ahead_loc.x, y = ahead_loc.y, z = height, distance = ray_distance }
                    end

                    local r = {
                        ray = {},
                        start = {
                            x = ahead_loc.x,
                            y = ahead_loc.y,
                            z = height,
                        },
                        dest = {
                            x = right.x,
                            y = right.y,
                            z = height,
                        },
                    }
                    r.ray.hit, r.ray.x, r.ray.y, r.ray.z = RenderManager:RayCast(ahead_loc.x, ahead_loc.y, height, right.x, right.y, height)
                    hit.right = hit.right + (r.ray.hit and 1 or 0)
                    ray_distance = math.distance2d(r.ray, ahead_loc)
                    if r.ray.hit and (not ml_navigation.obstacles.right[ml_global_information.Now] or ml_navigation.obstacles.right[ml_global_information.Now].distance > ray_distance) then
                        ml_navigation.obstacles.right[ml_global_information.Now] = { x = ahead_loc.x, y = ahead_loc.y, z = height, distance = ray_distance }
                    end
                end
            end

            if front then
                local step = (z.head - z.feet) / front_amount
                local prev_f
                for height = z.feet, z.head, step do
                    local f = {
                        ray = {},
                    }
                    f.ray.hit, f.ray.x, f.ray.y, f.ray.z = RenderManager:RayCast(ahead_loc.x, ahead_loc.y, height, frontal.x, frontal.y, height)
                    if f.ray.hit then
                        if prev_f and prev_f.hit then
                            local lowerdist = math.distance2d(prev_f, ahead_loc)
                            local upperdist = math.distance2d(f.ray, ahead_loc)

                            local dist = upperdist - lowerdist
                            local slope = (prev_f.z - f.ray.z) / dist

                            if slope > 1.5 or slope < 0 then
                                hit.frontal = hit.frontal + (f.ray.hit and 1 or 0)
                                no_hit.frontal = {}
                            end
                        end
                    else
                        table.insert(no_hit.frontal, math.abs(height) - math.abs(z.feet))
                    end

                    prev_f = f.ray
                end
            end
            if amount then
                if ml_navigation.obstacles.right[ml_global_information.Now] and ml_navigation.obstacles.left[ml_global_information.Now] then
                    if math.distance2d(ml_navigation.obstacles.right[ml_global_information.Now], ml_navigation.obstacles.left[ml_global_information.Now]) > (width * 2) then
                        return true
                    end
                end
            end
            if front and hit.frontal > 0 then
                return true, table.size(no_hit.frontal)
            end

            if amount then
                if table.valid(ml_navigation.obstacles.right) and table.valid(ml_navigation.obstacles.left) then
                    for r_time, right in table.pairsbykeys(ml_navigation.obstacles.right) do
                        if TimeSince(r_time) < 2500 then
                            for l_time, left in table.pairsbykeys(ml_navigation.obstacles.left) do
                                if TimeSince(l_time) < 2500 then
                                    if math.distance2d(left, right) < (width * 2) then
                                        return true
                                    end
                                else
                                    ml_navigation.obstacles.left[l_time] = nil
                                end
                            end
                        else
                            ml_navigation.obstacles.left[r_time] = nil
                        end
                    end
                end
            end
        end
    end
end

function ml_navigation.Sync(ms)
    ml_navigation.sync = true
end
