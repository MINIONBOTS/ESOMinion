-- general task for all non combat movement
-- responsible for:
--		moving to position
--		moving to mapid
--		mount/dismount
--		handling aggro
--		handling stuck

eso_task_moveto = inheritsFrom(ml_task)
function eso_task_moveto.Create()
    local newinst = inheritsFrom(eso_task_moveto)
    
    --eso_task_moveto members
    newinst.name = "MOVETOPOS"
    newinst.pos = 0
    newinst.range = 1.5
    newinst.doFacing = false
    newinst.remainMounted = false
    newinst.useFollowMovement = false
	
	newinst.distanceCheckTimer = 0
	newinst.lastPosition = nil
	newinst.lastDistance = 0
    
    return newinst
end

function eso_task_moveto:Init()	
	-- first init any superclass cnes and add task complete/fail cnes
	self:InitSuper()
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_movetomap = ml_element:create( "MoveToMap", c_movetomap, e_movetomap, 25 )
    self:add( ke_movetomap, self.process_elements)
	
	local ke_mount = ml_element:create( "Mount", c_mount, e_mount, 20 )
    self:add( ke_mount, self.process_elements)
   
    local ke_walktopos = ml_element:create( "WalkToPos", c_walktopos, e_walktopos, 10 )
    self:add( ke_walktopos, self.process_elements)
end

function eso_task_moveto:task_complete_eval()
	--[[if (IsPositionLocked() or IsLoading() or ml_mesh_mgr.loadingMesh ) then
		return true
	end]]

	local myPos = Player.pos
	local gotoPos = pos
	
	local distance = Distance3D(myPos.x, myPos.y, myPos.z, gotoPos.x, gotoPos.y, gotoPos.z)
	return distance < self.range 
end

function eso_task_moveto:task_complete_execute()
    Player:Stop()
	
	if(not self.remainMounted and ai_mount:IsMounted()) then
		ai_mount:Dismount()
	end
	
	if (self.doFacing) then
		Player:SetFacing(self.pos.h)
    end
	
    ml_task_hub:CurrentTask().completed = true
end

eso_task_moveto_kill = inheritsFrom(eso_task_moveto)
function eso_task_moveto_kill.Create()
    local newinst = inheritsFrom(eso_task_moveto_kill)
    
	-- within 30 we'll use combat movement instead
	newinst.range = 30
	newinst.targetid = 0
    
    return newinst
end

function eso_task_moveto_kill:Init()	
	-- first init any superclass cnes and add task complete/fail cnes
	self:InitSuper()
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_updatetarget = ml_element:create( "UpdateTarget", c_updatetarget, e_updatetarget, 10 )
    self:add( ke_updatetarget, self.overwatch_elements)
end

function eso_task_moveto_kill:task_complete_eval()
	--[[if (IsPositionLocked() or IsLoading() or ml_mesh_mgr.loadingMesh ) then
		return true
	end]]

	local myPos = Player.pos
	local gotoPos = pos
	
	local distance = Distance3D(myPos.x, myPos.y, myPos.z, gotoPos.x, gotoPos.y, gotoPos.z)
	return distance < self.range 
end

function eso_task_moveto_kill:task_complete_execute()
    Player:Stop()
	
	if(not self.remainMounted and ai_mount:IsMounted()) then
		ai_mount:Dismount()
	end
	
	if (self.doFacing) then
		Player:SetFacing(self.pos.h)
    end
	
    ml_task_hub:CurrentTask().completed = true
end

eso_task_moveto_interact = inheritsFrom(eso_task_moveto)
function eso_task_moveto_interact.Create()
    local newinst = inheritsFrom(eso_task_moveto_interact)
    
	-- within 30 we'll use combat movement instead
	newinst.range = 1.5
	newinst.targetid = 0
    
    return newinst
end

function eso_task_moveto_interact:Init()	
	-- first init any superclass cnes and add task complete/fail cnes
	self:InitSuper()
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_updatetarget = ml_element:create( "UpdateTarget", c_updatetarget, e_updatetarget, 10 )
    self:add( ke_updatetarget, self.overwatch_elements)
end

eso_task_killtarget = inheritsFrom(ml_task)
function eso_task_killtarget.Create()
    local newinst = inheritsFrom(eso_task_killtarget)
    
	newinst.targetid = 0
    newinst.targetfunction = nil
    return newinst
end

function eso_task_killtarget:Init()	
	-- first init any superclass cnes and add task complete/fail cnes
	self:InitSuper()
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_movetotarget = ml_element:create( "MoveToTarget", c_movetotarget, e_movetotarget, 15 )
    self:add( ke_movetotarget, self.process_elements)
	
	local ke_attacktarget = ml_element:create( "AttackTarget", c_attacktarget, e_attacktarget, 10 )
    self:add( ke_attacktarget, self.process_elements)
end

function eso_task_killtarget:task_complete_eval()
	--[[if (IsPositionLocked() or IsLoading() or ml_mesh_mgr.loadingMesh ) then
		return true
	end]]
	
	local target = EntityList:Get(self.targetid)
	if(ValidTable(target)) then
		return not target.alive
	end
	
	return false
end

function eso_task_killtarget:task_fail_eval()
	-- this task will go in reactive queue so it must have death check
	if (Player.dead) then
		return true
	end
	
	local target = EntityList:Get(self.targetid)
	if(not ValidTable(target)) then
		return true
	end
	
	local besttargetid = 0
	if(self.targetfunction and type(self.targetfunction) == "function") then
		besttargetid = self.targetfunction()
		if(besttarget and besttargetid ~= 0 and besttargetid ~= target.id) then
			return true
		end
	end
	
	return false
end

