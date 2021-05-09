-- Skillmanager for adv. skill customization
eso_skillmanager = {}
eso_skillmanager.version = "2.0";
eso_skillmanager.lastTick = 0
eso_skillmanager.ConditionList = {}
eso_skillmanager.CurrentSkill = {}
eso_skillmanager.CurrentSkillData = {}
eso_skillmanager.CurrentTarget = {}
eso_skillmanager.CurrentTID = 0
eso_skillmanager.profilepath = GetStartupPath() .. [[\LuaMods\ESOMinion\SkillManagerProfiles\]]
eso_skillmanager.skillbook = { name = GetString("skillbook"), x = 250, y = 50, w = 250, h = 350}
eso_skillmanager.mainwindow = { name = GetString("skillManager"), x = 350, y = 50, w = 250, h = 350}
eso_skillmanager.editwindow = { name = GetString("skillEditor"), x = 250, y = 50, w = 250, h = 550}
eso_skillmanager.confirmwindow = { name = GetString("confirm"), x = 250, y = 50, w = 250, h = 120}
eso_skillmanager.SkillBook = {}
eso_skillmanager.SkillProfile = {}
eso_skillmanager.prevSkillID = ""
eso_skillmanager.prevSkillList = {}
eso_skillmanager.copiedSkill = {}
eso_skillmanager.bestAOE = 0
eso_skillmanager.latencyTimer = 0
eso_skillmanager.resetTimer = 0

eso_skillmanager.lastAvoid = 0
eso_skillmanager.lastBreak = 0
eso_skillmanager.lastInterrupt = 0

eso_skillmanager.TIP_BLOCK = 1
eso_skillmanager.TIP_EXPLOIT = 2
eso_skillmanager.TIP_INTERRUPT = 3
eso_skillmanager.TIP_AVOID = 4
eso_skillmanager.TIP_BREAK = 18
eso_skillmanager.TIP_INTERRUPT2 = 19


eso_skillmanager.skillsbyindex = {}
eso_skillmanager.skillsbyid = {}
eso_skillmanager.skillsbyname = {}
eso_skillmanager.lastskillidcheck = 0
eso_skillmanager.lastskillindexcheck = 0
eso_skillmanager.GUI = {
	skillbook = {
		name = GetString("Skill Book"),
		visible = true,
		open = false,
		id = 0,
		height = 0, width = 350, x = 500, y = 500,
	},
	manager = {
		name = GetString("Skill Manager"),
		visible = true,
		open = false,
		height = 0, width = 0, x = 500, y = 500,
	},
	editor = {
		name = GetString("Skill Editor"),
		visible = true,
		open = false,
		height = 0, width = 350, x = 0, y = 0,
	},
	profile = {
		name = "Profile",
		visible = true,
		open = false,
	},
}

--[[
Player:RollDodge()
enum MOVEMENT_DIRECTION
{
 MOVEMENT_DIRECTION_FORWARD = 1,
 MOVEMENT_DIRECTION_BACKWARD = 2,
 MOVEMENT_DIRECTION_LEFT = 4,
 MOVEMENT_DIRECTION_RIGHT = 5,
};

Player:GetNumActiveCombatTips()
EntityList:GetFromCombatTip(tipID)

void Effect::ToLuaTable( LuaPlus::LuaState* pState , LuaPlus::LuaObject& pin ) {
	 pin.AssignNewTable(pState); 
	 pin.SetNumber("abilityid", GetAbilityId());
	 pin.SetNumber("casterid", GetCasterId());
	 pin.SetNumber("stackcount", GetStackCount());
	 pin.SetNumber("effectid1", GetEffectId1());
	 pin.SetNumber("effectid2", GetEffectId2());
	 pin.SetNumber("effectvalue",GetEffectValue());
	}

abilitylist:haseffect(somebuffid,someentityid)
abilitylist:geteffect(somebuffid,someentityid)

e("StartBlock()"), e("StopBock()"), e("PerformInterrupt()")
--]]

eso_skillmanager.slots = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
}

eso_skillmanager.StartingProfiles = {
	[1] = "DragonKnight",
	[2] = "Sorcerer",
	[3] = "Nightblade",
	[4] = "DragonKnight",
	[6] = "Templar",
}

eso_skillmanager.HeavyAttacks = {
	["1H + Shield"] = 15279,
	["Dest"] = 29365,
	["Shield"] = 60759,
	["1H"] = 14096,
	["Dual Wield 1"] = 16420,
	["Dual Wield 2"] = 18622,
	["Dual Wield 3"] = 60758,
	["Bow"] = 16691,
	["Bow 2"] = 60761,
	["2H"] = 16041,
	["2H 2"] = 60757,
	["Restoration"] = 32760,
	["Restoration 2"] = 40033,
	["Flame"] = 15383,
	["Fire"] = 60763,
	["Frost"] = 16261,
	["Frost 2"] = 60762,
	["Shock"] = 60764,
	["Were"] = 32477,
	["Were 2"] = 32480,
	["Were 3"] = 55886,
	["Werewolf"] = 55891,
	["Unarmed"] = 18429,
	["Unarmed 2"] = 60772,
}

eso_skillmanager.Variables = {
	SKM_NAME = { default = "", cast = "string", profile = "name", section = "main"},
	SKM_ALIAS = { default = "", cast = "string", profile = "alias", section = "main"},
	SKM_ID = { default = 0, cast = "number", profile = "skillID", section = "main"},
	SKM_SKILLTYPE = { default = GetString("smsktypedmg"), cast = "string", profile = "skilltype", section = "main"},
	SKM_Prio = { default = 0, cast = "number", profile = "prio", section = "main"},
	SKM_ATKRNG = { default = "0", cast = "string", profile = "atkrng", section = "main"},
	SKM_ENABLED = { default = "0", cast = "string", profile = "enabled", section = "main"},	
	
	SKM_Combat = { default = "In Combat", cast = "string", profile = "ooc", section = "fighting"  },
	SKM_CASTTIME = { default = 0, cast = "number", profile = "casttime", section = "fighting"   },
	SKM_MinR = { default = 0, cast = "number", profile = "minRange", section = "fighting"   },
	SKM_MaxR = { default = 30, cast = "number", profile = "maxRange", section = "fighting"   },
	
	SKM_PSkillID = { default = "", cast = "string", profile = "previd", section = "fighting"  },
	SKM_NPSkillID = { default = "", cast = "string", profile = "nprevid", section = "fighting"  },
	SKM_THROTTLE = { default = 0, cast = "number", profile = "throttle", section = "fighting" },  
	
	SKM_PHPGT = { default = 0, cast = "number", profile = "phpgt", section = "fighting"   },
	SKM_PHPLT = { default = 0, cast = "number", profile = "phplt", section = "fighting"   },
	SKM_POWERTYPE = { default = "Magicka", cast = "string", profile = "powertype", section = "fighting"},
	SKM_PPowGT = { default = 0, cast = "number", profile = "ppowgt", section = "fighting"   },
	SKM_PPowLT = { default = 0, cast = "number", profile = "ppowlt", section = "fighting"   },
	
	SKM_TRG = { default = "Target", cast = "string", profile = "trg", section = "fighting"  },
	SKM_THPGT = { default = 0, cast = "number", profile = "thpgt", section = "fighting"  },
	SKM_THPLT = { default = 0, cast = "number", profile = "thplt", section = "fighting"  },
	
	SKM_TECount = { default = 0, cast = "number", profile = "tecount", section = "fighting"  },
	SKM_TECount2 = { default = 0, cast = "number", profile = "tecount2", section = "fighting" },
	SKM_TERange = { default = 0, cast = "number", profile = "terange", section = "fighting"  },
	SKM_TACount = { default = 0, cast = "number", profile = "tacount", section = "fighting"  },
	SKM_TARange = { default = 0, cast = "number", profile = "tarange", section = "fighting"  },
	
	--[[ -------Skill Chains
	SKM_PSkillID = { default = "", cast = "string", profile = "pskill", section = "fighting"  },
	SKM_NPSkillID = { default = "", cast = "string", profile = "npskill", section = "fighting"  },
	SKM_PCSkillID = { default = "", cast = "string", profile = "pcskill", section = "fighting"  },
	SKM_NPCSkillID = { default = "", cast = "string", profile = "npcskill", section = "fighting"  },
	SKM_NSkillID = { default = "", cast = "string", profile = "nskill", section = "fighting"  },
	SKM_NSkillPrio = { default = "", cast = "string", profile = "nskillprio", section = "fighting"  },
	--]]

	--SKM_OnlySolo = { default = "0", cast = "string", profile = "onlysolo", section = "fighting"  },
	--SKM_OnlyParty = { default = "0", cast = "string", profile = "onlyparty", section = "fighting"  },
	
	--[[ -------Dynamic Filters
	SKM_FilterOne = { default = "Ignore", cast = "string", profile = "filterone", section = "fighting"  },
	SKM_FilterTwo = { default = "Ignore", cast = "string", profile = "filtertwo", section = "fighting"  },
	SKM_FilterThree = { default = "Ignore", cast = "string", profile = "filterthree", section = "fighting"  },
	SKM_FilterFour = { default = "Ignore", cast = "string", profile = "filterfour", section = "fighting"  },
	SKM_FilterFive = { default = "Ignore", cast = "string", profile = "filterfive", section = "fighting"  },
	--]]
	
	--[[ -------Target Info
	SKM_TRGTYPE = { default = "Any", cast = "string", profile = "trgtype", section = "fighting"  },
	SKM_NPC = { default = "0", cast = "string", profile = "npc", section = "fighting"  },
	SKM_PTRG = { default = "Any", cast = "string", profile = "ptrg", section = "fighting" },
	SKM_PGTRG = { default = "Direct", cast = "string", profile = "pgtrg", section = "fighting"  },
	SKM_THPADV = { default = 0, cast = "number", profile = "thpadv", section = "fighting"  },
	--]]
	
	--[[ -------Party
	SKM_HPRIOHP = { default = 0, cast = "number", profile = "hpriohp", section = "fighting"  },
	SKM_HPRIO1 = { default = "None", cast = "string", profile = "hprio1", section = "fighting"  },
	SKM_HPRIO2 = { default = "None", cast = "string", profile = "hprio2", section = "fighting"  },
	SKM_HPRIO3 = { default = "None", cast = "string", profile = "hprio3", section = "fighting"  },
	SKM_HPRIO4 = { default = "None", cast = "string", profile = "hprio4", section = "fighting"  },
	--]]
	
	--[[ -------Party
	SKM_PTCount = { default = 0, cast = "number", profile = "ptcount", section = "fighting"   },
	SKM_PTHPL = { default = 0, cast = "number", profile = "pthpl", section = "fighting"   },
	SKM_PTHPB = { default = 0, cast = "number", profile = "pthpb", section = "fighting"   },
	SKM_PTMPL = { default = 0, cast = "number", profile = "ptmpl", section = "fighting"   },
	SKM_PTMPB = { default = 0, cast = "number", profile = "ptmpb", section = "fighting"   },
	SKM_PTTPL = { default = 0, cast = "number", profile = "pttpl", section = "fighting"   },
	SKM_PTTPB = { default = 0, cast = "number", profile = "pttpb", section = "fighting"   },
	SKM_PTBuff = { default = "", cast = "string", profile = "ptbuff", section = "fighting"  },
	SKM_PTNBuff = { default = "", cast = "string", profile = "ptnbuff", section = "fighting"  },
	--]]
	
	--[[ ------- Target Casting
	SKM_TCASTID = { default = "", cast = "string", profile = "tcastids", section = "fighting"  },
	SKM_TCASTTM = { default = "0", cast = "string", profile = "tcastonme", section = "fighting"  },
	SKM_TCASTTIME = { default = "0.0", cast = "string", profile = "tcasttime", section = "fighting"  },
	--]]
	
	SKM_PBuffThis = { default = "", cast = "string", profile = "pbuffthis", section = "fighting"  },
	SKM_PBuff = { default = "", cast = "string", profile = "pbuff", section = "fighting"  },
	SKM_PNBuffThis = { default = "", cast = "string", profile = "pnbuffthis", section = "fighting"  },
	SKM_PNBuff = { default = "", cast = "string", profile = "pnbuff", section = "fighting"  },
	
	--[[ ------- Player Buffs
	SKM_PBuffDura = { default = 0, cast = "number", profile = "pbuffdura", section = "fighting" },
	SKM_PNBuffDura = { default = 0, cast = "number", profile = "pnbuffdura", section = "fighting"   },
	--]]
	
	SKM_TBuffThis = { default = "", cast = "string", profile = "tbuffthis", section = "fighting"  },
	SKM_TBuff = { default = "", cast = "string", profile = "tbuff", section = "fighting"  },
	SKM_TNBuffThis = { default = "", cast = "string", profile = "tnbuffthis", section = "fighting"  },
	SKM_TNBuff = { default = "", cast = "string", profile = "tnbuff", section = "fighting"  },
	
	--[[ ------- Target Buffs
	SKM_TBuffOwner = { default = "Player", cast = "string", profile = "tbuffowner", section = "fighting"  },
	SKM_TNBuffDura = { default = 0, cast = "number", profile = "tnbuffdura", section = "fighting"   },
	--]]
	
	--SKM_PPos = { default = "None", cast = "string", profile = "ppos", section = "fighting"  },
	
	--[[ ------- Other Skill Checks
	SKM_SKREADY = { default = "", cast = "string", profile = "skready", section = "fighting" },
	SKM_SKOFFCD = { default = "", cast = "string", profile = "skoffcd", section = "fighting" },
	SKM_SKNREADY = { default = "", cast = "string", profile = "sknready", section = "fighting" },
	SKM_SKNOFFCD = { default = "", cast = "string", profile = "sknoffcd", section = "fighting" },
	SKM_SKNCDTIMEMIN = { default = "", cast = "string", profile = "skncdtimemin", section = "fighting" },
	SKM_SKNCDTIMEMAX = { default = "", cast = "string", profile = "skncdtimemax", section = "fighting" },
	SKM_SKTYPE = { default = "Action", cast = "string", profile = "sktype", section = "fighting"},
	SKM_NCURRENTACTION = { default = "", cast = "string", profile = "ncurrentaction", section = "fighting" },
	--]]
}

