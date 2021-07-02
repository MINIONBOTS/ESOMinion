local tbl = 
{
	class = "SubTree",
	info = 
	{
		createlocalcontext = true,
		description = "priority node (self:fail() in the end) \nCheck Game State / Wait handler / Loot Picker\n\n\ntodo : Death handler.",
		title = "BT Top",
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
						title = "GameState/Mesh Checker",
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
							"if GetGameState() == 3 then",
							"    if not table.valid(context.base) then",
							"        context.base = {}",
							"    end",
							"    self:fail()",
							"else",
							"    self:success()",
							"end",
						},
					},
				},
				
				{
					class = "Action",
					info = 
					{
						title = "Wait handler",
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
							"--wait node use like this (milsecond base)",
							"-- context.wait = 1000 ",
							"--[[",
							"context.wait = {",
							"    timer = 1000,",
							"    func = function(self)",
							"        if true then",
							"            return true",
							"        end",
							"    end,",
							"}",
							"]]",
							"if context.wait then",
							"    if tonumber(context.wait) then",
							"        local tbl = {",
							"            --timer = context.wait,",
							"            limit = Now() + context.wait,",
							"        }",
							"        context.wait = tbl",
							"    end",
							"    if table.valid(context.wait) then",
							"        local w = context.wait",
							"        if not tonumber(w.limit) then",
							"            w.limit = Now() + (tonumber(w.timer) or 5000)",
							"        end",
							"        if w.limit < Now() then",
							"            context.wait = false",
							"            self:fail()",
							"            return",
							"        end",
							"        if type(w.func) == \"function\" and w.func(w) == true then",
							"            context.wait = false",
							"            self:fail()",
							"            return",
							"        end",
							"    end",
							"    self:success()",
							"    return",
							"end ",
							"self:fail()",
						},
					},
				},
				
				{
					class = "PrioritySelector",
					info = 
					{
						title = "Loot Handler",
					},
					nodes = 
					{
						
						{
							class = "Action",
							info = 
							{
								title = "---BT Top.st / loot node prio",
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
									"---BT Top.st / loot node prio",
									"if Player.interacttype == 2 then",
									"    d(\"loot window open\")",
									"    e(\"LootAll(true)\")",
									"    if Player:IsMoving() then",
									"        Player:StopMovement()",
									"    end",
									"    self:success()",
									"    return",
									"end",
									"",
									"---get lootable nearby",
									"if not context.base.lootable_id then",
									"    local el = MEntityList(\"lootable,nearest,maxdistance=20\")",
									"    if table.valid(el) then",
									"        local id, tbl = next(el)",
									"        d(\"nearest lootable detected. name: \" .. tostring(tbl.name) .. \"  distance: \" .. tostring(tbl.distance))",
									"        context.base.lootable_id = id",
									"    end",
									"end",
									"",
									"if context.base.lootable_id then",
									"    local target = EntityList:Get(context.base.lootable_id)",
									"    if not table.valid(target) then",
									"        context.base.lootable_id = false",
									"        d(\"disable lootable target. gone\")",
									"        self:success()",
									"        return",
									"    end",
									"    if target.interacttype ~= 1 then",
									"        context.base.lootable_id = false",
									"        d(\"disable lootable target. no longer lootable\")",
									"        self:success()",
									"        return",
									"    end",
									"    if target.distance < 4 then",
									"        local interactable = MGetGameCameraInteractableActionInfo()",
									"        if interactable == \"Search\" then",
									"            d(\"lootable status detected\")",
									"            target:Interact()",
									"            if Player:IsMoving() then",
									"                Player:StopMovement()",
									"            end",
									"            self:success()",
									"            return",
									"        end",
									"    end",
									"    context.moveto = target",
									"end",
									"self:fail()",
									"",
								},
							},
						},
						
						{
							class = "Sequence",
							info = 
							{
							},
							nodes = 
							{
								
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
											"if context.base.lootable_id then",
											"    self:success()",
											"else",
											"    self:fail()",
											"end",
										},
									},
								},
								
								{
									class = "SubTree",
									info = 
									{
										createlocalcontext = true,
										description = "context.moveto = {\n pos = {x = 0 , y = 0 , z = 0},\n meshpos = {x = 0 , y = 0 , z = 0},\n mapid = 0,\n}",
										title = "moveto node. need context.moveto",
									},
									nodes = 
									{
									},
									settings = 
									{
									},
									variables = 
									{
										filename = "Moveto.st",
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