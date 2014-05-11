--****************************************************************************
-- ai_mail
--****************************************************************************
ai_mail={}
ai_mail.queue = nil
ai_mail.taskdone = false
ai_mail.MainWindow = { Name = GetString("mail"), x = 350, y = 50, w = 250, h = 200}
ai_mail.visible = false


--****************************************************************************
-- MailBox Open Event
--****************************************************************************
RegisterForEvent("EVENT_MAIL_OPEN_MAILBOX", true)
RegisterEventHandler("GAME_EVENT_MAIL_OPEN_MAILBOX",
	function(...)
		d("mailbox test")
		if 	(ml_global_information.running and ai_mail.queue == nil ) then
			d("MailBox opened")
			ai_mail.taskdone= false
			ai_mail.queue = ai_mail:CreateNewQueue()
		end
	end
)
--****************************************************************************
-- MailBox Close Event
--****************************************************************************
RegisterForEvent("EVENT_MAIL_CLOSE_MAILBOX", true)	
RegisterEventHandler("GAME_EVENT_MAIL_CLOSE_MAILBOX",
	function(...)
		if 	ml_global_information.running then
			d("MailBox closed")
			ai_mail.queue = nil
		end
	end
)

--****************************************************************************
-- Mail Sent Failed Event
--****************************************************************************
RegisterForEvent("EVENT_MAIL_SEND_FAILED", true)	
RegisterEventHandler("GAME_EVENT_MAIL_SEND_FAILED",
	function(...)
		if 	ml_global_information.running then
			d("Sending Mail Failed")
			--nothing for now
		end
	end
)

--****************************************************************************
-- Mail Queue
--****************************************************************************
function ai_mail:CreateNewQueue()
	local queue = {}
	queue.last = 0
	queue.throttle = 2500
	queue.finished = false
	ai_vendor.vendored = false
				
	function queue:run()
	
		if ( ml_global_information.Now - queue.last > queue.throttle) then
			queue.last = ml_global_information.Now
			
			if not ai_mail.taskdone then
				d("Sending Mails")
				ai_mail:SendMails()
				return
			end
			if ml_global_information.running then
				d("Closing MailBox")
				e("CloseMailbox()")
				return
			end
			
			d("Mail queue completed")
			queue.finished = true
			ai_mail.queue = nil
			
		end
	end
	
	return queue
end

--****************************************************************************
-- Function thetime
--****************************************************************************

function ai_mail:thetime()
time = os.date("*t")
local minute = time.min
local seconde = time.sec
	if(minute < 10) then
		minute = ("0"..minute)
	end
	if(seconde < 10)then
		seconde = ("0"..seconde)
	end
	local thetime = (time.hour .. "h" ..minute..":"..seconde)
	return thetime
end

--****************************************************************************
-- Function SendMail
--****************************************************************************

function ai_mail:SendMails()

local bagIcon,InventoryMax = e("GetBagInfo(1)")
local numSlot = 1
local canAttach
local stackInfo
local itemType
local itemKind
local stackCount = 0
local mItemName = ""
local bodymail = tostring(ai_mail:thetime()).."\n"

	for i=0,InventoryMax,1 do
		canAttach = e("CanQueueItemAttachment(1,"..tostring(i)..","..tostring(numSlot)..")")
		if(canAttach) then
		itemType = e("GetItemFilterTypeInfo(1,"..tostring(i)..")")
		stackInfo =	{e("GetItemInfo(1,"..tostring(i)..")")}
		stackCount = stackInfo[2]
		itemKind = e("GetItemType(1,"..tostring(i)..")")
		mItemName= e("GetItemName(1,"..tostring(i)..")")
			if(tonumber(e("GetCurrentMoney()")) > 50)then
				if((itemKind ~= g("ITEMTYPE_POTION")) or (itemKind ~= g("ITEMTYPE_LOCKPICK")) or (itemKind ~= g("ITEMTYPE_AVA_REPAIR")) )then
					if((tonumber(stackCount)>= tonumber(gMailStack)) or (tonumber(itemType) == 2) or (tonumber(itemType) ==1) or (itemKind == g("ITEMTYPE_GLYPH_ARMOR")) or (itemKind == g("ITEMTYPE_GLYPH_WEAPON")) or (itemKind == g("ITEMTYPE_GLYPH_JEWELRY")) or (itemKind == g("ITEMTYPE_RECIPE")) )then
					e("QueueItemAttachment(1,"..tostring(i)..","..tostring(numSlot)..")")
						bodymail = bodymail..tostring(stackCount).."x "..tostring(mItemName).."\n"
						numSlot = numSlot + 1
						if(numSlot == 7) then 
							e("SendMail("..tostring(gMailTo)..","..tostring(gSubject)..","..tostring(bodymail)..")")
							numSlot = 1
							return
						end
					end
				end
			end
		end
	end
	e("ClearQueuedMail()")
	ai_mail.taskdone = true

