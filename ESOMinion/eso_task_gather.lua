eso_gather = {}
eso_gather.attemptedCasts = 0
eso_gather.biteDetected = 0
eso_gather.firstRun = nil
eso_gather.firstRunCompleted = false
eso_gather.profilePath = GetStartupPath()..[[\LuaMods\esominion\GatherProfiles\]]
eso_gather.currentTaskIndex = 0
eso_gather.thisPosition = {}
eso_gather.lastPosition = {}
eso_gather.needbaits = false
eso_gather.currenttask = {}
eso_gather.basepos = {}
eso_gather.killtargetid = 0
eso_gather.idLockoutattempts = 0
eso_gather.lockoutids = {}
eso_gather.whitelistchecks = {
	["Tailoring"] = "913;1858",
	["Woodworking"] = "1860;2065",
	["Smithing"] = "1862;2067",
	["Alchemy"] = "62;97;478;514;515;517;518;520;521;522;523;524;525;526;527;2100;2101",
	["Enchanting"] = "1957",
	["Jewlery"] = "2085",
}

eso_gather.GUI = {
	x = 0,
	y = 0, 
	height = 0,
	width = 0,
}

eso_task_gather = inheritsFrom(ml_task)
eso_task_gather.addon_process_elements = {}
eso_task_gather.addon_overwatch_elements = {}
function eso_task_gather.Create()	
	local newinst = {}
	
	--ml_task members
	newinst.valid = true
	newinst.completed = false
	newinst.subtask = nil
	newinst.auxiliary = false
	newinst.process_elements = {}
	newinst.overwatch_elements = {}
	newinst.name = "LT_GATHER"
	
	--eso_task_gather members
	newinst.castTimer = 0
	newinst.markerTime = 0
	ml_global_information.lastEquip = 0
	
	newinst.currentMarker = false
	ml_marker_mgr.currentMarker = nil
	
	newinst.filterLevel = true
	newinst.networkLatency = 0
	newinst.requiresAdjustment = false
	newinst.requiresRelocate = false
	
	eso_gather.currentTask = {}
	eso_gather.currentTaskIndex = 0
	eso_gather.attemptedCasts = 0
	eso_gather.biteDetected = 0
	eso_gather.firstRunCompleted = false
	eso_gather.basepos = Player.pos
		
	setmetatable(newinst, { __index = eso_task_gather })
	return newinst
end

function fd(var,level)
	local level = tonumber(level) or 3
	
	local requiredLevel = gGatherDebugLevel
	if (gBotMode == GetString("questMode") and gQuestDebug) then
		requiredLevel = gQuestDebugLevel
	end
	
	if ( gGatherDebug or (gQuestDebug and gBotMode == GetString("questMode"))) then
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

function eso_gather.GetDirective()
	local marker = ml_marker_mgr.currentMarker
	local task = eso_gather.currentTask
	
	if (table.valid(task)) then
		return task, "task"
	elseif (table.valid(marker)) then
		return marker, "marker"
	end
	
	return nil
end

function eso_gather.HasDirective()
	local marker = ml_marker_mgr.currentMarker
	local task = eso_gather.currentTask
	
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

function eso_task_gather:Init()
	local ke_death = ml_element:create( "Dead", c_isdead, e_isdead, 150 )
	self:add( ke_death, self.overwatch_elements)
	
	local ke_stopmovetonode = ml_element:create( "StopMoveToNode", c_stoptonode, e_stoptonode, 2 )
	self:add(ke_stopmovetonode, self.overwatch_elements)	
	
	local ke_loot = ml_element:create( "Loot", c_loot, e_loot, 100 )
	self:add(ke_loot, self.process_elements)
	
	local ke_findaggro = ml_element:create( "FindAggro", c_findaggro, e_findaggro, 99 )
	self:add(ke_findaggro, self.process_elements)
	
	local ke_killaggro = ml_element:create( "KillAggro", c_killaggro, e_killaggro, 98 )
	self:add(ke_killaggro, self.process_elements)
			
	local ke_findnode = ml_element:create( "FindNode", c_findnode, e_findnode, 9 )
	self:add(ke_findnode, self.process_elements)	
			
	local ke_movetobest = ml_element:create( "MoveToBest", c_movetobest, e_movetobest, 6 )
	self:add(ke_movetobest, self.process_elements)
	
	local ke_movetorandom = ml_element:create( "MoveToRandom", c_movetorandom, e_movetorandom, 5 )
	self:add(ke_movetorandom, self.process_elements)
	
	local kef_movetocustom = ml_element:create( "MoveToCustom", cga_movetonextpath, ega_movetonextpath, 4 )
	self:add(kef_movetocustom, self.process_elements)	
	
	
	 
	self:InitExtras()
	self:AddTaskCheckCEs()
