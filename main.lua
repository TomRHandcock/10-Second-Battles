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
end

function love.update(dt)
	if scene == 2 then
		agentManager.update(dt)
		replayManager.update(dt)
		timeElapsed = timeElapsed + dt
		if timeElapsed >= 1 then
			FPS = math.floor(1 / dt)
			timeElapsed = 0
		end
		mouseX = love.mouse.getX()
		mouseY = love.mouse.getY()
		if agentManager.selectedAgent ~= 0 then
			if agent_dead[agentManager.selectedAgent] == -1 then
				deltaX = mouseX - (agent_positionX[agentManager.selectedAgent]-1)*(tile_width * map_scaleX) - map_offsetX
				deltaY = mouseY - (agent_positionY[agentManager.selectedAgent]-1)*(tile_height * map_scaleY) - map_offsetY
				playerRotation = math.atan(deltaX/deltaY)
				if mouseY >= (agent_positionY[agentManager.selectedAgent]-1)*(tile_height * map_scaleY) - map_offsetY then
					playerRotation = math.pi - playerRotation
				else
					playerRotation = -playerRotation
				end
				agent_rotation[agentManager.selectedAgent] = playerRotation
			end

			if love.mouse.isDown(1) then
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
				if h_score[y][x] == desired_h_score then
					--love.graphics.setColor(0, 255, 0, 255)
					--love.graphics.draw(sprite[5],(x-0.5)*(tile_width * map_scaleX) + map_offsetX,(y-0.5)*(tile_height * map_scaleY) + map_offsetY, (path[y][x]-1)*(math.pi/2), map_scaleX*0.8, map_scaleY*0.8, 17, 17)
					--love.graphics.setColor(255, 0, 0, 255)
					--love.graphics.print(path[y][x],(x-0.5)*(tile_width * map_scaleX) + map_offsetX,(y-0.5)*(tile_height * map_scaleY) + map_offsetY)
					--love.graphics.setColor(255, 255, 255, 255)
				end
			end
		end
		agentManager.drawAgents()								--This function is handled by the Agent Manager, it just draws the agents.
		bulletManager.draw()
		drawUI()
	elseif scene == 1 then
		drawMenu()
	end
end

function drawUI()
	love.graphics.print("Time Left: " .. (math.floor(replayManager.timeLeft*10))/10, 10, 10)
	--love.graphics.print("Frame: " .. replayManager.frame, 10, 70)
	love.graphics.print("FPS: " .. FPS, 10, 70)
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
								end
							else
								print("Please select a valid agent")
							end
						end
					end
				end
			end
		end
end

function love.keyreleased(key)
	if key == "f1" then
		agentManager.selectedAgent = -1
	end
end

function drawMenu()
	love.graphics.draw(titleScreen, (love.graphics.getWidth()-titleScreen:getWidth()*2/3)/2, 0, 0, 2/3, 2/3)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("10 Second Battles", love.graphics.getWidth()/2-(602/2), love.graphics.getHeight()/4)
	love.graphics.setColor(255, 255,255, 255)
end
