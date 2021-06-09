local lib_common = {}
lib_common.dictionaries = {}
lib_common.ModuleFunctions = GetPrivateModuleFunctions()
lib_common.testingPath = GetStartupPath()..[[\LuaMods\ESOLib\data\]]
lib_common.API = {}
if not ESOLib then
	_G["ESOLib"] = {}
end

function lib_common.GetRandomPointOnCricle(pos, radiusmin, radiusmin, attempt)
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
lib_common.API.GetRandomPointOnCricle = lib_common.GetRandomPointOnCricle


function lib_common.BT_defaultUIMain()
    local bt = BehaviorManager:GetActiveBehaviorName()
    Settings.ESOMINION.random_move_radius = GUI:SliderInt(GetString("Random Move Radius"), IsNull(Settings.ESOMINION.random_move_radius,200), 50, 500)
    if bt == "Gather.bta" then

    elseif bt == "Grind.bta" then
        --todo: add blacklist mob (account base? character base?)
    elseif bt == "Fishing.bta" then

    end
end
lib_common.API.BT_defaultUIMain = lib_common.BT_defaultUIMain

-- todo: add gatherable type from setting?
-- todo: add chest here

lib_common.whitelistchecks = {
	["Tailoring"] = "913;1858",
	["Woodworking"] = "1860;2065",
	["Smithing"] = "1862;2067",
	["Alchemy"] = "62;97;478;514;515;517;518;520;521;522;523;524;525;526;527;2100;2101",
	["Enchanting"] = "1957",
	["Jewlery"] = "2085",
}
function lib_common.BuildWhitelist()
	local whitelist = ""
	
	for key,list in pairs (lib_common.whitelistchecks) do
		local addList = _G["gGather"..tostring(key)]
		if addList then
			if whitelist ~= "" then
				whitelist = whitelist..";"..tostring(list)
			else
				whitelist = list
			end
		end
	end
	
	return whitelist
end

function lib_common.GetNearbyGatherable(blacklist)
    local bl = blacklist or {}
    local el = MEntityList("gatherable,contentid="..tostring(lib_common.BuildWhitelist()))
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
            28 workbench
            ]]
            if table.valid(el2) then
                local tp = nr.pos
                for i, b in pairs(el2) do
                    if math.distance3d(tp, b.pos) < 3 and In(b.interacttype,28,2) then
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
lib_common.API.GetNearbyGatherable = lib_common.GetNearbyGatherable

ESOLib.Common = setmetatable({}, {__index = lib_common.API, __newindex = function() end, __metatable = false})
