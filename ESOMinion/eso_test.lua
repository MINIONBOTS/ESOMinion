function DevTest()
	RegisterForEvent("EVENT_QUEST_POSITION_REQUEST_COMPLETE", true)

	RegisterEventHandler("GAME_EVENT_QUEST_POSITION_REQUEST_COMPLETE",
		function (eventCode, taskId, pinType, x, y, areaRadius, insideCurrentMapWorld, isBreadcrumb)
			d("eventCode: "..tostring(eventCode))
			d("taskId: "..tostring(taskId))
			d("pinType: "..tostring(pinType))
			d("x: "..tostring(x))
			d("y: "..tostring(y))
			d("areaRadius: "..tostring(areaRadius))
			d("insideCurrentMapWorld: "..tostring(insideCurrentMapWorld))
			d("isBreadcrumb: "..tostring(isBreadcrumb))
		end
	)
	
	GUI_SizeWindow("Dev",250,800)
	GUI_UnFoldGroup("Dev","QuestInfo")
	GUI_WindowVisible("Dev",true)
end