local later = {
    stack = {}
}


function later.new(self, fn, time)
    self.stack[#self.stack+1] = {
        fn = fn,
        time = time or 1
    }
end

function later:update(dt)
    for i,v in ipairs(self.stack) do
        v.time = v.time - dt
        if v.time < 0 then
            v.fn()
            table.remove(self.stack, i)
        end
    end
end

local mt = {
    __index = later,
    __call = later.new
}
return setmetatable(later, mt)