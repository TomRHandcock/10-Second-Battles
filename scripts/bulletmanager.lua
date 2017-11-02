function bulletManager.load()
  bulletX = {}
  bulletY = {}
  bulletX_velocity = {}
  bulletY_velocity = {}
  bullet_rotation = {}
  bulletCount = 0
  bulletCoolDown = {}
  bullet_owner = {}
end

function bulletManager.spawn( x, y, agent)
  if bulletCoolDown[agent] <= 0 and agent_rotation[agent] ~= nil then
    bulletCount = bulletCount + 1
    bulletX_velocity[bulletCount] = 300 * math.sin(agent_rotation[agent])
    bulletY_velocity[bulletCount] = -300 * math.cos(agent_rotation[agent])
    bulletX[bulletCount] = (agent_positionX[agent]-1)*(tile_width * map_scaleX) + map_offsetX
    bulletY[bulletCount] = (agent_positionY[agent]-1)*(tile_height * map_scaleY) + map_offsetY
    bullet_rotation[bulletCount] = agent_rotation[agent]
    print("Bullet number: " .. bulletCount .. " spawned")
    bulletCoolDown[agent] = 0.3
    replay_bullet[agent][replayManager.frame] = true
    bullet_owner[bulletCount] = agent
  end
end

function bulletManager.update()
  if bulletCount ~= 0 then
    for i=1,bulletCount do
      bulletX[i] = bulletX[i] + bulletX_velocity[i] * deltaTime
      bulletY[i] = bulletY[i] + bulletY_velocity[i] * deltaTime
    end
  end

  if agentManager.agentCount > 0 then
    for i=1,agentManager.agentCount do
      if bulletCoolDown[i] > 0 then
        bulletCoolDown[i] = bulletCoolDown[i] - deltaTime
      end
    end
  end
end

function bulletManager.draw()
  if bulletCount ~= 0 then
    for i=1,bulletCount do
      love.graphics.draw(sprite[6],bulletX[i],bulletY[i],bullet_rotation[i]-(math.pi/2))
    end
  end
end

function bulletManager.reset()
  bulletX = {}
  bulletY = {}
  bulletX_velocity = {}
  bulletY_velocity = {}
  bullet_rotation = {}
  bulletCount = 0
end

function bulletManager.collision()
  if agentManager.agentCount > 0 then
    for agent = 1,agentManager.agentCount do
      if bulletCount > 0 then
        for bullet = 1,bulletCount do
          if bulletX[bullet] > agent_collider_x1[agent] and bulletX[bullet] < agent_collider_x2[agent] then
						if bulletY[bullet] > agent_collider_y1[agent] and bulletY[bullet] < agent_collider_y2[agent] then
              if bullet_owner[bullet] ~= agent and agent_hasBeenSelected[agent] == true then
                print("A bullet hit " .. agent)
                agent_dead[agent] = replayManager.frame
              end
            end
          end
        end
      end
    end
  end
end