function eso_skillmanager.ModuleInit() 	
    if (Settings.ESOMinion.gSMlastprofile == nil) then
        Settings.ESOMinion.gSMlastprofile = "None"
    end
	if (Settings.ESOMinion.SMDefaultProfiles == nil) then
		Settings.ESOMinion.SMDefaultProfiles = {}
	end	
	if (Settings.ESOMinion.SMDefaultProfiles[1] == nil) then
		Settings.ESOMinion.SMDefaultProfiles[1] = "DragonKnight"
	end
	if (Settings.ESOMinion.SMDefaultProfiles[2] == nil) then
		Settings.ESOMinion.SMDefaultProfiles[2] = "Sorcerer"
	end
	if (Settings.ESOMinion.SMDefaultProfiles[3] == nil) then
		Settings.ESOMinion.SMDefaultProfiles[3] = "Nightblade"
	end
	if (Settings.ESOMinion.SMDefaultProfiles[4] == nil) then
		Settings.ESOMinion.SMDefaultProfiles[4] = "DragonKnight"
	end
	if (Settings.ESOMinion.SMDefaultProfiles[6] == nil) then
		Settings.ESOMinion.SMDefaultProfiles[6] = "Templar"
	end
	
	eso_skillmanager.UseDefaultProfile()
	eso_skillmanager.AddDefaultConditions()
end

function eso_skillmanager.GUIVarUpdate(Event, NewVals, OldVals)
    for k,v in pairs(NewVals) do
        if ( k == "gSMprofile" ) then
            gSMactive = "1"					
			
            --GUI_WindowVisible(eso_skillmanager.editwindow.name,false)		
            --GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
            eso_skillmanager.UpdateCurrentProfileData()
			Settings.ESOMinion["gSMlastprofile"] = v
			eso_skillmanager.SetDefaultProfile()
		end
		
		if (eso_skillmanager.Variables[tostring(k)] ~= nil and tonumber(SKM_Prio) ~= nil and SKM_Prio > 0) then	
			if (v == "?") then
				d("Question mark was typed.")
			end
			if (v == nil) then
				eso_skillmanager.SkillProfile[SKM_Prio][eso_skillmanager.Variables[tostring(k)].profile] = eso_skillmanager.Variables[tostring(k)].default
			elseif (eso_skillmanager.Variables[k].cast == "string") then
				eso_skillmanager.SkillProfile[SKM_Prio][eso_skillmanager.Variables[tostring(k)].profile] = v
			elseif (eso_skillmanager.Variables[k].cast == "number") then
				eso_skillmanager.SkillProfile[SKM_Prio][eso_skillmanager.Variables[tostring(k)].profile] = tonumber(v)
			end
		end
    end
end

function eso_skillmanager.OnUpdate( event, tickcount )
	if ((tickcount - eso_skillmanager.lastTick) > 100) then
		eso_skillmanager.lastTick = tickcount
		
		if (eso_skillmanager.resetTimer ~= 0 and Now() > eso_skillmanager.resetTimer) then
			eso_skillmanager.prevSkillID = ""
			eso_skillmanager.resetTimer = 0
		end
	end
end

--This is the only function that should actually read from the file.
function eso_skillmanager.ReadFile(strFile)
	assert(type(strFile) == "string" and strFile ~= "", "[eso_skillmanager.ReadFile]: File target is not valid")
	local filename = eso_skillmanager.profilepath..strFile..".lua"
	--Attempt to read old files and convert them.
	local profile = fileread(filename)
	if (profile) then
		local version = nil
		for i,line in pairsByKeys(profile) do
			local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
			if ( tostring(key) == "SMVersion" and tostring(id) == "1") then
				version = 1
			end
			if (version == 1) then
				break
			end
		end
		if (version == 1) then
			local newskill = {}
			local sortedSkillList = {}
			for i,line in pairsByKeys(profile) do
				local _, key, value = string.match(line, "(%w+)_(%w+)=(.*)")
				if ( key and value ) then
					value = string.gsub(value, "\r", "")					
					if ( key == "END" ) then
						for k,v in pairs(eso_skillmanager.Variables) do
							if (v.section == "fighting") then
								newskill[v.profile] = newskill[v.profile] or v.default
							end
						end
						
						-- try to update the names 
						--[[
						local found = false
						for i, actiontype in pairsByKeys(eso_skillmanager.ActionTypes) do
							local AbilityList = AbilityList("type="..tostring(actiontype))
							for k, action in pairs(AbilityList) do
								if (action.id == newskill.id and action.name and action.name ~= "") then
									newskill.name = action.name
									found = true
									break
								end
							end
							if (found) then
								break
							end
						end
						--]]
						
						sortedSkillList = TableInsertSort(sortedSkillList,tonumber(newskill.prio),newskill)
						newskill = {}
					elseif (eso_skillmanager.Variables["SKM_"..key] ~= nil) then
						local t = eso_skillmanager.Variables["SKM_"..key]
						if (t ~= nil) then
							if (t.cast == "number") then
								newskill[t.profile] = tonumber(value)
							elseif (t.cast == "string") then
								newskill[t.profile] = tostring(value)
							end
						end
					end
				end
			end
			if ( TableSize(sortedSkillList) > 0 ) then
				local reorder = 1
				for k,v in pairsByKeys(sortedSkillList) do
					v.prio = reorder
					eso_skillmanager.SkillProfile[reorder] = v
					reorder = reorder + 1
				end
			end
			--Overwrite the old file with the new file type.
			eso_skillmanager.WriteToFile(strFile)
		end
	end	
	--Load the file, which should only be the new type.
	local profile, e = persistence.load(filename)
	if (ValidTable(profile)) then
		eso_skillmanager.SkillProfile = profile.skills
	end
	eso_skillmanager.ResetSkillTracking()
	eso_skillmanager.CheckProfileValidity()
end

--All writes to the profiles should come through this function.
function eso_skillmanager.WriteToFile(strFile)
	assert(strFile and type(strFile) == "string" and strFile ~= "", "[eso_skillmanager.WriteToFile]: File target is not valid.")
	assert(string.find(strFile,"\\") == nil, "[eso_skillmanager.WriteToFile]: File contains illegal characters.")
	
	local filename = eso_skillmanager.profilepath ..strFile..".lua"
	
	local info = {}
	info.version = 2
	eso_skillmanager.ResetSkillTracking()
	info.skills = eso_skillmanager.SkillProfile or {}	
	persistence.store(filename,info)
end

function eso_skillmanager.SetGUIVar(strName, value)
	if (eso_skillmanager.Variables[strName] ~= nil and SKM_Prio ~= nil and SKM_Prio > 0) then	
		skillVar = eso_skillmanager.Variables[strName]
		if (value == nil) then
			eso_skillmanager.SkillProfile[SKM_Prio][skillVar.profile] = skillVar.default
		elseif (skillVar.cast == "string") then
			eso_skillmanager.SkillProfile[SKM_Prio][skillVar.profile] = value
		elseif (skillVar.cast == "number") then
			eso_skillmanager.SkillProfile[SKM_Prio][skillVar.profile] = tonumber(value)
		end
	end
end

function eso_skillmanager.CheckProfileValidity()
	local profile = eso_skillmanager.SkillProfile
	
	local requiredUpdate = false
	if (ValidTable(profile)) then
		for prio,skill in pairsByKeys(profile) do
			if (tonumber(skill.prio) ~= tonumber(prio)) then
				skill.prio = tonumber(prio)
				requiredUpdate = true
			end
			
			for k,v in pairs(eso_skillmanager.Variables) do
				if (v.section == "fighting") then
					if (skill[v.profile] == nil) then
						skill[v.profile] = v.default
						requiredUpdate = true
					end
				end
			end
			
			--Second pass, make sure they are the correct types.
			for k,v in pairs(eso_skillmanager.Variables) do
				if (skill[v.profile] ~= nil) then
					if (type(skill[v.profile]) ~= v.cast) then
						if (v.cast == "number") then
							skill[v.profile] = tonumber(skill[v.profile])
						elseif (v.cast == "string") then
							skill[v.profile] = tonumber(skill[v.profile])
						end
					end
				end
			end
		end
	end
	
	if (not deepcompare(eso_skillmanager.SkillProfile,profile,true)) then
		eso_skillmanager.SkillProfile = profile
	end
	
	if (requiredUpdate) then
		eso_skillmanager.SaveProfile()
	end
end

function eso_skillmanager.UseProfile(strName)
	gSMprofile = strName
    gSMactive = "1"					
	--GUI_WindowVisible(eso_skillmanager.editwindow.name,false)		
	--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
	eso_skillmanager.UpdateCurrentProfileData()
	Settings.ESOMinion.gSMlastprofile = strName
end

