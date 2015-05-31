c_movetointeract = ml_cause.Create()
e_movetointeract = ml_effect.Create()
function c_movetointeract:evaluate()
	local pos = self.task.pos
	if(ValidTable(pos)) then
		local ppos = Player.pos
		local distance = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return distance > 5
	end
	
	return false
end
function e_movetointeract:execute()
	local moveTask = eso_task_moveto_interact.Create()
	if(ValidTable(moveTask)) then
		moveTask.pos = self.task.pos
		self.task:AddSubTask(moveTask)
	end
end

c_movetomap = ml_cause.Create()
e_movetomap = ml_effect.Create()
function c_movetomap:evaluate()
	return self.task.destMapID and self.task.destMapID ~= ml_global_information.CurrentMapID
end
function e_movetomap:execute()
	local newTask = eso_task_moveto_map.Create()
	newTask.destMapID = self.task.destMapID
	newTask.origMapID = ml_global_information.CurrentMapID

	ml_task_hub:CurrentTask():AddSubTask(newTask)
end

c_interactgate = inheritsFrom( ml_cause )
e_interactgate = inheritsFrom( ml_effect )
function c_interactgate:evaluate()
	if (ml_global_information.CurrentMapID ~= self.task.destMapID) then
		local pos = ml_nav_manager.GetNextPathPos(ml_global_information.Player_Position, ml_global_information.CurrentMapID, self.task.destMapID)

		if (ValidTable(pos)) then
			local interacts = EntityList("nearest,type=8,maxdistance=3")
			for i, interactable in pairs(interacts) do
				self.task.interactid = interactable.id
				return true
			end
		end
	end
	
	return false
end
function e_interactgate:execute()
	Player:Stop()
	
	local gate = EntityList:Get(self.task.interactid)
	local pos = gate.pos
	Player:SetFacing(pos.x,pos.y,pos.z)
	Player:Interact(gate.id)
end

c_movetogate = inheritsFrom( ml_cause )
e_movetogate = inheritsFrom( ml_effect )
function c_movetogate:evaluate()
	return 	ml_global_information.CurrentMapID ~= self.task.destMapID and
			not ml_mesh_mgr.loadingMesh
end
function e_movetogate:execute()
    ml_debug( "Moving to gate for next map" )
	local pos = ml_nav_manager.GetNextPathPos(ml_global_information.Player_Position, ml_global_information.CurrentMapID, self.task.destMapID)
	
	if (ValidTable(pos)) then
		local newTask = eso_task_moveto.Create()
		newTask.pos = pos
		newTask.range = 0.5
		newTask.remainMounted = true

		ml_task_hub:CurrentTask():AddSubTask(newTask)
	end
end

c_teleporttomap = inheritsFrom( ml_cause )
e_teleporttomap = inheritsFrom( ml_effect )
function c_teleporttomap:evaluate()
	
	--[[if (IsPositionLocked() or ActionList:IsCasting()) then
		return false
	end
	
	local el = EntityList("alive,attackable,onmesh,targetingme")
	if (ValidTable(el)) then
		return false
	end
	
	--Only perform this check when dismounted.
	if (not Player.ismounted) then
		local teleport = ActionList:Get(7,5)
		if (not teleport or not teleport.isready or Player.castinginfo.channelingid == 5 or Player.castinginfo.castingid == 5) then
			return false
		end
	end
	
	local destMapID = ml_task_hub:ThisTask().destMapID
    if (destMapID) then
        local pos = ml_nav_manager.GetNextPathPos(	Player.pos,
                                                    Player.localmapid,
                                                    destMapID	)

        if (ValidTable(ml_nav_manager.currPath)) then
            local aethid = nil
			local mapid = nil
            for _, node in pairsByKeys(ml_nav_manager.currPath) do
                if (node.id ~= Player.localmapid) then
					local map,aeth = GetAetheryteByMapID(node.id, ml_task_hub:ThisTask().pos)
                    if (aeth) then
						mapid = map
						aethid = aeth
					end
                end
            end
            
            if (aethid) then
				local aetheryte = GetAetheryteByID(aethid)
				if (aetheryte) then
					if (GilCount() >= aetheryte.price and aetheryte.isattuned) then
						e_teleporttomap.destMap = mapid
						e_teleporttomap.aethid = aethid
						return true
					end
				end
            end
        end
    end]]
    
    return false
end
function e_teleporttomap:execute()
	--[[if (Player:IsMoving()) then
		Player:Stop()
	end
	
	if (Player.ismounted) then
		Dismount()
		return
	end
	
	if (ActionIsReady(7,5)) then
		if (Player:Teleport(e_teleporttomap.aethid)) then	
			local newTask = ffxiv_task_teleport.Create()
			newTask.mapID = e_teleporttomap.destMap
			ml_task_hub:Add(newTask, IMMEDIATE_GOAL, TP_IMMEDIATE)
		end
	end]]
