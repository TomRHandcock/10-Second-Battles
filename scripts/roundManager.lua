function pickEnemy()
  picked = 0
  while agent_type[picked] ~= "enemy" do
    picked = math.random(1,agentManager.agentCount)
    print("Selected agent " .. agent_type[picked])
  end
  wakeUp(picked)
end

function wakeUp(ID)
  agentManager.enemyPicked = ID
  replay_positionX[agentManager.enemyPicked] = {}
  replay_positionY[agentManager.enemyPicked] = {}
  replay_rotation[agentManager.enemyPicked] = {}
  replay_bullet[agentManager.enemyPicked] = {}
  agent_hasBeenSelected[agentManager.enemyPicked] = true
  print("Starting pathfind X1: " .. agent_positionX[ID] .. " Y1: " .. agent_positionY[ID] .. " X2: " .. agent_positionX[agentManager.selectedAgent] .. " Y2: " .. agent_positionY[agentManager.selectedAgent])
  pathfind.find(math.floor(agent_positionX[ID]),math.floor(agent_positionY[ID]),math.floor(agent_positionX[agentManager.selectedAgent]),math.floor(agent_positionY[agentManager.selectedAgent]),ID)
end

function moveAI(dt)
  for ID=1,agentManager.agentCount do
    if agent_type[ID] == "enemy" and picked == ID then
      if agent_dead[ID] == -1 then
        if path[math.floor(agent_positionY[ID])][math.floor(agent_positionX[ID])] == 1 then
          agent_positionY[ID] = agent_positionY[ID] - 0.3 * dt * agentManager.speed
        elseif path[math.floor(agent_positionY[ID])][math.floor(agent_positionX[ID])] == 2 then
          agent_positionX[ID] = agent_positionX[ID] + 0.3 * dt * agentManager.speed
        elseif path[math.floor(agent_positionY[ID])][math.floor(agent_positionX[ID])] == 3 then
          agent_positionY[ID] = agent_positionY[ID] + 0.3 * dt * agentManager.speed
        elseif path[math.floor(agent_positionY[ID])][math.floor(agent_positionX[ID])] == 4 then
          agent_positionX[ID] = agent_positionX[ID] - 0.3 * dt * agentManager.speed
        end
      end
    end
  end
end

function endGame()
  love.graphics.setColor(0,0,0,255)
  love.graphics.print("Game Over", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  love.graphics.setColor(255, 255, 255, 255)
end