end

--****************************************************************************
-- Initialize
--****************************************************************************
RegisterEventHandler("Module.Initalize",
	function()
		if ( Settings.ESOMinion.gMail == nil ) then
			Settings.ESOMinion.gMail = "0"
		end
		if ( Settings.ESOMinion.gMailTo == nil ) then
			Settings.ESOMinion.gMailTo = ""
		end	
		if ( Settings.ESOMinion.gSubject == nil ) then
			Settings.ESOMinion.gSubject = ""
		end	
		if( Settings.ESOMinion.gMailStack == nil)then
			Settings.ESOMinion.gMailStack = "100"
		end
		
		GUI_NewCheckbox(ml_global_information.MainWindow.Name,GetString("enableMailing"),"gMail",GetString("settings"))
		GUI_NewWindow(ai_mail.MainWindow.Name,ai_mail.MainWindow.x,ai_mail.y,ai_mail.MainWindow.w,ai_mail.MainWindow.h,"",true)
		GUI_NewField(ai_mail.MainWindow.Name,GetString("mailto"),"gMailTo","Mail")
		GUI_NewField(ai_mail.MainWindow.Name,GetString("mailsubject"),"gSubject","Mail")
		GUI_NewNumeric(ai_mail.MainWindow.Name,GetString("mailstack"),"gMailStack","Mail","25","100")
		GUI_UnFoldGroup(ai_mail.MainWindow.Name,"Mail" )
		
		gMail = Settings.ESOMinion.gMail
		gMailTo = Settings.ESOMinion.gMailTo
		gSubject = Settings.ESOMinion.gSubject
		gMailStack = Settings.ESOMinion.gMailStack
		GUI_WindowVisible(ai_mail.MainWindow.Name,false)
	end
)

--****************************************************************************
-- GuiVarUpdate
--****************************************************************************

function ai_mail.guivarupdate(Event, NewVals, OldVals)

	
	for k,v in pairs(NewVals) do
		if (k == "gMail" or
			k == "gMailTo" or
			k == "gMailStack" or
			k == "gSubject"
		)						
		then
			Settings.ESOMinion[tostring(k)] = v

		end
	end
	GUI_RefreshWindow(ai_mail.MainWindow.Name)
end
RegisterEventHandler("GUI.Update",ai_mail.guivarupdate)

--****************************************************************************
-- Toggle Menu
--****************************************************************************

function ai_mail.ToggleMenu()
	if (ai_mail.visible) then
		GUI_WindowVisible(ai_mail.MainWindow.Name,false)	
		
		ai_mail.visible = false
	else
		local wnd = GUI_GetWindowInfo("MinionBot")	
		GUI_MoveWindow( ai_mail.MainWindow.Name, wnd.x+wnd.width,wnd.y) 
		GUI_WindowVisible(ai_mail.MainWindow.Name,true)	
		ai_mail.visible = true
	end
end

RegisterEventHandler("ai_mail.toggle", ai_mail.ToggleMenu)

--****************************************************************************
-- Cause/Effect
--****************************************************************************

c_sendmail = inheritsFrom( ml_cause )
e_sendmail = inheritsFrom( ml_effect )
c_sendmail.throttle = 1500

function c_sendmail:evaluate()
	if( (gMail == "1") and (ai_vendor.vendored == true))then
		d("test")
		return true
	end
	return false	
end


function e_sendmail:execute()
ml_log("sending mails")
e("RequestOpenMailbox()")
return false
end


--****************************************************************************
-- Game Loop
--****************************************************************************
RegisterEventHandler("Gameloop.Update",
	function()
		if 	ml_global_information.running and
			ai_mail.queue and
			not ai_mail.queue.finished
		then
			ai_mail.queue:run()
		end
	end
)
