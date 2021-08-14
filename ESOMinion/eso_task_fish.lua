eso_fish = {}
eso_fish.attemptedCasts = 0
eso_fish.biteDetected = 0
eso_fish.firstRun = nil
eso_fish.firstRunCompleted = false
eso_fish.profilePath = GetStartupPath()..[[\LuaMods\esominion\FishProfiles\]]
eso_fish.currentTaskIndex = 0
eso_fish.thisPosition = {}
eso_fish.lastPosition = {}
eso_fish.needbaits = false
eso_fish.currenttask = {}
eso_fish.gatherbaitid = 0
eso_fish.killtargetid = 0
eso_fish.idLockoutattempts = {}
eso_fish.lockoutids = {}
eso_fish.baitstring = "29849;48922;48923;48924;48925;48926;74219;74225;74226;74227"

eso_fish.GUI = {
	x = 0,
	y = 0, 
	height = 0,
	width = 0,
}

eso_task_fish = inheritsFrom(ml_task)
eso_task_fish.addon_process_elements = {}
eso_task_fish.addon_overwatch_elements = {}
function eso_task_fish.Create()	
	local newinst = {}
	
	--ml_task members
	newinst.valid = true
	newinst.completed = false
	newinst.subtask = nil
	newinst.auxiliary = false
	newinst.process_elements = {}
	newinst.overwatch_elements = {}
	newinst.name = "LT_FISH"
	
	--eso_task_fish members
	newinst.castTimer = 0
	newinst.markerTime = 0
	ml_global_information.lastEquip = 0
	
	newinst.currentMarker = false
	ml_marker_mgr.currentMarker = nil
	
	newinst.filterLevel = true
	newinst.networkLatency = 0
	newinst.requiresAdjustment = false
	newinst.requiresRelocate = false
	
	eso_fish.currentTask = {}
	eso_fish.currentTaskIndex = 0
	eso_fish.attemptedCasts = 0
	eso_fish.biteDetected = 0
	eso_fish.firstRunCompleted = false
		
	setmetatable(newinst, { __index = eso_task_fish })
	return newinst
end

function fd(var,level)
	local level = tonumber(level) or 3
	
	local requiredLevel = gFishDebugLevel
	if (gBotMode == GetString("questMode") and gQuestDebug) then
		requiredLevel = gQuestDebugLevel
	end
	
	if ( gFishDebug or (gQuestDebug and gBotMode == GetString("questMode"))) then
		if ( level <= tonumber(requiredLevel)) then
			if (type(var) == "string") then
				d("[L"..tostring(level).."]["..tostring(Now()).."]: "..var)
			elseif (type(var) == "number" or type(var) == "boolean") then
				d("[L"..tostring(level).."]["..tostring(Now()).."]: "..tostring(var))
			elseif (type(var) == "table") then
				outputTable(var)
			end
		end
	end
end

function eso_fish.GetDirective()
	local marker = ml_marker_mgr.currentMarker
	local task = eso_fish.currentTask
	
	if (table.valid(task)) then
		return task, "task"
	elseif (table.valid(marker)) then
		return marker, "marker"
	end
	
	return nil
end

function eso_fish.HasDirective()
	local marker = ml_marker_mgr.currentMarker
	local task = eso_fish.currentTask
	
	return (table.valid(task) or table.valid(marker))
end

function HasBaits(name)
	local inventories = {0,1,2,3}
	local itemid = 0
	local name = name or ""
	
	if (name ~= "") then
		for bait in StringSplit(name,",") do
			if (tonumber(bait) ~= nil) then
				itemid = tonumber(bait)
			else
				--fd("[HasBaits] Searching for bait ID for ["..IsNull(bait,"").."].",3)
				itemid = AceLib.API.Items.GetIDByName(bait)
			end

			if (itemid) then
				local item = GetItem(itemid,inventories)
				if (item) then
					return true
				end
			end
		end
	else
		return false
	end
	
	return false
end

