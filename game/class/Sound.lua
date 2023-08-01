local class = require "lib.class"

local sound = class()

function sound:init(filename, type)
    self.maxSources = 10
    self.type = type

    if type == "stream" then
        self.maxSources = 1
    end

    self.sources = {}
    self.offset = 0.01
    for i=1, self.maxSources do
        self.sources[i] = love.audio.newSource(filename, type or "static")
    end

    self.source = self.sources[1]

end

function sound:loop()
    self.sources[1]:setLooping(true)
end

function sound:volume(v)
    for i,v in ipairs(self.sources) do
        v:setVolume(v)
    end
end

function sound:stop()
    for i,v in ipairs(self.sources) do
        v:stop()
    end
end

function sound:play()
    if self.type == "static" then
        if not config.window.soundFX then
            return
        end
    elseif self.type == "stream" then
        if not config.window.music then
            return
        end
    end

    for i, source in ipairs(self.sources) do
        if not source:isPlaying() then
            later(function()
                source:play()
            end, self.offset * i)
            return
        end
    end
end

return sound