local class = require "lib.class"

local text = class()

function text:init(text, x, y, fnt, clr, alignment)
    self.text, self.x, self.y, self.font, self.color, self.alignment = text, x, y, fnt or font.large, clr or color[16], alignment or "center"

    self.padding = SAFE.width * 0.1
end

function text:setText(text)
    self.text = text
end

function text:move(x, y, time, after)
    after = after or function() end
    flux.to(self, time or config.window.animationScale, {x = x or self.x, y = y or self.y}):ease("expoout"):oncomplete(after)
end

function text:draw()
    lg.setFont(self.font)

    lg.setColor(0, 0, 0, config.window.shadowAlpha)
    lg.printf(self.text, self.x + self.padding, self.y + ((self.font:getAscent() - self.font:getDescent()) * 0.1), lg.getWidth() - (self.padding * 2), self.alignment)

    lg.setColor(self.color)
    lg.printf(self.text, self.x + self.padding, self.y, lg.getWidth() - (self.padding * 2), self.alignment)
end

return text