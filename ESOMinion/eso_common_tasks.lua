eso_task_death = inheritsFrom(ml_task)
function eso_task_death.Create()

	local newinst = inheritsFrom(eso_task_death)
    
    --: ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--: eso_task_death members
	newinst.name = "ESO_DEATH"
	newinst.delay = math.random(4000,8000)
	newinst.useSoulGem = false
	
    return newinst
end

function eso_task_death:Init()
	self:AddTaskCheckCEs()
end

function eso_task_death:task_complete_eval()
	return ((not self.useSoulGem and not Player.dead) or 
		(self.useSoulGem and not Player.isghost and not Player.dead))
end

function eso_task_death:task_complete_execute()
	ml_global_information.ResetBot()
	self.completed = true
end

function eso_task_death:Process()
	if (self.delay and not self.time) then
		self.time = Now() + self.delay
	end
	
	if (Now() > self.time) then
		if (not self.useSoulGem) then
			e("Release()")
			ml_log(" -> releasing")
		else
			if not Player.isghost then
				e("Revive()")
				ml_log(" -> reviving")
			end
		end
	else
		local remaining = math.floor((self.time - Now())/1000)
		ml_log(" -> waiting " .. remaining .. " seconds to release")
	end
	
    if (TableSize(self.process_elements) > 0) then
		ml_cne_hub.clear_queue()
		ml_cne_hub.eval_elements(self.process_elements)
		ml_cne_hub.queue_to_execute()
		ml_cne_hub.execute()
	end
end


eso_task_rest = inheritsFrom(ml_task)
function eso_task_rest.Create()

	local newinst = inheritsFrom(eso_task_rest)
    
    --: ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--: eso_task_rest members
	newinst.name = "ESO_REST"
	newinst.maxTime = Now() + 60000
	
    return newinst
end

function eso_task_rest:Init()
	self:AddTaskCheckCEs()
end

function eso_task_rest:task_complete_eval()
	local hpp = ml_global_information.Player_Health.percent
	local mpp = ml_global_information.Player_Magicka.percent
	local spp = ml_global_information.Player_Stamina.percent
	
	if Player:IsMoving() then
		SafeStop()
	end
	
	 if ((hpp > math.random(90,99) or tonumber(g_resthp) == 0) and 
		(mpp > math.random(90,99) or tonumber(g_restmp) == 0) and
		(spp > math.random(90,99) or tonumber(g_restsp) == 0)) 
	then
		return true
	end
	
	return false
end
function eso_task_rest:task_complete_execute()
	self.completed = true
end

function eso_task_rest:task_fail_eval()
	return (
		Player.dead or
		ml_global_information.Player_InCombat or
		Player.isswimming or
		Player.iscasting or 
		Now() > self.maxTime
	)
end
function eso_task_rest:task_fail_execute()
	self:Terminate()
end

eso_task_lockpick = inheritsFrom(ml_task)
function eso_task_lockpick.Create()

	local newinst = inheritsFrom(eso_task_lockpick)
    
    --: ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--: eso_task_rest members
	newinst.name = "ESO_LOCKPICK"
	newinst.delay = 0
	newinst.currentChamber = 0
	
    return newinst
end

function eso_task_lockpick:Init()
	self:AddTaskCheckCEs()
end

function eso_task_lockpick:task_complete_eval()
	if (Now() < self.delayTimer) then
		return false
	end
	
	if (self.currentChamber == 0) then
		for i = 1,5 do
			local isChamberSolved = e("IsChamberSolved(" .. i .. ")")
			if (not isChamberSolved) then
				e("StartSettingChamber(" .. i .. ")")
				e("PlaySound(Lockpicking_lockpick_contact)")
				e("PlaySound(Lockpicking_chamber_start)")
				self.currentChamber = i
				self.delay = Now() + 500
			end
		end
	else
		local chamberStress = e("GetSettingChamberStress()")
		if (chamberStress >= 0.2) then
			e("PlaySound(Lockpicking_chamber_stress)")
			e("StopSettingChamber()")
			d("Chamber "..tostring(self.currentChamber).." is solved.")
			self.currentChamber = 0
			self.delay = Now() + 1000
		end
	end
	
	local isInteracting = Player.interacting
	local lockTime = e("GetLockpickingTimeLeft()")
	
	if (not isInteracting or lockTime <= 0) then
		return true
	end
	
	return false
