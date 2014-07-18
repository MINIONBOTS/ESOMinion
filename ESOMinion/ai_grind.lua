-- Grind
ai_grind = inheritsFrom(ml_task)
ai_grind.name = "GrindMode"
--
function ai_grind.Create()
	local newinst = inheritsFrom(ai_grind)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	newinst.markerTime = 0
    newinst.currentMarker = false
	newinst.filterLevel = true
	
    return newinst
end

function ai_grind:Init()
   -- ml_log("combatAttack_Init->")
	
	-- Dead?
	self:add(ml_element:create( "Dead", c_dead, e_dead, 325 ), self.process_elements)
	
	-- LootAll
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 300 ), self.process_elements)	
			
	-- Aggro
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 275 ), self.process_elements) --reactive queue
	
	--Autoequip
	self:add(ml_element:create( "Autoequip", c_autoequip, e_autoequip, 250 ), self.process_elements)

	--Vendoring
	self:add(ml_element:create( "GetVendor", c_movetovendor, e_movetovendor, 225 ), self.process_elements)
				
	-- Resting
	self:add(ml_element:create( "Resting", c_resting, e_resting, 210 ), self.process_elements)	

	--Potions
	self:add(ml_element:create( "GetPotions", c_usePotions, e_usePotions, 190 ), self.process_elements)
		
	-- Looting
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
				
	-- Gathering - Gathers only in a smaller radius in grindingmode 
	self:add(ml_element:create( "Gathering", c_gringgatherTask, e_gringgatherTask, 150 ), self.process_elements)
	
	-- Fight in a smaller radius towards the current marker ( this takes care of reaching it and also when running outside the markerradius and we need to move back to marker)
	-- Only for GrindMarkers!	
	self:add(ml_element:create( "FightTowardsGrindMarker", c_FightToGrindMarker, e_FightToGrindMarker, 125 ), self.process_elements)
    
	-- Pick the next/new Marker and makes sure we are staying near the current Marker
    self:add( ml_element:create( "NextMarker", c_MoveToMarker, e_MoveToMarker, 75 ), self.process_elements)
		
	-- Check for attackable Targets 
	self:add(ml_element:create( "GetNextTarget", c_CombatTask, e_CombatTask, 50 ), self.process_elements)
	
	-- Move to a Randompoint if there is nothing to fight around us
	self:add( ml_element:create( "MoveToRandomPoint", c_MoveToRandomPoint, e_MoveToRandomPoint, 25 ), self.process_elements)	
			
    self:AddTaskCheckCEs()
end

function ai_grind:task_complete_eval()	
	return false
end
function ai_grind:task_complete_execute()
    
end

------------
c_gringgatherTask = inheritsFrom( ml_cause )
e_gringgatherTask = inheritsFrom( ml_effect )
c_gringgatherTask.throttle = 2500
c_gringgatherTask.target = nil
function c_gringgatherTask:evaluate()
	if ( gGather == "1" and not ml_global_information.Player_InventoryFull and not ml_global_information.Player_InCombat) then
		
		-- If we are doing the Markerdance, then gather just in a smaller radius while we move to the markers, else a bigger radius, never gather outside markerradius
		
		if ( TableSize(EntityList("nearest,alive,attackable,targetable,maxdistance=45,onmesh")) == 0 ) then
			local GList = EntityList("shortestpath,gatherable,maxdistance=20")
			if ( GList and TableSize(GList)>0) then
				local id,entry = next(GList)
				if ( id and entry ) then
					c_gringgatherTask.target = entry
					return true
				end
			end
		end		
	end
	c_gringgatherTask.target = nil
	return false
end
function e_gringgatherTask:execute()
	ml_log("e_gringgatherTask ")
	Player:Stop()
	local newTask = ai_gatherTask.Create()
	
	if ( c_gringgatherTask.target ~= nil ) then		
		newTask.tPos = c_gringgatherTask.target.pos		
	else
		ml_error("Bug: GList in e_gringgatherTask is empty!?")
	end
	ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
	return ml_log(true)
end


--------- Creates a new REACTIVE_GOAL subtask to kill an enemy when we are fighting our way towards the current grindmarker
c_FightToGrindMarker = inheritsFrom( ml_cause )
e_FightToGrindMarker = inheritsFrom( ml_effect )
c_FightToGrindMarker.target = nil
function c_FightToGrindMarker:evaluate()
	if ( c_MoveToMarker.markerreached == false and c_MoveToMarker.allowedToFight == true) then
		local EList = EntityList("attackable,targetable,alive,nocritter,shortestpath,onmesh,maxdistance=30") -- add los ?
		if ( EList and TableSize(EList) > 0 ) then
			local id,entry = next(EList)
			if ( id and entry ) then
				c_FightToGrindMarker.target = entry
				return Player.isswimming == false and c_FightToGrindMarker.target ~= nil
			end
		end
	end
	c_FightToGrindMarker.target = nil
	return false
