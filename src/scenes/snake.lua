local SceneManager = require("src.scene_manager")
local M = {}

function M.enter() end

function M.draw()
  love.graphics.clear(0.05, 0.05, 0.07)
  love.graphics.setColor(1,1,1)
  love.graphics.setNewFont(28)
  love.graphics.printf("Snake (soon)", 0, 320, love.graphics.getWidth(), "center")
  love.graphics.setNewFont(16)
  love.graphics.printf("Press Esc to return", 0, 370, love.graphics.getWidth(), "center")
end

function M.keypressed(key)
  if key == "escape" then SceneManager.switch("menu") end
end

return M
