local class = require "lib.class"

local timer = class()

function timer:init(fn, time, repeats)
    self.fn, self.time, self.repeats = fn, time, repeats or -1
    self.timer = 0
end

function timer:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.time then
        self.fn()    
        self.timer = self.time
    end
end

return timer