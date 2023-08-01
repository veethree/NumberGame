local class = require "lib.class"

local board = class()

function board:init(rows, columns)
    self.cell = {}
    self.selectedCells = {}
    self.rows, self.columns = columns, rows
    
    for y=1, self.rows do
        self.cell[y] = {}
        for x=1, self.columns do
            self.cell[y][x] = false
        end
    end
    self.scale = 0
    flux.to(self, config.window.animationScale * 3, {scale = 1}):ease("backout")
end

function board:loadState(stateString)
    local state = assert(loadstring(stateString))()
    local i = 0
    for y=1, self.rows do
        for x=1, self.columns do
            i = i + 1
            local c = state[y][x]
            self.cell[y][x] = Cell(x, y, self, i)
            if tonumber(c) then
                self.cell[y][x]:setValue(c, true)
            else
                self.cell[y][x]:setSpecial(c)
            end
        end
    end
end

function board:saveState()
    local str = {"return {"}
    for y=1, self.rows do
        str[#str+1] = "{"
        for x=1, self.columns do
            local cell = self.cell[y][x]
            if cell.value < 0 then
                str[#str+1] = "'"
                str[#str+1] = cell.type 
                str[#str+1] = "'"
            else
                str[#str+1] = self.cell[y][x].value
            end
            str[#str+1] = ","
        end
        str[#str+1] = "},"
    end
    str[#str+1] = "}"

    return table.concat(str)
end

function board:map(func)
    for y=1, self.rows do
        for x=1, self.columns do
            local cell = self.cell[y][x]
            func(cell, x, y)
        end
    end
end

function board:randomize()
    local i = 0
    for y=1, self.rows do
        for x=1, self.columns do
            i = i + 1
            self.cell[y][x] = Cell(x, y, self, i):randomValue()
        end
    end
end

function board:place(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.cellWidth = (width / self.columns)
    self.cellHeight = (height / self.rows)
    self.placed = true
end

function board:hide()
    for y=self.rows, 1, -1 do
        for x=1, self.columns do
            self.cell[y][x]:hide()
        end
    end
    flux.to(self, config.window.animationScale * 2, {scale = 0})
end

function board:movesLeft()
    for y=1, self.rows do
        for x=1, self.columns do
            local a = self.cell[y][x]

            -- Skipping over empty cells
            if a.type == "empty" then goto continue end

            -- Returning true if special cell
            if a.type ~= "normal" then
                return true
            else
                for y=1, self.rows do
                    for x=1, self.columns do
                        local b = self.cell[y][x]
                        
                        -- Skipping over empty cells
                        if b.type == "empty" then goto continue end
                        
                        -- Making sure a and b aren't the same cells
                        if a ~= b then
                            if a.value == b.value then
                                return true
                            end
                        end
                        ::continue::
                    end
                end
            end

            ::continue::
        end
    end

    return false
end

function board:checkRows()
    local cellsToClear = {}
    for y=1, self.rows do
        local clear = true
        for x=1, self.columns do
            if self.cell[y][x].value > 0 or self.cell[y][x].value == -1 then
                clear = false
            end 
        end

        if clear then
            for x=1, self.rows do
                cellsToClear[#cellsToClear+1] = self.cell[y][x]
            end
        end
    end

    for x=1, self.columns do
        local clear = true
        for y=1, self.rows do
            if self.cell[y][x].value > 0 or self.cell[y][x].value == -1 then
                clear = false
            end
        end

        if clear then
            for y=1, self.columns do
                cellsToClear[#cellsToClear+1] = self.cell[y][x]
            end
        end
    end

    for i,v in ipairs(cellsToClear) do
        v:randomValue()
    end
end

function board:deselectCells()
    self:map(function(cell)
        cell:deselect()
    end)
    self.selectedCells = {}
end

function board:updateSelectedCells()
    local cells = {}
    self:map(function(cell, x, y)
        if cell.selected then
            cells[#cells+1] = cell
        end
    end)
end

function board:randomCell(recursion)
    local maxRecursion = 20
    recursion = recursion or 0
    if not self:movesLeft() then
        return false
    end

    if recursion > maxRecursion then
        return false
    end

    local x, y = random(self.columns), random(self.rows)
    local cell = self.cell[y][x]
    if cell.type == "empty" then
        self:randomCell(recursion + 1)
        return
    end

    return cell
end

function board:findPair(recursion)
    local maxRecursion = 20
    recursion = recursion or 0
    local a = self:randomCell()

    if a then
        for y=1, self.rows do
            for x=1, self.columns do
                local b = self.cell[y][x]
                if a ~= b and a.type == b.type and a.value == b.value then
                    return a, b
                end
            end
        end
    end

    if recursion < maxRecursion then
        self:findPair(recursion + 1)
    end
end

function board:forceColorUpdate()
    self:map(function(cell)
        cell:updateColor()
    end)
end

function board:getSelectedCells()
    return self.selectedCells
end

function board:mousepressed(x, y)
    if self.scale == 1 then
        self:map(function(cell, cellX, cellY)
            if maf.pointInRect(x, y, cell.x, cell.y, cell.width ,cell.height) then
                if cell.type ~= "empty" then
                    sound.tick:play()
                    if not cell.selected then
                        cell:select()
                        sound.rise:play()
                        table.insert(self.selectedCells, cell)
                    else
                        cell:deselect()
                        sound.fall:play()
                        for i,v in ipairs(self.selectedCells) do
                            if v == cell then
                                table.remove(self.selectedCells, i)
                            end
                        end
                    end
                end
            end
        end)
    end
end

function board:update(dt)
    if self.placed then
        self:map(function(cell, x, y)
            cell:update(dt)
        end)
    end
end

function board:draw()
    if self.placed then
        self.extra = SAFE.height * 0.01
        lg.setColor(color[util.offsetColorIndex(19)][1], color[util.offsetColorIndex(19)][2], color[util.offsetColorIndex(19)][3], 0.8)
        lg.rectangle("fill", self.x, self.y - (self.extra / 2), self.width, (self.height + (self.extra)) * self.scale, SAFE.height * 0.01 * self.scale, SAFE.height * 0.01 * self.scale)

        local colorIndex = util.offsetColorIndex(1)
        lg.setColor(color[colorIndex][1], color[colorIndex][2], color[colorIndex][3], self.scale)
        lg.setLineWidth(2)
        lg.rectangle("line", self.x, self.y - (self.extra / 2), self.width, (self.height + (self.extra)) * self.scale, SAFE.height * 0.01 * self.scale, SAFE.height * 0.01 * self.scale)

        self:map(function(cell, x, y)
            cell:draw()
        end)
    end
end

return board