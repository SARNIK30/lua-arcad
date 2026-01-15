local M = {}

local scenes = {}
local current = nil

function M.init()
  scenes.menu = require("src.scenes.menu")
  scenes.snake = require("src.scenes.snake")
  scenes.minesweeper = require("src.scenes.minesweeper")
  scenes.pacman = require("src.scenes.pacman")
end

function M.switch(name)
  current = scenes[name]
  if current and current.enter then current.enter() end
end

function M.update(dt)
  if current and current.update then current.update(dt) end
end

function M.draw()
  if current and current.draw then current.draw() end
end

function M.keypressed(key)
  if current and current.keypressed then current.keypressed(key) end
end

function M.mousepressed(x, y, button)
  if current and current.mousepressed then current.mousepressed(x, y, button) end
end

function M.resize(w, h)
  if current and current.resize then current.resize(w, h) end
end

return M
