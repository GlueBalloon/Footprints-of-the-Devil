
GridData = class()

function GridData:init(rows, columns)
    self.rows = rows
    self.columns = columns
    self.cells = {} -- Stores cell instances
    self.selectedR = nil
    self.selectedC = nil   
    self.units = {} -- Stores unit positions
    self.nextUnitId = 1 -- Initialize the next unit ID to 1
    -- Initialize the grid with empty cells and no units
    for r = 1, rows do
        for c = 1, columns do
            self.cells[self:coordToIndex(r, c)] = Cell()
        end
    end
end

function GridData:addUnit(r, c, icon, state)
    local unit = Unit(self.nextUnitId, icon, state)
    self:placeUnit(unit, r, c)
    self.nextUnitId = self.nextUnitId + 1
    return unit
end

function GridData:coordToIndex(row, column)
    return (row - 1) * self.columns + column
end

function GridData:placeUnit(unit, r, c)
    self:getCell(r, c):addContent(Content.UNIT, unit)
end

function GridData:moveUnit(fromR, fromC, toR, toC)
    local unit = self:getUnit(fromR, fromC)
    self:getCell(fromR, fromC):removeContent(Content.UNIT)
    self:getCell(toR, toC):addContent(Content.UNIT, unit)
end

function GridData:removeUnit(r, c)
    self:getCell(r, c):removeContent(Content.UNIT)
end

function GridData:getUnit(r, c)
    return self:getCell(r, c):getContent(Content.UNIT)
end

function GridData:getCell(r, c)
    return self.cells[self:coordToIndex(r, c)]
end
