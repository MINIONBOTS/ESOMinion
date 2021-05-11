-- GrindMode Behavior
eso_task_assist = inheritsFrom(ml_task)
eso_task_assist.name = "AssistMode"
eso_task_assist.lastcast = 0
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
	
	local ke_usePotion = ml_element:create( "UsePotion", c_usepotion, e_usepotion, 15 )
    self:add(ke_usePotion, self.process_elements)
	
	self:AddTaskCheckCEs()
end

function eso_task_assist:Process()
	--d("AssistMode_Process->")
	
	if eso_skillmanager.lastskillidcheck ~= e("GetSlotBoundId(1)") or not table.valid(eso_skillmanager.skillsbyindex) then
		eso_skillmanager.BuildSkillsList()
	end
	
	if (Player.health.current > 0) then
		-- the client does not clear the target offsets since the 1.6 patch
		-- this is a workaround so that players can attack manually while the bot is running
		local target = Player:GetSoftTarget()
		--[[if ( gAssistTargetMode ~= "None" ) then
			local newTarget = eso_task_assist.GetTarget()
			if ( newTarget ~= nil and (not target or newTarget.id ~= target.id)) then
				target = newTarget
				Player:SetTarget(target.id)  
			end
		--end]]
		
		--if ( gAssistInitCombat == "1" or ml_global_information.Player_InCombat ) then
			--if ( target and target.attackable and target.health > 0 and not target.iscritter) then
			if ( target and target.hostile and target.health.current > 0) then
			
				local skillData = eso_skillmanager.skillsbyname["Light Attack"]
				if e("ArePlayerWeaponsSheathed()") then
					AbilityList:Cast(skillData.id)
					d("unsheathe weapon 1st")
					ml_global_information.Await(500,1000, function () return not e("ArePlayerWeaponsSheathed()") end)
					return false
				end
				--if (gPreventAttackingInnocents == "0" or target.hostile) then
					--d(TimeSince(eso_task_assist.lastcast))
					--if Now() >= eso_task_assist.lastcast then
						--if AbilityList:CanCast(skillData.id,target.id) == 10 then
							--local minDelay = math.max(skillData.casttime,400)
							--d(minDelay)
							--eso_task_assist.lastcast = Now() + minDelay
							--d("cast")
							--AbilityList:Cast(skillData.id,target.id)
							
						--end
					--end
					eso_skillmanager.Cast( target )
				--end
			end		
		--end
	end
	
	if (TableSize(self.process_elements) > 0) then
		ml_cne_hub.clear_queue()
		ml_cne_hub.eval_elements(self.process_elements)
		ml_cne_hub.queue_to_execute()
		ml_cne_hub.execute()
		return false
	else
		d("no elements in process table")
	end
end


function eso_task_assist.SelectTargetExtended(maxrange, los, aggro)
	--local filterstring = "attackable,targetable,alive,nocritter,maxdistance="..tostring(maxrange)
	--local filterstring = "attackable,targetable,maxdistance="..tostring(maxrange) -- attempt 1 no issues
	--local filterstring = "attackable,targetable,nocritter,maxdistance="..tostring(maxrange) -- attempt 2 crashed after a few mins
	local filterstring = "attackable,targetable,alive,maxdistance="..tostring(maxrange) -- attempt 3 
	if (los) then filterstring = filterstring..",los" end
	if (aggro) then filterstring = filterstring..",aggro" end
	--if (gAssistTargetType == "Players Only") then filterstring = filterstring..",player" end
	--if (gAssistTargetMode == "LowestHealth") then 
	--	filterstring = filterstring..",lowesthealth"
	--elseif (gAssistTargetMode == "Closest") then 
	--	filterstring = filterstring..",nearest" 
	--end
	
	--if (gAssistTargetMode == "Biggest Crowd") then filterstring = filterstring..",clustered=6" end
	--if (gPreventAttackingInnocents == "1") then filterstring = filterstring..",hostile" end
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
	
	target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange, true,true) -- check for aggro targets 1st
	if ( not ValidTable(target) ) then 
		target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange, true) -- normal targets next
	end	
	if ( not ValidTable(target) ) then 
		target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange, false) -- close but no los
	end
	if ( not ValidTable(target) ) then 
		target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange + 5, false) -- slightly out of range
	end
	
	return target
end

