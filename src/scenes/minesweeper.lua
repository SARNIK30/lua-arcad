local SceneManager = require("src.scene_manager")
local M = {}

local CELL = 28
local cols, rows = 16, 16
local minesCount = 40

local grid = {}
local firstClick = true
local gameOver = false
local win = false
local revealed = 0

local OFFSET_X, OFFSET_Y = 0, 0

local function inBounds(x, y)
  return x >= 1 and x <= cols and y >= 1 and y <= rows
end

local function neighbors(x, y)
  local t = {}
  for dy = -1, 1 do
    for dx = -1, 1 do
      if not (dx == 0 and dy == 0) then
        local nx, ny = x + dx, y + dy
        if inBounds(nx, ny) then table.insert(t, {nx, ny}) end
      end
    end
  end
  return t
end

local function calcOffsets()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local boardW = cols * CELL
  local boardH = rows * CELL
  OFFSET_X = math.floor((w - boardW) / 2)
  OFFSET_Y = math.floor((h - boardH) / 2) + 30
end

local function reset()
  grid = {}
  for y = 1, rows do
    grid[y] = {}
    for x = 1, cols do
      grid[y][x] = { mine = false, n = 0, open = false, flag = false }
    end
  end
  firstClick = true
  gameOver = false
  win = false
  revealed = 0
  calcOffsets()
end

local function placeMines(safeX, safeY)
  local placed = 0
  while placed < minesCount do
    local x = love.math.random(1, cols)
    local y = love.math.random(1, rows)

    local tooClose = false
    for _, nb in ipairs(neighbors(safeX, safeY)) do
      if nb[1] == x and nb[2] == y then tooClose = true end
    end
    if x == safeX and y == safeY then tooClose = true end

    if not tooClose and not grid[y][x].mine then
      grid[y][x].mine = true
      placed = placed + 1
    end
  end

  for y = 1, rows do
    for x = 1, cols do
      local c = grid[y][x]
      if not c.mine then
        local count = 0
        for _, nb in ipairs(neighbors(x, y)) do
          local nx, ny = nb[1], nb[2]
          if grid[ny][nx].mine then count = count + 1 end
        end
        c.n = count
      end
    end
  end
end

local function floodOpen(x, y)
  local stack = {{x, y}}
  while #stack > 0 do
    local cur = table.remove(stack)
    local cx, cy = cur[1], cur[2]
    local cell = grid[cy][cx]
    if cell.open or cell.flag then goto continue end

    cell.open = true
    revealed = revealed + 1

    if cell.n == 0 then
      for _, nb in ipairs(neighbors(cx, cy)) do
        local nx, ny = nb[1], nb[2]
        local ncell = grid[ny][nx]
        if not ncell.open and not ncell.flag and not ncell.mine then
          table.insert(stack, {nx, ny})
        end
      end
    end

    ::continue::
  end
end

local function checkWin()
  local totalSafe = cols * rows - minesCount
  if revealed >= totalSafe and not gameOver then
    win = true
  end
end

local function toCell(mx, my)
  local x = math.floor((mx - OFFSET_X) / CELL) + 1
  local y = math.floor((my - OFFSET_Y) / CELL) + 1
  if not inBounds(x, y) then return nil end
  return x, y
end

function M.enter()
  reset()
end

function M.resize()
  calcOffsets()
end

function M.draw()
  love.graphics.clear(0.05, 0.06, 0.09)
  local W, H = love.graphics.getWidth(), love.graphics.getHeight()

  love.graphics.setColor(0.2, 0.9, 1.0)
  love.graphics.setNewFont(36)
  love.graphics.printf("MINESWEEPER", 0, 24, W, "center")

  love.graphics.setNewFont(16)
  love.graphics.setColor(0.75, 0.85, 1.0)
  love.graphics.printf("LMB Open • RMB Flag • R Restart • Esc Menu", 0, H - 40, W, "center")

  -- board bg
  love.graphics.setColor(0.08, 0.10, 0.16)
  love.graphics.rectangle("fill", OFFSET_X - 10, OFFSET_Y - 10, cols*CELL + 20, rows*CELL + 20, 18, 18)
  love.graphics.setColor(0.2, 0.9, 1.0)
  love.graphics.rectangle("line", OFFSET_X - 10, OFFSET_Y - 10, cols*CELL + 20, rows*CELL + 20, 18, 18)

  for y = 1, rows do
    for x = 1, cols do
      local c = grid[y][x]
      local px = OFFSET_X + (x-1)*CELL
      local py = OFFSET_Y + (y-1)*CELL

      if c.open then
        love.graphics.setColor(0.12, 0.16, 0.22)
        love.graphics.rectangle("fill", px+1, py+1, CELL-2, CELL-2, 6, 6)

        if c.mine then
          love.graphics.setColor(1.0, 0.35, 0.4)
          love.graphics.circle("fill", px + CELL/2, py + CELL/2, CELL*0.25)
        elseif c.n > 0 then
          love.graphics.setColor(0.9, 0.95, 1.0)
          love.graphics.print(tostring(c.n), px + CELL*0.38, py + CELL*0.24)
        end
      else
        love.graphics.setColor(0.10, 0.14, 0.20)
        love.graphics.rectangle("fill", px+1, py+1, CELL-2, CELL-2, 6, 6)
        love.graphics.setColor(0.2, 0.9, 1.0, 0.15)
        love.graphics.rectangle("line", px+1, py+1, CELL-2, CELL-2, 6, 6)

        if c.flag then
          love.graphics.setColor(0.2, 0.9, 1.0)
          love.graphics.polygon("fill",
            px + CELL*0.30, py + CELL*0.72,
            px + CELL*0.30, py + CELL*0.25,
            px + CELL*0.75, py + CELL*0.40
          )
          love.graphics.setColor(0.85, 0.9, 1.0)
          love.graphics.rectangle("fill", px + CELL*0.28, py + CELL*0.22, 3, CELL*0.55)
        end
      end
    end
  end

  if gameOver then
    love.graphics.setColor(0,0,0,0.65)
    love.graphics.rectangle("fill", 0, 0, W, H)
    love.graphics.setColor(1,1,1)
    love.graphics.setNewFont(34)
    love.graphics.printf("BOOM!", 0, H/2 - 60, W, "center")
    love.graphics.setNewFont(18)
    love.graphics.printf("Press R to restart or Esc to menu", 0, H/2, W, "center")
  elseif win then
    love.graphics.setColor(0,0,0,0.55)
    love.graphics.rectangle("fill", 0, 0, W, H)
    love.graphics.setColor(1,1,1)
    love.graphics.setNewFont(34)
    love.graphics.printf("YOU WIN!", 0, H/2 - 60, W, "center")
    love.graphics.setNewFont(18)
    love.graphics.printf("Press R to restart or Esc to menu", 0, H/2, W, "center")
  end
end

function M.mousepressed(mx, my, button)
  if gameOver or win then return end
  local x, y = toCell(mx, my)
  if not x then return end
  local c = grid[y][x]

  if button == 2 then
    if not c.open then c.flag = not c.flag end
    return
  end

  if button ~= 1 then return end
  if c.flag or c.open then return end

  if firstClick then
    placeMines(x, y)
    firstClick = false
  end

  if c.mine then
    c.open = true
    gameOver = true
    return
  end

  floodOpen(x, y)
  checkWin()
end

function M.keypressed(key)
  if key == "escape" then
    SceneManager.switch("menu")
    return
  end
  if key == "r" then
    reset()
    return
  end
end

return M