end

c_mount = ml_cause.Create()
e_mount = ml_effect.Create()
function c_mount:evaluate()
	if(gUseMount == "1" and ai_mount:CanMount() and not ai_mount:IsMounted()) then
		local ppos = ml_global_information.Player_Position
		local pos = self.task.pos
		local dist = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return dist > tonumber(gUseMountRange)
	end
	return false
	
end
function e_mount:execute()
	ai_mount:Mount()
end

c_dismount = ml_cause.Create()
e_dismount = ml_effect.Create()
function c_dismount:evaluate()
	if(ai_mount:IsMounted()) then
		local ppos = ml_global_information.Player_Position
		local pos = self.task.pos
		local dist = Distance3D(pos.x,pos.y,pos.z,ppos.x,ppos.y,ppos.z)
		return dist < 6.0
	end
	return false
	
end
function e_dismount:execute()
	ai_mount:Dismount()
end


c_walktopos = ml_cause.Create()
e_walktopos = ml_effect.Create()
function c_walktopos:evaluate()
	--[[if (IsLoading() or IsPositionLocked()) then
		return false
	end
	
	if ((ActionList:IsCasting() and not ml_task_hub:CurrentTask().interruptCasting) or IsMounting()) then
		return false
	end]]
	 
	local myPos = Player.pos
	local gotoPos = self.task.pos
	local distance = Distance3D(myPos.x, myPos.y, myPos.z, gotoPos.x, gotoPos.y, gotoPos.z)
	--d("Bot Position: ("..tostring(myPos.x)..","..tostring(myPos.y)..","..tostring(myPos.z)..")")
	--d("MoveTo Position: ("..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..")")
	--d("Current Distance: "..tostring(distance))
	--d("Execute Distance: "..tostring(ml_task_hub:CurrentTask().range))
	
	if (distance > self.task.range) then
		return true
	end
	
    return false
end
function e_walktopos:execute()
	local gotoPos = self.task.pos
	--d("Moving to ("..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..")")	
	--d("Move To vars"..tostring(gotoPos.x)..","..tostring(gotoPos.y)..","..tostring(gotoPos.z)..","..tostring(ml_task_hub:CurrentTask().range *0.75)..","..tostring(ml_task_hub:CurrentTask().useFollowMovement or false)..","..tostring(gRandomPaths=="1"))
	if (self.lastAvoidanceCheck == nil or ml_global_information.Now - self.lastAvoidanceCheck > 200) then
    self.lastAvoidanceCheck = ml_global_information.Now
    local avoidPlease = EntityList("npc,alive,friendly,maxdistance=30")
    if ValidTable(avoidPlease) then
      local avoidpos = {}
      local id,entity = next(avoidPlease)
      while ( entity ) do
        table.insert(avoidpos,{ x=entity.pos.x, y=entity.pos.y, z=entity.pos.z, r=1.2 })
        id,entity = next(avoidPlease,id)
      end
      d("Setting " .. TableSize(avoidpos) .. " obstructed areas")
      NavigationManager:AddNavObstacles(avoidpos)
    end
  end
  
  local PathSize = Player:MoveTo(tonumber(gotoPos.x),tonumber(gotoPos.y),tonumber(gotoPos.z),tonumber(range), self.task.useFollowMovement or false, false,false)
	--d(tostring(PathSize))
end

c_handleaggro = ml_cause.Create()
e_handleaggro = ml_effect.Create()
function c_handleaggro:evaluate()
	if(self.task.ignoreAggro) then
		return false
	end
	
	return Player.isswimming == false and TableSize(EntityList("nearest,alive,aggro,attackable,hostile,targetable,maxdistance=28,onmesh")) > 0
end
function e_handleaggro:execute()
	Player:Stop()
	local EList = EntityList("nearest,alive,aggro,hostile,attackable,maxdistance=28,onmesh")
	if ( EList ) then
		local id,entity = next (EList)
		if (id and entity) then
			local newTask = eso_task_killtarget.Create()
			newTask.targetid = entity.id 
			newTask.pos = entity.pos
			e("OnSpecialMoveKeyUp(1)")
			ml_task_hub:Add(newTask, REACTIVE_GOAL, TP_ASAP)
			return
		end		
	end
end

