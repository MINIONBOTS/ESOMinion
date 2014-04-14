eso_skillmanager = {}
-- Skillmanager for adv. skill customization
eso_skillmanager.profilepath = GetStartupPath() .. [[\LuaMods\ESOMinion\SkillManagerProfiles\]];
eso_skillmanager.mainwindow = { name = GetString("skillManager"), x = 350, y = 50, w = 250, h = 350}
eso_skillmanager.editwindow = { name = GetString("skillEditor"), w = 250, h = 550}
eso_skillmanager.visible = false
eso_skillmanager.SkillProfile = {}
eso_skillmanager.SkillRecordingActive = false
eso_skillmanager.RecordSkillTmr = 0
eso_skillmanager.RegisteredButtonEventList = {}
eso_skillmanager.cskills = {} -- Current List of Skills, gets constantly updated each pulse
eso_skillmanager.prevSkillID = 0

eso_skillmanager.DefaultProfiles = {
	[1] = "DragonKnight",
	[2] = "Sorcerer",
	[3] = "Nightblade",
	[4] = "Templar",
}

function eso_skillmanager.ModuleInit() 	
	if (Settings.ESOMinion.gSMprofile == nil) then
		Settings.ESOMinion.gSMprofile = "None"
	end
		
	GUI_NewWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.x,eso_skillmanager.mainwindow.y,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h,"",true)
	GUI_NewComboBox(eso_skillmanager.mainwindow.name,GetString("profile"),"gSMprofile",GetString("generalSettings"),"None")
	
	GUI_NewButton(eso_skillmanager.mainwindow.name,GetString("autoetectSkills"),"SMAutodetect",GetString("skillEditor"))
	RegisterEventHandler("SMAutodetect",eso_skillmanager.AutoDetectSkills)	
	GUI_NewButton(eso_skillmanager.mainwindow.name,GetString("saveProfile"),"SMSaveEvent")	
	RegisterEventHandler("SMSaveEvent",eso_skillmanager.SaveProfile)	
	GUI_NewField(eso_skillmanager.mainwindow.name,GetString("newProfileName"),"gSMnewname",GetString("skillEditor"))
	GUI_NewButton(eso_skillmanager.mainwindow.name,GetString("newProfile"),"SMCreateNewProfile",GetString("skillEditor"))
	RegisterEventHandler("SMCreateNewProfile",eso_skillmanager.CreateNewProfile)
			
		
	gSMprofile = Settings.ESOMinion.gSMprofile
	gSMnewname = ""
  		
	GUI_SizeWindow(eso_skillmanager.mainwindow.name,eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.h)
	GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,GetString("generalSettings"))
	GUI_WindowVisible(eso_skillmanager.mainwindow.name,false)
	
	
	-- EDITOR WINDOW
	GUI_NewWindow(eso_skillmanager.editwindow.name,eso_skillmanager.mainwindow.x+eso_skillmanager.mainwindow.w,eso_skillmanager.mainwindow.y,eso_skillmanager.editwindow.w,eso_skillmanager.editwindow.h,"",true)		
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("maMarkerName"),"SKM_NAME","SkillDetails")
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("maMarkerID"),"SKM_ID","SkillDetails")
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("setsAttackRange"),"SKM_ATKRNG","SkillDetails")
	GUI_NewCheckbox(eso_skillmanager.editwindow.name,GetString("los"),"SKM_LOS","SkillDetails")
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("channeled"),"SKM_CHAN","SkillDetails")
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("minRange"),"SKM_MinR","SkillDetails")
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("maxRange"),"SKM_MaxR","SkillDetails")
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("targetType"),"SKM_TType","SkillDetails","Enemy,Self");
	GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("useOutOfCombat"),"SKM_OutOfCombat","SkillDetails","No,Yes,Either");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerHPGT"),"SKM_PHPL","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerHPLT"),"SKM_PHPB","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerPowerGT"),"SKM_PPowL","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("playerPowerLT"),"SKM_PPowB","SkillDetails");
	--GUI_NewField(eso_skillmanager.editwindow.name,GetString("playerHas"),"SKM_PEff1","SkillDetails");	
	--GUI_NewField(eso_skillmanager.editwindow.name,GetString("playerHasNot"),"SKM_PNEff1","SkillDetails");
	--GUI_NewNumeric(eso_skillmanager.editwindow.name,"Player has #Boons >","SKM_PBoonC","SkillDetails");
	--GUI_NewNumeric(eso_skillmanager.editwindow.name,"Player has #Conditions >","SKM_PCondC","SkillDetails");	
	--GUI_NewComboBox(eso_skillmanager.editwindow.name,GetString("targetMoving"),"SKM_TMove","SkillDetails","Either,Yes,No");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("targetHPGT"),"SKM_THPL","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("targetHPLT"),"SKM_THPB","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("enemiesNearCount"),"SKM_TECount","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("enemiesNearRange"),"SKM_TERange","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("alliesNearCount"),"SKM_TACount","SkillDetails");
	GUI_NewNumeric(eso_skillmanager.editwindow.name,GetString("alliesNearRange"),"SKM_TARange","SkillDetails");
	--GUI_NewField(eso_skillmanager.editwindow.name,GetString("targetHas"),"SKM_TEff1","SkillDetails");	
	--GUI_NewField(eso_skillmanager.editwindow.name,GetString("targetHasNot"),"SKM_TNEff1","SkillDetails");		
	--GUI_NewNumeric(eso_skillmanager.editwindow.name,"Target has #Boons >","SKM_TBoonC","SkillDetails");
	--GUI_NewNumeric(eso_skillmanager.editwindow.name,"Target has #Conditions >","SKM_TCondC","SkillDetails");	
	GUI_NewField(eso_skillmanager.editwindow.name,GetString("prevSkillID"),"SKM_PrevID","SkillDetails");	
	
	
	GUI_UnFoldGroup(eso_skillmanager.editwindow.name,"SkillDetails")
	GUI_SizeWindow(eso_skillmanager.editwindow.name,eso_skillmanager.editwindow.w,eso_skillmanager.editwindow.h)
	GUI_WindowVisible(eso_skillmanager.editwindow.name,false)
	
	GUI_NewButton(eso_skillmanager.editwindow.name,"DELETE","SMEDeleteEvent")
	RegisterEventHandler("SMEDeleteEvent",eso_skillmanager.EditorButtonHandler)	
	GUI_NewButton(eso_skillmanager.editwindow.name,"CLONE","SMECloneEvent")
	RegisterEventHandler("SMECloneEvent",eso_skillmanager.EditorButtonHandler)	
	GUI_NewButton(eso_skillmanager.editwindow.name,"DOWN","SMESkillDOWNEvent")	
	RegisterEventHandler("SMESkillDOWNEvent",eso_skillmanager.EditorButtonHandler)	
	GUI_NewButton(eso_skillmanager.editwindow.name,"UP","SMESkillUPEvent")
	RegisterEventHandler("SMESkillUPEvent",eso_skillmanager.EditorButtonHandler)
		
	eso_skillmanager.UpdateProfiles() -- Update the profiles dropdownlist
	GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
	eso_skillmanager.UpdateCurrentProfileData()	
