-- Settings
maxScore = 10 -- Maximum score registered and displayed
isDebug = false -- Allow the "reset" command
isHeadShotNeeded = false -- If an headshot is needed for save the score
weapons_allowed = {  "Mk11", "SV98", "SKS", "M40A5", "M98B", "M39", "SVD", "QBU98", "L96", "JNG90" } -- Sniper Only, nil = all weapons allowed

-- Global variable
final_scoreboard = {}

-- Open SQL Communication
if not SQL:Open() then
	print('Unable to open sql: '  .. SQL:Error())
	return
end

-- Create the score table if not exist.
local query = [[
  CREATE TABLE IF NOT EXISTS sniper_score (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT,
    score FLOAT
  )
]]

if not SQL:Query(query) then
  print('Failed to create table: ' .. SQL:Error())
  return
end

print('SniperScoreboard initialized !')

-- Command : Reset scoreboard
NetEvents:Subscribe('SPScoreBoard:Reset', function(player)
	if not isDebug then
		return
	end

	if not SQL:Query('DELETE FROM sniper_score') then
		print('Failed to reset scoreboard: ' .. SQL:Error())
	end

	final_scoreboard = {}
	NetEvents:Broadcast('SPScoreBoard:UpdateScoreboard', final_scoreboard)
	print('The scoreboard was reset !')
end)

-- Event: When the level is loading, update scoreboard in memory
Events:Subscribe('Level:LoadingInfo', function()
	print('Level is loading, updating scoreboard ...')

	results = SQL:Query('SELECT username, score FROM sniper_score ORDER BY score DESC LIMIT ?', maxScore)

	if not results then
	  print('Failed to got data query: ' .. SQL:Error())
	  return
	end

	final_scoreboard = results
end)

-- Event: When a player join, send him the current scoreboard
Events:Subscribe('Player:Authenticated', function(player)
	NetEvents:SendTo('SPScoreBoard:UpdateScoreboard', player, final_scoreboard)
end)

-- Event : If a player is killed, check and update the scoreboard if neccesary
Events:Subscribe('Player:Killed', function(player, inflictor, position, weapon, isRoadKill, isHeadShot, wasVictimInReviveState, info)
	-- Check if the weapon is allowed or not on the distance scoreboard, if nil => all allowed
	local isAllowed = false

	-- Check if the weapon is in the list
	if weapons_allowed == nil then
		isAllowed = true
	else
		for _, wp in pairs(weapons_allowed) do
			if wp == weapon then
				isAllowed = true
			end
		end
	end

	-- Check if an headshot is needed
	if isHeadShotNeeded and not isHeadShot then
		isAllowed = false
	end

	-- If not allowed, return
	if not isAllowed then
		return
	end

	if info.giver then
		-- Calculate the distance
		local distanceShoot =  info.giver.soldier.transform.trans:Distance(position)

		-- Check if the player exist
		local player_result = SQL:Query('SELECT * FROM sniper_score WHERE username = ?', info.giver.name)

		local playerExist = false
		local securityCount = 0
		emitNewScore = false

		-- If the query is not nil, try to update the player
		if player_result then
			for _, player in pairs(player_result) do
				playerExist = true
				
				-- Just update the score by the bigger
				if distanceShoot > player["score"] then
					emitNewScore = true
					if not SQL:Query('UPDATE sniper_score SET score = ? WHERE username = ?', distanceShoot, info.giver.name) then
						print('Failed to update score: ' .. SQL:Error())
					end

					print("ShowMessage Update")
					local message =  'New Distance: ' .. distanceShoot
					NetEvents:SendTo('SPScoreBoard:ShowMessage', info.giver, "New Score, Nice Shot !",  message)
				end

				securityCount = securityCount + 1
			end

			-- Ok, here something bad append, multiple users was found. No problem, just keep only one
			if securityCount > 1 then
				if not SQL:Query('DELETE FROM sniper_score WHERE id NOT IN (SELECT id FROM sniper_score WHERE username = ? ORDER BY score DESC LIMIT 1)', info.giver.name) then
				  print('Failed to fix issues: ' .. SQL:Error())
				  return
				end
			end
		end

		-- If the player doesn't exist, insert it
		if not playerExist then
			if not SQL:Query('INSERT INTO sniper_score (username, score) VALUES (?, ?)', info.giver.name, distanceShoot) then
			  print('Failed to save score: ' .. SQL:Error())
			  return
			end

			print("ShowMessage Insert")
			local message =  'New Distance: ' .. distanceShoot
			NetEvents:SendTo('SPScoreBoard:ShowMessage', info.giver, "New Score, Nice Shot !", message)
			emitNewScore = true
		end
	end

	-- Emit the new scoreboard to client for display it
	if emitNewScore then
		results = SQL:Query('SELECT username, score FROM sniper_score ORDER BY score DESC LIMIT ?', maxScore)

		if not results then
		  print('Failed to got data query: ' .. SQL:Error())
		  return
		end

		final_scoreboard = results
		NetEvents:Broadcast('SPScoreBoard:UpdateScoreboard', final_scoreboard)
	end
end)