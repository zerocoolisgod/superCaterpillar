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
local logicComponents   = require("bge.logicComponents")
local renderComponents  = require("bge.renderComponents")
local rand              = love.math.random


local ent = {}
function ent:new(x, y, w, h, props)
  local e = ENTSYS:newEnt(x, y, 8, 8)
  local sheet = resourceManager:getImage("foodSheet")
  
  e:setId("fruit")
  e:setGroup("fruit")

  e.dirs = {
    {x =  0, y = -1}, -- North
    {x = -1, y = -1}, -- NorthEast
    {x =  1, y =  0}, --      East
    {x = -1, y =  1}, -- SouthEast
    {x =  0, y =  1}, -- South
    {x =  1, y =  1}, -- SouthWest
    {x = -1, y =  0}, --      West
    {x =  1, y = -1}, -- NorthWest
  }

  e.heading = 1
  
  renderComponents:addSprite(e, sheet, 8, 8, props.fruitType)

  logicComponents:addMovement(e)
  logicComponents:addCollision(e, true)

  function e:onBump(o)
    if o.group == "player" then 
      local fCount = gameData:getData("levelFruit") or 1
      fCount = fCount - 1
      gameData:setData("levelFruit", fCount)
      self.collidable = false
      self.remove = true
    else
      self:setState("changeDir")
    end
  end

  -----------------------------------------------------------------------------
  -- States
  -------------------------------------
  -- Change Direction
  -------------------------------------
  logicComponents:addState(e,'changeDir',
    function(self) --Init
      self.heading = rand(1, 8)
      self:setState("move")
    end,

    function(self, dt) --Update
      -- pass
    end)
  

  -------------------------------------
  -- Move
  -------------------------------------
  logicComponents:addState(e,'move',
    function(self) --Init
    end,

    function(self, dt) --Update
      -- Movement
      local spdX, spdY = 35, 35
      local accelX, accelY = 0.1, 0.1
      local dir = self.dirs[self.heading]
      
      spdX = spdX * dir.x
      spdY = spdY * dir.y

      self:move(spdX, spdY, accelX, accelY, dt)
    end)
  
  self:setState("changeDir")
  return e
end
return ent