-------------------------------------------------------------------------------
-- Gate Factory
--
-- Transitions between maps


-----------------------------
-- Localized Globals
local gameStateManager  = GSTMAN
local entitySystem      = ENTSYS
local collisionSystem   = COLSYS
local camera            = CAMERA
local resourceManager   = RESMAN
local gameData          = GAMDAT
local overWorld         = OVRWLD
local logicComponents = require("bge.logicComponents")
local renderComponents = require("bge.renderComponents")

local ent = {}
function ent:new(x, y, w, h, props)
  local e = ENTSYS:newEnt(x, y, w, h)
  local sheet = resourceManager:getImage("foodSheet")

  renderComponents:addSprite(e, sheet, 8, 8, props.fruitType)

  return e
end
return ent