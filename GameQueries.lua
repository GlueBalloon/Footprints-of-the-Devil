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

function GameQueries:getPlayerByTeam(team)
end

function GameQueries:moveUnit(unit, row, col)
end

function GameQueries:attackUnit(attacker, target)
end

function GameQueries:orthogonalCellsFor(row, col)
end