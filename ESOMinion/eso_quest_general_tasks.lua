-- general task for all non combat movement
-- responsible for:
--		moving to position
--		moving to mapid
--		mount/dismount
--		handling aggro
--		handling stuck

eso_task_moveto = inheritsFrom(ml_task)
eso_task_moveto.name = "MOVETOPOS"
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
	self:AddTaskCheckCEs()

	local ke_endinteract = ml_element:create( "EndInteract", c_endinteract, e_endinteract, 30 )
    self:add( ke_endinteract, self.overwatch_elements)
	
	local ke_handleaggro = ml_element:create( "HandleAggro", c_handleaggro, e_handleaggro, 25 )
    self:add( ke_handleaggro, self.overwatch_elements)
	
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
	local gotoPos = self.pos
	
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
eso_task_moveto_kill.name = "MOVETOKILL"
function eso_task_moveto_kill.Create()
    local newinst = inheritsFrom(eso_task_moveto_kill)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	-- within 30 we'll use combat movement instead
	newinst.range = 30
	newinst.targetid = 0
	newinst.name = "MOVETOKILL"
    
    return newinst
end

function eso_task_moveto_kill:Init()	
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_endinteract = ml_element:create( "EndInteract", c_endinteract, e_endinteract, 30 )
    self:add( ke_endinteract, self.overwatch_elements)
	
	local ke_handleaggro = ml_element:create( "HandleAggro", c_handleaggro, e_handleaggro, 25 )
    self:add( ke_handleaggro, self.overwatch_elements)
	
	local ke_mount = ml_element:create( "Mount", c_mount, e_mount, 20 )
    self:add( ke_mount, self.process_elements)
   
    local ke_walktopos = ml_element:create( "WalkToPos", c_walktopos, e_walktopos, 10 )
    self:add( ke_walktopos, self.process_elements)
	
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
eso_task_moveto_interact.name = "MOVETOINTERACT"
function eso_task_moveto_interact.Create()
    local newinst = inheritsFrom(eso_task_moveto_interact)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	-- within 30 we'll use combat movement instead
	newinst.range = 1.5
	newinst.targetid = 0
	newinst.name = "MOVETOINTERACT"
    
    return newinst
end

function eso_task_moveto_interact:Init()	
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_endinteract = ml_element:create( "EndInteract", c_endinteract, e_endinteract, 30 )
    self:add( ke_endinteract, self.overwatch_elements)
	
	local ke_handleaggro = ml_element:create( "HandleAggro", c_handleaggro, e_handleaggro, 25 )
    self:add( ke_handleaggro, self.overwatch_elements)
	
	local ke_mount = ml_element:create( "Mount", c_mount, e_mount, 20 )
    self:add( ke_mount, self.process_elements)
   
	local ke_dismount = ml_element:create( "Disount", c_dismount, e_dismount, 20 )
    self:add( ke_dismount, self.process_elements)
   
  local ke_walktopos = ml_element:create( "WalkToPos", c_walktopos, e_walktopos, 10 )
    self:add( ke_walktopos, self.process_elements)
	
	local ke_updatetarget = ml_element:create( "UpdateTarget", c_updatetarget, e_updatetarget, 10 )
    self:add( ke_updatetarget, self.overwatch_elements)
end

eso_task_moveto_map = inheritsFrom(ml_task)
function eso_task_moveto_map.Create()
    local newinst = inheritsFrom(eso_task_moveto_map)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
    
    --eso_task_moveto_map members
    newinst.name = "MOVETOMAP"
    newinst.destMapID = 0
	newinst.origMapID = 0
    newinst.tryTP = true
   
    return newinst
end

function eso_task_moveto_map:Init()	
	local ke_handleaggro = ml_element:create( "HandleAggro", c_handleaggro, e_handleaggro, 25 )
    self:add( ke_handleaggro, self.overwatch_elements)
	
    local ke_teleportToMap = ml_element:create( "TeleportToMap", c_teleporttomap, e_teleporttomap, 15 )
    self:add( ke_teleportToMap, self.overwatch_elements)
	
	local ke_interactGate = ml_element:create( "InteractGate", c_interactgate, e_interactgate, 11 )
    self:add( ke_interactGate, self.process_elements)

    local ke_moveToGate = ml_element:create( "MoveToGate", c_movetogate, e_movetogate, 10 )
    self:add( ke_moveToGate, self.process_elements)
    
    self:AddTaskCheckCEs()
end

function eso_task_moveto_map:task_complete_eval()
    return Player.localmapid == ml_task_hub:ThisTask().destMapID
end

eso_task_killtarget = inheritsFrom(ml_task)
eso_task_killtarget.name = "KILLTARGET"
function eso_task_killtarget.Create()
    local newinst = inheritsFrom(eso_task_killtarget)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	newinst.name = "KILLTARGET"
	newinst.targetid = 0
    newinst.targetfunction = nil
    return newinst
end

function eso_task_killtarget:Init()	
	self:AddTaskCheckCEs()

	local ke_combattip = ml_element:create( "CombatTip", c_combattip, e_combattip, 20 )
    self:add( ke_combattip, self.overwatch_elements)
	
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
	if(e("IsUnitDead(player)")) then
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

eso_task_combattip = inheritsFrom(ml_task)
eso_task_combattip.name = "COMBATTIP"
function eso_task_combattip.Create()
    local newinst = inheritsFrom(eso_task_combattip)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	newinst.name = "COMBATTIP"
    return newinst
end

function eso_task_combattip:Init()	
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_handleblock = ml_element:create( "HandleBlock", c_block, e_block, 15 )
    self:add( ke_handleblock, self.process_elements)
	
	local ke_handledodge = ml_element:create( "HandleDodge", c_dodge, e_dodge, 15 )
    self:add( ke_handledodge, self.process_elements)
	
	local ke_handlestagger = ml_element:create( "HandleStagger", c_stagger, e_stagger, 15 )
    self:add( ke_handlestagger, self.process_elements)
end

function eso_task_combattip:task_complete_eval()
	return Player:GetNumActiveCombatTips() == 0
end

function eso_task_combattip:task_fail_eval()
	return not Player.alive
end
