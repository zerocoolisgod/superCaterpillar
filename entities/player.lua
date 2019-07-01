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
  local e = entitySystem:newEnt(x, y, 6, 14)
  local sheet = resourceManager:getImage("beth_blue_strip")

  e:setId("player")
  e:setGroup("player")
  
  logicComponents:addInputs(e)
  logicComponents:addMovement(e)
  logicComponents:addCollision(e, true)

  renderComponents:addSprite(e, sheet, 16, 16)
  e:setSpriteOffset(0,-1)
  logicComponents:addAnimation(e, "idle", {1}, 999)
  logicComponents:addAnimation(e, "walk", {3, 1, 2, 1}, 0.6)
  logicComponents:addAnimation(e, "jump", {4}, 0.2)
  logicComponents:addAnimation(e, "fall", {5}, 0.2)
  logicComponents:addAnimation(e, "duck", {8}, 0.2)
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
      if self:inputIsDown("left") then nstate = 'walk' end
      if self:inputIsDown("right") then nstate = 'walk' end
      if self:inputIsDown("down") then nstate = 'duck' end
      if self:inputIsPressed("btnB") then nstate = 'jump' end
      if not self:checkWall(0, 1) then nstate = 'fall' end
      if nstate then self:setState(nstate) end
      
      local spdX, spdY = 0, 90
      local accelX, accelY = 0.09, 0.02
      self:move(spdX, spdY, accelX, accelY, dt)
    end)
  

  -------------------------------------
  -- Walk
  -------------------------------------
  logicComponents:addState(e,'walk',
    function(self)
      self:setAnimation('walk')
    end,

    function(self, dt)
      -- Movement
      local spdX, spdY = 90, 90
      local accelX, accelY = 0.09, 0.02
      local dirX, dirY = 0, 1
      if self:inputIsDown("left") then dirX = -1 end
      if self:inputIsDown("right") then dirX = 1 end
      spdX = spdX * dirX
      spdY = spdY * dirY

      self:move(spdX, spdY, accelX, accelY, dt)

      -- Sprite Facing
      if dirX ~= 0 then self:setSpriteScale(dirX, 1) end

      -- Exit State
      local nstate
      if dirX == 0 then nstate = 'idle' end
      if self:inputIsDown("down") then nstate = 'duck' end
      if self:inputIsPressed("btnB") then nstate = 'jump' end
      if not self:checkWall(0, 1) then nstate = 'fall' end
      if nstate then self:setState(nstate) end
    end)
  
  
  -------------------------------------
  -- Jump
  -------------------------------------
  logicComponents:addState(e,'jump',
    function(self)
      self:setAnimation('jump')
      self.vel.y = -400 --360
    end,

    function(self, dt)
      -- Movement
      local spdX, spdY = 120, 300
      local accelX, accelY = 0.050, 0.009
      local dirX, dirY = 0, 1
      if self:inputIsDown("left") then dirX = -1 end
      if self:inputIsDown("right") then dirX = 1 end
      spdX = spdX * dirX
      spdY = spdY * dirY
      self:move(spdX, spdY, accelX, accelY, dt)
      
      --Sprite Facing
      if dirX ~= 0 then self:setSpriteScale(dirX, 1) end

      -- Exit State
      local nstate
      if self.vel.y >= 0 then nstate = 'fall' end
      if self:checkWall(0,-1) then nstate = 'fall' end
      if self:inputIsReleased('btnB') then nstate = 'fall' end
      if nstate then self:setState(nstate) end
    end)
  

  -------------------------------------
  -- Fall
  -------------------------------------
  logicComponents:addState(e,'fall',
    function(self)
      self.vel.y = self.vel.y/2
    end,

    function(self, dt)
      if self.vel.y >= 0 then self:setAnimation('fall') end
      -- Movement
      local spdX, spdY = 90,300
      local accelX, accelY = 0.020, 0.009
      local dirX, dirY = 0, 1
      if self:inputIsDown("left") then dirX = -1 end
      if self:inputIsDown("right") then dirX = 1 end
      spdX = spdX * dirX
      spdY = spdY * dirY

      self:move(spdX, spdY, accelX, accelY, dt)
      
      -- Exit State
      local nstate
      if self:checkWall(0,1) then nstate = 'idle' end
      if nstate then self:setState(nstate) end
    end)
  
  
  -------------------------------------
  -- Duck
  -- -------------------------------------
  logicComponents:addState(e,'duck',
    function(self)
      self:setAnimation('duck')
    end,

    function(self, dt)
      -- Exit State
      local nstate
      if not self:inputIsDown("down") then nstate = 'idle' end
      if not self:checkWall(0, 1) then nstate = 'fall' end
      if nstate then self:setState(nstate) end
      
      local spdX, spdY = 0, 90
      local accelX, accelY = 0.09, 0.02
      self:move(spdX, spdY, accelX, accelY, dt)
    end)
  
  
  -----------------------------------------------------------------------------
  -- Utility Methods
  -----------------------------------------------------------------------------
  function e:checkWall(dx,dy)
    local x,y,w,h,et,other,wall
    x = self.pos.x + dx
    y = self.pos.y + dy
    w = self.size.w
    h = self.size.h
    et = entitySystem:getEnts()
    
    other = collisionSystem:getEntityInRect(self,x,y,w,h,et)
    if other then 
      if other.group == "wall" then wall = true end
    end
    
    return wall
  end

  e:setState('idle')
  return e
end

return ent