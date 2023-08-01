local class = require "lib.class"

local Color = class()

function Color:init(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
end

function Color:apply()
    lg.setColor(self.r, self.g, self.b, self.a)
end

function Color:invert()
    self.r = 1 - self.r
    self.g = 1 - self.g
    self.b = 1 - self.b
end

return Color