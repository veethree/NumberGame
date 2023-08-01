-- A default config file

return {
    window = {
        width = 500,
        height = 960,
        nativeWidth = 800,
        nativeHeight = 600,
        scale = 0.001,
        title = NAME .. " (" .. VERSION .. ")",
        animationScale = 0.2,
        shadowAlpha = 0.45,
        font = "monofonto_rg.otf",--small_pixel-7.ttf
        fontScale = 0.8,
        cellScale = 1.15,
        hintTime = 10,
        colorTheme = 1,
        colorPaletteSize = 20,
        settings = {
            fullscreen = false,
            resizable = false,
            vsync = true,
            msaa = 0,
            minwidth = 1,
            minheight = 1,
            fullscreentype = "exclusive",
        },
    },
    game = {
        savedBoardState = false,
        savedScore = 0,
        startingScene = "Menu",
    }
}