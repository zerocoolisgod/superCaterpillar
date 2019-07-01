-------------------------------------------------------------------------------
-- Game Data Object
---------------------------------------
-- The majority of Game spacific Global Variables.
-- The only table needed to ba saved and loaded for save/load functionality.
-----------------------------
-- Localized Globals
local gstMan = GSTMAN
local entSys = ENTSYS
local colSys = COLSYS
local camera = CAMERA
local resMan = RESMAN


local g = {}
g.worldPos = {x = 1,y = 1,z = 1}
g.nextWorldPos = {x = 1,y = 1,z = 1}


function g:getWorldPosition( )
  return self.worldPos.x, self.worldPos.y, self.worldPos.z
end


function g:getNextWorldPosition( )
  return self.nextWorldPos.x, self.nextWorldPos.y, self.nextWorldPos.z
end


function g:setWorldPosition(x,y,z)
  self.worldPos.x = x
  self.worldPos.y = y
  self.worldPos.z = z
end


function g:setNextWorldPosition(x,y,z)
  self.nextWorldPos.x = x
  self.nextWorldPos.y = y
  self.nextWorldPos.z = z
end

return g