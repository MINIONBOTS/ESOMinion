eso_task_quest = inheritsFrom(ml_task)
eso_task_quest.name = "LT_QUEST_ENGINE"
eso_task_quest.profilePath = GetStartupPath()..[[\LuaMods\esominion\QuestProfiles\]]
eso_task_quest.questList = {}
eso_task_quest.currentQuest = {}

function eso_task_quest.Create()
    local newinst = inheritsFrom(eso_task_quest)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
    newinst.name = "LT_QUEST_ENGINE"
    
	newinst.profileCompleted = false
    newinst.profilePath = ""
    
    return newinst
end

function eso_task_quest.UIInit()
	if (Settings.ESOMinion.gLastQuestProfile == nil) then
        Settings.ESOMinion.gLastQuestProfile = ""
    end
	if (Settings.ESOMinion.completedQuestIDs == nil) then
		Settings.ESOMinion.completedQuestIDs = {}
	end
	if (Settings.ESOMinion.gCurrQuestID == nil) then
        Settings.ESOMinion.gCurrQuestID = ""
    end
	if (Settings.ESOMinion.gCurrQuestName == nil) then
		Settings.ESOMinion.gCurrQuestName = ""
	end
	if (Settings.ESOMinion.gCurrQuestStep == nil) then
		Settings.ESOMinion.gCurrQuestStep = 0
	end
	if (Settings.ESOMinion.currentQuestCondition == nil) then
		Settings.ESOMinion.currentQuestCondition = 0
	end
	if (Settings.ESOMinion.gTestQuest == nil) then
        Settings.ESOMinion.gTestQuest = "0"
    end
	if (Settings.ESOMinion.gQuestAutoEquip == nil) then
		Settings.ESOMinion.gQuestAutoEquip = "1"
	end
	if(gBotMode == GetString("questMode")) then
		eso_task_quest.UpdateProfiles()
	end
	
	local winName = ml_global_information.MainWindow.Name
	local group = GetString("questMode")
	GUI_NewComboBox(winName,strings[gCurrentLanguage].profile,"gProfile",group,"None")
	GUI_NewField(winName, GetString("questID"), "gCurrQuestID",group)
	GUI_NewField(winName, GetString("questName"), "gCurrQuestName",group)
	GUI_NewField(winName, GetString("stepIndex"), "gCurrQuestStep",group)
	GUI_NewField(winName, GetString("conditionIndex"), "gCurrQuestCondition",group)
	GUI_NewCheckbox(winName,GetString("autoEquip"),"gQuestAutoEquip",group)
	GUI_WindowVisible(winName, false)
	
	gCurrQuestID = Settings.ESOMinion.gCurrQuestID
	gCurrQuestName = Settings.ESOMinion.gCurrQuestName
	gCurrQuestStep = Settings.ESOMinion.gCurrQuestStep
	gCurrQuestCondition = Settings.ESOMinion.gCurrQuestCondition
	gTestQuest = Settings.ESOMinion.gTestQuest
	gQuestAutoEquip = Settings.ESOMinion.gQuestAutoEquip
end

function eso_task_quest.UpdateProfiles()
    local profiles = "None"
    local found = "None"	
    local profilelist = dirlist(eso_task_quest.profilePath,".*info")
    if ( TableSize(profilelist) > 0) then			
        local i,profile = next ( profilelist)
        while i and profile do				
            profile = string.gsub(profile, ".info", "")
            profiles = profiles..","..profile
            if ( Settings.ESOMinion.gLastQuestProfile ~= nil and Settings.ESOMinion.gLastQuestProfile == profile ) then
                d("Last Profile found : "..profile)
                found = profile
            end
            i,profile = next ( profilelist,i)
        end		
    else
        d("No quest profiles found")
    end
    gProfile_listitems = profiles
    gProfile = found
	if (gProfile ~= "" and gProfile ~= "None") then
		eso_task_quest.LoadProfile(eso_task_quest.profilePath..gProfile..".info")
	end
end