end

cga_movetonextpath = inheritsFrom( ml_cause )
ega_movetonextpath = inheritsFrom( ml_effect )
cga_movetonextpath.index = 0
function cga_movetonextpath:evaluate()

	local gatherid = 0
	local targetid = 0
	if ml_task_hub:CurrentTask() then
		gatherid = ml_task_hub:CurrentTask().gatherid or 0
		targetid = ml_task_hub:CurrentTask().targetid or 0
	end
	if (gatherid ~= 0 and targetid ~= 0) then
		--d("[cga_movetonextpath] false 1")
		return false
	end
	if InCombat() then
		--d("[cga_movetonextpath] false 3")
		return false
	end
	
	local positions = gGatherPosition[Player.mapid]
	if not table.valid(positions) then
		--d("[cga_movetonextpath] false 4")
		return false
	end
	local ppos = Player.pos
	if not table.valid(eso_task_grind.thisPosition) then
		if table.valid(positions[cga_movetonextpath.index +1]) then
			eso_task_grind.thisPosition = positions[cga_movetonextpath.index +1] 
			cga_movetonextpath.index = cga_movetonextpath.index + 1
			return true
		else
			local closest = math.huge
			local best = nil
			for i = 1,table.size(positions) do
				local testPos = positions[i]
				if NavigationManager:IsReachable(testPos) and cga_movetonextpath.index ~= i then
					local dist = math.distance2d(testPos.x, testPos.z, ppos.x, ppos.z)
					d(dist)
					if dist < closest then
						closest = dist
						best = testPos
						
					end
				end
			end
			if best then
				eso_task_grind.thisPosition = best
				return true
			end
		end
	else
		return true
	end
	d("[cga_movetonextpath] false 5")
	return false
end
function ega_movetonextpath:execute()
	
	local positions = gGatherPosition[Player.mapid]
	local nextPos = eso_task_grind.thisPosition
	if (table.valid(nextPos)) then
		local rpos = nextPos
		local myPos = Player.pos
		local dist = math.distance2d(myPos.x, myPos.z, rpos.x, rpos.z)
		if (table.valid(rpos)) then
			if dist > 5 then
				local newTask = eso_task_movetopos.Create()
				newTask.pos = rpos
				newTask.range = math.random(2,5)
				newTask.remainMounted = false
				ml_task_hub:CurrentTask():AddSubTask(newTask)
			else
				eso_task_grind.lastPosition = eso_task_grind.thisPosition
				eso_task_grind.thisPosition = {}
				d("has position close by")
				if table.size(positions) == cga_movetonextpath.index then
					cga_movetonextpath.index = 0
				end
			end
		end
	end
end
function eso_task_gather:InitExtras()
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

function eso_task_gather.SetModeOptions()
end

