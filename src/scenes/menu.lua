local SceneManager = require("src.scene_manager")
local VERSION = require("src.version")
local M = {}

local buttons = {}

local function addButton(text, y, action)
  table.insert(buttons, {
    text = text, x = 520, y = y, w = 240, h = 52,
    action = action
  })
end

local function inside(mx, my, b)
  return mx >= b.x and mx <= (b.x + b.w) and my >= b.y and my <= (b.y + b.h)
end

function M.enter()
  buttons = {}
  addButton("Snake",       250, function() SceneManager.switch("snake") end)
  addButton("Minesweeper", 320, function() SceneManager.switch("minesweeper") end)
  addButton("Pac-Man (WIP)",390, function() SceneManager.switch("pacman") end)
  addButton("Quit",        460, function() love.event.quit() end)
end

function M.draw()
  love.graphics.setColor(0.45, 0.55, 0.65)
love.graphics.printf(VERSION.name .. " v" .. VERSION.version, 0, love.graphics.getHeight() - 24, love.graphics.getWidth(), "center")

  local W = love.graphics.getWidth()

  love.graphics.setColor(0.2, 0.9, 1.0)
  love.graphics.setNewFont(48)
  love.graphics.printf("LUA ARCADE", 0, 120, W, "center")

  love.graphics.setNewFont(18)
  love.graphics.setColor(0.7, 0.85, 1.0)
  love.graphics.printf("Choose a game", 0, 180, W, "center")

  for _, b in ipairs(buttons) do
    local mx, my = love.mouse.getPosition()
    local hovered = inside(mx, my, b)

    if hovered then
      love.graphics.setColor(0.18, 0.26, 0.35)
    else
      love.graphics.setColor(0.12, 0.18, 0.25)
    end

    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 14, 14)
    love.graphics.setColor(0.2, 0.9, 1.0)
    love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 14, 14)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(b.text, b.x, b.y + 16, b.w, "center")
  end

  love.graphics.setColor(0.6, 0.7, 0.8)
  love.graphics.printf("Esc - quit", 0, 660, W, "center")
end

function M.mousepressed(x, y, button)
  if button ~= 1 then return end
  for _, b in ipairs(buttons) do
    if inside(x, y, b) then
      b.action()
      return
    end
  end
end

function M.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

return M
