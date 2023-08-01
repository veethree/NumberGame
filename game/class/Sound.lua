local class = require "lib.class"

local sound = class()

function sound:init(filename, type)
    self.source = love.audio.newSource(filename, type or "static")
end

function sound:play()
    self.source:stop()
    self.source:play()
end

return sound