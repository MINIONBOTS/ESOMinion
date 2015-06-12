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
	return ((not self.useSoulGem and not e("IsUnitDead(player)")) or 
		(self.useSoulGem and not Player.isghost and not e("IsUnitDead(player)")))
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
		Player:Stop()
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
		e("IsUnitDead(player)") or
		e("IsUnitInCombat(player)") or
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
				self.currentChamber = i
				self.delay = Now() + 500
			end
		end
	else
		local chamberStress = e("GetSettingChamberStress()")
		if (chamberStress > 0) then
			e("StopSettingChamber()")
			d("Chamber "..tostring(self.currentChamber).." is solved.")
			self.currentChamber = 0
			self.delay = Now() + 1000
		end
	end
	
	local isInteracting = e("IsPlayerInteractingWithObject()")
	local lockTime = e("GetLockpickingTimeLeft()")
	
	if (not isInteracting or lockTime <= 0) then
		return true
	end
	
	return false
end
function eso_task_lockpick:task_complete_execute()
	self.completed = true
end

function eso_task_lockpick:task_fail_eval()
	return (
		e("IsUnitDead(player)") or
		e("IsUnitInCombat(player)")
	)
end
function eso_task_lockpick:task_fail_execute()
	self:Terminate()
end
