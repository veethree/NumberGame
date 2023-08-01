local class = require "lib.class"
local util = class()
        
function util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Counts items in a dictionary like table ({"foo" = bar, "bar" = foobar}) > 2
function util.len(tab)
    local c = 1
    for k,v in pairs(tab) do c = c + 1 end
    return c
end

-- Returns true of table "tab" contains value "val"
function util.contains(tab, val)
    for k,v in pairs(tab) do
        if v == val then
            return true
        end
    end
end

-- Hooks a custom function to a löve callback
function util.hook(callback, func, ...)
    local arguments = {...}
    local base = love[callback] or function() end
    love[callback] = function(...)
        base(...)
        func(unpack(arguments), ...)
    end
end

-- requires all .lua files in a given directory
-- tab is a table into which the files will be loaded, Defaults to _G
-- If recursive is "true", It will recursively load every sub directory as well.
function util.requireDirectory(path, tab, recursive)
    tab = tab or _G
    if fs.getInfo(path) then    
        for _,item in ipairs(fs.getDirectoryItems(path)) do
            local name = util.getFileName(item)
            if fs.getInfo(path .. "/" .. item).type == "directory" then
                if recursive then
                    tab[name] = {} 
                    util.requireDirectory(path .. "/" .. name, tab[name], true)
                end
            else
                if util.getFileType(item) == "lua" then
                    tab[name] = require(path .. "." .. name)
                end
            end
        end
    end
end

-- Returns the extension of fileName ("main.lua" > "lua")
function util.getFileType(fileName)
    local type = string.match(fileName, "%..+")
    if type then
        return type:sub(2) 
    else
        return false
    end
end

-- Returns the name of fileName ("main.lua" > "main")
function util.getFileName(fileName)
    local name = string.match(fileName, ".+%.")
    if name then
        return name:sub(1, -2) 
    else
        return fileName
    end
end
 
-- Converts colors from 0-255 to 0-1
function util.convertColor(r, g, b, a)
    a = a or 255
    return r / 255,  g / 255,  b / 255,  a / 255
end

function util.loadAtlas(path, tileWidth, tileHeight, padding)
	if not love.filesystem.getInfo(path) then
		error("'"..path.."' doesn't exist.")
	end

	local a = {}
	local img = love.graphics.newImage(path)
	local width = math.floor(img:getWidth() / tileWidth)
	local height = math.floor(img:getHeight() / tileHeight)
		
	local x, y = padding, padding
	for i=1, width * height do
		a[i] = love.graphics.newQuad(x, y, tileWidth, tileHeight, img:getWidth(), img:getHeight())
		x = x + tileWidth + padding
		if x > ((width-1) * tileWidth) then
			x = padding
			y = y + tileHeight + padding
		end
	end

	return img, a
end

-- Serializes a table into a string ({a = 1, b = 2} > "return {a = 1, b = 2}")
function util.serialize(tab, recursion)
    recursion = recursion or false
    local output = "return {"
    if recursion then output = "" end
    local count = 1
    local length = util.len(tab)
    for key,val in pairs(tab) do
        if tonumber(key) then key = "" else key = key.."=" end
        if type(val) == "string" then val = '"'..val..'"' end
        if type(val) == "table" then val = "{"..util.serialize(val, true) end
        output = output..key..tostring(val)
        if count < length then output = output.."," end
        count = count + 1
    end
    output = output.."}"
    return output
end

-- Saves a table to a file
function util.save(tab, fileName)
    fs.write(fileName, util.serialize(tab))
end

-- Loads a table from a file
function util.load(fileName)
    if fs.getInfo(fileName) then return fs.load(fileName)() end
end

function util.hsl(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h*6, s, l
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return r+m, g+m, b+m, a
end

-- local thing = util.randomChoice({
--     { choice = "one", weight = 100 },
--     { choice = "two", weight = 50 },
--     { choice = "three", weight = 25 },
--     { choice = "four", weight = 10 },
--     { choice = "five", weight = 3 },
-- })

function util.randomChoice(t)
    local sum = 0
    local backup = ""
    for k,v in pairs(t) do
        backup = k
        sum = sum + v
    end

    local r = random(sum)
    local rsum = 0

    for k,v in pairs(t) do
        rsum = rsum + v
        if rsum > r then
            return k
        end
    end
    return backup
end

-- Source: http://lua-users.org/wiki/FormattingNumbers
function util.comma(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
        break
        end
    end
    return formatted
end

function util.randomLine(filename)
    local lines = {}
    for line in fs.lines(filename) do
        lines[#lines+1] = line
    end
    return lines[random(#lines)] 
end

function util.offsetColorIndex(colorIndex)
    return colorIndex + (config.window.colorPaletteSize * (config.window.colorTheme - 1))
end

return util