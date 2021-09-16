-- Skillmanager for adv. skill customization

-- CanAbilityBeUsedFromHotbar(number abilityId, number HotBarCategory hotbarCategory)
   -- Returns: boolean canBeUsed 
   
eso_skillmanager = {}
eso_skillmanager.version = "2.0";
eso_skillmanager.lastTick = 0
eso_skillmanager.debug = 0
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
eso_skillmanager.ComboSkillID = ""
eso_skillmanager.prevSkillList = {}
eso_skillmanager.copiedSkill = {}
eso_skillmanager.bestAOE = 0
eso_skillmanager.latencyTimer = 0
eso_skillmanager.resetTimer = 0
eso_skillmanager.doLoad = true
gSkillManagerDebugPriorities = ""
eso_skillmanager.lastAvoid = 0
eso_skillmanager.lastBreak = 0
eso_skillmanager.lastInterrupt = 0
eso_skillmanager.needsrebuild = true

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
eso_skillmanager.skillsearchstring = ""
eso_skillmanager.activeSkillsBar = {}
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
	[4] = "Warden",
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
eso_skillmanager.SummonSkills = {
	[23634] = "Summon Storm Atronach",
	[23636] = "Summon Storm Atronach",
	[23639] = "Summon Storm Atronach",
	[23662] = "Greater Storm Atronach",
	[23663] = "Greater Storm Atronach",
	[23666] = "Summon Charged Atronach",
	[23668] = "Summon Charged Atronach",
	[23669] = "Summon Charged Atronach",
	[23641] = "Volatile Familiar",
	[23644] = "Unstable Clannfear",
	[85982] = "Feral Guardian",
	[85986] = "Eternal Guardian",
	[85990] = "Wild Guardian",

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
	SKM_Swap = { default = false, cast = "boolean", profile = "forceswap", section = "fighting"  },
	SKM_Summon = { default = false, cast = "boolean", profile = "summonskill", section = "fighting"  },
	SKM_CASTTIME = { default = 0, cast = "number", profile = "casttime", section = "fighting"   },
	SKM_MinR = { default = 0, cast = "number", profile = "minRange", section = "fighting"   },
	SKM_MaxR = { default = 30, cast = "number", profile = "maxRange", section = "fighting"   },
	
	SKM_THROTTLE = { default = 0, cast = "number", profile = "throttle", section = "fighting" },  
	-- player
	SKM_PHPGT = { default = 0, cast = "number", profile = "phpgt", section = "fighting"   },
	SKM_PHPLT = { default = 0, cast = "number", profile = "phplt", section = "fighting"   },
	SKM_PHPEQ = { default = 0, cast = "number", profile = "phpeq", section = "fighting"   },
	SKM_PHCGT = { default = 0, cast = "number", profile = "phcgt", section = "fighting"   },
	SKM_PHCLT = { default = 0, cast = "number", profile = "phclt", section = "fighting"   },
	SKM_PHCEQ = { default = 0, cast = "number", profile = "phceq", section = "fighting"   },
	SKM_POWERTYPE = { default = "Magicka", cast = "string", profile = "powertype", section = "fighting"},
	SKM_PPowGT = { default = 0, cast = "number", profile = "ppowgt", section = "fighting"   },
	SKM_PPowLT = { default = 0, cast = "number", profile = "ppowlt", section = "fighting"   },
	SKM_PPowEQ = { default = 0, cast = "number", profile = "ppoweq", section = "fighting"   },
	SKM_PCowGT = { default = 0, cast = "number", profile = "pcowgt", section = "fighting"   },
	SKM_PCowLT = { default = 0, cast = "number", profile = "pcowlt", section = "fighting"   },
	SKM_PCowEQ = { default = 0, cast = "number", profile = "pcoweq", section = "fighting"   },
	
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
	
	 ------- Target Casting
	SKM_TCASTID = { default = "", cast = "string", profile = "tcastids", section = "fighting"  },
	SKM_TCASTTM = { default = "0", cast = "string", profile = "tcastonme", section = "fighting"  },
	SKM_TCASTTIME = { default = "0.0", cast = "string", profile = "tcasttime", section = "fighting"  },
	
	
	SKM_PBuffThis = { default = false, cast = "boolean", profile = "pbuffthis", section = "fighting"  },
	SKM_PBuff = { default = "", cast = "string", profile = "pbuff", section = "fighting"  },
	SKM_PNBuffThis = { default = false, cast = "boolean", profile = "pnbuffthis", section = "fighting"  },
	SKM_PNBuff = { default = "", cast = "string", profile = "pnbuff", section = "fighting"  },
	SKM_PBuffCount = { default = 0, cast = "number", profile = "pbuffc", section = "fighting"   },
	SKM_PDBuffCount = { default = 0, cast = "number", profile = "pdbuffc", section = "fighting"   },
		
	SKM_TBuffThis = { default = false, cast = "boolean", profile = "tbuffthis", section = "fighting"  },
	SKM_TBuff = { default = "", cast = "string", profile = "tbuff", section = "fighting"  },
	SKM_TNBuffThis = { default = false, cast = "boolean", profile = "tnbuffthis", section = "fighting"  },
	SKM_TNBuff = { default = "", cast = "string", profile = "tnbuff", section = "fighting"  },
	SKM_TBuffCount = { default = 0, cast = "number", profile = "tbuffc", section = "fighting"   },
	SKM_TDBuffCount = { default = 0, cast = "number", profile = "tdbuffc", section = "fighting"   },
	
	
	
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
	
	if (Settings.ESOMINION.SMDefaultProfiles == nil) then
		Settings.ESOMINION.SMDefaultProfiles = {}
	end	
	if (Settings.ESOMINION.SMDefaultProfiles[1] == nil) then
		Settings.ESOMINION.SMDefaultProfiles[1] = "DragonKnight"
	end
	if (Settings.ESOMINION.SMDefaultProfiles[2] == nil) then
		Settings.ESOMINION.SMDefaultProfiles[2] = "Sorcerer"
	end
	if (Settings.ESOMINION.SMDefaultProfiles[3] == nil) then
		Settings.ESOMINION.SMDefaultProfiles[3] = "Nightblade"
	end
	if (Settings.ESOMINION.SMDefaultProfiles[4] == nil) then
		Settings.ESOMINION.SMDefaultProfiles[4] = "Warden"
	end
	if (Settings.ESOMINION.SMDefaultProfiles[6] == nil) then
		Settings.ESOMINION.SMDefaultProfiles[6] = "Templar"
	end
	
	gSMBattleStatuses = { GetString("In Combat"), GetString("Out of Combat"), GetString("Any") }
	gSMBattleStatusIndex = 1
	gSMBattlePowerTypes = {"Magicka","Stamina","Ultimate"}
	gSMBattlePowerTypeIndex = 1
	
	gSKMFilter = esominion.GetSetting("gSKMFilter",false)
	gSKMWeaveDelay = esominion.GetSetting("gSKMWeaveDelay",100)
	
	eso_skillmanager.UpdateProfiles()
	eso_skillmanager.UseDefaultProfile()
	eso_skillmanager.AddDefaultConditions()
	
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
					Settings.ESOMINION.gSkillProfileNewIndex = newval
					Settings.ESOMINION.gSMlastprofileNew = checkProfile
					
					gSMprofile = checkProfile
					Settings.ESOMINION.gSMprofile = checkProfile
					eso_skillmanager.ReadFile(checkProfile)
				end
			end
		end
	end
end
--[[
function eso_skillmanager.SetPreferedList()
	d("Set prefered skillProfiles")
	local weaponID = e("GetSlotBoundId(1)")
	d("Weapon ["..tostring(weaponID).."] set to prefered ["..tostring(gSMprofile).."]")
	gSkillManagerPrefered[weaponID] = gSMprofile
	Settings.ESOMINION.gSkillManagerPrefered = gSkillManagerPrefered
end]]

function eso_skillmanager.OnUpdate( event, tickcount )
	
	
	if (GetGameState() == ESO.GAMESTATE.INGAME) then
		if (eso_skillmanager.doLoad == true) then
			eso_skillmanager.ModuleInit() 
			eso_skillmanager.UpdateCurrentProfileData()
			eso_skillmanager.doLoad = false
		end
	end
	
	if ((tickcount - eso_skillmanager.lastTick) > 100) then
		eso_skillmanager.lastTick = tickcount
		
		if (eso_skillmanager.resetTimer ~= 0 and Now() > eso_skillmanager.resetTimer) then
			eso_skillmanager.ComboSkillID = ""
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
	Settings.ESOMINION.gSMlastprofileNew = strName
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

function eso_skillmanager.AddProfilePrompt()
	local vars = {
		height = 200,
		width = 450,
		{
			["type"] = "string",
			["var"] = "gSMnewname",
			["display"] = "##new-profile",
			["width"] = 300,
		},
		{
			["type"] = "spacing",
			["amount"] = 3,
		},
		{
			["type"] = "button",
			["display"] = "OK",
			["isdefault"] = true,
			["sameline"] = true,
			["amount"] = 50,
			["width"] = 100,
			["onclick"] = function ()
				if gSMnewname ~= "" then
				d("gSMnewname")
				d(gSMnewname)
					Settings.ESOMINION.gSMlastprofileNew = gSMnewname
					eso_skillmanager.NewProfile()
					GUI:CloseCurrentPopup()
					eso_skillmanager.UpdateProfiles()
					d("gSMprofile")
					d(gSMprofile)
					eso_skillmanager.UseProfile(gSMprofile)
					eso_skillmanager.SetDefaultProfile(gSMprofile)
				else
					eso_dialog_manager.IssueNotice("Profile Name##SKM", "Please pick a name for the new profile.")
				end
			end,
		},
		{
			["type"] = "button",
			["display"] = "Cancel",
			["width"] = 100,
			["onclick"] = function ()
				GUI:CloseCurrentPopup()
			end,
		},
	}
	eso_dialog_manager.IssueNotice("New List##SKM", "Please pick a name for the new profile.", "none", vars)
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
		Settings.ESOMINION.gSMlastprofileNew = filename
		
		eso_skillmanager.WriteToFile(filename)
    elseif (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
        filename = gSMprofile
        gSMnewname = ""		
		
		eso_skillmanager.WriteToFile(filename)
    end
end

function eso_skillmanager.SetDefaultProfile(strName)
	local profile = strName or gSMprofile
	local classid = ml_global_information.CurrentClass
	Settings.ESOMINION.SMDefaultProfiles[classid] = profile
	Settings.ESOMINION.SMDefaultProfiles = Settings.ESOMINION.SMDefaultProfiles
end

function eso_skillmanager.UseDefaultProfile()
	local defaultTable = Settings.ESOMINION.SMDefaultProfiles
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
			local starterDefaultFile = eso_skillmanager.profilepath..starterDefault..".lua"
			if (FileExists(starterDefaultFile)) then
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
	eso_skillmanager.SkillProfiles = {"None"}
    local profilelist = dirlist(eso_skillmanager.profilepath,".*lua")
    if ( TableSize(profilelist) > 0) then			
        local i,profile = next ( profilelist)
        while i and profile do				
            profile = string.gsub(profile, ".lua", "")
            profiles = profiles..","..profile
            if ( Settings.ESOMINION.gSMlastprofileNew ~= nil and Settings.ESOMINION.gSMlastprofileNew == profile and Settings.ESOMINION.gSMlastprofileNew ~= "") then
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
		eso_skillmanager.SkillProfile = {}
		eso_skillmanager.ReadFile(profile)
		eso_skillmanager.RefreshSkillList()
		gSkillProfileNewIndex = GetKeyByValue(gSMprofile,eso_skillmanager.SkillProfiles)
	end
end
eso_skillmanager.mandatoryskills = {
	[61874] = true,
	[61875] = true,
}
function eso_skillmanager.BuildSkillsBook()
	d("build new skill book")
	local list = {}
	eso_skillmanager.skillsbyindex = {}
	eso_skillmanager.skillsbyid = {}
	eso_skillmanager.skillsbyname = {}
	if not gSKMFilter then
		for i = 1,100 do
			local skillid = e("GetAbilityIdByIndex("..i..")")
			if skillid ~= 0 then
				local skillData = AbilityList:Get(skillid)
				if skillData then
					list[i] = skillData
					eso_skillmanager.skillsbyid[skillid] = skillData
					eso_skillmanager.skillsbyname[skillData.name] = skillData
				
					if string.contains(skillData.name,"Light Attack") then
						eso_skillmanager.skillsbyname["Default"] = skillData
					end
					if string.contains(skillData.name,"Heavy Attack") then
						eso_skillmanager.skillsbyname["DefaultHeavy"] = skillData
					end
					ml_global_information.AttackRange = math.max(skillData.range,ml_global_information.AttackRange)
				end
			end
		end
	end
	for i,bool in pairs(eso_skillmanager.mandatoryskills) do
		local skillid = i
		if skillid ~= 0 then
			local skillData = AbilityList:Get(skillid)
			if skillData then
				list[i] = skillData
				eso_skillmanager.skillsbyid[skillid] = skillData
				eso_skillmanager.skillsbyname[skillData.name] = skillData
			
				if string.contains(skillData.name,"Light Attack") then
					eso_skillmanager.skillsbyname["Default"] = skillData
				end
				if string.contains(skillData.name,"Heavy Attack") then
					eso_skillmanager.skillsbyname["DefaultHeavy"] = skillData
				end
				ml_global_information.AttackRange = math.max(skillData.range,ml_global_information.AttackRange)
			end
		end
	end
	
	--[[local skillList = AbilityList:Get() 
	if table.valid(skillList) then
		for skillid,skillData in pairs (skillList) do
			if not eso_skillmanager.skillsbyid[skillid] then
				table.insert(list,skillData)
			end
			eso_skillmanager.skillsbyid[skillid] = skillData
			eso_skillmanager.skillsbyname[skillData.name] = skillData
		
			if string.contains(skillData.name,"Light Attack") then
				eso_skillmanager.skillsbyname["Default"] = skillData
			end
			if string.contains(skillData.name,"Heavy Attack") then
				eso_skillmanager.skillsbyname["DefaultHeavy"] = skillData
			end
			ml_global_information.AttackRange = math.max(skillData.range,ml_global_information.AttackRange)
		end
	end]]
	
	for i = 1,8 do
		local skillid = AbilityList:GetSlotInfo(i,0) 
		if skillid ~= 0 then
			local skillData = AbilityList:Get(skillid)
			if skillData then
				if not eso_skillmanager.skillsbyid[skillid] then
					table.insert(list,skillData)
				end
				eso_skillmanager.skillsbyid[skillid] = skillData
				eso_skillmanager.skillsbyname[skillData.name] = skillData
			
				if string.contains(skillData.name,"Light Attack") then
					eso_skillmanager.skillsbyname["Default"] = skillData
				end
				if string.contains(skillData.name,"Heavy Attack") then
					eso_skillmanager.skillsbyname["DefaultHeavy"] = skillData
				end
				ml_global_information.AttackRange = math.max(skillData.range,ml_global_information.AttackRange)
			end
		end
		local skillid = AbilityList:GetSlotInfo(i,1) 
		if skillid ~= 0 then
			local skillData = AbilityList:Get(skillid)
			if skillData then
				if not eso_skillmanager.skillsbyid[skillid] then
					table.insert(list,skillData)
				end
				eso_skillmanager.skillsbyid[skillid] = skillData
				eso_skillmanager.skillsbyname[skillData.name] = skillData
			
				ml_global_information.AttackRange = math.max(skillData.range,ml_global_information.AttackRange)
			end
		end
	end
	if not gSKMFilter then
		for id,skill in pairs (eso_skillmanager.SummonSkills) do
			local skillid = id
			if skillid ~= 0 then
				local skillData = AbilityList:Get(skillid)
				if skillData then
					if not eso_skillmanager.skillsbyid[skillid] then
						table.insert(list,skillData)
					end
			
					eso_skillmanager.skillsbyid[skillid] = skillData
					eso_skillmanager.skillsbyname[skillData.name] = skillData
				end
			end
		end
	end
	if table.valid(list) then
		local added = {}
		for i,e in pairs(list) do
			if not added[e.id] then
				added[e.id] = true
				table.insert(eso_skillmanager.skillsbyindex,e)
			end
		end
	end
	return eso_skillmanager.skillsbyindex
end
function eso_skillmanager.BuildSkillsList()
	
	eso_skillmanager.activeSkillsBar = {}
	local activeHotbar = AbilityList:GetActiveHotBar()
	eso_skillmanager.skillsbyid = {}
	eso_skillmanager.skillsbyname = {}
	for i = 1,8 do
		local skillid = AbilityList:GetSlotInfo(i,0) 
		if skillid ~= 0 then
			local skillData = AbilityList:Get(skillid)
			if skillData then
		
				eso_skillmanager.skillsbyid[skillid] = skillData
				eso_skillmanager.skillsbyname[skillData.name] = skillData
			
				if activeHotbar == 0 then
					if string.contains(skillData.name,"Light Attack") then
						eso_skillmanager.skillsbyname["Default0"] = skillData
					end
					if string.contains(skillData.name,"Heavy Attack") then
						eso_skillmanager.skillsbyname["DefaultHeavy0"] = skillData
					end
				end
				eso_skillmanager.activeSkillsBar[skillid] = 0
				ml_global_information.AttackRange = math.max(skillData.range,ml_global_information.AttackRange)
			end
		end
	end
	
	for i = 1,8 do
		local skillid = AbilityList:GetSlotInfo(i,1) 
		if skillid ~= 0 then
			local skillData = AbilityList:Get(skillid)
			if skillData then
		
				eso_skillmanager.skillsbyid[skillid] = skillData
				eso_skillmanager.skillsbyname[skillData.name] = skillData
				if activeHotbar == 1 then
					if string.contains(skillData.name,"Light Attack") then
						eso_skillmanager.skillsbyname["Default1"] = skillData
					end
					if string.contains(skillData.name,"Heavy Attack") then
						eso_skillmanager.skillsbyname["DefaultHeavy1"] = skillData
					end
				end
				eso_skillmanager.activeSkillsBar[skillid] = 1
				ml_global_information.AttackRange = math.max(skillData.range,ml_global_information.AttackRange)
			end
		end
	end
	for id,skill in pairs (eso_skillmanager.SummonSkills) do
		local skillid = id
		if skillid ~= 0 then
			local skillData = AbilityList:Get(skillid)
			if skillData then
		
				eso_skillmanager.skillsbyid[skillid] = skillData
				eso_skillmanager.skillsbyname[skillData.name] = skillData
			end
		end
	end
	eso_skillmanager.needsrebuild = false
end

function eso_skillmanager.BuildAllSkills()
	local list = {}
		
	for i = 1,100000 do
		local skillid = i
		local skillName = e("GetAbilityName("..skillid..")")
		if skillName ~= "" and skillName ~= nil then      
			local skillRangemin, skillRangemax = e("GetAbilityRange("..skillid..")")
			local skillRange = skillRangemax / 100
			local skillChanneled, skillCastTime, skillChannelTime = e("GetAbilityCastInfo("..skillid..")")
			local skillCost = e("GetAbilityCost("..skillid..")") 
			local buffType = e("GetAbilityBuffType("..skillid..")")
			local skillPermanant = e("IsAbilityPermanent("..skillid..")")
			--GetSpecificSkillAbilityKeysByAbilityId(number abilityId)
			-- IsAbilityPermanent(number abilityId) 
			--CanAbilityBeUsedFromHotbar(number abilityId, number HotBarCategory hotbarCategory)
			
			list[skillid] = {id = skillid, name = skillName, cost = skillCost, range = skillRange, ischanneled = skillChanneled, casttime = skillCastTime, channeltime = skillChannelTime, bufftype = buffType, permanant = skillPermanant }
		end
	end
	if table.valid(list) then
		SaveToFileX(GetStartupPath()..[[\LuaMods\ESOMinion\skill_data_output.lua]],list)
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

eso_skillmanager.lastcast = 0
eso_skillmanager.lastdefault = 0
eso_skillmanager.rebuild = 0
eso_skillmanager.roll = false
function eso_skillmanager.Cast( entity )
	if (not entity) then
		return false
	end
	--if TimeSince(eso_skillmanager.lastdefault) < 1100 or not gSKMWeaving then	
		if (Now() < eso_skillmanager.latencyTimer) then
			return false
		end
	--end
	local activeHotbar = AbilityList:GetActiveHotBar()
	--if eso_skillmanager.needsrebuild then
		eso_skillmanager.BuildSkillsList()
	--end
	local defaultName = "Default"..tostring(activeHotbar)
	local defaultAttack = eso_skillmanager.skillsbyname[defaultName]
	if not defaultAttack then
		eso_skillmanager.BuildSkillsList()
		defaultAttack = eso_skillmanager.skillsbyname[defaultName]
	end
	if AbilityList:GetSlotInfo(1) ~= defaultAttack.id then
		eso_skillmanager.BuildSkillsList()
	end
	if eso_skillmanager.latencyTimer == 0 then
		local GCDRemain3,GCDDuration3 = AbilityList:GetSlotCooldownInfo(3,activeHotbar)
		local GCDRemain4,GCDDuration4 = AbilityList:GetSlotCooldownInfo(4,activeHotbar)
		local GCDRemain5,GCDDuration5 = AbilityList:GetSlotCooldownInfo(5,activeHotbar)
		local GCDRemain = GetHighestValue(GCDRemain3,GCDRemain4,GCDRemain5)
		
		if GCDRemain > 0 then
			local addRandom = GCDRemain + math.random(100,250)
			eso_skillmanager.latencyTimer = Now() + addRandom
			--d("add delay")
			--d(addRandom)
			return false
		end
	end
	BuildBuffsByIndex(entity.index)
	--Check for blocks/interrupts.
	local isAssistMode = (gBotMode == GetString("assistMode"))
	
	local tipTarget = entity
	if IsNull(esominion.activeTip,0) ~= 0 then
		local TargetList = MEntityList("hostile,aggro,maxdistance=50")
		if table.valid(TargetList) then
			for i,e in pairs (TargetList) do
				if e.castinfo and e.castinfo.timeleft > 0 and e.castinfo.timeleft < 1000 then
					tipTarget = e
					break
				end
			end
		end
	end
	local blockable = esominion.activeTip == eso_skillmanager.TIP_BLOCK
	if (blockable) then
		if (not isAssistMode or (isAssistMode and gAssistDoBlock)) then
			if tipTarget then
				if tipTarget.castinfo and tipTarget.castinfo.timeleft < 500 then
					d(tipTarget.castinfo.timeleft)
					d("Attempting block.")
					e("StartBlock()")
					local newTask = eso_task_block.Create()
					newTask.blockTarget = tipTarget.index
					ml_task_hub:CurrentTask():AddSubTask(newTask)
					return true
				else
					d("block target not casting")
				end
			else
				d("no block target")
			end
		end
	end
	
	local exploitable = esominion.activeTip == eso_skillmanager.TIP_EXPLOIT
	if (exploitable) then
		if (not isAssistMode or (isAssistMode and gAssistDoExploit)) then
			local heavyAttack = eso_skillmanager.skillsbyname["DefaultHeavy"]
			if heavyAttack then
				if ((tipTarget.distance and heavyAttack.range) and tipTarget.distance < heavyAttack.range) and (AbilityList:CanCast(heavyAttack.id,tipTarget.id) == 10) then
					AbilityList:Cast(heavyAttack.id,tipTarget.id)
					eso_skillmanager.latencyTimer = Now() + 600
					d("Attempting to exploit enemy with skill ID :"..tostring(tipTarget.id))
					return true
				end
			end
		end
	end
	
	local interruptable = esominion.activeTip == eso_skillmanager.TIP_INTERRUPT
	if (interruptable) then
		if (not isAssistMode or (isAssistMode and gAssistDoInterrupt)) then
			if (TimeSince(eso_skillmanager.lastInterrupt) > 1000) then
				e("PerformInterrupt()")
				eso_skillmanager.latencyTimer = Now() + 300
				eso_skillmanager.lastInterrupt = Now()
				d("Attempting to interrupt enemy.")
				return true
			end
		end
	end
	
	local interruptable = esominion.activeTip == eso_skillmanager.TIP_INTERRUPT2
	if (interruptable) then
		if (not isAssistMode or (isAssistMode and gAssistDoInterrupt)) then
			if (TimeSince(eso_skillmanager.lastInterrupt) > 1000) then
				e("PerformInterrupt()")
				eso_skillmanager.latencyTimer = Now() + 300
				eso_skillmanager.lastInterrupt = Now()
				d("Attempting to interrupt enemy attack.")
				return true
			end
		end
	end
		
	if gSKMWeaving then
		if TimeSince(eso_skillmanager.lastcast) > 2000 then
			eso_skillmanager.prevSkillID = 0
		end
		
		if eso_skillmanager.prevSkillID ~= defaultAttack.id then
			local canCast = AbilityList:CanCast(defaultAttack.id,entity.id)
			if (canCast == 10) and ((entity.distance and defaultAttack.range) and entity.distance < defaultAttack.range) then
				if AbilityList:Cast(defaultAttack.id,entity.id) then
					--d("Attempting to cast weaving ability ID : "..tostring(defaultAttack.id).." ["..tostring(defaultAttack.name).."]")
					--d("last skill cast was "..tostring(Now() - eso_skillmanager.lastcast))
					eso_skillmanager.prevSkillID = defaultAttack.id
					eso_skillmanager.lastdefault = Now()
					eso_skillmanager.latencyTimer = 0
					ml_global_information.nextRun = Now() + gSKMWeaveDelay
					return true
				end
			elseif canCast == -110 then -- stunned
				return false
			end
		end
	end

	if (ValidTable(eso_skillmanager.SkillProfile)) then
		for prio,skill in pairsByKeys(eso_skillmanager.SkillProfile) do
			local result = eso_skillmanager.CanCast(prio, entity)
			if (result ~= 0) then
			
			--check swapable before checking conditions
				local skillOnBar = eso_skillmanager.activeSkillsBar[skill.skillID]
				if skill.forceswap then
					
					if skillOnBar ~= nil then
						if activeHotbar ~= skillOnBar then
							-- swap bars
							d("need swap for skill ["..tostring(prio).."]")
							--[[if skillOnBar == 0 then
								if (AbilityList:Cast(61874,Player.id)) then
									d("swap weapon to bar 0")
								end
							elseif skillOnBar == 1 then
								if (AbilityList:Cast(61875,Player.id)) then
									d("swap weapon to bar 1")
								end
							end]]
							e("OnWeaponSwap()")
							eso_skillmanager.latencyTimer = 0
							ml_global_information.nextRun = Now() + 300
							 return true
						end
					end
				end
			
			
			
				local TID = result
				--local realID = tonumber(skill.skillID)
				local realID = eso_skillmanager.GetRealSkillID(skill.skillID)
				--local action = AbilityList:Get(realID)
				local canCast = AbilityList:CanCast(realID,TID)
				d("canCast = "..tostring(prio).." "..tostring(canCast))
				if canCast == 10 and activeHotbar == skillOnBar then
					if (AbilityList:Cast(realID,TID)) then
						--d("Attempting to cast ability ID : "..tostring(realID).." ["..tostring(skill.name).."]")
						skill.timelastused = Now() + 2000
						eso_skillmanager.prevSkillID = realID
						eso_skillmanager.ComboSkillID = realID
						eso_skillmanager.resetTimer = Now() + 4000
						if gSKMWeaving then
							eso_skillmanager.latencyTimer = 0
							--d("last skill weave was "..tostring(Now() - eso_skillmanager.lastdefault))
						else
							eso_skillmanager.latencyTimer = Now() + math.random(500,700)
						end
						--d("last skill cast was "..tostring(Now() - eso_skillmanager.lastcast))
						eso_skillmanager.lastcast = Now()
						return true
					end
				elseif canCast == -110 then -- stunned
					return false
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
	
	if (IsNull(gSkillManagerDebugPriorities,"") ~= "") then
		local priorityChecks = {}
		for priority in StringSplit(gSkillManagerDebugPriorities,",") do
			priorityChecks[tonumber(priority)] = true
		end
		if (priorityChecks[prio]) then
			d("[SkillManager] : " .. message)
		end
	end
end

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

function eso_skillmanager.CanCast(prio, entity)
	if (not entity) then
		return 0
	end
	
	--local gameCameraActive = e("IsGameCameraActive()")
	--local interactionCameraActive = e("IsInteractionCameraActive()")
	
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
	if (not realskilldata and not skill.summonskill) then 
		eso_skillmanager.DebugOutput( prio, "Ability failed safeness check for "..skill.name.."["..tostring(prio).."]" )
		--[[if string.contains(skill.name,"Light Attack") then
			eso_skillmanager.BuildSkillsBook()
			d("rebuild skills list fallback")
		end]]
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
    newinst.blockTarget = 0
	
    return newinst
end

function eso_task_block:Init()    
    self:AddTaskCheckCEs()
end

function eso_task_block:task_complete_eval()	
	local activeTip = esominion.activeTip == eso_skillmanager.TIP_BLOCK
	if (activeTip) then 
		local target = MGetEntity(self.blockTarget)
		if table.valid(target) then
		d("valid block target")		
			Player:SetFacing(target.pos,true)
		else
		d("no valid block target")		
		end
			
		return false
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
        eso_skillmanager.CaptureElement(GUI:Checkbox("##"..var,_G[var]),var)
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
		
		if (skill.enabled == false) then
			return true
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Swap Bar Check"
	, eval = function()	
		local activeHotbar = AbilityList:GetActiveHotBar()
		local skill = eso_skillmanager.CurrentSkill
		
		if (In(activeHotbar,0) and In(skill.id,61874)) then
			return true
		end
		if (In(activeHotbar,1) and In(skill.id,61875)) then
			return true
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Summon Skill Check"
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		
		if (skill.summonskill) then
			skill.trg = "Self"
			--[[if hasPet() then
				return true
			end]]
		end
		
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	
	conditional = { name = "Target Casting Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		local TID = eso_skillmanager.CurrentTID
		
		local casttime = tonumber(skill.tcasttime)
		if casttime == nil then casttime = 0 end
		
		if (( casttime > 0 or skill.tcastids ~= "")) then
			if (TableSize(target.castinginfo) == 0) then
				return true
			elseif target.castinginfo.timeleft == 0 then
				return true
			elseif (skill.tcastids == "" and casttime ~= nil) then
				if target.castinginfo.timeleft < casttime then
					return true
				end
			elseif (skill.tcastids ~= "") then					
				local isCasting = false	
				for castid in StringSplit(skill.tcastids,",") do	
					if castid == target.castinginfo.a0 then
						isCasting = true
					end
				end
				local ctid = (skill.tcastonme  and Player.id or nil)
				if ( not isCasting ) then
					return true
				end
			end
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	
	conditional = { name = "Skill Slotted Check"
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		
		if not (eso_skillmanager.skillsbyid[skill.skillID]) then
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
		if not skill.summonskill then
			if ((minRange > 0 and target.distance < skill.minRange) or
				(maxRange > 0 and target.distance > skill.maxRange))
			then
				return true
			end
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)

	conditional = { name = "Previous Skill ID Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		
		if ( not IsNullString(skill.pskill)) then
			if (not IsNullString(eso_skillmanager.ComboSkillID)) then
				for skillid in StringSplit(skill.pskill,",") do
					local realID = tonumber(skillid)
					if (tonumber(eso_skillmanager.ComboSkillID) == realID) then
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
		if (not IsNullString(skill.npskill)) then
			if (not IsNullString(eso_skillmanager.ComboSkillID)) then
				for skillid in StringSplit(skill.npskill,",") do
					local realID = tonumber(skillid)
					if (tonumber(eso_skillmanager.ComboSkillID) == realID) then
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

	 -- No Combat Status Checks yet.
	conditional = { name = "Combat Status Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		local preCombat = eso_skillmanager.preCombat
		
		if (((skill.combat == "Out of Combat") and (preCombat == false or esominion.incombat)) or
			((skill.combat == "In Combat") and (preCombat == true)) or
			((skill.combat == "In Combat") and not esominion.incombat and skill.trg ~= "Target") or
			((skill.combat == "In Combat") and not esominion.incombat and not target.attackable))
		then 
			return true
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	
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
		
		local throttle = tonumber(skill.throttle) * 1000 or 0
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
		if Player.health.percent > 0 then
			if ((tonumber(skill.phpgt) > 0 and tonumber(skill.phpgt) > Player.health.percent) or 
				(tonumber(skill.phplt) > 0 and tonumber(skill.phplt) < Player.health.percent) or 
				(tonumber(skill.phpeq) > 0 and tonumber(skill.phpeq) ~= Player.health.percent))
			then
				return true
			end
		end
		if Player.health.current > 0 then
			if ((tonumber(skill.phpgt) > 0 and tonumber(skill.phpgt) > Player.health.current) or 
				(tonumber(skill.phplt) > 0 and tonumber(skill.phplt) < Player.health.current) or 
				(tonumber(skill.phpeq) > 0 and tonumber(skill.phpeq) ~= Player.health.percent))
			then
				return true
			end
		end
		
		
		--https://i.imgur.com/ijmyVho.png
		if (skill.powertype == "Magicka") then -- cost type 0
			if Player.magicka.current < IsNull(eso_skillmanager.skillsbyid[skill.skillID].cost,0) then
				return true
			end
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > Player.magicka.percent) or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < Player.magicka.percent) or 
				(tonumber(skill.phpeq) > 0 and tonumber(skill.phpeq) ~= Player.magicka.percent))
			then 
				return true
			end
			if ((tonumber(skill.pcowgt) > 0 and tonumber(skill.pcowgt) > Player.magicka.current) or 
				(tonumber(skill.pcowlt) > 0 and tonumber(skill.pcowlt) < Player.magicka.current) or 
				(tonumber(skill.phpeq) > 0 and tonumber(skill.phpeq) ~= Player.magicka.current))
			then 
				return true
			end
		elseif (skill.powertype == "Stamina") then -- cost type 6
			if Player.stamina.current < IsNull(eso_skillmanager.skillsbyid[skill.skillID].cost,0) then
				return true
			end
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > Player.stamina.percent) or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < Player.stamina.percent) or 
				(tonumber(skill.ppoweq) > 0 and tonumber(skill.ppoweq) ~= Player.stamina.percent))
			then 
				return true
			end
			if ((tonumber(skill.pcowgt) > 0 and tonumber(skill.pcowgt) > Player.stamina.current) or 
				(tonumber(skill.pcowlt) > 0 and tonumber(skill.pcowlt) < Player.stamina.current) or 
				(tonumber(skill.pcoweq) > 0 and tonumber(skill.pcoweq) ~= Player.stamina.current))
			then 
				return true
			end
		elseif (skill.powertype == "Ultimate") then -- cost type 10
			if ((tonumber(skill.ppowgt) > 0 and tonumber(skill.ppowgt) > ml_global_information.Player_Ultimate.percent)	or 
				(tonumber(skill.ppowlt) > 0 and tonumber(skill.ppowlt) < ml_global_information.Player_Ultimate.percent) or 
				(tonumber(skill.ppoweq) > 0 and tonumber(skill.ppoweq) ~= ml_global_information.Player_Ultimate.percent))
			then 
				return true
			end
			if ((tonumber(skill.pcowgt) > 0 and tonumber(skill.pcowgt) > ml_global_information.Player_Ultimate.current)	or 
				(tonumber(skill.pcowlt) > 0 and tonumber(skill.pcowlt) < ml_global_information.Player_Ultimate.current) or 
				(tonumber(skill.pcoweq) > 0 and tonumber(skill.pcoweq) ~= ml_global_information.Player_Ultimate.current))
			then 
				return true
			end
		end				
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Player Single Buff Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local playerBuffs = esominion.masterbuffList[Player.index]
		if (skill.pbuffthis == true) then
			if not HasBuff(playerBuffs, realskilldata.id) then 
				return true
			end 
		end
		if (skill.pnbuffthis == true) then
			if not MissingBuff(playerBuffs, realskilldata.id) then 
				return true
			end
		end
		if (tonumber(skill.pbuffc) > 0 and tonumber(skill.pbuffc) < IsNull(table.size(esominion.buffList[Player.index]),0)) then
			return true
		end
		if (tonumber(skill.pdbuffc) > 0 and tonumber(skill.pdbuffc) < IsNull(table.size(esominion.buffList[Player.index]),0)) then
			return true
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Target Single Buff Check"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		local realskilldata = eso_skillmanager.CurrentSkillData
		local targetBuffs = esominion.masterbuffList[target.index]
		
		if (skill.tbuffthis == true) then
			if not HasBuff(targetBuffs, realskilldata.id) then 
				return true
			end 
		end
		if (skill.tnbuffthis == true) then
			if not MissingBuff(targetBuffs, realskilldata.id) then 
				return true
			end
		end	
		if (tonumber(skill.tbuffc) > 0 and tonumber(skill.tbuffc) < table.size(esominion.buffList[target.index])) then
			return true
		end
		if (tonumber(skill.tdbuffc) > 0 and tonumber(skill.tdbuffc) < table.size(esominion.debuffList[target.index])) then
			return true
		end
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Player Buff Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local playerBuffs = esominion.masterbuffList[Player.index]
		if (skill.pbuff ~= "") then
			if not HasBuffs(playerBuffs, skill.pbuff) then 
				return true
			end 
		end
		if (skill.pnbuff ~= "") then
			if not MissingBuffs(playerBuffs, skill.pnbuff) then 
				return true
			end
		end			
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Target Buff Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local target = eso_skillmanager.CurrentTarget
		local realskilldata = eso_skillmanager.CurrentSkillData
		local targetBuffs = esominion.masterbuffList[target.index]
		if (skill.tbuff ~= "") then
			if not HasBuffs(targetBuffs, skill.tbuff) then 
				return true
			end 
		end
		if (skill.tnbuff ~= "") then
			if not MissingBuffs(targetBuffs, skill.tnbuff) then 
				return true
			end
		end			
		return false
	end
	}
	eso_skillmanager.AddConditional(conditional)
		
	conditional = { name = "Target HP Checks"	
	, eval = function()	
		local skill = eso_skillmanager.CurrentSkill
		local realskilldata = eso_skillmanager.CurrentSkillData
		local target = eso_skillmanager.CurrentTarget
		
		local thpgt = tonumber(skill.thpgt) or 0
		local thplt = tonumber(skill.thplt) or 0
		local thpadv = tonumber(skill.thpadv) or 0
		
		if thpadv > 0  then
			if  target.health.max < Player.health.max * thpadv then
				return true
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
		
				
				
		local val, changed = GUI:Checkbox(GetString("Display Active SKills Only"),gSKMFilter)
		if (changed) then
			gSKMFilter = val
			Settings.ESOMINION.gSKMFilter = gSKMFilter
			eso_skillmanager.SkillBook = {}
		end				
		
		GUI:Separator()              
		
		local skillBook = eso_skillmanager.SkillBook
		if (table.valid(skillBook)) then
			local sortfunc = function(skillBook,a,b) 
				return (skillBook[a].name < skillBook[b].name)
			end
			local function WindowFocusFlags()
				if GUI:IsWindowFocused() == true or GUI:IsWindowHovered() == true then
					return 0
				else
					return GUI.InputTextFlags_ReadOnly
				end
			end
			GUI:Text(GetString("Search:"))
			if GUI:IsItemHovered() then GUI:SetTooltip(GetString("Name or ID")) end
			GUI:SameLine()
			eso_skillmanager.skillsearchstring = GUI:InputText("##eso_skillmanagerskillsearchstring",eso_skillmanager.skillsearchstring,WindowFocusFlags())
			if GUI:IsItemHovered() then GUI:SetTooltip(GetString("Name or ID")) end
			for key, skillInfo in spairs(skillBook,sortfunc) do
				if eso_skillmanager.skillsearchstring == "" or
					string.find(string.lower(skillInfo.name),string.lower(eso_skillmanager.skillsearchstring)) or
						string.find(tostring(skillInfo.id),eso_skillmanager.skillsearchstring) then
					if ( GUI:Button(skillInfo.name.." ["..tostring(skillInfo.id).."]",width,20)) then
						eso_skillmanager.AddSkillToProfile(skillInfo.id)
						eso_skillmanager.SaveProfile()
					
					end
				end
			end
		else
			eso_skillmanager.SkillBook = eso_skillmanager.BuildSkillsBook()
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
			
			eso_skillmanager.GUI.profile.visible, eso_skillmanager.GUI.profile.open = GUI:Begin(eso_skillmanager.GUI.profile.name, true)
			
			local contentwidth = GUI:GetContentRegionAvailWidth()
			if table.valid(eso_skillmanager.SkillProfile) then
		
				GUI:PushItemWidth(100)
				eso_skillmanager.CaptureElement(GUI:InputText("Debug Prio##gSkillManagerDebugPriorities",gSkillManagerDebugPriorities),"gSkillManagerDebugPriorities");
				GUI:PopItemWidth()
				GUI:Separator()         
			
				local doDelete = 0
				local doPriorityUp = 0
				local doPriorityDown = 0
				local doPriorityTop = 0
				local doPriorityBottom = 0
			
				--GUI:Spacing() GUI:Spacing() GUI:Spacing() GUI:Spacing()
				
				--[[if (GUI:Button("Set Weapon Prefered Profile",contentwidth,20)) then -- skill to edit
					eso_skillmanager.SetPreferedList()
				end]]
				
				--[[GUI:Spacing() GUI:Spacing() GUI:Spacing() GUI:Spacing()
				GUI:Separator()
				GUI:Spacing() GUI:Spacing() GUI:Spacing() GUI:Spacing()]]
				for prio,skillInfo in spairs(eso_skillmanager.SkillProfile) do
				
					if (GUI:Button(skillInfo.name.." ["..tostring(prio).."]",contentwidth - 85,20)) then -- skill to edit
					end
						
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(0)) then
							eso_skillmanager.GUI.skillbook.id = prio
							eso_skillmanager.EditingSkill = prio
							eso_skillmanager.EditSkill(prio)
							eso_skillmanager.GUI.editor.open = true
						end
					end					
					GUI:SameLine(0,5)
					if (GUI:ImageButton("##eso_skillmanager-manage-prioup-"..tostring(prio),ml_global_information.path.."\\GUI\\UI_Textures\\w_up.png", 16, 16)) then	
						doPriorityUp = prio
					end
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(1)) then
							doPriorityTop = prio
						end
					end	
					GUI:SameLine(0,5)
					if (GUI:ImageButton("##eso_skillmanager-manage-priodown-"..tostring(prio),ml_global_information.path.."\\GUI\\UI_Textures\\w_down.png", 16, 16)) then
						doPriorityDown = prio
					end
					if (GUI:IsItemHovered()) then
						if (GUI:IsMouseClicked(1)) then
							doPriorityBottom = prio
						end
					end	
					GUI:SameLine(0,5)
					if (GUI:ImageButton("##eso_skillmanager-manage-delete-"..tostring(prio),ml_global_information.path.."\\GUI\\UI_Textures\\bt_alwaysfail_fail.png", 16, 16)) then
						doDelete = prio
					end
					
					
				end
				if (doPriorityTop ~= 0 and doPriorityTop ~= 1) then
					local currentPos = doPriorityTop
					local newPos = doPriorityTop
					
					while currentPos > 1 do
						local temp = eso_skillmanager.SkillProfile[newPos]
						eso_skillmanager.SkillProfile[newPos] = eso_skillmanager.SkillProfile[currentPos]
						eso_skillmanager.SkillProfile[currentPos] = temp	
						currentPos = newPos
						newPos = newPos - 1
					end
					
					eso_skillmanager.GUI.skillbook.id = 0
					eso_skillmanager.SaveProfile()
				end
				
				if (doPriorityUp ~= 0 and doPriorityUp ~= 1) then
					local currentPos = doPriorityUp
					local newPos = doPriorityUp - 1
					
					local temp = eso_skillmanager.SkillProfile[newPos]
					eso_skillmanager.SkillProfile[newPos] = eso_skillmanager.SkillProfile[currentPos]
					eso_skillmanager.SkillProfile[currentPos] = temp	
					
					eso_skillmanager.GUI.skillbook.id = 0
					eso_skillmanager.SaveProfile()
				end
				if (doPriorityDown ~= 0 and doPriorityDown < TableSize(eso_skillmanager.SkillProfile)) then
					local currentPos = doPriorityDown
					local newPos = doPriorityDown + 1
					
					local temp = eso_skillmanager.SkillProfile[newPos]
					eso_skillmanager.SkillProfile[newPos] = eso_skillmanager.SkillProfile[currentPos]
					eso_skillmanager.SkillProfile[currentPos] = temp
					
					eso_skillmanager.GUI.skillbook.id = 0
					eso_skillmanager.SaveProfile()
				end
				
				local profSize = TableSize(eso_skillmanager.SkillProfile)
				if (doPriorityBottom ~= 0 and doPriorityBottom < profSize) then
				
					local currentPos = doPriorityBottom
					local newPos = doPriorityBottom + 1
					
					while currentPos < profSize do
						local temp = eso_skillmanager.SkillProfile[newPos]
						eso_skillmanager.SkillProfile[newPos] = eso_skillmanager.SkillProfile[currentPos]
						eso_skillmanager.SkillProfile[currentPos] = temp	
						currentPos = newPos
						newPos = newPos + 1
					end
					
					eso_skillmanager.GUI.skillbook.id = 0
					eso_skillmanager.SaveProfile()
				end
				
				if (doDelete ~= 0) then
					eso_skillmanager.SkillProfile = TableRemoveSort(eso_skillmanager.SkillProfile,doDelete)
					for prio,skill in pairsByKeys(eso_skillmanager.SkillProfile) do
						if (skill.prio ~= prio) then
							eso_skillmanager.SkillProfile[prio].prio = prio
						end
					end
					eso_skillmanager.GUI.skillbook.id = 0
					eso_skillmanager.SaveProfile()
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
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Allow Weapon Swap")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_Swap",SKM_Swap),"SKM_Swap"); GUI:NextColumn();	
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Summon Skill")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_Summon",SKM_Summon),"SKM_Summon"); GUI:NextColumn();		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Min Range")); GUI:NextColumn(); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Minimum range the skill can be used.")) end eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_MinR",SKM_MinR,0,0),"SKM_MinR");  GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Max Range")); GUI:NextColumn(); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Maximum range the skill can be used.")) end eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_MaxR",SKM_MaxR,0,0),"SKM_MaxR"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous Skill")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should be used immediately after another skill that is not on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PSkillID",SKM_PSkillID),"SKM_PSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Previous Skill NOT")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If this skill should NOT be used immediately after another skill that is not on the GCD, put the ID of that skill here.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_NPSkillID",SKM_NPSkillID),"SKM_NPSkillID"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Throttle Skill",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Delay reuse of skill. (seconds)")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_THROTTLE",SKM_THROTTLE,0,0),"SKM_THROTTLE"); GUI:NextColumn();
		GUI:Columns(1)
	end
	
	
	if (GUI:CollapsingHeader(GetString("Player Stats"),"battle-playerhp-header")) then
		GUI:Columns(2,"#battle-playerhp-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP %% >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player HP is greater than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHPGT",SKM_PHPGT,0,0),"SKM_PHPGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP %% <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player HP is less than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHPLT",SKM_PHPLT,0,0),"SKM_PHPLT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP %% ==",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player HP is less than this percent.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHPEQ",SKM_PHPEQ,0,0),"SKM_PHPEQ"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Current Player HP is greater than this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHCGT",SKM_PHCGT,0,0),"SKM_PHCGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Current Player HP is less than this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHCLT",SKM_PHCLT,0,0),"SKM_PHCLT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Player HP ==",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Current Player HP is equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PHCEQ",SKM_PHCEQ,0,0),"SKM_PHCEQ"); GUI:NextColumn();
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power Type")); GUI:NextColumn(); SKM_Combo("##SKM_POWERTYPE","gSMBattlePowerTypeIndex","SKM_POWERTYPE",gSMBattlePowerTypes); GUI:NextColumn();
		
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power %% >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player Power is more than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PPowGT",SKM_PPowGT,0,0),"SKM_PPowGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power %% <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player Power is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PPowLT",SKM_PPowLT,0,0),"SKM_PPowLT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power %% ==",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Player Power is equal to this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PPowEQ",SKM_PPowEQ,0,0),"SKM_PPowEQ"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power >",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Current Player Power is more than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PCowGT",SKM_PCowGT,0,0),"SKM_PCowGT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power <",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Current Player Power is less than this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PCowLT",SKM_PCowLT,0,0),"SKM_PCowLT"); GUI:NextColumn();
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Power ==",true)); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when Current Player Power is equal to this value.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PCowEQ",SKM_PCowEQ,0,0),"SKM_PCowEQ"); GUI:NextColumn();
		
		GUI:Columns(1)
	end
	if (GUI:CollapsingHeader(GetString("casting"),"battle-casting-header")) then
		GUI:Columns(2,"#battle-casting-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		GUI:Text(GetString("skmTCASTID")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Target must be channelling one of the listed spell IDs (comma-separated list).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TCASTID",SKM_TCASTID),"SKM_TCASTID"); GUI:NextColumn();
		--GUI:Text(GetString("skmTCASTTM")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Target must be casting the spell on me (self).")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_TCASTTM",SKM_TCASTTM),"SKM_TCASTTM"); GUI:NextColumn();
		--GUI:Text(GetString("skmTCASTTIME")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Cast time left on the current spell must be greater than or equal to (>=) this time in seconds.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TCASTTIME",SKM_TCASTTIME),"SKM_TCASTTIME"); GUI:NextColumn();		
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
		--GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Has this effect")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_PBuffThis",SKM_PBuffThis),"SKM_PBuffThis"); GUI:NextColumn();	
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Missing this effect")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_PNBuffThis",SKM_PNBuffThis),"SKM_PNBuffThis"); GUI:NextColumn();	
		GUI:Text(GetString("Has buffs/debuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Player is being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PBuff",SKM_PBuff),"SKM_PBuff"); GUI:NextColumn();
		GUI:Text(GetString("Missing buffs/debuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Player is not being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_PNBuff",SKM_PNBuff),"SKM_PNBuff"); GUI:NextColumn();
		GUI:Text(GetString("Buff Count >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of buffs is greater than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PBuffCount",SKM_PBuffCount,0,0),"SKM_PBuffCount"); GUI:NextColumn();
		GUI:Text(GetString("Debuff Count >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of debuffs is greater than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_PDBuffCount",SKM_PDBuffCount,0,0),"SKM_PDBuffCount"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	if (GUI:CollapsingHeader(GetString("targetBuffs"),"battle-targetbuffs-header")) then
		GUI:Columns(2,"#battle-targetbuffs-main",false)
		GUI:SetColumnOffset(1,150); GUI:SetColumnOffset(2,450);
		
		GUI:PushItemWidth(100)
		--GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Has this effect")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_TBuffThis",SKM_TBuffThis),"SKM_TBuffThis"); GUI:NextColumn();	
		GUI:AlignFirstTextHeightToWidgets(); GUI:Text(GetString("Missing this effect")); GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:Checkbox("##SKM_TNBuffThis",SKM_TNBuffThis),"SKM_TNBuffThis"); GUI:NextColumn();	
		GUI:Text(GetString("Has Has buffs/debuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Target is being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TBuff",SKM_TBuff),"SKM_TBuff"); GUI:NextColumn();
		GUI:Text(GetString("Missing buffs/debuffs")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the Target is not being affected by a buff with the ID entered.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputText("##SKM_TNBuff",SKM_TNBuff),"SKM_TNBuff"); GUI:NextColumn();
		GUI:Text(GetString("Buff Count >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of buffs is greater than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TBuffCount",SKM_TBuffCount,0,0),"SKM_TBuffCount"); GUI:NextColumn();
		GUI:Text(GetString("Debuff Count >=")); if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Use this skill when the number of debuffs is greater than or equal to this number.")) end GUI:NextColumn(); eso_skillmanager.CaptureElement(GUI:InputInt("##SKM_TDBuffCount",SKM_TDBuffCount,0,0),"SKM_TDBuffCount"); GUI:NextColumn();
		GUI:PopItemWidth()
		
		GUI:Columns(1)
	end
	
	--[[		
	GUI_NewButton(eso_skillmanager.editwindow.name,"Build Macro","SMToggleMacro","Macro")
	--]]
end

RegisterEventHandler("Gameloop.Update",eso_skillmanager.OnUpdate,"ESO Update")
RegisterEventHandler("Gameloop.Draw",eso_skillmanager.Draw,"ESOSKM  Draw")
RegisterEventHandler("Module.Initalize",eso_skillmanager.ModuleInit,"ESO ModuleInit")
