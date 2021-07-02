local tbl = 
{
	class = "SubTree",
	info = 
	{
		createlocalcontext = true,
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
						title = "-- combat handler prio #1",
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
							"-- combat handler prio #1",
							"-- todo : AddCombatMovement and avoidance in next nodes",
							"-- todo : set base range for move to (current weapon base)",
							"if not context.combat then",
							"    context.combat = {}",
							"end",
							"",
							"if context.combat.target_id then",
							"",
							"    local target = MGetEntity(context.combat.target_id)",
							"    if target and target.health.current > 0 then",
							"        Player:SetFacing(target.pos,true)",
							"        eso_skillmanager.Cast( target )",
							"    else",
							"        context.combat.target_id = false",
							"        self:success()",
							"        return",
							"    end",
							"    local mpos = target.meshpos",
							"    if math.distance3d(Player.meshpos , mpos) < 3 then",
							"        if Player:IsMoving() then",
							"            Player:StopMovement()",
							"        end",
							"    else",
							"        Player:MoveTo(mpos.x, mpos.y, mpos.z, false, nil, 15)",
							"    end",
							"    self:running()",
							"    return",
							"else",
							"    self:success()",
							"end",
							"",
							"",
						},
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
}



return tbl