function eso_task_gather:UIInit()
		
	gGatherDebug = esominion.GetSetting("gGatherDebug",false)
	local debugLevels = { 1, 2, 3}
	gGatherDebugLevel = esominion.GetSetting("gGatherDebugLevel",1)
	gGatherDebugLevelIndex = GetKeyByValue(gGatherDebugLevel,debugLevels)
	
	gGatherTailoring = esominion.GetSetting("gGatherTailoring",false)
	gGatherWoodworking = esominion.GetSetting("gGatherWoodworking",false)
	gGatherSmithing = esominion.GetSetting("gGatherSmithing",false)
	gGatherAlchemy = esominion.GetSetting("gGatherAlchemy",false)
	gGatherEnchanting = esominion.GetSetting("gGatherEnchanting",false)
	gGatherJewlery = esominion.GetSetting("gGatherJewlery",false)
	gGatherPositionShow = false
	gGatherPosition = esominion.GetSetting("gGatherPosition",{})
				
	self.GUI = {}
	
	self.GUI.profile = {
		open = false,
		visible = true,
		name = "Gather - Profile Management",
		main_tabs = GUI_CreateTabs("Manage,Add,Edit",true),
	}
end

function eso_task_gather:Draw()
	local MarkerOrProfileWidth = (GUI:GetContentRegionAvail() - 10)
	--local tabindex, tabname = GUI_DrawTabs(self.GUI.main_tabs)
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text("Gather Mode")
	
	gGatherTailoring, changed = GUI:Checkbox("Tailoring##gGatherTailoring", gGatherTailoring) 
	if (changed) then
		Settings.ESOMINION["gGatherTailoring"] = gGatherTailoring
	end 
	gGatherWoodworking, changed = GUI:Checkbox("Woodworking##gGatherWoodworking", gGatherWoodworking) 
	if (changed) then
		Settings.ESOMINION["gGatherWoodworking"] = gGatherWoodworking
	end 
	gGatherSmithing, changed = GUI:Checkbox("Smithing##gGatherSmithing", gGatherSmithing) 
	if (changed) then
		Settings.ESOMINION["gGatherSmithing"] = gGatherSmithing
	end 
	gGatherAlchemy, changed = GUI:Checkbox("Alchemy##gGatherAlchemy", gGatherAlchemy) 
	if (changed) then
		Settings.ESOMINION["gGatherAlchemy"] = gGatherAlchemy
	end 
	gGatherEnchanting, changed = GUI:Checkbox("Enchanting##gGatherEnchanting", gGatherEnchanting) 
	if (changed) then
		Settings.ESOMINION["gGatherEnchanting"] = gGatherEnchanting
	end 
	gGatherJewlery, changed = GUI:Checkbox("Jewlery##gGatherJewlery", gGatherJewlery) 
	if (changed) then
		Settings.ESOMINION["gGatherJewlery"] = gGatherJewlery
	end 
	local contentwidth = GUI:GetContentRegionAvailWidth()
	GUI:PushItemWidth(contentwidth)
	if ( GUI:Button("Add Position")) then
		if not gGatherPosition[Player.mapid] then
			gGatherPosition[Player.mapid] = {}
		end
		table.insert(gGatherPosition[Player.mapid],Player.pos)
		Settings.ESOMINION.gGatherPosition = gGatherPosition
	end
	if ( GUI:Button("Edit Positions")) then
		esominion.GUI.gatheredit.open = not esominion.GUI.gatheredit.open
	end
	GUI:PopItemWidth()
	if esominion.GUI.gatheredit.open then
		GUI:SetNextWindowSize(200,400,GUI.SetCond_Once) --set the next window size, only on first ever	
		GUI:SetNextWindowCollapsed(false,GUI.SetCond_Always)
		
		local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
		GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
		
		local flags = (GUI.WindowFlags_NoCollapse)
		esominion.GUI.gatheredit.visible, esominion.GUI.gatheredit.open = GUI:Begin(esominion.GUI.gatheredit.name, esominion.GUI.gatheredit.open, flags)
		if ( esominion.GUI.gatheredit.visible) then 
		
			local x, y = GUI:GetWindowPos()
			local width, height = GUI:GetWindowSize()
			local contentwidth = GUI:GetContentRegionAvailWidth()
			
			esominion.GUI.x = x; esominion.GUI.y = y; esominion.GUI.width = width; esominion.GUI.height = height;
	
	
			GUI:Separator()
			local positions = gGatherPosition[Player.mapid]
			if table.valid(positions) then
				local closest = math.huge
				local best = 0
				local ppos = Player.pos
				local doDelete = 0
				local doPriorityUp = 0
				local doPriorityDown = 0
				local doPriorityTop = 0
				local doPriorityBottom = 0
			
				for prio,e in pairs(positions) do
					if prio == eso_gather.positionClose then
						if (GUI:Button("["..tostring(prio).."] [Closest Node]",contentwidth - 85,20)) then
						end		
					else
						if (GUI:Button("["..tostring(prio).."]",contentwidth - 85,20)) then
						end		
					end
                    local dist = math.distance2d(ppos, e)
					if dist < closest then
						closest = dist
						best = prio
					end
					GUI:SameLine(0,5)
					if (GUI:ImageButton("##eso_skillmanager-manage-prioup-"..tostring(prio),ml_global_information.path.."\\GUI\\UI_Textures\\w_up.png", 16, 16)) then	
						doPriorityUp = prio
					end
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(1)) then
							doPriorityTop = prio
						end
					end	
					GUI:SameLine(0,5)
					if (GUI:ImageButton("##eso_skillmanager-manage-priodown-"..tostring(prio),ml_global_information.path.."\\GUI\\UI_Textures\\w_down.png", 16, 16)) then
						doPriorityDown = prio
					end
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(1)) then
							doPriorityBottom = prio
						end
					end	
					GUI:SameLine(0,5)
					if (GUI:ImageButton("##eso_skillmanager-manage-delete-"..tostring(prio),ml_global_information.path.."\\GUI\\UI_Textures\\bt_alwaysfail_fail.png", 16, 16)) then
						doDelete = prio
					end
				end
				eso_gather.positionClose = best
				
				if (doPriorityTop ~= 0 and doPriorityTop ~= 1) then
					local currentPos = doPriorityTop
					local newPos = doPriorityTop
					
					while currentPos > 1 do
						local temp = gGatherPosition[Player.mapid][newPos]
						gGatherPosition[Player.mapid][newPos] = gGatherPosition[Player.mapid][currentPos]
						gGatherPosition[Player.mapid][currentPos] = temp	
						currentPos = newPos
						newPos = newPos - 1
					end
					
					Settings.ESOMINION.gGatherPosition = gGatherPosition
				end
				
				if (doPriorityUp ~= 0 and doPriorityUp ~= 1) then
					local currentPos = doPriorityUp
					local newPos = doPriorityUp - 1
					
					local temp = gGatherPosition[Player.mapid][newPos]
					gGatherPosition[Player.mapid][newPos] = gGatherPosition[Player.mapid][currentPos]
					gGatherPosition[Player.mapid][currentPos] = temp	
					
					Settings.ESOMINION.gGatherPosition = gGatherPosition
				end
				if (doPriorityDown ~= 0 and doPriorityDown < TableSize(gGatherPosition[Player.mapid])) then
					local currentPos = doPriorityDown
					local newPos = doPriorityDown + 1
					
					local temp = gGatherPosition[Player.mapid][newPos]
					gGatherPosition[Player.mapid][newPos] = gGatherPosition[Player.mapid][currentPos]
					gGatherPosition[Player.mapid][currentPos] = temp
					
					Settings.ESOMINION.gGatherPosition = gGatherPosition
				end
				
				local profSize = TableSize(gGatherPosition[Player.mapid])
				if (doPriorityBottom ~= 0 and doPriorityBottom < profSize) then
				
					local currentPos = doPriorityBottom
					local newPos = doPriorityBottom + 1
					
					while currentPos < profSize do
						local temp = gGatherPosition[Player.mapid][newPos]
						gGatherPosition[Player.mapid][newPos] = gGatherPosition[Player.mapid][currentPos]
						gGatherPosition[Player.mapid][currentPos] = temp	
						currentPos = newPos
						newPos = newPos + 1
					end
					
					Settings.ESOMINION.gGatherPosition = gGatherPosition
				end
				
				if (doDelete ~= 0) then
					gGatherPosition[Player.mapid] = TableRemoveSort(gGatherPosition[Player.mapid],doDelete)
					for prio,skill in pairsByKeys(gGatherPosition[Player.mapid]) do
						if (skill.prio ~= prio) then
							gGatherPosition[Player.mapid][prio].prio = prio
						end
					end
					Settings.ESOMINION.gGatherPosition = gGatherPosition
				end
			end
			
		end	
		GUI:End()
		GUI:PopStyleColor()
	end
