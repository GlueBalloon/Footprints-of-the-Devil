GridIO = class()

function GridIO:init(gridData, cellSize)
    -- Capture parameters
    self.gridData = gridData
    self.cellSize = cellSize
    
    -- Setup grid
    self:setupGrid()
    
    -- Initialize other variables
    self.draggingUnit = nil
    self.originalUnitPosition = nil
end

function GridIO:setupGrid()
    -- This function should be overridden in subclasses
end

function GridIO:selectedCoords()
    if self.gridData.selectedR and self.gridData.selectedC then
        return self.gridData.selectedR, self.gridData.selectedC
    else
        return nil
    end
end


function GridIO:updateSelectionVisuals(r, c)
    if not r or not c then
        return
    end
    if self.clearSelectedCellEffect then
        self:clearSelectedCellEffect()
    end
    if self.applySelectedCellEffect then
        self:applySelectedCellEffect(r, c)
    end
end

function GridIO:touched(touch)
    if touch.state == BEGAN then
        self:touchBegan(touch)
    elseif touch.state == CHANGED then
        self:touchChanged(touch)
    elseif touch.state == ENDED or touch.state == CANCELLED then
        self:touchEnded(touch)
    end
end

function GridIO:touchBegan(touch)
    self:changeSelectedCell(touch)
end

function GridIO:touchChanged(touch)
end

function GridIO:touchEnded(touch)
end

function GridIO:changeSelectedCell(touch)
    local r, c = self:pointToRowAndColumn(vec2(touch.x, touch.y))
    if r and c then
        self.gridData.selectedR = r
        self.gridData.selectedC = c
    end
end

function GridIO:pointToRowAndColumn(point)
    -- This function should be overridden in subclasses (Grid2D and Grid3D)
end