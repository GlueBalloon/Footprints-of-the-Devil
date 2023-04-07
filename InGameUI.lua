-- In-Game UI
InGameUI = class()

function InGameUI:init(map)
    self.map = map
    self.gridSize = map.gridSize
    self.cellSize = map.cellSize
    self.selectedUnit = nil
end

function InGameUI:draw(units)
    if self.selectedUnit then
        self:drawSelectedUnitInfo(self.selectedUnit)
        self:highlightAvailableMoves(self.selectedUnit)
    end
    
    for _, unit in ipairs(units) do
        self:drawUnit(unit)
    end
end

function InGameUI:drawUnit(unit)
    
    local row, column = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    
    if (not row) or (not column) then
        print("not row or column ", row, column, unit.x, unit.y)
        return
    end

    -- Calculate the x and y position of the cell
    local x = self.map.offsetX + (column - 1) * self.map.cellSize
    local y = self.map.offsetY + (row - 1) * self.map.cellSize
    
    -- Draw the background rectangle
    pushStyle()
    strokeWidth(self.map.cellSize * 0.1)
    local rectInset = self.map.cellSize * 0.05
    local rectSize = self.map.cellSize - rectInset
    local rectX = x + (rectInset / 2)
    local rectY = y + (rectInset / 2)
    -- Draw a colored rectangle based on unit type
    fill(unit.color)
    stroke(unit.color.r, unit.color.g, unit.color.b, 110)
    rect(rectX, rectY, rectSize, rectSize)
    
    -- Draw the unit sprite
    local spriteInset = self.map.cellSize * 0.2
    spriteMode(CORNER)
    local spriteSizeX = self.map.cellSize - spriteInset
    local spriteSizeY = spriteSizeX
    local spriteX = x + (spriteInset / 2)
    local spriteY = y + (spriteInset / 2)
    if unit.team == "neanderthal" then
        spriteX = spriteX + spriteSizeX
        spriteSizeX = spriteSizeX * -1
    end
    sprite(asset.builtin.SpaceCute.Beetle_Ship, spriteX, spriteY, spriteSizeX, spriteSizeY)
end

function InGameUI:highlightAvailableMoves(unit)
    local row, column = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    local adjacentCells = {
        {row = row - 1, col = column},
        {row = row + 1, col = column},
        {row = row, col = column - 1},
        {row = row, col = column + 1}
    }
    
    local inset = self.map.cellSize * 0.1
    for _, cell in ipairs(adjacentCells) do
        local x = self.map.offsetX + (cell.col - 1) * self.map.cellSize + inset
        local y = self.map.offsetY + (cell.row - 1) * self.map.cellSize + inset
        pushStyle()
        fill(unit.color.r, unit.color.g, unit.color.b, 96)
        rect(x, y, self.map.cellSize - (inset * 2), self.map.cellSize - (inset * 2))
        popStyle()
    end
end

function InGameUI:highlightAvailableMoves(unit)
    local row, column = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    local adjacentCells = {
        {row = row - 1, col = column},
        {row = row + 1, col = column},
        {row = row, col = column - 1},
        {row = row, col = column + 1}
    }
    
    local inset = self.map.cellSize * 0.1
    for _, cell in ipairs(adjacentCells) do
        -- Check if the cell coordinates are within the map grid bounds
        if cell.row >= 1 and cell.row <= self.map.gridSize and cell.col >= 1 and cell.col <= self.map.gridSize then
            local x = self.map.offsetX + (cell.col - 1) * self.map.cellSize + inset
            local y = self.map.offsetY + (cell.row - 1) * self.map.cellSize + inset
            pushStyle()
            fill(unit.color.r, unit.color.g, unit.color.b, 96)
            rect(x, y, self.map.cellSize - (inset * 2), self.map.cellSize - (inset * 2))
            popStyle()
        end
    end
end

function InGameUI:drawSelectedUnitInfo(unit)
    -- Draw the background square for the unit info
    pushStyle()
    fill(64, 64, 64, 200)
    rectMode(CORNER)
    local infoBoxWidth = 150
    local infoBoxHeight = 100
    rect(WIDTH - infoBoxWidth, HEIGHT - infoBoxHeight, infoBoxWidth, infoBoxHeight)
    popStyle()
    
    -- Draw the selected unit's info (health, attack, etc.) inside the square
    local textX, textY = WIDTH - infoBoxWidth + 10, HEIGHT - 20
    fill(255)
    text("Unit Team: " .. unit.team, textX, textY)
    text("Strength: " .. unit.strength, textX, textY - 20)
end

function InGameUI:isValidMove(unit, row, col)
    local currentRow, currentCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    local rowDelta = math.abs(row - currentRow)
    local colDelta = math.abs(col - currentCol)
    
    return (rowDelta == 1 and colDelta == 0) or (rowDelta == 0 and colDelta == 1)
end

function InGameUI:isValidMove(unit, row, col, units)
    local currentRow, currentCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    local rowDelta = math.abs(row - currentRow)
    local colDelta = math.abs(col - currentCol)
    
    local isAdjacent = (rowDelta == 1 and colDelta == 0) or (rowDelta == 0 and colDelta == 1)
    
    if not isAdjacent then
        return false
    end
    
    for _, otherUnit in ipairs(units) do
        local otherUnitRow, otherUnitCol = self.map:pointToCellRowAndColumn(otherUnit.x, otherUnit.y)
        if row == otherUnitRow and col == otherUnitCol then
            return false
        end
    end
    
    return true
end


function InGameUI:selectUnit(units, x, y)
    if not units then
        return
    end
    for _, unit in ipairs(units) do
        local unitX, unitY = unit.x, unit.y
        if x >= unitX and x <= unitX + 32 and y >= unitY and y <= unitY + 32 then
            self.selectedUnit = unit
            return
        end
    end
    self.selectedUnit = nil
end

function InGameUI:moveSelectedUnit(x, y)
    if self.selectedUnit then
        self.selectedUnit.x = x
        self.selectedUnit.y = y
    end
end


