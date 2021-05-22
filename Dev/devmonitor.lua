Dev = { }
Dev.lastticks = 0
Dev.running = false
Dev.curTask = nil

Dev.aggro = false
Dev.alive = false
Dev.attackable = false
Dev.clustered = ""
Dev.contentid = ""
Dev.dead = false
Dev.distanceto = ""
Dev.exclude_contentid = ""
Dev.friendly = false
Dev.gatherable = false
Dev.highesthealth = false
Dev.hostile = false
Dev.incombat = false
Dev.interacttype = ""
Dev.isvendor = false
Dev.lootable = false
Dev.los = false
Dev.lowesthealth = false
Dev.maxdistance = ""
Dev.maxhealth = ""
Dev.maxlevel = ""
Dev.maxpathdistance = ""
Dev.mindistance = ""
Dev.minhealth = ""
Dev.nearest = false
Dev.nocritter = false
Dev.noplayersaround = false
Dev.notincombat = false
Dev.notnpc= false
Dev.npc = false
Dev.onmesh = false
Dev.player= false
Dev.questinteraction = false
Dev.shortestpath = false
Dev.targetable = false
Dev.targeting = ""
Dev.targetingme = false

Dev.GUI = {
	open = false,
	visible = true,
}

function Dev.ModuleInit()
	gDevScannerString = ""
	ml_gui.ui_mgr:AddMember({ id = "ESOMINION##MENU_ACR", name = "Dev", onClick = function() Dev.GUI.open = not Dev.GUI.open end, tooltip = "Open the Dev addon."},"ESOMINION##MENU_HEADER")
end

function Dev.GUIVarUpdate(Event, NewVals, OldVals)
    for k,v in pairs(NewVals) do
        if (k == "HackNoCl") then
            if ( v == "1" ) then
                d(Player:NoClip(true))
            else
                d(Player:NoClip(false))
            end        
        end	
	end
end
function Dev.DrawCall(event, ticks )
	
	if ( Dev.GUI.open  ) then 
		GUI:SetNextWindowPosCenter(GUI.SetCond_Appearing)
		GUI:SetNextWindowSize(500,400,GUI.SetCond_FirstUseEver) --set the next window size, only on first ever
		Dev.GUI.visible, Dev.GUI.open = GUI:Begin("Dev-Monitor", Dev.GUI.open)
		if ( Dev.GUI.visible ) then 
			local gamestate = GetGameState()
									
			GUI:PushStyleVar(GUI.StyleVar_FramePadding, 4, 0)
			GUI:PushStyleVar(GUI.StyleVar_ItemSpacing, 8, 2)

			if ( GUI:TreeNode("UI Events")) then
				Dev.logUiEvent = GUI:Checkbox("Logs UI events", Dev.logUiEvent)
				GUI:TreePop()
			end
			-- cbk: Addon Controls
			
			if ( GUI:TreeNode("AddonControls")) then
				GUI:PushItemWidth(200); gDevAddonTextFilter = GUI:InputText("Filter by Name",gDevAddonTextFilter); GUI:PopItemWidth();
				gDevAddonOpenFilter = GUI:Checkbox("Show Open Only",gDevAddonOpenFilter)
				gDevAddonClosedFilter = GUI:Checkbox("Show Closed Only",gDevAddonClosedFilter)
				
				if ( GUI:TreeNode("Active Controls")) then
					--local controls = GetControls()
					if (table.valid(controls)) then
						for id, e in pairs(controls) do
							if (gDevAddonTextFilter == "" or string.contains(e.name,gDevAddonTextFilter)) then
								
								local isopen = e:IsOpen()
								if ((gDevAddonOpenFilter and isopen) or (gDevAddonClosedFilter and not isopen) or (not gDevAddonOpenFilter and not gDevAddonClosedFilter)) then
									GUI:PushItemWidth(150)
									if ( GUI:TreeNode(tostring(id).." - "..e.name.." ("..tostring(table.size(e:GetActions())).." / "..tostring(table.size(e:GetData()))..")") ) then
										GUI:BulletText("Ptr") GUI:SameLine(200) GUI:InputText("##Devc0"..tostring(id),tostring(string.format( "%X",e.ptr)))
										
										GUI:BulletText("IsOpen") GUI:SameLine(200) GUI:InputText("##Devc1"..tostring(id),tostring(isopen))
										local x,y = e:GetXY()
										GUI:BulletText("Position") GUI:SameLine(200) GUI:InputText("##Devc1pos"..tostring(id),tostring(x).. ", "..tostring(y)) 
										GUI:PushItemWidth(50)
										gDevX = GUI:InputText("##Devc1pos2"..tostring(id),tostring(gDevX)) 
										GUI:SameLine(140) 
										GUI:PushItemWidth(50)
										gDevY = GUI:InputText("##Devc1pos3"..tostring(id),tostring(gDevY))
									
										GUI:SameLine(200)
									
									if (GUI:Button("Set Pos",75,15) ) then e:SetXY(tonumber(gDevX),tonumber(gDevY)) end
										
										
										GUI:PushItemWidth(150)
										
										if (isopen == false) then
											if (GUI:Button("Open",100,15) ) then d("Opening Control Result: "..tostring(e:Open())) end
											GUI:SameLine()
											if (GUI:Button("Destroy",100,15) ) then d("Destroy Control Result: "..tostring(e:Destroy())) end
											
										else
											if (GUI:Button("Close",100,15) ) then d("Closing Control Result: "..tostring(e:Close())) end
											GUI:SameLine()
											if (GUI:Button("Destroy",100,15) ) then d("Destroy Control Result: "..tostring(e:Destroy())) end
											
											local ac = e:GetActions()
											if (table.valid(ac)) then
												GUI:SetNextTreeNodeOpened(true,GUI.SetCond_Always)
												if ( GUI:TreeNode("Control Actions##"..tostring(id)) ) then
													for aid, action in pairs(ac) do
														if (GUI:Button(action,150,15) ) then d("Action Result with arg "..tostring(Dev.addoncontrolarg).." :" ..tostring(e:Action(action,Dev.addoncontrolarg))) end
														GUI:SameLine()
														if (not Dev.addoncontrolarg) then Dev.addoncontrolarg = 0 end
														Dev.addoncontrolarg = GUI:InputInt("Arg 1##"..tostring(aid)..tostring(id), Dev.addoncontrolarg)
													end
													GUI:TreePop()
												end
											end

											local ad = e:GetData()
											if (table.valid(ad)) then
												for key, value in pairs(ad) do	
													if (type(value) == "table") then
														GUI:BulletText(key)
														for vk,vv in pairs(value) do
															if (type(vv) == "table") then
																GUI:Text("") GUI:SameLine(0,30) GUI:Text("["..tostring(vk).."] -") GUI:SameLine(0,10)
																for vvk,vvv in pairs(vv) do
																	GUI:Text("["..tostring(vvk).."]:") GUI:SameLine(0,5) GUI:Text(vvv) GUI:SameLine(0,5)
																end
															else
																GUI:BulletText(vk) GUI:SameLine(200) GUI:InputText("##Devcvdata"..tostring(vk),tostring(vv))
															end
															GUI:NewLine()
														end
													else
														GUI:BulletText(key) GUI:SameLine(200) GUI:InputText("##Devcdata"..tostring(key),tostring(value))
													end
												end										
											end
                                        											
											if ( GUI:TreeNode("Strings##"..tostring(id)) ) then
												local str = e:GetStrings()
												if (table.valid(str)) then
													for key, value in pairs(str) do												
														GUI:BulletText(tostring(key)) GUI:SameLine(200) GUI:InputText("##Devcdatastr"..tostring(key),value)													
													end										
												end
												GUI:TreePop()
											end	

											if (GUI:TreeNode("RawData##"..tostring(id)) ) then
												local datas = e:GetRawData()
												if (table.valid(datas)) then	
													GUI:Separator()                                            
													GUI:Columns(3, "##RawDataDetails",true)
													GUI:Text("Index"); GUI:NextColumn()
													GUI:Text("Type"); GUI:NextColumn()
													GUI:Text("Value"); GUI:NextColumn()
													GUI:Separator()             
													for index, data in pairs(datas) do			
														if (data.type ~= "0") then
															GUI:Text(tostring(index)) GUI:NextColumn()
															GUI:Text(tostring(data.type)) GUI:NextColumn()
															GUI:PushItemWidth(500)
															if (data.type == "int32") then
																GUI:Text(tostring(data.value))
															elseif (data.type == "uint32") then
																GUI:Text(tostring(data.value))
															elseif (data.type == "bool") then
																GUI:Text(tostring(data.value))
															elseif (data.type == "string") then
																GUI:Text(data.value)
															elseif (data.type == "float") then
																GUI:Text(tostring(data.value))
															elseif (data.type == "4bytes") then
																GUI:Text("A: "..tostring(data.value.A).." B: "..tostring(data.value.B).." C: "..tostring(data.value.C).." D: "..tostring(data.value.D))
															else
																GUI:Text("")  
															end        
															GUI:NextColumn()  
															GUI:PopItemWidth()                                           
														end
													end	
													GUI:Separator()
													GUI:Columns(1)		
												end
												GUI:TreePop()
											end
											
											if ( GUI:TreeNode("Dev##"..tostring(id)) ) then										
												if (GUI:Button("PushButton",100,15) ) then d("Push Button Result: "..tostring(e:PushButton(Dev.pushbuttonA, Dev.pushbuttonB))) end
												GUI:SameLine()										
												if ( not Dev.pushbuttonA or Dev.pushbuttonA < 0) then Dev.pushbuttonA = 0 end
												Dev.pushbuttonA = GUI:InputInt("##Devc2"..tostring(id),Dev.pushbuttonA ,1,1) 
												GUI:SameLine()
												if ( not Dev.pushbuttonB or Dev.pushbuttonB < 0) then Dev.pushbuttonB = 0 end
												Dev.pushbuttonB = GUI:InputInt("##Devc3"..tostring(id),Dev.pushbuttonB ,1,1)																					
												GUI:TreePop()
											end
										end								
										GUI:TreePop()
									end					
									GUI:PopItemWidth()
								end
							end
						end
					end
					GUI:TreePop()
				end	
				if ( GUI:TreeNode("All Controls")) then	
					--local controls = GetControlList()
					GUI:PushItemWidth(200)
					if (table.valid(controls)) then
						for id, e in pairs(controls) do
							if (gDevAddonTextFilter == "" or string.contains(e,gDevAddonTextFilter)) then
								GUI:BulletText("ID: "..tostring(id)) GUI:SameLine(150) GUI:InputText("##Devac0"..tostring(id), e) 
								GUI:SameLine() 
								if (GUI:Button("Create##"..tostring(id),50,15) ) then d("Creating Control Result: "..tostring(CreateControl(id))) end
							end
						end
					end
					GUI:PopItemWidth()
					GUI:TreePop()
				end				
				GUI:TreePop()
			end
			--End Active Controls
			
			-- cbk: Player
			if ( GUI:TreeNode("Player") ) then
				if( gamestate == 3 ) then 
					local c = Player
					
					
					GUI:BulletText("interacting: "..tostring(c.interacting))
					GUI:BulletText("interacttype: "..tostring(c.interacttype))
					if ( GUI:TreeNode("Stats")) then
						GUI:Text("Health")
						local stat = Player.health
						if (table.valid(stat)) then
							for key, value in pairs(stat) do
								GUI:BulletText(tostring(key).." - "..tostring(value))							
							end
						end
						GUI:Text("Magicka")
						local stat = Player.magicka
						if (table.valid(stat)) then
							for key, value in pairs(stat) do
								GUI:BulletText(tostring(key).." - "..tostring(value))							
							end
						end
						GUI:Text("Stamina")
						local stat = Player.stamina
						if (table.valid(stat)) then
							for key, value in pairs(stat) do
								GUI:BulletText(tostring(key).." - "..tostring(value))							
							end
						end
						
						GUI:TreePop()
					end
					
					
					--if ( c ) then Dev.DrawGameObjectDetails(c,true) else	GUI:Text("No Player found.") end
                    --local mapX, mapY, mapZ = WorldToMapCoords(c.localmapid, c.pos.x, c.pos.y, c.pos.z)
					
					--GUI:BulletText("Map ID") GUI:SameLine(200) GUI:InputText("##Devuf2",tostring(c.localmapid))
					--GUI:BulletText("Map Name") GUI:SameLine(200) GUI:InputText("##Devuf3",GetMapName(c.localmapid))
					--GUI:BulletText("Map X") GUI:SameLine(200) GUI:InputText("##Devuf4",tostring(mapX))
					--GUI:BulletText("Map Y") GUI:SameLine(200) GUI:InputText("##Devuf5",tostring(mapY))
					--GUI:BulletText("Map Z") GUI:SameLine(200) GUI:InputText("##Devuf6",tostring(mapZ))
					--GUI:BulletText("Pulse Duration") GUI:SameLine(200) GUI:InputText("##Devuf7",tostring(GetBotPerformance()))
					
					
					
				else
					GUI:Text("Not Ingame...")
				end
				GUI:TreePop()
			end
