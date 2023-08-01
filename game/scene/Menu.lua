local class = require "lib.class"
local Menu = class()

function Menu:init()
    self.logo = Image(image.logo, 0, -SAFE.height, SAFE.width * 0.0009):centerHorizontal()
    flux.to(self.logo, config.window.animationScale * 4, {y = SAFE.y + (SAFE.height * 0.01)})

    self.version = Text("v" .. VERSION, 0, -lg.getHeight(), font.small, color[16], "right")
    flux.to(self.version, config.window.animationScale * 4.2, {y = SAFE.y + (SAFE.height * 0.07)})

    self.greeting = Text(util.randomLine("game/data/greetings.txt"), 0, -lg.getHeight(), font.medium, color[20], "center")
    flux.to(self.greeting, config.window.animationScale * 3.8, {y = SAFE.y + (SAFE.height * 0.39)})

    local topGuiY = lg.getHeight() * 0.02 + SAFE.y
    self.ui = {
        Button("Play", 0, lg.getHeight() * 0.5, lg.getWidth() * 0.8, lg.getHeight() * 0.1, color[util.offsetColorIndex(1)]):setFunction(function()

            flux.to(self.logo, config.window.animationScale * 4, {y = -SAFE.height})
            flux.to(self.version, config.window.animationScale * 4, {y = -SAFE.height})
            flux.to(self.greeting, config.window.animationScale * 4, {y = -SAFE.height})
            flux.to(self, config.window.animationScale, {anim = 0})

            for i,v in ipairs(self.ui) do
                v:hide()
            end


            later(function()
                Scene:loadScene(scene.Game)
            end, config.window.animationScale)
        end),
        Button("Exit", 0, lg.getHeight() * 0.65, lg.getWidth() * 0.8, lg.getHeight() * 0.1, color[util.offsetColorIndex(16)]):setFunction(function()
            love.event.push("quit")
        end),
        Button("Clear Savegame", 0, SAFE.y + SAFE.height * 0.9, SAFE.width * 0.5, SAFE.width * 0.1, color[util.offsetColorIndex(15)], font.small, true):setFunction(function()
            config = defaultConfig
            util.save(config, "config.lua")
        end),

        -- Button("!", lg.getWidth() - ((lg.getHeight() * 0.08) + (lg.getWidth() * 0.05)), topGuiY, lg.getHeight() * 0.08, lg.getHeight() * 0.08, color[10]):setFunction(function()
        --     self:showCredits()
        -- end),

        -- Button("Theme", SAFE.width * 0.05, SAFE.y + SAFE.height * 0.03, SAFE.width * 0.15, SAFE.width * 0.1, color[util.offsetColorIndex(20)], font.small, true):setFunction(function()
        --     config.window.colorTheme = config.window.colorTheme + 1
        --     if config.window.colorTheme > 3 then
        --         config.window.colorTheme = 1
        --     end

        --     self.board:forceColorUpdate()
        --     background:forceColorUpdate()
        -- end),
        -- Button("Exit", 0, lg.getHeight() * 0.8, lg.getWidth() * 0.8, lg.getHeight() * 0.1, color[titleColor])
    }
    
    self.ui[1]:centerHorizontal()
    self.ui[2]:centerHorizontal()
    self.ui[3]:centerHorizontal()

    for i,v in ipairs(self.ui) do
        v:show()
    end

    self.board = Board(4, 8)
    self.board:place(0, 0, lg.getWidth(), lg.getHeight())
    self.board:randomize()

    -- self.background = Background()

    self.anim = 0
    self.titleSway = SAFE.height * 0.05

    self.time = 0

    self:load()
end

function Menu:load()
    self.titleAPosition = lg.getHeight() * 0.1
    self.titleBPosition = lg.getHeight() * 0.2

    -- self.titleA:move(false, self.titleAPosition, 1.4)
    -- self.titleB:move(false, self.titleBPosition, 1)

    flux.to(self, config.window.animationScale, {anim = 1})
end

function Menu:update(dt)
    -- self.background:update(dt)

end

function Menu:draw()
    self.logo:draw()
    self.version:draw()
    self.greeting:draw()
    for i,v in ipairs(self.ui) do
        v:draw()
    end
end

function Menu:keypressed(key)
    if key == "space" then
        self:init()
    end
end

function Menu:mousepressed(x, y, k)
    for i,v in ipairs(self.ui) do
        v:mousepressed(x, y, k)
    end
end

function Menu:quit()
    config.game.startingScene = "Menu"
end

return Menu