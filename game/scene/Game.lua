local class = require "lib.class"
local Game = class()

function Game:init()
    
end

function Game:load()
    self.inputBlocked = false
    self.state = "game"
    self.flash = {}

    -- UI Elements
    -- Score
    self.scoreTitle = Text("Score", 0, -lg.getHeight(), font.large, color[util.offsetColorIndex(17)], "center")
    self.scoreText = Text("0", 0, -lg.getHeight(), font.huger, color[util.offsetColorIndex(1)], "center")

    -- Game Over
    self.gameOverTitle = Text("GAME OVER", 0, -lg.getHeight(), font.huger, color[util.offsetColorIndex(16)], "center")
    self.gameOverText = Text("GAME OVER", 0, -lg.getHeight(), font.large, color[util.offsetColorIndex(17)], "center")
    self.resetText = Text("Tap to reset", 0, lg.getHeight() * 2, font.medium, color[util.offsetColorIndex(1)], "center")

    self.helpTitle = Text("Help", 0, -lg.getHeight(), font.huge, color[util.offsetColorIndex(1)], "center")

--     local helpScript = [[
-- Tap two tiles with the same value to combine them. Clear a row or column of tiles for more tiles to spawn
    
-- Yellow tiles are special, Combine them with something and see what happens

-- The game ends when you run out of tiles to combine.]]

    local helpScript = {
        color[17], "Tap two tiles with the same value to combine them, Clear a row or column of tiles, and more tiles will apear\n\n",
        color[20], "Yellow ",
        color[17], "tiles are special, Match them with numbered ones and see what happens\n\n",
        color[17], "The game ends when you run out of tiles to combine"
    }

    self.helpText = Text(helpScript, 0, -lg.getHeight(), font.medium, {1, 1, 1, 1}, "center")

    -- Buttonz
    local topGuiY = lg.getHeight() * 0.02 + SAFE.y
    self.ui = {
        exit = Button("X", lg.getWidth() * 0.05, topGuiY, lg.getHeight() * 0.08, lg.getHeight() * 0.08, color[16]):setFunction(function()
            self.board:hide()
            self.ui.help:hide()
            self.ui.exit:hide()
            self.scoreTitle:move(false, -SAFE.height, 1)
            self.scoreText:move(false, -SAFE.height, 1)
            flux.to(self, config.window.animationScale * 2, {anim = 0}):oncomplete(function()
                config.game.savedBoardState = self.board:saveState()
                config.game.savedScore = self.score
                Scene:loadScene(scene.Menu)
            end)
        end),
        help = Button("?", lg.getWidth() - ((lg.getHeight() * 0.08) + (lg.getWidth() * 0.05)), topGuiY, lg.getHeight() * 0.08, lg.getHeight() * 0.08, color[10]):setFunction(function()
            self:showHelp()
        end),
        back = Button("<", lg.getWidth() - ((lg.getHeight() * 0.08) + (lg.getWidth() * 0.05)), topGuiY, lg.getHeight() * 0.08, lg.getHeight() * 0.08, color[16]):setFunction(function()
            self:hideHelp()
        end),
    }

    self.ui.exit:show()
    self.ui.help:show()

    self:reset()

    self.helpAnim = 0
    self.anim = 0

    self.inactiveTime = 0

    flux.to(self, config.window.animationScale * 5, {anim = 1})
end

function Game:reset()
    self.board = Board(4, 4)
    self.board:place(SAFE.x, SAFE.height * 0.35 + SAFE.y, SAFE.width, SAFE.width)
    if config.game.savedBoardState then
        self.board:loadState(config.game.savedBoardState)
        self.score = config.game.savedScore
    else
        self.board:randomize()
        self.score = 0
    end


    self.savedBoardState = false
    self.selectedCells = {}
    self.state = "game"

    
    -- Animations
    self.scoreText:move(false, SAFE.height * 0.25 + SAFE.y, 1)
    self.scoreTitle:move(false, SAFE.height * 0.21 + SAFE.y, 1.2)
    self.gameOverTitle:move(false, -SAFE.height + SAFE.y, 1)
    self.gameOverText:move(false, -SAFE.height + SAFE.y, 1)
    self.resetText:move(false, SAFE.height* 2 + SAFE.y, 1)
    self.helpText:move(false, -SAFE.height + SAFE.y, 1)
    self.helpTitle:move(false, -SAFE.height + SAFE.y, 1)

    self.ui.help:show()
    self.ui.exit:show()

    self.anim = 0
    flux.to(self, config.window.animationScale * 5, {anim = 1})

    later(function()
        self:unblockInput()
    end, 0.5)
end