end

function eso_gather.GetLockout(profile,task)
	if (Settings.ESOMINION.gGatherLockout ~= nil) then
		lockout = Settings.ESOMINION.gGatherLockout
		if (table.valid(lockout[profile])) then
			return lockout[profile][task] or 0
		end
	end
	
	return 0
end

c_findnode = inheritsFrom( ml_cause )
e_findnode = inheritsFrom( ml_effect )
e_findnode.blockOnly = false
function c_findnode:evaluate()
	if table.valid(eso_gather.currenttask) then
		return false
	end
	if InventoryFull() then
		return false
	end
		
	local whitelist = ESOLib.Common.BuildWhitelist()
	local radius = 100
	local filter = ""
	if whitelist == "" then
		return false
	end
	filter = "onmesh,contentid="..whitelist

	local gatherable = nil				
	if (gatherable == nil) then
		gatherable = GetNearestFromList(filter,Player.pos,radius,eso_gather.lockoutids)
	end
	
	if (table.valid(gatherable)) then
		eso_gather.currenttask = MGetEntity(gatherable.index)
		return true
	else
		--d("no gatherables")
	end
	--d("failed out")
	return false
end
function e_findnode:execute()
end

c_movetonode = inheritsFrom( ml_cause )
e_movetonode = inheritsFrom( ml_effect )
e_movetonode.block = false
function c_movetonode:evaluate()
	if (not table.valid(eso_gather.currenttask)) then
		return false
	end
	e_movetonode.block = false
	local gatherable = eso_gather.currenttask
	if (gatherable) then
		local interactable = MGetGameCameraInteractableActionInfo()
		local distanceMax = 5
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
	eso_gather.thisPosition = {}
	local gatherable = eso_gather.currenttask
	if (table.valid(gatherable)) then
		local gpos = gatherable.meshpos
		local distanceMax = 5
		if (table.valid(gpos)) then
			
			local newTask = eso_task_movetointeract.Create()
			newTask.pos = gatherable.pos
			newTask.interact = gatherable.index
			newTask.interactRange = 2
			newTask.postDelay = 4000	
			ml_task_hub:CurrentTask():AddSubTask(newTask)	
		end
	end