end
function e_FightToGrindMarker:execute()
	ml_log("e_FightToGrindMarker ")
	
	-- Weakest Aggro in CombatRange first	
	local TList = ( EntityList("lowesthealth,attackable,targetable,alive,aggro,nocritter,onmesh,maxdistance=15") )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			c_FightToGrindMarker.target = E
			d("Fight new Aggro Target: "..(E.name).." ID:"..tostring(E.id))			
		end		
	end
	
	if (c_FightToGrindMarker.target ~= nil) then
		Player:Stop()
		local newTask = ai_combatAttack.Create()
		newTask.targetID = c_FightToGrindMarker.target.id		
		newTask.targetPos = c_FightToGrindMarker.target.pos
		d("Attacking new target : "..c_FightToGrindMarker.target.name.." ID: "..c_FightToGrindMarker.target.id.." Dist: "..c_FightToGrindMarker.target.distance)
		ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
		c_FightToGrindMarker.target = nil
	else
		ml_log("e_FightToGrindMarker found no target")
	end
	return ml_log(false)
end

---------
-- Moves player towards the current marker and makes sure we are still inside tha radius around the marker, moves the player randomly around the maker to kill n find stuff
-- If Markertime is up, it will pick also the next marker
-- If there are no Maker in the current mesh, it will pick a random point and go there
c_MoveToMarker = inheritsFrom( ml_cause )
e_MoveToMarker = inheritsFrom( ml_effect )
c_MoveToMarker.markerreachedfirsttime = false
c_MoveToMarker.markerreached = false
c_MoveToMarker.allowedToFight = false -- this sh*t is needed else he will go back n forth on the outer side of the marker's 350 radius if an enemy sits at 520 behind that radius -.-
function c_MoveToMarker:evaluate()
	-- Get a new/next Marker if we need one ( no marker , out of level, time up )
	if (ml_task_hub:CurrentTask().currentMarker == nil or ml_task_hub:CurrentTask().currentMarker == false 
		or ( ml_task_hub:CurrentTask().filterLevel and ml_task_hub:CurrentTask().currentMarker:GetMinLevel() and ml_task_hub:CurrentTask().currentMarker:GetMaxLevel() and (ml_global_information.Player_Level < ml_task_hub:CurrentTask().currentMarker:GetMinLevel() or ml_global_information.Player_Level > ml_task_hub:CurrentTask().currentMarker:GetMaxLevel())) 
		or ( ml_task_hub:CurrentTask().currentMarker:GetTime() and ml_task_hub:CurrentTask().currentMarker:GetTime() ~= 0 and TimeSince(ml_task_hub:CurrentTask().markerTime) > ml_task_hub:CurrentTask().currentMarker:GetTime() * 1000 )) then
		-- TODO: ADD TIMEOUT FOR MARKER
		ml_task_hub:CurrentTask().currentMarker = ml_marker_mgr.GetNextMarker(GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
		
		-- disable the levelfilter in case we didnt find any other marker
		if (ml_task_hub:CurrentTask().currentMarker == nil) then
			ml_task_hub:CurrentTask().filterLevel = false
			ml_task_hub:CurrentTask().currentMarker = ml_marker_mgr.GetNextMarker(GetString("grindMarker"), ml_task_hub:CurrentTask().filterLevel)
		end
		
		-- we found a new marker, setup vars
		if ( ml_task_hub:CurrentTask().currentMarker ~= nil ) then
			d("New Marker set!")
			ml_task_hub:CurrentTask().markerTime = ml_global_information.Now -- Are BOTH needed to get updated ?
			ml_global_information.MarkerTime = ml_global_information.Now     --
			ml_global_information.MarkerMinLevel = ml_task_hub:CurrentTask().currentMarker:GetMinLevel()
			ml_global_information.MarkerMaxLevel = ml_task_hub:CurrentTask().currentMarker:GetMaxLevel()
			ml_global_information.BlacklistContentID = ml_task_hub:CurrentTask().currentMarker:GetFieldValue(strings[gCurrentLanguage].NOTcontentIDEquals)
			ml_global_information.WhitelistContentID = ml_task_hub:CurrentTask().currentMarker:GetFieldValue(strings[gCurrentLanguage].contentIDEquals)	
			c_MoveToMarker.markerreached = false
			c_MoveToMarker.markerreachedfirsttime = false
		end
	end
	
	-- We have a valid current Grindmarker
    if (ml_task_hub:CurrentTask().currentMarker ~= false and ml_task_hub:CurrentTask().currentMarker ~= nil) then
        
		-- Reset the Markertime until we actually reached the marker the first time and then let it count down
		if (c_MoveToMarker.markerreachedfirsttime == false ) then
			ml_task_hub:CurrentTask().markerTime = ml_global_information.Now
			ml_global_information.MarkerTime = ml_global_information.Now
		end
		
		-- We haven't reached the currentMarker or ran outside its radius
		if ( c_MoveToMarker.markerreached == false) then			
			return true
		
		else
			-- check if we ran outside the currentMarker radius and if so, we need to walk back to the currentMarker
			local pos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
			local distance = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.z, pos.x, pos.z)			
			if  (gBotMode == GetString("grindMode") and distance > 350) then
				d("We need to move back to our current Marker!")
				c_MoveToMarker.markerreached = false
				c_MoveToMarker.allowedToFight = false
				return true
			end
		end		
	end
	
    return false
