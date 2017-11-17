function love.load()
	loadAssets()		--This function handles the loading of assets such as images
	agentManager = {}													--This is a table of functions and variables used by the agentManager system.
	replayManager = {}
	pathfind = {}
	bulletManager = {}
	require("scripts/agentManager")						--This function simply ensures the Agent Manager script is loaded.
	require("scripts/replayManager")
	require("scripts/roundManager")
	require("scripts/bulletmanager")
	require("level/level0")
	agentManager.load()												--This function instantiates the agent manager which handles all the details of the agents and pathfinding.
	replayManager.load()
	pathfind.load()
	bulletManager.load()
	loadMap()
	scene = 1																	--This value is the scene number, the scene being the game's state, such as the menu, or level selector.
	timeElapsed = 0
	FPS = 0
	debug_pathfind = false
end

function love.update(dt)																												--This function is called once per frame.
	if scene == 2 then																														--Checking that the game scene is active.
		agentManager.update(dt)																											--These two lines are delegating relevent tasks to different function.
		replayManager.update(dt)
		timeElapsed = timeElapsed + dt																							--These next 5 lines calculate the FPS.
		if timeElapsed >= 1 then
			FPS = math.floor(1 / dt)
			timeElapsed = 0
		end
		mouseX = love.mouse.getX()																									--Updating the mouse position.
		mouseY = love.mouse.getY()
		if agentManager.selectedAgent ~= 0 then																			--Updating the rotation of the controlled agent.
			if agent_dead[agentManager.selectedAgent] == -1 then
				deltaX = mouseX - (agent_positionX[agentManager.selectedAgent]-1)*(tile_width * map_scaleX) - map_offsetX
				deltaY = mouseY - (agent_positionY[agentManager.selectedAgent]-1)*(tile_height * map_scaleY) - map_offsetY
				playerRotation = math.atan(deltaX/deltaY)																--The angle of the player is found by using some simply trigonometry, it is then adjusted to ensure this angle is in the right quartile.
				if mouseY >= (agent_positionY[agentManager.selectedAgent]-1)*(tile_height * map_scaleY) - map_offsetY then
					playerRotation = math.pi - playerRotation
				else
					playerRotation = -playerRotation
				end
				agent_rotation[agentManager.selectedAgent] = playerRotation
			end

			if love.mouse.isDown(1) then																							--If the left mouse button is pressed then the bullet system will spawn a bullet at the agent's position.
				bulletManager.spawn(agent_positionX[agentManager.selectedAgent],agent_positionY[agentManager.selectedAgent],agentManager.selectedAgent)
			end
			bulletManager.update()
		end
		bulletManager.collision()
	end
	deltaTime = dt
end

function love.draw()
	if scene == 2 then												--This if statement only completes if the game is actually being run.
		for y=1,height do												--These two lines loop through every tile on the map.
			for x=1,width do
				love.graphics.draw(tile[map[y][x]],(x-1)*(tile_width * map_scaleX) + map_offsetX,(y-1)*(tile_height * map_scaleY) + map_offsetY, 0, map_scaleX, map_scaleY)			--This line draws the tiles.
				if h_score[y][x] == desired_h_score and debug_pathfind == true then
					love.graphics.setColor(0, 255, 0, 255)
					love.graphics.draw(sprite[5],(x-0.5)*(tile_width * map_scaleX) + map_offsetX,(y-0.5)*(tile_height * map_scaleY) + map_offsetY, (path[y][x]-1)*(math.pi/2), map_scaleX*0.8, map_scaleY*0.8, 17, 17)
					love.graphics.setColor(255, 0, 0, 255)
					love.graphics.print(path[y][x],(x-0.5)*(tile_width * map_scaleX) + map_offsetX,(y-0.5)*(tile_height * map_scaleY) + map_offsetY)
					love.graphics.setColor(255, 255, 255, 255)
				end
			end
		end
		agentManager.drawAgents()								--This function is handled by the Agent Manager, it just draws the agents.
		bulletManager.draw()
		drawUI()
	elseif scene == 1 then
		drawMenu()
	elseif scene == 1.1 then
		drawLevels()
	end
end

function drawUI()
	love.graphics.print("Time Left: " .. (math.floor(replayManager.timeLeft*10))/10, 10, 10)
	--love.graphics.print("Frame: " .. replayManager.frame, 10, 70)
	love.graphics.print("FPS: " .. FPS, 10, 70)
	if agentManager.selectedAgent == 0 and agentManager.player_count == replayManager.round_count then
		endGame()
	end