function GetCurrentTaskPos(meshcheck)
	local pos = {}
	local meshcheck = IsNull(meshcheck,true)
	
	local task = eso_fish.currentTask
	if (table.valid(task)) then
		if (task.maxPositions > 0) then
			local taskMultiPos = task.multipos
			if (table.valid(taskMultiPos)) then
				if (table.valid(taskMultiPos[task.currentPositionIndex])) then
					pos = taskMultiPos[task.currentPositionIndex]
					if (meshcheck) then
						pos = NavigationManager:GetClosestPointOnMesh(pos)
						pos.h = taskMultiPos[task.currentPositionIndex].h
					end
				else
					for i,choice in pairs(taskMultiPos) do
						if (table.valid(choice)) then
							eso_fish.currentTask.currentPositionIndex = i
							pos = choice
							if (meshcheck) then
								pos = NavigationManager:GetClosestPointOnMesh(pos)
								pos.h = choice.h
							end
							break
						end
					end
				end
			end
		else
			local taskPos = task.pos
			if (table.valid(taskPos)) then
				pos = taskPos
			end
		end
	end

	return pos
end

function GetNextTaskPos()
	local newIndex,newPos = nil,{}
	
	local multipos = eso_fish.currentTask.multipos
	local attempted = eso_fish.currentTask.attemptedPositions
	local rerollMap = {}
	
	if (table.valid(multipos)) then
		for k,v in pairs(multipos) do
			if (not table.valid(attempted) or not attempted[k]) then
				table.insert(rerollMap,k)
			end
		end
		
		if (table.size(rerollMap) > 0) then
			local actual = rerollMap[math.random(1,table.size(rerollMap))]
			if (actual) then
				newIndex = actual
				newPos = multipos[actual]
			end		
		end
	end

	return newIndex, newPos
end

c_cast = inheritsFrom( ml_cause )
e_cast = inheritsFrom( ml_effect )
c_cast.doblock = false
c_cast.blocktime = 0
function c_cast:evaluate()
-- SetFishingLure(number lureIndex) 
-- GetFishingLure()
-- GetNumFishingLures() 
	local TargetList = MEntityList("maxdistance=20,contentid=909;910;911;912")
	if not TargetList then
		return false
	end

	local currentBait = IsNull(e("GetFishingLure()"),0)
	if (currentBait == 0) then
		e_setbait.needbait = true
		return false
	end
	if TimeSince(c_cast.blocktime) < 5000 then
		return false
	end
	c_cast.doblock = false
	if Player.isswimming == 1 then
		local gatherable = eso_fish.currenttask
		if table.valid(gatherable) then
			local newPos = NavigationManager:GetRandomPointOnCircle(gatherable.pos.x,gatherable.pos.y,gatherable.pos.z,5,10)
			if (table.valid(newPos)) then
				Player:MoveTo(newPos.x, newPos.y, newPos.z, false, 0, 2)
				c_cast.doblock = true
				c_cast.blocktime = Now()
				d("find alternate pos")
			end
			return true
		end
	end
	local interactable = MGetGameCameraInteractableActionInfo()
	if interactable == "Fish" then
		return true
	end
	
	return false
end
function e_cast:execute()
	if c_cast.doblock then
		return true
	end
	local TargetList = MEntityList("maxdistance=20,contentid=909;910;911;912")
	if TargetList then
		id,mytarget = next (TargetList)
		mytarget:Interact()
		esominion.lureType = 0
		ml_global_information.Await(1000)
	end
end

c_bite = inheritsFrom( ml_cause )
e_bite = inheritsFrom( ml_effect )
function c_bite:evaluate()
	if esominion.hooked then
		d("has bite")
		return true
	end
	return false
end
function e_bite:execute()
d("bite execute")
	if (eso_fish.biteDetected == 0) then
		eso_fish.biteDetected = Now() + math.random(250,750)
		d("bite set")
		return
	elseif (Now() > eso_fish.biteDetected) then
		local doHook = true
		if doHook then
		d("do hook")
			Player:CameraInteractionStart()
			--[[local TargetList = MEntityList("maxdistance=20,contentid=909;910;911;912")
			if TargetList then
				id,mytarget = next (TargetList)
				mytarget:Interact()
				d("check new reel in type stuff")
				--ml_global_information.Await(1000)
			end]]
		end
		esominion.hooked = false
	end
end

c_resetidle = inheritsFrom( ml_cause )
e_resetidle = inheritsFrom( ml_effect )
function c_resetidle:evaluate()
	return false
