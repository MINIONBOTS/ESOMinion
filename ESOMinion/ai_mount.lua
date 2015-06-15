--:===============================================================================================================
--: Mount
--:===============================================================================================================

ai_mount = {}

--:===============================================================================================================
--: API Usage
--:===============================================================================================================  
-- func: e("IsMounted()") 				- Returns: bool mounted
-- func: e("ToggleMount()")				- Mount or Dismount
-- func: e("IsInteractionPending()") 	- gathering bug pends interactions
-- func: e("EndPendingInteraction()")	- end it, before mounting

--:===============================================================================================================
--: Mount
--:===============================================================================================================

function ai_mount:Mount()
	if (TimeSince(ai_mount.lastmount) >= ai_mount.throttle) then
		d("Mounting")
		
		if e("IsInteractionPending()") then
			e("EndPendingInteraction()")
		end
		
		e("ToggleMount()")
		ml_task_hub:CurrentTask():SetDelay(math.random(500,750))
		ai_mount.lastmount = Now()
	end
end

--:===============================================================================================================
--: Dismount
--:===============================================================================================================

function ai_mount:Dismount()
	if (TimeSince(ai_mount.lastmount) >= ai_mount.throttle) then
		d("Dismounting")
		
		if e("IsInteractionPending()") then
			e("EndPendingInteraction()")
		end

		e("ToggleMount()")
		ml_task_hub:CurrentTask():SetDelay(math.random(500,750))
		ai_mount.lastmount = Now()
	end
end

--:===============================================================================================================
--: Functions
--:===============================================================================================================

function ai_mount:HaveMount()
	return e("HasMountSkin()")
end

function ai_mount:CanMount()
	return Player.onmesh and not Player.isswimming and not ml_global_information.Player_InCombat and not ai_mount:IsMounted() and
		 not Player.iscasting and tonumber(e("GetChatterOptionCount()")) == 0 and TimeSince(ai_mount.lastmount) >= ai_mount.throttle
		 and ai_mount:HaveMount()
end

function ai_mount:CanDismount()
	return Player.onmesh and not Player.isswimming and not ml_global_information.Player_InCombat and ai_mount:IsMounted() and
		 not Player.iscasting and tonumber(e("GetChatterOptionCount()")) == 0 and TimeSince(ai_mount.lastmount) >= ai_mount.throttle
		 and ai_mount:HaveMount()
end

function ai_mount:IsMounted()
	return e("IsMounted()")
end

--:===============================================================================================================
--: Initialize
--:===============================================================================================================

function ai_mount.Initialize()
	ai_mount.lastmount = 0
	ai_mount.throttle  = 5000
	
	if Settings.ESOMinion.gUseMount == nil then Settings.ESOMinion.gUseMount = "1" end
	if Settings.ESOMinion.gUseMountRange == nil then Settings.ESOMinion.gUseMountRange = "100" end
	
	local window = ml_global_information.MainWindow
	GUI_NewCheckbox(window.Name,"UseMount","gUseMount",GetString("settings"))
	GUI_NewNumeric(window.Name,"MountDistance","gUseMountRange",GetString("settings"),"30","10000")
	
	gUseMount = Settings.ESOMinion.gUseMount
	gUseMountRange = Settings.ESOMinion.gUseMountRange
end

--:===============================================================================================================
--: GuiUpdate
--:===============================================================================================================

function ai_mount.GuiUpdate(event,newvars,oldvars)
	for key,value in pairs(newvars) do
		if 	key == "gUseMount" or
			key == "gUseMountRange"					
		then
			Settings.ESOMinion[tostring(key)] = value
		end
	end
end

--:===============================================================================================================
--: Debug
--:===============================================================================================================

RegisterForEvent("EVENT_MOUNT_FAILURE", true)

RegisterEventHandler("GAME_EVENT_MOUNT_FAILURE",
	function(event,id,reason,args)
		if tonumber(reason) == 0 then
			d("[Mount Error] Waiting to try again [Reason] InCombat")
		end
		if tonumber(reason) == 1 then
			d("[Mount Error] Waiting to try again [Reason] No Horse Zone")
		end
		ai_mount.lastmount = ml_global_information.Now + math.random(10000,30000)
	end
)

--:===============================================================================================================
--: EventHandlers
--:===============================================================================================================

RegisterEventHandler("Module.Initalize",ai_mount.Initialize)
RegisterEventHandler("GUI.Update",ai_mount.GuiUpdate)


	
