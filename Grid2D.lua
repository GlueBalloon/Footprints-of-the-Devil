Grid2D = class()

function Grid2D:init(gridData, cellSize)
    self.gridData = gridData
    self.cellSize = cellSize
    self.currentTouchX = nil
    self.currentTouchY = nil
    
    -- Calculate offsets to center the grid
    self.offsetX = (WIDTH - gridData.columns * cellSize) / 2
    self.offsetY = (HEIGHT - gridData.rows * cellSize) / 2
    
    self.selectionColor = color(255, 255, 0, 100)
    self.cellColor = color(255)
end

--[[
function Grid2D:draw()
    pushStyle()
    rectMode(CENTER)
    for c = 1, self.gridData.rows do
        for r = 1, self.gridData.columns do
            local x = (c - 1) * self.cellSize + self.offsetX
            local y = (self.gridData.rows - r) * self.cellSize + self.offsetY          
           
            -- Draw the cell background
            fill(200, 200, 200)
            rect(x + self.cellSize / 2, y + self.cellSize / 2, self.cellSize, self.cellSize)
            
            local cell = self.gridData:getCell(r, c)
            local unit = cell:getContent(Cell.contentTypes.UNIT)
            if unit then
                textMode(CENTER)
                fill(0, 98, 255)
                text(unit.icon, c * self.cellSize, r * self.cellSize)
            end
        end
    end
    
    -- Draw the selected cell highlight
    if self.gridData.selectedR and self.gridData.selectedC then
        print("Selected cell: R=" .. self.gridData.selectedR .. ", C=" .. self.gridData.selectedC) -- Add this line to print the selected cell coordinates
        local x = (self.gridData.selectedC - 1) * self.cellSize + self.offsetX
        local y = (self.gridData.selectedR - 1) * self.cellSize + self.offsetY
        fill(255, 255, 0, 100)
        rect(x + self.cellSize / 2, y + self.cellSize / 2, self.cellSize, self.cellSize)
    else
        print("No cell selected") -- Add this line to print when no cell is selected
    end

    popStyle()
end

]]
function Grid2D:draw()
    pushMatrix()
    pushStyle()
    
    translate(self.offsetX, self.offsetY)
    
    -- Draw cells
    for r = 1, self.gridData.rows do
        for c = 1, self.gridData.columns do
            local x = (c - 1) * self.cellSize
            local y = (self.gridData.rows - r) * self.cellSize
            
            fill(self.cellColor)
            rect(x, y, self.cellSize, self.cellSize)
            
            if self.gridData.selectedR == r and self.gridData.selectedC == c then
                fill(self.selectionColor)
                rect(x, y, self.cellSize, self.cellSize)
            end

            local cell = self.gridData:getCell(r, c)
            local unit = cell:getContent(Content.UNIT)
            if unit then
                local halfCell = self.cellSize * 0.5
                textMode(CENTER)
                fill(172, 192, 223)
                rect(x + 3, y + 3, self.cellSize - 6)
                sprite(unit.icon, x + halfCell, y + halfCell, self.cellSize - 1, self.cellSize - 1)
                text(unit.id, x, y)
            end
        end
    end
    
    popStyle()
    popMatrix()
end

function Grid2D:touchToPoint(touch)
    local adjustedX = touch.x - self.offsetX
    local adjustedY = touch.y - self.offsetY
    
    local c = math.floor(adjustedX / self.cellSize) + 1
    local r = self.gridData.rows - math.floor(adjustedY / self.cellSize)
    
    -- Ensure the calculated row and column are within grid bounds
    if adjustedX >= 0 and adjustedX <= self.gridData.columns * self.cellSize and
    adjustedY >= 0 and adjustedY <= self.gridData.rows * self.cellSize then
        --print("Selected cell: R=" .. r .. ", C=" .. c) -- Add this line to print the selected cell coordinates
        return r, c
    else
        return nil, nil
    end
end

function Grid2D:touched(touch)
    if touch.state == BEGAN then
        grid2D:touchBegan(touch)
    elseif touch.state == CHANGED then
        grid2D:touchMoved(touch)
    elseif touch.state == ENDED or touch.state == CANCELLED then
        grid2D:touchEnded(touch)
    end
end

function Grid2D:touchBegan(touch)
    local r, c = self:touchToPoint(touch)
    self.gridData.selectedR = r
    self.gridData.selectedC = c
end



function Grid2D:touchMoved(touch)
    if self.gridData.selectedR and self.gridData.selectedC then
        self.currentTouchX = touch.x
        self.currentTouchY = touch.y
    end
end

function Grid2D:touchEnded(touch)
    if self.gridData.selectedR and self.gridData.selectedC then
        local r, c = self:touchToPoint(touch)
        self.gridData:moveUnit(self.gridData.selectedR, self.gridData.selectedC, r, c)
    end
end