function eso_skillmanager.ButtonHandler(event, Button)
    gSMRecactive = "0"
	if (event == "GUI.Item" and (string.find(Button,"SKM") ~= nil or string.find(Button,"SM") ~= nil )) then
	
		if (string.find(Button,"SMDeleteEvent") ~= nil) then
			-- Delete the currently selected Profile - file from the HDD
			if (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
				d("Deleting current Profile: "..gSMprofile)
				os.remove(eso_skillmanager.profilepath ..gSMprofile..".lua")	
				eso_skillmanager.UpdateProfiles()	
			end
		end
		
		if (string.find(Button,"SMRefreshSkillbookEvent") ~= nil) then
			eso_skillmanager.SkillBook = {}
			--GUI_DeleteGroup(eso_skillmanager.skillbook.name,"AvailableSkills")
			--GUI_DeleteGroup(eso_skillmanager.skillbook.name,"MiscSkills")	
			eso_skillmanager.RefreshSkillBook()		
		end
        
		if (string.find(Button,"SMEDeleteEvent") ~= nil) then
			if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then
				--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
				eso_skillmanager.SkillProfile = TableRemoveSort(eso_skillmanager.SkillProfile,tonumber(SKM_Prio))

				eso_skillmanager.RefreshSkillList()	
				--GUI_WindowVisible(eso_skillmanager.editwindow.name,false)
			end
		end

		if (string.find(Button,"SMESkillUPEvent") ~= nil) then
			if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then
				if ( SKM_Prio > 1) then
					--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
					local tmp = eso_skillmanager.SkillProfile[SKM_Prio-1]
					eso_skillmanager.SkillProfile[SKM_Prio-1] = eso_skillmanager.SkillProfile[SKM_Prio]
					eso_skillmanager.SkillProfile[SKM_Prio-1].prio = eso_skillmanager.SkillProfile[SKM_Prio-1].prio - 1
					eso_skillmanager.SkillProfile[SKM_Prio] = tmp
					eso_skillmanager.SkillProfile[SKM_Prio].prio = eso_skillmanager.SkillProfile[SKM_Prio].prio + 1
					SKM_Prio = SKM_Prio-1
					eso_skillmanager.RefreshSkillList()				
				end
			end
		end
	
		if (string.find(Button,"SMESkillDOWNEvent") ~= nil) then
			if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then
				if ( SKM_Prio < TableSize(eso_skillmanager.SkillProfile)) then
					--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")		
					local tmp = eso_skillmanager.SkillProfile[SKM_Prio+1]
					eso_skillmanager.SkillProfile[SKM_Prio+1] = eso_skillmanager.SkillProfile[SKM_Prio]
					eso_skillmanager.SkillProfile[SKM_Prio+1].prio = eso_skillmanager.SkillProfile[SKM_Prio+1].prio + 1
					eso_skillmanager.SkillProfile[SKM_Prio] = tmp
					eso_skillmanager.SkillProfile[SKM_Prio].prio = eso_skillmanager.SkillProfile[SKM_Prio].prio - 1
					SKM_Prio = SKM_Prio+1
					eso_skillmanager.RefreshSkillList()						
				end
			end
		end
	
		if (string.find(Button,"SKMEditSkill") ~= nil) then
			local key = Button:gsub("SKMEditSkill", "")
			eso_skillmanager.EditSkill(key)
		end
		if (string.find(Button,"SKMClearProfile") ~= nil) then
			local key = Button:gsub("SKMClearProfile", "")
			eso_skillmanager.ClearProfile(key)
		end
		if (string.find(Button,"SKMAddSkill") ~= nil) then
			local key = Button:gsub("SKMAddSkill", "")
			eso_skillmanager.AddSkillToProfile(key)
		end
		if (string.find(Button,"SKMCopySkill") ~= nil) then
			eso_skillmanager.CopySkill()
		end
		if (string.find(Button,"SKMPasteSkill") ~= nil) then
			eso_skillmanager.PasteSkill()
		end
	end
end

function eso_skillmanager.NewProfile()
    if ( gSMnewname and gSMnewname ~= "" ) then
		gSMprofile_listitems = gSMprofile_listitems..","..gSMnewname
        gSMprofile = gSMnewname
        gSMnewname = ""
		
		--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
		eso_skillmanager.SkillProfile = {}
		eso_skillmanager.WriteToFile(gSMprofile)
	else
		d("New profile name is invalid, couldn't create new profile.")
    end
end

function eso_skillmanager.ClearProfilePrompt()
	local wnd = GUI_GetWindowInfo(eso_skillmanager.mainwindow.name)
	--GUI_MoveWindow(eso_skillmanager.confirmwindow.name, wnd.x,wnd.y+wnd.height) 
	----GUI_SizeWindow(eso_skillmanager.confirmwindow.name,wnd.width,eso_skillmanager.confirmwindow.h)
	--GUI_WindowVisible(eso_skillmanager.confirmwindow.name,true)
end

function eso_skillmanager.ClearProfile(arg)
	if (arg == "Yes") then
		--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
		eso_skillmanager.SkillProfile = {}
		eso_skillmanager.WriteToFile(gSMprofile)
	end
	--GUI_WindowVisible(eso_skillmanager.confirmwindow.name,false)
end

function eso_skillmanager.SaveProfile()
    local filename = ""
	
    --If a new name is filled out, copy the profile rather than save it.
    if ( gSMnewname ~= "" and gSMnewname ~= nil ) then
        filename = gSMnewname
        gSMnewname = ""

		gSMprofile_listitems = gSMprofile_listitems..","..filename
		gSMprofile = filename
		Settings.ESOMinion.gSMlastprofile = filename
		
		eso_skillmanager.WriteToFile(filename)
    elseif (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
        filename = gSMprofile
        gSMnewname = ""		
		
		eso_skillmanager.WriteToFile(filename)
    end
end

function eso_skillmanager.SetDefaultProfile(strName)
	local profile = strName or gSMprofile
	local classid = e("GetUnitClassId(player)")
	Settings.ESOMinion.SMDefaultProfiles[classid] = profile
	Settings.ESOMinion.SMDefaultProfiles = Settings.ESOMinion.SMDefaultProfiles
end

function eso_skillmanager.UseDefaultProfile()
	local defaultTable = Settings.ESOMinion.SMDefaultProfiles
	local default = nil
	local profile = nil
	local profileFound = false
	local classid = e("GetUnitClassId(player)")
	
	--Try default profile first.
	if (ValidTable(defaultTable)) then
		default = defaultTable[classid]
		if (default) then
			if (FileExists(eso_skillmanager.profilepath..default..".lua")) then
				profileFound = true
			end
		end
	end
	
	if (not profileFound) then
		local starterDefault = eso_skillmanager.StartingProfiles[classid]
		if ( starterDefault ) then
			local starterDefault = eso_skillmanager.profilepath..starterDefault..".lua"
			if (FileExists(starterDefault)) then
				d("No default profile set, using start default ["..tostring(starterDefault).."]")
				eso_skillmanager.SetDefaultProfile(starterDefault)
				default = starterDefault
				profileFound = true
			end
		end
	end
	
	gSMprofile = profileFound and default or "None"
	--GUI_WindowVisible(eso_skillmanager.editwindow.name,false)	
	--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
	eso_skillmanager.UpdateCurrentProfileData()
	
	--GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
end

--Grasb all Profiles and enlist them in the dropdown field
function eso_skillmanager.UpdateProfiles()
    
    local profiles = "None"
    local found = "None"	
    local profilelist = dirlist(eso_skillmanager.profilepath,".*lua")
    if ( TableSize(profilelist) > 0) then			
        local i,profile = next ( profilelist)
        while i and profile do				
            profile = string.gsub(profile, ".lua", "")
            profiles = profiles..","..profile
            if ( Settings.ESOMinion.gSMlastprofile ~= nil and Settings.ESOMinion.gSMlastprofile == profile ) then
                found = profile
            end
            i,profile = next ( profilelist,i)
        end		
    else
        d("No Skillmanager profiles found")
    end
	
    gSMprofile_listitems = profiles
    gSMprofile = found
	
	return profiles
end

function eso_skillmanager.CopySkill()
	d("COPYING SKILL #:"..tostring(SKM_Prio))
	local source = eso_skillmanager.SkillProfile[tonumber(SKM_Prio)]
	eso_skillmanager.copiedSkill = {}
	local temp = {}
	for k,v in pairs(eso_skillmanager.Variables) do
		if (v.section ~= "main") then
			temp[k] = _G[tostring(k)]
		end
	end
	eso_skillmanager.copiedSkill = temp
end

function eso_skillmanager.PasteSkill()
	d("PASTING INTO SKILL #:"..tostring(SKM_Prio))
	local source = eso_skillmanager.copiedSkill
	for k,v in pairs(eso_skillmanager.copiedSkill) do
		_G[tostring(k)] = v
		eso_skillmanager.SetGUIVar(tostring(k),v)
	end
end

function eso_skillmanager.UpdateCurrentProfileData()
	local profile = gSMprofile
	if (profile and profile ~= "") then
		--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
		eso_skillmanager.SkillProfile = {}
		eso_skillmanager.ReadFile(profile)
		eso_skillmanager.RefreshSkillList()
		----GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
		--GUI_RefreshWindow(eso_skillmanager.mainwindow.name)
	end
end
function eso_skillmanager.BuildSkillsList()

	for i = 1,33 do
		local skillid = e("GetAbilityIdByIndex("..i..")")
		local skillName, skillTexture, skillRank, skillSlotType, skillpassive, skillVisable = e("GetAbilityInfoByIndex("..i..")")
		local skillRangemin, skillRangemax = e("GetAbilityRange("..skillid..")")
		local skillRange = skillRangemax / 100
		local skillChanneled, skillCastTime, skillChannelTime = e("GetAbilityCastInfo("..skillid..")")
		eso_skillmanager.skillsbyindex[i] = {id = skillid, index = i ,name = skillName, rank = skillRank, type = skillSlotType, passive = skillpassive, visable = skillVisable, range = skillRange, ischanneled = skillChanneled, casttime = skillChannelTime, channeltime = skillChannelTime}
		eso_skillmanager.skillsbyid[skillid] = {id = skillid, index = i ,name = skillName, rank = skillRank, type = skillSlotType, passive = skillpassive, visable = skillVisable, range = skillRange, ischanneled = skillChanneled, casttime = skillChannelTime, channeltime = skillChannelTime}
		eso_skillmanager.skillsbyname[skillName] = {id = skillid, index = i ,name = skillName, rank = skillRank, type = skillSlotType, passive = skillpassive, visable = skillVisable, range = skillRange, ischanneled = skillChanneled, casttime = skillChannelTime, channeltime = skillChannelTime}
		
		if skillName == "Light Attack" then
			eso_skillmanager.lastskillidcheck = skillid
			eso_skillmanager.lastskillindexcheck = i
		end
		ml_global_information.AttackRange = math.max(skillRange,ml_global_information.AttackRange)
	end
	return eso_skillmanager.skillsbyindex
end
--+Rebuilds the UI Entries for the SkillbookList
function eso_skillmanager.RefreshSkillBook()
    local SkillList = eso_skillmanager.BuildSkillsList()
    if ( ValidTable( SkillList ) ) then
		for i,skill in spairs(SkillList, function( skill,a,b ) return skill[a].name < skill[b].name end) do
			eso_skillmanager.CreateNewSkillBookEntry(skill.id)
		end
    end

    GUI_UnFoldGroup(eso_skillmanager.skillbook.name,"AvailableSkills")
end

function eso_skillmanager.CreateNewSkillBookEntry(id)
	local action = eso_skillmanager.skillsbyid[id]
	if (ValidTable(action)) then
		local skName = action.name
		local skID = tostring(action.id)	 
		
		GUI_NewButton(eso_skillmanager.skillbook.name, skName.." ["..skID.."]", "SKMAddSkill"..skID, "AvailableSkills")
		
		eso_skillmanager.SkillBook[action.id] = {["skillID"] = action.id, ["name"] = action.name}	
	else
		ml_error("Action ID:"..tostring(id).." is not valid and could not be retrieved.")
	end
end

-- Button Handler for Skillbook-skill-buttons
function eso_skillmanager.AddSkillToProfile(event)
	local skillid = tonumber(event)
    if (table.valid(eso_skillmanager.skillsbyid[skillid])) then
        eso_skillmanager.CreateNewSkillEntry(eso_skillmanager.skillsbyid[skillid])
    end
end


--+Rebuilds the UI Entries for the Profile-SkillList
function eso_skillmanager.RefreshSkillList()
	--GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
    if ( TableSize( eso_skillmanager.SkillProfile ) > 0 ) then
		for prio,skill in pairsByKeys(eso_skillmanager.SkillProfile) do
			--local realID = tonumber(skill.skillID)
			local realID = eso_skillmanager.GetRealSkillID(skill.skillID)
				
			--local clientSkill = AbilityList:Get(realID)
			local clientSkill = eso_skillmanager.skillsbyid[realID]
			local skillFound = ValidTable(clientSkill)
			local skillName = (clientSkill and clientSkill.name) or skill.name
			local viewString = ""
			if (not IsNullString(skill.alias)) then
				viewString = tostring(prio)..": "..skill.alias.."["..tostring(realID).."]"
			else
				viewString = tostring(prio)..": "..skillName.."["..tostring(realID).."]"
			end
			if (not skillFound) then
				viewString = "***"..viewString.."***"
			end
			--GUI_NewButton(eso_skillmanager.mainwindow.name, viewString, "SKMEditSkill"..tostring(prio),"ProfileSkills")
		end
		--GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
    end
end

function eso_skillmanager.ResetSkillTracking()
	local skills = eso_skillmanager.SkillProfile
	if (ValidTable(skills)) then
		for prio,skill in pairs(skills) do
			skill.timelastused = 0
		end
	end
end

function eso_skillmanager.CreateNewSkillEntry(skill)
	assert(type(skill) == "table", "CreateNewSkillEntry was called with a non-table value.")
	
	if (not skill.name or not skill.id) then
		return false
	end
	
	local skname = skill.name
	local skID = tonumber(skill.id)
	
	local newskillprio = TableSize(eso_skillmanager.SkillProfile)+1
	local bevent = tostring(newskillprio)

	eso_skillmanager.SkillProfile[newskillprio] = {	["skillID"] = skID, ["prio"] = newskillprio, ["name"] = skname, ["enabled"] = "1", ["alias"] = ""}
	for k,v in pairs(eso_skillmanager.Variables) do
		if (v.section == "fighting") then
			eso_skillmanager.SkillProfile[newskillprio][v.profile] = skill[v.profile] or v.default
		end
	end	
	eso_skillmanager.RefreshSkillList()
end	

--+	Button Handler for ProfileList Skills
function eso_skillmanager.EditSkill(event)
    --local wnd = GUI_GetWindowInfo(eso_skillmanager.mainwindow.name)		
	
	-- Normal Editor 
	--GUI_MoveWindow( eso_skillmanager.editwindow.name, wnd.x+wnd.width,wnd.y) 
	--GUI_WindowVisible(eso_skillmanager.editwindow.name,true)
	-- Update EditorData
	local skill = eso_skillmanager.SkillProfile[tonumber(event)]	
	if ( skill ) then		
		for k,v in pairs(eso_skillmanager.Variables) do
			if (v.section == "main") then
				_G[k] = skill[v.profile] or v.default
			end
		end
		for k,v in pairs(eso_skillmanager.Variables) do
			if (v.section == "fighting") then
				_G[k] = skill[v.profile] or v.default
			end
		end
	end
	
	SKM_Prio = tonumber(event)
end

function eso_skillmanager.ToggleMenu()
    if (eso_skillmanager.visible) then
       -- GUI_WindowVisible(eso_skillmanager.mainwindow.name,false)	
       -- GUI_WindowVisible(eso_skillmanager.skillbook.name,false)	
      --  GUI_WindowVisible(eso_skillmanager.editwindow.name,false)	
		--GUI_WindowVisible(eso_skillmanager.confirmwindow.name,false)
        eso_skillmanager.visible = false
    else
		eso_skillmanager.RefreshSkillList()
		----GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
      --  GUI_WindowVisible(eso_skillmanager.skillbook.name,true)
     --   GUI_WindowVisible(eso_skillmanager.mainwindow.name,true)	
        eso_skillmanager.visible = true
    end
end

function eso_skillmanager.GetAttackRange()
	local maxrange = 5 -- 5 is the melee sword attack range
	if ( Player ) then	
		if ( gAttackRange == GetString("aRange")) then
			maxrange = 28
		elseif ( gAttackRange == GetString("aAutomatic")) then
		
			local lightAttack = e("GetSlotBoundId(1)")
			--local heavyAttack = e("GetSlotBoundId(1)")
			
			if (lightAttack > 0) then
				local ability = eso_skillmanager.skillsbyid[lightAttack]
				if (ValidTable(ability)) then
					if ability.range > 0 then
						maxrange = ability.range
					end
				end
			else
				d("Could not find the ability ID for light attack.")
			end
			
			--[[
			-- Check if we have a target to check our skills against
			target = Player:GetTarget()
			if ( not target ) then
				target = Player
			end
			
			if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then				
				for k,v in pairs(eso_skillmanager.SkillProfile) do					
					-- Get Max Attack Range for global use
					if (v.atkrng == "1" and v.trg == "Target") then
						local skillid = eso_skillmanager.GetRealSkillID(v.skillID)
						if (AbilityList:IsTargetInRange(skillid,target.id) and AbilityList:CanCast(skillid,target.id) == 10) then
							if ( v.maxRange > maxrange) then
								maxrange = v.maxRange
							end	
						end
					end				
				end
			end
			--]]
		end
	end
	return maxrange
end

function eso_skillmanager.Cast( entity )
d("start cast check")
	if (not entity) then
		return false
	end
	if (Now() < eso_skillmanager.latencyTimer) then
		return false
	end
	
	--Check for blocks/interrupts.
	--[=[if (Player:GetNumActiveCombatTips() > 0) then
		
		local isAssistMode = (gBotMode == GetString("assistMode"))
		
		local blockable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_BLOCK)
		if (ValidTable(blockable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoBlock == "1")) then
				d("Attempting block.")
				e("StartBlock()")
				local newTask = eso_task_block.Create()
				ml_task_hub:CurrentTask():AddSubTask(newTask)
				return true
			end
		end
		
		--[[local exploitable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_EXPLOIT)
		if (ValidTable(exploitable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoExploit == "1")) then
				local heavyAttacks = eso_skillmanager.HeavyAttacks
				for name,id in pairs(heavyAttacks) do
					if (AbilityList:IsTargetInRange(id,exploitable.id) and AbilityList:CanCast(id,exploitable.id) == 10) then
						AbilityList:Cast(id,exploitable.id)
						eso_skillmanager.latencyTimer = Now() + 600
						d("Attempting to exploit enemy with skill ID :"..tostring(id))
						return true
					end
				end
			end
		end]]
		
		local interruptable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_INTERRUPT)
		if (ValidTable(interruptable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoInterrupt == "1")) then
				if (TimeSince(eso_skillmanager.lastInterrupt) > 1000) then
					e("PerformInterrupt()")
					eso_skillmanager.latencyTimer = Now() + 300
					eso_skillmanager.lastBreak = Now()
					d("Attempting to interrupt enemy.")
					return true
				end
			end
		end
		
		local interruptable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_INTERRUPT2)
		if (ValidTable(interruptable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoInterrupt == "1")) then
				if (TimeSince(eso_skillmanager.lastInterrupt) > 1000) then
					e("PerformInterrupt()")
					eso_skillmanager.latencyTimer = Now() + 300
					eso_skillmanager.lastBreak = Now()
					d("Attempting to interrupt enemy attack.")
					return true
				end
			end
		end
		
		local breakable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_BREAK)
		if (ValidTable(breakable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoBreak == "1")) then
				if (TimeSince(eso_skillmanager.lastBreak) > 1000) then
					local validRolls = GetValidRollDirections()
					if (validRolls) then
						local direction = GetRandomEntry(validRolls)
						Player:RollDodge(direction)
						eso_skillmanager.latencyTimer = Now() + 300
						eso_skillmanager.lastBreak = Now()
						d("Attempting to break CC.")
						return true
					end
				end
			end
		end
		
		local avoidable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_AVOID)
		if (ValidTable(avoidable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoAvoid == "1")) then
				if (TimeSince(eso_skillmanager.lastAvoid) > 2000) then
					if (ml_global_information.Player_Stamina.percent > 50) then
						local validRolls = GetValidRollDirections()
						if (validRolls) then
							local direction = GetRandomEntry(validRolls)
							Player:RollDodge(direction)
							eso_skillmanager.latencyTimer = Now() + 300
							eso_skillmanager.lastBreak = Now()
							d("Attempting to break CC.")
							return true
						end
					end
				end
			end
		end
	end]=]
	
	if (ValidTable(eso_skillmanager.SkillProfile)) then
		for prio,skill in pairsByKeys(eso_skillmanager.SkillProfile) do
			local result = eso_skillmanager.CanCast(prio, entity)
			if (result ~= 0) then
				local TID = result
				--local realID = tonumber(skill.skillID)
				local realID = eso_skillmanager.GetRealSkillID(skill.skillID)
				--local action = AbilityList:Get(realID)
				d("Attempting to cast ability ID : "..tostring(realID))
				if (AbilityList:Cast(realID,TID)) then
					skill.timelastused = Now() + 2000
					eso_skillmanager.prevSkillID = realID
					eso_skillmanager.resetTimer = Now() + 4000
					
					local casttime = 0
					if ( casttime > 0 ) then							
						eso_skillmanager.latencyTimer = Now() + casttime
					else
						eso_skillmanager.latencyTimer = Now() + 300
					end
					return true
				end
			end
		end
	end
