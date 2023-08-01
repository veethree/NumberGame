-- class.lua: A very basic OOP helper library for lua.
-- v1.0
local mt = {
    __index = function(self, key) return self.__baseClass[key] end,
    __call = function(self, ...) return self:new(...) end
}
local class = setmetatable({ __baseClass = {} }, mt)
function class:new(...)
    local arg = {...}
    local cls = {__baseClass = self, __type = "class"}
    setmetatable(cls, getmetatable(self))
    if type(arg[1]) == "table" then
        if arg[1].__type == "class" then
            cls.__super = arg[1]
            cls.__baseClass = arg[1]
            setmetatable(cls, getmetatable(arg[1]))
        end
    end
    if cls.init then cls:init(...) end
    return cls
end
return class