end

c_movetorandom = inheritsFrom( ml_cause )
e_movetorandom = inheritsFrom( ml_effect )
function c_movetorandom:evaluate()
	if (table.valid(eso_gather.currenttask)) then
	--d("[c_movetorandom] false 1")
		return false
	end
	if InCombat() then
	--d("[c_movetorandom] false 3")
		return false
	end
	local positions = gGatherPosition[Player.mapid]
	if table.valid(positions) then
		return false
	end
	local ppos = Player.pos
	if not table.valid(eso_gather.thisPosition) then
		for i = 1,10 do
			local newPos = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,50,125)
			if (table.valid(newPos)) then
				local p = FindClosestMesh(newPos,30)
				if (p) then
					local baseDist = math.distance3d(ppos.x, ppos.y, ppos.z, eso_gather.basepos.x, eso_gather.basepos.y, eso_gather.basepos.z)
				
					if baseDist < 1000 then
						if not table.valid(eso_gather.lastPosition) then
							eso_gather.lastPosition = eso_gather.thisPosition
							eso_gather.thisPosition = p
							return true
						else
							local dist = math.distance3d(ppos.x, ppos.y, ppos.z, p.x, p.y, p.z)
							local dist2 = math.distance3d(eso_gather.lastPosition.x, eso_gather.lastPosition.y, eso_gather.lastPosition.z, p.x, p.y, p.z)
							if dist < dist2 then
								eso_gather.lastPosition = eso_gather.thisPosition
								eso_gather.thisPosition = p
								return true
							end
						end
					end
				end
			end
		end
		eso_gather.thisPosition = eso_gather.basepos
		d("return to base pos")
		return true
	else
		local dist = math.distance3d(ppos.x, ppos.y, ppos.z, eso_gather.thisPosition.x, eso_gather.thisPosition.y, eso_gather.thisPosition.z)
		if dist > 5 then
			--d("move to random execute 1")
			return true
		else
			eso_gather.thisPosition = {}
			return true
		end
	end
	--d("[c_movetorandom] false 4")
	
	return false
