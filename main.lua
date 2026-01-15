local SceneManager = require("src.scene_manager")

function love.load()
  love.keyboard.setKeyRepeat(true)
  SceneManager.init()
  SceneManager.switch("menu")
end

function love.update(dt)
  SceneManager.update(dt)
end

function love.draw()
  SceneManager.draw()
end

function love.keypressed(key)
  SceneManager.keypressed(key)
end

function love.mousepressed(x, y, button)
  SceneManager.mousepressed(x, y, button)
end

function love.resize(w, h)
  SceneManager.resize(w, h)
end
