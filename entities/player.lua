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
  logicComponents:addAnimation(e, "idleHorz", {1}, 99)
  logicComponents:addAnimation(e, "idleVert", {4}, 99)
  logicComponents:addAnimation(e, "walkHorz", {1, 2, 3, 2}, 0.6)
  logicComponents:addAnimation(e, "walkVert", {4, 5, 6, 5}, 0.6)

  e:setAnimation("idleHorz")
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
      local pAnm = self:getAnimation()
      local nAnm = 'idleHorz'
      if pAnm == "walkVert" then nAnm = "idleVert" end
      self:setAnimation(nAnm)
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
      local fx, fy = self:getSpriteScale()
      local nAnm = self:getAnimation()
      if dirX ~= 0 then fx, nAnm = dirX, 'walkHorz' end
      if dirY ~= 0 then fy, nAnm = dirY, 'walkVert' end
      if nAnm == 'walkHorz' then fy = 1 end
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