end
function e_movetorandom:execute()
	
	local randomPos = eso_gather.thisPosition
	if (table.valid(randomPos)) then
	--d("move")
		local rpos = randomPos
		local myPos = Player.pos
		local dist = math.distance2d(myPos.x, myPos.z, rpos.x, rpos.z)
		if (table.valid(rpos)) then
			if dist > 5 then
				local newTask = eso_task_movetopos.Create()
				newTask.pos = rpos
				newTask.range = math.random(2,5)
				newTask.remainMounted = false
				ml_task_hub:CurrentTask():AddSubTask(newTask)
			else
				eso_gather.lastPosition = eso_gather.thisPosition
				eso_gather.thisPosition = {}
				d("has position close by")
			end
		end
	end
end

c_stoptonode = inheritsFrom( ml_cause )
e_stoptonode = inheritsFrom( ml_effect )
function c_stoptonode:evaluate()
	if (not table.valid(eso_gather.currenttask)) then
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
	local gatherable = eso_gather.currenttask
	if (gatherable) then
		local interactable = MGetGameCameraInteractableActionInfo()
		local distanceMax = 5
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

c_movetobest = inheritsFrom( ml_cause )
e_movetobest = inheritsFrom( ml_effect )
c_movetobest.doblock = false
function c_movetobest:evaluate()
	if (not table.valid(eso_gather.currenttask)) then
	--d("[c_movetobest] false 1")
		return false
	end
	if (Player.interacting and Player.interacttype ~= 0) then
	--d("[c_movetobest] false 2")
		return false
	end
	if TimeSince(c_cast.blocktime) < 5000 then
	--d("[c_movetobest] false 3")
		return false
	end
	if eso_gather.idLockoutattempts >= 5 then
		eso_gather.lockoutids[eso_gather.currenttask.index] = true
		d("clear gather locked out")
		d("add exclude")
		d(eso_gather.currenttask.id)
		d(eso_gather.currenttask.name)
		eso_gather.currenttask = {}
	end
	local gatherable = eso_gather.currenttask
	if not MGetEntity(gatherable.index) then
		eso_gather.currenttask = {}
		return false
	end
	if InCombat() then
	--d("[c_movetobest] false 4")
		return false
	end
	c_movetobest.doblock = false
	if (gatherable) then
		local distanceMax = 5
		local interactable = MGetGameCameraInteractableActionInfo()
		local reachable = (IsNull(gatherable.distance,100) <= distanceMax and not In(interactable,nil,false))
		--d("reachable = "..tostring(reachable))
		if (not reachable) then
			return true
		else
			if interactable then
			--if In(interactable,"Collect","Cut","Mine") then
				local TargetList = MEntityList("maxdistance=5,contentid="..ESOLib.Common.BuildWhitelist())
				if TargetList then
					id,mytarget = next (TargetList)
					mytarget:Interact()
					ml_global_information.Await(1000)
					c_movetobest.doblock = true
					--eso_gather.idLockoutattempts = eso_gather.idLockoutattempts + 1
					return true
				end
			end
			
		end
	end
	
	return false
end
function e_movetobest:execute()
	if c_movetobest.doblock then
		return false
	end
	local gatherable = eso_gather.currenttask
	if (table.valid(gatherable)) then
		local gpos = gatherable.meshpos
		local distanceMax = 5
		if (table.valid(gpos)) then
			local newTask = eso_task_movetopos.Create()
			newTask.pos = gpos
			newTask.range = math.random(2,5)
			newTask.remainMounted = false
			ml_task_hub:CurrentTask():AddSubTask(newTask)
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
	if (table.valid(eso_gather.currenttask)) then
		local gatherable = eso_gather.currenttask
		local distanceMax = 5
		if gatherable.distance < distanceMax then
			local interactable = MGetGameCameraInteractableActionInfo()
			if In(interactable,nil,false) then 
				e_setfacing.gatherable = eso_gather.currenttask
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

