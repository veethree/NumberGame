local class = require "lib.class"

local background = class()

function background:init(x, y, width, height)
    self.x, self.y, self.width, self.height = x or 0, y or 0, width or lg.getWidth(), height or lg.getHeight()
    self.count = 32
    self.particle = {}

    for i=1, self.count do
        self.particle[i] = Particle(random(lg.getWidth()), random(lg.getHeight()), self.x, self.y, self.width, self.height)
    end
end

function background:forceColorUpdate()
    for _,particle in ipairs(self.particle) do
        particle:randomColor()
    end
end

function background:update(dt)
    for _, particle in ipairs(self.particle) do
        particle:update(dt)
    end
end

function background:draw()
    if config.window.background then
        for _, particle in ipairs(self.particle) do
            particle:draw()
        end

        local r, g, b = lg.getBackgroundColor()
        lg.setColor(r, g, b, 0.8)
        lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
    end
end

return background