end
function eso_task_lockpick:task_complete_execute()
	e("PlaySound(Lockpicking_unlocked)")
	e("PlaySound(Lockpicking_success)")
	self.completed = true
end

function eso_task_lockpick:task_fail_eval()
	return (
		Player.dead or
		ml_global_information.Player_InCombat
	)
end
function eso_task_lockpick:task_fail_execute()
	self:Terminate()
end

eso_task_movetopos = inheritsFrom(ml_task)
function eso_task_movetopos.Create()
    local newinst = inheritsFrom(eso_task_movetopos)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
    
    --eso_task_movetopos members
    newinst.name = "MOVETOPOS"
    newinst.pos = 0
    newinst.range = 1.5
    newinst.pauseTimer = 0
    newinst.remainMounted = false
    newinst.useFollowMovement = false
	newinst.use3d = false
	newinst.dismountDistance = 15
	newinst.failTimer = 0
	
	newinst.distanceCheckTimer = 0
	newinst.lastPosition = nil
	newinst.lastDistance = 0
	
	newinst.abortFunction = nil
    
    return newinst
end

function eso_task_movetopos:Init()	
	
	local ke_getMovementPath = ml_element:create( "GetMovementPath", c_getmovementpath, e_getmovementpath, 85 )
    self:add( ke_getMovementPath, self.process_elements)
	
	local ke_mount = ml_element:create( "Mount", c_mount, e_mount, 20 )
    self:add( ke_mount, self.process_elements)
    
    local ke_sprint = ml_element:create( "Sprint", c_sprint, e_sprint, 15 )
    self:add( ke_sprint, self.process_elements)
    
    local ke_walkToPos = ml_element:create( "WalkToPos", c_walktopos, e_walktopos, 5 )
    self:add( ke_walkToPos, self.process_elements)
    
    self:AddTaskCheckCEs()
end

function eso_task_movetopos:task_complete_eval()
	if (ml_mesh_mgr.loadingMesh ) then
		return true
	end
	
	if (self.abortFunction) then
		if (type(self.abortFunction) == "function") then
			local retval = self.abortFunction()
			if (retval == true) then
				return true
			end
		elseif (type(self.abortFunction) == "table") then
			local abortFunctions = self.abortFunction
			for i,fn in pairs(abortFunctions) do
				if (type(fn) == "function") then
					local retval = fn()
					if (retval == true) then
						return true
					end
				end
			end
		end
	end

    if (ValidTable(self.pos)) then
        local myPos = Player.pos
		local gotoPos = self.pos
		
		local distance = 0.0
		if (self.use3d) then
			distance = Distance3D(myPos.x, myPos.y, myPos.z, gotoPos.x, gotoPos.y, gotoPos.z)
		else
			distance = Distance2D(myPos.x, myPos.z, gotoPos.x, gotoPos.z)
		end 		
	
		if (distance <= self.range) then
			return true
		end
    end    
    return false
end

function eso_task_movetopos:task_complete_execute()
    SafeStop()
	--[[if (not self.remainMounted and ai_mount:CanDismount()) then
		ai_mount:Dismount()
	end]]
    self.completed = true
end

function eso_task_movetopos:task_fail_eval()
	if (not Player:IsMoving()) then
		if (self.failTimer == 0) then
			self.failTimer = Now() + 5000
		end
	else
		if (self.failTimer ~= 0) then
			self.failTimer = 0
		end
	end
	
	return (Player.dead or (self.failTimer ~= 0 and Now() > self.failTimer))
end
function eso_task_movetopos:task_fail_execute()
	SafeStop()
    self.valid = false
end

eso_task_movetointeract = inheritsFrom(ml_task)
function eso_task_movetointeract.Create()
    local newinst = inheritsFrom(eso_task_movetointeract)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    newinst.name = "ESO_MOVETOINTERACT"
	newinst.creator = ""
	
	newinst.started = Now()
	newinst.interact = 0
    newinst.lastinteract = 0
	newinst.delayTimer = 0
	newinst.pos = false
	newinst.use3d = true
	newinst.lastDistance = nil
	newinst.failTimer = 0
	newinst.forceLOS = false
	newinst.interactRange = 4
	newinst.dismountDistance = newinst.interactRange + 10
	newinst.range = 4
	newinst.waitForInteract = false
	newinst.waitingForInteract = false
	newinst.checkLootable = false
	
    return newinst