end

--[[
function eso_skillmanager.Use( actionid, targetid, actiontype )
	actiontype = actiontype or 1
	local tid = targetid or Player.id
	
	if (AbilityList:CanCast(actionid, tonumber(tid))) then
		local action = AbilityList:Get(actionid)
		if (action) then
			action:Cast(tid)
		end
	end
end
--]]

function eso_skillmanager.DebugOutput( prio, message )
	local prio = tonumber(prio) or 0
	local message = tostring(message)
	
	if (gSkillManagerDebug == "1") then
		if (not gSkillManagerDebugPriorities or gSkillManagerDebugPriorities == "") then
			d("[SkillManager] : " .. message)
		else
			local priorityChecks = {}
			for priority in StringSplit(gSkillManagerDebugPriorities,",") do
				priorityChecks[tonumber(priority)] = true
			end
			if (priorityChecks[prio]) then
				d("[SkillManager] : " .. message)
			end
		end
	end
end

-- Need to return a table containing the target, the cast TID, and the buffs table for the target.
--[[
function eso_skillmanager.GetSkillTarget(skill, entity, maxrange)
	if (not skill or not entity) then
		return nil
	end
	
	local PID = Player.id
	local pet = Player.pet
	local target = entity
	local TID = entity.id
	local maxrange = tonumber(maxrange) or 0
	
	local targetTable = {}
	
	local skillid = tonumber(skill.id) or 0
	if (skillid == 0) then
		d("There is a problem with the skill ID for : "..tostring(skill.name))
		return nil
	end
	
	if (skill.trg == "Target") then
		if (target.id == Player.id) then
			return nil
		end
	elseif ( skill.trg == "Player" ) then
		TID = PID
	end
	
	if (ValidTable(target) and TID ~= 0) then
		targetTable.target = target
		targetTable.TID = TID
		return targetTable
	end
	
	return nil
end
--]]

function eso_skillmanager.GetRealSkillID(skillID)
	local newid = tonumber(skillID) or 0
	--local realID = AbilityList:GetProgressionAbilityId(newid) or 0
	local realID = 0
	if (realID == 0) then
		realID = newid
	end
	
	return realID
end

function eso_skillmanager.GetAbilitySafe(skillid)
	local skillid = tonumber(skillid) or 0
	local ability = nil
	
	local list = eso_skillmanager.skillsbyindex
	if (ValidTable(list)) then
		for id,ab in pairs(list) do
			if (ab.id == skillid) then
				ability = ab
			end
			if (ability) then
				break
			end
		end
	end
	return ability
end