c_updatetarget = ml_cause.Create()
e_updatetarget = ml_effect.Create()
function c_updatetarget:evaluate()
	local target = EntityList:Get(self.task.targetid)
	if(ValidTable(target)) then
		local distance = Distance3D(target.pos.x, target.pos.y, target.pos.z, self.task.pos.x, self.task.pos.z)
		if(distance > 0) then
			self.element.newPos = target.pos
			return distance > 0
		end
	end
end
function e_updatetarget:execute()
	self.task.pos = self.element.newPos
	self.element.newPos = nil
end

c_movetotarget = ml_cause.Create()
e_movetotarget = ml_effect.Create()
function c_movetotarget:evaluate()
	local target = EntityList:Get(self.task.targetid)
	if(ValidTable(target)) then
		local tpos = target.pos
		if ( target.distance > ml_global_information.AttackRange or not target.los ) then		
			self.task.pos = tpos
			return true
		end
	end
end
function e_movetotarget:execute()	
	local tpos = self.task.pos
	local rndPath = false
    if (target.distance>20) then rndPath = true else rndPath = false end					
	Player:MoveTo(tpos.x,tpos.y,tpos.z,0.5+(target.radius),false,rndPath,false)
end

c_attacktarget = ml_cause.Create()
e_attacktarget = ml_effect.Create()
function c_attacktarget:evaluate()
	local target = EntityList:Get(self.task.targetid)
	if(ValidTable(target)) then
		local tpos = target.pos
		if ( target.distance <= ml_global_information.AttackRange and target.los ) then	
			return true
		end
	end
	
	return false
end
function e_attacktarget:execute()
	local tpos = self.task.pos
	Player:SetFacing(tpos.x,tpos.y,tpos.z,false)
	Player:SetTarget(target.id)
	
	if ( not eso_skillmanager.Heal( Player.id ) ) then

		--[[if not ml_task_hub:CurrentTask().timestarted then
			ml_task_hub:CurrentTask().timestarted = ml_global_information.Now
		end
	
		local timediff = ml_global_information.Now - ml_task_hub:CurrentTask().timestarted
		
		if  timediff > 30000
			and target.alive
			and target.hp.current == 0
		then
			d("Blacklisting Target " .. target.id)
			EntityList:AddToBlacklist(target.id, 300000)
			ml_task_hub:CurrentTask().completed = true
			return ml_log(false)
		end]]

		eso_skillmanager.AttackTarget( target.id )
	end
end

c_endinteract = ml_cause.Create()
e_endinteract = ml_effect.Create()
function c_endinteract:evaluate()
	local interactionType = e("GetInteractionType()")
	if(tonumber(interactionType) > 0) then
		self.element.interactionType = interactionType
		return true
	end
	
	return false
end
function e_endinteract:execute()	
	e("EndInteraction("..tostring(self.element.interactionType)..")")
end

-- ID 1 - Block
-- ID 2 - Staggered
-- ID 4 - Dodge
c_combattip = ml_cause.Create()
e_combattip = ml_effect.Create()
function c_combattip:evaluate()
	return Player:GetNumActiveCombatTips() > 0
end
function e_combattip:execute()
	d("NumActiveCombatTips: "..tostring(Player:GetNumActiveCombatTips()))
	local newTask = eso_task_combattip.Create()
	ml_task_hub:Add(newTask, IMMEDIATE_GOAL, TP_ASAP)
	return
end

c_block = ml_cause.Create()
e_block = ml_effect.Create()
function c_block:evaluate()
	local entity = EntityList:GetFromCombatTip(1)
	return ValidTable(entity) and not e("IsBlockActive()")
end
function e_block:execute()	
	e("OnSpecialMoveKeyDown(0)")
end

c_dodge = ml_cause.Create()
e_dodge = ml_effect.Create()
function c_dodge:evaluate()
	local entity = EntityList:GetFromCombatTip(4)
	if(ValidTable(entity) and not self.task.isDodging) then
		self.task.entityDodge = entity
		return true
	end
	
	return false
end
function e_dodge:execute()	
	local entity = self.task.entityDodge
	Player:SetFacing(entity.pos.x, entity.pos.y, entity.pos.z)
	local can_move_left = NavigationManager:IsOnMesh(GetPosFromDistanceHeading(Player.pos, 3, 270))
	local can_move_right = NavigationManager:IsOnMesh(GetPosFromDistanceHeading(Player.pos, 3, 90))
	local dodge_dir = 0
	if(can_move_left) then
		dodge_dir = 4
	else
		dodge_dir = 5
	end
	
	Player:RollDodge(dodge_dir)
	self.task.isDodging = true
end

c_stagger = ml_cause.Create()
e_stagger = ml_effect.Create()
function c_stagger:evaluate()
	return false
end
function e_stagger:execute()	
	
end


