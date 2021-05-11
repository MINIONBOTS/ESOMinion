-- Skillmanager for adv. skill customization

-- CanAbilityBeUsedFromHotbar(number abilityId, number HotBarCategory hotbarCategory)
   -- Returns: boolean canBeUsed 
   
--[[ fix ui list

trg
skill
	.used
	.name
	.id
	.prio
	.minrange
	.maxrange
	.previd
	.nprevid
	.ptrg
	.combat
	.throttle
	.timelastused
	
	health
	.phpgt
	.phplt
	
	.powertype
	.ppowgt
	.ppowlt
	
	.pbuffthis
	.pnbuffthis
	.tbuffthis
	.tnbuffthis
	
	.pbuff
	.pnbuff
	.tbuff
	.tnbuff
	
	target hp
	.thpgt
	.thplt
	
	casting
	.iscasting
	
	aoe
	.tecount
	.tecount2
	.terange
	
	ally aoe
	.tacount
	.tarange
	
]]
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
eso_skillmanager.SkillProfiles = {"None"}
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
	-- basic
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
	
	SKM_THROTTLE = { default = 0, cast = "number", profile = "throttle", section = "fighting" },  
	-- player
	SKM_PHPGT = { default = 0, cast = "number", profile = "phpgt", section = "fighting"   },
	SKM_PHPLT = { default = 0, cast = "number", profile = "phplt", section = "fighting"   },
	SKM_POWERTYPE = { default = "Magicka", cast = "string", profile = "powertype", section = "fighting"},
	SKM_PPowGT = { default = 0, cast = "number", profile = "ppowgt", section = "fighting"   },
	SKM_PPowLT = { default = 0, cast = "number", profile = "ppowlt", section = "fighting"   },
	
	-- target
	SKM_TRG = { default = "Target", cast = "string", profile = "trg", section = "fighting"  },
	SKM_THPGT = { default = 0, cast = "number", profile = "thpgt", section = "fighting"  },
	SKM_THPLT = { default = 0, cast = "number", profile = "thplt", section = "fighting"  },
	SKM_THPCGT = { default = 0, cast = "number", profile = "thpcgt", section = "fighting"  },
	SKM_THPCLT = { default = 0, cast = "number", profile = "thpclt", section = "fighting"  },
	SKM_THPADV = { default = 0, cast = "number", profile = "thpadv", section = "fighting"  },
	
	-- aoe count
	SKM_TECount = { default = 0, cast = "number", profile = "tecount", section = "fighting"  },
	SKM_TECount2 = { default = 0, cast = "number", profile = "tecount2", section = "fighting" },
	SKM_TERange = { default = 0, cast = "number", profile = "terange", section = "fighting"  },
	
	 -------Skill Chains
	SKM_PSkillID = { default = "", cast = "string", profile = "pskill", section = "fighting"  },
	SKM_NPSkillID = { default = "", cast = "string", profile = "npskill", section = "fighting"  },
	SKM_PCSkillID = { default = "", cast = "string", profile = "pcskill", section = "fighting"  },
	SKM_NPCSkillID = { default = "", cast = "string", profile = "npcskill", section = "fighting"  },
	SKM_NSkillID = { default = "", cast = "string", profile = "nskill", section = "fighting"  },
	SKM_NSkillPrio = { default = "", cast = "string", profile = "nskillprio", section = "fighting"  },
	
	SKM_PHPL = { default = 0, cast = "number", profile = "phpl", section = "fighting"   },
	SKM_PHPB = { default = 0, cast = "number", profile = "phpb", section = "fighting"   },
	SKM_PUnderAttack = { default = false, cast = "boolean", profile = "punderattack", section = "fighting"  },
	SKM_PUnderAttackMelee = { default = false, cast = "boolean", profile = "punderattackmelee", section = "fighting"  },
	SKM_PPowL = { default = 0, cast = "number", profile = "ppowl", section = "fighting"   },
	SKM_PPowB = { default = 0, cast = "number", profile = "ppowb", section = "fighting"   },
	SKM_PMPPL = { default = 0, cast = "number", profile = "pmppl", section = "fighting"   },
	SKM_PMPPB = { default = 0, cast = "number", profile = "pmppb", section = "fighting"   },
	

	--SKM_OnlySolo = { default = "0", cast = "string", profile = "onlysolo", section = "fighting"  },
	--SKM_OnlyParty = { default = "0", cast = "string", profile = "onlyparty", section = "fighting"  },
	
	--[[ -------Dynamic Filters
	SKM_FilterOne = { default = "Ignore", cast = "string", profile = "filterone", section = "fighting"  },
	SKM_FilterTwo = { default = "Ignore", cast = "string", profile = "filtertwo", section = "fighting"  },
	SKM_FilterThree = { default = "Ignore", cast = "string", profile = "filterthree", section = "fighting"  },
	SKM_FilterFour = { default = "Ignore", cast = "string", profile = "filterfour", section = "fighting"  },
	SKM_FilterFive = { default = "Ignore", cast = "string", profile = "filterfive", section = "fighting"  },
	--]]
	
	--[[ -------Party
	SKM_HPRIOHP = { default = false, cast = "number", profile = "hpriohp", section = "fighting"  },
	SKM_HPRIO1 = { default = "None", cast = "string", profile = "hprio1", section = "fighting"  },
	SKM_HPRIO2 = { default = "None", cast = "string", profile = "hprio2", section = "fighting"  },
	SKM_HPRIO3 = { default = "None", cast = "string", profile = "hprio3", section = "fighting"  },
	SKM_HPRIO4 = { default = "None", cast = "string", profile = "hprio4", section = "fighting"  },
	--]]
	
	--[[ -------Party
	SKM_PTCount = { default = false, cast = "number", profile = "ptcount", section = "fighting"   },
	SKM_PTHPL = { default = false, cast = "number", profile = "pthpl", section = "fighting"   },
	SKM_PTHPB = { default = false, cast = "number", profile = "pthpb", section = "fighting"   },
	SKM_PTMPL = { default = false, cast = "number", profile = "ptmpl", section = "fighting"   },
	SKM_PTMPB = { default = false, cast = "number", profile = "ptmpb", section = "fighting"   },
	SKM_PTTPL = { default = false, cast = "number", profile = "pttpl", section = "fighting"   },
	SKM_PTTPB = { default = false, cast = "number", profile = "pttpb", section = "fighting"   },
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
		
	SKM_TBuffThis = { default = "", cast = "string", profile = "tbuffthis", section = "fighting"  },
	SKM_TBuff = { default = "", cast = "string", profile = "tbuff", section = "fighting"  },
	SKM_TNBuffThis = { default = "", cast = "string", profile = "tnbuffthis", section = "fighting"  },
	SKM_TNBuff = { default = "", cast = "string", profile = "tnbuff", section = "fighting"  },
	
	
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

	for varname,info in pairs(eso_skillmanager.Variables) do
		_G[varname] = info.default
	end
	
	local uuid = GetUUID()
	
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
	
	gSMBattleStatuses = { GetString("In Combat"), GetString("Out of Combat"), GetString("Any") }
	gSMBattleStatusIndex = 1
	gSMBattlePowerTypes = {"Magicka","Stamina","Ultimate"}
	gSMBattlePowerTypeIndex = 1
	
	eso_skillmanager.UpdateProfiles()
	eso_skillmanager.UseDefaultProfile()
	eso_skillmanager.AddDefaultConditions()
	gSkillProfileNewIndex = 1
	gSMlastprofileNew = esominion.GetSetting("gSMlastprofileNew","None")
	gSMprofile = esominion.GetSetting("gSMprofile","None")
	gSkillProfileNewIndex = GetKeyByValue(gSMlastprofileNew,eso_skillmanager.SkillProfiles)
	
	gSkillManagerPrefered = esominion.GetSetting("gSkillManagerPrefered",{})
	
end

function eso_skillmanager.CheckPreferedList(weaponID)
	d("check prefered skillProfiles")
	if table.valid(gSkillManagerPrefered) then
		if weaponID ~= 0 then
			local checkProfile = gSkillManagerPrefered[weaponID]
			if checkProfile then
				local newval = GetKeyByValue(checkProfile,eso_skillmanager.SkillProfiles)
				if newval then
					gSkillProfileNewIndex = newval
					Settings.ESOMinion.gSkillProfileNewIndex = newval
					Settings.ESOMinion.gSMlastprofileNew = checkProfile
					
					gSMprofile = checkProfile
					Settings.ESOMinion.gSMprofile = checkProfile
					eso_skillmanager.ReadFile(checkProfile)
				end
			end
		end
	end
end
function eso_skillmanager.SetPreferedList()
	d("Set prefered skillProfiles")
	local weaponID = e("GetSlotBoundId(1)")
	d("Weapon ["..tostring(weaponID).."] set to prefered ["..tostring(gSMprofile).."]")
	gSkillManagerPrefered[weaponID] = gSMprofile
	Settings.ESOMinion.gSkillManagerPrefered = gSkillManagerPrefered
end

function eso_skillmanager.GUIVarUpdate(Event, NewVals, OldVals)
    for k,v in pairs(NewVals) do
        if ( k == "gSMprofile" ) then
            gSMactive = "1"					
			
            --GUI_WindowVisible(eso_skillmanager.editwindow.name,false)		
            --GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
            eso_skillmanager.UpdateCurrentProfileData()
			Settings.ESOMinion["gSMlastprofileNew"] = v
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
	Settings.ESOMinion.gSMlastprofileNew = strName
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
		Settings.ESOMinion.gSMlastprofileNew = filename
		
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
            if ( Settings.ESOMinion.gSMlastprofileNew ~= nil and Settings.ESOMinion.gSMlastprofileNew == profile ) then
                found = profile
            end
			table.insert(eso_skillmanager.SkillProfiles,profile)
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
	d("build new skill list")
	eso_skillmanager.lastskillidcheck = e("GetSlotBoundId(1)")
	for i = 1,33 do
		local skillid = e("GetAbilityIdByIndex("..i..")")
		local skillName, skillTexture, skillRank, skillSlotType, skillpassive, skillVisable = e("GetAbilityInfoByIndex("..i..")")
		local skillRangemin, skillRangemax = e("GetAbilityRange("..skillid..")")
		local skillRange = skillRangemax / 100
		local skillChanneled, skillCastTime, skillChannelTime = e("GetAbilityCastInfo("..skillid..")")
		eso_skillmanager.skillsbyindex[i] = {id = skillid, index = i ,name = skillName, rank = skillRank, type = skillSlotType, passive = skillpassive, visable = skillVisable, range = skillRange, ischanneled = skillChanneled, casttime = skillChannelTime, channeltime = skillChannelTime}
		eso_skillmanager.skillsbyid[skillid] = {id = skillid, index = i ,name = skillName, rank = skillRank, type = skillSlotType, passive = skillpassive, visable = skillVisable, range = skillRange, ischanneled = skillChanneled, casttime = skillChannelTime, channeltime = skillChannelTime}
		eso_skillmanager.skillsbyname[skillName] = {id = skillid, index = i ,name = skillName, rank = skillRank, type = skillSlotType, passive = skillpassive, visable = skillVisable, range = skillRange, ischanneled = skillChanneled, casttime = skillChannelTime, channeltime = skillChannelTime}
		
		ml_global_information.AttackRange = math.max(skillRange,ml_global_information.AttackRange)
	end
	return eso_skillmanager.skillsbyindex
end
--+Rebuilds the UI Entries for the SkillbookList
function eso_skillmanager.RefreshSkillBook()
    local SkillList = nil
	if eso_skillmanager.lastskillidcheck ~= e("GetSlotBoundId(1)") then 	
		SkillList = eso_skillmanager.BuildSkillsList()
	else
		SkillList = eso_skillmanager.skillsbyindex
	end
	
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
	if (not entity) then
		return false
	end
	if (Now() < eso_skillmanager.latencyTimer) then
		return false
	end
	--local pBuffCount = e(GetNumBuffs("player"))
	local pBuffs = {}
	--[[if pBuffCount > 0 then
		for i = 1 , pBuffCount do
			table.insert(pBuffs,e(GetUnitBuffInfo("player"),i))
		end
	end]]
	
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
	}
	eso_skillmanager.AddConditional(conditional)]]
	
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
			if (( skill.ptrg == "Enemy" and (not target or not target.attackable)) or -- check this
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
		
		if ((tonumber(skill.phpgt) > 0 and tonumber(skill.phpgt) > Player.health.percent)	or 
			(tonumber(skill.phplt) > 0 and tonumber(skill.phplt) < Player.health.percent))
		then
			return true
		end
		
		if (skill.powertype == "Magicka") then
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > Player.magika.percent)	or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < Player.magika.percent))
			then 
				return true
			end
		elseif (skill.powertype == "Stamina") then
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > Player.stamina.percent)	or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < Player.stamina.percent))
			then 
				return true
			end
		--[[elseif (skill.powertype == "Ultimate") then
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > ml_global_information.Player_Ultimate.percent)	or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < ml_global_information.Player_Ultimate.percent))
			then 
				return true
			end]]
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
	}
	eso_skillmanager.AddConditional(conditional)]]
	
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
	}
	eso_skillmanager.AddConditional(conditional)]]
	
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
	}
	eso_skillmanager.AddConditional(conditional)]]
	
	conditional = { name = "Target HP Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		local thpgt = tonumber(skill.thpgt) or 0
		local thplt = tonumber(skill.thplt) or 0
		local thpadv = tonumber(skill.thpadv) or 0
		
		if thpadv > 0  then
			if  target.health.max < Player.hp.max * thpadv then
				return false
			end
		end
		if ((thpgt > 0 and thpgt > target.health.percent) or
			(thplt > 0 and thplt < target.health.percent)) then 
			return true 
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	--[[conditional = { name = "Target Casting Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		
		if ( skill.iscasting == "1" and not (target.iscasting) ) then 
			return false 
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)]]
	
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
			if (gPreventAttackingInnocents) then
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
	
	--[[conditional = { name = "Ally AOE Checks"	
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
	eso_skillmanager.AddConditional(conditional)]]
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
				
		if (table.valid(eso_skillmanager.SkillBook)) then
			for key, skillInfo in spairs(eso_skillmanager.SkillBook) do
				if ( GUI:Button(skillInfo.name.." ["..tostring(skillInfo.id).."]",width,20)) then
					eso_skillmanager.AddSkillToProfile(skillInfo.id)
					eso_skillmanager.SaveProfile()
				
				end
			end
		else
			eso_skillmanager.SkillBook = eso_skillmanager.BuildSkillsList()
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
				GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("ID")); GUI:NextColumn(); GUI:Text(skill.skillID); GUI:NextColumn();	
				
				GUI:Columns(1)
				
				eso_skillmanager.DrawBattleEditor(skill)
			end
		end
		GUI:End()
	end
end

function eso_skillmanager.Draw()
	local gamestate = GetGameState()
	if (gamestate == ESO.GAMESTATE.INGAME) then

		if ( eso_skillmanager.GUI.skillbook.open ) then 
		
			eso_skillmanager.DrawSkillBook()

		
			GUI:SetNextWindowSize(250,400,GUI.SetCond_Once) --set the next window size, only on first ever	
			GUI:SetNextWindowCollapsed(false,GUI.SetCond_Once)
			
			local winBG = GUI:GetStyle().colors[GUI.Col_WindowBg]
			GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], (255/255))
			
			eso_skillmanager.GUI.profile.visible, eso_skillmanager.GUI.profile.open = GUI:Begin(eso_skillmanager.GUI.profile.name, eso_skillmanager.GUI.profile.open)
			
			local contentwidth = GUI:GetContentRegionAvailWidth()
			if table.valid(eso_skillmanager.SkillProfile) then
			
			
				GUI:Spacing() GUI:Spacing() GUI:Spacing() GUI:Spacing()
				
				if (GUI:Button("Set Weapon Prefered Profile",contentwidth,20)) then -- skill to edit
					eso_skillmanager.SetPreferedList()
				end
				
				GUI:Spacing() GUI:Spacing() GUI:Spacing() GUI:Spacing()
				GUI:Separator()
				GUI:Spacing() GUI:Spacing() GUI:Spacing() GUI:Spacing()
				for prio,skillInfo in spairs(eso_skillmanager.SkillProfile) do
				
					if (GUI:Button(skillInfo.name,contentwidth,20)) then -- skill to edit
					end
						
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(0)) then
							eso_skillmanager.GUI.skillbook.id = prio
							eso_skillmanager.EditSkill(prio)
							eso_skillmanager.GUI.editor.open = true
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
end