-- END PLAYER INFO
			
			-- cbk: Target
			if ( GUI:TreeNode("Target") ) then
				if( gamestate == 3 ) then 
					local c = Player:GetPeferedTarget()
					if ( c ) then Dev.DrawGameObjectDetails(c) else	GUI:Text("No target found.") end
				else
					GUI:Text("Not Ingame...")
				end
				GUI:TreePop()
			end

			-- cbk: Scanner
			if ( GUI:TreeNode("Scanner") ) then
				if( gamestate == 3 ) then 
					GUI:Separator()
					GUI:Text("EntityList")
					GUI:PushItemWidth(500)
					gDevScannerString = GUI:InputText("##scanner-string",gDevScannerString);
					GUI:PopItemWidth()
					GUI:Separator()
					local el = EntityList(gDevScannerString)
					if (table.valid(el)) then
						GUI:Text("Identity");
						GUI:SameLine(200)
						GUI:Text("Current Target");
						for i, entity in pairs(el) do
							GUI:Text(entity.name.." ["..tostring(i).."]["..tostring(entity.contentid).."]");
						end
					end
				else
					GUI:Text("Not Ingame...")
				end
				GUI:TreePop()
			end

			if ( GUI:TreeNode("Entities") ) then -- haha tities
				if( gamestate == 3 ) then
					if ( GUI:TreeNode("EntityList") ) then
						if (GUI:CollapsingHeader(GetString("Filters"))) then
							GUI:Indent()
							GUI:PushStyleVar(GUI.StyleVar_ScrollbarSize,20)
							GUI:BeginChild("##DevEntityListFilterScrollArea",0,152,false,GUI.SetCond_Always+GUI.WindowFlags_ForceVerticalScrollbar)


								Dev.aggro = GUI:Checkbox(".aggro", Dev.aggro)
								Dev.alive = GUI:Checkbox(".alive", Dev.alive)
								Dev.attackable = GUI:Checkbox(".attackable", Dev.attackable)
								GUI:PushItemWidth(100); Dev.clustered = GUI:InputText("clustered",Dev.clustered); GUI:PopItemWidth();
								GUI:PushItemWidth(100); Dev.contentid = GUI:InputText("contentid",Dev.contentid); GUI:PopItemWidth();
								Dev.dead = GUI:Checkbox(".dead", Dev.dead)
								GUI:PushItemWidth(100); Dev.distanceto = GUI:InputText("distanceto",Dev.distanceto); GUI:PopItemWidth();
								GUI:PushItemWidth(100); Dev.exclude_contentid = GUI:InputText("exclude_contentid",Dev.exclude_contentid); GUI:PopItemWidth();
								Dev.friendly = GUI:Checkbox(".friendly", Dev.friendly)
								Dev.gatherable = GUI:Checkbox(".gatherable", Dev.gatherable)
								Dev.highesthealth = GUI:Checkbox(".highesthealth", Dev.highesthealth)
								Dev.hostile = GUI:Checkbox(".hostile", Dev.hostile)
								Dev.incombat = GUI:Checkbox(".incombat", Dev.incombat)
								GUI:PushItemWidth(100); Dev.interacttype = GUI:InputText("interacttype",Dev.interacttype); GUI:PopItemWidth();
								Dev.isvendor = GUI:Checkbox(".isvendor", Dev.isvendor)
								Dev.lootable = GUI:Checkbox(".lootable", Dev.lootable)
								Dev.los = GUI:Checkbox(".los", Dev.los)
								Dev.lowesthealth = GUI:Checkbox(".lowesthealth", Dev.lowesthealth)
								GUI:PushItemWidth(100); Dev.maxdistance = GUI:InputText("maxdistance",Dev.maxdistance); GUI:PopItemWidth();
								GUI:PushItemWidth(100); Dev.maxhealth = GUI:InputText("maxhealth",Dev.maxhealth); GUI:PopItemWidth();
								GUI:PushItemWidth(100); Dev.maxlevel = GUI:InputText("maxlevel",Dev.maxlevel); GUI:PopItemWidth();
								GUI:PushItemWidth(100); Dev.maxpathdistance = GUI:InputText("maxpathdistance",Dev.maxpathdistance); GUI:PopItemWidth();
								GUI:PushItemWidth(100); Dev.mindistance = GUI:InputText("mindistance",Dev.mindistance); GUI:PopItemWidth();
								GUI:PushItemWidth(100); Dev.minhealth = GUI:InputText("minhealth",Dev.minhealth); GUI:PopItemWidth();
								Dev.nearest = GUI:Checkbox(".nearest", Dev.nearest)
								Dev.nocritter = GUI:Checkbox(".nocritter", Dev.nocritter)
								Dev.noplayersaround = GUI:Checkbox(".noplayersaround", Dev.noplayersaround)
								Dev.notincombat = GUI:Checkbox(".notincombat", Dev.notincombat)
								Dev.notnpc = GUI:Checkbox(".notnpc", Dev.notnpc)
								Dev.npc = GUI:Checkbox(".npc", Dev.npc)
								Dev.onmesh = GUI:Checkbox(".onmesh", Dev.onmesh)
								Dev.player = GUI:Checkbox(".player", Dev.player)
								Dev.questinteraction = GUI:Checkbox(".questinteraction", Dev.questinteraction)
								Dev.shortestpath = GUI:Checkbox(".shortestpath", Dev.shortestpath)
								Dev.targetable = GUI:Checkbox(".targetable", Dev.targetable)
								GUI:PushItemWidth(100); Dev.targeting = GUI:InputText("targeting",Dev.targeting); GUI:PopItemWidth();
								Dev.targetingme = GUI:Checkbox(".targetingme", Dev.targetingme)

								GUI:PopStyleVar()
							GUI:EndChild()
							GUI:Unindent()
						end
						GUI:Separator()
						if (GUI:CollapsingHeader(GetString("Entities"))) then -- haha tities
							GUI:PushStyleVar(GUI.StyleVar_ScrollbarSize,20)
							GUI:BeginChild("##DevEntityListScrollArea",0,330,false,GUI.SetCond_Always+GUI.WindowFlags_ForceVerticalScrollbar)
							GUI:PushItemWidth(200)
							gDevScannerString = ""
							if Dev.aggro then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("aggro")
							end
							if Dev.alive then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("alive")
							end
							if Dev.attackable then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("attackable")
							end
							if Dev.clustered ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("clustered="..tostring(Dev.clustered))
							end
							if Dev.contentid ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("contentid="..tostring(Dev.contentid))
							end
							if Dev.dead then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("dead")
							end
							if Dev.distanceto ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("distanceto="..tostring(Dev.distanceto))
							end
							if Dev.exclude_contentid ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("exclude_contentid="..tostring(Dev.exclude_contentid))
							end
							if Dev.friendly then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("friendly")
							end
							if Dev.gatherable then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("gatherable")
							end
							if Dev.highesthealth then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("highesthealth")
							end
							if Dev.hostile then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("hostile")
							end
							if Dev.incombat then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("incombat")
							end
							if Dev.interacttype ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("interacttype="..tostring(Dev.interacttype))
							end
							if Dev.isvendor then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("isvendor")
							end
							if Dev.lootable then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("lootable")
							end
							if Dev.los then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("los")
							end
							if Dev.lowesthealth then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("lowesthealth")
							end
							if Dev.maxdistance ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("maxdistance="..tostring(Dev.maxdistance))
							end
							if Dev.maxhealth ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("maxhealth="..tostring(Dev.maxhealth))
							end
							if Dev.maxlevel ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("maxlevel="..tostring(Dev.maxlevel))
							end
							if Dev.maxpathdistance ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("maxpathdistance="..tostring(Dev.maxpathdistance))
							end
							if Dev.mindistance ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("mindistance="..tostring(Dev.mindistance))
							end
							if Dev.minhealth ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("minhealth="..tostring(Dev.minhealth))
							end
							if Dev.nearest then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("nearest")
							end
							if Dev.nocritter then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("nocritter")
							end
							if Dev.noplayersaround then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("noplayersaround")
							end
							if Dev.notincombat then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("notincombat")
							end
							if Dev.notnpc then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("notnpc")
							end
							if Dev.npc then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("npc")
							end
							if Dev.onmesh then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("onmesh")
							end
							if Dev.player then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("player")
							end
							if Dev.questinteraction then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("questinteraction")
							end
							if Dev.shortestpath then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("shortestpath")
							end
							if Dev.targetable then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("targetable")
							end
							if Dev.targeting ~= "" then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("targeting="..tostring(Dev.targeting))
							end
							if Dev.targetingme then
								if gDevScannerString ~= "" then gDevScannerString = gDevScannerString..tostring(",") end
								gDevScannerString = gDevScannerString..tostring("targetingme")
							end

							local el = EntityList(gDevScannerString)
							if (table.valid(el)) then
								for index,entity in spairs(el) do
									if not entity.name or entity.name == "" then
										entity.name = GetString("No Name")
									end
									if GUI:TreeNode(entity.contentid .. " - " .. entity.name) then
										GUI:BulletText(".id = "..tostring(entity.id))
										GUI:BulletText(".name = "..tostring(entity.name))
										GUI:BulletText(".index = "..tostring(entity.index))
										GUI:BulletText(".contentid = "..tostring(entity.contentid))
										GUI:BulletText(".interacttype = "..tostring(entity.interacttype))
										GUI:BulletText(".ismoving = "..tostring(entity.ismoving))
										GUI:BulletText(".friendly = "..tostring(entity.friendly))
										GUI:BulletText(".hostile = "..tostring(entity.hostile))
										GUI:BulletText(".type = "..tostring(entity.type))
										GUI:BulletText(".los = "..tostring(entity.los))
										GUI:BulletText(".mapid = "..tostring(entity.mapid))
										GUI:BulletText(".distance = "..tostring(entity.distance))
										GUI:BulletText(".distance2d = "..tostring(entity.distance2d))
										GUI:BulletText(".pathdistance = "..tostring(entity.pathdistance))
										GUI:BulletText(".isreachable = "..tostring(entity.isreachable))
										if ValidTable(entity.health) then
											if GUI:TreeNode(".health") then
												GUI:BulletText(".percent = "..tostring(entity.health.percent))
												GUI:BulletText(".current = "..tostring(entity.health.current))
												GUI:BulletText(".max = "..tostring(entity.health.max))
												GUI:TreePop()
											end
										end
										if ValidTable(entity.magika) then
											if GUI:TreeNode(".magika") then
												GUI:BulletText(".percent = "..tostring(entity.magika.percent))
												GUI:BulletText(".current = "..tostring(entity.magika.current))
												GUI:BulletText(".max = "..tostring(entity.magika.max))
												GUI:TreePop()
											end
										end
										if ValidTable(entity.stamina) then
											if GUI:TreeNode(".stamina") then
												GUI:BulletText(".percent = "..tostring(entity.stamina.percent))
												GUI:BulletText(".current = "..tostring(entity.stamina.current))
												GUI:BulletText(".max = "..tostring(entity.stamina.max))
												GUI:TreePop()
											end
										end
										if ValidTable(entity.pos) then
											if GUI:TreeNode(".pos - Mesh Space Position") then
												GUI:BulletText(".x = "..tostring(entity.pos.x))
												GUI:BulletText(".y = "..tostring(entity.pos.y))
												GUI:BulletText(".z = "..tostring(entity.pos.z))
												GUI:BulletText(".height = "..tostring(entity.pos.height))
												GUI:TreePop()
											end
										end
										if ValidTable(entity.worldpos) then
											if GUI:TreeNode(".worldpos - Game World Position") then
												GUI:BulletText(".x = "..tostring(entity.worldpos.x))
												GUI:BulletText(".y = "..tostring(entity.worldpos.y))
												GUI:BulletText(".z = "..tostring(entity.worldpos.z))
												GUI:BulletText(".h = "..tostring(entity.worldpos.h))
												GUI:BulletText(".height = "..tostring(entity.worldpos.height))
												GUI:TreePop()
											end
										end
										if ValidTable(entity.renderpos) then
											if GUI:TreeNode(".renderpos - Game's Render Position") then
												GUI:BulletText(".x = "..tostring(entity.renderpos.x))
												GUI:BulletText(".y = "..tostring(entity.renderpos.y))
												GUI:BulletText(".z = "..tostring(entity.renderpos.z))
												GUI:BulletText(".h = "..tostring(entity.renderpos.h))
												GUI:BulletText(".height = "..tostring(entity.renderpos.height))
												GUI:TreePop()
											end
										end
										if ValidTable(entity.meshpos) then
											if GUI:TreeNode(".meshpos") then
												GUI:BulletText(".x = "..tostring(entity.meshpos.x))
												GUI:BulletText(".y = "..tostring(entity.meshpos.y))
												GUI:BulletText(".z = "..tostring(entity.meshpos.z))
												GUI:BulletText(".distance = "..tostring(entity.meshpos.distance))
												GUI:BulletText(".meshdistance = "..tostring(entity.meshpos.meshdistance))
												GUI:TreePop()
											end
										end
										GUI:TreePop()
									end
								end
							end
							GUI:PopItemWidth()
							GUI:PopStyleVar()
							GUI:EndChild()
							GUI:Separator()
						end
						GUI:TreePop()
					end
				else
					GUI:Text("Not Ingame...")
				end
				GUI:TreePop()
			end
						
			-- cbk: AbilityList
			if ( GUI:TreeNode("AbilityList")) then
				if( gamestate == 3 ) then 
					GUI:NewLine()
					GUI:Separator()
					GUI:Separator()
					GUI:Text(GetString("Cast Functons"))
					GUI:Separator()
					GUI:Separator()
					GUI:NewLine()
					GUI:Indent()
					GUI:TextWrapped(GetString("No Target Skills"))
					GUI:Indent()
					GUI:InputText("##DevCastNote1","AbilityList:Cast('AbilityID')",GUI.InputTextFlags_ReadOnly+GUI.InputTextFlags_AutoSelectAll)
					GUI:InputText("##DevCastNote2","AbilityList:Cast2('AbilityID')",GUI.InputTextFlags_ReadOnly+GUI.InputTextFlags_AutoSelectAll)
					GUI:Unindent()
					GUI:NewLine()
					GUI:TextWrapped(GetString("Single Target Skills"))
					GUI:Indent()
					GUI:InputText("##DevCastNote3","AbilityList:Cast('AbilityID, TargetID')",GUI.InputTextFlags_ReadOnly+GUI.InputTextFlags_AutoSelectAll)
					GUI:InputText("##DevCastNote4","AbilityList:Cast2('AbilityID, TargetID')",GUI.InputTextFlags_ReadOnly+GUI.InputTextFlags_AutoSelectAll)
					GUI:Unindent()
					GUI:NewLine()
					GUI:TextWrapped(GetString("Ground Target Skills"))
					GUI:Indent()
					GUI:InputText("##DevCastNote5","AbilityList:Cast('AbilityID, X, Y, Z')",GUI.InputTextFlags_ReadOnly+GUI.InputTextFlags_AutoSelectAll)
					GUI:Unindent()
					GUI:Unindent()
					GUI:NewLine()
					GUI:Separator( )
					
					GUI:Separator( )
					GUI:TextWrapped(GetString("Ability List"))
					GUI:Separator()
					GUI:Separator()
					GUI:BeginChild("##DevAbilityScrollArea",0,165,false,GUI.SetCond_Always+GUI.WindowFlags_ForceVerticalScrollbar)
					if not table.valid(eso_skillmanager.skillsbyindex) then
						if not table.valid(eso_skillmanager.skillsbyindex) then
							eso_skillmanager.BuildSkillsBook()
						end
					end
					
					GUI:PushItemWidth(200)
					if (table.valid(eso_skillmanager.skillsbyid)) then
						local softTarget = Player:GetSoftTarget()
						
						for index,skillInfo in spairs(eso_skillmanager.skillsbyindex) do
							if GUI:TreeNode(skillInfo.index.." - "..skillInfo.name) then
								GUI:BulletText("id = "..tostring(skillInfo.id))
								GUI:BulletText("name = "..tostring(skillInfo.name))
								GUI:BulletText("passive = "..tostring(skillInfo.passive))
								GUI:BulletText("rank = "..tostring(skillInfo.rank))
								GUI:BulletText("type = "..tostring(skillInfo.type))
								GUI:BulletText("visable = "..tostring(skillInfo.visable))
								GUI:BulletText("can cast (self) = "..tostring(AbilityList:CanCast(skillInfo.id)))
								if softTarget then
									GUI:BulletText("can cast soft (target) ID = "..tostring(AbilityList:CanCast(skillInfo.id,softTarget.id)))
									GUI:BulletText("can cast assist (target) CID = "..tostring(AbilityList:CanCast(skillInfo.id,softTarget.contentid)))
								end
								GUI:TreePop()
							end
						end
					end
					GUI:PopItemWidth()
					GUI:EndChild()
					GUI:NewLine()
				else
					GUI:Text("Not Ingame...")
				end
				GUI:TreePop()
			end
			-- END ABILITYLIST

			if ( GUI:TreeNode("Utility Functions")) then
				if( gamestate == 3 ) then
					GUI:PushItemWidth(200)
					GUI:BulletText("GetGameState") GUI:SameLine(200) GUI:InputText("##DevUT0",tostring(GetGameState()))
					GUI:PopItemWidth()
					GUI:Indent()
					GUI:BulletText("1: " .. GetString("Character Select"))
					GUI:BulletText("2: " .. GetString("Main Menu"))
					GUI:BulletText("3: " .. GetString("In Game"))
					GUI:BulletText("4: " .. GetString("Error"))
					GUI:BulletText("5: " .. GetString("Loading"))
					GUI:Unindent()
				end
				GUI:TreePop()
			end
		end
		GUI:End()
		GUI:PopStyleVar(2)
	end