end
function e_resetidle:execute()
	ml_debug("Resetting idle status, waiting detected.")
	eso_fish.attemptedCasts = 0
	eso_fish.biteDetected = 0
end

c_isfishing = inheritsFrom( ml_cause )
e_isfishing = inheritsFrom( ml_effect )
function c_isfishing:evaluate()
	return false
end
function e_isfishing:execute()
	ml_debug("Preventing idle while waiting for bite.")
end

c_setbait = inheritsFrom( ml_cause )
e_setbait = inheritsFrom( ml_effect )
e_setbait.needbait = true
e_setbait.baitid = 0
e_setbait.baitname = ""
function c_setbait:evaluate()
	if not e_setbait.needbait then
		return false
	end
	if (not table.valid(eso_fish.currenttask)) then
		return false
	end
	local currentBait = esominion.lureType
	if (currentBait == 0) then
		return true
	end
		
	return false
end
function e_setbait:execute()
local locationType = esominion.reversefishingNodes[eso_fish.currenttask.contentid]
	d("locationType = "..tostring(locationType))
	if not SetBait(locationType) then
		eso_fish.currenttask = {}
		d("clear task 3")
	end
end

c_fishnexttask = inheritsFrom( ml_cause )
e_fishnexttask = inheritsFrom( ml_effect )
c_fishnexttask.blockOnly = false
c_fishnexttask.postpone = 0
c_fishnexttask.subset = {}
c_fishnexttask.subsetExpiration = 0
function c_fishnexttask:evaluate()
		
	return false
end
function e_fishnexttask:execute()
end

c_fishnextprofilemap = inheritsFrom( ml_cause )
e_fishnextprofilemap = inheritsFrom( ml_effect )
e_fishnextprofilemap.mapid = 0
function c_fishnextprofilemap:evaluate()

		
	return false
end
function e_fishnextprofilemap:execute()
end

c_fishnextprofilepos = inheritsFrom( ml_cause )
e_fishnextprofilepos = inheritsFrom( ml_effect )
c_fishnextprofilepos.blockOnly = false
c_fishnextprofilepos.distance = 0
function c_fishnextprofilepos:evaluate()
	if (not table.valid(eso_fish.currentTask)) then
		return false
	end
	
	c_fishnextprofilepos.blockOnly = false
	c_fishnextprofilepos.distance = 0
	
	local task = eso_fish.currentTask
	if (task.mapid == Player.localmapid) then
		local pos = GetCurrentTaskPos()
		local myPos = Player.pos
		local dist = math.distance2d(myPos.x, myPos.z, pos.x, pos.z)
		if (dist > 3 or ml_task_hub:CurrentTask().requiresRelocate) then
			c_fishnextprofilepos.distance = dist
			return true
		elseif (Player.ismounted) then
			Dismount()
			c_fishnextprofilepos.blockOnly = true
			return true
		end
	end
	
	return false
end
function e_fishnextprofilepos:execute()
	if (c_fishnextprofilepos.blockOnly) then
		return true
	end
	
	local newTask = ffxiv_task_movetopos.Create()
	local task = eso_fish.currentTask
	local taskPos = GetCurrentTaskPos()
	newTask.pos = taskPos
	newTask.range = 1
	newTask.doFacing = true
	
	if (CanFlyInZone() and c_fishnextprofilepos.distance > 40 and not gTeleportHack) then
		local flightApproach, approachDist = AceLib.API.Math.GetFlightApproach(taskPos)
		if (flightApproach and approachDist < 30) then
			newTask.pos = flightApproach
			newTask.range = 5
			newTask.doFacing = false
		end
	end
	
	if (gTeleportHack) then
		newTask.useTeleport = true
	end
	
	ml_task_hub:CurrentTask().requiresRelocate = false
	ml_task_hub:CurrentTask().requiresAdjustment = true
	ml_task_hub:CurrentTask():AddSubTask(newTask)
end

c_fishisloading = inheritsFrom( ml_cause )
e_fishisloading = inheritsFrom( ml_effect )
function c_fishisloading:evaluate()
	return false
end
function e_fishisloading:execute()
	ml_debug("Character is loading, prevent other actions and idle.")
