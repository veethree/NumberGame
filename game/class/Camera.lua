local class = require "lib.class"
local Camera = class()

local function lerp(a, b, t)
	return a + (b - a) * t
end

-- Initialize
function Camera:init(x, y, scale, width, height)
    self.position = vec2()
    self.targetPosition = vec2()
    self.scale = vec2(1, 1)
    self.targetScale = vec2(1, 1)
    self.smoothing = 0.05
    self.size = vec2(width or lg.getWidth(), height or lg.getHeight())
end

-- Setters & Getters
function Camera:setSmoothing(s)
    self.smoothing = s
end

function Camera:setViewport(width, height)
    self.size:set(width, height)
end

function Camera:setScale(x, y)
    y = y or x
    self.targetScale:set(x, y)
    self.scale:set(x, y)
end

-- Updates the camera position and applies smoothing if enabled
function Camera:update(dt)
    if self.smoothing then
        self.position = lerp(self.position, self.targetPosition, 1 - math.pow(self.smoothing, dt))
        self.scale = lerp(self.scale, self.targetScale, 1 - math.pow(self.smoothing, dt))
    else
        self.position:set(self.targetPosition.x, self.targetPosition.y)
        self.scale:set(self.targetScale.x, self.targetScale.y)
    end
end

-- Moves the camera so x and y is at the center
function Camera:look(x, y, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    self.targetPosition:set(
        x - ((self.size.x / self.scale.x) / 2) + (offsetX / self.scale.x),
        y - ((self.size.y / self.scale.y) / 2) + (offsetY / self.scale.y))
end

-- Zoomz the camera by x / y
function Camera:zoom(x, y)
    y = y or x
    self.targetScale = self.targetScale + vec2(x, y)
end

-- Moves the camera by x and y
function Camera:move(x, y)
    self.targetPosition = self.targetPosition + vec2(x, y)
end

-- Moves the camera by x and y

-- Pushes the cameras transformation 
function Camera:push()
    lg.push()
    
    -- lg.translate((self.size.x / 2), (self.size.y / 2))
    lg.scale(self.scale.x, self.scale.y)
    -- lg.translate(-(self.size.x / 2), -(self.size.y / 2))
    lg.translate(-self.position.x, -self.position.y)
end

-- Pops the cameras transformation
function Camera:pop()
    lg.pop()
end


function Camera:getMouse()
    local mx, my = love.mouse.getPosition()    
    return self.position.x + mx / self.scale.x, self.position.y + my / self.scale.y
end

return Camera