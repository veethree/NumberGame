local min, max, random = math.min, math.max, love.math.random
local class = require "lib.class"
local maf = class()

--:: General stuff ::--
function maf.normal(val, min, max)
	return (val - min) / (max - min)
end

function maf.map(val, min, max)
	return (max - min) * val + min
end

function maf.lerp(a, b, t)
	return a + (b - a) * t
end

function maf.clamp(val, min, max)
	return max(min, min(val, max))
end

function maf.distance(x1, y1, x2, y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function maf.angle(x1, y1, x2, y2)
	return math.atan2(y2-y1, x2-x1)
end

--:: Intersections ::--
function maf.pointInRect(px, py, rx, ry, rw, rh)
	return px > rx and px < rx + rw and py > ry and py < ry + rh
end

function maf.rectIntersect(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end

--:: Random ::--
function maf.randomBool()
	return math.random() < 0.5
end

function maf.rsign()
	return random(2) == 2 and 1 or -1
end

return maf