--:======================================================================================================================================================================
--: eso_social
--:======================================================================================================================================================================
--: edited 9.28.2014

eso_social = {}

RegisterForEvent("EVENT_CHAT_MESSAGE_CHANNEL", true)
RegisterForEvent("EVENT_AGENT_CHAT_REQUESTED", true)

--:======================================================================================================================================================================
--: event handlers
--:======================================================================================================================================================================
--: todo: add a friend/guild/group ignore check

RegisterEventHandler("GAME_EVENT_CHAT_MESSAGE_CHANNEL",
	function(event, eventnumber, messagetype, messagefrom, message)
		if (gPlaySoundOnWhisper == "1" and messagetype == g("CHAT_CHANNEL_WHISPER")) then
			d("eso_social -> new whisper: [" .. e("zo_strformat(<<1>>,"..messagefrom..")") .. "] " .. message)
			e("PlaySound(New_Notification)")
		else
			--d("eso_social -> new whisper: [" .. e("zo_strformat(<<1>>,"..messagefrom..")") .. "] " .. message)
			--e("PlaySound(New_Notification)")
		end
	end
)

RegisterEventHandler("GAME_EVENT_AGENT_CHAT_REQUESTED",
	function(event, eventnumber)
		if (gPlaySoundOnWhisper == "1" and e("IsAgentChatActive()")) then
			d("eso_social -> new agent request: [" .. e("zo_strformat(<<1>>,"..event..")") .. "] " .. eventnumber)
			e("PlaySound(New_Notification)")
		end
	end
)

--:======================================================================================================================================================================
--: functions
--:======================================================================================================================================================================

function eso_social.IsFriend(messagefrom)
	if (e("IsFriend("..messagefrom..")")) then
		return true
	else
		for index = 1, e("GetNumFriends()") do
			local accountname = e("GetFriendInfo("..tostring(index)..")")
			local _, charactername = e("GetFriendCharacterInfo("..tostring(index)..")")
			
			if (messagefrom == accountname or messagefrom == charactername) then
				return true
			end
		end
	end
	
	return false
end
