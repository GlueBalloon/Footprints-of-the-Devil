AIPlayer = class()

function AIPlayer:init(id, team, teamColor, logicModule, queries)
    self.id = id
    self.team = team
    self.teamColor = teamColor
    self.logicModule = logicModule
    self.queries = queries
    self.aiActionTime = nil
end

function AIPlayer:decideAction()
    self.logicModule:decideAction(self.queries)
end

SimpleLogicModule = class()

function SimpleLogicModule:init()
    self.shuffle = function(aTable)
        local n = #aTable
        for i = n, 2, -1 do
            local j = math.random(i)
            aTable[i], aTable[j] = aTable[j], aTable[i]
        end
        return aTable
    end
end

function SimpleLogicModule:decideAction(queries)
    local actionTaken = false
    local units = queries:getUnits()
    local currentPlayerTeam = queries:getCurrentPlayer().team
    
    -- Get the player's units
    local playerUnits = {}
    for _, unit in ipairs(units) do
        if unit.team == currentPlayerTeam then
            table.insert(playerUnits, unit)
        end
    end
    
    local shuffledUnits = self.shuffle(playerUnits)
    
    for _, unit in ipairs(shuffledUnits) do
        local row, col = queries:getRowAndColumnFor(unit)
        local neighbors = queries:orthogonalCellsFor(row, col)
        local moveTargets = {}
        local attackTargets = {}
        
        for _, neighbor in ipairs(neighbors) do
            local target = queries:getUnitAt(neighbor.row, neighbor.col)
            if not target then
                table.insert(moveTargets, neighbor)
            elseif target.team ~= unit.team then
                table.insert(attackTargets, target)
            end
        end
        
        if #attackTargets > 0 and math.random() > 0.5 then
            -- Attack a random adjacent enemy unit.
            local target = attackTargets[math.random(1, #attackTargets)]
            queries:attack(unit, target)
            actionTaken = true
        elseif #moveTargets > 0 then
            -- Move the unit to a random empty adjacent cell.
            local newPosition = moveTargets[math.random(1, #moveTargets)]
            queries:moveUnit(unit, newPosition.row, newPosition.col)
            actionTaken = true
        end
            
            -- If an action was taken, stop iterating through units
            if actionTaken then
                break
        end
    end
    
    return actionTaken
end

