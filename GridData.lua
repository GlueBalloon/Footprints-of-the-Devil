
GridData = class()

function GridData:init(rows, columns)
    self.rows = rows
    self.columns = columns
    self.cells = {} -- Stores cell instances
    self.selectedR = nil
    self.selectedC = nil   
    self.units = {} -- Stores unit positions
    self.nextUnitId = 1 -- Initialize the next unit ID to 1

    for r = 1, rows do
        local row = {}
        for c = 1, columns do
            row[c] = Cell()
        end
        self.cells[r] = row
    end
end

function GridData:getCell(r, c)
    return self.cells[r][c]
end

function GridData:addNewUnitUsing(icon, state, r, c)
    local unit = Unit(self.nextUnitId, icon, state)
    self:placeUnit(unit, r, c)
    self.nextUnitId = self.nextUnitId + 1
    return unit
end

function GridData:coordToIndex(row, col)
    if not row or not col then
        return nil
    end
    return (row - 1) * self.columns + col
end

function GridData:placeUnitData(unit, r, c)
    local cell = self:getCell(r, c)
    cell:addContent(Content.UNIT, unit)
end

function GridData:removeUnitData(r, c)
    self:getCell(r, c):removeContent(Content.UNIT)
end

function GridData:getUnit(r, c)
    return self:getCell(r, c):getContent(Content.UNIT)
end

function GridData:moveUnit(fromR, fromC, toR, toC)
    local unit = self:getUnit(fromR, fromC)
    self:getCell(fromR, fromC):removeContent(Content.UNIT)
    self:getCell(toR, toC):addContent(Content.UNIT, unit)
end
