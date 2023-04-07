-- Footprints Of The Devil

-- Main
function setup()
    
    parameter.watch("selectedUnit")
    game = Game()
    
    -- Create players
    local player1 = {id = 1}
    local aiPlayer = AIPlayer(2)
    
    -- Initialize the turn system
    local turnSystem = TurnSystem({player1, aiPlayer})
    
    -- Add this to your setup function:
    inGameUI = InGameUI(game.map)
    
    -- Add this to your setup function:
    unitManager = UnitManager()
    
    -- Create some example units (you can replace this with your own unit creation logic)
    unitManager:createUnit("sapiens", 5, 400, HEIGHT/2)
    unitManager:createUnit("neanderthal", 7, WIDTH/2, 306)
    
    -- Start the first turn
    turnSystem:startTurn()
    
end

function draw()
    background(40, 40, 50)
    game:update()
    game:draw()
    inGameUI:draw(unitManager:getUnits())
    selectedUnit = inGameUI.selectedUnit
end



function touched(touch)
    local units = unitManager:getUnits()
    if touch.state == BEGAN then
        local row, col = game.map:pointToCellRowAndColumn(touch.x, touch.y)
        if inGameUI.selectedUnit then
            local unitX, unitY = game.map.offsetX + (col - 1) * game.map.cellSize, game.map.offsetY + (row - 1) * game.map.cellSize
            inGameUI:moveSelectedUnit(unitX, unitY)
            inGameUI.selectedUnit = nil
        else
            for _, unit in ipairs(units) do
                local unitRow, unitCol = game.map:pointToCellRowAndColumn(unit.x, unit.y)
                if row == unitRow and col == unitCol then
                    inGameUI:selectUnit(units, unit.x, unit.y)
                    break
                end
            end
        end
    end
end