end

c_fishnoactivity = inheritsFrom( ml_cause )
e_fishnoactivity = inheritsFrom( ml_effect )
function c_fishnoactivity:evaluate()
	return false
end
function e_fishnoactivity:execute()
	-- Do nothing here, but there's no point in continuing to process and eat CPU.
end


function eso_fish.IsFishing()
	return false
end

function eso_fish.StopFishing()
end

c_syncadjust = inheritsFrom( ml_cause )
e_syncadjust = inheritsFrom( ml_effect )
function c_syncadjust:evaluate()
		
	return false
end
function e_syncadjust:execute()
	local heading;
	local marker = ml_marker_mgr.currentMarker
	local task = eso_fish.currentTask
	if (table.valid(task)) then
		local taskPos = GetCurrentTaskPos()
		heading = taskPos.h
	elseif (table.valid(marker)) then
		local pos = ml_marker_mgr.currentMarker:GetPosition()
		if (pos) then
			heading = pos.h
		end
	end
	
	local newTask = eso_task_syncadjust.Create()
	newTask.heading = heading
	ml_task_hub:CurrentTask():AddSubTask(newTask)
end

eso_task_syncadjust = inheritsFrom(ml_task)
function eso_task_syncadjust.Create()
	local newinst = inheritsFrom(eso_task_syncadjust)
	
	--ml_task members
	newinst.valid = true
	newinst.completed = false
	newinst.subtask = nil
	newinst.auxiliary = false
	newinst.process_elements = {}
	newinst.overwatch_elements = {}
	
	newinst.name = "SYNC_ADJUSTMENT"
	newinst.timer = 0
	newinst.heading = 0
	
	return newinst
end
function eso_task_syncadjust:Init()	
	self:AddTaskCheckCEs()
end
function eso_task_syncadjust:task_complete_eval()
	Player:SetFacing(self.heading)
	
	--[[if (not Player:IsMoving()) then
		Player:Move(FFXIV.MOVEMENT.FORWARD)
	end]]
	
	if (self.timer == 0) then
		self.timer = Now() + 300
	elseif (Now() > self.timer) then
		return true
	end

	return false
end
function eso_task_syncadjust:task_complete_execute()
	Player:Stop()
	self:ParentTask().requiresAdjustment = false
	self.completed = true
end

function eso_task_syncadjust:task_fail_eval()
	if (not Player.alive) then
		return true
	end
end

function eso_task_fish:Init()
	--init ProcessOverwatch() cnes
	--local ke_dead = ml_element:create( "Dead", c_dead, e_dead, 150 )
	--self:add( ke_dead, self.overwatch_elements)
	
	local ke_stopmovetonode = ml_element:create( "StopMoveToNode", c_stoptonode, e_stoptonode, 2 )
	self:add(ke_stopmovetonode, self.overwatch_elements)	
	
	local ke_loot = ml_element:create( "Loot", c_loot, e_loot, 100 )
	self:add(ke_loot, self.process_elements)
	
	local ke_findaggro = ml_element:create( "FindAggro", c_findaggro, e_findaggro, 99 )
	self:add(ke_findaggro, self.process_elements)
	
	local ke_killaggro = ml_element:create( "KillAggro", c_killaggro, e_killaggro, 98 )
	self:add(ke_killaggro, self.process_elements)
	
	local ke_setbait = ml_element:create( "SetBait", c_setbait, e_setbait, 90 )
	self:add(ke_setbait, self.process_elements)
	
	--local ke_syncadjust = ml_element:create( "SyncAdjust", c_syncadjust, e_syncadjust, 25)
	--self:add(ke_syncadjust, self.process_elements)
		
	local ke_cast = ml_element:create( "Cast", c_cast, e_cast, 20 )
	self:add(ke_cast, self.process_elements)
	
	local ke_bite = ml_element:create( "Bite", c_bite, e_bite, 10 )
	self:add(ke_bite, self.process_elements)
		
	local kef_findnode = ml_element:create( "FindNode", cf_findnode, ef_findnode, 9 )
	self:add(kef_findnode, self.process_elements)	
	
	local ke_findbait = ml_element:create( "FindBait", c_findbaits, e_findbaits, 8 )
	self:add(ke_findbait, self.process_elements)
		
	local kef_movetobest = ml_element:create( "MoveToBest", cf_movetobest, ef_movetobest, 6 )
	self:add(kef_movetobest, self.process_elements)
	
	local kef_movetorandom = ml_element:create( "MoveToRandom", cf_movetorandom, ef_movetorandom, 5 )
	self:add(kef_movetorandom, self.process_elements)
	
	
	--local ke_fishing = ml_element:create( "Fishing", c_isfishing, e_isfishing, 1 )
	--self:add(ke_fishing, self.process_elements)
	 
	self:InitExtras()
	self:AddTaskCheckCEs()
