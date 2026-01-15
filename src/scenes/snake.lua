local SceneManager = require("src.scene_manager")
local M = {}

-- Grid settings
local CELL = 24
local GRID_W, GRID_H = 0, 0
local OFFSET_X, OFFSET_Y = 0, 0

-- Game state
local snake = {}
local dir = { x = 1, y = 0 }
local nextDir = { x = 1, y = 0 }
local food = { x = 10, y = 10 }
local alive = true
local paused = false

local score = 0
local best = 0

-- Timing
local stepTimer = 0
local stepDelay = 0.12  -- speed

local function clamp(v, a, b)
  if v < a then return a end
  if v > b then return b end
  return v
end

local function setupGrid()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()

  GRID_W = math.floor((w - 200) / CELL)
  GRID_H = math.floor((h - 200) / CELL)

  GRID_W = clamp(GRID_W, 12, 40)
  GRID_H = clamp(GRID_H, 12, 26)

  local gridPxW = GRID_W * CELL
  local gridPxH = GRID_H * CELL

  OFFSET_X = math.floor((w - gridPxW) / 2)
  OFFSET_Y = math.floor((h - gridPxH) / 2) + 20
end

local function samePos(a, b)
  return a.x == b.x and a.y == b.y
end

local function insideSnake(x, y)
  for _, s in ipairs(snake) do
    if s.x == x and s.y == y then return true end
  end
  return false
end

local function spawnFood()
  local tries = 0
  while tries < 2000 do
    local x = love.math.random(1, GRID_W)
    local y = love.math.random(1, GRID_H)
    if not insideSnake(x, y) then
      food.x, food.y = x, y
      return
    end
    tries = tries + 1
  end
end

local function resetGame()
  setupGrid()

  snake = {
    { x = math.floor(GRID_W / 2),     y = math.floor(GRID_H / 2) },
    { x = math.floor(GRID_W / 2) - 1, y = math.floor(GRID_H / 2) },
    { x = math.floor(GRID_W / 2) - 2, y = math.floor(GRID_H / 2) },
  }

  dir = { x = 1, y = 0 }
  nextDir = { x = 1, y = 0 }
  score = 0
  alive = true
  paused = false
  stepTimer = 0
  stepDelay = 0.12

  spawnFood()
end

local function setDir(x, y)
  -- prevent reversing direction
  if (#snake >= 2) then
    if dir.x == -x and dir.y == -y then return end
  end
  nextDir.x, nextDir.y = x, y
end

local function step()
  dir.x, dir.y = nextDir.x, nextDir.y

  local head = snake[1]
  local newHead = { x = head.x + dir.x, y = head.y + dir.y }

  -- wrap around
  if newHead.x < 1 then newHead.x = GRID_W end
  if newHead.x > GRID_W then newHead.x = 1 end
  if newHead.y < 1 then newHead.y = GRID_H end
  if newHead.y > GRID_H then newHead.y = 1 end

  -- collision (with body)
  for i = 1, #snake do
    if snake[i].x == newHead.x and snake[i].y == newHead.y then
      alive = false
      if score > best then best = score end
      return
    end
  end

  -- move
  table.insert(snake, 1, newHead)

  -- food
  if samePos(newHead, food) then
    score = score + 1
    -- speed up a bit
    stepDelay = math.max(0.06, stepDelay - 0.002)
    spawnFood()
  else
    table.remove(snake) -- remove tail
  end
end

-- Scene lifecycle
function M.enter()
  -- load best from save file (optional)
  if love.filesystem.getInfo("snake_best.txt") then
    local t = love.filesystem.read("snake_best.txt")
    best = tonumber(t) or 0
  end

  resetGame()
end

function M.resize()
  setupGrid()
end

function M.update(dt)
  if paused then return end
  if not alive then return end

  stepTimer = stepTimer + dt
  while stepTimer >= stepDelay do
    stepTimer = stepTimer - stepDelay
    step()
  end
end

local function drawCell(x, y, r, g, b)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle(
    "fill",
    OFFSET_X + (x - 1) * CELL + 2,
    OFFSET_Y + (y - 1) * CELL + 2,
    CELL - 4, CELL - 4,
    6, 6
  )
end

function M.draw()
  love.graphics.clear(0.05, 0.06, 0.09)

  local W, H = love.graphics.getWidth(), love.graphics.getHeight()

  -- Title
  love.graphics.setColor(0.2, 0.9, 1.0)
  love.graphics.setNewFont(36)
  love.graphics.printf("SNAKE", 0, 32, W, "center")

  -- Info
  love.graphics.setNewFont(18)
  love.graphics.setColor(0.8, 0.9, 1.0)
  love.graphics.printf("Score: " .. score .. "    Best: " .. best, 0, 78, W, "center")

  -- Grid background
  love.graphics.setColor(0.08, 0.10, 0.16)
  love.graphics.rectangle("fill", OFFSET_X - 10, OFFSET_Y - 10, GRID_W * CELL + 20, GRID_H * CELL + 20, 18, 18)

  love.graphics.setColor(0.2, 0.9, 1.0)
  love.graphics.rectangle("line", OFFSET_X - 10, OFFSET_Y - 10, GRID_W * CELL + 20, GRID_H * CELL + 20, 18, 18)

  -- Food
  drawCell(food.x, food.y, 1.0, 0.35, 0.4)

  -- Snake
  for i, s in ipairs(snake) do
    if i == 1 then
      drawCell(s.x, s.y, 0.2, 0.9, 1.0)
    else
      drawCell(s.x, s.y, 0.12, 0.55, 0.75)
    end
  end

  -- Bottom hint
  love.graphics.setColor(0.65, 0.75, 0.9)
  love.graphics.printf("WASD / Arrows • Esc - Menu • R - Restart • Space - Pause", 0, H - 40, W, "center")

  if paused then
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, W, H)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(36)
    love.graphics.printf("PAUSED", 0, H/2 - 40, W, "center")
  end

  if not alive then
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, W, H)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(36)
    love.graphics.printf("GAME OVER", 0, H/2 - 60, W, "center")
    love.graphics.setNewFont(18)
    love.graphics.printf("Press R to restart or Esc to menu", 0, H/2, W, "center")
  end
end

function M.keypressed(key)
  if key == "escape" then
    -- save best
    love.filesystem.write("snake_best.txt", tostring(best))
    SceneManager.switch("menu")
    return
  end

  if key == "r" then
    resetGame()
    return
  end

  if key == "space" then
    paused = not paused
    return
  end

  if not alive then return end

  -- movement
  if key == "up" or key == "w" then setDir(0, -1) end
  if key == "down" or key == "s" then setDir(0,  1) end
  if key == "left" or key == "a" then setDir(-1, 0) end
  if key == "right" or key == "d" then setDir(1,  0) end
end

return M
