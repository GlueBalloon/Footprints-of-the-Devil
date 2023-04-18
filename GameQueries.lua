GameQueries = class()

function GameQueries:init()
    self.class = "GameQueries"
end

function GameQueries:getUnits()
end

function GameQueries:getRowAndColumnFor(unit)
end

function GameQueries:getUnitAt(row, col)
end

function GameQueries:getCurrentPlayer()
end

function GameQueries:getTeams(units)
end

function GameQueries:moveUnit(unit, row, col)
end

function GameQueries:attack(attacker, target)
end

function GameQueries:orthogonalCellsFor(row, col)
end

function GameQueries:endTurn()
end

function GameQueries:isFlanked(unit)
end

function GameQueries:attackableUnits(selectedUnit, units)
end
