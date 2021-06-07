---  (madao side common lua functions. mainly for btree)
-- todo : will merge this into helper or rename later // this name is for temporal // just for avoiding over-write mess //
eso_bt_helper = {}
function eso_bt_helper.GetRandomPointOnCricle(pos, radiusmin, radiusmin, attempt)
    local dotimes
    if attempt then
        dotimes = attempt
    else
        dotimes = 1
    end
    for i = 1, dotimes do
        local randr = math.random(radiusmin, radiusmin)
        local randd = (math.random(0, 628) - 314) / 100
        local ppos = {
            x = pos.x + randr * math.cos(randd),
            y = pos.y + randr * math.sin(randd),
            z = pos.z,
        }
        local mpos = NavigationManager:GetClosestPointOnMesh(ppos)
        if table.valid(mpos) then
            if NavigationManager:IsReachable(mpos) then
                d("reachable randomized meshpos detected ")
                return mpos
            end
        end
    end
    return false
end
if not Settings.ESOMINION.random_move_radius then
    Settings.ESOMINION.random_move_radius = 200
end

function eso_bt_helper.BT_defaultUIMain()
    local bt = BehaviorManager:GetActiveBehaviorName()
    Settings.ESOMINION.random_move_radius = GUI:SliderInt(GetString("Random Move Radius"), Settings.ESOMINION.random_move_radius, 50, 500)
    if bt == "Gather.bta" then

    elseif bt == "Grind.bta" then
        --todo: add blacklist mob (account base? character base?)
    elseif bt == "Fishing.bta" then

    end
end

-- todo: add gatherable type from setting?
-- todo: add chest here
function eso_bt_helper.Get_GatherableNearby(blacklist)
    local bl = blacklist or {}
    local el = MEntityList("gatherable")
    local nr
    for x = 1, 5 do
        if table.valid(el) then
            for i, b in pairs(el) do
                if not bl[b.id] and (not nr or nr.distance > b.distance) then
                    nr = b
                end
            end
            if nr then
                d("nearest gatherable detected. " .. tostring(nr.name))
            else
                -- no valid node detected
                return
            end
        else
            -- no valid node detected
            return
        end
        if nr then
            local el2 = MEntityList("player,maxdistance=30")
            --[[
            interactingtype:
            2 looting
            28
            ]]
            if table.valid(el2) then
                local tp = nr.pos
                for i, b in pairs(el2) do
                    if math.distance3d(tp, b.pos) < 3 and (b.interacttype == 28 or b.interacttype == 2) then
                        d("player is interacting detected node")
                        bl[b.id] = Now() + 30000
                        nr = false
                        break
                    end
                end
            end
            if nr then
                return nr.id
            end
        end
    end
end

--[[
function myOnMountFunction2(eventCode, what_this, mounted)
    d("eventCode "..tostring(eventCode).."   what_this "..tostring(what_this).."   mounted "..tostring(mounted))
    gMounted = tostring(mounted)
end
RegisterForEvent("EVENT_MOUNTED_STATE_CHANGED", true)
RegisterEventHandler("GAME_EVENT_MOUNTED_STATE_CHANGED ", myOnMountFunction2,"SomeMinionAddonName")
]]