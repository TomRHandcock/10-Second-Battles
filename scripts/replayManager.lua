function replayManager.load()
    replayManager.timeLeft = 10
    replayManager.timeElapsed = 0
    replayManager.frame = 0
    replay_positionX = {}
    replay_positionY = {}
    replay_rotation = {}
    replay_bullet = {}
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
    replay_positionX[agentManager.selectedAgent][replayManager.frame] = agent_positionX[agentManager.selectedAgent]
    replay_positionY[agentManager.selectedAgent][replayManager.frame] = agent_positionY[agentManager.selectedAgent]
    replay_rotation[agentManager.selectedAgent][replayManager.frame] = agent_rotation[agentManager.selectedAgent]
    if replay_bullet[agentManager.selectedAgent][replayManager.frame] ~= true then
      replay_bullet[agentManager.selectedAgent][replayManager.frame] = false
    end
    replay_positionX[agentManager.enemyPicked][replayManager.frame] = agent_positionX[agentManager.enemyPicked]
    replay_positionY[agentManager.enemyPicked][replayManager.frame] = agent_positionY[agentManager.enemyPicked]
    replay_rotation[agentManager.enemyPicked][replayManager.frame] = agent_rotation[agentManager.enemyPicked]
    replay_bullet[agentManager.enemyPicked][replayManager.frame] = false
  end
end

function replayManager.play()
  for i=1,agentManager.agentCount do
    if agent_hasBeenSelected[i] == true and replayManager.timeLeft > 0 then
      if agent_type[i] == "Inactiveplayer" or agent_type[i] == "InactiveEnemy" then
        if replay_positionX[i][replayManager.frame] ~= nil then
          if agent_type[i] == "Inactiveplayer" or agent_type[i] == "InactiveEnemy" then
            if replay_bullet[i][replayManager.frame] == true then
              bulletManager.spawn(agent_positionX[i],agent_positionY[i],i)
            end
          end
          print(agent_type[i] .. " died on frame " .. agent_dead[i])
          if agent_dead[i] >= replayManager.frame or agent_dead[i] == -1 then
            agent_positionX[i] = replay_positionX[i][replayManager.frame]
            agent_positionY[i] = replay_positionY[i][replayManager.frame]
            agent_rotation[i] = replay_rotation[i][replayManager.frame]
            --print("Agent number: " .. i .. " location X: " .. agent_positionX[i] .. " Y: " ..   agent_positionY[i])
          end
          end
        end
      end
    end
  end
