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
            
    return newinst
end

function eso_ai_assist:Init()

end

function eso_ai_assist:Process()
	--ml_log("AssistMode_Process->")
		
	if ( ml_global_information.Player_Dead == false ) and ( e("IsMounted()") == false ) then
		
		
		-- LootAll
		if ( c_LootAll:evaluate() ) then e_LootAll:execute() end
		
		if ( sMtargetmode == "None" ) then
			local target = Player:GetTarget()
			if ( target and target.attackable and target.alive and target.iscritter == false) then 
				eso_skillmanager.AttackTarget( target.id )
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
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMtargetmode"),"sMtargetmode",GetString("assistMode"),"None,LowestHealth,Closest,Biggest Crowd");
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMmode"),"sMmode",GetString("assistMode"),"Everything,Players Only")
	
	sMtargetmode = Settings.ESOMinion.sMtargetmode
	sMmode = Settings.ESOMinion.sMmode
	
end


-- Adding it to our botmodes
if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("assistMode")] = eso_ai_assist
end 

RegisterEventHandler("Module.Initalize",eso_ai_assist.moduleinit)
