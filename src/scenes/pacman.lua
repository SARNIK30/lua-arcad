local SceneManager = require("src.scene_manager")
local M = {}

local CELL = 24
local map = {
  "####################",
  "#........##........#",
  "#.####...##...####.#",
  "#.................##",
  "#.####.######.####.#",
  "#......#....#......#",
  "######.#.##.#.######",
  "#......#....#......#",
  "#.####.######.####.#",
  "##.................#",
  "#.####...##...####.#",
  "#........##........#",
  "####################",
}

local w = #map[1]
local h = #map

local px, py = 2, 2
local dir = {x=0,y=0}
local score = 0
local dotsLeft = 0

local OFFSET_X, OFFSET_Y = 0, 0

local function calcOffsets()
  local W, H = love.graphics.getWidth(), love.graphics.getHeight()
  OFFSET_X = math.floor((W - w*CELL)/2)
  OFFSET_Y = math.floor((H - h*CELL)/2) + 30
end

local function isWall(x, y)
  if x < 1 or x > w or y < 1 or y > h then return true end
  return map[y]:sub(x,x) == "#"
end

local function reset()
  px, py = 2, 2
  dir.x, dir.y = 0, 0
  score = 0
  dotsLeft = 0

  -- Count dots
  for y = 1, h do
    for x = 1, w do
      if map[y]:sub(x,x) == "." then dotsLeft = dotsLeft + 1 end
    end
  end
  calcOffsets()
end

local function eatDot()
  if map[py]:sub(px,px) == "." then
    map[py] = map[py]:sub(1, px-1) .. " " .. map[py]:sub(px+1)
    score = score + 10
    dotsLeft = dotsLeft - 1
  end
end

function M.enter()
  -- важно: при каждом входе восстанавливаем карту (чтобы точки вернулись)
  map = {
    "####################",
    "#........##........#",
    "#.####...##...####.#",
    "#.................##",
    "#.####.######.####.#",
    "#......#....#......#",
    "######.#.##.#.######",
    "#......#....#......#",
    "#.####.######.####.#",
    "##.................#",
    "#.####...##...####.#",
    "#........##........#",
    "####################",
  }
  reset()
  eatDot()
end

function M.resize()
  calcOffsets()
end

function M.update(dt)
  -- grid-step movement with small delay
  M._t = (M._t or 0) + dt
  if M._t < 0.10 then return end
  M._t = 0

  if dir.x == 0 and dir.y == 0 then return end

  local nx, ny = px + dir.x, py + dir.y
  if not isWall(nx, ny) then
    px, py = nx, ny
    eatDot()
  end
end

function M.draw()
  love.graphics.clear(0.05, 0.06, 0.09)
  local W, Hs = love.graphics.getWidth(), love.graphics.getHeight()

  love.graphics.setColor(0.2, 0.9, 1.0)
  love.graphics.setNewFont(36)
  love.graphics.printf("PAC-MAN (Prototype)", 0, 24, W, "center")

  love.graphics.setNewFont(18)
  love.graphics.setColor(0.8, 0.9, 1.0)
  love.graphics.printf("Score: "..score.."   Dots left: "..dotsLeft.."   R Restart • Esc Menu", 0, 72, W, "center")

  for y = 1, h do
    for x = 1, w do
      local ch = map[y]:sub(x,x)
      local pxs = OFFSET_X + (x-1)*CELL
      local pys = OFFSET_Y + (y-1)*CELL

      if ch == "#" then
        love.graphics.setColor(0.12, 0.55, 0.90)
        love.graphics.rectangle("fill", pxs, pys, CELL, CELL, 6, 6)
      else
        love.graphics.setColor(0.06, 0.08, 0.12)
        love.graphics.rectangle("fill", pxs, pys, CELL, CELL)
        if ch == "." then
          love.graphics.setColor(1, 0.95, 0.5)
          love.graphics.circle("fill", pxs + CELL/2, pys + CELL/2, 3)
        end
      end
    end
  end

  -- player
  local ppx = OFFSET_X + (px-1)*CELL + CELL/2
  local ppy = OFFSET_Y + (py-1)*CELL + CELL/2
  love.graphics.setColor(1, 0.95, 0.2)
  love.graphics.circle("fill", ppx, ppy, CELL*0.40)
end

function M.keypressed(key)
  if key == "escape" then
    SceneManager.switch("menu")
    return
  end
  if key == "r" then
    M.enter()
    return
  end

  if key == "up" or key == "w" then dir.x, dir.y = 0, -1 end
  if key == "down" or key == "s" then dir.x, dir.y = 0,  1 end
  if key == "left" or key == "a" then dir.x, dir.y = -1, 0 end
  if key == "right" or key == "d" then dir.x, dir.y = 1,  0 end
end

return M
