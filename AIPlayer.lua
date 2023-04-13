AIPlayer = class()

function AIPlayer:init(id, team, teamColor, queries)
    self.id = id
    self.team = team
    self.teamColor = teamColor
    self.queries = queries
end

function AIPlayer:takeTurn()
    print("AIPlayer:takeTurn()")
    local queries = self.queries
    local units = queries:getUnits()
    print("queries:getUnits() ", units)
    for i, unit in ipairs(units) do
        if unit.team == queries:getCurrentPlayer().team then
            local row, col = queries:getRowAndColumnFor(unit)
            local neighbors = queries:orthogonalCellsFor(row, col)
            local moveTargets = {}
            local attackTargets = {}
            
            for _, neighbor in ipairs(neighbors) do
                if neighbor.row and neighbor.col then
                    local target = queries:getUnitAt(neighbor.row, neighbor.col)
                    if not target then
                        table.insert(moveTargets, neighbor)
                    elseif target.team ~= unit.team then
                        table.insert(attackTargets, target)
                    end 
                end
            end
            
            if #attackTargets > 0 then
                -- Attack a random adjacent enemy unit.
                local target = attackTargets[math.random(1, #attackTargets)]
                queries:attackUnit(unit, target)
            elseif #moveTargets > 0 then
                -- Move the unit to a random empty adjacent cell.
                local newPosition = moveTargets[math.random(1, #moveTargets)]
                queries:moveUnit(unit, newPosition.row, newPosition.col)
            end
            break
        end
    end
end
