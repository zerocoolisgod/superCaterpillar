-------------------------------------------------------------------------------
-- Bird Factory
--
-- Moves back and forth, Eats caterpiller


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
  local e = entitySystem:newEnt(x, y, 8, 8)
  local sheet = resourceManager:getImage("smallEntSheet")
  
  e:setId("bird")
  e:setGroup("bird")
  
  logicComponents:addCollision(e, false)
  renderComponents:addSprite(e, sheet, 8, 8, 1)

  function e:onBump(o)
    if o.group == "player" then end
  end

  return e
end
return ent