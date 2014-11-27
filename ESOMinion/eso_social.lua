--:======================================================================================================================================================================
--: eso_social
--:======================================================================================================================================================================

eso_social = {}

RegisterForEvent("EVENT_CHAT_MESSAGE_CHANNEL", true)
RegisterForEvent("EVENT_AGENT_CHAT_REQUESTED", true)

--:======================================================================================================================================================================
--: event handlers
--:======================================================================================================================================================================

RegisterEventHandler("GAME_EVENT_CHAT_MESSAGE_CHANNEL",
	function(event, eventnumber, messagetype, messagefrom, message)
		if (gPlaySoundOnWhisper == "1" and tonumber(messagetype) == g("CHAT_CHANNEL_WHISPER")) then
			d("eso_social -> new whisper: [" .. e("zo_strformat(<<1>>,"..messagefrom..")") .. "] " .. message)
			PlaySound(GetStartupPath() .. [[\MinionFiles\Sounds\Alarm1.wav]])
		end
	end
)

RegisterEventHandler("GAME_EVENT_AGENT_CHAT_REQUESTED",
	function(event, eventnumber)
		if (gPlaySoundOnWhisper == "1" and e("IsAgentChatActive()")) then
			d("eso_social -> new agent request: [" .. e("zo_strformat(<<1>>,"..event..")") .. "] " .. eventnumber)
			PlaySound(GetStartupPath() .. [[\MinionFiles\Sounds\Alarm1.wav]])
		end
	end
)