end
function e_MoveToMarker:execute()
	ml_log(" e_MoveToMarker ")
	-- Move to our current marker
	if (ml_task_hub:CurrentTask().currentMarker ~= false and ml_task_hub:CurrentTask().currentMarker ~= nil) then
		
		local pos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
		local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.z, pos.x, pos.z)

		if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
			ai_mount:Mount()
		elseif gUseMount == "1" and tonumber(gUseMountRange) > dist then
			ai_mount:Dismount()
		end
		
		-- Allow fighting when we are far away from the "outside radius of the marker" , else the bot goes back n forth spinning trying to reach the target outside n going back inside right after
		if ( dist < 300) then
			c_MoveToMarker.allowedToFight = true
		else
			c_MoveToMarker.allowedToFight = false
		end
		
		if  ( dist < 10) then
			-- We reached our Marker
			c_MoveToMarker.markerreached = true
			c_MoveToMarker.markerreachedfirsttime = true
			d("Reached current Marker...")
			return ml_log(true)		
		else
			-- We need to reach our Marker yet			
			local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,10,false,true,false))
			if (tonumber(navResult) < 0) then
				ml_log("e_MoveToMarker result: "..tostring(navResult))
				return ml_log(false)
			end
			return ml_log(true)
		end
	end
	return ml_log(false)
end


c_MoveToRandomPoint = inheritsFrom( ml_cause )
e_MoveToRandomPoint = inheritsFrom( ml_effect )
c_MoveToRandomPoint.randomPoint = nil
c_MoveToRandomPoint.randomPointreached = false
function c_MoveToRandomPoint:evaluate()
	
	-- We dont have a current randomPoint to goto
	if ( c_MoveToRandomPoint.randomPoint == nil ) then
		local ppos = ml_global_information.Player_Position
		if ( TableSize(ppos)>0)then
			local p = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,30,5000)
			if ( p ) then
				if ( Distance3D(p.x,p.y,p.z,ppos.x,ppos.y,ppos.z) > 25 ) then
					c_MoveToRandomPoint.randomPoint = p
					c_MoveToRandomPoint.randomPointreached = false
					return true
				end
			end
		end
				
	else
		-- We haven't reached the current randomPoint
		if ( c_MoveToRandomPoint.randomPointreached == false) then			
			return true
		end		
	end			
    return false
end
function e_MoveToRandomPoint:execute()
	ml_log(" e_MoveToRandomPoint ")
		
	-- Move to our random Point
	if ( c_MoveToRandomPoint.randomPoint ~= nil ) then
		local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.z, c_MoveToRandomPoint.randomPoint.x, c_MoveToRandomPoint.randomPoint.z)

		if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
			ai_mount:Mount()
		end
		
		if  ( dist < 10) then
			-- We reached our random Point
			c_MoveToRandomPoint.randomPointreached = true
			c_MoveToRandomPoint.randomPoint = nil
			d("Reached Random Point...")
			return ml_log(true)
		else
			-- We need to reach our random Point yet
			local navResult = tostring(Player:MoveTo(c_MoveToRandomPoint.randomPoint.x,c_MoveToRandomPoint.randomPoint.y,c_MoveToRandomPoint.randomPoint.z,10,false,true,false))
			if (tonumber(navResult) < 0) then
				ml_log("e_MoveToRandomPoint result: "..tostring(navResult))
				return ml_log(false)
			end
			return ml_log(true)
		end
	
	else
		d("BUG in e_MoveToRandomPoint ... I guess..")
	end
	
	return ml_log(false)
end

if ( ml_global_information.BotModes) then
	ml_global_information.BotModes[GetString("grindMode")] = ai_grind
end