function Game:showHelp()
    flux.to(self, config.window.animationScale, {helpAnim = 1})
    self.helpTitle:setText("You need some help, " .. util.randomLine("game/data/names.txt") .. "?")
    self.helpText:move(false, lg.getHeight() * 0.3, 1)
    self.helpTitle:move(false, lg.getHeight() * 0.13, 1)
    self.ui.back:show()
    self.ui.help:hide()
    self.ui.exit:hide()
end

function Game:hideHelp()
    flux.to(self, config.window.animationScale, {helpAnim = 0})
    self.helpText:move(false, -lg.getHeight(), 1)
    self.helpTitle:move(false, -lg.getHeight(), 1)
    self.ui.back:hide()
    self.ui.help:show()
    self.ui.exit:show()
end

function Game:blockInput()
    self.inputBlocked = true
end

function Game:unblockInput()
    self.inputBlocked = False
end
            -- self.board:hide()
            -- self.ui.help:hide()
            -- self.ui.exit:hide()
            -- self.scoreTitle:move(false, -SAFE.height, 1)
            -- self.scoreText:move(false, -SAFE.height, 1)
            -- flux.to(self, config.window.animationScale * 2, {anim = 0}):oncomplete(function()
            --     config.game.savedBoardState = self.board:saveState()
            --     config.game.savedScore = self.score
            --     Scene:loadScene(scene.Menu)
            -- end)

function Game:over()
    flux.to(self, config.window.animationScale * 5, {anim = 0})
    self:blockInput()
    later(function()
        self:unblockInput()
        self.resetText:move(false, lg.getHeight() * 0.9, 1)
    end, config.window.animationScale)
    self.state = "over"
    config.game.savedBoardState = false
    config.game.savedScore = 0
    saveConfig()
    util.save(config, "config.lua")
    later(function()
        -- self.board:deselectCells()
        self.board:hide()
        
        self.gameOverText:setText("You scored " .. util.comma(floor(self.score)) .. " points!")
        self.resetText:setText("Tap to reset, " .. util.randomLine("game/data/names.txt"))
        -- Animations
        self.scoreTitle:move(false, -SAFE.height, 1)
        self.scoreText:move(false, -SAFE.height, 1)
        self.helpText:move(false, -lg.getHeight(), 1)
        self.helpTitle:move(false, -lg.getHeight(), 1)
        self.gameOverTitle:move(false, lg.getHeight() * 0.2, 2)
        self.gameOverText:move(false, lg.getHeight() * 0.3, 1)
        self.ui.help:hide()
        self.ui.exit:hide()
        self.ui.back:hide()
    end, config.window.animationScale)
end

function Game:update(dt)
    self.board:update(dt)
    for _,flash in ipairs(self.flash) do
        flash:update(dt)
    end

    self.scoreText:setText(util.comma(floor(self.score)))
    self.inactiveTime = self.inactiveTime + dt

    if self.inactiveTime > config.window.hintTime then
        self.inactiveTime = 0 
        local a, b = self.board:findPair()
        if a and b then
            a:wobble()
            b:wobble()
        end
    end
end

function Game:draw()
    -- lg.setColor(lg.getBackgroundColor())
    -- lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())

    -- Score Background
    lg.setColor(color[util.offsetColorIndex(18)][1], color[util.offsetColorIndex(18)][2], color[util.offsetColorIndex(18)][3], 0.95)
    lg.rectangle("fill", -(SAFE.width * 0.1) * (1 - self.anim), SAFE.height * 0.21 + SAFE.y, SAFE.width * self.anim, SAFE.height * 0.11, SAFE.height * 0.01, SAFE.height * 0.01)

    lg.setColor(color[util.offsetColorIndex(1)][1], color[util.offsetColorIndex(1)][2], color[util.offsetColorIndex(1)][3], 0.95)
    lg.rectangle("line", -(SAFE.width * 0.1) * (1 - self.anim), SAFE.height * 0.21 + SAFE.y, SAFE.width * self.anim, SAFE.height * 0.11, SAFE.height * 0.01, SAFE.height * 0.01)

    lg.setColor(1, 1, 1, 1)
    self.board:draw()

    for _,flash in ipairs(self.flash) do
        flash:draw()
    end


    self.scoreTitle:draw()
    self.scoreText:draw()
    
    self.gameOverTitle:draw()
    self.gameOverText:draw()
    self.resetText:draw()

    local r, g, b = lg.getBackgroundColor()
    lg.setColor(r, g, b, self.helpAnim)
    lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
    self.helpText:draw()
    self.helpTitle:draw()

    for _,v in pairs(self.ui) do
        v:draw()
    end
end

function Game:resize(width, height)
    self.board:place(0, height * 0.3, width, width)
end

