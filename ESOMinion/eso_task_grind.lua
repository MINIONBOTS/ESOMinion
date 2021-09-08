-- Grind
eso_task_grind = inheritsFrom(ml_task)
eso_task_grind.name = "ESO_TASK_GRIND"
function eso_task_grind.Create()
	local newinst = inheritsFrom(eso_task_grind)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	newinst.markerTime = 0
    newinst.currentMarker = false
	newinst.filterLevel = true
	
	newinst.targetID = 0
	newinst.gatherid = 0
	newinst.movementDelay = 0
	newinst.lastMovement = 0
	
    return newinst
end
eso_task_grind.currentTaskIndex = 0
eso_task_grind.thisPosition = {}
eso_task_grind.lastPosition = {}

function eso_task_grind:UIInit()
	if (Settings.ESOMinion.gAssistTargetMode == nil) then
		Settings.ESOMinion.gAssistTargetMode = "None"
	end
	gGather = esominion.GetSetting("gGather",false)
	gGrindPositionShow = false
	gGrindPosition = esominion.GetSetting("gGrindPosition",{})
end
--[[
function eso_task_grind.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "gGather")						
		then
			Settings.ESOMinion[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(ml_global_information.MainWindow.Name)
end]]

function eso_task_grind:Init()
    local ke_dead = ml_element:create( "Dead", c_dead, e_dead, 300 )
    self:add( ke_dead, self.overwatch_elements )
	
	local ke_rest = ml_element:create( "Rest", c_rest, e_rest, 250 )
    self:add( ke_rest, self.overwatch_elements )
	
	local ke_aggro = ml_element:create( "Aggro", c_findaggro, e_findaggro, 200 )
	self:add( ke_aggro, self.overwatch_elements )
	
	local ke_autoEquip = ml_element:create( "AutoEquip", c_autoequip, e_autoequip, 200 )
	self:add( ke_autoEquip, self.process_elements)
	
	local ke_vendor = ml_element:create( "Vendor", c_Vendor, e_Vendor, 195 )
	self:add(ke_vendor, self.process_elements)
	
	--self:add(ml_element:create( "GetPotions", c_usePotions, e_usePotions, 190 ), self.process_elements)
		
	local ke_lootBodies = ml_element:create( "Loot", c_lootbodies, e_lootbodies, 100 )
	self:add( ke_lootBodies, self.process_elements )
		
	local ke_findGrindable = ml_element:create( "FindGrindable", c_findgrindable, e_findgrindable, 85 )
	self:add( ke_findGrindable, self.process_elements )
	
	local ke_findnode = ml_element:create( "FindGatherable", c_findgatherable, e_findgatherable, 80 )
	self:add( ke_findnode, self.process_elements )
	
	--local ke_nextMarker = ml_element:create( "NextMarker", c_nextgrindmarker, e_nextgrindmarker, 75 )
    --self:add( ke_nextMarker, self.process_elements )
    
	--local ke_returnToMarker = ml_element:create( "ReturnToMarker", c_returntomarker, e_returntomarker, 70 )
   --self:add( ke_returnToMarker, self.process_elements)
	
	local ke_nextGrindObjective = ml_element:create( "NextGrindObjective", c_nextgrindobjective, e_nextgrindobjective, 50 )
	self:add( ke_nextGrindObjective, self.process_elements )
	
	local kef_movetocustom = ml_element:create( "MoveToCustom", cg_movetonextpath, eg_movetonextpath, 4 )
	self:add(kef_movetocustom, self.process_elements)	
			
    self:AddTaskCheckCEs()
end

