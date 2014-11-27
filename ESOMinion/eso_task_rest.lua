--:======================================================================================================================================================================
--: rest
--:======================================================================================================================================================================

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
	newinst.name = "eso_task_rest"
	newinst.hp = { percent = 0 }
	newinst.mp = { percent = 0 }
	newinst.sp = { percent = 0 }
	
    return newinst
end

--:============================================================================================
--: initialize
--:============================================================================================

function eso_task_rest:Init()
	self:AddTaskCheckCEs()
end

--:============================================================================================
--: eval complete
--:============================================================================================

function eso_task_rest:task_complete_eval()
	return (
		self.hp.percent >= tonumber(g_resthp) and
		self.mp.percent >= tonumber(g_restmp) and
		self.sp.percent >= tonumber(g_restsp)
	)
end

function eso_task_rest:task_complete_execute()
	self.completed = true
end

--:============================================================================================
--: eval failed
--:============================================================================================

function eso_task_rest:task_fail_eval()
	return (
		e("IsUnitDead(player)") or
		e("IsUnitInCombat(player)") or
		Player.isswimming or
		Player.iscasting
	)
end

function eso_task_rest:task_fail_execute()
	self:Terminate()
end

--:============================================================================================
--: process
--:============================================================================================

function eso_task_rest:Process()
	--: hp
	self.hp = {e("GetUnitPower(player,"..tostring(g("POWERTYPE_HEALTH"))..")")}
	self.hp.percent = self.hp[1]*100/self.hp[3]
	if self.hp.percent >= tonumber(g_resthp) then self.hp.percentile = 100 else
		self.hp.percentile = math.floor(self.hp.percent*100/tonumber(g_resthp))
	end
	
	--: mp
	self.mp = {e("GetUnitPower(player,"..tostring(g("POWERTYPE_MAGICKA"))..")")}
	self.mp.percent = self.mp[1]*100/self.mp[3]
	if self.mp.percent >= tonumber(g_restmp) then self.mp.percentile = 100 else
		self.mp.percentile = math.floor(self.mp.percent*100/tonumber(g_restmp))
	end
	
	--: sp
	self.sp = {e("GetUnitPower(player,"..tostring(g("POWERTYPE_STAMINA"))..")")}
	self.sp.percent = self.sp[1]*100/self.sp[3]
	if self.sp.percent >= tonumber(g_restsp) then self.sp.percentile = 100 else
		self.sp.percentile = math.floor(self.sp.percent*100/tonumber(g_restsp))
	end
	
	local current = (self.hp.percentile + self.mp.percentile + self.sp.percentile)
	local target  = (tonumber(g_resthp) + tonumber(g_restmp) + tonumber(g_restsp))
	local percentage = math.floor(current*100/300)
	
	if Player:IsMoving() then
		Player:Stop()
	end

	ml_log(" -> resting, " .. percentage .. "% completed")

    if (TableSize(self.process_elements) > 0) then
		ml_cne_hub.clear_queue()
		ml_cne_hub.eval_elements(self.process_elements)
		ml_cne_hub.queue_to_execute()
		ml_cne_hub.execute()
	end
end

