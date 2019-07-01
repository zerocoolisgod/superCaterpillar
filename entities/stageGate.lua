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
  e:setId("Stage Gate")
  e:setGroup("stageGate")
  e.gateTo = props
  logicComponents:addCollision(e, true)
  renderComponents:addRectangle(e,{0.5, 0.10, 0.5})
  
  function e:onBump(o)
    local x,y,z = self.gateTo.x, self.gateTo.y, self.gateTo.z
    gameData:setNextWorldPosition(x,y,z)
    gameStateManager:setState('loadStage')
  end

  return e
end

return ent