end

Dev.Obstacles = {}
Dev.AvoidanceAreas = {}

function Dev.Mov ( arg ) 
	if ( arg == "Dev.playerPosition") then
		local p = Player
		if ( p ) then
			local p = Player.pos
			tb_xPos = tostring(p.x)
			tb_yPos = tostring(p.y)
			tb_zPos = tostring(p.z)
			d(p)
		end
	elseif ( arg == "Dev.facePos" and tonumber(tb_xPos)~=nil) then
		d("SetFacing..")
		d(Player:SetFacing(tonumber(tb_xPos),tonumber(tb_yPos),tonumber(tb_zPos),true))
	elseif ( arg == "Dev.faceTar") then
		local mytarget = Player:GetPeferedTarget()
		if ( mytarget ) then
			local tPos = mytarget.pos
			if ( TableSize(tPos) > 0 ) then
				d(Player:SetFacing(tPos.x,tPos.y,tPos.z), true)
			end
		end
	
	elseif ( arg == "Dev.MoveDir") then
		d(Player:SetMovement(1,tonumber(mimovf)))
	elseif ( arg == "Dev.UnMoveDir") then
		d(Player:SetMovement(0,tonumber(mimovf)))
	elseif ( arg == "Dev.MoveS") then
		d(Player:Stop())
	elseif ( arg == "Dev.naviTo" and tonumber(tb_xPos)~=nil) then		
		local navsystem
		local navpath
		local smoothturns
		if ( Nnavitype == "Normal") then 
			navsystem = false 
		else 
			navsystem = true --FollowNavSystem
		end
		if ( Nmovetype == "Straight") then 
			navpath = false 
		else 
			navpath = true --Random
		end
		if ( Nsmooth == "0") then 
			smoothturns = false 
		else 
			smoothturns = true
		end
		d("Navigating to "..tostring(tb_xPos).." "..tostring(tb_yPos).." "..tostring(tb_zPos))
		tb_nRes = tostring(Player:MoveTo(tonumber(tb_xPos),tonumber(tb_yPos),tonumber(tb_zPos),0.5,navsystem,navpath,smoothturns))
	elseif ( arg == "Dev.Teleport") then
		if (tonumber(tb_xPos) ~= nil ) then
			d(Player:Teleport(tonumber(tb_xPos),tonumber(tb_yPos),tonumber(tb_zPos)))
		end	
	elseif ( arg == "Dev.ranPT") then
		local ppos = Player.pos
		if ( tonumber(tb_min) and tonumber(tb_max) ) then 
			local p = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,tonumber(tb_min),tonumber(tb_max))
			if ( p) then
				tb_xPos = tostring(p.x)
				tb_yPos = tostring(p.y)
				tb_zPos = tostring(p.z)				
				tb_xdist = Distance3D(p.x,p.y,p.z,ppos.x,ppos.y,ppos.z)
			end
		end

	elseif ( arg == "Dev.AddOB" and Player.onmesh) then
		local pPos = Player.pos
		if ( pPos ) then
			table.insert(Dev.Obstacles, { x=pPos.x, y=pPos.y, z=pPos.z, r=tonumber(obsSize) })
			d("Adding new Obstacle with size "..tostring(obsSize))
			NavigationManager:AddNavObstacles(Dev.Obstacles)
		end
	elseif ( arg == "Dev.ClearOB" ) then
		local pPos = Player.pos
		if ( pPos ) then
			Dev.Obstacles = {}
			d("Clearing Obstacles ")
			NavigationManager:ClearNavObstacles()
		end
	elseif ( arg == "Dev.AddAA" and Player.onmesh) then
		local pPos = Player.pos
		if ( pPos ) then
			table.insert(Dev.AvoidanceAreas, { x=pPos.x, y=pPos.y, z=pPos.z, r=tonumber(avoidSize) })
			d("adding AvoidanceArea with size "..tostring(avoidSize))
			NavigationManager:SetAvoidanceAreas(Dev.AvoidanceAreas)
		end
	elseif ( arg == "Dev.ClearAA" ) then
		local pPos = Player.pos
		if ( pPos ) then
			Dev.AvoidanceAreas = {}
			d("Clearing AvoidanceAreas ")
			NavigationManager:ClearAvoidanceAreas()
		end			
	end	
