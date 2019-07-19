-------------------------------------------------------------------------------
-- Fruit Factory
--
-- To Be Eaten


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
  local e = ENTSYS:newEnt(x, y, 8, 8)
  local sheet = resourceManager:getImage("foodSheet")
  
  e:setId("fruit")
  e:setGroup("fruit")
  
  logicComponents:addCollision(e, false)
  renderComponents:addSprite(e, sheet, 8, 8, props.fruitType)

  function e:onBump(o)
    if o.group == "player" then 
      local fCount = gameData:getData("levelFruit") or 1
      fCount = fCount - 1
      gameData:setData("levelFruit", fCount)
      self.collidable = false
      self.remove = true
    end
  end

  return e
end
return ent