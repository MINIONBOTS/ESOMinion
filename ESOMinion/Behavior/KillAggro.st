local tbl = 
{
	class = "SubTree",
	info = 
	{
		createlocalcontext = true,
		title = "Kill Aggro",
	},
	nodes = 
	{
		
		{
			class = "PrioritySelector",
			info = 
			{
			},
			nodes = 
			{
				
				{
					class = "Action",
					info = 
					{
						title = "Aggro Getter",
					},
					nodes = 
					{
					},
					settings = 
					{
					},
					variables = 
					{
						runcode = 
						{
							"---kill aggro st prio #1",
							"",
							"if not context.combat then",
							"    context.combat = {}",
							"end",
							"if not Player.isswimming and Player.incombat then",
							"    ---get aggrp enemy",
							"    if not context.combat.aggro_target_id then",
							"        --- maybe not need this code...?",
							"        --[[",
							"                local now_target_id = tonumber(context.combat.target_id)",
							"                if now_target_id then",
							"                    local target = EntityList:Get(now_target_id)",
							"                    if target.health.current > 0 then",
							"                        d(\"target_id was already assigned. KillAggro.st\")",
							"                        context.combat.aggro_target_id = target.id",
							"                    end",
							"                end",
							"        ]]",
							"        if not context.combat.aggro_target_id then",
							"            local TargetList = MEntityList(\"maxdistance=20,hostile,aggro\")",
							"            if table.valid(TargetList) then",
							"                local best = nil",
							"                local lowestHP = math.huge",
							"                for i, e in pairs(TargetList) do",
							"                    if e.health.current > 0 then",
							"                        if e.health.current < lowestHP then",
							"                            lowestHP = e.health.current",
							"                            best = e",
							"                        end",
							"                    end",
							"                end",
							"                if best then",
							"                    context.combat.aggro_target_id = best.id",
							"                end",
							"            end",
							"        end",
							"    end",
							"end",
							"",
							"if context.combat.aggro_target_id then",
							"    if not Player.isswimming then",
							"        d(\"player is swimming disable aggro status\")",
							"        context.combat.aggro_target_id = false",
							"    end",
							"    local target = EntityList:Get(context.combat.aggro_target_id)",
							"    if not table.valid(target) or target.health.current <= 0 then",
							"        context.combat.aggro_target_id = false",
							"        d(\"current aggro target dead.\")",
							"        self:success()",
							"        return",
							"    else",
							"        context.combat.target_id = context.combat.aggro_target_id",
							"    end",
							"",
							"end",
							"",
							"self:fail()",
						},
					},
				},
				
				{
					class = "Sequence",
					info = 
					{
						title = "kill aggro seq#1",
					},
					nodes = 
					{
						
						{
							class = "Action",
							info = 
							{
								title = "---kill aggro st sequence #1",
							},
							nodes = 
							{
							},
							settings = 
							{
							},
							variables = 
							{
								runcode = 
								{
									"if context.combat.aggro_target_id then",
									"",
									"    self:success()",
									"else",
									"    self:fail()",
									"end",
								},
							},
						},
						
						{
							class = "PrioritySelector",
							info = 
							{
							},
							nodes = 
							{
								
								{
									class = "SubTree",
									info = 
									{
										createlocalcontext = true,
										description = "",
										title = "",
									},
									nodes = 
									{
									},
									settings = 
									{
									},
									variables = 
									{
										filename = "Combat_Handler.st",
									},
								},
								
								{
									class = "Action",
									info = 
									{
									},
									nodes = 
									{
									},
									settings = 
									{
									},
									variables = 
									{
										runcode = 
										{
											"self:success()",
										},
									},
								},
							},
							settings = 
							{
							},
							variables = 
							{
							},
						},
					},
					settings = 
					{
					},
					variables = 
					{
					},
				},
				
				{
					class = "Action",
					info = 
					{
					},
					nodes = 
					{
					},
					settings = 
					{
					},
					variables = 
					{
						runcode = 
						{
							"if context.combat.aggro_target_id then",
							"",
							"    self:success()",
							"else",
							"",
							"    self:fail()",
							"end",
						},
					},
				},
			},
			settings = 
			{
			},
			variables = 
			{
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
	},
}



return tbl