local tbl = 
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
						title = "-- Moveto.st priority#1 mapconnector",
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
							"-- Moveto.st priority#1 mapconnector",
							"-- todo : add unstuck node",
							"-- todo : add wayshrine usage node (maybe with paid)",
							"-- todo : add mapconnector node (maybe with paid)",
							"-- moveto should contains localmapid",
							"",
							"if not table.valid(context.moveto) then",
							"    ml_error(\"context.moveTo is not assigned\")",
							"    self:success()",
							"    return",
							"end",
							"if not table.valid(context.moveto.meshpos) then",
							"    ml_error(\"context.moveto.meshpos is not assigned\")",
							"    self:success()",
							"    return",
							"end",
							"if not context.moveto.mapid then",
							"    context.moveto.mapid = Player.mapid",
							"end",
							"if context.moveto.mapid == Player.mapid then",
							"    self:fail()",
							"    return",
							"else",
							"    context.moveto = false",
							"    ml_error(\"context.moveto is for different mapid\")",
							"    self:success()",
							"    return",
							"end",
							"self:success()",
						},
					},
				},
				
				{
					class = "Action",
					info = 
					{
						title = "-- moveto.st prio#2 ",
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
							"-- moveto.st prio#2 ",
							"-- todo: add unstuck here",
							"-- todo: set proper stop distance from pulse and movement_speed",
							"local mpos = context.moveto.meshpos",
							"if table.valid(mpos) then",
							"    if math.distance3d(Player.meshpos , mpos) < 2 then",
							"        if Player:IsMoving() then",
							"            Player:StopMovement()",
							"        end",
							"    else",
							"        Player:MoveTo(mpos.x, mpos.y, mpos.z, false, nil, 15)",
							"    end",
							"    self:running()",
							"    return",
							"else",
							"    ml_error(\"meshpos is invalid? moveto.st\")",
							"    self:success()",
							"    return",
							"end",
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