function Game:matchCells(a, b)
    local a = a or self.selectedCells[1]
    local b = b or self.selectedCells[2]
    local score = 0

    if a.type == "normal" then
        if a.value == b.value then
            score = (a.value + b.value)
            b:setValue(a.value + b.value, false)
            a:setValue(0, false)
        end
    elseif a.type == "clearRow" then
        if b.type == "clearColumn" then
            b:setSpecial("clearCross")  
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
            a:setValue(0, false)
        else
            local sum = 0
            if a.cellY ~= b.cellY then
                a:setValue(0)
                a:setSpecial("empty")
            end
            for x=1, self.board.columns do
                sum = sum + self.board.cell[b.cellY][x].value
                self.board.cell[b.cellY][x]:randomValue()
                later(function()
                    self.board.cell[b.cellY][x].flash:play()
                end, x * 0.1)
            end
            score = sum
        end

    elseif a.type == "clearColumn" then
        if b.type == "clearRow" then
            b:setSpecial("clearCross")  
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
            a:setValue(0, false)
        else
            local sum = 0
            if a.cellX ~= b.cellX then
                a:setValue(0, false)
            end
            for y=1, self.board.rows do
                sum = sum + self.board.cell[y][b.cellX].value
                self.board.cell[y][b.cellX]:randomValue()
                later(function()
                    self.board.cell[y][b.cellX].flash:play()
                end, y * 0.1)
            end
            score = sum
        end
    elseif a.type == "clearCross" then
        local sum = 0
        if a.cellX ~= b.cellX and a.cellY ~= b.cellY then
            a:setValue(0, false)
        end
        for y=1, self.board.rows do
            sum = sum + self.board.cell[y][b.cellX].value
            self.board.cell[y][b.cellX]:randomValue()
            later(function()
                self.board.cell[y][b.cellX].flash:play()
            end, y * 0.1)
        end

        for x=1, self.board.columns do
            sum = sum + self.board.cell[b.cellY][b.cellX].value
            self.board.cell[b.cellY][x]:randomValue()
            later(function()
                self.board.cell[b.cellY][x].flash:play()
            end, x * 0.1)
        end
        score = sum
    elseif a.type == "double" then
        if b.type == "normal" then
            b:setValue(b.value * 2)
            b.flash:play()
            score = b.value * 2
            a:setValue(0, false)
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
        elseif b.type == "double" then
            b:setSpecial("quadruple") 
            a:setValue(0, false)
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
        end
    elseif a.type == "quadruple" then
        if b.type == "normal" then
            b:setValue(b.value * 4)
            score = b.value * 2
            a:setValue(0, false)
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
        elseif b.type == "quadruple" then
            b:setSpecial("octuple") 
            a:setValue(0, false)
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
        end
    elseif a.type == "octuple" then
        if b.type == "normal" then
            b:setValue(b.value * 8)
            score = b.value * 2
            a:setValue(0, false)
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
        elseif b.type == "octuple" then
            b:setSpecial("sexdecuple") 
            a:setValue(0, false)
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
        end
    elseif a.type == "sexdecuple" then
        if b.type == "normal" then
            b:setValue(b.value * 32)
            score = b.value * 2
            a:setValue(0, false)
            later(function()
                b.flash:play()
            end, config.window.animationScale * 2)
        end
    end

    flux.to(self, 0.2 ,{score = self.score + score})

    later(function()
        self.board:deselectCells()
        self.selectedCells = {}
        self.board:checkRows()
        
        if not self.board:movesLeft() then
            self:over()
        end

    end, config.window.animationScale)
end

function Game:mousepressed(x, y, k)
    self.inactiveTime = 0

    for _,v in pairs(self.ui) do
        v:mousepressed(x, y)
    end

    if not self.inputBlocked and self.helpAnim < 1 then
        if self.state == "game" then
            self.board:mousepressed(x, y)
            self.selectedCells = self.board:getSelectedCells()

            if #self.selectedCells == 2 then
                self:matchCells()
            end
        elseif self.state == "over" then
            self:reset()
        end
    end

    -- self.flash[#self.flash+1] = Flash(x, y)
end

function Game:keypressed(key)
    if key == "space" then
        self:reset()
    elseif key == "q" then
        self:over()
    elseif key == "s" then
        self.board:findPair()
    elseif key == "m" then
       
    end


end

function Game:focus(f)
    if f then
        if self.savedBoardState then
            self.board:loadState(self.savedBoardState)
        end
        print("Gained focus")
    else
        self.savedBoardState = self.board:saveState()
        print("Lost focus")
    end
end

function Game:quit()
    print("Game quit")
    config.game.savedBoardState = self.board:saveState()
    config.game.savedScore = self.score
    config.game.startingScene = "Game"
end

return Game