end

function eso_task_fish:InitExtras()
	local overwatch_elements = self.addon_overwatch_elements
	if (table.valid(overwatch_elements)) then
		for i,element in pairs(overwatch_elements) do
			self:add(element, self.overwatch_elements)
		end
	end
	
	local process_elements = self.addon_process_elements
	if (table.valid(process_elements)) then
		for i,element in pairs(process_elements) do
			self:add(element, self.process_elements)
		end
	end
end

function eso_task_fish.SetModeOptions()
end

function eso_task_fish:UIInit()
		
	gFishDebug = esominion.GetSetting("gFishDebug",false)
	local debugLevels = { 1, 2, 3}
	gFishDebugLevel = esominion.GetSetting("gFishDebugLevel",1)
	gFishDebugLevelIndex = GetKeyByValue(gFishDebugLevel,debugLevels)
	
				
	self.GUI = {}
	
	self.GUI.profile = {
		open = false,
		visible = true,
		name = "Fish - Profile Management",
		main_tabs = GUI_CreateTabs("Manage,Add,Edit",true),
	}
end

function eso_task_fish:Draw()
	local MarkerOrProfileWidth = (GUI:GetContentRegionAvail() - 10)
	--local tabindex, tabname = GUI_DrawTabs(self.GUI.main_tabs)
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text("Fish Mode")
end

function eso_fish.GetLockout(profile,task)
	if (Settings.ESOMINION.gFishLockout ~= nil) then
		lockout = Settings.ESOMINION.gFishLockout
		if (table.valid(lockout[profile])) then
			return lockout[profile][task] or 0
		end
	end
	
	return 0
end
function eso_fish.SetLockout(profile,task)
	local profile = IsNull(profile,"placeholder")
	if (Settings.ESOMINION.gFishLockout == nil or type(Settings.ESOMINION.gFishLockout) ~= "table") then
		Settings.ESOMINION.gFishLockout = {}
	end
	
	local lockout = Settings.ESOMINION.gFishLockout
	if (lockout[profile] == nil or type(lockout[profile]) ~= "table") then
		lockout[profile] = {}
	end
	
	lockout[profile][task] = GetCurrentTime()
	Settings.ESOMINION.gFishLockout = lockout
end
function eso_fish.ResetLastGather()
	Settings.ESOMINION.gFishLockout = {}
end

cf_findnode = inheritsFrom( ml_cause )
ef_findnode = inheritsFrom( ml_effect )
ef_findnode.blockOnly = false
function cf_findnode:evaluate()
	if table.valid(eso_fish.currenttask) then
		return false
	end
		
	local whitelist = ESOLib.Common.BuildWhiteFishlist()
	local radius = 100
	local filter = ""
	if whitelist == "" then
		eso_fish.needbaits = true
		return false
	end
	filter = "onmesh,contentid="..whitelist

	local gatherable = nil				
	if (gatherable == nil) then
		gatherable = GetNearestFromList(filter,Player.pos,radius)
	end
	
	if (table.valid(gatherable)) then
		eso_fish.currenttask = MGetEntity(gatherable.index)
		d("node found")
		return true
	end
	
	return false
end
function ef_findnode:execute()
end

