-- GLOBAL SETTINGS
NAME = "Number Game"
VERSION = "0.3a"
DEBUG_MODE = true
USE_CONFIG = true -- If false the defaultConfig file is always used.
USE_SHADERS = false

--:: SHORTHANDS ::--
lg = love.graphics
fs = love.filesystem
kb = love.keyboard
lm = love.mouse
random = love.math.random
noise = love.math.noise
sin = math.sin
cos = math.cos
floor = math.floor
f = string.format

local outputToScreen = false
local printout = ""
local oprint = print
function print(...)
    if outputToScreen then
        printout  = printout .. table.concat({...}) .. "\n"
    end
    oprint(...)
end


function love.load()
    -- Loading util first as it contains the "requireDirectory" function used to load everything else
    util = require "lib.util"
    
    -- Setting the identy before creating/loading the config file
    fs.setIdentity(NAME)

    -- Loading config file
    defaultConfig = util.load("game/defaultConfig.lua")
    if USE_CONFIG then 
        config = util.load("config.lua") or defaultConfig 
        util.save(config, "config.lua")
    else 
        config = defaultConfig 
    end

    fixConfig()

    -- Creating window
    love.window.setMode(config.window.width, config.window.height, config.window.settings)
    love.window.setTitle(config.window.title)

    love.timer.step()


    --Loading libraries
    util.requireDirectory("lib")

    -- Loading classes
    util.requireDirectory("game/class")

    -- Graphics setup
    -- lg.setDefaultFilter("nearest", "nearest")
    -- lg.setLineStyle("rough")
    local function c(r, g, b, a)
        a = a or 255
        return {r / 255,  g / 255,  b / 255,  a / 255}
    end
    lg.setBackgroundColor(color[util.offsetColorIndex(18)])

    -- Loading scenes
    scene = {}
    util.requireDirectory("game/scene", scene)

    TIME = 0
    TICK = 0

    image = {
        rowClear = lg.newImage("game/art/image/rowClear_256.png"),
        colClear = lg.newImage("game/art/image/colClear_256.png"),
        crossClear = lg.newImage("game/art/image/crossClear_256.png"),
        tile = lg.newImage("game/art/image/tileBase_256.png"),
        tileOverlay = lg.newImage("game/art/image/tileOverlay.png"),
        logo = lg.newImage("game/art/image/logo_1024.png")
    }

    -- Loading sounds
    sound = {
        tick = Sound("game/art/sound/tick.ogg")
    }
    
    -- Calling resize to calculate the scale values
    resize()

    maskShader = lg.newShader([[
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            if (Texel(tex, tc).a < 0.1) {
                discard;
            }

            return Texel(tex, tc);
        }
    ]])

    background = Background()

    Scene:registerEvents({"draw"})
    Scene:loadScene(scene[config.game.startingScene])
end

function saveConfig()
    util.save(config, "config.lua")
end

function fixConfig()
    for o,b in pairs(defaultConfig) do
        for k,v in pairs(b) do
            if not config[o][k] then
                config[o][k] = v
            end
        end 
    end
    saveConfig()
end

function love.update(dt)
    lg.setBackgroundColor(color[util.offsetColorIndex(18)])
    TIME = TIME + dt
    TICK = sin(TIME)

    background:update(dt)
    flux.update(dt)
    later:update(dt)
    
end

function love.draw()
    lg.setColor(1, 1, 1, 1)
    background:draw()
    Scene:draw()

    if DEBUG_MODE then
        -- lg.setColor(color[16])
        -- lg.setFont(font.small)
        -- lg.print(love.timer.getFPS(), 12, 12)

        lg.setFont(font.tiny)
        lg.setColor(color[18])
        lg.print(printout, 12, 14)
        lg.setColor(color[17])
        lg.print(printout, 12, 12)

        -- lg.setColor(color[9])
        -- lg.rectangle("line", SAFE.x, SAFE.y, SAFE.width, SAFE.height)
    end
end

function resize(width, height)
    width = width or lg.getWidth()
    height = height or lg.getHeight()

    local x, y, w, h = love.window.getSafeArea()
    -- local x, y, w, h = 0, 100, lg.getWidth(), lg.getHeight() - 100
    SAFE = {x = x, y = y, width = w, height = h}

    config.window.width, config.window.height = width, height
    local scaleX, scaleY = config.window.width / config.window.nativeWidth, config.window.height / config.window.nativeHeight
    local scale = math.min(scaleX, scaleY)
    Scale = vec2(scale, scale)

    lg.setLineWidth(2)

    font = {
        tiny = lg.newFont("game/art/font/" .. config.window.font, 30 * config.window.fontScale * Scale.x),
        small = lg.newFont("game/art/font/" .. config.window.font, 40 * config.window.fontScale * Scale.x),
        medium = lg.newFont("game/art/font/" .. config.window.font, 60 * config.window.fontScale * Scale.x),
        large = lg.newFont("game/art/font/" .. config.window.font, 80 * config.window.fontScale * Scale.x),
        huge = lg.newFont("game/art/font/" .. config.window.font, 70 * config.window.fontScale * Scale.x),
        huger = lg.newFont("game/art/font/" .. config.window.font, 120 * config.window.fontScale * Scale.x),
        subtitle = lg.newFont("game/art/font/" .. config.window.font, 230 * config.window.fontScale * Scale.x),
        title = lg.newFont("game/art/font/" .. config.window.font, 300 * config.window.fontScale * Scale.x),
    }
end

function love.resize(width, height)
    resize(width, height)
end

function love.focus(f)

end

function love.quit()
    util.save(config, "config.lua")
end

function love.keypressed(key)
    if key == "escape" and DEBUG_MODE then love.event.push("quit") end

    if key == "e" then
        error("pussyjuice")
    end

    if key == "f1" then
        love.system.openURL("file://"..love.filesystem.getSaveDirectory())     
    elseif key == "f2" then
        lg.captureScreenshot(os.time()..".png")
    end
end

local utf8 = require("utf8")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

    -- Clearing config file in case of error
    fs.remove("config.lua")

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
        love.graphics.setFont(font.small)
		love.graphics.clear(color[18])
        love.graphics.setColor(color[16])
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end