end

function Dev.Func ( arg )
	local ji = tostring(qJournalIndex)
	local si = tostring(qStepIndex)
	local ci = tostring(qConditionIndex)
	local ti = tostring(qToolIndex)
	local ri = tostring(qRewardIndex)

	if ( arg == "AB_Cast") then
		local mytarget
		if ( ABchartarg == "Player" ) then
			mytarget = Player
		elseif ( ABchartarg == "Target" ) then
			mytarget = Player:GetPeferedTarget()	
		end		
		if (mytarget ~= nil and tonumber(ABID)~=nil) then
			d("Casting.."..ABName.." at "..tostring(mytarget.id))
			d(AbilityList:Cast(tonumber(ABID),mytarget.id))
		end
	elseif (arg == "qQuestAssistance") then
		e("RequestJournalQuestConditionAssistance("..ji..","..si..","..ci..")")
	elseif (arg == "qQuestInfo") then
		questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverideText, completed, tracked, questLevel, pushed, questType = e("GetJournalQuestInfo("..ji..")")
		d("questName: "..questName)
		d("backgroundText: "..backgroundText)
		d("activeStepText: "..activeStepText)
		d("activeStepType: "..activeStepType)
		d("activeStepTrackerOverrideText: "..(activeStepTrackerOverrideText or ""))
		d("completed: "..tostring(completed))
		d("tracked: "..tostring(tracked))
		d("questLevel: "..questLevel)
		d("pushed: "..tostring(pushed))
		d("questType: "..questType)
	elseif(arg == "qQuestStepInfo") then
		_, stepText, stepType, trackerOverrideText, numConditions = e("GetJournalQuestStepInfo("..ji..","..si..")")
		d("stepText: "..stepText)
		d("stepType: "..stepType)
		d("trackerOverrideText: "..trackerOverrideText)
		d("numConditions: "..numConditions)
	elseif(arg == "qQuestConditionInfo") then
		conditionText, current, max, isFailCondition, isComplete, isCreditShared = e("GetJournalQuestConditionInfo("..ji..","..si..","..ci..")")
		d("conditiontext: "..conditionText)
		d("current: "..tostring(currrent))
		d("max: "..tostring(max))
		d("isFailCondition: "..tostring(isFailCondition))
		d("isComplete: "..tostring(isComplete))
		d("isCreditShared: "..tostring(isCreditShared))
	elseif(arg == "qQuestToolInfo") then
		iconFilename, stackCount, isUsable, name = e("GetQuestToolInfo("..ti..")")
		d("iconFilename: "..iconFilename)
		d("stackCount: "..stackCount)
		d("isUsable: "..tostring(isUsable))
		d("name: "..name)
	elseif(arg == "qQuestItemInfo") then
		iconFilename,stackCount,name = e("GetQuestItemInfo("..ji..","..si..","..ci..")")
		d("iconFilename: "..iconFilename)
		d("stackCount: "..stackCount)
		d("name: "..name)	
	elseif(arg == "qQuestRewardInfo") then
		rewardType,itemName,amount,iconFile,meetsUsageRequirement,itemQuality = e("GetJournalQuestRewardInfo("..ji..","..ri..")")
		d("rewardType: "..rewardType)
		d("itemName: "..itemName)
		d("amount: "..amount)
		d("iconFile: "..iconFile)
		d("meetsUsageRequirement: "..tostring(meetsUsageRequirement))
		d("itemQuality: "..itemQuality)
	elseif(arg == "qQuestLocInfo") then
		zoneName, objectiveName, zoneIndex, poiIndex = e("GetJournalQuestLocationInfo("..ji..")")
		d("zoneName: "..zoneName)
		d("objectiveName: "..objectiveName)
		d("zoneIndex: "..zoneIndex)
		d("poiIndex: "..poiIndex)
	elseif(arg == "qQuestTimerInfo") then
		timerStart,timerEnd,isVisible,isPaused = e("GetJournalQuestTimerInfo("..ji..")")
		d("timerStart: "..timerStart)
		d("timerEnd: "..timerEnd)
		d("isVisible: "..tostring(isVisible))
		d("isPaused: "..tostring(isPaused))
	elseif(arg == "qQuestNearestCondition") then
		foundValidCondition,journalQuestIndex,stepIndex,conditionIndex = e("GetNearestQuestCondition()")
		d("foundValidCondition: "..tostring(foundValidCondition))
		d("journalQuestIndex: "..journalQuestIndex)
		d("stepIndex: "..stepIndex)
		d("conditionIndex: "..conditionIndex)
	elseif(arg == "qQuestOfferedInfo") then
		dialogue,response = e("GetOfferedQuestInfo()")
		d("dialogue: "..dialogue)
		d("response: "..response)
	elseif(arg == "qUseQuestItem") then
		d(e("UseQuestItem("..ji..","..si..","..ci..")"))
	elseif(arg == "qUseQuestTool") then
		d(e("UseQuestTool("..ji..","..ti..")"))
	elseif(arg == "qQuestAccept") then
		d(e("AcceptOfferedQuest()"))
	elseif(arg == "qQuestComplete") then
		d(e("CompleteQuest()"))
	elseif(arg == "qQuestAbandon") then
		d(e("AbandonQuest("..ji..")"))
	end