function eso_skillmanager.DrawBattleEditor(skill)
	
	if (GUI:CollapsingHeader("Basic","battle-basic-header")) then
		GUI:Columns(2,"#battle-basic-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Combat Status")); GUI:NextColumn(); SKM_Combo("##SKM_Combat","gSMBattleStatusIndex","SKM_Combat",gSMBattleStatuses); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); eso_skillmanager.DrawLineItem{control = "int", name = "minRange", variable = "SKM_MinR", width = 50, tooltip = "Minimum range the skill can be used (For most skills, this will stay at 0)."}
		GUI:AlignFirstTextHeightToWidgets(); eso_skillmanager.DrawLineItem{control = "int", name = "maxRange", variable = "SKM_MaxR", width = 50, tooltip = "Maximum range the skill can be used."}
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("prevComboSkill")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill is part of a combo, enter the ID of the skill that should be executed immediately before this one.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PCSkillID",SKM_PCSkillID),"SKM_PCSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("prevComboSkillNot")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill is part of a combo, enter the ID of the skill that should NOT be executed immediately before this one.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_NPCSkillID",SKM_NPCSkillID),"SKM_NPCSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous Skill")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should be used immediately after another skill that is not on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PSkillID",SKM_PSkillID),"SKM_PSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous Skill NOT")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should NOT be used immediately after another skill that is not on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_NPSkillID",SKM_NPSkillID),"SKM_NPSkillID"); GUI:NextColumn();
		GUI:Columns(1)
	end
	
	
	if (GUI:CollapsingHeader(GetString("Player Stats"),"battle-playerhp-header")) then
		GUI:Columns(2,"#battle-playerhp-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP %% >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player HP is greater than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHPGT",SKM_PHPGT,0,0),"SKM_PHPGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP %% <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player HP is less than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHPLT",SKM_PHPLT,0,0),"SKM_PHPLT"); GUI:NextColumn();
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power Type")); GUI:NextColumn(); SKM_Combo("##SKM_POWERTYPE","gSMBattlePowerTypeIndex","SKM_POWERTYPE",gSMBattlePowerTypes); GUI:NextColumn();
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power %% >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player Power is more than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PPowGT",SKM_PPowGT,0,0),"SKM_PPowGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power %% <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player Power is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PPowLT",SKM_PPowLT,0,0),"SKM_PPowLT"); GUI:NextColumn();
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("Target Stats"),"battle-target-header")) then
		GUI:Columns(2,"#battle-target-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		
		GUI:Text(GetString("Target HP %% >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is greater than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPGT",SKM_THPGT,0,0),"SKM_THPGT"); GUI:NextColumn();
		GUI:Text(GetString("Target HP %% <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is less than this percentage.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPLT",SKM_THPLT,0,0),"SKM_THPLT"); GUI:NextColumn();
		GUI:Text(GetString("Target HP Current >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPCGT",SKM_THPCGT,0,0),"SKM_THPCGT"); GUI:NextColumn();
		GUI:Text(GetString("Target HP Current <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the HP of the Target is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THPCLT",SKM_THPCLT,0,0),"SKM_THPCLT"); GUI:NextColumn();
		GUI:Text(GetString("HP Advantage")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the difference of Max HP between you and an enemy is greater than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputFloat("##SKM_THPADV",SKM_THPADV,0,0,2),"SKM_THPADV"); GUI:NextColumn();
		
		GUI:PopItemWidth()
		GUI:Columns(1)
	end
	--[[if (GUI:CollapsingHeader(GetString("Party"),"battle-party-header")) then
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
		GUI:PopItemWidth()
		GUI:Columns(1)
	end]]
	
	
	if (GUI:CollapsingHeader(GetString("aoe"),"battle-aoe-header")) then
		GUI:Columns(2,"#battle-aoe-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("Enemy Count >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of enemies is greater than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TECount",SKM_TECount,0,0),"SKM_TECount"); GUI:NextColumn();
		GUI:Text(GetString("Enemy Count <=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of enemies is less than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TECount2",SKM_TECount2,0,0),"SKM_TECount2"); GUI:NextColumn();
		GUI:Text(GetString("Radius")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when enemies are within this range (150 = size of the minimap).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TERange",SKM_TERange,0,0),"SKM_TERange"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("playerBuffs"),"battle-playerbuffs-header")) then
		GUI:Columns(2,"#battle-playerbuffs-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("skmHasBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Player is being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PBuff",SKM_PBuff),"SKM_PBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmMissBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Player is not being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PNBuff",SKM_PNBuff),"SKM_PNBuff"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("targetBuffs"),"battle-targetbuffs-header")) then
		GUI:Columns(2,"#battle-targetbuffs-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		GUI:Text(GetString("skmHasBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Target is being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TBuff",SKM_TBuff),"SKM_TBuff"); GUI:NextColumn();
		GUI:Text(GetString("skmMissBuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Target is not being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TNBuff",SKM_TNBuff),"SKM_TNBuff"); GUI:NextColumn();
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