end

function eso_task_movetointeract:Init()	
	
	local ke_getMovementPath = ml_element:create( "GetMovementPath", c_getmovementpath, e_getmovementpath, 85 )
    self:add( ke_getMovementPath, self.process_elements)
	
	local ke_mount = ml_element:create( "Mount", c_mount, e_mount, 20 )
    self:add( ke_mount, self.process_elements)
    
    local ke_sprint = ml_element:create( "Sprint", c_sprint, e_sprint, 15 )
    self:add( ke_sprint, self.process_elements)
	
	local ke_walkToPos = ml_element:create( "WalkToPos", c_walktopos, e_walktopos, 5 )
    self:add( ke_walkToPos, self.process_elements)
	
	self:AddTaskCheckCEs()
end

function eso_task_movetointeract:task_complete_eval()
	if c_aggro:evaluate() then
		return true
	end
	local isInteracting = Player.interacting
	if (isInteracting) then
		if (self.waitForInteract) then
			self.waitingForInteract = true
		else
			return true
		end
	else
		if (self.waitingForInteract) then
			return true
		end
	end
	
	self.dismountDistance = self.interactRange + 10
	
	if (self.interact ~= 0) then
		local interact = EntityList:Get(tonumber(self.interact))
		if (not interact) then
			return true
		else
			if (self.checkLootable) then
				local found = false
				local lootables = EntityList("lootable,onmesh,maxdistance=30")
				if (ValidTable(lootables)) then
					for i,entity in pairs(lootables) do
						if (entity.id == interact.id) then
							found = true
							if (found) then
								break
							end
						end
					end
				end
				if (not found) then
					return true
				end
			end
		end
	end
	
	if (self.interact ~= 0) then
		local interact = EntityList:Get(tonumber(self.interact))
		if (interact and interact.targetable and interact.distance < 15) then
			--Player:SetTarget(interact.id)
			--d("need set target here")
			local ipos = shallowcopy(interact.pos)
			local p,dist = NavigationManager:GetClosestPointOnMesh(ipos,false)
			if (ValidTable(p)) then
				if (not deepcompare(self.pos,p,true)) then
					self.pos = p
				end
			end
		end
	end
	
	if (self.interact ~= 0 and Now() > self.lastinteract) then
		if (not isInteracting) then
			local interact = EntityList:Get(tonumber(self.interact))
			local forceLOS = self.forceLOS
			if (not forceLOS or (forceLOS and interact.los)) then
				if (interact and interact.distance < self.range) then
					if (Player:IsMoving()) then
						SafeStop()
						return false
					end
				end
				if (interact and interact.distance <= self.interactRange) then
					Player:SetFacing(interact.pos.x,interact.pos.y,interact.pos.z)
					interact:Interact()
					self.lastDistance = interact.pathdistance
					self.lastinteract = Now() + 500
					ml_global_information.Await(1000)
				end
			end
		end
	end
	return false
end

function eso_task_movetointeract:task_complete_execute()
    SafeStop()
	self.completed = true
end

function eso_task_movetointeract:task_fail_eval()
	if (self.interact ~= 0) then
		local interact = EntityList:Get(tonumber(self.interact))
		if (interact) then
			if (self.avoidPlayers) then
				local ppos = Player.pos
				local npos = interact.pos
				local distance = Distance3D(ppos.x,ppos.y,ppos.z,npos.x,npos.y,npos.z)
				
				if (distance < 8) then
					local players = EntityList("nearest,type=1")
					if (players) then
						local index,player = next(players)
						if (index and player) then
							local apos = player.pos
							local pdistance = Distance3D(apos.x,apos.y,apos.z,npos.x,npos.y,npos.z)
							if (pdistance < (distance+2)) then
								EntityList:AddToBlacklist(interact.id,60000)
								d("Temporarily blacklisting object to avoid player collision.")
								return true
							end
						end
					end
				end
			end
		end
	end
	
	if (not c_walktopos:evaluate() and not Player:IsMoving()) then
		if (self.failTimer == 0) then
			self.failTimer = Now() + 5000
		end
	else
		if (self.failTimer ~= 0) then
			self.failTimer = 0
		end
	end
	
	return (Player.dead or (self.failTimer ~= 0 and Now() > self.failTimer))
