local class = require "lib.class"

local particle = class()

function particle:init(x, y, worldX, worldY, worldWidth, worldHeight)
    self.worldX, self.worldY, self.worldWidth, self.worldHeight = worldX, worldY, worldWidth, worldHeight
    self.position = vec2(x, y)
    self.radius = random(32, 128) * Scale.x
    self.angle = (math.pi * 2) * random()
    self.speed = lg.getWidth() * 0.04
    self.velocity = vec2():setLength(self.speed):setAngle(self.angle)


    self.moon = false
    if random() < 0.2 then
        self.moon = vec2()
        self.orbit = (math.pi * 2) * random()
        self.orbitSpeed = 0.3 + (random() * 0.5)
    end

    self.scale = 0

    later(function()
        flux.to(self, config.window.animationScale * 10, {scale = 1}):ease("elasticout")
    end, random())

    self.r = 0
    self.g = 0
    self.b = 0

    self:randomColor()

    self.animationFrequency = 10
    self.animationRange = 30

    self.time = self.animationFrequency + (random() * self.animationFrequency)
end

function particle:randomColor()
    local colorIndex = util.offsetColorIndex(random(config.window.colorPaletteSize))
    local r = color[colorIndex][1]
    local g = color[colorIndex][2]
    local b = color[colorIndex][3]

    flux.to(self, config.window.animationScale * 10, {r = r, g = g, b = b})
end

function particle:update(dt)
    self.time = self.time + dt

    if self.moon then
        self.orbit = self.orbit + self.orbitSpeed * dt
        if self.orbit > math.pi * 2 then
            self.orbit = 0
        end
    end

    if self.time < 0 then
        self.angle = (math.pi * 2) * random()
        self.velocity:setAngle(self.angle)
        flux.to(self, config.window.animationScale * 20, {scale = 1 + (math.random() * 0.5)}):ease("elasticout"):oncomplete(function()
            flux.to(self, config.window.animationScale * 20, {scale = 1}):ease("backout")
        end)
        self:randomColor()
        
        self.time = self.animationFrequency + (random() * self.animationFrequency)
    end

    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt

    if self.moon then
        self.moon.x = self.position.x + cos(self.orbit) * self.radius * 1.5
        self.moon.y = self.position.y + sin(self.orbit) * self.radius * 1.5
    end

    local extra = 4
    if self.position.x < self.worldX - (self.radius * extra) then
        self.position.x = self.worldX + self.worldWidth + (self.radius * extra)
    elseif self.position.x > self.worldX + self.worldWidth + (self.radius * extra) then
        self.position.x = self.worldX - (self.radius * extra)
    end

    if self.position.y < self.worldY - (self.radius * extra) then
        self.position.y = self.worldY + self.worldHeight + (self.radius * extra)
    elseif self.position.y > self.worldY + self.worldHeight + (self.radius * extra) then
        self.position.y = self.worldY - (self.radius * extra)
    end
end

function particle:draw()
    lg.setColor(0, 0, 0, config.window.shadowAlpha)
    lg.circle("fill", self.position.x, self.position.y + self.radius * 0.2, self.radius * self.scale)


    lg.setColor(self.r, self.g, self.b, self.scale)
    lg.circle("fill", self.position.x, self.position.y, self.radius * self.scale)

    if self.moon then
        lg.setColor(0, 0, 0, config.window.shadowAlpha)
        lg.circle("fill", self.moon.x, self.moon.y + (self.radius * 0.35), (self.radius * 0.3) * self.scale)

        lg.setColor(self.r, self.g, self.b, self.scale)
        lg.circle("fill", self.moon.x, self.moon.y, (self.radius * 0.3) * self.scale)
    end

    lg.setColor(color[19])
    lg.circle("line", self.position.x, self.position.y, self.radius * self.scale * 1)

    
    -- lg.setBlendMode("add")
    -- local count = 10
    -- for i=1, count do
    --     lg.setColor(1, 1, 1, 0.04)
    --     lg.circle("line", self.position.x, self.position.y, self.radius * (i * 0.2) * self.scale)
    -- end
    -- lg.setBlendMode("alpha")
end

return particle