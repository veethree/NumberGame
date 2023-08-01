local class = require "lib.class"
local Gradient = class()

local shader = lg.newShader([[
    #define MAX_POINTS 32

    // Defining a struct for the points
    struct Light {
        vec2 position;
        vec4 color;
        float size;
    };

    uniform Light lights[MAX_POINTS];
    //uniform float count;

    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec4 pixel = vec4(0);
        for (int i=0; i < MAX_POINTS; i++) {
            Light light = lights[i];
            pixel += light.color / distance(light.position, tc) * light.size;
        }

        return clamp(pixel, 0.0, 1.0);
    }
    
]])

function Gradient:init(width, height, colors)
    -- Sending relevant data to the shader
    -- shader:send("count", #colors)
    for i,v in ipairs(colors) do
        shader:send("lights[" .. i - 1 .."].position", v.position)
        shader:send("lights[" .. i - 1 .."].color", v.color)
        shader:send("lights[" .. i - 1 .."].size", v.size)
    end

    local blank = lg.newCanvas(width, height)
    self.canvas = lg.newCanvas(width, height)
    lg.setCanvas(blank)
    lg.setColor(1, 1, 1, 1)
    lg.rectangle("fill", 0, 0, width, height)
    lg.setCanvas(self.canvas)
    lg.setShader(shader)
    lg.draw(blank)
    lg.setShader()
    lg.setCanvas()
    return self
end

function Gradient:get()
    return self.canvas
end

return Gradient