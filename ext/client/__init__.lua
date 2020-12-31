--Settings
inputPress = InputDeviceKeys.IDK_F2 -- Input for Open / Close the Menu

-- Load the WebUI
Events:Subscribe('Extension:Loaded', function()
    WebUI:Init()
	WebUI:Hide()
	print("UI initialized.")
end)

Events:Subscribe("Player:Connected", function(player)
	WebUI:Show()
	print("UI is now ready !")
end)

-- When key is pressed, show, and hide when unpress

Events:Subscribe('Client:UpdateInput', function(data)
	if InputManager:WentKeyDown(inputPress) then
		WebUI:ExecuteJS('showScoreboard();')
	end
end)

-- NetEvent : Show notification
NetEvents:Subscribe('SPScoreBoard:ShowMessage', function(title, message)
	WebUI:ExecuteJS("showMessage('"..title.."', '"..message.."');")
end)

-- NetEvent : Got update of scoreboard from the server
NetEvents:Subscribe('SPScoreBoard:UpdateScoreboard', function(scoreboard)
	print(json.encode(scoreboard))
	WebUI:ExecuteJS("updateScoreboard('"..json.encode(scoreboard).."');")
end)

-- Command : Reset command
Console:Register('reset', 'Reset the scoreboard.', function(args)
	NetEvents:SendLocal('SPScoreBoard:Reset')
	print("The scoreboard was reset !")
	return nil
end)