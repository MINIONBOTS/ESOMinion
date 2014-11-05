--:======================================================================================================================================================================
--: release
--:======================================================================================================================================================================

eso_task_release = inheritsFrom(ml_task)

function eso_task_release.Create()

	local newinst = inheritsFrom(eso_task_release)
    
    --: ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--: eso_task_release members
	newinst.name = "eso_task_release"
	newinst.delay = 4000
	
    return newinst
end

function eso_task_release:Init()
	self:AddTaskCheckCEs()
end

function eso_task_release:task_complete_eval()
	return not e("IsUnitDead(player)")
end

function eso_task_release:task_complete_execute()
	ml_global_information.ResetBot()
	self.completed = true
end

function eso_task_release:Process()
	if (self.delay and not self.time) then
		self.time = Now() + self.delay
	end
	
	if (Now() > self.time) then
		e("Release()")
		ml_log(" -> releasing")
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

