-- Player factory
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

function ent:new(x,y)
  local e = entitySystem:newEnt(x, y, 6, 6)
  local sheet = resourceManager:getImage("playerSheet")

  e:setId("player")
  e:setGroup("player")
  
  logicComponents:addInputs(e)
  logicComponents:addMovement(e)
  logicComponents:addCollision(e, true)

  renderComponents:addSprite(e, sheet, 8, 8)
  e:setSpriteOffset(0, -1)
  logicComponents:addAnimation(e, "idle", {1}, 999)
  logicComponents:addAnimation(e, "walkHorz", {1, 2, 3, 2}, 0.6)
  logicComponents:addAnimation(e, "walkVert", {4, 5, 6, 5}, 0.6)

  e:setAnimation("idle")
  camera:setFocus(e)
  logicComponents:addOnUpdate(e, function(self, dt)
    
  end)

  -----------------------------------------------------------------------------
  -- States
  -------------------------------------
  -- Idle
  -------------------------------------
  logicComponents:addState(e,'idle',
    function(self)
      self:setAnimation('idle')
    end,

    function(self, dt)
      -- Exit State
      local nstate
      if self:inputIsDown("up") then nstate = 'walk' end
      if self:inputIsDown("down") then nstate = 'walk' end
      if self:inputIsDown("left") then nstate = 'walk' end
      if self:inputIsDown("right") then nstate = 'walk' end
      if nstate then self:setState(nstate) end
      
      local spdX, spdY = 0, 0
      local accelX, accelY = 0.1, 0.1
      self:move(spdX, spdY, accelX, accelY, dt)
    end)
  

  -------------------------------------
  -- Walk
  -------------------------------------
  logicComponents:addState(e,'walk',
    function(self)
      self:setAnimation('walkHorz')
    end,

    function(self, dt)
      -- Movement
      local spdX, spdY = 50, 50
      local accelX, accelY = 0.1, 0.1
      local dirX, dirY = 0, 0
      if self:inputIsDown("up") then dirY = -1 end
      if self:inputIsDown("down") then dirY = 1 end
      if self:inputIsDown("left") then dirX = -1 end
      if self:inputIsDown("right") then dirX = 1 end
      spdX = spdX * dirX
      spdY = spdY * dirY

      self:move(spdX, spdY, accelX, accelY, dt)

      -- Sprite Facing and animation
      local fx, fy, nAnm = 1, 1, 'walkHorz'
      if dirX ~= 0 then fx, fy, nAnm = dirX, 1, 'walkHorz' end
      if dirY ~= 0 then fx, fy, nAnm = 1, dirY, 'walkVert' end
      self:setSpriteScale(fx, fy)
      self:setAnimation(nAnm)
      

      -- Exit State
      local nstate
      if dirX == 0 and dirY == 0 then nstate = 'idle' end

      if nstate then self:setState(nstate) end
    end)

  e:setState('idle')
  return e
end

return ent