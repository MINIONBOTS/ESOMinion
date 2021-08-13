---unstuck handler for eso.
---poke Madao if something goes wrong.

--[[
unlike gw2 unstuck, its only gets called when main function used inside movement loop
like in combatmovement (undone) , navigation Player:MoveTo
]]

eso_unstuck = {}
eso_unstuck.gui = { open = false; visible = false; name = GetString("Unstuck") }
eso_unstuck.folderpath = GetLuaModsPath() .. "\\ESOMinion\\UnstuckRecord\\"
eso_unstuck.updatetick = 0
eso_unstuck.stucktick = 0
eso_unstuck.stuckhistory = {}
eso_unstuck.movementtype = { forward = false; backward = false; swimpup = false; swimdown = false; }
eso_unstuck.statuscodes = {
    ENTRY_NOT_HANDLED = 1;
    ENTRY_HANDLED = 2;
    STOP_BOT = 3;
    WAYPOINT_USED = 4;
    WAYPOINT_NOT_USED = 5;
    PVP_MATCH = 6;
}
eso_unstuck.version = 1
eso_unstuck.tickdelay = 150
eso_unstuck.pvpmatch = false
eso_unstuck.enabled = true

--- eso original
eso_unstuck.mesh = {} -- off mesh related
eso_unstuck.path = {} -- stuck while using ml_navigation.path and moving

---Settings
if Settings.ESOMINION.use_unstuck == nil then
    Settings.ESOMINION.use_unstuck = true
end
if Settings.ESOMINION.use_unstuck_alarming == nil then
    Settings.ESOMINION.use_unstuck_alarming = false
end
---SettingsUUID
if SettingsUUID.activations.dodge == nil then
    SettingsUUID.activations.dodge = false
end

local function ud(str)
    d("[unstuck]: " .. tostring(str))
end
--[[
 todo : on mesh checker
 todo : sending move >> moved distance
 todo : actual unstuck behavior (raycast)
 todo : stuck log
 todo : UI
 todo : stun/immobilize >> navigation
 todo : sprint >> navigation
 todo : back to home / use wayshrine >> from passive >> pause main tree?
]]


-- todo: put this on main UI of btree
function eso_unstuck.UI()
    Settings.ESOMINION.use_unstuck = GUI:Checkbox(GetString("Use Unstuck") .. "##esominionunstuck", Settings.ESOMINION.use_unstuck)
    Settings.ESOMINION.record_unstuck = GUI:Checkbox(GetString("Record Unstuck") .. "##esominionunstuck", Settings.ESOMINION.record_unstuck)
    Settings.ESOMINION.use_unstuck_alarming = GUI:Checkbox(GetString("Use Alarming when comes to stop by stuck") .. "##esominionunstuck", Settings.ESOMINION.use_unstuck_alarming)
end

---check current  is manual mode btree (like ass  it mode) or not
function eso_unstuck.IsManualMode()
    return SettingsUUID.Btree.isManualTree[BehaviorManager:GetActiveBehaviorName()] or false
end


-- todo: add check object through RayCast later
---- located inside 'Player:MoveTo'
function eso_unstuck.ResetOffMesh()
    eso_unstuck.mesh = {} -- off mesh related
end
function eso_unstuck.HandleOffMesh(status)
    if (status == 1 or status == 7) then
        if Player.health.current == 0 then
            ud("Player is dead??")
            eso_unstuck.Reset()
            return
        end

        if eso_unstuck.enabled then
            --ml_navigation:MoveToNextNode(playerpos, lastnode, nextnode)
            -- local ms = Player:GetMovementType() / (ms ~= "Falling" and ms ~= "Jumping")  /  Player:IsOnMesh()  already considered
            eso_unstuck.mesh.count = (not eso_unstuck.mesh.count and 1) or (eso_unstuck.mesh.count + 1)
            if eso_unstuck.mesh.count > 5 then
                -- todo: add check object through RayCast later
                d("[Unstuck]: Player not on mesh. count: " .. tostring(eso_unstuck.mesh.count))
                if not table.valid(eso_unstuck.mesh.lastnode) then
                    eso_unstuck.mesh.lastnode = Player.pos
                    eso_unstuck.mesh.nextnode = NavigationManager:GetClosestPointOnMesh(Player.pos)
                    ud("assigned off-mesh-moveto")
                end
                local dist = math.distance2d(Player.pos, eso_unstuck.mesh.nextnode)
                if dist < 2 then
                    ud("reached. closest mesh position. (should be)")
                    if Player:IsMoving() then
                        Player:StopMovement()
                    end
                else
                    ml_navigation:MoveToNextNode(Player.pos, eso_unstuck.mesh.lastnode, eso_unstuck.mesh.nextnode)
                end
            else
                d("[Unstuck]: Player not on mesh. Move to closest mesh active. count: " .. tostring(eso_unstuck.mesh.count))
            end
        else
            d("[Unstuck]: Handle Off Mesh. status -1 or -7. enable: " .. tostring(eso_unstuck.enabled))
        end
        return true
    elseif eso_unstuck.mesh.lastnode then
        eso_unstuck.mesh.lastnode = false
        eso_unstuck.mesh.nextnode = false
    end
end

function eso_unstuck.ResetPathStuck()
    ---reached next path position
    eso_unstuck.path = {
        next_tick = 0,
        history = {},
        jump_timer = 0,
        jump_count = 0,
    } -- stuck while using ml_navigation.path and moving
