local class = require "lib.class"

local button = class()

function button:init(text, x, y, width, height, clr, fnt, animated)
    self.text, self.x, self.y, self.width, self.height, self.color, self.font = text, x, y, width, height, clr or color[1], fnt or font.huger
    self.fn = false
    self.hidden = false
    self.scale = 0
    self.animated = animated or false

    -- flux.to(self, config.window.animationScale * 2, {scale = 1}):ease("circout")

    return self
end

function button:show()
    flux.to(self, config.window.animationScale * 2, {scale = 1}):ease("circout")
    self.hidden = false
end

function button:hide()
    flux.to(self, config.window.animationScale * 2, {scale = 0}):ease("circout")
    self.hidden = true
end

function button:centerHorizontal()
    self.x = (lg.getWidth() / 2) - (self.width / 2)

    return self
end

function button:setFunction(fn)
    self.fn = fn

    return self
end

function button:mousepressed(x, y, k)
    if self.scale == 1 then
        if maf.pointInRect(x, y, self.x, self.y, self.width, self.height) then
            sound.tick:play()
            if self.fn then
                self.fn(self)
                if self.animated then
                    flux.to(self, config.window.animationScale, {scale = 0.8}):ease("backout"):oncomplete(function()
                        flux.to(self, config.window.animationScale * 5, {scale = 1}):ease("elasticout")
                    end)
                end
            end
        end
    end
end

function button:draw()
    local width, height = self.width * self.scale, self.height * self.scale

    -- Shadow
    lg.setColor(0, 0, 0, config.window.shadowAlpha)
    lg.rectangle("fill", 
        self.x + (self.width / 2) - (width / 2), 
        self.y + (self.height / 2) / height, width, height + (height * 0.1), height * 0.1, height * 0.1)
        -- self.x + (self.board.cellWidth / 2) - (width / 2),

    -- Base
    lg.setColor(self.color)
    lg.rectangle("fill", 
        self.x + (self.width / 2) - (width / 2), 
        self.y + (self.height / 2) / height, width, height, height * 0.1, height * 0.1)

    lg.setColor(color[19])
    lg.rectangle("line", 
        self.x + (self.width / 2) - (width / 2), 
        self.y + (self.height / 2) / height, width, height, height * 0.1, height * 0.1)

    -- Text
    lg.setFont(self.font)
    local textHeight = lg.getFont():getAscent() - lg.getFont():getDescent()

    lg.setColor(0, 0, 0, config.window.shadowAlpha * self.scale)
    lg.printf(self.text, self.x, self.y + (height / 2) - (textHeight / 2) + (textHeight * 0.08), self.width, "center")

    lg.setColor(color[19][1], color[19][2], color[19][3], self.scale)
    lg.printf(self.text, self.x, self.y + (height / 2) - (textHeight / 2), self.width, "center")
end

return button