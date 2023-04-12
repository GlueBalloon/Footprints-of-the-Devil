AIPlayer = class()

function AIPlayer:init(team, teamColor, queries)
    self.team = team
    self.teamColor = teamColor
    self.queries = queries
end

AIPlayer = class()

function AIPlayer:init(team, teamColor, queries)
    self.team = team
    self.teamColor = teamColor
    self.queries = queries
end

function AIPlayer:takeTurn()
    local units = self.queries:getUnits()
    local teamUnits = {}
    
    for _, unit in ipairs(units) do
        if unit.playerTeam == self.team then
            table.insert(teamUnits, unit)
        end
    end
    
    if #teamUnits == 0 then return end
    
    local unitToAct = teamUnits[math.random(#teamUnits)]
    
    local action = math.random(2) -- 1 for move, 2 for attack
    local row, col = unitToAct.row, unitToAct.col
    
    if action == 1 then
        local newRow, newCol = row + math.random(-1, 1), col + math.random(-1, 1)
        self.queries:moveUnit(unitToAct, newRow, newCol)
    else
        local target = self.queries:getUnitAt(row + math.random(-1, 1), col + math.random(-1, 1))
        
        if target and target.playerTeam ~= self.team then
            self.queries:attackUnit(unitToAct, target)
        end
    end
end