c_movetonode = inheritsFrom( ml_cause )
e_movetonode = inheritsFrom( ml_effect )
e_movetonode.block = false
function c_movetonode:evaluate()
	if (not table.valid(eso_fish.currenttask)) then
		return false
	end
	if TimeSince(esominion.hooktimer) < 3000 then
		return false
	end
	e_movetonode.block = false
	local gatherable = eso_fish.currenttask
	if (gatherable) then
		local interactable = MGetGameCameraInteractableActionInfo()
		local distanceMax = 5
		if In(gatherable.contentid,909,910,911,912) then
			distanceMax = 15
		end
		local reachable = (gatherable.distance <= distanceMax)
		if (not reachable) then
			e_movetonode.block = false
			return true
		else
			if In(interactable,nil,false) then 
				Player:SetFacing(gatherable.pos,true)
				e_movetonode.block = true
				return true
			end
		end
	end
	
	return false
end
function e_movetonode:execute()
	if e_movetonode.block then
		return false
	end
	eso_fish.thisPosition = {}
	local gatherable = eso_fish.currenttask
	if (table.valid(gatherable)) then
		local gpos = gatherable.meshpos
		local distanceMax = 5
		if In(gatherable.contentid,909,910,911,912) then
			distanceMax = 15
		end
		if (table.valid(gpos)) then
			 Player:MoveTo(gpos.x, gpos.y, gpos.z, false, 0, distanceMax)
		end
	end
end

cf_movetorandom = inheritsFrom( ml_cause )
ef_movetorandom = inheritsFrom( ml_effect )
function cf_movetorandom:evaluate()
	if (table.valid(eso_fish.currenttask)) then
	--d("[cf_movetorandom] false 1")
		return false
	end
	if InCombat() then
	--d("[cf_movetorandom] false 3")
		return false
	end
	if TimeSince(esominion.hooktimer) < 3000 then
	--d("[cf_movetorandom] false 4")
		return false
	end
	local ppos = Player.pos
	if not table.valid(eso_fish.thisPosition) then
		for i = 1,10 do
			local newPos = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,50,125)
			if (table.valid(newPos)) then
				local p = FindClosestMesh(newPos,30)
				if (p) then
					if not table.valid(eso_fish.lastPosition) then
						eso_fish.lastPosition = eso_fish.thisPosition
						eso_fish.thisPosition = p
						return true
					else
						local dist = math.distance2d(ppos.x, ppos.z, p.x, p.z)
						local dist2 = math.distance2d(eso_fish.lastPosition.x, eso_fish.lastPosition.z, p.x, p.z)
						if dist < dist2 then
							eso_fish.lastPosition = eso_fish.thisPosition
							eso_fish.thisPosition = p
							return true
						end
					end
				end
			end
		end
	else
		return true
	end
	return false
end
function ef_movetorandom:execute()
	
	local randomPos = eso_fish.thisPosition
	if (table.valid(randomPos)) then
		local rpos = randomPos
		local myPos = Player.pos
		local dist = math.distance2d(myPos.x, myPos.z, rpos.x, rpos.z)
		if (table.valid(rpos)) then
			if dist > 5 then
				Player:MoveTo(rpos.x, rpos.y, rpos.z, false, 0, 5)
			else
				eso_fish.lastPosition = eso_fish.thisPosition
				eso_fish.thisPosition = {}
				d("has position close by")
			end
		end
	end
end

c_stoptonode = inheritsFrom( ml_cause )
e_stoptonode = inheritsFrom( ml_effect )
function c_stoptonode:evaluate()
	if (not table.valid(eso_fish.currenttask)) then
		return false
	end
	if TimeSince(c_cast.blocktime) < 5000 then
		return false
	end
	if not Player:IsMoving() then
		return false
	end
	if InCombat() then
		Player:StopMovement()
		return true
	end
	local gatherable = eso_fish.currenttask
	if (gatherable) then
		local interactable = MGetGameCameraInteractableActionInfo()
		local distanceMax = 5
		if In(gatherable.contentid,909,910,911,912) then
			distanceMax = 15
		end
		local reachable = (gatherable.distance <= distanceMax and not In(interactable,nil,false))
		if (reachable) then
			Player:StopMovement()
			return true
		end
	end
	
	return false
end
function e_stoptonode:execute()
	
end

