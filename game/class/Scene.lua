util = require "lib.util"
-- A scene managenent class
local Scene = class()

-- Checks if "scene" exists and contains the function "callback"
local function hasCallback(scene, callback)
    if scene then
        if type(scene[callback]) == "function" then
            return true
        end
    end
    return false
end

-- Creating callback functions
Scene.callbackFunctions = {
    "load", "update", "draw", "resize", "quit", "mousepressed", "mousereleased", 
    "mousemoved", "wheelmoved", "mousefocus", "keypressed", "keyreleased", "textinput", "focus"}

for _,callback in ipairs(Scene.callbackFunctions) do
    Scene[callback] = function(self, ...)
        if hasCallback(self.scene, callback) then
            if callback ~= "update" and callback ~= "draw" then
                print(callback)
            end
            self.scene[callback](self.scene, ...)
        end
    end
end

function Scene:init()
    self.scene = false -- The currently loaded scene
end

function Scene:loadScene(scene)
    self.scene = scene()
    self:load()
end

-- Appends Scene callbacks to the löve callbacks
-- skip is an optional table of callbacks that should NOT be appened ({"draw", "update"})
function Scene:registerEvents(skip)
    skip = skip or {}
    for _, callback in ipairs(self.callbackFunctions) do
        if not util.contains(skip, callback) then
            util.hook(callback, self[callback], self)
        end
    end  
end

return Scene