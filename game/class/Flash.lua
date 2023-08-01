local class = require "lib.class"

local flash = class()

function flash:init(x, y, radius, speed, clr)
    self.x, self.y, self.radius, self.speed, self.color = x, y, radius or SAFE.width * 0.2, speed or 1, clr or 17

    self.anim = 0
    self.alpha = 0
end

function flash:play()
    flux.to(self, config.window.animationScale * self.speed, {anim = 1}):ease("quadout")

    flux.to(self, config.window.animationScale * self.speed / 2, {alpha = 1}):ease("quadin"):oncomplete(function()
            flux.to(self, config.window.animationScale * self.speed / 2, {alpha = 0}):ease("quadin")
    end)
end

function flash:update(dt)

end

function flash:draw()
    lg.setBlendMode("add")
    local clr = color[util.offsetColorIndex(self.color)]

    lg.setColor(clr[1], clr[2], clr[3], self.alpha * 0.4)
    lg.circle("fill", self.x, self.y, self.radius * self.anim)
    lg.setBlendMode("alpha")
end

return flash