local M = {}

function M.clamp(v, a, b)
  if v < a then return a end
  if v > b then return b end
  return v
end

function M.round(v)
  return math.floor(v + 0.5)
end

return M