end

function loadAssets()
	tile = {}
	for i=0,1 do														--Each tile is assigned an "ID" which can be found as a suffix in it's file name
		tile[i] = love.graphics.newImage("img/tile" .. i .. ".png")				--This function loops through the tiles in the range and adds them to a "dictionary" of tiles
	end
	sprite = {}
	sprite[0] = love.graphics.newImage("img/Character.png")
	sprite[1] = love.graphics.newImage("img/Direction Arrow.png")
	sprite[2] = love.graphics.newImage("img/InactiveCharacter.png")
	sprite[3] = love.graphics.newImage("img/Enemy.png")
	sprite[4] = love.graphics.newImage("img/InactiveEnemy.png")
	sprite[5] = love.graphics.newImage("img/Arrow.png")
	sprite[6] = love.graphics.newImage("img/bullet.png")
	sprite[7] = love.graphics.newImage("img/blood.png")
	titleScreen = love.graphics.newImage("img/TitleScreen.png")
	start_button = love.graphics.newImage("img/Start Button.png")
	quit_button = love.graphics.newImage("img/Quit Button.png")
	font = love.graphics.newFont("font/BadMofo.ttf", 90)
	love.graphics.setFont(font)
end

function loadMap()
	width = 15			-- These are a couple of variables that need to be defined in order for the map system to function
	height = 15		-- There is the width and height of the map and the width and height of the tiles.
	tile_height = 32
	tile_width = 32
	map_scaleX = 1.5
	map_scaleY = 1.5
	map_offsetX = (love.graphics.getWidth()/2 - (tile_width*map_scaleX*width) / 2) -- This function places the map in the middle of the screen by tweaking the offset, it subtracts half the width of the map from the centre of the screen
	map_offsetY = 0
	getMap()
end

function love.mousereleased(x, y, button, isTouch)
		if scene == 2 then
			if agentManager.agentCount > 0 then
				for i=1,agentManager.agentCount do
					if x > agent_collider_x1[i] and x < agent_collider_x2[i] then
						if y > agent_collider_y1[i] and y < agent_collider_y2[i] then
							if agent_type[i] == "player" then
								if agentManager.selectedAgent == 0 then
									agentManager.selectedAgent = i
									pickEnemy()
									print("Agent number " .. i .. " selected")
									replay_positionX[agentManager.selectedAgent] = {}
									replay_positionY[agentManager.selectedAgent] = {}
									replay_rotation[agentManager.selectedAgent] = {}
									replay_bullet[agentManager.selectedAgent] = {}
									agent_hasBeenSelected[agentManager.selectedAgent] = true
									replayManager.round_count = replayManager.round_count + 1
								end
							else
								print("Please select a valid agent")
							end
						end
					end
				end
			end
		elseif scene == 1 then
			if x >= love.graphics.getWidth()/2-403*0.25 and x <= love.graphics.getWidth()/2+403*0.25 then
				if y >= love.graphics.getHeight()/2 and y <= love.graphics.getHeight()/2 + 308*0.25 then
					scene = 2
				elseif y >= love.graphics.getHeight()/2 + 100 and y <= love.graphics.getHeight()/2 +100 + 308*0.25 then
					love.event.quit()
				end
			end
		end
end

function love.keyreleased(key)
	if key == "f1" then
		agentManager.selectedAgent = -1
	elseif key == "f2" then
		if debug_pathfind == true then
			debug_pathfind = false
		else
			debug_pathfind = true
		end
	end
end

function drawMenu()
	love.graphics.draw(titleScreen, (love.graphics.getWidth()-titleScreen:getWidth()*2/3)/2, 0, 0, 2/3, 2/3)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("10 Second Battles", love.graphics.getWidth()/2-(602/2), love.graphics.getHeight()/4)
	love.graphics.setColor(255, 255,255, 255)
	love.graphics.draw(start_button, love.graphics.getWidth()/2-403*0.25, love.graphics.getHeight()/2, 0, 0.25, 0.25)
	love.graphics.draw(quit_button, love.graphics.getWidth()/2-403*0.25, love.graphics.getHeight()/2 + 100, 0, 0.25, 0.25)
end

function drawLevels()
	love.graphics.draw(titleScreen, (love.graphics.getWidth()-titleScreen:getWidth()*2/3)/2, 0, 0, 2/3, 2/3)
end