function eso_task_quest.LoadProfile(profilePath)
	d("Loading quest profile from "..profilePath)
	local profileData = {}
	local e = nil
    if (profilePath ~= "" and file_exists(profilePath)) then
        profileData, e = persistence.load(profilePath)
        local luaPath = profilePath:sub(1,profilePath:find(".info")).."lua"
        if (file_exists(luaPath)) then
            dofile(luaPath)
        end
    end
	
	if (ValidTable(profileData)) then
		--create quest objects for each quest in the profile
		local quests = profileData.quests
		eso_task_quest.questList = {}
		if (ValidTable(quests)) then
			for id, questTable in pairs(quests) do
				local quest = eso_quest.Create()
				quest.id = id
				quest.level = questTable.level
				quest.prereq = questTable.prereq
				quest.steps = questTable.steps
				
				if(questTable.job ~= nil) then
					quest.job = questTable.job
				else
					quest.job = -1
				end
				eso_task_quest.questList[id] = quest
			end
		end
	else
		ml_error("Error reading quest profile")
		ml_error(e)
	end
end

c_nextquest = inheritsFrom( ml_cause )
e_nextquest = inheritsFrom( ml_effect )
function c_nextquest:evaluate()
	local currQuest = tonumber(Settings.ESOMinion.gCurrQuestID)

	if (currQuest ~= nil and 
		Quest:HasQuest(currQuest) and
		ValidTable(eso_task_quest.questList[currQuest]))
	then
		e_nextquest.quest = eso_task_quest.questList[currQuest]
		return true
	end

	for id, quest in pairs(eso_task_quest.questList) do
		if (quest:canStart()) then
			e_nextquest.quest = quest
			return true
		end
	end
	
	return false
end
function e_nextquest:execute()
	local quest = e_nextquest.quest
	if (ValidTable(quest)) then
		if(quest.id == 307 and gDevDebug == "1") then
			ml_task_hub.ToggleRun()
			ml_error("At quest for testing")
			return
		end
		local task = quest:CreateTask()
		ml_task_hub:CurrentTask():AddSubTask(task)
		
		eso_task_quest.currentQuest = quest
		gCurrQuestID = quest.id
		Settings.ESOMinion.gCurrQuestID = tonumber(gCurrQuestID)
	end
end

c_questaddgrind = inheritsFrom( ml_cause )
e_questaddgrind = inheritsFrom( ml_effect )
function c_questaddgrind:evaluate()
	-- we should always go grind if we can't find a quest to do
	-- might need to tweak this later?
	return true
end
function e_questaddgrind:execute()
	local grindmap = GetBestGrindMap()
	
	local newTask = eso_quest_grind.Create()
	newTask.task_complete_eval = 
		function()
			return c_nextquest:evaluate()
		end
	newTask.params["mapid"] = grindmap
	ml_task_hub:CurrentTask():AddSubTask(newTask)
	
	--clear all the quest interface data so the user knows whats happening
	gCurrQuestID = ""
	gCurrQuestObjective = ""
	gCurrQuestStep = ""
	gQuestStepType = "grind"
	gQuestKillCount = ""
end

function eso_task_quest:Init()
	--process elements
	--its tempting to add equip cnes to overwatch but there are too many states 
	--when the client does not allow gear changes
	
	--equip reward checks if we just got an item we wanted to equip for the last quest reward
	--and queues it for equip if so
	local ke_equipReward = ml_element:create( "EquipReward", c_equipreward, e_equipreward, 30 )
    self:add( ke_equipReward, self.process_elements)
	
	local ke_equip = ml_element:create( "Equip", c_equip, e_equip, 25 )
    self:add( ke_equip, self.process_elements)
	
    local ke_nextQuest = ml_element:create( "NextQuest", c_nextquest, e_nextquest, 20 )
    self:add( ke_nextQuest, self.process_elements)
	
	local ke_questAddGrind = ml_element:create( "QuestAddGrind", c_questaddgrind, e_questaddgrind, 15 )
    self:add( ke_questAddGrind, self.process_elements)
	
	--overwatch elements
	--flee has to go on individual step tasks so that we don't lose current step data
	--when it goes off
	local ke_dead = ml_element:create( "Dead", c_questdead, e_questdead, 20 )
    self:add( ke_dead, self.overwatch_elements)
	
	local ke_questIsLoading = ml_element:create( "QuestIsLoading", c_questisloading, e_questisloading, 105 )
    self:add( ke_questIsLoading, self.overwatch_elements)
	
	local ke_questInDialog = ml_element:create( "QuestInDialog", c_questindialog, e_questindialog, 105 )
    self:add( ke_questInDialog, self.overwatch_elements)
	
	self:AddTaskCheckCEs()
end

