local class = require "lib.class"

local cell = class()

-- 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384


function cell:init(x, y, board, index)
    self.index = index
    self.cellX, self.cellY = x, y
    self.board = board
    self.width = board.cellWidth * 0.85
    self.height = board.cellHeight * 0.85
    self.x = board.x + board.cellWidth * (x - 1)
    self.y = board.y + board.cellHeight * (y - 1)
    self.flash = Flash(self.x + (self.width * config.window.cellScale) / 2, self.y + (self.height * config.window.cellScale) / 2, self.width * 2, 3.5)

    self.time = random() * 0.1

    self.maxValue = 4096

    self.transition = 0

    self.value = 0
    self.printValue = 0
    self.selected = false

    self.hue = (1 / self.maxValue) * self.value
    self.saturation = 0.5
    self.lightness = 0.25

    self.r, self.g, self.b = 0, 0, 0
    self.colorIndex = 1

    self.special = {"clearColumn", "clearRow", "double", "quadruple", "crossClear"}
    self.type = "normal"

    self.image = false

    self.bgImage = image.tile
    self.fgImage = image.tileOverlay

    self.scale = 0
    later( function()
        later( function()
            flux.to(self, config.window.animationScale * 3, {scale = 1}):ease("backout")
        end, self.index * 0.05)
    end, 0.1)

end

function cell:hide()
    later( function()
        flux.to(self, config.window.animationScale * 2, {scale = 0}):ease("backout")
    end, self.index * 0.01)
end

function cell:setSpecial(type)
    self.type = type

    self.value = -1
    if self.type == "clearRow" then
        self.image = image.rowClear
    elseif self.type == "clearColumn" then
        self.image = image.colClear
    elseif self.type == "clearCross" then
        self.image = image.crossClear
    end
    self:updateColor()
end

function cell:setValue(val, instant)
    self.image = false
    if val >= 1 then
        self.type = "normal"
    end

    if val == 0 then
        self.type = "empty"
    end

    if instant then
        self.value = val
        self:updateColor()
    else
        flux.to(self, config.window.animationScale * 1, {transition = 1}):oncomplete(function()
            self.transition = -1
            self.value = val
            self.printValue = val
            self:updateColor() 
            sound.swish:play()
            flux.to(self, config.window.animationScale * 1, {transition = 0})
        end)
    end
end

function cell:select()
    self.selected = true
    flux.to(self, config.window.animationScale * 4, {scale = 0.9}):ease("elasticout")
end

function cell:deselect()
    self.selected = false
    flux.to(self, config.window.animationScale * 4, {scale = 1}):ease("elasticout")
end

-- If spec
function cell:randomValue(special)
    local type = util.randomChoice({
        normal = 4000,
        clearColumn = 50,
        clearRow = 50,
        clearCross = 50,
        double = 10,
        quadruple = 5,
    })

    -- Normal cell
    -- Defining possible starting values strangely because numbers
    if type == "normal" then
        local values = {}
        values["2"] = 800
        values["4"] = 800
        values["8"] = 800
        values["16"] = 1000
        values["32"] = 200
        values["64"] = 10

        -- Picking starting value
        self:setValue(tonumber(util.randomChoice(values)))
        self.image = false
    else
        -- Super cell
        self.type = type
        self:setValue(-1)
        if self.type == "clearRow" then
            self.image = image.rowClear
        elseif self.type == "clearColumn" then
            self.image = image.colClear
        elseif self.type == "clearCross" then
            self.image = image.crossClear
        end
    end

    return self
end

