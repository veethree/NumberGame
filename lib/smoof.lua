-- Smoof: A tweening library for lua
-- Version 2.0
--
-- MIT License
-- 
-- Copyright (c) 2021 Pawel Þorkelsson
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local smoof = {
    stack = {} -- Contains all current tweens
}
smoof.mt = {
    __index = smoof,
    __call = function(self, ...)
        return self.new(self, ...)
    end
}
setmetatable(smoof, smoof.mt)

-- Shorthands
local insert, remove = table.insert, table.remove

-- Local functions
local function lerp(a, b, t)
	return a + (b - a) * t
end

-- Easing functions adapted from https://easings.net/
smoof.functions = {
    linear = function(t)
        return t
    end,
    smoothstep = function(t)
        local v1 = t * t
        local v2 = 1 - (1 - t) * (1 - t)
        return lerp(v1, v2, t)
    end,
    -- Sine
    easeInSine = function(t)
        return 1 - math.cos((t * math.pi) / 2)
    end,
    easeOutSine = function(t)
        return math.sin((t * math.pi) / 2)
    end,
    easeInOutSine = function(t)
        return -(math.cos(math.pi * t) - 1) / 2
    end,

    -- QUAD
    easeInQuad = function(t)
        return t * t
    end,
    easeOutQuad = function(t)
        return 1 - (1 - t) * (1 - t);
    end,
    easeInOutQuad = function(t)
        if t < 0.5 then
            return 2 * t * t
        else
            return 1 - (-2 * t + 2)^2 / 2
        end
    end,
    
    -- CUBIC
    easeInCubic = function(t)
        return t * t * t
    end,
    easeOutCubic = function(t)
        return 1 - math.pow(1 - t, 3)
    end,
    easeInOutCubic = function(t)
        if t < 0.5 then
            return 4 * t * t * t            
        else
            return 1 - math.pow(-2 * t + 2, 3) / 2
        end
    end,

    -- QUART
    easeInQuart = function(t)
        return t * t * t * t
    end,
    easeOutQuart = function(t)
        return 1 - math.pow(1 - t, 4)
    end,
    easeInOutQuart = function(t)
        if t < 0.5 then
            return 8 * t * t * t * t            
        else
            return 1 - math.pow(-2 * t + 2, 4) / 2
        end
    end,

    -- QUINT
    easeInQuint = function(t)
        return t * t * t * t * t
    end,
    easeOutQuint = function(t)
        return 1 - math.pow(1 - t, 5)
    end,
    easeInOutQuint = function(t)
        if t < 0.5 then
            return 16 * t * t * t * t * t            
        else
            return 1 - math.pow(-2 * t + 2, 5) / 2
        end
    end,
    
    -- EXPO
    easeInExpo = function(t)
        if t == 0 then
            return 0
        else
            return math.pow(2, 10 * t - 10)
        end
    end,
    easeOutExpo = function(t)
        if t == 1 then
            return 1
        else
            return 1 - math.pow(2, -10 * t)
        end
    end,
    easeInOutExpo = function(t)
        if t == 0 then
            return 0
        elseif t == 1 then
            return 1
        else
            if t < 0.5 then
                return math.pow(2, 20 * t - 10) / 2
            else
                return (2 - math.pow(2, -20 * t + 10)) / 2
            end
        end
    end,

    -- CIRC
    easeInCirc = function(t)
        return 1 - math.sqrt(1 - t^2)
    end,
    easeOutCirc = function(t)
        return math.sqrt(1 - math.pow(t - 1, 2))
    end,
    easeInOutCirc = function(t)
        if t < 0.5 then
            return (1 - math.sqrt(1 - math.pow(2 * t, 2))) / 2
        else
            return (math.sqrt(1 - math.pow(-2 * t + 2, 2)) + 1) / 2
        end
    end,

    -- BACK
    easeInBack = function(t)
        local c1 = 0.2
        local c3 = c1 + 1
        return c3 * t * t * t - c1 * t * t
    end,
    easeOutBack = function(t)
        local c1 = 1.7
        local c3 = c1 + 1
        return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
    end,

}

--- Creates a new tween
-- @param target: The table to be tweened (ex: {a = 12, b = 12})
-- @param targetValues: A table with desired values for the tween (ex: {a = 36, b = 329})
-- @param func: The easing function to be used for the tween
-- @param time: How leng the tween should take in seconds
-- @param wait: How leng the to wait before starting the tween
function smoof:new(target, targetValues, func, time, wait)
    local tween = setmetatable({
        target = target,
        targetValues = targetValues,
        func = self.functions[func or "linear"],
        time = time or 1,
        wait = wait or 0,
        value = 0,
        callbacks = {
            onStartCalled = false,
            onEndCalled = false
        }
    }, self.mt)

    -- Checking if the target is already in the stack
    local index, exists = 0, false
    for i,v in ipairs(self.stack) do
        if v.target == target then
            exists = true
            index = i
            break
        end
    end

    -- if exists then
    --     remove(self.stack, index)
    -- end

    insert(self.stack, tween)
    return tween
end

--- Returns how many tweens are happening right now
function smoof:count()
    return #self.stack
end

--- Adds a callback to a tween.
-- @param callback: Callback to add ("onStart, "onStep", "onEnd")
-- @param func: The function to be used for the callback. It will be called with the tween as an argument
function smoof:callback(callback, func)
    self.callbacks[callback] = func 
    return self
end

--- Updates the tweens in the stack
function smoof:update(dt)
    for i, tween in ipairs(self.stack) do
        tween.wait = tween.wait - dt
        if tween.wait < 0 then
            tween.wait = 0
            -- onStart callback
            if not tween.callbacks.onStartCalled then
                if tween.callbacks.onStart then
                    tween.callbacks.onStart(tween)
                    tween.callbacks.onStartCalled = true
                end
            end
            tween.value = tween.value + (1 / tween.time) * dt
            if tween.value > 0.9 then
                tween.value = 1
                remove(self.stack, i)
                -- onEnd Callback
                if tween.callbacks.onEnd then
                    tween.callbacks.onEnd(tween)
                end
            end
            -- onStep callback
            if tween.callbacks.onStep then
                tween.callbacks.onStep(tween)
            end
            for key,val in pairs(tween.target) do
                if tween.targetValues[key] then
                    tween.target[key] = lerp(tween.target[key], tween.targetValues[key], tween.func(tween.value))
                end
            end
        end
    end
end

return smoof