c_findbaits = inheritsFrom( ml_cause )
e_findbaits = inheritsFrom( ml_effect )
e_findbaits.blockOnly = false
function c_findbaits:evaluate()
	--[[if not eso_fish.needbaits then
	d("[c_findbaits] false 1")
		return false
	end]]
	if InCombat() then
	--d("[c_findbaits] false 1")
		return false
	end
	if table.valid(eso_fish.currenttask) then
	--d("[c_findbaits] false 2")
		return false
	end
	local whitelist = eso_fish.baitstring
	local radius = 75
	local filter = ""
	filter = "onmesh,contentid="..whitelist
	local gatherable = nil				
	if (gatherable == nil) then
		gatherable = GetNearestFromList(filter,Player.pos,30,eso_fish.lockoutids)
	end
	
	if (table.valid(gatherable)) then
		eso_fish.currenttask = MGetEntity(gatherable.index)
		return true
	end
	
	return false
end
function e_findbaits:execute()
end

cf_movetobest = inheritsFrom( ml_cause )
ef_movetobest = inheritsFrom( ml_effect )
cf_movetobest.doblock = false
function cf_movetobest:evaluate()
	if (not table.valid(eso_fish.currenttask)) then
	--d("[cf_movetobest] false 1")
		return false
	end
	if TimeSince(c_cast.blocktime) < 5000 then
		return false
	end
	local gatherable = eso_fish.currenttask
	if not MGetEntity(gatherable.index) then
		eso_fish.currenttask = {}
		d("clear task 1")
		return false
	end
	if InCombat() then
	--d("[cf_movetobest] false 2")
		return false
	end
	if TimeSince(esominion.hooktimer) < 3000 then
	--d("[cf_movetobest] false 4")
		return false
	end
	if IsNull(eso_fish.idLockoutattempts[eso_fish.currenttask.index],0) >= 5 then
		eso_fish.lockoutids[eso_fish.currenttask.index] = true
		eso_fish.currenttask = {}
		d("clear task 2")
	end
	cf_movetobest.doblock = false
	if (gatherable) then
		local distanceMax = 5
		if In(gatherable.contentid,909,910,911,912) then
			distanceMax = 15
		end
		--local interactable = MGetGameCameraInteractableActionInfo()
		local reachable = (gatherable.distance <= distanceMax)
		if (not reachable) then
			return true
		else
			--if interactable == "Take" then
				local TargetList = MEntityList("maxdistance=5,contentid="..eso_fish.baitstring)
				if TargetList then
					id,mytarget = next (TargetList)
					mytarget:Interact()
					ml_global_information.Await(1000)
					cf_movetobest.doblock = true
					eso_fish.idLockoutattempts[eso_fish.currenttask.index] = IsNull(eso_fish.idLockoutattempts[eso_fish.currenttask.index],0) + 1
					return true
				end
			--end
		end
	end
	
	return false
end
function ef_movetobest:execute()
	if cf_movetobest.doblock then
		return false
	end
	--d("[cf_movetobest] execute 1")
	local gatherable = eso_fish.currenttask
	if (table.valid(gatherable)) then
		local gpos = gatherable.meshpos
		local distanceMax = 5
		if In(gatherable.contentid,909,910,911,912) then
			distanceMax = 15
		end
	--d("[cf_movetobest] execute 2")
		if (table.valid(gpos)) then
			
	--d("[cf_movetobest] execute 3")
			 Player:MoveTo(gpos.x, gpos.y, gpos.z, false, 0, distanceMax)
		end
	end
end

c_setfacing = inheritsFrom( ml_cause )
e_setfacing = inheritsFrom( ml_effect )
e_setfacing.gatherable = {}
function c_setfacing:evaluate()
	if InCombat() then
		return false
	end
	e_setfacing.gatherable = {}
	if (table.valid(eso_fish.currenttask)) then
		local gatherable = eso_fish.currenttask
		local distanceMax = 5
		if In(gatherable.contentid,909,910,911,912) then
			distanceMax = 15
		end
		if gatherable.distance < distanceMax then
			local interactable = MGetGameCameraInteractableActionInfo()
			if In(interactable,nil,false) then 
				e_setfacing.gatherable = eso_fish.currenttask
				return true
			end
		end
	end
	
	return false
end
function e_setfacing:execute()

	local gatherable = e_setfacing.gatherable
	Player:SetFacing(gatherable.pos,true)
	
end