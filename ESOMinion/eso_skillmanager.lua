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

eso_skillmanager.TIP_BLOCK = 1
eso_skillmanager.TIP_EXPLOIT = 2
eso_skillmanager.TIP_INTERRUPT = 3
eso_skillmanager.TIP_AVOID = 4
eso_skillmanager.TIP_BREAK = 18

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
	if (Settings.ESOMinion.SMDefaultProfiles[6] == nil) then
		Settings.ESOMinion.SMDefaultProfiles[6] = "Templar"
	end
		
    -- Skillbook
    GUI_NewWindow(eso_skillmanager.skillbook.name, eso_skillmanager.skillbook.x, eso_skillmanager.skillbook.y, eso_skillmanager.skillbook.w, eso_skillmanager.skillbook.h)
    GUI_NewButton(eso_skillmanager.skillbook.name,GetString("skillbookrefresh"),"SMRefreshSkillbookEvent")
    GUI_UnFoldGroup(eso_skillmanager.skillbook.name,"AvailableSkills")
    GUI_SizeWindow(eso_skillmanager.skillbook.name,eso_skillmanager.skillbook.w,eso_skillmanager.skillbook.h)
    GUI_WindowVisible(eso_skillmanager.skillbook.name,false)	
    
    -- SelectedSkills/Main Window
    GUI_NewWindow(eso_skillmanager.mainwindow.name, eso_skillmanager.skillbook.x+eso_skillmanager.skillbook.w,eso_skillmanager.mainwindow.y,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
    GUI_NewComboBox(eso_skillmanager.mainwindow.name,GetString("profile"),"gSMprofile",GetString("generalSettings"),"")
	GUI_NewCheckbox(eso_skillmanager.mainwindow.name,GetString("debugging"),"gSkillManagerDebug",GetString("generalSettings"))
	GUI_NewField(eso_skillmanager.mainwindow.name,GetString("debugItems"),"gSkillManagerDebugPriorities",GetString("generalSettings"))
	
    GUI_NewButton(eso_skillmanager.mainwindow.name,GetString("saveProfile"),"SMSaveEvent")
    RegisterEventHandler("SMSaveEvent",eso_skillmanager.SaveProfile)
	--GUI_NewButton(eso_skillmanager.mainwindow.name,GetString("clearProfile"),"SMClearEvent")
    --RegisterEventHandler("SMClearEvent",eso_skillmanager.ClearProfilePrompt)
    GUI_NewField(eso_skillmanager.mainwindow.name,GetString("newProfileName"),"gSMnewname",GetString("skillEditor"))
    GUI_NewButton(eso_skillmanager.mainwindow.name,GetString("newProfile"),"newSMProfileEvent",GetString("skillEditor"))
    RegisterEventHandler("newSMProfileEvent",eso_skillmanager.NewProfile)
    GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,GetString("generalSettings"))
    GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
    GUI_WindowVisible(eso_skillmanager.mainwindow.name,false)		
	
	GUI_NewWindow(eso_skillmanager.confirmwindow.name, eso_skillmanager.confirmwindow.x, eso_skillmanager.confirmwindow.y, eso_skillmanager.confirmwindow.w, eso_skillmanager.confirmwindow.h)
	GUI_NewButton(eso_skillmanager.confirmwindow.name,GetString("yes"),"SKMClearProfileYes")
	GUI_NewButton(eso_skillmanager.confirmwindow.name,GetString("no"),"SKMClearProfileNo")
	GUI_NewButton(eso_skillmanager.confirmwindow.name,GetString("no"),"SKMClearProfileNo")
	GUI_NewButton(eso_skillmanager.confirmwindow.name,GetString("no"),"SKMClearProfileNo")
	GUI_WindowVisible(eso_skillmanager.confirmwindow.name,false)
                   
    gSMnewname = ""
    
    -- EDITOR WINDOW
    GUI_NewWindow(eso_skillmanager.editwindow.name, eso_skillmanager.mainwindow.x+eso_skillmanager.mainwindow.w, eso_skillmanager.mainwindow.y, eso_skillmanager.editwindow.w, eso_skillmanager.editwindow.h,"",true)		
    GUI_NewField(eso_skillmanager.editwindow.name,GetString("maMarkerID"),"SKM_ID",GetString("skillDetails"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("maMarkerName"),"SKM_NAME",GetString("skillDetails"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("alias"),"SKM_ALIAS",GetString("skillDetails"))
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("enabled"),"SKM_ENABLED",GetString("skillDetails"))
	--GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmCombat"),"SKM_Combat",GetString("skillDetails"),"In Combat,Out of Combat,Any")
	
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("minRange"),"SKM_MinR",GetString("basicDetails"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("maxRange"),"SKM_MaxR",GetString("basicDetails"))
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("smsktype"),"SKM_SKILLTYPE",GetString("basicDetails"),GetString("smsktypedmg")..","..GetString("smsktypeheal"));
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("casttime"),"SKM_CASTTIME",GetString("basicDetails"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("prevSkillID"),"SKM_PSkillID",GetString("basicDetails"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("prevSkillIDNot"),"SKM_NPSkillID",GetString("basicDetails"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("smthrottle"),"SKM_THROTTLE",GetString("basicDetails"))

	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerHPGT"),"SKM_PHPL",GetString("playerHPMPTP"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerHPLT"),"SKM_PHPB",GetString("playerHPMPTP"))
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("smskpowertype"),"SKM_POWERTYPE",GetString("playerHPMPTP"),"Magicka,Stamina,Ultimate");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerPowerGT"),"SKM_PPowGT",GetString("playerHPMPTP"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerPowerLT"),"SKM_PPowLT",GetString("playerHPMPTP"))

	--GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmTRG"),"SKM_TRG",GetString("target"),"Target,Ground Target,SMN DoT,SMN Bane,Cast Target,Player,Party,PartyS,Low TP,Low MP,Pet,Ally,Tank,Tankable Target,Tanked Target,Heal Priority,Dead Ally,Dead Party")
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("targetHPGT"),"SKM_THPGT",GetString("target"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("targetHPLT"),"SKM_THPLT",GetString("target"))
	
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmTECount"),"SKM_TECount",GetString("aoe"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmTECount2"),"SKM_TECount2",GetString("aoe"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmTERange"),"SKM_TERange",GetString("aoe"))
	--GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmTELevel"),"SKM_TELevel",GetString("aoe"),"0,2,4,6,Any")
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmTACount"),"SKM_TACount",GetString("aoe"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmTARange"),"SKM_TARange",GetString("aoe"))
	--GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("alliesNearHPLT"),"SKM_TAHPL",GetString("aoe"))
	
	--[[
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("filter1"),"SKM_FilterOne",GetString("basicDetails"), "Ignore,Off,On")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("filter2"),"SKM_FilterTwo",GetString("basicDetails"), "Ignore,Off,On")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("filter3"),"SKM_FilterThree",GetString("basicDetails"), "Ignore,Off,On")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("filter4"),"SKM_FilterFour",GetString("basicDetails"), "Ignore,Off,On")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("filter5"),"SKM_FilterFive",GetString("basicDetails"), "Ignore,Off,On")
	--]]
	
	--[[
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmPTCount"),"SKM_PTCount",GetString("party"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmPTHPL"),"SKM_PTHPL",GetString("party"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmPTHPB"),"SKM_PTHPB",GetString("party"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmPTMPL"),"SKM_PTMPL",GetString("party"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmPTMPB"),"SKM_PTMPB",GetString("party"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmPTTPL"),"SKM_PTTPL",GetString("party"))
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmPTTPB"),"SKM_PTTPB",GetString("party"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmHasBuffs"),"SKM_PTBuff",GetString("party"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmMissBuffs"),"SKM_PTNBuff",GetString("party"))
	--]]
	
	--[[
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmTCASTID"),"SKM_TCASTID",GetString("casting"))
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("skmTCASTTM"),"SKM_TCASTTM",GetString("casting"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmTCASTTIME"),"SKM_TCASTTIME",GetString("casting"))
	--]]
	
	--[[
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("skmHPRIOHP"),"SKM_HPRIOHP",GetString("healPriority"))
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmHPRIO1"),"SKM_HPRIO1",GetString("healPriority"),"Self,Tank,Party,Any,None")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmHPRIO2"),"SKM_HPRIO2",GetString("healPriority"),"Self,Tank,Party,Any,None")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmHPRIO3"),"SKM_HPRIO3",GetString("healPriority"),"Self,Tank,Party,Any,None")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmHPRIO4"),"SKM_HPRIO4",GetString("healPriority"),"Self,Tank,Party,Any,None")
	--]]
	
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("skmHasBuff"),"SKM_PBuffThis",GetString("playerBuffs"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmHasBuffs"),"SKM_PBuff",GetString("playerBuffs"))
	--GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmAndBuffDura"),"SKM_PBuffDura",GetString("playerBuffs"))
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("skmMissBuff"),"SKM_PNBuffThis",GetString("playerBuffs"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmMissBuffs"),"SKM_PNBuff",GetString("playerBuffs"))
	--GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmOrBuffDura"),"SKM_PNBuffDura",GetString("playerBuffs"))
	
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("skmTBuffOwner"),"SKM_TBuffOwner",GetString("targetBuffs"), "Player,Any")
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("skmHasBuff"),"SKM_TBuffThis",GetString("targetBuffs"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmHasBuffs"),"SKM_TBuff",GetString("targetBuffs"))
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("skmMissBuff"),"SKM_TNBuffThis",GetString("targetBuffs"))
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmMissBuffs"),"SKM_TNBuff",GetString("targetBuffs"))
	--GUI_NewField(eso_skillmanager.editwindow.name,GetString("skmOrBuffDura"),"SKM_TNBuffDura",GetString("targetBuffs"))
	
    GUI_UnFoldGroup(eso_skillmanager.editwindow.name,GetString("skillDetails"))
	
    GUI_NewButton(eso_skillmanager.editwindow.name,"DELETE","SMEDeleteEvent")
    GUI_NewButton(eso_skillmanager.editwindow.name,"DOWN","SMESkillDOWNEvent")	
    GUI_NewButton(eso_skillmanager.editwindow.name,"UP","SMESkillUPEvent")
	GUI_NewButton(eso_skillmanager.editwindow.name,"PASTE","SKMPasteSkill")
	GUI_NewButton(eso_skillmanager.editwindow.name,"COPY","SKMCopySkill")
    GUI_SizeWindow(eso_skillmanager.editwindow.name,eso_skillmanager.editwindow.w,eso_skillmanager.editwindow.h)
    GUI_WindowVisible(eso_skillmanager.editwindow.name,false)

    eso_skillmanager.SkillBook = {}
	eso_skillmanager.UpdateProfiles()
    eso_skillmanager.UpdateCurrentProfileData()
    GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
	
	eso_skillmanager.AddDefaultConditions()
end

function eso_skillmanager.GUIVarUpdate(Event, NewVals, OldVals)
    for k,v in pairs(NewVals) do
        if ( k == "gSMprofile" ) then
            gSMactive = "1"					
            GUI_WindowVisible(eso_skillmanager.editwindow.name,false)		
            GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
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
	GUI_WindowVisible(eso_skillmanager.editwindow.name,false)		
	GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
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
			GUI_DeleteGroup(eso_skillmanager.skillbook.name,"AvailableSkills")
			GUI_DeleteGroup(eso_skillmanager.skillbook.name,"MiscSkills")	
			eso_skillmanager.RefreshSkillBook()		
		end
        
		if (string.find(Button,"SMEDeleteEvent") ~= nil) then
			if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then
				GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
				eso_skillmanager.SkillProfile = TableRemoveSort(eso_skillmanager.SkillProfile,tonumber(SKM_Prio))

				eso_skillmanager.RefreshSkillList()	
				GUI_WindowVisible(eso_skillmanager.editwindow.name,false)
			end
		end

		if (string.find(Button,"SMESkillUPEvent") ~= nil) then
			if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then
				if ( SKM_Prio > 1) then
					GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
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
					GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")		
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
		
		GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
		eso_skillmanager.SkillProfile = {}
		eso_skillmanager.WriteToFile(gSMprofile)
	else
		d("New profile name is invalid, couldn't create new profile.")
    end
end

function eso_skillmanager.ClearProfilePrompt()
	local wnd = GUI_GetWindowInfo(eso_skillmanager.mainwindow.name)
	GUI_MoveWindow(eso_skillmanager.confirmwindow.name, wnd.x,wnd.y+wnd.height) 
	GUI_SizeWindow(eso_skillmanager.confirmwindow.name,wnd.width,eso_skillmanager.confirmwindow.h)
	GUI_WindowVisible(eso_skillmanager.confirmwindow.name,true)
end

function eso_skillmanager.ClearProfile(arg)
	if (arg == "Yes") then
		GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
		eso_skillmanager.SkillProfile = {}
		eso_skillmanager.WriteToFile(gSMprofile)
	end
	GUI_WindowVisible(eso_skillmanager.confirmwindow.name,false)
end

function eso_skillmanager.SaveProfile()
    local filename = ""
	
    --If a new name is filled out, copy the profile rather than save it.
    if ( gSMnewname ~= "" ) then
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
	GUI_WindowVisible(eso_skillmanager.editwindow.name,false)	
	GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
	eso_skillmanager.UpdateCurrentProfileData()
	
	GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
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
		GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
		eso_skillmanager.SkillProfile = {}
		eso_skillmanager.ReadFile(profile)
		eso_skillmanager.RefreshSkillList()
		GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
		GUI_RefreshWindow(eso_skillmanager.mainwindow.name)
	end
end

--+Rebuilds the UI Entries for the SkillbookList
function eso_skillmanager.RefreshSkillBook()
    local SkillList = AbilityList("")
    if ( ValidTable( SkillList ) ) then
		for i,skill in spairs(SkillList, function( skill,a,b ) return skill[a].name < skill[b].name end) do
			eso_skillmanager.CreateNewSkillBookEntry(skill.id)
		end
    end

    GUI_UnFoldGroup(eso_skillmanager.skillbook.name,"AvailableSkills")
end


function eso_skillmanager.CreateNewSkillBookEntry(id)
	local action = AbilityList:Get(id)
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
    if (ValidTable(eso_skillmanager.SkillBook[skillid])) then
        eso_skillmanager.CreateNewSkillEntry(eso_skillmanager.SkillBook[skillid])
    end
end


--+Rebuilds the UI Entries for the Profile-SkillList
function eso_skillmanager.RefreshSkillList()
	GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
    if ( TableSize( eso_skillmanager.SkillProfile ) > 0 ) then
		for prio,skill in pairsByKeys(eso_skillmanager.SkillProfile) do
			--local realID = tonumber(skill.skillID)
			local realID = eso_skillmanager.GetRealSkillID(skill.skillID)
				
			local clientSkill = AbilityList:Get(realID)
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
			GUI_NewButton(eso_skillmanager.mainwindow.name, viewString, "SKMEditSkill"..tostring(prio),"ProfileSkills")
		end
		GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
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
	
	if (not skill.name or not skill.skillID) then
		return false
	end
	
	local skname = skill.name
	local skID = tonumber(skill.skillID)
	
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
    local wnd = GUI_GetWindowInfo(eso_skillmanager.mainwindow.name)		
	
	-- Normal Editor 
	GUI_MoveWindow( eso_skillmanager.editwindow.name, wnd.x+wnd.width,wnd.y) 
	GUI_WindowVisible(eso_skillmanager.editwindow.name,true)
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
        GUI_WindowVisible(eso_skillmanager.mainwindow.name,false)	
        GUI_WindowVisible(eso_skillmanager.skillbook.name,false)	
        GUI_WindowVisible(eso_skillmanager.editwindow.name,false)	
		GUI_WindowVisible(eso_skillmanager.confirmwindow.name,false)
        eso_skillmanager.visible = false
    else
		eso_skillmanager.RefreshSkillList()
		GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
        GUI_WindowVisible(eso_skillmanager.skillbook.name,true)
        GUI_WindowVisible(eso_skillmanager.mainwindow.name,true)	
        eso_skillmanager.visible = true
    end
end

function eso_skillmanager.GetAttackRange()
	local maxRange = 5
	
	local classID = ml_global_information.CurrentClassID
	if (classID) then
	
		--[1] = "DragonKnight",
		--[2] = "Sorcerer",
		--[3] = "Nightblade",
		--[6] = "Templar",
	
		if (classID == 1) then
			maxRange = 5
		elseif (classID == 2) then
			maxRange = 10
		elseif (classID == 3) then
			maxRange = 5
		elseif (classID == 6) then
			maxRange = 5
		end		
	end
	return maxRange
end

function eso_skillmanager.Cast( entity )
	if (not entity or not entity.attackable or Now() < eso_skillmanager.latencyTimer) then
		return false
	end
	
	--Check for blocks/interrupts.
	if (Player:GetNumActiveCombatTips() > 0) then
		
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
		
		local exploitable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_EXPLOIT)
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
		end
		
		local interruptable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_INTERRUPT)
		if (ValidTable(interruptable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoInterrupt == "1")) then
				e("PerformInterrupt()")
				eso_skillmanager.latencyTimer = Now() + 300
				d("Attempting to interrupt enemy.")
				return true
			end
		end
		
		local breakable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_BREAK)
		if (ValidTable(breakable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoBreak == "1")) then
				local direction = math.random(0,1) == 1 and 4 or 5
				Player:RollDodge(direction)
				eso_skillmanager.latencyTimer = Now() + 300
				d("Attempting to break CC.")
				return true
			end
		end
		
		local avoidable = EntityList:GetFromCombatTip(eso_skillmanager.TIP_AVOID)
		if (ValidTable(avoidable)) then
			if (not isAssistMode or (isAssistMode and gAssistDoAvoid == "1")) then
				local direction = math.random(0,1) == 1 and 4 or 5
				Player:RollDodge(direction)
				eso_skillmanager.latencyTimer = Now() + 300
				d("Attempting to avoid attack.")
				return true
			end
		end
	end
	
	--This call is here to refresh the action list in case new skills are equipped. May not be necessary for ESO.
	local al = AbilityList("")
	if (ValidTable(eso_skillmanager.SkillProfile)) then
		for prio,skill in pairsByKeys(eso_skillmanager.SkillProfile) do
			local result = eso_skillmanager.CanCast(prio, entity)
			if (result ~= 0) then
				local TID = result
				
				--local realID = tonumber(skill.skillID)
				local realID = eso_skillmanager.GetRealSkillID(skill.skillID)
				local action = AbilityList:Get(realID)
				d("Attempting to cast ability ID : "..tostring(realID))
				if ( action and AbilityList:Cast(realID,TID)) then
					skill.timelastused = Now()
					eso_skillmanager.prevSkillID = realID
					eso_skillmanager.resetTimer = Now() + 4000
					
					local casttime = action.casttime or 0
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
	elseif ( skill.trg == "Tankable Target") then
		local newtarget = eso_skillmanager.GetTankableTarget(maxrange)
		if (newtarget) then
			target = newtarget
			TID = newtarget.id
		else
			return nil
		end
	elseif ( skill.trg == "Tanked Target") then
		local newtarget = eso_skillmanager.GetTankedTarget(maxrange)
		if (newtarget) then
			target = newtarget
			TID = newtarget.id
		else
			return nil
		end
	elseif ( skill.trg == "Pet" ) then
		if ( pet ) then
			if ( eso_skillmanager.IsPetSummonSkill(skillid) and pet.alive ) then 
				return nil 
			else
				target = pet
				TID = pet.id
			end
		else
			TID = PID
		end
	elseif ( skill.trg == "Party" ) then
		if ( not IsNullString(skill.ptbuff) or not IsNullString(skill.ptnbuff)) then
			local newtarget = PartyMemberWithBuff(skill.ptbuff, skill.ptnbuff, maxrange)
			if (newtarget) then
				target = newtarget
				TID = newtarget.id
			 else
				return nil
			end
		else
			local ally = nil
			if ( skill.npc == "1" ) then
				ally = GetBestPartyHealTarget( true, maxrange )
			else
				ally = GetBestPartyHealTarget( false, maxrange )
			end
			
			if ( ally ) then
				target = ally
				TID = ally.id
			else
				return nil
			end
		end
	elseif ( skill.trg == "PartyS" ) then
		if (not IsNullString(skill.ptbuff) or not IsNullString(skill.ptnbuff)) then
			local newtarget = PartySMemberWithBuff(skill.ptbuff, skill.ptnbuff, maxrange)
			if (newtarget) then
				target = newtarget
				TID = newtarget.id
			else
				return nil
			end
		else
			local ally = GetLowestHPParty( skill )
			if ( ally ) then
				target = ally
				TID = ally.id
			else
				return nil
			end
		end
	elseif ( skill.trg == "Tank" ) then
		local ally = GetBestTankHealTarget( maxrange )
		if ( ally and ally.id ~= PID) then
			target = ally
			TID = ally.id
		else
			return nil
		end
	elseif ( skill.trg == "Ally" ) then
		local ally = nil
		if ( skill.npc == "1" ) then
			ally = GetBestHealTarget( true, maxrange )
		else
			ally = GetBestHealTarget( false, maxrange )
		end
		
		if ( ally and ally.id ~= PID) then
			target = ally
			TID = ally.id
		end	
	elseif ( skill.trg == "Dead Party" or skill.trg == "Dead Ally") then
		local ally = nil
		if (skill.trg == "Dead Party") then
			ally = GetBestRevive( true, skill.trgtype )
		else
			ally = GetBestRevive( false, skill.trgtype )
		end 
		
		if ( ally and ally.id ~= PID ) then
			if IsReviveSkill(skillid) then
				target = ally
				TID = ally.id
			else
				TID = PID
			end
		else
			return nil
		end
	elseif ( skill.trg == "Casting Target" ) then
		local ci = entity.castinginfo
		if ( ci ) then
			target = EntityList:Get(ci.channeltargetid)
			TID = ci.channeltargetid
		else
			return nil
		end
	elseif ( skill.trg == "SMN DoT" ) then
		local newtarget = GetBestDoTTarget()
		if (newtarget) then
			target = newtarget
			TID = newtarget.id
		else
			return nil
		end
	elseif ( skill.trg == "SMN Bane" ) then
		local newtarget = GetBestBaneTarget()
		if (newtarget) then
			target = newtarget
			TID = newtarget.id
		else
			return nil
		end
	elseif ( skill.trg == "Player" ) then
		TID = PID
	elseif ( skill.trg == "Low TP" ) then
		local ally = GetLowestTPParty( maxrange, skill.trgtype )
		if ( ally ) then
			target = ally
			TID = ally.id
		else
			return nil
		end
	elseif ( skill.trg == "Low MP" ) then
		local ally = GetLowestMPParty( maxrange, skill.trgtype )
		if ( ally ) then
			target = ally
			TID = ally.id
		else
			return nil
		end
	elseif ( skill.trg == "Heal Priority" and tonumber(skill.hpriohp) > 0 ) then
		local priorities = {
			[1] = skill.hprio1,
			[2] = skill.hprio2,
			[3] = skill.hprio3,
			[4] = skill.hprio4,
		}
		
		local healTargets = {}
		healTargets["Self"] = Player
		healTargets["Tank"] = GetBestTankHealTarget( maxrange )
		if ( skill.npc == "1" ) then
			healTargets["Party"] = GetBestPartyHealTarget( true, maxrange )
			healTargets["Any"] = GetBestHealTarget( true, maxrange )
		else
			healTargets["Party"] = GetBestPartyHealTarget( false, maxrange )
			healTargets["Any"] = GetBestHealTarget( false, maxrange ) 
		end
		
		local ally = nil
		for i,trgstring in ipairs(priorities) do
			if (healTargets[trgstring]) then
				local htarget = healTargets[trgstring]
				if (tonumber(skill.hpriohp) > htarget.hp.percent) then
					ally = htarget
				end
			end
			if (ally) then
				break
			end
		end
		
		if ( ally ) then
			eso_skillmanager.DebugOutput( skill.prio, "Heal Priority: Target Selection : "..ally.name)
			target = ally
			TID = ally.id
		else
			eso_skillmanager.DebugOutput( skill.prio, "Heal Priority: Target Selection : nil")
			return nil
		end
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
	local realID = AbilityList:GetProgressionAbilityId(newid) or 0
	if (realID == 0) then
		realID = newid
	end
	
	return realID
end

function eso_skillmanager.GetAbilitySafe(skillid)
	local skillid = tonumber(skillid) or 0
	local ability = nil
	
	local list = AbilityList("")
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
	local realskilldata = eso_skillmanager.GetAbilitySafe(realID) 
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
	
	conditional = { name = "Client CanCast/Range Check"
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
		if ( throttle > 0 and skill.timelastused and (TimeSince(skill.timelastused) < (throttle * 1000))) then 
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
	
	conditional = { name = "Player Single Buff Check"	
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
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Target Single Buff Check"	
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
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Player Buff Checks"	
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
	}
	eso_skillmanager.AddConditional(conditional)
	
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
	eso_skillmanager.AddConditional(conditional)
	
	conditional = { name = "Target HP Checks"	
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
	}
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

RegisterEventHandler("Gameloop.Update",eso_skillmanager.OnUpdate)
RegisterEventHandler("GUI.Item",eso_skillmanager.ButtonHandler)
RegisterEventHandler("SkillManager.toggle", eso_skillmanager.ToggleMenu)
RegisterEventHandler("GUI.Update",eso_skillmanager.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",eso_skillmanager.ModuleInit)
