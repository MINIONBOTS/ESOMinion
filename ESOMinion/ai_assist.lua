-- GrindMode Behavior
eso_ai_assist = inheritsFrom(ml_task)
eso_ai_assist.name = "AssistMode"

function eso_ai_assist.Create()
	local newinst = inheritsFrom(eso_ai_assist)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
            
	newinst.lastTargetID = 0		
			
    return newinst
end

function eso_ai_assist:Init()

end

function eso_ai_assist:Process()
	--ml_log("AssistMode_Process->")
	if ( ml_global_information.Player_Dead == false ) and ( e("IsMounted()") == false ) then
		-- LootAll
		if ( c_LootAll:evaluate() ) then e_LootAll:execute() end
		
		-- the client does not clear the target offsets since the 1.6 patch
		-- this is a workaround so that players can attack manually while the bot is running
		local target = Player:GetTarget()
		if(target and target.id ~= self.lastTargetID) then
			Player:ClearTarget()
			self.lastTargetID = target.id
		end
		
		if( gAssistInitCombat == "0" and not ml_global_information.Player_InCombat ) then
			return
		end
		
		if ( sMtargetmode == "None" ) then
			if ( target and target.attackable and target.alive and target.iscritter == false) then
				if(gPreventAttackingInnocents == "0" or target.hostile) then
					eso_skillmanager.AttackTarget( target.id )
				end
			end		
		else
			eso_ai_assist.SetTargetAssist()
		end
	end
end


function eso_ai_assist.SelectTargetExtended(maxrange, los)
    
	local filterstring = "attackable,targetable,alive,nocritter,maxdistance="..tostring(maxrange)
	
	if (los == "1") then filterstring = filterstring..",los" end
	if (sMmode == "Players Only") then filterstring = filterstring..",player" end
	if (sMtargetmode == "LowestHealth") then filterstring = filterstring..",lowesthealth" end
	if (sMtargetmode == "Closest") then filterstring = filterstring..",nearest" end
	if (sMtargetmode == "Biggest Crowd") then filterstring = filterstring..",clustered=600" end
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

function eso_ai_assist.SetTargetAssist()
	-- Try to get Enemy with los in range first
	local target = eso_ai_assist.SelectTargetExtended(ml_global_information.AttackRange, 1)	
	if ( not target ) then target = eso_ai_assist.SelectTargetExtended(ml_global_information.AttackRange, 0) end
	if ( not target ) then target = eso_ai_assist.SelectTargetExtended(ml_global_information.AttackRange + 5, 0) end
	
	if ( target ) then 
		Player:SetTarget(target.id)
		return eso_skillmanager.AttackTarget( target.id ) 
	else
		return false
	end
end

function eso_ai_assist.moduleinit()
	
	if (Settings.ESOMinion.sMtargetmode == nil) then
		Settings.ESOMinion.sMtargetmode = "None"
	end
	if (Settings.ESOMinion.sMmode == nil) then
		Settings.ESOMinion.sMmode = "Everything"
	end
	if (Settings.ESOMinion.gAssistInitCombat == nil) then
		Settings.ESOMinion.gAssistInitCombat = "0"
	end
	
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMtargetmode"),"sMtargetmode",GetString("assistMode"),"None,LowestHealth,Closest,Biggest Crowd");
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMmode"),"sMmode",GetString("assistMode"),"Everything,Players Only")
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("startCombat"),"gAssistInitCombat",GetString("assistMode"))
	
	sMtargetmode = Settings.ESOMinion.sMtargetmode
	sMmode = Settings.ESOMinion.sMmode
	gAssistInitCombat = Settings.ESOMinion.gAssistInitCombat
end


-- Adding it to our botmodes
if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("assistMode")] = eso_ai_assist
end 

function eso_ai_assist.guivarupdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "sMtargetmode" or
			k == "sMmode" or
			k == "gAssistInitCombat"
		)						
		then
			Settings.ESOMinion[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(ml_global_information.MainWindow.Name)
end

RegisterEventHandler("Module.Initalize",eso_ai_assist.moduleinit)
RegisterEventHandler("GUI.Update",eso_ai_assist.guivarupdate)
