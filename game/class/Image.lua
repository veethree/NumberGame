local class = require "lib.class"

local image = class()

function image:init(image, x, y, scale)
    self.image, self.x, self.y, self.scale = image, x, y, scale or 1
    self.width = image:getWidth() * scale
    self.height = image:getHeight() * scale
    self.flash = Flash(self.x, self.y, SAFE.width)

    return self
end

function image:centerHorizontal()
    self.x = (SAFE.width / 2) - (self.width / 2)
    return self
end

function image:draw()
    lg.setColor(1, 1, 1, 1)
    lg.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
    self.flash:draw()
end

return image