end

function eso_skillmanager.UpdateCurrentProfileData()
    if ( gSMprofile ~= nil and gSMprofile ~= "" and gSMprofile ~= "None" ) then
        local profile = fileread(eso_skillmanager.profilepath..gSMprofile..".lua")
        if ( TableSize(profile) > 0) then
            local unsortedSkillList = {}			
            local newskill = {}            
			local i, line = next (profile)
            
			-- Profession Check			
			local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
           -- if ( tostring(key) == "Profession" and tonumber(id) == Player.class) then
               --- d("Skillprofile Profession matches Playerprofession, loading profile")
				
				if ( line ) then                
					while i and line do
						local _, key, value = string.match(line, "(%w+)_(%w+)=(.*)")
						--d("key: "..tostring(key).." value:"..tostring(value))
						
						if ( key and value ) then
							value = string.gsub(value, "\r", "")					
							if ( key == "END" ) then
								--d("Adding Skill :"..newskill.name.."Prio:"..tostring(newskill.prio))
								table.insert(unsortedSkillList,tonumber(newskill.prio),newskill)						
								newskill = {}
								elseif ( key == "ID" )then newskill.skillID = tonumber(value)
								elseif ( key == "NAME" )then newskill.name = value
								elseif ( key == "ATKRNG" )then newskill.atkrng = tostring(value)
								elseif ( key == "Prio" )then newskill.prio = tonumber(value)
								elseif ( key == "LOS" )then 
									if ( tostring(value) == "Yes" ) then newskill.los = "1" 
									elseif ( tostring(value) == "No" ) then newskill.los = "0" 
									else	newskill.los = tostring(value)
									end
								elseif ( key == "CHAN" )then newskill.channel = tonumber(value)	
								elseif ( key == "MinR" )then newskill.minRange = tonumber(value)
								elseif ( key == "MaxR" )then newskill.maxRange = tonumber(value)
								elseif ( key == "TType" )then newskill.ttype = tostring(value)
								elseif ( key == "OutOfCombat" )then newskill.ooc = tostring(value)
								elseif ( key == "PHPL" )then newskill.phpl = tonumber(value)
								elseif ( key == "PHPB" )then newskill.phpb = tonumber(value)
								elseif ( key == "PPowL" )then newskill.ppowl = tonumber(value)
								elseif ( key == "PPowB" )then newskill.ppowb = tonumber(value)
								elseif ( key == "PEff1" )then newskill.peff1 = tostring(value)
								elseif ( key == "PNEff1" )then newskill.pneff1 = tostring(value)
								elseif ( key == "PCondC" )then newskill.pcondc = tonumber(value)
								elseif ( key == "PBoonC" )then newskill.pboonc = tonumber(value)								
								elseif ( key == "TMove" )then newskill.tmove = tostring(value)
								elseif ( key == "THPL" )then newskill.thpl = tonumber(value)
								elseif ( key == "THPB" )then newskill.thpb = tonumber(value)						
								elseif ( key == "TECount" )then newskill.tecount = tonumber(value)
								elseif ( key == "TERange" )then newskill.terange = tonumber(value)
								elseif ( key == "TACount" )then newskill.tacount = tonumber(value)
								elseif ( key == "TARange" )then newskill.tarange = tonumber(value)
								elseif ( key == "TEff1" )then newskill.teff1 = tostring(value)
								elseif ( key == "TNEff1" )then newskill.tneff1 = tostring(value)						
								elseif ( key == "TCondC" )then newskill.tcondc = tonumber(value)								
								elseif ( key == "TBoonC" )then newskill.tboonc = tonumber(value)
								elseif ( key == "PrevID" )then newskill.previd = tostring(value)		
							end
						else
							ml_error("Error loading inputline: Key: "..(tostring(key)).." value:"..tostring(value))
						end				
						i, line = next (profile,i)
					end
				end
				
				-- Create UI Fields
				local sortedSkillList = {}
				if ( TableSize(unsortedSkillList) > 0 ) then
					local i,skill = next (unsortedSkillList)
					while i and skill do
						sortedSkillList[#sortedSkillList+1] = skill
						i,skill = next (unsortedSkillList,i)
					end
					table.sort(sortedSkillList, function(a,b) return a.prio < b.prio end )	
					for i = 1,TableSize(sortedSkillList),1 do					
						if (sortedSkillList[i] ~= nil ) then
							sortedSkillList[i].prio = i						
							eso_skillmanager.CreateNewSkillEntry(sortedSkillList[i])
						end
					end
				end			
				
			--else
			--	d("Skillprofile Profession DOES NOT match Playerprofession")
			--	d("key: "..tostring(key).." id:"..tostring(id))
            --end            
        else
            d("Profile is empty..")			
        end		
    else
        d("No new SkillProfile selected!")
		gSMprofile = "None"
    end
    GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
end

function eso_skillmanager.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		--d(tostring(k).." = "..tostring(v))
		if ( k == "gSMprofile" ) then			
			eso_skillmanager.SkillRecordingActive = false				
			GUI_WindowVisible(eso_skillmanager.editwindow.name,false)
			GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
			eso_skillmanager.SkillProfile = {}
			eso_skillmanager.UpdateCurrentProfileData()
			Settings.ESOMinion.gSMprofile = tostring(v)
		elseif ( k == "SKM_NAME" ) then eso_skillmanager.SkillProfile[SKM_Prio].name = v
		elseif ( k == "SKM_ID" ) then eso_skillmanager.SkillProfile[SKM_Prio].skillID = v
		elseif ( k == "SKM_ATKRNG" ) then eso_skillmanager.SkillProfile[SKM_Prio].atkrng = v
		elseif ( k == "SKM_LOS" ) then eso_skillmanager.SkillProfile[SKM_Prio].los = v
		elseif ( k == "SKM_INSTA" ) then eso_skillmanager.SkillProfile[SKM_Prio].insta = v
		elseif ( k == "SKM_CHAN" ) then eso_skillmanager.SkillProfile[SKM_Prio].channel = tonumber(v)	
		elseif ( k == "SKM_MinR" ) then eso_skillmanager.SkillProfile[SKM_Prio].minRange = tonumber(v)
		elseif ( k == "SKM_MaxR" ) then eso_skillmanager.SkillProfile[SKM_Prio].maxRange = tonumber(v)
		elseif ( k == "SKM_TType" ) then eso_skillmanager.SkillProfile[SKM_Prio].ttype = v
		elseif ( k == "SKM_OutOfCombat" ) then eso_skillmanager.SkillProfile[SKM_Prio].ooc = v
		elseif ( k == "SKM_PHPL" ) then eso_skillmanager.SkillProfile[SKM_Prio].phpl = tonumber(v)
		elseif ( k == "SKM_PHPB" ) then eso_skillmanager.SkillProfile[SKM_Prio].phpb = tonumber(v)
		elseif ( k == "SKM_PPowL" ) then eso_skillmanager.SkillProfile[SKM_Prio].ppowl = tonumber(v)
		elseif ( k == "SKM_PPowB" ) then eso_skillmanager.SkillProfile[SKM_Prio].ppowb = tonumber(v)
		elseif ( k == "SKM_PEff1" ) then eso_skillmanager.SkillProfile[SKM_Prio].peff1 = v
		elseif ( k == "SKM_PCondC" ) then eso_skillmanager.SkillProfile[SKM_Prio].pcondc = tonumber(v)
		elseif ( k == "SKM_PNEff1" ) then eso_skillmanager.SkillProfile[SKM_Prio].pneff1 = v
		elseif ( k == "SKM_TMove" ) then eso_skillmanager.SkillProfile[SKM_Prio].tmove = v
		elseif ( k == "SKM_THPL" ) then eso_skillmanager.SkillProfile[SKM_Prio].thpl = tonumber(v)
		elseif ( k == "SKM_THPB" ) then eso_skillmanager.SkillProfile[SKM_Prio].thpb = tonumber(v)
		elseif ( k == "SKM_TECount" ) then eso_skillmanager.SkillProfile[SKM_Prio].tecount = tonumber(v)
		elseif ( k == "SKM_TERange" ) then eso_skillmanager.SkillProfile[SKM_Prio].terange = tonumber(v)
		elseif ( k == "SKM_TACount" ) then eso_skillmanager.SkillProfile[SKM_Prio].tacount = tonumber(v)
		elseif ( k == "SKM_TARange" ) then eso_skillmanager.SkillProfile[SKM_Prio].tarange = tonumber(v)
		elseif ( k == "SKM_TEff1" ) then eso_skillmanager.SkillProfile[SKM_Prio].teff1 = v
		elseif ( k == "SKM_TNEff1" ) then eso_skillmanager.SkillProfile[SKM_Prio].tneff1 = v				
		elseif ( k == "SKM_TCondC" ) then eso_skillmanager.SkillProfile[SKM_Prio].tcondc = tonumber(v)
		elseif ( k == "SKM_PBoonC" ) then eso_skillmanager.SkillProfile[SKM_Prio].pboonc = tonumber(v)
		elseif ( k == "SKM_TBoonC" ) then eso_skillmanager.SkillProfile[SKM_Prio].tboonc = tonumber(v)
		elseif ( k == "SKM_PrevID" ) then eso_skillmanager.SkillProfile[SKM_Prio].previd = v		
		end
	end
end

function eso_skillmanager.EditorButtonHandler(event)
	eso_skillmanager.SkillRecordingActive = false
	if ( event == "SMECloneEvent") then
		local clone = deepcopy(eso_skillmanager.SkillProfile[SKM_Prio])
		clone.prio = table.maxn(eso_skillmanager.SkillProfile)+1
		eso_skillmanager.CreateNewSkillEntry(clone)
		
	elseif ( event == "SMEDeleteEvent") then				
		if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then
			GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
			local i,s = next ( eso_skillmanager.SkillProfile, SKM_Prio)
			while i and s do
				s.prio = s.prio - 1
				eso_skillmanager.SkillProfile[SKM_Prio] = s
				SKM_Prio = i
				i,s = next ( eso_skillmanager.SkillProfile, i)
			end
			eso_skillmanager.SkillProfile[SKM_Prio] = nil
			eso_skillmanager.RefreshSkillList()	
			GUI_WindowVisible(eso_skillmanager.editwindow.name,false)
		end
		
	elseif (event == "SMESkillUPEvent") then		
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
		
	elseif ( event == "SMESkillDOWNEvent") then			
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
end

function eso_skillmanager.RefreshSkillList()

	if ( TableSize( eso_skillmanager.SkillProfile ) > 0 ) then
		local i,s = next ( eso_skillmanager.SkillProfile )
		while i and s do			
			eso_skillmanager.CreateNewSkillEntry(s)
			i,s = next ( eso_skillmanager.SkillProfile , i )
		end
	end
	GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
end

function eso_skillmanager.SaveProfile()
	local filename = ""
    local isnew = false
    -- Save under new name if one was entered
    if ( gSMnewname ~= "" ) then
        filename = gSMnewname
        gSMnewname = ""
        isnew = true
    elseif (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
        filename = gSMprofile
        gSMnewname = ""		
    end
	
	 -- Save current Profiledata into the Profile-file 
    if ( filename ~= "" ) then
		d("Saving Profile Data into File: "..filename)
		local profession = Player.class
		local string2write = "SKM_Profession_"..tostring(profession).."="..tostring(profession).."\n"
		local skID,skill = next (eso_skillmanager.SkillProfile)
		while skID and skill do
			string2write = string2write.."SKM_NAME="..skill.name.."\n"
			string2write = string2write.."SKM_ID="..skill.skillID.."\n"
			string2write = string2write.."SKM_ATKRNG="..skill.atkrng.."\n"			
			string2write = string2write.."SKM_Prio="..skill.prio.."\n"
			string2write = string2write.."SKM_LOS="..skill.los.."\n"
			string2write = string2write.."SKM_CHAN="..skill.channel.."\n"			
			string2write = string2write.."SKM_MinR="..skill.minRange.."\n"
			string2write = string2write.."SKM_MaxR="..skill.maxRange.."\n" 
			string2write = string2write.."SKM_TType="..skill.ttype.."\n"
			string2write = string2write.."SKM_OutOfCombat="..skill.ooc.."\n"
			string2write = string2write.."SKM_PHPL="..skill.phpl.."\n" 
			string2write = string2write.."SKM_PHPB="..skill.phpb.."\n" 
			string2write = string2write.."SKM_PPowL="..skill.ppowl.."\n" 
			string2write = string2write.."SKM_PPowB="..skill.ppowb.."\n" 
			string2write = string2write.."SKM_PEff1="..skill.peff1.."\n" 
			string2write = string2write.."SKM_PCondC="..skill.pcondc.."\n" 
			string2write = string2write.."SKM_PNEff1="..skill.pneff1.."\n" 								
			string2write = string2write.."SKM_TMove="..skill.tmove.."\n" 
			string2write = string2write.."SKM_THPL="..skill.thpl.."\n" 
			string2write = string2write.."SKM_THPB="..skill.thpb.."\n" 
			string2write = string2write.."SKM_TECount="..skill.tecount.."\n" 
			string2write = string2write.."SKM_TERange="..skill.terange.."\n" 
			string2write = string2write.."SKM_TACount="..skill.tacount.."\n" 
			string2write = string2write.."SKM_TARange="..skill.tarange.."\n" 	
			string2write = string2write.."SKM_TEff1="..skill.teff1.."\n" 
			string2write = string2write.."SKM_TNEff1="..skill.tneff1.."\n" 
			string2write = string2write.."SKM_TCondC="..skill.tcondc.."\n" 
			string2write = string2write.."SKM_PBoonC="..skill.pboonc.."\n" 
			string2write = string2write.."SKM_TBoonC="..skill.tboonc.."\n"
			string2write = string2write.."SKM_PrevID="..skill.previd.."\n"			
			string2write = string2write.."SKM_END=0\n"
		
			skID,skill = next (eso_skillmanager.SkillProfile,skID)
		end	
		d(filewrite(eso_skillmanager.profilepath ..filename..".lua",string2write))
		
		if ( isnew ) then
            gSMprofile_listitems = gSMprofile_listitems..","..filename
            gSMprofile = filename
            Settings.ESOMinion.gSMprofile = filename
        end
	else
		ml_error("You need to enter a new Filename first!!")
	end
end

function eso_skillmanager.CreateNewProfile()
	-- Delete existing Skills
    GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
    gSMprofile = "None"
    Settings.ESOMinion.gSMprofile = gSMprofile
    gSMnewname = ""	
	eso_skillmanager.SkillProfile = {}
end

function eso_skillmanager.AutoDetectSkills()
	eso_skillmanager.RecordSkillTmr = ml_global_information.Now
	eso_skillmanager.SkillRecordingActive = true
end

function eso_skillmanager.UpdateProfiles()
	-- Grab all Profiles and enlist them in the dropdown field
	local profiles = "None"
	local found = "None"	
	local profilelist = dirlist(eso_skillmanager.profilepath,".*lua")
	if ( TableSize(profilelist) > 0) then			
		local i,profile = next ( profilelist)
		while i and profile do				
			profile = string.gsub(profile, ".lua", "")
			--d("Skillprofile: "..tostring(profile).." == "..tostring(gSMnewname))
			
			-- Make sure it matches our profession
			local file = fileread(eso_skillmanager.profilepath..profile..".lua")
			if ( TableSize(file) > 0) then
				local i, line = next (file)					
				local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
				-- Take the profession restriction out for now since I'm not sure if "Templar" is also the same in other languages
				--if ( tostring(key) == "Profession" and tonumber(id) == Player.profession) then
					profiles = profiles..","..profile
					if ( Settings.ESOMinion.gSMprofile ~= nil and Settings.ESOMinion.gSMprofile == profile ) then
						d("Last Profile found : "..profile)
						found = profile					
					end					
				--end
			end
			i,profile = next ( profilelist,i)
		end		
	else
		ml_error("No Skillmanager profiles for our current Profession found")		
	end
	gSMprofile_listitems = profiles
	
	-- try to load default profiles
	--[[if ( found == "None" ) then
		local defaultprofile = eso_skillmanager.DefaultProfiles[tonumber(Player.profession)]
		if ( defaultprofile ) then
			d("Loading default Profile for our profession")	
			eso_skillmanager.SkillRecordingActive = false				
			GUI_WindowVisible(eso_skillmanager.editwindow.name,false)
			GUI_DeleteGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
			eso_skillmanager.SkillProfile = {}
			eso_skillmanager.UpdateCurrentProfileData()
			Settings.ESOMinion.gSMprofile = tostring(defaultprofile)
			gSMprofile = defaultprofile
			return
		end
	end]]
	
	gSMprofile = found
end

function eso_skillmanager.CheckForNewSkills()
	
	local ABList = AbilityList("")
	if (ABList) then
		local id,skill = next(ABList)
		while (id and skill ) do			
			local found = false
				if ( TableSize( eso_skillmanager.SkillProfile ) > 0 ) then
					local i,s = next ( eso_skillmanager.SkillProfile )
					while i and s do
						if s.skillID == skill.id then
							found = true
							break
						end
						i,s = next ( eso_skillmanager.SkillProfile , i )
					end
				end
				if not found then
					skill.skillID = skill.id -- ya I'm lazy
					eso_skillmanager.CreateNewSkillEntry(skill)
				end
			
			
			id,skill = next(ABList,id)
		end	
	end	
		
	GUI_UnFoldGroup(eso_skillmanager.mainwindow.name,"ProfileSkills")
end

function eso_skillmanager.CreateNewSkillEntry(skill)	
	if (skill ~= nil ) then
		local skname = skill.name
		local skID = skill.skillID		
		if (skname ~= "" and skID ) then
			local newskillprio = skill.prio or table.maxn(eso_skillmanager.SkillProfile)+1
			local bevent = tostring(newskillprio)
			
			GUI_NewButton(eso_skillmanager.mainwindow.name, tostring(bevent)..": "..skname, bevent,"ProfileSkills")
			if ( eso_skillmanager.RegisteredButtonEventList[newskillprio] == nil ) then
				RegisterEventHandler(bevent,eso_skillmanager.EditSkill)
				eso_skillmanager.RegisteredButtonEventList[newskillprio] = 1
			end	
			
			local sRange = skill.range
			if ( sRange == 0 ) then 
				sRange = skill.radius
			end
			
			eso_skillmanager.SkillProfile[newskillprio] = {		
				skillID = skID,
				prio = newskillprio,
				name = skname,
				atkrng = skill.atkrng or "1",		
				los = skill.los or "1",
				channel = skill.channel or skill.channeltime or 0,
				minRange = skill.minRange or 0,
				maxRange = skill.maxRange or sRange or 0,
				ttype = skill.ttype or "Enemy",
				ooc = skill.ooc or "No",
				phpl = skill.phpl or 0,
				phpb = skill.phpb or 0,
				ppowl = skill.ppowl or skill.cost,
				ppowb = skill.ppowb or 0,
				peff1 = skill.peff1 or "",
				pcondc = skill.pcondc or 0,
				pneff1 = skill.pneff1 or "",
				tmove = skill.tmove or "Either",
				thpl = skill.thpl or 0,
				thpb = skill.thpb or 0,
				tecount = skill.tecount or 0,
				terange = skill.terange or 0,
				tacount = skill.tacount or 0,
				tarange = skill.tarange or 0,
				teff1 = skill.teff1 or "",
				tneff1 = skill.tneff1 or "",
				tcondc = skill.condc or 0,
				pboonc = skill.pboonc or 0,
				tboonc = skill.tboonc or 0,
				previd = skill.previd or ""				
			}		
		end		
	end
end

function eso_skillmanager.EditSkill(event)
	local wnd = GUI_GetWindowInfo(eso_skillmanager.mainwindow.name)	
	GUI_MoveWindow( eso_skillmanager.editwindow.name, wnd.x+wnd.width,wnd.y) 
	GUI_WindowVisible(eso_skillmanager.editwindow.name,true)
	-- Update EditorData
	local skill = eso_skillmanager.SkillProfile[tonumber(event)]	
	if ( skill ) then		
		SKM_NAME = skill.name or ""
		SKM_ID = skill.skillID or 0
		SKM_ATKRNG = skill.atkrng or "1"
		SKM_Prio = tonumber(event)
		SKM_LOS = skill.los or "1"
		SKM_CHAN = skill.channel or "0"
		SKM_MinR = tonumber(skill.minRange) or 0
		SKM_MaxR = tonumber(skill.maxRange) or 160
		SKM_TType = skill.ttype or "Either"
		SKM_OutOfCombat = skill.ooc or "No"
		SKM_PHPL = tonumber(skill.phpl) or 0
		SKM_PHPB = tonumber(skill.phpb) or 0
		SKM_PPowL = tonumber(skill.ppowl) or 0
		SKM_PPowB = tonumber(skill.ppowb) or 0
		SKM_PEff1 = skill.peff1 or ""
		SKM_PCondC = tonumber(skill.pcondc) or 0
		SKM_PNEff1 = skill.pneff1 or ""
		SKM_TMove = skill.tmove or "Either"
		SKM_THPL = tonumber(skill.thpl) or 0
		SKM_THPB = tonumber(skill.thpb) or 0
		SKM_TECount = tonumber(skill.tecount) or 0
		SKM_TERange = tonumber(skill.terange) or 0
		SKM_TACount = tonumber(skill.tacount) or 0
		SKM_TARange = tonumber(skill.tarange) or 0
		SKM_TEff1 = skill.teff1 or ""
		SKM_TNEff1 = skill.tneff1 or ""
		SKM_TCondC = tonumber(skill.tcondc) or 0
		SKM_PBoonC = tonumber(skill.pboonc) or 0
		SKM_TBoonC = tonumber(skill.tboonc) or 0
		SKM_PrevID = skill.previd or ""
	end
end


function eso_skillmanager.OnUpdate( tick )
	
	if ( eso_skillmanager.SkillRecordingActive ) then
		if ( tick - eso_skillmanager.RecordSkillTmr > 30000) then -- max record 30seconds
			eso_skillmanager.RecordSkillTmr = 0
			eso_skillmanager.SkillRecordingActive = false
		elseif ( tick - eso_skillmanager.RecordSkillTmr > 500 ) then
			eso_skillmanager.RecordSkillTmr = tick
			eso_skillmanager.CheckForNewSkills()
		end		
	end
	
end

function eso_skillmanager.ToggleMenu()
	if (eso_skillmanager.visible) then
		GUI_WindowVisible(eso_skillmanager.mainwindow.name,false)	
		GUI_WindowVisible(eso_skillmanager.editwindow.name,false)
		
		eso_skillmanager.visible = false
	else
		local wnd = GUI_GetWindowInfo("MinionBot")	
		GUI_MoveWindow( eso_skillmanager.mainwindow.name, wnd.x+wnd.width,wnd.y) 
		GUI_WindowVisible(eso_skillmanager.mainwindow.name,true)	
		eso_skillmanager.visible = true
	end
end


-- Updates the MaxAttackRange and our cskills List
function eso_skillmanager.GetAttackRange()
	
	local maxrange = 5 -- 5 is the melee sword attack range
	
	if ( gAttackRange == GetString("aRange")) then
		maxrange = 28
	elseif ( gAttackRange == GetString("aAutomatic")) then
		-- go through all current skills and grab the one which is in our skillmanagerprofile + set to "Set Attackrange"
		local ABList = AbilityList("")
		if (ABList) then
			local id,skill = next(ABList)
			while (id and skill ) do			
				
				if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then				
					local sID = skill.id
					for k,v in pairs(eso_skillmanager.SkillProfile) do					
						--d("skill "..tostring(sID) .." vs "..tostring(v.skillID) .." "..v.name)						
						if ( v.skillID == sID) then					
							
							-- Get Max Attack Range for global use
							if (v.atkrng == "1" ) then
								--d(skill.name.." "..tostring(skill.maxRange).." "..tostring(v.name).." "..tostring(v.maxRange))
								--TODO ADD CD CHECK if ( skill.cooldown == 0 and v.maxRange > maxrange) then
								if ( v.maxRange > maxrange) then
									maxrange = v.maxRange
								end							
							end						
							break
						end
					end
				end	
				id,skill = next(ABList,id)
			end	
		end	
		
	end
	return maxrange
end

-- goes through our skilllist and checks if we can attack the enemy with our current attackrange
function eso_skillmanager.CanAttackTarget( TargetID )
	local ABList = AbilityList("")
	
	if (ABList) then
		local id,skill = next(ABList)
		while (id and skill ) do			
			
			if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then				
				local sID = skill.id
				for k,v in pairs(eso_skillmanager.SkillProfile) do					
					--d("skill "..tostring(sID) .." vs "..tostring(v.skillID) .." "..v.name)						
					if ( v.skillID == sID) then						
						if ( AbilityList:CanCast(sID,TargetID) == 10 ) then
							return true
						end
						break
					end
				end
			end	
			id,skill = next(ABList,id)
		end	
	end
	return false
end

function eso_skillmanager.AttackTarget( TargetID )	
	local fastcastcount = 0
	
	--Valid Target?
	local target
	if ( not TargetID or TargetID == 0) then
		target = Player:GetTarget()
		if ( target ) then TargetID = target.id end
	else
		target = EntityList:Get(TargetID)
		
	end
	
		
	if ( target and TargetID > 0 and target.attackable ) then	
		local mybuffs = nil --Player.buffs		
		local targetbuffs = nil
		--[[if ( target.isCharacter) then
			targetbuffs = target.buffs
		end]]
		if ( TableSize(eso_skillmanager.SkillProfile) > 0 ) then --and Player:CanCast()) then
			for prio,skill in pairs(eso_skillmanager.SkillProfile) do
				
				local ab = AbilityList:Get(skill.skillID)
				if ( ab and AbilityList:IsTargetInRange(ab.id,TargetID) and AbilityList:CanCast(ab.id,TargetID) == 10 ) then
										
					-- TARGETTYPE + LOS + RANGE + MOVEMENT + HEALTH CHECK
					
					if (skill.ttype == "Enemy" and (							
						(skill.minRange > 0 and target.distance < skill.minRange)
						or (skill.maxRange > 0 and target.distance > skill.maxRange)
						or (skill.thpl > 0 and skill.thpl > target.hp.percent)
						or (skill.thpb > 0 and skill.thpb < target.hp.percent)
						or (skill.los == "Yes" and not target.los)
						)) then continue end	
							
					-- PLAYER HEALTH,POWER,ENDURANCE CHECK				
					if ( (skill.phpl > 0 and skill.phpl > Player.hp.percent)
						or (skill.phpb > 0 and skill.phpb < Player.hp.percent)
						--or (skill.ppowl > 0 and skill.ppowl > Player.power)
						--or (skill.ppowb > 0 and skill.ppowb < Player.power)					
						) then continue end
						
					--[[ PLAYER BUFF AND CONDITION CHECKS
					if ( skill.peff1 ~= "" and mybuffs )then 	
						--Possible value in peff1: "134,245+123,552+123+531"
						--d("Buffcheck : "..tostring(mc_helper.BufflistHasBuffs(mybuffs, skill.peff1)))
						if ( not mc_helper.BufflistHasBuffs(mybuffs, skill.peff1) ) then continue end											
					end
					if ( skill.pneff1 ~= "" and mybuffs )then 	
						--Possible value in pneff1: "134,245+123,552+123+531"
						--d("Not Buffcheck : "..tostring(mc_helper.BufflistHasBuffs(mybuffs, skill.pneff1)))
						if ( mc_helper.BufflistHasBuffs(mybuffs, skill.pneff1) ) then continue end
					end						
					if ( skill.pcondc > 0 and mybuffs ) then																		
						if (CountConditions(mybuffs) <= skill.pcondc) then continue end								
					end
					if ( skill.pboonc > 0 and mybuffs ) then
						if (CountBoons(mybuffs) <= skill.pboonc) then continue end						
					end	]]
					--ALLIE AE CHECK
					if ( skill.tacount > 0 and skill.tarange > 0) then
						--d("ALLIE AE CHECK "..tostring(TableSize(EntityList("friendly,maxdistance="..skill.tarange..",distanceto="..target.id))))
						if (  TableSize(EntityList("friendly,maxdistance="..skill.tarange..",distanceto="..target.id)) < skill.tacount) then continue end
					end	
					
					--[[ TARGET BUFF CHECKS 
					if ( skill.teff1 ~= "" and targetbuffs )then 
						--Possible value in teff1: "134,245+123,552+123+531"
						--d("Target Buffcheck : "..tostring(mc_helper.BufflistHasBuffs(mybuffs, skill.teff1)))
						if ( not mc_helper.BufflistHasBuffs(targetbuffs, skill.teff1) ) then continue end	
					end						
					if ( skill.tneff1 ~= "" and targetbuffs )then 
						--Possible value in tneff1: "134,245+123,552+123+531"
						--d("Not Target Buffcheck : "..tostring(mc_helper.BufflistHasBuffs(mybuffs, skill.tneff1)))
						if ( mc_helper.BufflistHasBuffs(targetbuffs, skill.tneff1) ) then continue end
					end]]
					-- TARGET AE CHECK
					if ( skill.tecount > 0 and skill.terange > 0) then
						if ( TableSize(EntityList("alive,attackable,maxdistance="..skill.terange..",distanceto="..target.id)) < skill.tecount) then continue end
					end
					--[[ TARGET #CONDITIONS CHECK
					if ( skill.tcondc > 0 and targetbuffs ) then
						if (CountConditions(targetbuffs) <= skill.tcondc) then continue end			
					end	
					-- TARGET #BOON CHECK
					if ( skill.tboonc > 0 and targetbuffs ) then
						if (CountBoons(targetbuffs) <= skill.tboonc) then continue end						
					end	]]
												
					 -- PREVIOUS SKILL					
                    if ( eso_skillmanager.prevSkillID ~= 0 and skill.previd ~= "" ) then
                        --d("Previous SkillID "..tostring(eso_skillmanager.prevSkillID))
						if ( not StringContains(skill.previd, eso_skillmanager.prevSkillID) ) then continue end
                    end
					
										
					d("Casting.."..ab.name.." at "..target.name.."Result: "..tostring(AbilityList:CanCast(ab.id,TargetID)))								
					if ( AbilityList:Cast(ab.id,TargetID) ) then
						--d("Casting on Target: "..tostring(eso_skillmanager.cskills[currentSlot].name))
						eso_skillmanager.prevSkillID = ab.id															
					end	
						
					if ( skill.channel > 0 ) then
						-- Add a tiny delay so "iscasting" gets true for this spell, not interrupting it on the next pulse
						ml_global_information.lasttick = ml_global_information.lasttick + skill.channel - 500
						return true
					else										
						fastcastcount = fastcastcount + 1 
						if ( fastcastcount > 1) then
							
							--[[Swap Weapon check			
							if ( ml_global_information.AttackRange < 300 and target.distance > ml_global_information.AttackRange ) then
								eso_skillmanager.SwapWeaponCheck("Range")
							else	 
								eso_skillmanager.SwapWeaponCheck("CoolDown")
							end]]
							return true
						end
						ml_global_information.Wait(250)
					end				
				end				
			end
		end
	end
	return false
end

function eso_skillmanager.HealMe()
	ml_log("ADD SM HEALME")
end

RegisterEventHandler("SkillManager.toggle", eso_skillmanager.ToggleMenu)
RegisterEventHandler("GUI.Update",eso_skillmanager.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",eso_skillmanager.ModuleInit)