end
			
function Dev.UpdateWindow()
	-- CharacterInfo --
	local mytarget
	if ( chartarg == "Player" ) then
		mytarget = Player
	elseif ( chartarg == "Target" ) then
		mytarget = Player:GetPeferedTarget()
	else
		local EList = EntityList("nearest")
		if ( EList ) then			
			id,mytarget = next (EList)
		end
	end
		
	if (mytarget ~= nil) then
		
		TargetPtr = string.format( "%x",tonumber(mytarget.ptr ))
		TID = mytarget.id
		SID = mytarget.serverid
		TType = mytarget.type
		TCID = mytarget.contentid
		TName = mytarget.name
		TClass = mytarget.class
		TTarID = mytarget.targetid
		THP = tostring(mytarget.hp.current.." / "..mytarget.hp.max.." / "..mytarget.hp.percent.."%")
		TPos = (math.floor(mytarget.pos.x * 10) / 10).." / "..(math.floor(mytarget.pos.y * 10) / 10).." / "..(math.floor(mytarget.pos.z * 10) / 10)
		TOnMesh = tostring(mytarget.onmesh)
		TOnMeshExact = tostring(mytarget.onmeshexact)
		TDist = mytarget.distance --(math.floor(mytarget.distance * 100) / 100)
		TPDist = (math.floor(mytarget.pathdistance * 100) / 100)
		THead = mytarget.pos.facingangle
		TIAT = mytarget.interacttype
		TIATName = mytarget.interactname
		TAtt = mytarget.attitude
		TIsAlive = tostring(mytarget.alive)
		TIsDead = tostring(mytarget.dead)
		TIsF = tostring(mytarget.friendly)
		TIHost = tostring(mytarget.hostile)
		TAtta = tostring(mytarget.attackable)
		TTarg = tostring(mytarget.targetable)
		TKillab = tostring(mytarget.killable)
		TIsVend = tostring(mytarget.isvendor)
		TIsQI = tostring(mytarget.isquestinteraction)
		THRad = tostring(mytarget.radius).." / "..tostring(mytarget.pos.height)	
		TLOS = tostring(mytarget.los)
		TSwim = tostring(mytarget.isswimming)
		TIsfall = tostring(mytarget.isfalling)
		TIsStea = tostring(mytarget.isstealthed)
		TStealthSta = mytarget.stealthstate		
		TIsNPC = tostring(mytarget.isnpc)
		TIsGhost = tostring(mytarget.isghost)
		TIsCrit = tostring(mytarget.iscritter)
		TIsWere = tostring(mytarget.iswerewolf)
		TIsBoss = tostring(mytarget.isbossmonster)
			
		
	else
		TID = "nil"
		TCID = "nil"
		TName = "none"
		TType = "none"
		GTType = "none"
	end	
	
	-- AbilityInfo
	local mytarget
	if ( ABchartarg == "Player" ) then
		mytarget = Player
	elseif ( ABchartarg == "Target" ) then
		mytarget = Player:GetPeferedTarget()	
	end		
	if (mytarget ~= nil) then
		ABIsCast = tostring(mytarget.iscasting)
		ABIsChannel = tostring(mytarget.ischanneling)
		
		local cinfo = mytarget.castinfo
		if ( cinfo ) then
			CABility = cinfo.name
			CAbiliID = cinfo.abilityid
			CAbiStar = cinfo.starttime
			CAbiEnd = cinfo.endtime
			CABIsChann = tostring(cinfo.ischanneling)
		else
			CABility = "none"
			CAbiliID = 0
			CAbiStar = 0
			CAbiEnd = 0
			CABIsChann = 0
		end		
	end	
		
	local ABList = AbilityList("")
	local id,ab
	if (ABList) then
		local count = 1
		id,ab = next(ABList)
		while (id and ab ) do			
			if ( tonumber(count) == tonumber(abilitySlot) ) then
				break
			end
			count = count + 1
			id,ab = next(ABList,id)
		end	
	end	
	if ( id and ab ) then
		if (mytarget ~= nil) then
			ABCanCa = AbilityList:CanCast(ab.id,mytarget.id)
			ABInRange = tostring(AbilityList:IsTargetInRange(ab.id,mytarget.id))	
		end
		ABPtr = ab.ptr
		ABID = ab.id
		ABName = ab.name
		ABUsable = tostring(ab.isusable)
		ABGround = tostring(ab.isgroundtarget)
		ABType = ab.type
		ABCost = ab.cost
		ABCastT = ab.casttime
		ABChanT = ab.channeltime
		ABRange = ab.range
		ABRadius= ab.radius		
	else
		ABPtr = 0
		ABID = 0
		ABName = 0
		ABCanCa = "false"
		ABUsable = "false"
		ABGround = "false"
		ABType = 0
		ABCost = 0
		ABCastT = 0
		ABChanT = 0
		ABRange = 0
		ABRadius= 0
		ABInRange = "false"
	end
	
	-- QuestInfo
	local ji = tostring(qJournalIndex)
	local si = tostring(qStepIndex)
	local ci = tostring(qConditionIndex)
	local ti = tostring(qToolIndex)
	
	qNumQuests = e("GetNumJournalQuests()")
	qNumSteps = e("GetJournalQuestNumSteps("..ji..")")
	qNumConditions = e("GetJournalQuestNumConditions("..ji..","..si..")")
	qNumTools = e("GetQuestToolCount("..ji..")")
	qNumRewards = e("GetJournalQuestNumRewards("..ji..")")
	qValidIndex = tostring(e("IsValidQuestIndex("..ji..")"))
	qName = e("GetJournalQuestName("..ji..")")
	qLevel = e("GetJournalQuestLevel("..ji..")")
	qQuestType = e("GetJournalQuestType("..ji..")")
	qQuestRepeatType = e("GetJournalQuestRepeatType("..ji..")")
	qIsComplete = tostring(e("GetJournalQuestIsComplete("..ji..")"))
	--qIsPushed = tostring(e("GetJournalQuestIsPushed("..ji..")"))
	qConditionPinType = e("GetJournalQuestConditionType("..ji..","..si..","..ci..")")
	qShareIDs = e("GetOfferedQuestShareIds()")
	qTimerCaption = e("GetJournalQuestTimerCaption("..ji..")")
	--qDailyCount = e("GetQuestDailyCount()")
	
	local questTable = QuestManager:GetByIndex(tonumber(ji))
	local stepTable = QuestManager:GetQuestStep(tonumber(ji),tonumber(si))
	local conditionTable = QuestManager:GetQuestCondition(tonumber(ji),tonumber(si),tonumber(ci))
	if(ValidTable(questTable)) then
		qQuestID = questTable.id
		qCurrStepIndex = questTable.currentstep
		qCurrCondIndex = questTable.currentcondition
	end
	if(ValidTable(stepTable)) then
		qStepID = stepTable.id
	end
	if(ValidTable(conditionTable)) then
		qConditionID = conditionTable.id
		qConditionType = conditionTable.type
		qConditionPos = (math.floor(conditionTable.pos.x * 10) / 10).." / "..(math.floor(conditionTable.pos.y * 10) / 10).." / "..(math.floor(conditionTable.pos.z * 10) / 10)
	end
	
	-- Movement & Navigation	
	MovState = tostring(Player:GetMovementState())
	mimov = tostring(Player:IsMoving())
	local movdirs = Player:GetMovement()
	local movstr = ""
	if (movdirs.forward) then movstr = "forward" end
	if (movdirs.left) then movstr = movstr.." left" end
	if (movdirs.right) then movstr = movstr.." right" end
	if (movdirs.backward) then movstr = movstr.." backward" end
	midirect = movstr
	
