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
						title = "-- MoveToRandom priority #1",
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
							"-- MoveToRandom priority #1",
							"if not table.valid(context.moveToRandom) or",
							"        context.moveToRandom.mapid ~= Player.mapid then",
							"    d(\"generate random move to location\")",
							"    local max, min = Settings.ESOMINION.random_move_radius, Settings.ESOMINION.random_move_radius * 0.8",
							"    local rpos = eso_bt_helper.GetRandomPointOnCricle(Player.pos, min, max, 10)",
							"    if not table.valid(rpos) then",
							"        d(\"failed to generate random move to location\")",
							"        self:success()",
							"        return",
							"    end",
							"    context.moveToRandom = {",
							"        meshpos = rpos,",
							"        pos = rpos,",
							"        mapid = Player.mapid,",
							"    }",
							"end",
							"",
							"if table.valid(context.moveToRandom) then",
							"d(\"random position active\")",
							"    if math.distance3d(Player.pos ,  context.moveToRandom.pos) < 5 then",
							"        d(\"reached random point. generate random point again\")",
							"        context.moveToRandom = false",
							"        self:success()",
							"        return",
							"    end",
							"    context.moveto = context.moveToRandom",
							"    self:fail()",
							"else",
							"    self:success()",
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