cf_movetonextpath = inheritsFrom( ml_cause )
ef_movetonextpath = inheritsFrom( ml_effect )
cf_movetonextpath.index = 0
function cf_movetonextpath:evaluate()
	if (table.valid(eso_gather.currenttask)) then
	--d("[cf_movetonextpath] false 1")
		return false
	end
	if InCombat() then
	--d("[cf_movetonextpath] false 3")
		return false
	end
	
	local positions = gGatherPosition[Player.mapid]
	if not table.valid(positions) then
		return false
	end
	local ppos = Player.pos
	if not table.valid(eso_gather.thisPosition) then
		if table.valid(positions[cf_movetonextpath.index +1]) then
			eso_gather.thisPosition = positions[cf_movetonextpath.index +1] 
			cf_movetonextpath.index = cf_movetonextpath.index + 1
			return true
		else
			local closest = math.huge
			local best = nil
			for i = 1,table.size(positions) do
				local testPos = positions[i]
				if NavigationManager:IsReachable(testPos) and cf_movetonextpath.index ~= i then
					local dist = math.distance2d(testPos.x, testPos.z, ppos.x, ppos.z)
					if dist < closest then
						closest = dist
						best = testPos
						
					end
				end
			end
			if best then
				eso_gather.thisPosition = best
				return true
			end
		end
	else
		return true
	end
	return false
end
function ef_movetonextpath:execute()
	
	local positions = gGatherPosition[Player.mapid]
	local nextPos = eso_gather.thisPosition
	if (table.valid(nextPos)) then
		local rpos = nextPos
		local myPos = Player.pos
		local dist = math.distance2d(myPos.x, myPos.z, rpos.x, rpos.z)
		if (table.valid(rpos)) then
			if dist > 5 then
				local newTask = eso_task_movetopos.Create()
				newTask.pos = rpos
				newTask.range = math.random(2,5)
				newTask.remainMounted = false
				ml_task_hub:CurrentTask():AddSubTask(newTask)
			else
				eso_gather.lastPosition = eso_gather.thisPosition
				eso_gather.thisPosition = {}
				d("has position close by")
				if table.size(positions) == cf_movetonextpath.index then
					cf_movetonextpath.index = 0
				end
			end
		end
	end
end
function eso_gather.DrawPathFinder(event, ticks)
	local gamestate;
	if (GetGameState and GetGameState()) then
		gamestate = GetGameState()
	else
		gamestate = 1
	end
	
	if (gamestate == ESO.GAMESTATE.INGAME) then
		if esominion.GUI.gatheredit.open then
			local maxWidth, maxHeight = GUI:GetScreenSize()
			GUI:SetNextWindowPos(0, 0, GUI.SetCond_Always)
			GUI:SetNextWindowSize(maxWidth,maxHeight,GUI.SetCond_Always) --set the next window size
			local winBG = ml_gui.style.current.colors[GUI.Col_WindowBg]
			GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], 0)
			flags = (GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
			GUI:Begin("Show Nav Space", true, flags)
			
				local positions = gGatherPosition[Player.mapid]
				if table.valid(positions) then
					for prio,e in pairs(positions) do
						local RoundedPos = { x = math.round(e.x,2), y = math.round(e.y,2), z = math.round(e.z,2) }
						local screenPos = RenderManager:WorldToScreen(RoundedPos)
						if table.valid(screenPos) then
							GUI:AddCircleFilled(screenPos.x,screenPos.y,7, 4281545727)
						end
					end
				end
			GUI:End()
			GUI:PopStyleColor()
		end
	end
end
RegisterEventHandler("Gameloop.Draw", eso_gather.DrawPathFinder,"eso_gather.DrawPathFinder")