function eso_task_grind:Draw()
	local MarkerOrProfileWidth = (GUI:GetContentRegionAvail() - 10)
	--local tabindex, tabname = GUI_DrawTabs(self.GUI.main_tabs)
	GUI:AlignFirstTextHeightToWidgets() 
	
	gGather, changed = GUI:Checkbox("Gather##gGather", gGather) 
	if (changed) then
		Settings.ESOMINION["gGather"] = gGather
	end 
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
		if not gGrindPosition[Player.mapid] then
			gGrindPosition[Player.mapid] = {}
		end
		table.insert(gGrindPosition[Player.mapid],Player.pos)
		Settings.ESOMINION.gGrindPosition = gGrindPosition
	end
	if ( GUI:Button("Edit Positions")) then
		esominion.GUI.grindedit.open = not esominion.GUI.grindedit.open
	end
	GUI:PopItemWidth()
	if esominion.GUI.grindedit.open then
		GUI:SetNextWindowSize(200,400,GUI.SetCond_Once) --set the next window size, only on first ever	
		GUI:SetNextWindowCollapsed(false,GUI.SetCond_Always)
		
		local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
		GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
		
		local flags = (GUI.WindowFlags_NoCollapse)
		esominion.GUI.grindedit.visible, esominion.GUI.grindedit.open = GUI:Begin(esominion.GUI.grindedit.name, esominion.GUI.grindedit.open, flags)
		if ( esominion.GUI.grindedit.visible) then 
		
			local x, y = GUI:GetWindowPos()
			local width, height = GUI:GetWindowSize()
			local contentwidth = GUI:GetContentRegionAvailWidth()
			
			esominion.GUI.x = x; esominion.GUI.y = y; esominion.GUI.width = width; esominion.GUI.height = height;
	
	
			GUI:Separator()
			local positions = gGrindPosition[Player.mapid]
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
					if prio == eso_task_grind.positionClose then
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
				eso_task_grind.positionClose = best
				
				if (doPriorityTop ~= 0 and doPriorityTop ~= 1) then
					local currentPos = doPriorityTop
					local newPos = doPriorityTop
					
					while currentPos > 1 do
						local temp = gGrindPosition[Player.mapid][newPos]
						gGrindPosition[Player.mapid][newPos] = gGrindPosition[Player.mapid][currentPos]
						gGrindPosition[Player.mapid][currentPos] = temp	
						currentPos = newPos
						newPos = newPos - 1
					end
					
					Settings.ESOMINION.gGrindPosition = gGrindPosition
				end
				
				if (doPriorityUp ~= 0 and doPriorityUp ~= 1) then
					local currentPos = doPriorityUp
					local newPos = doPriorityUp - 1
					
					local temp = gGrindPosition[Player.mapid][newPos]
					gGrindPosition[Player.mapid][newPos] = gGrindPosition[Player.mapid][currentPos]
					gGrindPosition[Player.mapid][currentPos] = temp	
					
					Settings.ESOMINION.gGrindPosition = gGrindPosition
				end
				if (doPriorityDown ~= 0 and doPriorityDown < TableSize(gGrindPosition[Player.mapid])) then
					local currentPos = doPriorityDown
					local newPos = doPriorityDown + 1
					
					local temp = gGrindPosition[Player.mapid][newPos]
					gGrindPosition[Player.mapid][newPos] = gGrindPosition[Player.mapid][currentPos]
					gGrindPosition[Player.mapid][currentPos] = temp
					
					Settings.ESOMINION.gGrindPosition = gGrindPosition
				end
				
				local profSize = TableSize(gGrindPosition[Player.mapid])
				if (doPriorityBottom ~= 0 and doPriorityBottom < profSize) then
				
					local currentPos = doPriorityBottom
					local newPos = doPriorityBottom + 1
					
					while currentPos < profSize do
						local temp = gGrindPosition[Player.mapid][newPos]
						gGrindPosition[Player.mapid][newPos] = gGrindPosition[Player.mapid][currentPos]
						gGrindPosition[Player.mapid][currentPos] = temp	
						currentPos = newPos
						newPos = newPos + 1
					end
					
					Settings.ESOMINION.gGrindPosition = gGrindPosition
				end
				
				if (doDelete ~= 0) then
					gGrindPosition[Player.mapid] = TableRemoveSort(gGrindPosition[Player.mapid],doDelete)
					for prio,skill in pairsByKeys(gGrindPosition[Player.mapid]) do
						if (skill.prio ~= prio) then
							gGrindPosition[Player.mapid][prio].prio = prio
						end
					end
					Settings.ESOMINION.gGrindPosition = gGrindPosition
				end
			end
			
		end	
		GUI:End()
		GUI:PopStyleColor()
	end	
end
c_findgatherable = inheritsFrom(ml_cause)
e_findgatherable = inheritsFrom(ml_effect)
c_findgatherable.node = nil
function c_findgatherable:evaluate()
	local isInteracting = Player.interacting
	if (InventoryFull() or isInteracting or Player.incombat) then
		return false
	end
	
	local needsUpdate = false
	if not ml_task_hub:CurrentTask() or (ml_task_hub:CurrentTask().gatherid == nil or ml_task_hub:CurrentTask().gatherid == 0 ) then
		needsUpdate = true
	end
		
	--[[local gatherable = EntityList:Get(ml_task_hub:CurrentTask().gatherid)
	if (not ValidTable(gatherable)) then
		needsUpdate = true
	end]]
	
	if (needsUpdate) then
	
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
			c_findgatherable.node = gatherable
			return true
		else
			--d("no gatherables")
		end
		--d("failed out")
	end
    
    return false
end
function e_findgatherable:execute()
	d("Updating task gatherid.")
	d(c_findgatherable.node)
	ml_task_hub:CurrentTask().gatherid = c_findgatherable.node.index
end

c_findgrindable = inheritsFrom(ml_cause)
e_findgrindable = inheritsFrom(ml_effect)
c_findgrindable.targetid = nil
function c_findgrindable:evaluate()	

	if c_aggro:evaluate() then
		return false
	end
	
	local needsUpdate = false
	if ( ml_task_hub:CurrentTask().targetid == nil or ml_task_hub:CurrentTask().targetid == 0 ) then
		needsUpdate = true
	end
	
	local target = EntityList:Get(ml_task_hub:CurrentTask().targetid)
	if (ValidTable(target)) then
		if (target.health.current < 1) then
			needsUpdate = true
		end
	else
		needsUpdate = true
	end
	
	if (needsUpdate) then
		ml_task_hub:CurrentTask().targetid = 0
		local newTarget = GetNearestGrind()
		if (ValidTable(newTarget)) then
			c_findgrindable.targetid = newTarget.index
			return true
		end
	end	
    
    return false
