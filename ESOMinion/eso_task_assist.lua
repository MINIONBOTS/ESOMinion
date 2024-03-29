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
	if (Player.health.current > 0) then
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
		elseif gAssistTargetModeSetting == "Aggro" then
			local TargetList = MEntityList("lowesthealth,attackable,aggro,maxdistance=28")
			if table.valid(TargetList) then
				local id,entry = next(TargetList)
				if (id and entry ) then
					target = entry
				end
			end
		end
		if not IsMounted() and not Player.interacting then
			if ( gAssistInitCombat or Player.incombat or gAssistAllowOOC) then
				if ( target and target.attackable and target.health.current > 0) then
					eso_skillmanager.Cast( target )
				elseif gAssistAllowOOC then
					eso_skillmanager.Cast( Player )
				end	
			end
		end
	end
end


function eso_task_assist.SelectTargetExtended(maxrange, los, aggro)
	local filterstring = "attackable,targetable,alive,nocritter,maxdistance="..tostring(maxrange)
	if (los) then filterstring = filterstring..",los" end
	if (aggro) then filterstring = filterstring..",aggro" end
	--if (gAssistTargetType == "Players Only") then filterstring = filterstring..",player" end
	if (gAssistTargetMode == "LowestHealth") then 
		filterstring = filterstring..",lowesthealth"
	elseif (gAssistTargetMode == "Closest") then 
		filterstring = filterstring..",nearest" 
	end
	
	if (gAssistTargetMode == "Biggest Crowd") then filterstring = filterstring..",clustered=6" end
	local TargetList = MEntityList(filterstring)
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
	target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange, true, true) -- check for aggro targets 1st
	if ( not ValidTable(target) ) then 
		target = eso_task_assist.SelectTargetExtended(ml_global_information.AttackRange, false, true) -- normal targets next
	end	
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
	
	gAssistBlessedShards = esominion.GetSetting("gAssistBlessedShards",false)
	gAssistDoLockpick = esominion.GetSetting("gAssistDoLockpick",true)
	gAssistUsePotions = esominion.GetSetting("gAssistUsePotions",true)
	gSKMWeaving = esominion.GetSetting("gSKMWeaving",false)
	gAssistLoot = esominion.GetSetting("gAssistLoot",false)
	gAssistDoBlock = esominion.GetSetting("gAssistDoBlock",true)
	gAssistDoExploit = esominion.GetSetting("gAssistDoExploit",true)
	gAssistDoInterrupt = esominion.GetSetting("gAssistDoInterrupt",true)
	gAssistDoBreak = esominion.GetSetting("gAssistDoBreak",true)
	gAssistDoAvoid = esominion.GetSetting("gAssistDoAvoid",true)
	gAssistInitCombat = esominion.GetSetting("gAssistInitCombat",false)
	gAssistAllowOOC = esominion.GetSetting("gAssistAllowOOC",false)
	gSKMShowAll = false
	gAssistIsDummy = false
	
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
	GUI:Text(GetString("Allow OOC Casting"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Do Block"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Do Exploit"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Do Interrupt"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Do Break"))
	GUI:AlignFirstTextHeightToWidgets() 
	GUI:Text(GetString("Do Avoid"))
	GUI:NextColumn()
	local columnWidth = GUI:GetContentRegionAvail() - 10
	GUI:PushItemWidth(columnWidth)
	
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Combo("##targetingMode","gAssistTargetModeIndex","gAssistTargetModeSetting",{"Reticle","Highlighted","Scanner","Aggro"});
	if In(gAssistTargetModeIndex,3) then
		GUI:AlignFirstTextHeightToWidgets() 
		GUI_Combo("##targetingassist","gAssistTargetTypeIndex","gAssistTargetTypeSetting",{"None","LowestHealth","Closest","Biggest Crowd"});
	end
	GUI:AlignFirstTextHeightToWidgets() 
	
	
	GUI_Capture(GUI:Checkbox("##"..GetString("Start Combat"),gAssistInitCombat),"gAssistInitCombat")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("Allow OOC Casting"),gAssistAllowOOC),"gAssistAllowOOC")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("gAssistDoBlock"),gAssistDoBlock),"gAssistDoBlock")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("gAssistDoExploit"),gAssistDoExploit),"gAssistDoExploit")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("gAssistDoInterrupt"),gAssistDoInterrupt),"gAssistDoInterrupt")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("gAssistDoBreak"),gAssistDoBreak),"gAssistDoBreak")
	GUI:AlignFirstTextHeightToWidgets() 
	GUI_Capture(GUI:Checkbox("##"..GetString("gAssistDoAvoid"),gAssistDoAvoid),"gAssistDoAvoid")
	
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
Lockpicker.Chamber1 = ""
Lockpicker.Chamber2 = ""
Lockpicker.Chamber3 = ""
Lockpicker.Chamber4 = ""
Lockpicker.Chamber5 = ""
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
					local lockpicksRemaining = e("GetNumLockpicksLeft()")
					if (timeRemaining > 0 and lockpicksRemaining > 0) then
						esominion.GUI.lockpicking.open = true
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
								else
									if i == 1 then
										Lockpicker.Chamber1 = "Set"
									elseif i == 2 then
										Lockpicker.Chamber2 = "Set"
									elseif i == 3 then
										Lockpicker.Chamber3 = "Set"
									elseif i == 4 then
										Lockpicker.Chamber4 = "Set"
									elseif i == 5 then
										Lockpicker.Chamber5 = "Set"
									end
								end
							end
						else
							local chamberStress = e("GetSettingChamberStress()")
							--d("chamberStress = "..tostring(chamberStress))
							if (chamberStress >= 0.2) then
								e("PlaySound(Lockpicking_chamber_stress)")
								e("StopSettingChamber()")
								d("Chamber "..tostring(Lockpicker.chamber).." is solved.")
								Lockpicker.chamber = 0
								ml_global_information.Await(math.random(800,1000))
							end
							return true
						end
					else
						d("exit window here")
					end
				end
			else
				Lockpicker.timer = 0
				Lockpicker.Chamber1 = ""
				Lockpicker.Chamber2 = ""
				Lockpicker.Chamber3 = ""
				Lockpicker.Chamber4 = ""
				Lockpicker.Chamber5 = ""
			end
			Lockpicker.delay = Now() + math.random(400,600)
		end
		Lockpicker.Chamber1 = ""
		Lockpicker.Chamber2 = ""
		Lockpicker.Chamber3 = ""
		Lockpicker.Chamber4 = ""
		Lockpicker.Chamber5 = ""
		esominion.GUI.lockpicking.open = false
	end
	return false
