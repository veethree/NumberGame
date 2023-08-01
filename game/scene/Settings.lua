local class = require "lib.class"
local settings = class()

function settings:init()

    self.title = Text("Settings", 0, -SAFE.height, font.huger, color[17])
    self.clearWarning = Text("This will also erase your savegame!", 0, -SAFE.height, font.small, color[16])

    self.enabledColor = color[10]
    self.disabledColor = color[16]

    self.ui = {
        Button("Toggle Music", 0, SAFE.y + SAFE.height * 0.3, SAFE.width * 0.5, SAFE.width * 0.1, color[util.offsetColorIndex(1)], font.small, true):setFunction(function()
            config.window.music = not config.window.music
            self:updateButtonColors()

            if config.window.music then
                currentSong:play()
            else
                currentSong:stop()
            end
        end),
        Button("Toggle Sound FX", 0, SAFE.y + SAFE.height * 0.4, SAFE.width * 0.5, SAFE.width * 0.1, color[util.offsetColorIndex(1)], font.small, true):setFunction(function()
            config.window.soundFX = not config.window.soundFX
            self:updateButtonColors()
        end),
        Button("Toggle Background", 0, SAFE.y + SAFE.height * 0.5, SAFE.width * 0.5, SAFE.width * 0.1, color[util.offsetColorIndex(1)], font.small, true):setFunction(function()
            config.window.background = not config.window.background
            self:updateButtonColors()
        end),
        Button("Clear Config", 0, SAFE.y + SAFE.height * 0.8, SAFE.width * 0.5, SAFE.width * 0.1, color[util.offsetColorIndex(16)], font.small, true):setFunction(function()
            config = util.deepcopy(defaultConfig)
            saveConfig()
            self.ui[4].text = "Cleared!"
            self:updateButtonColors()

            if config.window.music then
                currentSong:play()
            else
                currentSong:stop()
            end
        end),
        Button("back", 0, SAFE.y + SAFE.height * 0.9, SAFE.width * 0.5, SAFE.width * 0.1, color[util.offsetColorIndex(15)], font.small, true):setFunction(function()
            self:unload()

            saveConfig()

            later(function()
                Scene:loadScene(scene.Menu)
            end, config.window.animationScale)
        end),
    }

    self:updateButtonColors()

    for i,v in ipairs(self.ui) do
        v:centerHorizontal()
        v:show()
    end
    -- self.background = Background()

    self.anim = 0

    self:load()
end

function settings:updateButtonColors()
    if config.window.music then
        self.ui[1].color = self.enabledColor
    else
        self.ui[1].color = self.disabledColor
    end

    if config.window.soundFX then
        self.ui[2].color = self.enabledColor
    else
        self.ui[2].color = self.disabledColor
    end

    if config.window.background then
        self.ui[3].color = self.enabledColor
    else
        self.ui[3].color = self.disabledColor
    end
end

function settings:load()
    flux.to(self.title, config.window.animationScale * 2, {y = SAFE.y + (SAFE.height * 0.1)})
    flux.to(self.clearWarning, config.window.animationScale * 2, {y = SAFE.y + (SAFE.height * 0.86)})
    flux.to(self, config.window.animationScale, {anim = 1})
end

function settings:unload()
    for i,v in ipairs(self.ui) do
        v:hide()
    end
    flux.to(self.title, config.window.animationScale * 2, {y = -SAFE.height})
    flux.to(self.clearWarning, config.window.animationScale * 2, {y = -SAFE.height})
    flux.to(self, config.window.animationScale, {anim = 0})
end

function settings:update(dt)
    -- self.background:update(dt)

end

function settings:draw()
    self.title:draw()
    for i,v in ipairs(self.ui) do
        v:draw()
    end
    self.clearWarning:draw()
end

function settings:keypressed(key)
    if key == "space" then
        self:init()
    end
end

function settings:mousepressed(x, y, k)
    for i,v in ipairs(self.ui) do
        v:mousepressed(x, y, k)
    end
end

function settings:quit()
    config.game.startingScene = "Menu"
end

return settings