-------------------------------------------------------------------------------
-- Render Components

local renSys = {}


---------------------------------------
-- Local Utility functions and framework variables
local lgDraw = love.graphics.draw
local lgSetColor = love.graphics.setColor
local lgRect = love.graphics.rectangle


local function cutQuads (img, width, height, buffer, margin)
  -- Cut quads
  local t_insert = table.insert
  local frame_width = width
  local frame_height = height
  local b = buffer or 0
  local m = margin or 0
  local image_width = img:getWidth()
  local image_height = img:getHeight()
  
  local q_table = {}

  -- Position in image is based on cells,
  -- frame size is the size of the tile or spriteframe.
  -- If we are using a buffered sprite sheet then the cell
  -- will be the size of the frame + 2 buffer on all 4 sides,
  -- or cx=fx+b*2 cy=fy+b*2
  local cell_w = frame_width + b
  local cell_h = frame_height + b

  local number_wide = image_width / cell_w
  local number_high = image_height / cell_h

  -- Cut tile sheet into quads
  for y = 1, number_high do
    for x = 1, number_wide do
      -- add buffer to whole thing to get the first position off
      -- of the 0x and 0y
      local xpos = ((x-1) * (cell_w)) + m
      local ypos = ((y-1) * (cell_w)) + m
      table.insert(q_table, love.graphics.newQuad(xpos, ypos, frame_width, frame_height, image_width, image_height))
    end
  end
  return q_table
end


-------------------------------------------------------------------------------
-- Components
function renSys:addOnDraw(ent,f)
	-- Generic function to run every draw
	ent:addRenSys(f)
end


function renSys:addRectangle(ent, c)
	ent.color = c or {1,0.5,1}
	
	function ent:setColor(c)
		ent.color = c
	end
	
	ent:addRenSys(function(e)
		lgSetColor(e.color)
		lgRect("fill", e.pos.x, e.pos.y, e.size.w, e.size.h)
    lgSetColor(1,1,1)
	end)
end


function renSys:addSprite(ent, sheet, width, height, quad)
  if not RESMAN then 
    love.errhand("RESMAN needs to be globally accessable!")
    love.event.quit()
  end

	ent.sheet = sheet
  ent.frame = quad or 1
  ent.quads = RESMAN:getQuads(sheet, width, height)
	ent.scale = {x = 1, y = 1}
	ent.radian = 0
  ent.orig = {x = width/2, y = height/2}
	ent.offset = {x = 0, y = 0}
    
  function ent:setSpriteScale(x, y)
		self.scale.x = x or 1
    self.scale.y = y or x or 1
	end
	
  
	function ent:setSpriteAlpha(c)
		self.colorkey = c or 0
	end
	
  
	function ent:setSpriteRadian(r)
		self.radian = r or 0
	end
  
  
  function ent:setSpriteOffset(x,y)
		self.offset.x = x or 0
    self.offset.y = y or x or 0
	end

  
  function ent:setFrame(f)
    if f > #self.quads then f = 1 end
    self.frame = f or 1
  end
		
	ent:addRenSys(function(e)
		-- drawable (quad) x y radian scaleX scaleY originX originY
    local q = e.quads[e.frame]
    local x = e.pos.x + e.size.w/2 + e.offset.x
    local y = e.pos.y + e.size.h/2 + e.offset.y
		lgDraw(e.sheet, q, x, y, e.radian, e.scale.x, e.scale.y, e.orig.x, e.orig.y)
	end)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Need a map renering component that uses spriteBatch, need to make sure
-- all my sprite sheets are buffered.


return renSys