end

function Dev.OnUpdateHandler( Event, ticks )
	
	local gamestate = GetGameState()
	
	if ( gamestate == 2 ) and ( ticks - Dev.lastticks > 500 ) then
		Dev.lastticks = ticks		
		if ( Dev.running ) then
			Dev.UpdateWindow()
						
			if (Dev.curTask) then
				Dev.curTask()
			end
		end
	end
end

function Dev.DrawGameObjectDetails(c,isplayer,ispet) 
	GUI:PushItemWidth(200)
	--if ( GUI:TreeNode("Core Data") ) then
		GUI:BulletText("Ptr") GUI:SameLine(200) GUI:InputText("##dev0",tostring(string.format( "%X",c.ptr)))
		GUI:BulletText("ID") GUI:SameLine(200) GUI:InputText("##dev1",tostring(c.id))
		GUI:BulletText("Name") GUI:SameLine(200) GUI:InputText("##dev2",c.name)	
		GUI:BulletText("ContentID") GUI:SameLine(200) GUI:InputText("##dev4",tostring(c.contentid))
		GUI:BulletText("Type") GUI:SameLine(200) GUI:InputText("##dev5",tostring(c.type))
		GUI:BulletText("Status") GUI:SameLine(200) GUI:InputText("##dev5a",tostring(c.status))
		if (ispet) then
			GUI:BulletText("PetType") GUI:SameLine(200) GUI:InputText("##objpettype",tostring(c.pettype))
			GUI:BulletText("PetState") GUI:SameLine(200) GUI:InputInt2( "##objpetstate", c.petstate[1], c.petstate[2], GUI.InputTextFlags_ReadOnly)
		end
		GUI:BulletText("ChocoboState") GUI:SameLine(200) GUI:InputText("##objchocobostate",tostring(c.chocobostate))
		GUI:BulletText("CharType") GUI:SameLine(200) GUI:InputText("##dev6",tostring(c.chartype))
		GUI:BulletText("TargetID") GUI:SameLine(200) GUI:InputText("##dev7",tostring(c.targetid))
		GUI:BulletText("OwnerID") GUI:SameLine(200) GUI:InputText("##dev8",tostring(c.ownerid))
		GUI:BulletText("Claimed By ID") GUI:SameLine(200) GUI:InputText("##dev43",tostring(c.claimedbyid))
		GUI:BulletText("Fate ID") GUI:SameLine(200) GUI:InputText("##dev35", tostring(c.fateid))
		GUI:BulletText("Icon ID") GUI:SameLine(200) GUI:InputText("##dev354", tostring(c.iconid))
		GUI:TreePop()
	--end
	if ( GUI:TreeNode("Bars Data") ) then
		GUI:PushItemWidth(250)
		local h = c.hp
		GUI:BulletText("Health") GUI:SameLine(200)  GUI:InputFloat3( "##dev9", h.current, h.max, h.percent, 2, GUI.InputTextFlags_ReadOnly)
		GUI:PushItemWidth(100)
			GUI:SameLine() GUI:InputFloat("##dev9.1", h.extra, 2, GUI.InputTextFlags_ReadOnly)
		GUI:PopItemWidth()
		h = c.mp
		GUI:BulletText("MP") GUI:SameLine(200)  GUI:InputFloat3( "##dev10", h.current, h.max, h.percent, 2, GUI.InputTextFlags_ReadOnly)
		h = c.cp
		GUI:BulletText("CP") GUI:SameLine(200)  GUI:InputFloat3( "##dev11", h.current, h.max, h.percent, 2, GUI.InputTextFlags_ReadOnly)
		h = c.gp
		GUI:BulletText("GP") GUI:SameLine(200)  GUI:InputFloat3( "##dev12", h.current, h.max, h.percent, 2, GUI.InputTextFlags_ReadOnly)
		GUI:BulletText("TP") GUI:SameLine(200) GUI:InputText("##dev13",tostring(c.tp))
		GUI:PopItemWidth()		
		GUI:TreePop()
	end
	local p = c.pos
	if ( GUI:TreeNode("Position Data") ) then
		GUI:BulletText("Position") GUI:SameLine(200)  GUI:InputFloat4( "##dev14", p.x, p.y, p.z, p.h, 2, GUI.InputTextFlags_ReadOnly)
		GUI:BulletText("Radius") GUI:SameLine(200) GUI:InputText("##dev15",tostring(c.hitradius))	
		GUI:BulletText("Distance") GUI:SameLine(200) GUI:InputFloat("##dev16", c.distance,0,0,2)
		GUI:BulletText("Distance2D") GUI:SameLine(200) GUI:InputFloat("##dev17", c.distance2d,0,0,2)
		GUI:BulletText("PathDistance") GUI:SameLine(200) GUI:InputFloat("##dev18", c.pathdistance,0,0,2)	
		GUI:BulletText("LoS") GUI:SameLine(200) GUI:InputText("##dev19", tostring(c.los))
		GUI:BulletText("LoS2") GUI:SameLine(200) GUI:InputText("##dev20", tostring(c.los2))
		GUI:BulletText("OnMesh") GUI:SameLine(200) GUI:InputText("##dev20", tostring(c.onmesh))
		GUI:BulletText("IsReachable") GUI:SameLine(200) GUI:InputText("##dev48", tostring(c.isreachable))
		local meshpos = c.meshpos
		if ( meshpos ) then 
			GUI:BulletText("MeshPosition") GUI:SameLine(200)  GUI:InputFloat3( "##dev9m", meshpos.x, meshpos.y, meshpos.z, 2, GUI.InputTextFlags_ReadOnly)
			GUI:BulletText("Dist MeshPos-Player") GUI:SameLine(200)  GUI:InputFloat("##dev12m", meshpos.distance,0,0,2)
			GUI:BulletText("Dist to MeshPos") GUI:SameLine(200)  GUI:InputFloat("##dev13m", meshpos.meshdistance,0,0,2)	
		else
			GUI:BulletText("MeshPosition") GUI:SameLine(200)  GUI:InputFloat3( "##dev9m", 0, 0, m0, 2, GUI.InputTextFlags_ReadOnly)
			GUI:BulletText("Dist MeshPos-Player") GUI:SameLine(200)  GUI:InputFloat("##dev12m", 0,0,0,2)
			GUI:BulletText("Dist to MeshPos") GUI:SameLine(200)  GUI:InputFloat("##dev13m", 0,0,0,2)			
		end
		local cubepos = c.cubepos
		if( table.valid(cubepos)) then
			GUI:BulletText("CubePosition") GUI:SameLine(200)  GUI:InputFloat3( "##deva14m", cubepos.x, cubepos.y, cubepos.z, 2, GUI.InputTextFlags_ReadOnly)
			GUI:BulletText("Dist CubePos-Player") GUI:SameLine(200)  GUI:InputFloat("##deva15m", cubepos.distance,0,0,2)
			GUI:BulletText("Dist to CubePos") GUI:SameLine(200)  GUI:InputFloat("##deva16m", cubepos.meshdistance,0,0,2)
		end		
		GUI:TreePop()
	end	
	if ( GUI:TreeNode("Misc Data") ) then
		GUI:BulletText("IsMounted") GUI:SameLine(200) GUI:InputText("##dev38", tostring(c.ismounted))
		GUI:BulletText("Job") GUI:SameLine(200) GUI:InputText("##dev21",tostring(c.job))
		GUI:BulletText("Level") GUI:SameLine(200) GUI:InputText("##dev22",tostring(c.level))
		GUI:BulletText("PvPTeam") GUI:SameLine(200) GUI:InputText("##dev672",tostring(c.pvpteam))
		GUI:BulletText("GrandCompany") GUI:SameLine(200) GUI:InputText("##dev41",tostring(c.grandcompany))
		GUI:BulletText("GrandCompanyRank") GUI:SameLine(200) GUI:InputText("##dev42",tostring(c.grandcompanyrank))
		GUI:BulletText("Aggro") GUI:SameLine(200) GUI:InputText("##dev24",tostring(c.aggro))
		GUI:BulletText("AggroPercentage") GUI:SameLine(200) GUI:InputText("##dev25",tostring(c.aggropercentage))	
		if(isplayer)then
			GUI:BulletText("Has Aggro") GUI:SameLine(200) GUI:InputText("##devp45", tostring(c.hasaggro))
			GUI:BulletText("ReviveState") GUI:SameLine(200) GUI:InputText("##devp46", tostring(c.revivestate))
			GUI:BulletText("Party Role") GUI:SameLine(200) GUI:InputText("##devp46", tostring(c.role))
		end
		GUI:BulletText("Attackable") GUI:SameLine(200) GUI:InputText("##dev26", tostring(c.attackable))
		GUI:BulletText("Aggressive") GUI:SameLine(200) GUI:InputText("##dev27", tostring(c.aggressive))
		GUI:BulletText("Friendly") GUI:SameLine(200) GUI:InputText("##dev28", tostring(c.friendly))
		GUI:BulletText("InCombat") GUI:SameLine(200) GUI:InputText("##dev29", tostring(c.incombat))
		GUI:BulletText("Interactable") GUI:SameLine(200) GUI:InputText("##dev291", tostring(c.interactable))
		GUI:BulletText("Targetable") GUI:SameLine(200) GUI:InputText("##dev30", tostring(c.targetable))
		GUI:BulletText("Alive") GUI:SameLine(200) GUI:InputText("##dev31", tostring(c.alive))
		GUI:BulletText("Gatherable") GUI:SameLine(200) GUI:InputText("##dev32", tostring(c.cangather))
		GUI:BulletText("Spear Fish State") GUI:SameLine(200) GUI:InputText("##dev33", tostring(c.spearfishstate))
		GUI:BulletText("Marker") GUI:SameLine(200) GUI:InputText("##dev36", tostring(c.marker))
		GUI:BulletText("Online Status") GUI:SameLine(200) GUI:InputText("##dev37", tostring(c.onlinestatus))
		GUI:BulletText("Current World") GUI:SameLine(200) GUI:InputText("##dev38", tostring(c.currentworld))
		GUI:BulletText("Home World") GUI:SameLine(200) GUI:InputText("##dev39", tostring(c.homeworld))
			-- SpearFishing
			--SPEARFISHSTATE_NOTFISHNODE = -1,
			--SPEARFISHSTATE_NONE = 0,
			--SPEARFISHSTATE_BEGIN = 1,
			--SPEARFISHSTATE_BUBBLES = 2, 
			--SPEARFISHSTATE_SUCCESS = 4,
			--SPEARFISHSTATE_MISSED = 5,
			--SPEARFISHSTATE_UNKN = 6,
			--SPEARFISHSTATE_GOTAWAY = 7,
			--SPEARFISHSTATE_NOTAVAIL = 9,
		if ( c.cangather ) then
			GUI:BulletText("GatherAttempts") GUI:SameLine(200) GUI:InputText("##dev34", tostring(c.gatherattempts))
			GUI:BulletText("GatherAttemptsMax") GUI:SameLine(200) GUI:InputText("##dev35", tostring(c.gatherattemptsmax))
		end
		GUI:TreePop()
	end
	
	if ( GUI:TreeNode("Cast & Spell Data") ) then
		GUI:BulletText("Current Action") GUI:SameLine(200) GUI:InputText("##dev36", tostring(c.action))
		GUI:BulletText("Last Action") GUI:SameLine(200) GUI:InputText("##dev37", tostring(c.lastaction))
		local cinfo = c.castinginfo
		if ( table.size(cinfo) > 0) then
			GUI:BulletText("(.castinginfo)")
			GUI:BulletText("ptr") GUI:SameLine(250) GUI:InputText("##dev38323", string.format( "%X",cinfo.ptr))
			GUI:BulletText("Casting ID") GUI:SameLine(250) GUI:InputText("##dev38", tostring(cinfo.castingid))
			GUI:BulletText("Casting Time") GUI:SameLine(250) GUI:InputText("##dev39", tostring(cinfo.casttime))
			GUI:BulletText("Casting TargetCount") GUI:SameLine(250) GUI:InputText("##dev40", tostring(cinfo.castingtargetcount))
			GUI:BulletText("Casting Interruptible") GUI:SameLine(250) GUI:InputText("##dev42130", tostring(cinfo.castinginterruptible))
			if ( GUI:TreeNode("Casting Targets") ) then
				local ct = cinfo.castingtargets			
				if ( table.size(ct) > 0) then
					for tid, target in pairs(ct) do
						GUI:BulletText("Target "..tostring(tid)) GUI:SameLine(200) GUI:InputText("##dev45"..tostring(tid), tostring(target))
					end
				end
				GUI:TreePop()
			end	
			GUI:BulletText("Last Cast ID") GUI:SameLine(250) GUI:InputText("##dev41", tostring(cinfo.lastcastid))
			GUI:BulletText("Time Since Last Cast") GUI:SameLine(250) GUI:InputText("##dev47", tostring(cinfo.timesincecast))
			GUI:BulletText("Channeling ID") GUI:SameLine(250) GUI:InputText("##dev42", tostring(cinfo.channelingid))
			GUI:BulletText("Channeling Target ID") GUI:SameLine(250) GUI:InputText("##dev43", tostring(cinfo.channeltargetid))
			GUI:BulletText("Channeling Time") GUI:SameLine(250) GUI:InputText("##dev44", tostring(cinfo.channeltime))
			if(isplayer)then
				GUI:BulletText("ComboTime Remain") GUI:SameLine(250) GUI:InputText("##devp45", tostring(c.combotimeremain))
				GUI:BulletText("Last Combo ID") GUI:SameLine(250) GUI:InputText("##devp46", tostring(c.lastcomboid))
			
			end
		end
		GUI:TreePop()
	end
	
	local ekinfo = c.eurekainfo
	if ( table.size(ekinfo) > 0) then
		if ( GUI:TreeNode(".eurekainfo") ) then
			GUI:BulletText(".level") GUI:SameLine(200) GUI:InputText("##eurekainfo.level", tostring(ekinfo.level))
			local aff = { [0] = "self", [1] = "fire", [2] = "ice", [3] = "wind", [4] = "earth", [5] = "lightning", [6] = "water"}
			GUI:BulletText(".element") GUI:SameLine(200) GUI:InputText("##eurekainfo.element", tostring(ekinfo.element).."("..IsNull(aff[ekinfo.element],"none")..")")
			GUI:TreePop()
		end
	end
	
	if ( GUI:TreeNode("Buffs") ) then
		local buffs = c.buffs
		if ( table.size(buffs) > 0) then
			for id, b in pairs(buffs) do
				if ( GUI:TreeNode(tostring(b.slot).." - "..b.name) ) then
					GUI:BulletText("Ptr") GUI:SameLine(200) GUI:InputText("##devb0",tostring(string.format( "%X",b.ptr)))
					GUI:BulletText("Ptr2") GUI:SameLine(200) GUI:InputText("##devb1",tostring(string.format( "%X",b.ptr2)))
					GUI:BulletText("ID") GUI:SameLine(200) GUI:InputText("##devb8", tostring(b.id))
					GUI:BulletText("Duration") GUI:SameLine(200) GUI:InputText("##devb9", tostring(b.duration))				
					GUI:BulletText("Name") GUI:SameLine(200) GUI:InputText("##devb3", tostring(b.name))
					GUI:BulletText("OwnerID") GUI:SameLine(200) GUI:InputText("##devb4", tostring(b.ownerid))
					GUI:BulletText("IsBuff") GUI:SameLine(200) GUI:InputText("##devb5", tostring(b.isbuff))
					GUI:BulletText("IsDebuff") GUI:SameLine(200) GUI:InputText("##devb6", tostring(b.isdebuff))
					GUI:BulletText("Stacks") GUI:SameLine(200) GUI:InputText("##devb7", tostring(b.stacks))
					GUI:BulletText("Slot") GUI:SameLine(200) GUI:InputText("##devb2", tostring(b.slot))
					GUI:BulletText("Dispellable") GUI:SameLine(200) GUI:InputText("##devb10", tostring(b.dispellable))
					GUI:TreePop()
				end
			end
		else
			GUI:Text("No Buffs Available...")
		end
		GUI:TreePop()
	end
	
	GUI:PopItemWidth()	
end

function Dev.getPlayerStatus()

	if table.valid(Player) then
	
		for i,e in pairs(Player) do
			d(tostring(i) .. " = ")
			d(e)
		end
	end
end
RegisterEventHandler("Module.Initalize",Dev.ModuleInit,"ESO Dev Update")
RegisterEventHandler("Gameloop.Update", Dev.OnUpdateHandler,"ESO Dev Update")
RegisterEventHandler("GUI.Update",Dev.GUIVarUpdate,"ESO Dev Update")
RegisterEventHandler("Gameloop.Draw", Dev.DrawCall, "ESO Dev DrawCall")
