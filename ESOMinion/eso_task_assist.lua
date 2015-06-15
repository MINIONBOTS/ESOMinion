-- GrindMode Behavior
eso_task_assist = inheritsFrom(ml_task)
eso_task_assist.name = "AssistMode"

function eso_task_assist.Create()
	local newinst = inheritsFrom(eso_task_assist)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
            
	newinst.lastTargetID = 0		
			
    return newinst
end

function eso_task_assist:Init()
	local ke_pickLocks = ml_element:create( "PickLocks", c_lockpick, e_lockpick, 25 )
    self:add(ke_pickLocks, self.process_elements)
	
	--local ke_lootwindow = ml_element:create( "lootwindow", c_lootwindow, e_lootwindow, 24 )
	--self:add(ke_lootwindow, self.process_elements)
	
	self:AddTaskCheckCEs()
end

function eso_task_assist:Process()
	--ml_log("AssistMode_Process->")
	if ( Player.alive ) and ( e("IsMounted()") == false ) then
		-- the client does not clear the target offsets since the 1.6 patch
		-- this is a workaround so that players can attack manually while the bot is running
		local target = Player:GetTarget()
		if (target and target.id ~= self.lastTargetID) then
			Player:ClearTarget()
			self.lastTargetID = target.id
		end
		
		if ( gAssistTargetMode ~= "None" ) then
			local newTarget = eso_task_assist.GetTarget()
			if ( newTarget ~= nil and (not target or newTarget.id ~= target.id)) then
				target = newTarget
				Player:SetTarget(target.id)  
			end
		end
		
		if ( gAssistInitCombat == "1" or ml_global_information.Player_InCombat ) then
			if ( target and target.attackable and target.alive and not target.iscritter) then
				if (gPreventAttackingInnocents == "0" or target.hostile) then
					eso_skillmanager.Cast( target )
				end
			end		
		end
	end
	
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


function eso_task_assist.SelectTargetExtended(maxrange, los)
	local filterstring = "attackable,targetable,alive,nocritter,maxdistance="..tostring(maxrange)
	if (los) then filterstring = filterstring..",los" end
	if (gAssistTargetType == "Players Only") then filterstring = filterstring..",player" end
	if (gAssistTargetMode == "LowestHealth") then 
		filterstring = filterstring..",lowesthealth"
	elseif (gAssistTargetMode == "Closest") then 
		filterstring = filterstring..",nearest" 
	end
	
	if (gAssistTargetMode == "Biggest Crowd") then filterstring = filterstring..",clustered=6" end
	if (gPreventAttackingInnocents == "1") then filterstring = filterstring..",hostile" end
	
	local TargetList = EntityList(filterstring)
	if ( TargetList ) then
		local id,entry = next(TargetList)
		if (id and entry ) then
			ml_log("Attacking "..tostring(entry.id) .. " name "..entry.name)
			return entry
		end
	end	
	return nil
end

function eso_task_assist.GetTarget()
	local target = nil
	
	target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange, true)	
	if ( not ValidTable(target) ) then 
		target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange, false) 
	end
	if ( not ValidTable(target) ) then 
		target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange + 5, false) 
	end
	
	return target
end

function eso_task_assist.ModuleInit()
	
	if (Settings.ESOMinion.gAssistTargetMode == nil) then
		Settings.ESOMinion.gAssistTargetMode = "None"
	end
	if (Settings.ESOMinion.gAssistTargetType == nil) then
		Settings.ESOMinion.gAssistTargetType = "Everything"
	end
	if (Settings.ESOMinion.gAssistInitCombat == nil) then
		Settings.ESOMinion.gAssistInitCombat = "0"
	end
	if (Settings.ESOMinion.gAssistDoInterrupt == nil) then
		Settings.ESOMinion.gAssistDoInterrupt = "1"
	end
	if (Settings.ESOMinion.gAssistDoExploit == nil) then
		Settings.ESOMinion.gAssistDoExploit = "1"
	end
	if (Settings.ESOMinion.gAssistDoAvoid == nil) then
		Settings.ESOMinion.gAssistDoAvoid = "1"
	end
	if (Settings.ESOMinion.gAssistDoBlock == nil) then
		Settings.ESOMinion.gAssistDoBlock = "1"
	end
	if (Settings.ESOMinion.gAssistDoBreak == nil) then
		Settings.ESOMinion.gAssistDoBreak = "1"
	end
	if (Settings.ESOMinion.gAssistDoLockpick == nil) then
		Settings.ESOMinion.gAssistDoLockpick = "1"
	end
	
	
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMtargetmode"),"gAssistTargetMode",GetString("assistMode"),"None,LowestHealth,Closest,Biggest Crowd");
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMmode"),"gAssistTargetType",GetString("assistMode"),"Everything,Players Only")
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("startCombat"),"gAssistInitCombat",GetString("assistMode"))
	
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Interrupts","gAssistDoInterrupt",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Exploits","gAssistDoExploit",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Dodges","gAssistDoAvoid",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Blocks","gAssistDoBlock",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform CC Breaks","gAssistDoBreak",GetString("assistMode"))
	
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Lockpicks","gAssistDoLockpick",GetString("assistMode"))
	
	gAssistTargetMode = Settings.ESOMinion.gAssistTargetMode
	gAssistTargetType = Settings.ESOMinion.gAssistTargetType
	gAssistInitCombat = Settings.ESOMinion.gAssistInitCombat
	gAssistDoInterrupt = Settings.ESOMinion.gAssistDoInterrupt
	gAssistDoExploit = Settings.ESOMinion.gAssistDoExploit
	gAssistDoAvoid = Settings.ESOMinion.gAssistDoAvoid
	
	gAssistDoBlock = Settings.ESOMinion.gAssistDoBlock
	gAssistDoBreak = Settings.ESOMinion.gAssistDoBreak
	gAssistDoLockpick = Settings.ESOMinion.gAssistDoLockpick
end

-- Adding it to our botmodes
if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("assistMode")] = eso_task_assist
end 

function eso_task_assist.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "gAssistTargetMode" or
			k == "gAssistTargetType" or
			k == "gAssistInitCombat" or 
			k == "gAssistDoInterrupt" or 
			k == "gAssistDoExploit" or 
			k == "gAssistDoAvoid" or 
			k == "gAssistDoBlock" or 
			k == "gAssistDoBreak" or
			k == "gAssistDoLockpick"
		)						
		then
			Settings.ESOMinion[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(ml_global_information.MainWindow.Name)
end

RegisterEventHandler("Module.Initalize",eso_task_assist.ModuleInit)
RegisterEventHandler("GUI.Update",eso_task_assist.GUIVarUpdate)
