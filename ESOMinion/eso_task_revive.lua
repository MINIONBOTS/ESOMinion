--:======================================================================================================================================================================
--: revive
--:======================================================================================================================================================================

eso_task_revive = inheritsFrom(ml_task)

function eso_task_revive.Create()

	local newinst = inheritsFrom(eso_task_revive)
    
    --: ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--: eso_task_revive members
	newinst.name = "eso_task_revive"
	newinst.delay = 4000
	
    return newinst
end

--:============================================================================================
--: initialize
--:============================================================================================

function eso_task_revive:Init()
	self:AddTaskCheckCEs()
end

--:============================================================================================
--: eval complete
--:============================================================================================

function eso_task_revive:task_complete_eval()
	return not Player.isghost and not e("IsUnitDead(player)")
end

function eso_task_revive:task_complete_execute()
	ml_global_information.ResetBot()
	self.completed = true
end

--:============================================================================================
--: eval failed
--:============================================================================================

function eso_task_revive:task_fail_eval()
	return false
end

function eso_task_revive:task_fail_execute()
	self:Terminate()
end

--:============================================================================================
--: process
--:============================================================================================

function eso_task_revive:Process()
	if (self.delay and not self.time) then
		self.time = Now() + self.delay
	end
	
	if (Now() > self.time) then
		if not Player.isghost then
			e("Revive()")
		end
		ml_log(" -> reviving")
	else
		local remaining = math.floor((self.time - Now())/1000)
		ml_log(" -> waiting " .. remaining .. " seconds to revive")
	end
	
    if (TableSize(self.process_elements) > 0) then
		ml_cne_hub.clear_queue()
		ml_cne_hub.eval_elements(self.process_elements)
		ml_cne_hub.queue_to_execute()
		ml_cne_hub.execute()
	end
end

