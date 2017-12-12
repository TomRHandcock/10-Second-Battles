function agentManager.load()
	agent_positionX = {}					--This table stores the x-position of all the current agents
	agent_positionY = {}					--This table stores the y-position of all the current agents
	agent_rotation = {}
	agent_SpositionX = {}
	agent_SpositionY = {}
	agent_collider_x1 = {}				--These lines specify the positions of the sides that make up an agents box collider.
	agent_collider_y1 = {}
	agent_collider_x2 = {}
	agent_collider_y2 = {}
	agent_type = {}							--This table stores the type of agent -ie "activeplayer", "inactiveplayer", "deadplayer", "activeenemy", "inactiveenemy", "deadenemy"
	agent_desiredX = {}						--This table stores the desired location of the agent to pathfind to
	agent_desiredY = {}						--This table stores the desired location of the agent to pathfind twoards.
	agentManager.agentCount = 0				--This number is the total number of agents currently on the map, it also serves as a system to identify the sprites.
	agentManager.loadMap()
	agent_hasBeenSelected = {}
	pathfind_data = {}
	agentManager.speed = 3
	agent_dead = {}
	agentManager.player_count = 0
	agentManager.timeSinceAIUpdate = 0
end

function agentManager.update(dt)																								--This is the update procedure for the agent manager module. This procedure has a parameter for detla time - the time elapsed betweeen frames
		if agentManager.agentCount > 0 then																					--These two lines of code will loop through every agent, provided there are agents spawned.
			for agent = 1, agentManager.agentCount do
				agent_collider_x1[agent] = (agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX - (34*0.5*map_scaleX)					--These lines update the positions of the sides of the agent's collider relative to the agent's position.
				agent_collider_y1[agent] = (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY - (34*0.5*map_scaleY)
				agent_collider_x2[agent] = (agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX + (34*0.5*map_scaleX)
				agent_collider_y2[agent] = (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY + (34*0.5*map_scaleY)
			 if agentManager.selectedAgent ~= 0 and agent_dead[agent] == -1 and agent ~= agentManager.selectedAgent then																	--If there is an agent selected by the player then this variable will NOT be zero.
				 moveAI(dt)
				 agentManager.Shoot(agent)																															--This procedure moves any agents controlled by AI, it does not do any pathfinding but uses a map in order to tell an agent where to go.

				if agent_type[agent] == "enemy" and agent == agentManager.enemyPicked then			--This block of code controls which direction the agent will be looking, for now the agent will always look at the player.
				 	deltaX1 = (agent_positionX[agentManager.selectedAgent]-1)*(tile_width * map_scaleX) - (agent_positionX[agentManager.enemyPicked]-1)*(tile_width * map_scaleX)
				 	deltaY1 = (agent_positionY[agentManager.selectedAgent]-1)*(tile_height * map_scaleY) - map_offsetY - (agent_positionY[agentManager.enemyPicked]-1)*(tile_height * map_scaleY) - map_offsetY
				 	enemyRotation = math.atan(deltaX1/deltaY1)														--This is some simple trigonometry in order to obtain the angle the agent should be looking
				 	if (agent_positionY[agentManager.selectedAgent]-1)*(tile_height * map_scaleY) - map_offsetY >= (agent_positionY[agentManager.enemyPicked]-1)*(tile_height * map_scaleY) - map_offsetY then				--This block of code will alter the already existing value for the angle in order to ensure the agent is looking in the correct quartile.
						enemyRotation = math.pi - enemyRotation
				 	else
						enemyRotation = -enemyRotation
				 	end
				 	agent_rotation[agent] = enemyRotation
			 	 	end
			 	end
			end

			if agentManager.selectedAgent > 0 then
				agentManager.timeSinceAIUpdate = agentManager.timeSinceAIUpdate + 1
				if agentManager.timeSinceAIUpdate >= 0.5 then
					pathfind.find(math.floor(agent_positionX[agentManager.enemyPicked]),math.floor(agent_positionY[agentManager.enemyPicked]),math.floor(agent_positionX[agentManager.selectedAgent]),math.floor(agent_positionY[agentManager.selectedAgent]),agentManager.enemyPicked)
					agentManager.timeSinceAIUpdate = 0
				end
			end
		end
		agentManager.move(dt)																												--This procedure is responsible for moving the player.
end

function agentManager.spawnAgent(x, y, agentType, desiredX, desiredY)						--This function will spawn an agent at the desired position, the type of agent it spawns should be specified in the function.
	if x == nil then																															--These two if statements will default the x and y values to 1
		x = 1
	end
	if y == nil then
		y = 1
	end
	if agentType ~= "player" and agentType ~= "enemy" then																									--This statement will check the agent type is valid, if not it will stop the function.
		print("Not a valid agent type!")
		return
	end
	if agentType ~= "player" then
		if desiredX == nil then
			desiredX = x
			desiredY = y
		end
	else
		agentManager.player_count = agentManager.player_count + 1
	end
	agentManager.agentCount = agentManager.agentCount + 1													--This line increases the agent count variable by 1, this variable is the number of agents.
	agent_positionX[agentManager.agentCount] = x																	--The next two lines set the agent's position to what has been specified either by calling the function or the default values.
	agent_positionY[agentManager.agentCount] = y
	agent_SpositionX[agentManager.agentCount] = x
	agent_SpositionY[agentManager.agentCount] = y
	agent_type[agentManager.agentCount] = agentType																--This line sets the agent's type.
	agent_hasBeenSelected[agentManager.agentCount] = false
	bulletCoolDown[agentManager.agentCount] = 0
	agent_dead[agentManager.agentCount] = -1
end

function agentManager.loadMap()
	agentManager.agentCount = 0																										--This line will set (or reset) the agent count value to zero.
	agentManager.selectedAgent = 0
	agentManager.player_count = 0
end

function agentManager.reset()																										--This procedure simply resets all the agent positions.
	if agentManager.agentCount > 0 then
		for i = 1, agentManager.agentCount do
			agent_positionX[i] = agent_SpositionX[i]																	--The Sposition table refers to the agent's spawning position.
			agent_positionY[i] = agent_SpositionY[i]
			agentManager.selectedAgent = 0
		end
	end
end

function agentManager.drawAgents()																							--This function draws the agents.
	if agentManager.agentCount > 0 then																						--The statement ensures there are agents to draw.
		for agent = 1,agentManager.agentCount do																		--This loops through each agent spawned.
			if agent_type[agent] == "player" then																			--This statement runs if the agent type is an active player.
				love.graphics.draw(sprite[0],(agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, agent_rotation[agent], map_scaleX, map_scaleY, 17, 17)						--This line draws the agent at the desired position with thr anchor offset to the centre of the agent (this will aid in working out the agent's position)
				love.graphics.draw(sprite[1],(agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, agent_rotation[agent], map_scaleX, map_scaleY, 6.5, 14.5)					--This line simply adds a debug arrow which represents the direction the agent is facing.
				if debug_player then
					love.graphics.setColor(0, 255, 0, 255)																	--This procedure changes the colour of objects drawn.
					love.graphics.rectangle("line", agent_collider_x1[agent], agent_collider_y1[agent], 34 * map_scaleX, 34 * map_scaleY)		--This draws the rectangle surrounding the agent showing its collision box.
				end
				love.graphics.setColor(255, 255, 255, 255)															--Resetting the colour
			elseif agent_type[agent] == "Inactiveplayer" then													--This statement is for drawing the players that are 'inactive' - the ghost players.
				if agent_positionX[agent] == nil then																		--This is here for debugging purposes. If any of the values are undefined then the program will print the variable name and its assigned value - this helps determine which variable is undefined.
					print("Game crashed on frame : " .. replayManager.frame)
				end
				if tile_width == nil then
					print("Game crashed on frame : " .. replayManager.frame)
				end
				if map_scaleX == nil then
					print("Game crashed on frame : " .. replayManager.frame)
				end
				if map_offsetX == nil then
					print("Game crashed on frame : " .. replayManager.frame)
				end
				x_pos = (agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX				--These two lines load the position coordinates of the ghost player.
				y_pos = (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY
				love.graphics.draw(sprite[2], x_pos, y_pos, 0, map_scaleX, map_scaleY, 17, 17)						--This line draws the ghost agent at the desired position with the anchor offset to the centre of the agent (this will aid in working out the agent's position)
				love.graphics.draw(sprite[1],(agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, agent_rotation[agent], map_scaleX, map_scaleY, 6.5, 14.5)					--This line simply adds a debug arrow which represents the direction the agent is facing.
				if debug_player then
					love.graphics.setColor(0, 255, 0, 255)
					love.graphics.rectangle("line", agent_collider_x1[agent], agent_collider_y1[agent], 34 * map_scaleX, 34 * map_scaleY)		--This draws the rectangle surrounding the agent showing its collision box.
				end
				love.graphics.setColor(255, 255, 255, 255)
			elseif agent_type[agent] == "enemy" then																	--This repeats the first if statement in this procedure however does so with the drawable changed to an enemy.
				love.graphics.draw(sprite[3],(agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, agent_rotation[agent], map_scaleX, map_scaleY, 17, 17)						--This line draws the agent at the desired position with thr anchor offset to the centre of the agent (this will aid in working out the agent's position)
				love.graphics.draw(sprite[1],(agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, agent_rotation[agent], map_scaleX, map_scaleY, 6.5, 14.5)					--This line simply adds a debug arrow which represents the direction the agent is facing.
				if debug_player then
					love.graphics.setColor(0, 255, 0, 255)
					love.graphics.rectangle("line", agent_collider_x1[agent], agent_collider_y1[agent], 34 * map_scaleX, 34 * map_scaleY)
				end
				love.graphics.setColor(255, 255, 255, 255)
			elseif agent_type[agent] == "InactiveEnemy" then													--This is another repeat however the drawable is changed to a ghost enemy agent.
				love.graphics.draw(sprite[4],(agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, agent_rotation[agent], map_scaleX, map_scaleY, 17, 17)						--This line draws the agent at the desired position with thr anchor offset to the centre of the agent (this will aid in working out the agent's position)
				love.graphics.draw(sprite[1],(agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, agent_rotation[agent], map_scaleX, map_scaleY, 6.5, 14.5)					--This line simply adds a debug arrow which represents the direction the agent is facing.
				if debug_player then
					love.graphics.setColor(0, 255, 0, 255)
					love.graphics.rectangle("line", agent_collider_x1[agent], agent_collider_y1[agent], 34 * map_scaleX, 34 * map_scaleY)
				end
				love.graphics.setColor(255, 255, 255, 255)
			else
				print("Can't draw agent type: " .. agent_type[agent])										--This is a debug message, if the agent type is not valid.
			end
		end
	end
	agentManager.drawDead()																												--This procedure will simply draw blood around a dead agent.
	if agentManager.selectedAgent ~= 0 then
		--clearSightLine(agentManager.enemyPicked,agentManager.selectedAgent)
	end
end

function agentManager.move(dt)																									--This procedure is responsible for moving the agent the player controls. It is called from agentmanager.update()
	if agentManager.selectedAgent ~= 0 then																				--These two lines will loop through every agent if there are agents currently spawned.
		if agent_dead[agentManager.selectedAgent] == -1 then
			tile1 = map[math.floor((agent_collider_y1[agentManager.selectedAgent]-map_offsetY)/(tile_height*map_scaleY))+1][math.floor((((agent_collider_x1[agentManager.selectedAgent] + agent_collider_x2[agentManager.selectedAgent]) / 2)-map_offsetX)/(tile_width*map_scaleX))+1]		--These four lines will determine the values of the four tiles immediately adjacent to the player.
			tile2 = map[math.floor((((agent_collider_y1[agentManager.selectedAgent] + agent_collider_y2[agentManager.selectedAgent]) / 2) -map_offsetY)/(tile_height*map_scaleY))+1][math.floor((agent_collider_x2[agentManager.selectedAgent]-map_offsetX)/(tile_width*map_scaleX))+1]
			tile3 = map[math.floor((agent_collider_y2[agentManager.selectedAgent]-map_offsetY)/(tile_height*map_scaleY))+1][math.floor((((agent_collider_x1[agentManager.selectedAgent] + agent_collider_x2[agentManager.selectedAgent]) / 2)-map_offsetX)/(tile_width*map_scaleX))+1]
			tile4 = map[math.floor((((agent_collider_y1[agentManager.selectedAgent] + agent_collider_y2[agentManager.selectedAgent]) / 2)-map_offsetY)/(tile_height*map_scaleY))+1][math.floor((agent_collider_x1[agentManager.selectedAgent]-map_offsetX)/(tile_width*map_scaleX))+1]

			if love.keyboard.isDown("up") == true or love.keyboard.isDown("w") == true then		--This if statement will trigger if either 'w' or 'up' is pressed.
				if tile1 == 0 then																															--If the tile above the player is clear then the if statement will trigeer.
					agent_positionY[agentManager.selectedAgent] = agent_positionY[agentManager.selectedAgent] - 1 * dt * agentManager.speed				--This line of code will be executed which will move the players position up by subtracting from the current y-position.
				end
			elseif love.keyboard.isDown("down") == true or love.keyboard.isDown("s") == true then			--This if statement duplicates the first but with down movement.
				if tile3 == 0 then
					agent_positionY[agentManager.selectedAgent] = agent_positionY[agentManager.selectedAgent] + 1 * dt * agentManager.speed
				end
			end
			if love.keyboard.isDown("left") == true or love.keyboard.isDown("a") == true then					--This if statement again duplicates the first but for movement to the left, this time altering the x-position.
				if tile4 == 0 then
					agent_positionX[agentManager.selectedAgent] = agent_positionX[agentManager.selectedAgent] - 1 * dt * agentManager.speed
				end
			elseif love.keyboard.isDown("right") == true or love.keyboard.isDown("d") == true then		--This if statement duplicates the previous but instead uses the right direction.
				if tile2 == 0 then
					agent_positionX[agentManager.selectedAgent] = agent_positionX[agentManager.selectedAgent] + 1 * dt * agentManager.speed
				end
			end
		end
	end
end

function pathfind.find( x1, y1, x2, y2, agentNumber )														--This is the pathfind procedure, when it is called it requires the current position of the player (first two values),  the desired position of the player (next two values) and the id number of the player.
	print("Finding a path")
	if love.filesystem.exists("agent"..agentNumber..".txt") == true then													--This if statement will either create or open a file which contains a map of the path the agent should take.
		pathfind_data[agentNumber] = love.filesystem.newFile("agent"..agentNumber..".txt","w")
	else
		pathfind_data[agentNumber] = love.filesystem.newFile("agent"..agentNumber..".txt", "w")
	end
	for y=1,height do																															--This loop runs through every tile and resets it's f,g, h and path score to zero, in order to reset the function.
		for x=1,width do
			path[y][x] = 0
			f_score[y][x] = 0
			g_score[y][x] = 0
			h_score[y][x] = 0
		end
	end
	desired_h_score = 0																														--These two lines reset some variables.
	pathfindstring = ""
	f_score[y1][x1] = 1																														--The f-score of a tile is the 'cost' of the agent moving to that tile, it starts from a cost of one on the starting tile
	g_score[y2][x2] = 1																														--The g-score of a tile is the 'cost' of an agent moving from the said tile to the goal tile.
	for i=1,math.ceil(math.sqrt((height^2)+(width^2))) do													--This loop will run a number of times equivilent to the length of the longest path from any two points on the map to ensure every tile has been considered.
		for y=1,height do																														--These next loops will run through every tile on the map.
			for x=1,width do

				if map[y][x] ~= 0 then
					h_score[y][x] = 100
					f_score[y][x] = 100
					g_score[y][x] = 100
				end

				if f_score[y][x] ~= 0 and f_score[y][x] ~= 100 then																							--If a tile's f-score is not zero then this means the tile's f-score value has been set already by the function (hence why the starting tile is 1)
					if y ~= height then																										--This statement checks that the tile is not on the bottom row of the map, if it is then the if statement will run, if it is at the bottom of the map then the statement will not be triggered as there is no row below the bottom of the map.
						if f_score[y+1][x] == 0 and f_score[y+1][x] ~= 100 then																				--If the f-score of the tile below has not already been set then the pathfind procedure will set it to the f-score of the current tile plus one (the cost of moving to that tile)
							f_score[y+1][x] = f_score[y][x] + 1
						end
					end
					if y ~= 1 then																												--This is a duplication of the previous if statement but for the tile immediately above the current tile.
						if f_score[y-1][x] == 0 and f_score[y-1][x] ~= 100 then
							f_score[y-1][x] = f_score[y][x] + 1
						end
					end
					if x ~= width then																										--These two if statements deal with the tiles either side of the tile in a similar fashion to the above two.
						if f_score[y][x+1] == 0 and f_score[y][x+1] ~= 100 then
							f_score[y][x+1] = f_score[y][x] + 1
						end
					end
					if x ~= 1 then
						if f_score[y][x-1] == 0 and f_score[y][x-1] ~= 100 then
							f_score[y][x-1] = f_score[y][x] + 1
						end
					end
				end
				--g_score																																--This repeats the previous 24 lines but for the g-score instead (the cost of moving from the tile to the goal)
				if g_score[y][x] ~= 0 and g_score[y][x] ~= 100 then
					if y ~= height then
						if g_score[y+1][x] == 0 and g_score[y+1][x] ~= 100 then
							g_score[y+1][x] = g_score[y][x] + 1
						end
					end
					if y ~= 1 then
						if g_score[y-1][x] == 0 and g_score[y-1][x] ~= 100 then
							g_score[y-1][x] = g_score[y][x] + 1
						end
					end
					if x ~= width then
						if g_score[y][x+1] == 0 and g_score[y][x+1] ~= 100 then
							g_score[y][x+1] = g_score[y][x] + 1
						end
					end
					if x ~= 1 then
						if g_score[y][x-1] == 0 and g_score[y][x-1] ~= 100 then
							g_score[y][x-1] = g_score[y][x] + 1
						end
					end
				end
			end
		end
	end
	for y=1,height do																															--For all tiles in the map, if a tile is not clear then it is not possible to move to it, these values that are set will eliminate that tile from being a potential path.
		for x=1,width do
			h_score[y][x] = f_score[y][x] + g_score[y][x]
			if y == y1 and x == x1 then																								--If the current tile is the starting tile then the h-score of this tile will be the same for all tiles along the path.
				desired_h_score = h_score[y][x]
			end
		end
	end
	for y=1,height do
		for x=1,width do
			if h_score[y][x] == h_score[y1][x1] then
				if y ~= 1 then
					if g_score[y][x] > g_score[y-1][x] then																--This block of code will assign the direction an agent should move in order to progress along the path if they were on a particular tile. For example if a tile has a path score of 1, the agent should move up.
						path[y][x] = 1
					end
				end
				if x ~= width then
					if g_score[y][x] > g_score[y][x+1] then
						path[y][x] = 2
					end
				end
				if y ~= height then
					if g_score[y][x] > g_score[y+1][x] then
						path[y][x] = 3
					end
				end
				if x ~= 1 then
					if g_score[y][x] > g_score[y][x-1] then
						path[y][x] = 4
					end
				end
				pathfindstring = pathfindstring .. path[y][x]
			else
				pathfindstring = pathfindstring .. "0"
			end
		end
	end
	--pathfind_data[agentNumber]:open("w")																				--These lines of code are not needed as the pathfinding system will only ever need to deal with one agent concurrently, therefore a single table can be used to store the values of the path scores an agent should take rather than files for a multi-agent system.
	--pathfind_data[agentNumber]:write(pathfindstring)
end

function agentManager.drawDead()																								--This procedure will simply draw blood around any agents that are dead.
	if agentManager.agentCount > 0 then
		for agent = 1, agentManager.agentCount do
			if agent_dead[agent] <= replayManager.frame and agent_dead[agent] ~= -1 then
				love.graphics.draw( sprite[7], (agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, 0, map_scaleX * 2, map_scaleY * 2,16,16)
			end
		end
	end
end

function agentManager.Shoot(agent)
	if bulletCoolDown[agent] <= 0  then
		if clearSightLine(agentManager.enemyPicked,agentManager.selectedAgent) == true then
			bulletManager.spawn(agent_positionX[agent],agent_positionY[agent],agent)
		end
	end
end

function clearSightLine(agent, target)
	if agent > 0 and target > 0 then
		sourceX = agent_positionX[agent]
		sourceY = agent_positionY[agent]

		targetX = agent_positionX[target]
		targetY = agent_positionY[target]

		if sourceX < targetX then
			smallestX = math.floor(sourceX)
			largestX = math.ceil(targetX)
		else
			smallestX = math.floor(targetX)
			largestX = math.ceil(sourceX)
		end

		if sourceY < targetY then
			smallestY = math.floor(sourceY)
			largestY = math.ceil(targetY)
		else
			smallestY = math.floor(targetY)
			largestY = math.ceil(sourceY)
		end

		clear = true

		gradient = ((MapToY(sourceY)-MapToY(targetY)))/((MapToX(sourceX)-MapToX(targetX)))
		y_offset = MapToY(sourceY) - (gradient * MapToX(sourceX))
		--print("Gradient: " .. gradient .. " y_offset: " .. y_offset)
		--love.graphics.setColor(255,0,0,255)
		--love.graphics.circle("fill", (x-1)*(tile_width * map_scaleX) + map_offsetX, (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY, 5)

		for y=1,love.graphics.getHeight() do
			for x=map_offsetX,love.graphics.getWidth() do
				if math.floor(y) == math.floor((x * gradient) + y_offset) then
					if clear == true then
						love.graphics.setColor(0, 255, 0, 255)
					else
						love.graphics.setColor(255, 0, 0, 255)
					end
					--love.graphics.circle("fill", x, y, 1)
					love.graphics.setColor(255, 255, 255, 255)
					if YtoMap(y) >= smallestY and YtoMap(y) <= largestY and XtoMap(x) >= smallestX and XtoMap(x) <= largestX then
						if map[math.floor(YtoMap(y))][math.floor(XtoMap(x))] ~= 0 then
							--print("There is something in the way")
							clear = false
						end
					end
				end
			end
		end
		return clear
	end
end

function MapToX(x)
	return (x-1)*(tile_width * map_scaleX) + map_offsetX
end

function MapToY(y)
return (y-1)*(tile_height * map_scaleY) + map_offsetY
end

function XtoMap(x)
	return (x - map_offsetX)/(tile_width*map_scaleX)+1
end

function YtoMap(y)
	return (y - map_offsetY)/(tile_height*map_scaleY)+1
end
