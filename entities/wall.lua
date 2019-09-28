-------------------------------------------------------------------------------
-- Solid Wall Factory
-------------------------------------------------------------------------------
local logicComponents = require("bge.logicComponents")
local renderComponents = require("bge.renderComponents")

local ent = {}

function ent:new(x,y,w,h,props)
  local e = ENTSYS:newEnt(x, y, w, h)
  e:setId("wall")
  e:setGroup("wall")
  logicComponents:addCollision(e, true)
  return e
end

return ent