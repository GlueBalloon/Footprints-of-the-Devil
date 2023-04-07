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
    end
    
    for _, unit in ipairs(units) do
        self:drawUnit(unit)
    end
end

function InGameUI:drawUnit(unit)
    
    local row, column = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    
    if (not row) or (not column) then
        print(unit.x)
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
    if unit.team == "sapiens" then
        fill(143, 236, 67, 226)
        stroke(92, 159, 38, 150)
    elseif unit.team == "neanderthal" then
        fill(236, 67, 143, 222)
        stroke(146, 40, 88, 169)
    end
    rect(rectX, rectY, rectSize, rectSize)
    
    -- Draw the unit sprite
    local spriteInset = self.map.cellSize * 0.2
    spriteMode(CORNER)
    local spriteSize = self.map.cellSize - spriteInset
    local spriteX = x + (spriteInset / 2)
    local spriteY = y + (spriteInset / 2)
    sprite(asset.builtin.SpaceCute.Beetle_Ship, spriteX, spriteY, spriteSize, spriteSize)
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