end

function eso_task_movetointeract:task_fail_execute()
	SafeStop()
    self.valid = false
end


eso_task_combat = inheritsFrom(ml_task)
eso_task_combat.name = "ESO_COMBAT_ATTACK"
function eso_task_combat.Create()
    --ml_log("combatAttack:Create")
	local newinst = inheritsFrom(eso_task_combat)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	newinst.targetID = 0
	newinst.pos = {}
	
	newinst.lastMovement = 0
	newinst.movementDelay = 0
	
    return newinst
end
function eso_task_combat:Init()	
	
	local ke_getMovementPath = ml_element:create( "GetMovementPath", c_getmovementpath, e_getmovementpath, 85 )
    self:add( ke_getMovementPath, self.process_elements)
	
	local ke_usePotion = ml_element:create( "UsePotion", c_usepotion, e_usepotion, 25 )
    self:add(ke_usePotion, self.process_elements)
	
	local ke_mount = ml_element:create( "Mount", c_mount, e_mount, 20 )
    self:add( ke_mount, self.process_elements)
    
    local ke_sprint = ml_element:create( "Sprint", c_sprint, e_sprint, 15 )
    self:add( ke_sprint, self.process_elements)
	
    self:AddTaskCheckCEs()
end

function eso_task_combat:Process()	
	target = EntityList:Get(self.targetID)
	if ValidTable(target) then
		
		self.pos = target.pos
		
		local currentTarget = Player:GetTarget()
		--[[if (not currentTarget or (currentTarget and currenttarget.index ~= target.index)) then
			Player:SetTarget(target.index)
		end]]
		
		local ppos = Player.pos
		local pos = target.pos
		local range = ml_global_information.AttackRange
		
		local dist = Distance3D(ppos.x,ppos.y,ppos.z,pos.x,pos.y,pos.z)
		if (ml_global_information.AttackRange > 5) then
			if ((not InCombatRange(target.index) or (not target.los and not CanAttack(target.index)))) then
				if (Now() > self.movementDelay) then
					Player:MoveTo(pos.x,pos.y,pos.z, false, target.id, 5, true,true)
					self.movementDelay = Now() + 1000
				end
			end
			if (InCombatRange(target.index)) then
				--[[if (ai_mount:CanDismount()) then
					ai_mount:Dismount()
				end]]
				if (Player:IsMoving() and (target.los or CanAttack(target.index))) then
					SafeStop()
				end
				--if (not EntityIsFrontTight(target)) then
					Player:SetFacing(pos.x,pos.y,pos.z) 
				--end
			end
			if (InCombatRange(target.index) and target.health.current > 0) then
				eso_skillmanager.Cast( target )
			end
		else
			if (not InCombatRange(target.index) or (not target.los and not CanAttack(target.index))) then
				Player:MoveTo(pos.x,pos.y,pos.z, false, target.id, 2, true,true)
				ml_task_hub:CurrentTask().lastMovement = Now()
			end
			if (target.distance <= 15) then
				--[[if (ai_mount:CanDismount()) then
					ai_mount:Dismount()
				end]]
			end
			if (InCombatRange(target.index)) then
				Player:SetFacing(pos.x,pos.y,pos.z) 
				if (target.los or CanAttack(target.index)) then
					Player:Stop()
				end
			end
			eso_skillmanager.Cast( target )
		end
	else
		d("no valid target")
	end
      
    --Process regular elements.
    if (TableSize(self.process_elements) > 0) then
		ml_cne_hub.clear_queue()
		ml_cne_hub.eval_elements(self.process_elements)
		ml_cne_hub.queue_to_execute()
		ml_cne_hub.execute()
		return false
	else
		ml_debug("no elements in process table")
	end
end

function eso_task_combat:task_complete_eval()
	local target = EntityList:Get(self.targetID)
    if (not target or not target.alive or target.hp.percent == 0 or not target.attackable) then
        return true
    end
end
function eso_task_combat:task_complete_execute()
    Player:Stop()
	self.completed = true
end

function eso_task_combat:task_fail_eval()	
	if (not Player.alive or Player.isswimming) then
		return true
	end
	
	return false
end
function eso_task_combat:task_fail_execute()
	Player:Stop()
	self.valid = false
end