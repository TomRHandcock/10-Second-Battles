function replayManager.load()
    replayManager.timeLeft = 10
    replayManager.timeElapsed = 0
    replayManager.frame = 0
    replay_positionX = {}
    replay_positionY = {}
    replay_rotation = {}
    replay_bullet = {}
    replayManager.round_count = 0
end


function replayManager.update(dt)
    if agentManager.selectedAgent ~= 0 then
      if replayManager.timeLeft >= 0 then
        replayManager.timeLeft = replayManager.timeLeft - dt
        replayManager.timeElapsed = replayManager.timeElapsed + dt
        replayManager.frame = replayManager.frame + 1
        replayManager.record()
        replayManager.play()
        --print(replayManager.timeLeft)
      else
        agent_type[agentManager.selectedAgent] = "Inactiveplayer"
        agent_type[agentManager.enemyPicked] = "InactiveEnemy"
        print("Last frame : " .. replayManager.frame)
        print("Agent number " .. agentManager.selectedAgent .. " changed to " .. agent_type[agentManager.selectedAgent])
        replayManager.reset()
        agentManager.reset()
        bulletManager.reset()
      end
    end
end

function replayManager.reset()
  replayManager.timeLeft = 10
  replayManager.timeElapsed = 0
  replayManager.frame = 0
end

function replayManager.record()
  --print("Recorded agent position on frame: " .. replayManager.frame)
  if agentManager.selectedAgent ~= -1 then
    replay_positionX[agentManager.selectedAgent][math.floor(replayManager.timeLeft*100)/100] = agent_positionX[agentManager.selectedAgent]
    replay_positionY[agentManager.selectedAgent][math.floor(replayManager.timeLeft*100)/100] = agent_positionY[agentManager.selectedAgent]
    replay_rotation[agentManager.selectedAgent][math.floor(replayManager.timeLeft*100)/100] = agent_rotation[agentManager.selectedAgent]
    if replay_bullet[agentManager.selectedAgent][math.floor(replayManager.timeLeft*100)/100] ~= true then
      replay_bullet[agentManager.selectedAgent][math.floor(replayManager.timeLeft*100)/100] = false
      print("Not shooting now")
    end
    replay_positionX[agentManager.enemyPicked][math.floor(replayManager.timeLeft*100)/100] = agent_positionX[agentManager.enemyPicked]
    replay_positionY[agentManager.enemyPicked][math.floor(replayManager.timeLeft*100)/100] = agent_positionY[agentManager.enemyPicked]
    replay_rotation[agentManager.enemyPicked][math.floor(replayManager.timeLeft*100)/100] = agent_rotation[agentManager.enemyPicked]
    replay_bullet[agentManager.enemyPicked][math.floor(replayManager.timeLeft*100)/100] = false
  end
end

function replayManager.play()
  for i=1,agentManager.agentCount do
    if agent_hasBeenSelected[i] == true and replayManager.timeLeft > 0 then
      if agent_type[i] == "Inactiveplayer" or agent_type[i] == "InactiveEnemy" then
        if replay_positionX[i][math.floor(replayManager.timeLeft*100)/100] ~= nil then
          if agent_type[i] == "Inactiveplayer" or agent_type[i] == "InactiveEnemy" then
            if replay_bullet[i][math.floor(replayManager.timeLeft*100)/100] == true then
              bulletManager.spawn(agent_positionX[i],agent_positionY[i],i)
            end
          end

          if agent_dead[i] >= replayManager.frame or agent_dead[i] == -1 then
            agent_positionX[i] = replay_positionX[i][math.floor(replayManager.timeLeft*100)/100]
            agent_positionY[i] = replay_positionY[i][math.floor(replayManager.timeLeft*100)/100]
            agent_rotation[i] = replay_rotation[i][math.floor(replayManager.timeLeft*100)/100]
            --print("Agent number: " .. i .. " location X: " .. agent_positionX[i] .. " Y: " ..   agent_positionY[i])
          end
          end
        end
      end
    end
  end