function eso_skillmanager.HasBuff(entity, buffID)
	local haseffect = false
	if (ValidTable(entity)) then
		haseffect = AbilityList:HasEffect(tonumber(buffID),entity.id)
	end
	
	return haseffect
end

function eso_skillmanager.MissingBuff(entity, buffID)
	local missingeffect = false
	if (ValidTable(entity)) then
		missingeffect = not AbilityList:HasEffect(tonumber(buffID),entity.id)
	end
	
	return missingeffect
end


function eso_skillmanager.HasBuffs(entity, buffIDs)
	for _orids in StringSplit(buffIDs,",") do
		local found = false
		for _andid in StringSplit(_orids,"+") do
			local realid = tonumber(eso_skillmanager.GetRealSkillID(tonumber(_andid)))
			found = AbilityList:HasEffect(tonumber(_andid),entity.id) or AbilityList:HasEffect(realid,entity.id)
			--found = AbilityList:HasEffect(tonumber(_andid),entity.id)
			if (not found) then
				break
			end
		end
		if (found) then 
			return true 
		end
	end
	return false
end

function eso_skillmanager.MissingBuffs(entity, buffIDs)
    local missing = true
    for _orids in StringSplit(buffIDs,",") do
    	missing = true
		for _andid in StringSplit(_orids,"+") do
			local realid = tonumber(eso_skillmanager.GetRealSkillID(tonumber(_andid)))
			missing = not (AbilityList:HasEffect(tonumber(_andid),entity.id) or AbilityList:HasEffect(realid,entity.id))
			--missing = not AbilityList:HasEffect(tonumber(_andid),entity.id)
			
			if (not missing) then 
				break
			end
		end
		if (missing) then 
			return true
		end
    end
    
    return false
end

function eso_skillmanager.CanCast(prio, entity)
	if (not entity) then
		return 0
	end
	
	local gameCameraActive = e("IsGameCameraActive()")
	local interactionCameraActive = e("IsInteractionCameraActive()")
	
	local prio = tonumber(prio) or 0
	if (prio == 0) then
		return 0
	end
	
	local skill = eso_skillmanager.SkillProfile[prio]
	if (not skill) then
		return 0
	elseif (skill and skill.used == "0") then
		return 0
	end
	--local realID = tonumber(skill.skillID)
	local realID = eso_skillmanager.GetRealSkillID(skill.skillID)

	--Pull the real skilldata, if we can't find it, consider it uncastable.	
	--local realskilldata = eso_skillmanager.GetAbilitySafe(realID) 
	local realskilldata = eso_skillmanager.skillsbyid[realID]
	if (not realskilldata) then
		eso_skillmanager.DebugOutput( prio, "Ability failed safeness check for "..skill.name.."["..tostring(prio).."]" )
		return 0
	end

	local castable = true
	
	--[[ -- No automatic target selections for ESO.
	local maxrange = realskilldata.range
	local targetTable = eso_skillmanager.GetSkillTarget(skill, entity, maxrange)
	if (not targetTable) then
		eso_skillmanager.DebugOutput( prio, "Target function returned no valid target. : "..tostring(prio))
		return 0
	end
	--]]
	
	-- Just in case, these shouldn't happen.
	--[[ -- No automatic target selections for ESO.
	if (not ValidTable(targetTable.target)) then
		eso_skillmanager.DebugOutput( prio, "Target function returned an invalid target, should never happen.")
		return 0
	elseif (targetTable.TID == 0) then
		eso_skillmanager.DebugOutput( prio, "Target function returned 0, should never happen.")
		return 0
	end
	--]]
	
	if (skill.trg == "Self") then
		entity = Player
	end
	
	eso_skillmanager.CurrentSkill = skill
	eso_skillmanager.CurrentSkillData = realskilldata	
	eso_skillmanager.CurrentTarget = entity
	eso_skillmanager.CurrentTID = entity.id
	
	-- Verify that condition list is valid, and that castable hasn't already been flagged false, just to save processing time.
	if (eso_skillmanager.ConditionList) then
		for i,condition in pairsByKeys(eso_skillmanager.ConditionList) do
			if (type(condition.eval) == "function") then
				if (condition.eval()) then
					castable = false		
					eso_skillmanager.DebugOutput( prio, "Condition ["..condition.name.."] failed its check for "..skill.name.."["..tostring(prio).."]" )
				end
			end
			if (not castable) then
				break
			end
		end
	end
							
	-- If skill matches the nextskillprio, force it.
	--[[ -- No forced next skills yet for ESO.
	if ( eso_skillmanager.nextSkillPrio ~= "" ) then
		if ( tonumber(eso_skillmanager.nextSkillPrio) == tonumber(skill.prio) ) then
			castable = true
		end
	end
	--]]
	
	if (castable) then
		return entity.id
	end
	
	return 0
end

eso_task_block = inheritsFrom(ml_task)
function eso_task_block.Create()
    local newinst = inheritsFrom(eso_task_block)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
    
    --ffxiv_task_killtarget members
    newinst.name = "RT_TIP_BLOCK"
    newinst.maxTime = Now() + 3000
	
    return newinst
end

function eso_task_block:Init()    
    self:AddTaskCheckCEs()
end

function eso_task_block:task_complete_eval()	
	local activeTips = Player:GetNumActiveCombatTips()
	if (activeTips > 0) then
		local blockable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_BLOCK)
		if (not ValidTable(blockable)) then
			return true
		end
	else
		return true
	end
	
	return (Now() > self.maxTime)
end

function eso_task_block:task_complete_execute()
	e("StopBlock()")
    self.completed = true
end

function eso_skillmanager.AddConditional(conditional)
	assert(type(conditional) == "table","Expected table for conditional,received type "..tostring(type(conditional)))
	table.insert(eso_skillmanager.ConditionList,conditional)
end

function eso_skillmanager.CaptureElement(newVal, varName)
	local needsSave = false
	
	local currentVal = _G[varName]
	--d("varName:"..varName..",currentVal:"..tostring(_G[varName]))
	if (currentVal ~= newVal or (type(newVal) == "table" and not deepcompare(currentVal,newVal))) then
		--d("set ["..varName.."] to ["..tostring(newVal).."]")
		_G[varName] = newVal
		needsSave = true
	end
		
	if (needsSave) then
		local prio = eso_skillmanager.EditingSkill
		if (eso_skillmanager.Variables[varName] ~= nil) then	
			skillVar = eso_skillmanager.Variables[varName]
			eso_skillmanager.SkillProfile[prio][skillVar.profile] = newVal
		end
		eso_skillmanager.SaveProfile()
	end
end

function SKM_Combo(label, varindex, varval, itemlist, height)
	_G[varindex] = GetKeyByValue(_G[varval],itemlist)
	
	local changed = false
	local newIndex = GUI:Combo(label, _G[varindex], itemlist, height)
	if (newIndex ~= _G[varindex]) then
		changed = true
		
		_G[varindex] = newIndex
		_G[varval] = itemlist[_G[varindex]]
		
		local prio = eso_skillmanager.EditingSkill
		if (eso_skillmanager.Variables[varval] ~= nil) then	
			skillVar = eso_skillmanager.Variables[varval]
			eso_skillmanager.SkillProfile[prio][skillVar.profile] = _G[varval]
		end
		eso_skillmanager.SaveProfile()
	end
	
	return changed, _G[varindex], _G[varval]
end

function eso_skillmanager.DrawLineItem(options)
    local control = options.control
    local name = options.name
    local var = options.variable
    local indexvar = options.indexvar
    local tablevar = options.tablevar
    local width = options.width
    local tooltip = IsNull(options.tooltip,"")
    
    local width = IsNull(width,0)
    GUI:AlignFirstTextHeightToWidgets()
    GUI:Text(GetString(name)); GUI:SameLine(); GUI:InvisibleButton("##"..tostring(var),5,20);
    GUI:NextColumn();
    
    if (width ~= 0) then
        GUI:PushItemWidth(width)
    end

    if (control == "combobox") then
        SKM_Combo("##"..var,indexvar,var,tablevar)
    elseif (control == "float") then
        eso_skillmanager.CaptureElement(GUI:InputFloat("##"..var,_G[var],0,0,precision),var)
    elseif (control == "int") then
        eso_skillmanager.CaptureElement(GUI:InputInt("##"..var,_G[var],0,0),var)
    elseif (control == "text") then
        eso_skillmanager.CaptureElement(GUI:InputText("##"..var,_G[var]),var)
    elseif (control == "checkbox") then
        
    end
    
    if (width ~= 0) then
        GUI:PopItemWidth()
    end
    
    if (tooltip ~= "") then
        if (GUI:IsItemHovered()) then
            GUI:SetTooltip(tooltip)
        end
    end
    
    GUI:NextColumn();
end