function eso_task_quest.GUIVarUpdate(Event, NewVals, OldVals)
    for k,v in pairs(NewVals) do
		if (	k == "gProfile" and gBotMode == GetString("questMode")) then
			eso_task_quest.LoadProfile(eso_task_quest.profilePath..v..".info")
			Settings.ESOMinion["gLastQuestProfile"] = v
        elseif (k == "gCurrQuestID" or
				k == "gCurrQuestStep" or
				k == "gQuestAutoEquip" )
        then
            Settings.ESOMinion[k] = v
        end
    end
    GUI_RefreshWindow(esominion.Windows.Main.Name)
end

RegisterEventHandler("GUI.Update",eso_task_quest.GUIVarUpdate)


eso_quest = inheritsFrom(nil)

function eso_quest.Create()
	local quest = inheritsFrom(eso_quest)
	
	-- this data comes from profile
	quest.id = 0
	quest.prereq = {}
	quest.steps = {}		--list of param tables for each step indexed by step number
	
	-- this static data comes from client when we start quest
	quest.numSteps = 0
	quest.numConditions = 0
	quest.name = ""
	quest.level = 0
	
	-- this dynamic data comes from client and is updated during quest
	quest.journalIndex = 0
	quest.step = 0
	quest.condition = 0
	
	return quest
end

function eso_quest:CreateTask()
	local task = eso_quest_task.Create()
	task.profileData = steps
	task.quest = self
	
	return task
end

function eso_quest:updateInfo()
	local a, b, currStepText = e("GetJournalQuestInfo("..tostring(self.journalIndex)..")")
	local 
	
	-- iterate through steps to find matching step text
	local currStepIndex = 0
	for i=1,self.numSteps do
		-- only care about first result
		local stepText = e("GetJournalQuestStepInfo("..tostring(self.journalIndex).","..tostring(i)..")")
		if(stepText == currStepText) then
			currStepIndex = i
			break
		end
	end
	
	-- iterate through conditions to find matching condition text
end

function eso_quest:canStart()
	if (self:hasBeenCompleted()) then
		return false
	end

	if(ValidTable(self.prereq)) the
		for _, questid in pairs(self.prereq) do
			if (not Quest:IsQuestCompleted(questid)) then
				return false
			end
		end
	end
	
	return Player.level >= self.level
end

function eso_quest:isStarted()
	return Quest:HasQuest(self.id)
end

--checks to see if all quest objectives have been met
function eso_quest:isComplete()
	return e("GetJournalQuestIsComplete("..tostring(self.journalIndex)..")")
end

--checks to see if quest has been previously completed
function eso_quest:hasBeenCompleted()
	return Quest:IsQuestCompleted(self.id)
end

function eso_quest:currentStepIndex()
	-- must be a better way to do this
	local name, 
	return e("GetJournalQuestIsComplete("..tostring(self.journalIndex)..")")
end

function eso_quest:currentConditionIndex()
	return Quest:GetQuestCurrentStep(self.id)
end

function eso_quest:GetStartTask()
	local task = eso_quest_start.Create()
	task.params = self.steps[1]
	
	return task
end

function eso_quest:GetCompleteTask()
	local task = eso_quest_complete.Create()
	task.params = self.steps[TableSize(self.steps)]
	
	return task
end

--returns a task for the given step index
function eso_quest:GetStepTask(stepIndex)
	local params = self.steps[stepIndex]
	local task = eso_quest.tasks[params.type]()
	task.params = params
	
	return task
end

--finds the task for the step matching the objective index and returns it
function eso_quest:GetObjectiveTask(objectiveIndex)
	return self:GetStepTask(self:GetStepIndexForObjective(objectiveIndex))
end

function eso_quest:GetNearestEntity()
	-- to be filled out later
	-- will be used to check if an objective entity for this quest is closer so we can switch to it
end

eso_quest.tasks = 
{
	["start"] 		= eso_quest_start.Create,
	["complete"] 	= eso_quest_complete.Create,
	["interact"] 	= eso_quest_interact.Create,
	["kill"]		= eso_quest_kill.Create,
	["nav"]			= eso_quest_nav.Create,
	["accept"]		= eso_quest_accept.Create,
	["dutykill"]	= eso_quest_dutykill.Create,
	["textcommand"] = eso_quest_textcommand.Create,
	["useitem"] 	= eso_quest_useitem.Create,
	["useaction"]	= eso_quest_useaction.Create,
	["vendor"]		= eso_quest_vendor.Create,
	["equip"]		= eso_quest_equip.Create,
}