function cell:updateColor()
    local colorIndex = math.log(self.value) / math.log(2)
    -- local colorIndex = math.log(self.maxValue)  / math.log(#self.colors)

    
    -- If infinity
    if colorIndex == -(1/0) then
        colorIndex = 18
    end
    
    -- Clamping
    if colorIndex < 1 then
        colorIndex = 19
    elseif colorIndex > 16 then
        colorIndex = 16
    end

    -- Special cells
    if self.type ~= "normal" then
        colorIndex = 13
    end

    if self.type == "empty" then
        colorIndex = 19
    end

    if self.value == -1 then
        colorIndex = 20
    end

    
    local r, g, b = color[util.offsetColorIndex(colorIndex)][1], color[util.offsetColorIndex(colorIndex)][2], color[util.offsetColorIndex(colorIndex)][3]
    self.colorIndex = colorIndex
    self.flash.color = colorIndex
    
    flux.to(self, config.window.animationScale, {r = r, g = g, b = b}):ease("quadin")
end

function cell:wobble()
    flux.to(self, config.window.animationScale * 2, {scale = 1.1}):oncomplete( function()
        flux.to(self, config.window.animationScale * 4, {scale = 1}):ease("elasticout")
    end)
end

function cell:update(dt)

end

function cell:draw()
    local width = floor((self.width * self.scale) * config.window.cellScale)
    local height = floor((self.height * self.scale) * config.window.cellScale)

    -- lg.setColor(0, 0, 0, self.scale * config.window.shadowAlpha)
    -- lg.draw(self.bgImage, 
    --     self.x + (self.board.cellWidth / 2) - (width / 2),
    --     self.y + (self.board.cellHeight / 2) - (height / 2) + (height * 0.1), 0,
    --     width / self.bgImage:getWidth(), height / self.bgImage:getHeight())

    -- SELECTED
    if self.selected then
        local width = width * 0.9
        local height = height * 0.9
        lg.setColor(color[util.offsetColorIndex(12)])
        lg.rectangle("line", 
            self.x + (self.board.cellWidth / 2) - (width / 2),
            self.y + (self.board.cellHeight / 2) - (height / 2),
            width, height * 1.1, width * 0.1, height * 0.1)
    end

    lg.setColor(self.r, self.g, self.b, self.scale)
    lg.draw(self.bgImage, 
        floor(self.x + (self.board.cellWidth / 2) - (width / 2)),
        floor(self.y + (self.board.cellHeight / 2) - (height / 2)), 0,
        floor((width / self.bgImage:getWidth()) * 1000 ) / 1000, floor((height / self.bgImage:getHeight()) * 1000 ) / 1000)
            

    -- IMAGE
    if self.image then
        lg.setColor(0, 0, 0, config.window.shadowAlpha * self.scale)
        lg.draw(self.image,
            self.x + (self.board.cellWidth / 2) - (width / 2),
            self.y + (self.board.cellHeight / 2) - (height / 2) + height * 0.04, 0,
            width / self.image:getWidth(), height / self.image:getHeight())

        lg.setColor(1, 1, 1, self.scale)
        lg.draw(self.image,
            self.x + (self.board.cellWidth / 2) - (width / 2),
            self.y + (self.board.cellHeight / 2) - (height / 2), 0,
            width / self.image:getWidth(), height / self.image:getHeight())
    end
    

    -- TEXT
    -- local text = floor(self.printValue)
    local text = floor(self.value)

    if self.value == 0 then
        text = "x"
    end

    if self.type == "clearRow" or self.type == "clearColumn" or self.type == "clearCross" then
        text = ""
    end

    if self.type == "double" then
        text = "x2"
    elseif self.type == "quadruple" then
        text = "x4"
    elseif self.type == "octuple" then
        text = "x8"
    elseif self.type == "sexdecuple" then
        text = "x16"
    end


    local x, y = self.x, self.y - (self.height * (1 - self.scale))

    local stencilFunction = function()
        lg.setShader(maskShader)
        lg.draw(self.bgImage, 
            floor(self.x + (self.board.cellWidth / 2) - (width / 2)),
            floor(self.y + (self.board.cellHeight / 2) - (height / 2)), 0,
            floor((width / self.bgImage:getWidth()) * 1000 ) / 1000, floor((height / self.bgImage:getHeight()) * 1000 ) / 1000)
        lg.setShader()
    end

    lg.stencil(stencilFunction)

    lg.setStencilTest("greater", 0)
    
    -- SHADOW
    -- lg.setColor(util.hsl(self.hue, self.saturation, self.lightness - 0.04, self.scale))
    lg.setColor(0, 0, 0, self.scale * config.window.shadowAlpha)
    lg.setFont(font.huge)
    lg.printf(text,
        x + (self.board.cellWidth / 2) - (self.width / 2),
        y + (self.board.cellHeight / 2) - (self.height / 2) + (self.height / 2) - ((lg.getFont():getAscent() - lg.getFont():getDescent()) / 2) + (self.height * 0.04) -((height) * self.transition),
        self.width, "center")

    -- TEXT
    -- lg.setColor(color[util.offsetColorIndex(self.colorIndex)][1] + 0.6, color[util.offsetColorIndex(self.colorIndex)][2] + 0.6, color[util.offsetColorIndex(self.colorIndex)][3] + 0.6, self.scale)
    lg.setColor(color[util.offsetColorIndex(17)][1], color[util.offsetColorIndex(17)][2], color[util.offsetColorIndex(17)][3], self.scale)
    lg.setFont(font.huge)
    lg.printf(text,
        x + (self.board.cellWidth / 2) - (self.width / 2),
        y + (self.board.cellHeight / 2) - (self.height / 2) + (self.height / 2) - ((lg.getFont():getAscent() - lg.getFont():getDescent()) / 2) - ((height) * self.transition),
        self.width, "center")

    lg.setBlendMode("add")
    lg.setColor(1, 1, 1, self.scale - 1)
    lg.draw(self.bgImage, 
        floor(self.x + (self.board.cellWidth / 2) - (width / 2)),
        floor(self.y + (self.board.cellHeight / 2) - (height / 2)), 0,
        floor((width / self.bgImage:getWidth()) * 1000 ) / 1000, floor((height / self.bgImage:getHeight()) * 1000 ) / 1000)
    lg.setBlendMode("alpha")

    self.flash:draw()
    
    lg.setStencilTest()
    
    -- FG
    -- if self.value > 0 then
    -- lg.setColor(1, 1, 1, self.scale)
    -- lg.draw(self.fgImage, 
    --     self.x + (self.board.cellWidth / 2) - (width / 2),
    --     self.y + (self.board.cellHeight / 2) - (height / 2), 0,
    --     width / self.bgImage:getWidth(), height / self.bgImage:getHeight())
    -- end

    -- Debug text
    -- lg.setColor(util.hsl(self.hue, self.saturation + 0.2, self.lightness + 0.7, self.scale))
    -- lg.setFont(font.small)
    -- lg.printf(self.colorIndex,
    --     x + (self.board.cellWidth / 2) - (self.width / 2),
    --     y + (self.board.cellHeight / 2) - (self.height / 2) + (self.height / 2) - ((lg.getFont():getAscent() - lg.getFont():getDescent()) / 2) + (self.height * 0.2),
    --     self.width, "center")
    
end

return cell