
---------------------------------------
-- Logic Componants

-----------------------------
-- Localized Globals
local gameStateManager  = GSTMAN
local entitySystem      = ENTSYS
local collisionSystem   = COLSYS
local camera            = CAMERA
local resourceManager   = RESMAN
local gameData          = GAMDAT
local overWorld         = OVRWLD

local logSys = {}

function logSys:addOnUpdate(ent, f)
	-- Generic function to run every update
	ent:addLogSys(f)
end


function logSys:addInputs(ent)
  ent.inputs = {
    up    = {key = "w", held = false, pressed = false, released = false},
    down  = {key = "s", held = false, pressed = false, released = false},
    left  = {key = "a", held = false, pressed = false, released = false},
    right = {key = "d", held = false, pressed = false, released = false},
    btnA  = {key = "l", held = false, pressed = false, released = false},
    btnB  = {key = "k", held = false, pressed = false, released = false},
    btnX  = {key = "o", held = false, pressed = false, released = false},
    btnY  = {key = "i", held = false, pressed = false, released = false},
  }
  
  
  function ent:setInput(inputs, key)
    self.inputs[id].key = key
  end
  
  
  function ent:inputIsDown(ip)
    return self.inputs[ip]["held"]
  end
  
  
  function ent:inputIsPressed(ip)
    return self.inputs[ip]["pressed"]
  end
  
  
  function ent:inputIsReleased(ip)
    return self.inputs[ip]["released"]
  end  
  
  
	ent:addLogSys(function(self, dt)
    for k,v in pairs(self.inputs) do
      local nowState = love.keyboard.isDown(self.inputs[k].key)
      local held = self.inputs[k].held
      self.inputs[k].pressed = nowState and not held
      self.inputs[k].released = held and not nowState
      self.inputs[k].held = nowState
    end
    
	end)
end


function logSys:addAnimation(ent, aId, frms, dly)
	if not ent.anms then ent.anms={} end
	ent.anms[aId] = {
		frames = frms,
		delay = dly,
		len = #frms
	}
	
	ent.anmTimer=0
	ent.frameNum = 1
	ent.cAnm = aId
	ent.nAnm = aId
	

	-------------------------------------
	-- Setters
	ent.setAnimation = function(self,a)
		self.nAnm = a
	end


	-------------------------------------
	-- Getters
	ent.getAnimation = function(self,a)
		return self.cAnm
	end
	
	-------------------------------------
	--Update Function
	ent:addLogSys(function(self, dt)
		local anm
		local sprt
		
		if self.cAnm ~= self.nAnm then
			self.cAnm = self.nAnm
			self.frameNum = 1
		end
		
		anm = self.anms[self.cAnm]
		
		self.anmTimer = self.anmTimer + dt
		if self.anmTimer > anm.delay then
			self.anmTimer = 0
			self.frameNum = self.frameNum + 1
    end
		
		if self.frameNum > anm.len then self.frameNum = 1 end
		
    self:setFrame(anm.frames[self.frameNum])
	end)
end


function logSys:addCollision(ent, solid)
	-- Solid objects repell objects 
	-- attempting to move into their 
	-- space. non solids do not, they 
	-- still get onBump() response.
	ent.collidable = true
	ent.solid = solid
	
	function ent:setSolid(b)
		self.solid = b
	end

	function ent:onBump (self, other) end
end


function logSys:addMovement(ent)
  if not COLSYS then 
    love.errhand("COLSYS needs to be globally accessable!")
    love.event.quit()
  end
  
  if not ENTSYS then 
    love.errhand("ENTSYS needs to be globally accessable!")
    love.event.quit()
  end
   
	-- spdX = spdX or 100
	-- spdY = spdY or 100
	ent._framAcum = 0
	ent.vel = {x = 0, y = 0}
	ent.dir = {x = 1, y = 0}
	


	function ent:move(tgtSpdX, tgtSpdY, accelX, accelY, dt)
		-- Takes target_speed, a rate of acceleration and delta time
		-- a linear interpolation between the current velocity and the target
		-- velocity by an acceleration percentage accel of 1 changes immediately,
		-- 0 is never, .5 half's the difference each tick.
		
		local tfps = (1/60)
		self._framAcum = self._framAcum + dt
		-- normalize the time step. With a fluxuating dt
		-- accels get wierd.
		if self._framAcum >= tfps then
			self._framAcum = self._framAcum - tfps
			local curSpeedX = self.vel.x
			local curSpeedY = self.vel.y
			local threshold = 1   -- Lower to make more 'floaty'
	
			curSpeedX = accelX * tgtSpdX + (1 - accelX) * curSpeedX
			curSpeedY = accelY * tgtSpdY + (1 - accelY) * curSpeedY
			if (math.abs(curSpeedX)) < threshold then
				curSpeedX = 0
			end
	
			if (math.abs(curSpeedY)) < threshold then
				curSpeedY = 0
			end
	
			self.vel.x = curSpeedX
			self.vel.y = curSpeedY
		end
	end

	
	ent:addLogSys(function(self, dt)
		local px, py
		
		self.pos.x = self.pos.x + (self.vel.x * dt)
		if self.collidable then 
			px = COLSYS:ckCollison(self, ENTSYS:getEnts())
		end
		if px then self.pos.x = px.x end	
	
    self.pos.y = self.pos.y + (self.vel.y * dt)
		if self.collidable then 
			py = COLSYS:ckCollison(self, ENTSYS:getEnts())
		end
		if py then self.pos.y = py.y end

	end)
end


function logSys:addState(ent, id, init, state)
	if not ent.stateInits then ent.stateInits={} end
	ent.stateInits[id] = init

	if not ent.states then ent.states={} end
	ent.states[id] = state
	
	ent.cState = id -- Current State
	ent.nState = id -- Next State
		
	ent.setState = function(self,s)
		self.nState = s
	end
	
	ent:addLogSys(function(e, dt)
		-- Check for state change, run initial
		if e.cState ~= e.nState then
			e.cState = e.nState
			e.stateInits[e.cState](e) 
		end
		
		e.states[e.cState](e, dt)
	end)	
end


return logSys                     