end

--- hundle stuck case using by navigation path
--- located inside 'ml_navigation.Navigate'
--- reset once reached next path position // means not stuck so
function eso_unstuck.HandlePathStuck(playerpos, lastnode, nextnode)
    if not eso_unstuck.enabled then
        return
    end

    if Player.health.current == 0 then
        ud("Player is dead??")
        eso_unstuck.Reset()
        return
    end

    if not eso_unstuck.path then
        eso_unstuck.ResetPathStuck()
    end


    --todo: add immobilize and stun handler here before check unstuck



    local data = eso_unstuck.path
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
                    if not eso_unstuck.rec_init then
                        eso_unstuck.rec_init = true
                        if not FolderExists(eso_unstuck.folderpath) then
                            FolderCreate(eso_unstuck.folderpath)
                        end
                        eso_uncstuck.rec_filename = os.date("%c", os.time()) .. ".lua"
                        eso_uncstuck.rec_data = {}
                        eso_uncstuck.rec_path = eso_unstuck.folderpath .. eso_uncstuck.rec_filename
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
                local front_entities = eso_unstuck.CheckEntitiesInfront()
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
                        eso_unstuck.dodge_active = true
                        SettingsUUID.activations.dodge = true
                    end
                    ud("dodge / npc stuck / on timer")
                    return true
                end
                eso_unstuck.OffTriggerDodge()

                if data.jump_count <= 2 then
                    if not Player.isjumping then
                        ---check collision front line for jump
                        local front_collisions = eso_unstuck.CheckRayCastInfrontLine()
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
                eso_unstuck.OffTriggerDodge()
            end

        end
        data.prepos = playerpos
    end


end

--- call this when task started
function eso_unstuck.Reset()
    eso_unstuck.enabled = Settings.ESOMINION.use_unstuck
    d("[Unstuck]: Reset. unstuck enabled: " .. tostring(eso_unstuck.enabled))
    eso_unstuck.ResetPathStuck()
    eso_unstuck.ResetOffMesh()
end
function eso_unstuck.OnMesh()

end

function eso_unstuck.CheckEntitiesInfront()
    local el = EntityList("maxdistance=3")
    if table.valid(el) then
        local res = {}
        local pp = Player.pos
        local ph = pp.h
        for i, b in pairs(el) do
            if table.valid(b) then
                --                                    local dx, dy = -1 * (b.pos.z - pp.z), -1 * (b.pos.x - pp.x)
                --                                    local radian = ConvertHeading(math.atan2(dy, dx))
                if math.abs(ConvertHeading(math.atan2(-b.pos.z + pp.z, -b.pos.x + pp.x)) - ph) < 1.57 then
                    res[i] = b
                end
            end
        end
        return res
    end
end
function eso_unstuck.CheckRayCastInfrontLine(line_length, line_width, heights)
    local len = line_length or 2
    local width = line_width or 1
    ---check raycast 9 point in front of pc >> get 9 x 2 cordinates and raycast 9times
    --- 0.2 , 0. 6 , 1.0 of player height
    ---get 1st 2d vector
    local pp = Player.pos
    local ph = pp.h

    local dx, dy = math.cos(ph), math.sin(ph)
    local z, x = -len * dx, -len * dy
    --right
    local dx_r, dy_r = math.cos(ph - 1.57), math.sin(ph - 1.57)
    local z_r, x_r = -width * dx_r, -width * dy_r
    --left
    local dx_l, dy_l = math.cos(ph + 1.57), math.sin(ph + 1.57)
    local z_l, x_l = -width * dx_l, -width * dy_l
    local base2d = {
        center = { a = { x = pp.x, z = pp.z }, b = { x = pp.x + x, z = pp.z + z } },
        right = { a = { x = pp.x + x_r, z = pp.z + z_r }, b = { x = pp.x + x_r + x, z = pp.z + z_r + z } },
        left = { a = { x = pp.x + x_l, z = pp.z + z_l }, b = { x = pp.x + x_l + x, z = pp.z + z_l + z } },
    }
    local collision = {}
    local scale = heights or { 0.6, 1.0 }
    for _, height in pairs(scale) do
        for tag, dir in pairs(base2d) do
            for p1, pos in pairs(dir) do
                local res1 = RenderManager:RayCast(pos.a.x, height, pos.a.z, pos.b.x, height, pos.b.z)
                if res1 then
                    collision[tag .. height] = height
                end
            end
        end
    end
    return collision

end

function eso_unstuck.OffTriggerDodge()
    if eso_unstuck.dodge_active or SettingsUUID.activations.dodge then
        SettingsUUID.activations.dodge = false
        eso_unstuck.dodge_active = false
        e("RollDodgeStop()")
        ud("untag dodge")
    end
    if eso_unstuck.dodge_active_timer and eso_unstuck.dodge_active_timer > Now() then
        return true
    end
end

---todo : need to make
function Player:DodgeForward()
    local tags = { "ismovingbackward", "ismovingleft", "ismovingright", }--"ismovingforward",
    for _, b in pairs(tags) do
        if self[b] then
            self.UnSetMovement_API(i)
        end
    end
    if not Player.ismovingforward then
        Player.SetMovement_API("Forward")
    end
    ml_navigation.dodge_active_timer = Now() + 1500
    ml_navigation:UseApi("RollDodgeStart()")
end
function eso_unstuck.RecordUnstuck()

end