function eso_task_assist:UIInit()
	
	
	--[=[GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMtargetmode"),"gAssistTargetMode",GetString("assistMode"),"None,LowestHealth,Closest,Biggest Crowd");
	GUI_NewComboBox(ml_global_information.MainWindow.Name,GetString("sMmode"),"gAssistTargetType",GetString("assistMode"),"Everything,Players Only")
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("startCombat"),"gAssistInitCombat",GetString("assistMode"))
	
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Interrupts","gAssistDoInterrupt",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Exploits","gAssistDoExploit",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Dodges","gAssistDoAvoid",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform Blocks","gAssistDoBlock",GetString("assistMode"))
	GUI_NewCheckbox(ml_global_information.MainWindow.Name,"Perform CC Breaks","gAssistDoBreak",GetString("assistMode"))
	
	gAssistTargetMode = Settings.ESOMinion.gAssistTargetMode
	gAssistTargetType = Settings.ESOMinion.gAssistTargetType
	gAssistInitCombat = Settings.ESOMinion.gAssistInitCombat
	gAssistDoInterrupt = Settings.ESOMinion.gAssistDoInterrupt
	gAssistDoExploit = Settings.ESOMinion.gAssistDoExploit
	gAssistDoAvoid = Settings.ESOMinion.gAssistDoAvoid
	
	gAssistDoBlock = Settings.ESOMinion.gAssistDoBlock
	gAssistDoBreak = Settings.ESOMinion.gAssistDoBreak
	]=]
end

-- Adding it to our botmodes
if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("assistMode")] = eso_task_assist
end 

function eso_task_assist:Draw()
	local mainWidth = (GUI:GetContentRegionAvail() - 10)
	local fontSize = GUI:GetWindowFontSize()
	local windowPaddingY = GUI:GetStyle().windowpadding.y
	local framePaddingY = GUI:GetStyle().framepadding.y
	local itemSpacingY = GUI:GetStyle().itemspacing.y
	
	--GUI:BeginChild("##header-status",0,GUI_GetFrameHeight(10),true)
	--GUI:PushItemWidth(120)
	
	GUI:Separator()
	GUI:Columns(2)
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Do Lock Picking"))
	--GUI:Text(GetString("Use Potions"))
	GUI:NextColumn()
	local columnWidth = GUI:GetContentRegionAvail() - 10
	GUI:PushItemWidth(columnWidth)
	
	GUI_Capture(GUI:Checkbox("##"..GetString("Do Lock Picking"),gAssistDoLockpick),"gAssistDoLockpick")
	--GUI_Capture(GUI:Checkbox("##"..GetString("Use Potions"),gAssistUsePotions),"gAssistUsePotions")
	
	GUI:PopItemWidth()
	GUI:Columns()
	GUI:Separator()
end
Lockpicker = {}
Lockpicker.delay = 0
Lockpicker.chamber = 0
function Lockpicker.OnUpdate()
	if (GetGameState() == ESO.GAMESTATE.INGAME) then
		if (gBotMode == GetString("assistMode") and not gAssistDoLockpick) then
			return false
		end
		if Now() > Lockpicker.delay then
			local lockTime = e("GetLockpickingTimeLeft()")
			if (lockTime and lockTime > 0) then
				if Lockpicker.chamber == 0 then
					for i = 1,5 do
						local isChamberSolved = e("IsChamberSolved(" .. i .. ")")
						if (not isChamberSolved) then
							d("Start setting Chamber "..tostring(i)..".")
							e("StartSettingChamber(" .. i .. ")")
							e("PlaySound(Lockpicking_Lockpicker_contact)")
							e("PlaySound(Lockpicking_chamber_start)")
							Lockpicker.chamber = i
							ml_global_information.Await(500)
							return true
						end
					end
				else
					local chamberStress = e("GetSettingChamberStress()")
					if (chamberStress >= 0.2) then
						e("PlaySound(Lockpicking_chamber_stress)")
						e("StopSettingChamber()")
						d("Chamber "..tostring(Lockpicker.chamber).." is solved.")
						Lockpicker.chamber = 0
						ml_global_information.Await(1000)
						return true
					end
				end
			end
			Lockpicker.delay = Now() + 500
		end
	end
	return false
end
RegisterEventHandler("Gameloop.Update",Lockpicker.OnUpdate,"Lockpicker OnUpdate")