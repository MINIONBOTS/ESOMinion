-- task to handle swapping to vendor char, sell, and swap back
ai_vendorswap = inheritsFrom(ml_task)
ai_vendorswap.name = "VendorSwap"

function ai_vendorswap.Create()
	local newinst = inheritsFrom(ai_login)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	newinst.charName = ""
	newinst.state = ""
	
    return newinst
end

c_MainLogout = inheritsFrom( ml_cause )
e_MainLogout = inheritsFrom( ml_effect )
function c_MainLogout:evaluate()
	return 	GetGameState() == 2 and 
			Player.name ~= gMailTo and
			not ml_global_information.Player_InventoryNearlyFull
end
function e_MainLogout:execute()
	ml_log("e_MainLogout")
	ml_global_information.VendorChar = gMailTo
	e("Logout()")
	return ml_log(false)
end

c_VendorLogout = inheritsFrom( ml_cause )
e_VendorLogout = inheritsFrom( ml_effect )
function c_VendorLogout:evaluate()
	return 	GetGameState() == 2 and 
			Player.name == gMailTo and
			not ml_global_information.Player_InventoryNearlyFull
end
function e_VendorLogout:execute()
	ml_log("e_VendorLogout")
	ml_global_information.VendorChar = gMailTo
	e("Logout()")
	return ml_log(false)
end

c_MailToVendor = inheritsFrom( ml_cause )
e_MailToVendor = inheritsFrom( ml_effect )
c_MailToVendor.throttle = 1500

function c_MailToVendor:evaluate()
	return(	Player.name ~= gMailTo and
			gMail == "1" and 
			gMailToVendor == "1" and 
			ml_global_information.Player_InventoryNearlyFull )	
end
function e_MailToVendor:execute()
	ml_log("sending mails")
	e("RequestOpenMailbox()")
	return false
end

function ai_vendorswap:Init()
	self:add(ml_element:create( "MailToVendor", c_MailToVendor, e_MailToVendor, 300 ), self.process_elements)
	self:add(ml_element:create( "MainLogout", c_MainLogout, e_MainLogout, 250 ), self.process_elements)
	self:add(ml_element:create( "GetVendor", c_vendor, e_vendor, 225 ), self.process_elements)
end

ai_movetomap = inheritsFrom(ml_task)
function ai_movetomap.Create()
    local newinst = inheritsFrom(ai_movetomap)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
    
    --ffxiv_task_movetomap members
    newinst.name = "MOVETOMAP"
    newinst.destMapID = 0
    --newinst.tryTP = true
   
    return newinst
end

function ai_movetomap:Init()
    --local ke_teleportToMap = ml_element:create( "TeleportToMap", c_teleporttomap, e_teleporttomap, 15 )
    --self:add( ke_teleportToMap, self.process_elements)

    local ke_moveToGate = ml_element:create( "MoveToGate", c_movetogate, e_movetogate, 10 )
    self:add( ke_moveToGate, self.process_elements)
	
	
    
    self:AddTaskCheckCEs()
end

function ai_movetomap:task_complete_eval()
    return Player.localmapid == ml_task_hub:CurrentTask().destMapID
end