end
function e_findgrindable:execute()
	ml_task_hub:CurrentTask().targetid = c_findgrindable.targetid
end

c_nextgrindobjective = inheritsFrom( ml_cause )
e_nextgrindobjective = inheritsFrom( ml_effect )
c_nextgrindobjective.task = nil
function c_nextgrindobjective:evaluate()
	c_nextgrindobjective.task = nil
	
	local gatherdistance = 9999
	local targetdistance = 9999
	
	local gatherid = ml_task_hub:CurrentTask().gatherid or 0
	local targetid = ml_task_hub:CurrentTask().targetid or 0
	
	local gatherable = nil
	local target = nil
	if not InventoryFull() then
		if (gatherid > 0 and gGather) then
			gatherable = EntityList:Get(gatherid)
			if (ValidTable(gatherable)) then
				gatherdistance = math.distance2d(Player.pos,gatherable.pos)
			end
		end
	end
	
	if (targetid > 0) then
		target = EntityList:Get(targetid)
		if (ValidTable(target)) then
			targetdistance = math.distance2d(Player.pos,target.pos)
		end
	end
	if (targetdistance < gatherdistance) then
		if (ValidTable(target)) then
			local newTask = eso_task_combat.Create()
			newTask.targetID = targetid
			c_nextgrindobjective.task = newTask
			return true
		end
	else
		if (ValidTable(gatherable)) then
			local newTask = eso_task_movetointeract.Create()
			newTask.creator = "nextgrindobjective"
			newTask.pos = gatherable.pos
			newTask.interact = gatherid
			newTask.interactRange = 8
			newTask.avoidPlayers = true
			newTask.postDelay = 4000	
			c_nextgrindobjective.task = newTask
			return true
		end
	end
	
	return false
end
function e_nextgrindobjective:execute()
	if (ValidTable(c_nextgrindobjective.task)) then
		ml_task_hub:Add(c_nextgrindobjective.task, REACTIVE_GOAL, TP_IMMEDIATE)
	end
end

cg_movetonextpath = inheritsFrom( ml_cause )
eg_movetonextpath = inheritsFrom( ml_effect )
cg_movetonextpath.index = 0
function cg_movetonextpath:evaluate()

	local gatherid = 0
	local targetid = 0
	if ml_task_hub:CurrentTask() then
		gatherid = ml_task_hub:CurrentTask().gatherid or 0
		targetid = ml_task_hub:CurrentTask().targetid or 0
	end
	if (gatherid ~= 0 and targetid ~= 0) then
		--d("[cg_movetonextpath] false 1")
		return false
	end
	if InCombat() then
		--d("[cg_movetonextpath] false 3")
		return false
	end
	
	local positions = gGrindPosition[Player.mapid]
	if not table.valid(positions) then
		--d("[cg_movetonextpath] false 4")
		return false
	end
	local ppos = Player.pos
	if not table.valid(eso_task_grind.thisPosition) then
		if table.valid(positions[cg_movetonextpath.index +1]) then
			eso_task_grind.thisPosition = positions[cg_movetonextpath.index +1] 
			cg_movetonextpath.index = cg_movetonextpath.index + 1
			return true
		else
			local closest = math.huge
			local best = nil
			for i = 1,table.size(positions) do
				local testPos = positions[i]
				if NavigationManager:IsReachable(testPos) and cg_movetonextpath.index ~= i then
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
	d("[cg_movetonextpath] false 5")
	return false
end
function eg_movetonextpath:execute()
	
	local positions = gGrindPosition[Player.mapid]
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
				if table.size(positions) == cg_movetonextpath.index then
					cg_movetonextpath.index = 0
				end
			end
		end
	end
end
if ( ml_global_information.BotModes) then
	ml_global_information.BotModes[GetString("grindMode")] = eso_task_grind
end

RegisterEventHandler("GUI.Update",eso_task_grind.GUIVarUpdate)
function eso_task_grind.DrawPathFinder(event, ticks)
	local gamestate;
	if (GetGameState and GetGameState()) then
		gamestate = GetGameState()
	else
		gamestate = 1
	end
	
	if (gamestate == ESO.GAMESTATE.INGAME) then
		if esominion.GUI.grindedit.open then
			local maxWidth, maxHeight = GUI:GetScreenSize()
			GUI:SetNextWindowPos(0, 0, GUI.SetCond_Always)
			GUI:SetNextWindowSize(maxWidth,maxHeight,GUI.SetCond_Always) --set the next window size
			local winBG = ml_gui.style.current.colors[GUI.Col_WindowBg]
			GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], 0)
			flags = (GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
			GUI:Begin("Show Nav Space", true, flags)
			
				local positions = gGrindPosition[Player.mapid]
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
RegisterEventHandler("Gameloop.Draw", eso_task_grind.DrawPathFinder,"eso_task_grind.DrawPathFinder")