end
function Lockpicker.Draw()

	if (esominion.GUI.lockpicking.open) then
		GUI:SetNextWindowSize(250,125,GUI.SetCond_Always) --set the next window size, only on first ever	
		GUI:SetNextWindowCollapsed(false,GUI.SetCond_Always)
		
		local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
		GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], .75)
		
		local flags = (GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
		esominion.GUI.lockpicking.visible, esominion.GUI.lockpicking.open = GUI:Begin(esominion.GUI.lockpicking.name, esominion.GUI.lockpicking.open, flags)
		if ( esominion.GUI.lockpicking.visible ) then 
		
			local x, y = GUI:GetWindowPos()
			local width, height = GUI:GetWindowSize()
			local contentwidth = GUI:GetContentRegionAvailWidth()
			
			esominion.GUI.x = x; esominion.GUI.y = y; esominion.GUI.width = width; esominion.GUI.height = height;
	
	
			GUI:Separator()
			
			GUI:AlignFirstTextHeightToWidgets() 
			GUI:Text(GetString("Chamber 1"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber1 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 1 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 2"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber2 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 2 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 3"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber3 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 3 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 4"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber4 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 4 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
			GUI:Text(GetString("Chamber 5"))
			GUI:SameLine()
			GUI:Text(" | ")
			GUI:SameLine()
			if Lockpicker.Chamber5 == "Set" then
				GUI:TextColored(0,.8,.3,1,GetString("SET"))
			elseif Lockpicker.chamber == 5 then
				GUI:TextColored(1,.5,0,1,GetString("RUNNING"))
			else
				GUI:TextColored(1,.1,.2,1,GetString("...Waiting"))
			end
			GUI:Separator()
		end
		GUI:End()
		GUI:PopStyleColor()
	end
end
RegisterEventHandler("Gameloop.Draw",Lockpicker.Draw,"Lockpicker Draw")
RegisterEventHandler("Gameloop.Update",Lockpicker.OnUpdate,"Lockpicker OnUpdate")