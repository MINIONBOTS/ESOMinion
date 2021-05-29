-- GrindMode Behavior
Lockpicker = {}
Lockpicker.delay = 0
Lockpicker.chamber = 0
Lockpicker.timer = 0
Lockpicker.interactType = 0
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
	
	--local ke_usePotion = ml_element:create( "UsePotion", c_usepotion, e_usepotion, 15 )
    --self:add(ke_usePotion, self.process_elements)
	
	self:AddTaskCheckCEs()
end
eso_task_assist.lastidcheck = 0
eso_task_assist.lastprocess = 0
eso_task_assist.lootattempt = false
function eso_task_assist:Process()
	--d("AssistMode_Process->")
	--d("timesince last = "..tostring(TimeSince(eso_task_assist.lastprocess)))
	--eso_task_assist.lastprocess = Now()
	  
		
	if (not esominion.playerdead) then
		-- the client does not clear the target offsets since the 1.6 patch
		-- this is a workaround so that players can attack manually while the bot is running
		
		local target = nil
		if gAssistTargetModeSetting == "Highlighted" then
			target = Player:GetHilightedTarget()
		elseif gAssistTargetModeSetting == "Reticle" then
			target = Player:GetTargetUnderReticle()
			if not target then
				target = Player:GetSoftTarget()
			end
		elseif gAssistTargetModeSetting == "Scanner" then
			target = eso_task_assist.GetTarget()
		end
		
		if ( gAssistInitCombat or esominion.incombat ) then
			if ( target and target.hostile and target.health.current > 0) then
				eso_skillmanager.Cast( target )
			end		
		end
	end
end


function eso_task_assist.SelectTargetExtended(maxrange, los, aggro)
	local filterstring = "hostile,targetable,alive,nocritter,maxdistance="..tostring(maxrange)
	if (los) then filterstring = filterstring..",los" end
	if (aggro) then filterstring = filterstring..",aggro" end
	--if (gAssistTargetType == "Players Only") then filterstring = filterstring..",player" end
	if (gAssistTargetMode == "LowestHealth") then 
		filterstring = filterstring..",lowesthealth"
	elseif (gAssistTargetMode == "Closest") then 
		filterstring = filterstring..",nearest" 
	end
	
	if (gAssistTargetMode == "Biggest Crowd") then filterstring = filterstring..",clustered=6" end
	--if (gPreventAttackingInnocents == "1") then filterstring = filterstring..",hostile" end
	local TargetList = EntityList(filterstring)
	if ( TargetList ) then
		local id,entry = next(TargetList)
		if (id and entry ) then
			--d("Attacking "..tostring(entry.id) .. " name "..entry.name)
			return entry
		end
	end	
	return nil
end

function eso_task_assist.GetTarget()
	local target = nil
	if not eso_skillmanager.skillsbyname["Default"] then
		eso_skillmanager.BuildSkillsList()
	end
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
	
	gAssistDoLockpick = esominion.GetSetting("gAssistDoLockpick",true)
	gAssistUsePotions = esominion.GetSetting("gAssistUsePotions",true)
	gPreventAttackingInnocents = esominion.GetSetting("gPreventAttackingInnocents",true)
	gSKMWeaving = esominion.GetSetting("gSKMWeaving",false)
	gAssistLoot = esominion.GetSetting("gAssistLoot",false)
	gAssistDoBlock = esominion.GetSetting("gAssistDoBlock",true)
	gAssistDoExploit = esominion.GetSetting("gAssistDoExploit",true)
	gAssistDoInterrupt = esominion.GetSetting("gAssistDoInterrupt",true)
	gAssistDoBreak = esominion.GetSetting("gAssistDoBreak",true)
	gAssistDoAvoid = esominion.GetSetting("gAssistDoAvoid",true)
	gAssistInitCombat = esominion.GetSetting("gAssistInitCombat",false)
	
	gAssistTargetModeIndex = esominion.GetSetting("gAssistTargetModeIndex",1)
	gAssistTargetModeSetting = esominion.GetSetting("gAssistTargetModeSetting","Reticle")
	gAssistTargetTypeIndex = esominion.GetSetting("gAssistTargetTypeIndex",1)
	gAssistTargetTypeSetting = esominion.GetSetting("gAssistTargetTypeSetting","None")
	
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
	GUI:Text(GetString("Targeting Mode"))
	if In(gAssistTargetModeIndex,3) then
		GUI:AlignFirstTextHeightToWidgets() 
		GUI:Text(GetString("Targeting Type"))
	end
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Start Combat"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Do Lock Picking"))
	--GUI:AlignFirstTextHeightToWidgets() 
	--GUI:Text(GetString("Use Potions"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("SKM Weaving"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Loot Assist"))
	GUI:NextColumn()
	local columnWidth = GUI:GetContentRegionAvail() - 10
	GUI:PushItemWidth(columnWidth)
	
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Combo("##targetingMode","gAssistTargetModeIndex","gAssistTargetModeSetting",{"Reticle","Highlighted","Scanner"});
	if In(gAssistTargetModeIndex,3) then
		GUI:AlignFirstTextHeightToWidgets() 
		GUI_Combo("##targetingassist","gAssistTargetTypeIndex","gAssistTargetTypeSetting",{"None","LowestHealth","Closest","Biggest Crowd"});
	end
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("Start Combat"),gAssistInitCombat),"gAssistInitCombat")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("Do Lock Picking"),gAssistDoLockpick),"gAssistDoLockpick")
	--GUI:AlignFirstTextHeightToWidgets() 
	--GUI_Capture(GUI:Checkbox("##"..GetString("Use Potions"),gAssistUsePotions),"gAssistUsePotions")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("SKM Weaving (TEST)"),gSKMWeaving),"gSKMWeaving")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("Loot"),gAssistLoot),"gAssistLoot")
	
	GUI:PopItemWidth()
	GUI:Columns()
	GUI:Separator()
end

function Lockpicker.timeRemaining()

	if Lockpicker.timer > 0  then
		return  Lockpicker.timer - Now() 
	end
	return 0
end
function Lockpicker.OnUpdate()
	if (GetGameState() == ESO.GAMESTATE.INGAME) then
	
		if not ESO_Common_BotRunning then
			return false
		end
		if (gBotMode == GetString("assistMode") and not gAssistDoLockpick) then
			return false
		end
		if Now() > Lockpicker.delay then
			if Player.interacting then
				if Player.interacttype == 20 then
					if Lockpicker.timer == 0 then
						Lockpicker.timer = Now() + e("GetLockpickingTimeLeft()")
					end
					local timeRemaining = Lockpicker.timeRemaining()
					if (timeRemaining > 0) then
						if Lockpicker.chamber == 0 then
							for i = 1,5 do
								local isChamberSolved = e("IsChamberSolved(" .. i .. ")")
								if (not isChamberSolved) then
									d("Start setting Chamber "..tostring(i)..".")
									e("StartSettingChamber(" .. i .. ")")
									e("PlaySound(Lockpicking_Lockpicker_contact)")
									e("PlaySound(Lockpicking_chamber_start)")
									Lockpicker.chamber = i
									ml_global_information.Await(math.random(400,600))
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
								ml_global_information.Await(math.random(800,1000))
								return true
							end
						end
					end
				end
			else
				Lockpicker.timer = 0
			end
			Lockpicker.delay = Now() + math.random(400,600)
		end
	end
	return false
end
RegisterEventHandler("Gameloop.Update",Lockpicker.OnUpdate,"Lockpicker OnUpdate")