function eso_skillmanager.AddDefaultConditions()
	conditional = { name = "Skill Enabled Check"
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		
		if (skill.enabled == "0") then
			return true
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	--[[conditional = { name = "Client CanCast/Range Check"
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		
		--local skillid = tonumber(skill.skillID)
		local skillid = eso_skillmanager.GetRealSkillID(skill.skillID)
		if not (AbilityList:IsTargetInRange(skillid,target.id) and AbilityList:CanCast(skillid,target.id) == 10) then
			return true
		end
		
		return false
	end
	}]]
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Min/Max Range Check"
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		
		local minRange = tonumber(skill.minRange)
		local maxRange = tonumber(skill.maxRange)
		
		if ((minRange > 0 and target.distance < skill.minRange) or
			(maxRange > 0 and target.distance > skill.maxRange))
		then
			return true
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)

	conditional = { name = "Previous Skill ID Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		
		if ( not IsNullString(skill.previd)) then
			if (not IsNullString(eso_skillmanager.prevSkillID)) then
				for skillid in StringSplit(skill.previd,",") do
					--local realID = tonumber(skillid)
					local realID = eso_skillmanager.GetRealSkillID(skillid)
					if (tonumber(eso_skillmanager.prevSkillID) == realID) then
						return false
					end
				end
			end
			return true
		end
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Previous Skill NOT ID Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		if (not IsNullString(skill.nprevid)) then
			if (not IsNullString(eso_skillmanager.prevSkillID)) then
				for skillid in StringSplit(skill.nprevid,",") do
					--local realID = tonumber(skillid)
					local realID = eso_skillmanager.GetRealSkillID(skillid)
					if (tonumber(eso_skillmanager.prevSkillID) == realID) then
						return true
					end
				end
			end
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)

	conditional = { name = "Player Target Type Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		if ( skill.ptrg ~= "Any" ) then
			if (( skill.ptrg == "Enemy" and (not target or not target.attackable)) or 
				( skill.ptrg == "Player" and (not target or target.type ~= 1))) 
			then 
				return true 
			end
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)

	--[[ - No Combat Status Checks yet.
	conditional = { name = "Combat Status Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		local preCombat = eso_skillmanager.preCombat
		
		if (((skill.combat == "Out of Combat") and (preCombat == false or Player.incombat)) or
			((skill.combat == "In Combat") and (preCombat == true)) or
			((skill.combat == "In Combat") and not Player.incombat and skill.trg ~= "Target") or
			((skill.combat == "In Combat") and not Player.incombat and not target.attackable))
		then 
			return true
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	--]]
	
	--[[ - No Filter Checks yet.
	conditional = { name = "Filter Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		
		if 	((gAssistFilter1 == "1" and skill.filterone == "Off") or 
			(gAssistFilter1 == "0" and skill.filterone == "On" ) or 
			(gAssistFilter2 == "1" and skill.filtertwo == "Off") or
			(gAssistFilter2 == "0" and skill.filtertwo == "On" ) or
			(gAssistFilter3 == "1" and skill.filterthree == "Off") or
			(gAssistFilter3 == "0" and skill.filterthree == "On" ) or
			(gAssistFilter4 == "1" and skill.filterfour == "Off") or
			(gAssistFilter4 == "0" and skill.filterfour == "On" ) or
			(gAssistFilter5 == "1" and skill.filterfive == "Off") or
			(gAssistFilter5 == "0" and skill.filterfive == "On" ))
		then
			return true
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	--]]
	
	conditional = { name = "Throttled Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		local throttle = tonumber(skill.throttle) or 0
		if ( throttle > 0 and skill.timelastused and TimeSince(skill.timelastused) < throttle) then 
			return true
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Player HP/Power Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		if ((tonumber(skill.phpgt) > 0 and tonumber(skill.phpgt) > ml_global_information.Player_Health.percent)	or 
			(tonumber(skill.phplt) > 0 and tonumber(skill.phplt) < ml_global_information.Player_Health.percent))
		then
			return true
		end
		
		if (skill.powertype == "Magicka") then
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > ml_global_information.Player_Magicka.percent)	or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < ml_global_information.Player_Magicka.percent))
			then 
				return true
			end
		elseif (skill.powertype == "Stamina") then
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > ml_global_information.Player_Stamina.percent)	or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < ml_global_information.Player_Stamina.percent))
			then 
				return true
			end
		elseif (skill.powertype == "Ultimate") then
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > ml_global_information.Player_Ultimate.percent)	or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < ml_global_information.Player_Ultimate.percent))
			then 
				return true
			end
		end				
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	--[[conditional = { name = "Player Single Buff Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		
		if (skill.pbuffthis == "1") then
			if not eso_skillmanager.HasBuff(Player, realskilldata.id) then 
				return true
			end 
		end
		if (skill.pnbuffthis == "1") then
			if not eso_skillmanager.MissingBuff(Player, realskilldata.id) then 
				return true
			end
		end			
		return false
	end
	}]]
	eso_skillmanager.AddConditional(conditional)
	
	--[[conditional = { name = "Target Single Buff Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		if (skill.tbuffthis == "1") then
			if not eso_skillmanager.HasBuff(target, realskilldata.id) then 
				return true
			end 
		end
		if (skill.tnbuffthis == "1") then
			if not eso_skillmanager.MissingBuff(target, realskilldata.id) then 
				return true
			end
		end			
		return false
	end
	}]]
	eso_skillmanager.AddConditional(conditional)
	
	--[[conditional = { name = "Player Buff Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		if (not IsNullString(skill.pbuff)) then
			if (not eso_skillmanager.HasBuffs(Player, skill.pbuff)) then 
				return true
			end 
		end
		if (not IsNullString(skill.pnbuff)) then
			if (not eso_skillmanager.MissingBuffs(Player, skill.pnbuff)) then 
				return true 
			end 
		end			
		return false
	end
	}]]
	--[[eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Target Buff Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		if (not IsNullString(skill.tbuff)) then
			if (not eso_skillmanager.HasBuffs(target, skill.tbuff)) then 
				return true 
			end 
		end
		if (not IsNullString(skill.tnbuff)) then
			if (not eso_skillmanager.MissingBuffs(target, skill.tnbuff)) then 
				return true 
			end 
		end	
		return false
	end
	}]]
	eso_skillmanager.AddConditional(conditional)
	
	--[[conditional = { name = "Target HP Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		local thpgt = tonumber(skill.thpgt) or 0
		local thplt = tonumber(skill.thplt) or 0
		
		if ((thpgt > 0 and thpgt > target.hp.percent) or
			(thplt > 0 and thplt < target.hp.percent))
		then 
			return true 
		end
		
		return false
	end
	}]]
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Target Casting Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		
		if ( skill.iscasting == "1" and not (target.iscasting) ) then 
			return false 
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Target AOE Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		
		local tecount = tonumber(skill.tecount) or 0
		local tecount2 = tonumber(skill.tecount2) or 0
		local terange = tonumber(skill.terange) or 5
		
		local tlistAE = nil
		if (tecount > 0 or tecount2 > 0) then
			local elstring = "alive,attackable,nocritter,maxdistance="..tostring(skill.terange)..",distanceto="..tostring(target.id)
			if (gPreventAttackingInnocents == "1") then
				elstring = elstring..",hostile"
			end
			
			tlistAE = EntityList(elstring)
			local attackTable = TableSize(tlistAE) or 0
			
			if (tecount > 0 and ( attackTable < tecount)) then
				return true
			end
			if (tecount2 > 0 and ( attackTable > tecount2)) then
				return true
			end
		end	
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Ally AOE Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		
		local tacount = tonumber(skill.tacount) or 0
		local tarange = tonumber(skill.tarange) or 5
		
		if (tacount > 0) then
			plistAE = EntityList("friendly,maxdistance="..tostring(skill.tarange)..",distanceto="..tostring(target.id))
			if (TableSize(plistAE) < tacount) then 
				return true 
			end
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
end

function eso_skillmanager.DrawSkillBook()

	GUI:SetNextWindowPos((eso_skillmanager.GUI.manager.x - eso_skillmanager.GUI.skillbook.width),eso_skillmanager.GUI.manager.y,GUI.SetCond_Appearing)
	GUI:SetNextWindowSize(350,450,GUI.SetCond_Appearing)
	eso_skillmanager.GUI.skillbook.visible, eso_skillmanager.GUI.skillbook.open = GUI:Begin(eso_skillmanager.GUI.skillbook.name, true)
	if ( eso_skillmanager.GUI.skillbook.visible ) then 
		
		local x, y = GUI:GetWindowPos()
		local width, height = GUI:GetWindowSize()
		local contentwidth = GUI:GetContentRegionAvailWidth()
		
		eso_skillmanager.GUI.skillbook.x = x; eso_skillmanager.GUI.skillbook.y = y; eso_skillmanager.GUI.skillbook.width = width; eso_skillmanager.GUI.skillbook.height = height;
		
		--GUI_Capture(GUI:Checkbox("This Job Only",geso_skillmanagerFilterJob),"geso_skillmanagerFilterJob")
		--GUI_Capture(GUI:Checkbox("Usable Only",geso_skillmanagerFilterUsable),"geso_skillmanagerFilterUsable")
		
		eso_skillmanager.SkillBook = eso_skillmanager.BuildSkillsList()
		
		if (table.valid(eso_skillmanager.SkillBook)) then
			for key, skillInfo in spairs(eso_skillmanager.SkillBook) do
				if ( GUI:Button(skillInfo.name.." ["..tostring(skillInfo.id).."]",width,20)) then
					eso_skillmanager.AddSkillToProfile(skillInfo.id)
					eso_skillmanager.SaveProfile()
				
				end
			end
		end
	end
	GUI:End()
end

function eso_skillmanager.DrawSkillEditor(prio)
	if (eso_skillmanager.GUI.editor.open) then	
		GUI:SetNextWindowPos(eso_skillmanager.GUI.manager.x + eso_skillmanager.GUI.manager.width,eso_skillmanager.GUI.manager.y,GUI.SetCond_Appearing)
		GUI:SetNextWindowSize(350,600,GUI.SetCond_FirstUseEver) --set the next window size, only on first ever
		eso_skillmanager.GUI.editor.visible, eso_skillmanager.GUI.editor.open = GUI:Begin(eso_skillmanager.GUI.editor.name, eso_skillmanager.GUI.editor.open)
		if ( eso_skillmanager.GUI.editor.visible ) then 
			local skill = eso_skillmanager.SkillProfile[eso_skillmanager.GUI.skillbook.id]
			if (table.valid(skill)) then
				
				GUI:Columns(2,"#table-main",false)
				GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,300);
				
				GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Name")); GUI:NextColumn(); GUI:Text(skill.name); GUI:NextColumn();
				GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Alias")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_ALIAS",SKM_ALIAS),"SKM_ALIAS"); GUI:NextColumn();
				GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("ID")); GUI:NextColumn(); GUI:Text(skill.id); GUI:NextColumn();
				GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Type")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TYPE",SKM_TYPE,0,0),"SKM_TYPE"); GUI:NextColumn();
				GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Used")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_ON",SKM_ON),"SKM_ON"); GUI:NextColumn();		
				
				GUI:Columns(1)
				
				eso_skillmanager.DrawBattleEditor(skill)
			end
		end
		GUI:End()
	end
end

function eso_skillmanager.Draw()

	if ( eso_skillmanager.GUI.skillbook.open ) then 
	
		eso_skillmanager.DrawSkillBook()

	
		GUI:SetNextWindowSize(250,400,GUI.SetCond_Once) --set the next window size, only on first ever	
		GUI:SetNextWindowCollapsed(false,GUI.SetCond_Once)
		
		local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
		GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], (255/255))
		
		eso_skillmanager.GUI.profile.visible, eso_skillmanager.GUI.profile.open = GUI:Begin(eso_skillmanager.GUI.profile.name, eso_skillmanager.GUI.profile.open)
		
		local contentwidth = GUI:GetContentRegionAvailWidth()
		if table.valid(eso_skillmanager.SkillProfile) then
			for prio,skillInfo in spairs(eso_skillmanager.SkillProfile) do
			
				if (GUI:Button(skillInfo.name,contentwidth,20)) then -- skill to edit
				end
					
				if (GUI:IsItemHovered()) then
					if (GUI:IsMouseClicked(0)) then
						eso_skillmanager.GUI.skillbook.id = prio
					elseif (GUI:IsMouseClicked(1)) then
						eso_skillmanager.GUI.skillbook.id = 0
						eso_skillmanager.SkillProfile[prio] = nil
						eso_skillmanager.SaveProfile()
					end
				end
			end
		end

	
		GUI:End()
		GUI:PopStyleColor()
		
		if eso_skillmanager.GUI.skillbook.id ~= 0 then -- draw editor
			eso_skillmanager.DrawSkillEditor(eso_skillmanager.GUI.skillbook.id)
		end

	
	end
end

function eso_skillmanager.DrawBattleEditor()
	
	if (GUI:CollapsingHeader("Basic","battle-basic-header")) then
		GUI:Columns(2,"#battle-basic-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Combat Status")); GUI:NextColumn(); SKM_Combo("##SKM_Combat","gSMBattleStatusIndex","SKM_Combat",gSMBattleStatuses); GUI:NextColumn();
		--eso_skillmanager.DrawLineItem{control = "combobox", name = "Combat Status", variable = "SKM_Combat", indexvar = "gSMBattleStatusIndex", tablevar = gSMBattleStatuses, width = 200}
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("skmCHARGE")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When selected, this skill will be considered a 'gap closer', like Shoulder Tackle or Plunge.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_CHARGE",SKM_CHARGE),"SKM_CHARGE"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("appliesBuff")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Check this box if the skill applies a Buff or Debuff.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_DOBUFF",SKM_DOBUFF),"SKM_DOBUFF"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("removesBuff")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Check this box if the skill removes a Buff.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_REMOVESBUFF",SKM_REMOVESBUFF),"SKM_REMOVESBUFF"); GUI:NextColumn();
		
		GUI:AlignFirstTextHeightToWidgets(); eso_skillmanager.DrawLineItem{control = "int", name = "skmLevelMin", variable = "SKM_LevelMin", width = 50, tooltip = "Use this skill when the character is at or above a certain level (Set to 0 to ignore)."}
		GUI:AlignFirstTextHeightToWidgets(); eso_skillmanager.DrawLineItem{control = "int", name = "skmLevelMax", variable = "SKM_LevelMax", width = 50, tooltip = "Use this skill when the character is at or below a certain level (Set to 0 to ignore)."}
		GUI:AlignFirstTextHeightToWidgets(); eso_skillmanager.DrawLineItem{control = "int", name = "minRange", variable = "SKM_MinR", width = 50, tooltip = "Minimum range the skill can be used (For most skills, this will stay at 0)."}
		GUI:AlignFirstTextHeightToWidgets(); eso_skillmanager.DrawLineItem{control = "int", name = "maxRange", variable = "SKM_MaxR", width = 50, tooltip = "Maximum range the skill can be used."}
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("prevComboSkill")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill is part of a combo, enter the ID of the skill that should be executed immediately before this one.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PCSkillID",SKM_PCSkillID),"SKM_PCSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("prevComboSkillNot")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill is part of a combo, enter the ID of the skill that should NOT be executed immediately before this one.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_NPCSkillID",SKM_NPCSkillID),"SKM_NPCSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous GCD Skill")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should be used immediately after another skill on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PGSkillID",SKM_PGSkillID),"SKM_PGSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous GCD Skill NOT")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should NOT be used immediately after another skill on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_NPGSkillID",SKM_NPGSkillID),"SKM_NPGSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous Skill")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should be used immediately after another skill that is not on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PSkillID",SKM_PSkillID),"SKM_PSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous Skill NOT")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should NOT be used immediately after another skill that is not on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_NPSkillID",SKM_NPSkillID),"SKM_NPSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Current Action NOT")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should NOT be used while the character is in a particular animation, put the ID of that animation here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_NCURRENTACTION",SKM_NCURRENTACTION),"SKM_NCURRENTACTION"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("filter1")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Quick 'switches' used to adjust what skills can or can't be used.")) end GUI:NextColumn(); SKM_Combo("##SKM_FilterOne","gSMFilter1Index","SKM_FilterOne",gSMFilterStatuses); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("filter2")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Quick 'switches' used to adjust what skills can or can't be used.")) end GUI:NextColumn(); SKM_Combo("##SKM_FilterTwo","gSMFilter2Index","SKM_FilterTwo",gSMFilterStatuses); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("filter3")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Quick 'switches' used to adjust what skills can or can't be used.")) end GUI:NextColumn(); SKM_Combo("##SKM_FilterThree","gSMFilter3Index","SKM_FilterThree",gSMFilterStatuses); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("filter4")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Quick 'switches' used to adjust what skills can or can't be used.")) end GUI:NextColumn(); SKM_Combo("##SKM_FilterFour","gSMFilter4Index","SKM_FilterFour",gSMFilterStatuses); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("filter5")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Quick 'switches' used to adjust what skills can or can't be used.")) end GUI:NextColumn(); SKM_Combo("##SKM_FilterFive","gSMFilter5Index","SKM_FilterFive",gSMFilterStatuses); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("onlySolo")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, this skill will only be used when the character is solo or with only their chocobo.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_OnlySolo",SKM_OnlySolo),"SKM_OnlySolo"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("onlyParty")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, this skill will only be used when the character is in a Party.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_OnlyParty",SKM_OnlyParty),"SKM_OnlyParty"); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, this skill will only be used when the character is in a Party.")) end GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Party Size <=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, this skill will only be used when the character is in a Party of less than or equal to this number of characters (Set to 0 to ignore).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PartySizeLT",SKM_PartySizeLT,0,0),"SKM_PartySizeLT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("secsSinceLastCast")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Set this to ensure that the skill is used at least this many seconds since the last time it was used on this mob.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_SecsPassed",SKM_SecsPassed,0,0,3),"SKM_SecsPassed"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Secs Passed Unique")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Set this to ensure that the skill is used at least this many seconds since the last time it was used irrespective of mob.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_SecsPassedUnique",SKM_SecsPassedUnique,0,0,3),"SKM_SecsPassedUnique"); GUI:NextColumn();
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader("Chain","battle-chain-header")) then
		GUI:Columns(2,"#battle-chain-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Chain Name")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill is part of a custom chain, enter that name here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_CHAINNAME",SKM_CHAINNAME),"SKM_CHAINNAME"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Chain Start")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, this skill will be considered the first skill in the custom chain.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_CHAINSTART",SKM_CHAINSTART),"SKM_CHAINSTART"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Chain End")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, this skill will be considered the last skill in the custom chain.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_CHAINEND",SKM_CHAINEND),"SKM_CHAINEND"); GUI:NextColumn();
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader("Other Skill Checks","battle-otherskills-header")) then
		GUI:Columns(2,"#battle-otherskills-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Is Ready")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("The ID of any skill that should be available for use before this skill is used.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_SKREADY",SKM_SKREADY),"SKM_SKREADY"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("CD Ready")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString(" The ID of any skill off the global cooldown that should be ready before this skill is used.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_SKOFFCD",SKM_SKOFFCD),"SKM_SKOFFCD"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Is Not Ready")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString(" The ID of any skill that should NOT be ready before this skill is used.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_SKNREADY",SKM_SKNREADY),"SKM_SKNREADY"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("CD Not Ready")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("The ID of any skill off the global cooldown that should NOT be ready before this skill is used.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_SKNOFFCD",SKM_SKNOFFCD),"SKM_SKNOFFCD"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("CD Time >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("This is in reference to 'CD Not Ready' - Use this and the following skill to set advanced usage instructions, such as 'Use this skill when Skill 'X' has between 2 and 6 seconds left on cooldown'.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_SKNCDTIMEMIN",SKM_SKNCDTIMEMIN,0,0,3),"SKM_SKNCDTIMEMIN"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("CD Time <=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("This is in reference to 'CD Not Ready' - Use this and the preceeding skill to set advanced usage instructions, such as 'Use this skill when Skill 'X' has between 2 and 6 seconds left on cooldown'.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_SKNCDTIMEMAX",SKM_SKNCDTIMEMAX,0,0,3),"SKM_SKNCDTIMEMAX"); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("What is this?")) end GUI:NextColumn();
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("playerHPMPTP"),"battle-playerhp-header")) then
		GUI:Columns(2,"#battle-playerhp-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("playerHPGT",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player HP is greater than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHPL",SKM_PHPL,0,0),"SKM_PHPL"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("playerHPLT",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player HP is less than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHPB",SKM_PHPB,0,0),"SKM_PHPB"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("underAttack")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player is under attack from Ranged or Melee targets.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_PUnderAttack",SKM_PUnderAttack),"SKM_PUnderAttack"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("underAttackMelee")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player is under attack from Melee targets only.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_PUnderAttackMelee",SKM_PUnderAttackMelee),"SKM_PUnderAttackMelee"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("playerPowerGT",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player MP is more than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PPowL",SKM_PPowL,0,0),"SKM_PPowL"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("playerPowerLT",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player MP is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PPowB",SKM_PPowB,0,0),"SKM_PPowB"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("skmPMPPL",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player MP is greater than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PMPPL",SKM_PMPPL,0,0),"SKM_PMPPL"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("skmPMPPB",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("TUse this skill when Player MP is less than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PMPPB",SKM_PMPPB,0,0),"SKM_PMPPB"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Result MP >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player MP after casting the skill will be more than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PMPRGT",SKM_PMPRGT,0,0),"SKM_PMPRGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Result MP %% >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player MP after casting the skill will be more than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PMPPRGT",SKM_PMPPRGT,0,0),"SKM_PMPPRGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Result MP >= Cost of [ID]")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player MP after casting the skill will be greater than or equal to the MP required to cast the spell whose ID is in this field.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PMPRSGT",SKM_PMPRSGT),"SKM_PMPRSGT"); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("The ID of any skill that should be available for use before this skill is used.")) end GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("skmPTPL",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player TP is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTPL",SKM_PTPL,0,0),"SKM_PTPL"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("skmPTPB",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player TP is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTPB",SKM_PTPB,0,0),"SKM_PTPB"); GUI:NextColumn();
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("Party"),"battle-party-header")) then
		GUI:Columns(2,"#battle-party-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("skmPTCount")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTCount",SKM_PTCount,0,0),"SKM_PTCount"); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of party members is more or equal to this number.")) end GUI:NextColumn();
		GUI:Text(GetString("skmPTHPL",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when a party members' HP is greater than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTHPL",SKM_PTHPL,0,0),"SKM_PTHPL"); GUI:NextColumn();
		GUI:Text(GetString("skmPTHPB",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when a party members' HP is less than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTHPB",SKM_PTHPB,0,0),"SKM_PTHPB"); GUI:NextColumn();
		GUI:Text(GetString("skmPTMPL",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when a party members' MP is greater than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTMPL",SKM_PTMPL,0,0),"SKM_PTMPL"); GUI:NextColumn();
		GUI:Text(GetString("skmPTMPB",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when a party members' MP is less than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTMPB",SKM_PTMPB,0,0),"SKM_PTMPB"); GUI:NextColumn();
		GUI:Text(GetString("skmPTTPL",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when a party members' TP is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTTPL",SKM_PTTPL,0,0),"SKM_PTTPL"); GUI:NextColumn();
		GUI:Text(GetString("skmPTTPB",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when a party members' TP is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PTTPB",SKM_PTTPB,0,0),"SKM_PTTPB"); GUI:NextColumn();
		GUI:Text(GetString("skmHasBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill if a party member is being affected by buffs with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PTBuff",SKM_PTBuff),"SKM_PTBuff"); GUI:NextColumn();
		GUI:Text(GetString("Known Debuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When selected, use this skill when being affected by a Minion-maintained list of debuffs (helpful for Esuna skills).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_PTKBuff",SKM_PTKBuff),"SKM_PTKBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmMissBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill if a party member is missing a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PTNBuff",SKM_PTNBuff),"SKM_PTNBuff"); GUI:NextColumn();
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("Target"),"battle-target-header")) then
		GUI:Columns(2,"#battle-target-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("skmTRG")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select the target of the skill, including Ground Target, Tankable Enemy, etc.")) end GUI:NextColumn(); SKM_Combo("##SKM_TRG","gSMTarget","SKM_TRG",gSMTargets); GUI:NextColumn();
		GUI:Text(GetString("skmTRGTYPE")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select the role of the character that this spell should be used on.")) end GUI:NextColumn(); SKM_Combo("##SKM_TRGTYPE","gSMTargetType","SKM_TRGTYPE",gSMTargetTypes); GUI:NextColumn();
		GUI:Text(GetString("Include Self")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, the skill will be used on yourself if you meet the conditions.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_TRGSELF",SKM_TRGSELF),"SKM_TRGSELF"); GUI:NextColumn();
		GUI:Text(GetString("skmNPC")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, the skill will be used on NPCs who meet the conditions.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_NPC",SKM_NPC),"SKM_NPC"); GUI:NextColumn();
		GUI:Text(GetString("skmPTRG")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select the Target of the Player casting the spell- Enemy or Player.")) end GUI:NextColumn(); SKM_Combo("##SKM_PTRG","gSMPlayerTarget","SKM_PTRG",gSMPlayerTargets); GUI:NextColumn();
		GUI:Text(GetString("skmPGTRG")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select how 'accurate' the Ground Target effect should be- directly on the target, behind it, or near it.")) end GUI:NextColumn(); SKM_Combo("##SKM_PGTRG","gSMPlayerGroundTargetPosition","SKM_PGTRG",gSMPlayerGroundTargetPositions); GUI:NextColumn();
		GUI:Text(GetString("skmPPos")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If the skill has a positional, select it here.")) end GUI:NextColumn(); SKM_Combo("##SKM_PPos","gSMPlayerPosition","SKM_PPos",gSMPlayerPositions); GUI:NextColumn();
		
		GUI:Text(GetString("targetHPGT",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is greater than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPL",SKM_THPL,0,0),"SKM_THPL"); GUI:NextColumn();
		GUI:Text(GetString("targetHPLT",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is less than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPB",SKM_THPB,0,0),"SKM_THPB"); GUI:NextColumn();
		GUI:Text(GetString("skmTHPCL",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPCL",SKM_THPCL,0,0),"SKM_THPCL"); GUI:NextColumn();
		GUI:Text(GetString("skmTHPCB",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPCB",SKM_THPCB,0,0),"SKM_THPCB"); GUI:NextColumn();
		
		GUI:Text(GetString("hpAdvantage")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the difference of Max HP between you and an enemy is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_THPADV",SKM_THPADV,0,0,2),"SKM_THPADV"); GUI:NextColumn();
		GUI:Text(GetString("targetTPLE",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the TP of the Target is less than this amount.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TTPL",SKM_TTPL,0,0),"SKM_TTPL"); GUI:NextColumn();
		GUI:Text(GetString("targetMPLE",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the TP of the Target is more than this amount.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TMPL",SKM_TMPL,0,0),"SKM_TMPL"); GUI:NextColumn();
		GUI:Text(GetString("skmTCONTIDS")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Target must have one of the listed contentids (comma-separated list).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TCONTIDS",SKM_TCONTIDS),"SKM_TCONTIDS"); GUI:NextColumn();
		GUI:Text(GetString("skmTNCONTIDS")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Target must NOT have one of the listed contentids (comma-separated list).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TNCONTIDS",SKM_TNCONTIDS),"SKM_TNCONTIDS"); GUI:NextColumn();

		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("Gauges"),"battle-gauges-header")) then
		GUI:Columns(2,"#battle-gauges-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		for i = 1,8 do
			GUI:Text(GetString("Gauge Indicator "..tostring(i))); GUI:NextColumn(); GUI:NextColumn();
			GUI:Text(GetString("Value <=")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_GAUGE"..tostring(i).."LT",_G["SKM_GAUGE"..tostring(i).."LT"],0,0),"SKM_GAUGE"..tostring(i).."LT"); GUI:NextColumn();
			GUI:Text(GetString("Value >=")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_GAUGE"..tostring(i).."GT",_G["SKM_GAUGE"..tostring(i).."GT"],0,0),"SKM_GAUGE"..tostring(i).."GT"); GUI:NextColumn();
			GUI:Text(GetString("Value =")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_GAUGE"..tostring(i).."EQ",_G["SKM_GAUGE"..tostring(i).."EQ"],0,0),"SKM_GAUGE"..tostring(i).."EQ"); GUI:NextColumn();
			GUI:Text(GetString("Value In")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_GAUGE"..tostring(i).."OR",_G["SKM_GAUGE"..tostring(i).."OR"]),"SKM_GAUGE"..tostring(i).."OR"); 
			if (GUI:IsItemHovered()) then
				GUI:SetTooltip(GetString("Ex: [0,16,32,48] if the value needs to be 0 or 16 or 32 or 48 (do not include brackets)."))
			end
			GUI:NextColumn();	
		end
			
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("casting"),"battle-casting-header")) then
		GUI:Columns(2,"#battle-casting-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		GUI:Text(GetString("skmTCASTID")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Target must be channelling one of the listed spell IDs (comma-separated list).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TCASTID",SKM_TCASTID),"SKM_TCASTID"); GUI:NextColumn();
		GUI:Text(GetString("skmTCASTTM")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Target must be casting the spell on me (self).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_TCASTTM",SKM_TCASTTM),"SKM_TCASTTM"); GUI:NextColumn();
		GUI:Text(GetString("skmTCASTTIME")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Cast time left on the current spell must be greater than or equal to (>=) this time in seconds.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TCASTTIME",SKM_TCASTTIME),"SKM_TCASTTIME"); GUI:NextColumn();		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("healPriority"),"battle-healPriority-header")) then
		GUI:Columns(2,"#battle-healPriority-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("skmHPRIOHP")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("HP percentage (%) must be lesser or equal to (<=) this number for the spell to apply.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_HPRIOHP",SKM_HPRIOHP,0,0),"SKM_HPRIOHP"); GUI:NextColumn();		
		GUI:Text(GetString("skmHPRIO1")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Heals will target the applicable groups in this priority order. Possible values: Self, Tank, Party, Any.")) end GUI:NextColumn(); SKM_Combo("##SKM_HPRIO1","gSMHealPriority1","SKM_HPRIO1",gSMHealPriorities); GUI:NextColumn();
		GUI:Text(GetString("skmHPRIO2")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Heals will target the applicable groups in this priority order. Possible values: Self, Tank, Party, Any.")) end GUI:NextColumn(); SKM_Combo("##SKM_HPRIO2","gSMHealPriority2","SKM_HPRIO2",gSMHealPriorities); GUI:NextColumn();
		GUI:Text(GetString("skmHPRIO3")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Heals will target the applicable groups in this priority order. Possible values: Self, Tank, Party, Any.")) end GUI:NextColumn(); SKM_Combo("##SKM_HPRIO3","gSMHealPriority3","SKM_HPRIO3",gSMHealPriorities); GUI:NextColumn();
		GUI:Text(GetString("skmHPRIO4")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Heals will target the applicable groups in this priority order. Possible values: Self, Tank, Party, Any.")) end GUI:NextColumn(); SKM_Combo("##SKM_HPRIO4","gSMHealPriority4","SKM_HPRIO4",gSMHealPriorities); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("aoe"),"battle-aoe-header")) then
		GUI:Columns(2,"#battle-aoe-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("enmityAOE")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select this option if the skill is an Area-of-Effect skill that generates enmity.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_EnmityAOE",SKM_EnmityAOE),"SKM_EnmityAOE"); GUI:NextColumn();
		GUI:Text(GetString("frontalCone")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select this option if the skill has a frontal cone effect.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_FrontalConeAOE",SKM_FrontalConeAOE),"SKM_FrontalConeAOE"); GUI:NextColumn();
		GUI:Text(GetString("tankedTargetsOnly")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select this option if the skill should only be used on enemies being tanked.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_TankedOnly",SKM_TankedOnly),"SKM_TankedOnly"); GUI:NextColumn();
		GUI:Text(GetString("Average HP %% >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the average HP of the enemies is greater than or equal to this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TEHPAvgGT",SKM_TEHPAvgGT,0,0),"SKM_TEHPAvgGT"); GUI:NextColumn();
		GUI:Text(GetString("skmTECount")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of enemies is greater than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TECount",SKM_TECount,0,0),"SKM_TECount"); GUI:NextColumn();
		GUI:Text(GetString("skmTECount2")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of enemies is less than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TECount2",SKM_TECount2,0,0),"SKM_TECount2"); GUI:NextColumn();
		GUI:Text(GetString("skmTERange")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when enemies are within this range (150 = size of the minimap).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TERange",SKM_TERange,0,0),"SKM_TERange"); GUI:NextColumn();
		GUI:Text(GetString("aoeCenter")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this dropdown to select where the AOE should be centered. Possible values: Target, Self.")) end GUI:NextColumn(); SKM_Combo("##SKM_TECenter","gSMAOECenter","SKM_TECenter",gSMAOECenters); GUI:NextColumn();
		GUI:Text(GetString("skmTELevel")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when there is a level difference between you and the target. Possible values: 2, 4, 6.")) end GUI:NextColumn(); SKM_Combo("##SKM_TELevel","gSMAOELevel","SKM_TELevel",gSMAOELevels); GUI:NextColumn();
		GUI:Text(GetString("skmTACount")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of allies near you is greater or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TACount",SKM_TACount,0,0),"SKM_TACount"); GUI:NextColumn();
		GUI:Text(GetString("skmTARange")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when allies are within this range (150 = size of the minimap).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TARange",SKM_TARange,0,0),"SKM_TARange"); GUI:NextColumn();
		GUI:Text(GetString("alliesNearHPLT")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of an ally is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TAHPL",SKM_TAHPL,0,0),"SKM_TAHPL"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("playerBuffs"),"battle-playerbuffs-header")) then
		GUI:Columns(2,"#battle-playerbuffs-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("skmHasBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Player is being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PBuff",SKM_PBuff),"SKM_PBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmAndBuffDura")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the duration remaining of one of the buffs above is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PBuffDura",SKM_PBuffDura,0,0),"SKM_PBuffDura"); GUI:NextColumn();
		GUI:Text(GetString("skmMissBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Player is not being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PNBuff",SKM_PNBuff),"SKM_PNBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmOrBuffDura")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the duration remaining of one of the buffs above is less than or equal to this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PNBuffDura",SKM_PNBuffDura,0,0),"SKM_PNBuffDura"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("targetBuffs"),"battle-targetbuffs-header")) then
		GUI:Columns(2,"#battle-targetbuffs-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("skmTBuffOwner")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select the entity who will have the buff for this condition. Possible values: Player, Any.")) end GUI:NextColumn(); SKM_Combo("##SKM_TBuffOwner","gSMBuffOwner","SKM_TBuffOwner",gSMBuffOwners); GUI:NextColumn();
		GUI:Text(GetString("skmHasBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Target is being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TBuff",SKM_TBuff),"SKM_TBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmAndBuffDura")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the duration remaining of one of the buffs above is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TBuffDura",SKM_TBuffDura,0,0),"SKM_TBuffDura"); GUI:NextColumn();
		GUI:Text(GetString("skmTBuffOwner")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Select the entity who will be missing the buff for this condition. Possible values: Player, Any.")) end GUI:NextColumn(); SKM_Combo("##SKM_TNBuffOwner","gSMBuffOwnerN","SKM_TNBuffOwner",gSMBuffOwners); GUI:NextColumn();
		GUI:Text(GetString("skmMissBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Target is not being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TNBuff",SKM_TNBuff),"SKM_TNBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmOrBuffDura")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the duration remaining of one of the buffs above is less than or equal to this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TNBuffDura",SKM_TNBuffDura,0,0),"SKM_TNBuffDura"); GUI:NextColumn();	
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("Pet Buffs"),"battle-petbuffs-header")) then
		GUI:Columns(2,"#battle-petbuffs-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("skmHasBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when your pet is being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PetBuff",SKM_PetBuff),"SKM_PetBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmAndBuffDura")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the duration remaining of one of the buffs above is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PetBuffDura",SKM_PetBuffDura,0,0),"SKM_PetBuffDura"); GUI:NextColumn();
		GUI:Text(GetString("skmMissBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when your pet is not being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PetNBuff",SKM_PetNBuff),"SKM_PetNBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmOrBuffDura")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the duration remaining of one of the buffs above is less than or equal to this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PetNBuffDura",SKM_PetNBuffDura,0,0),"SKM_PetNBuffDura"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("advancedSettings"),"battle-advanced-header")) then
		GUI:Columns(2,"#battle-advanced-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("offGCDSkill")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this dropdown to tell FFXIVMinion explicitly if the skill is off the global cooldown.")) end GUI:NextColumn(); SKM_Combo("##SKM_OffGCD","gSMOffGCDSetting","SKM_OffGCD",gSMOffGCDSettings); GUI:NextColumn();
		GUI:Text(GetString("Off GCD Time >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Global cooldown time remaining must be greater or equal to this number in seconds.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_OffGCDTime",SKM_OffGCDTime,0,0,2),"SKM_OffGCDTime"); GUI:NextColumn();	
		GUI:Text(GetString("Off GCD Time <=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Global cooldown time remaining must be lesser or equal to this number in seconds.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_OffGCDTimeLT",SKM_OffGCDTimeLT,0,0,2),"SKM_OffGCDTimeLT"); GUI:NextColumn();	
		GUI:Text(GetString("Ignore Moving")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("When checked, the skill will be used whether or not the character is moving. ")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_IgnoreMoving",SKM_IgnoreMoving),"SKM_IgnoreMoving"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	--[[		
	GUI_NewButton(eso_skillmanager.editwindow.name,"Build Macro","SMToggleMacro","Macro")
	--]]
end

RegisterEventHandler("Gameloop.Update",eso_skillmanager.OnUpdate,"ESO Update")
RegisterEventHandler("Gameloop.Draw",eso_skillmanager.Draw,"ESOSKM  Draw")
RegisterEventHandler("GUI.Item",eso_skillmanager.ButtonHandler,"ESO ButtonHandler")
RegisterEventHandler("SkillManager.toggle", eso_skillmanager.ToggleMenu,"ESO ToggleMenu")
RegisterEventHandler("GUI.Update",eso_skillmanager.GUIVarUpdate,"ESO GUIVarUpdate")
RegisterEventHandler("Module.Initalize",eso_skillmanager.ModuleInit,"ESO ModuleInit")
