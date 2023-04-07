-- Footprints Of The Devil

-- Main
function setup()    
    parameter.watch("selectedUnit")
    game = Game()
  --  game.unitManager:createUnit("sapiens", 5, 400, HEIGHT/2, color(143, 236, 67, 226))
  --  game.unitManager:createUnit("neanderthal", 7, WIDTH/2, 306, color(236, 67, 143, 222))
    game.turnSystem:startTurn()    
end

function draw()
    background(40, 40, 50)
    game:update()
    game:draw()
    selectedUnit = game.inGameUI.selectedUnit
end

function touched(touch)
    local units = game.unitManager.units
    if touch.state == BEGAN then
        local row, col = game.map:pointToCellRowAndColumn(touch.x, touch.y)
        if game.inGameUI.selectedUnit then
            local validMove = game.inGameUI:isValidMove(game.inGameUI.selectedUnit, row, col, units)
            if validMove then
                local unitX, unitY = game.map:cellRowAndColumnToPoint(row, col)
                game.inGameUI.selectedUnit.x, game.inGameUI.selectedUnit.y = unitX + game.map.cellSize / 2, unitY + game.map.cellSize / 2
                game.inGameUI.selectedUnit = nil
                
                game.turnSystem.moveCounter = game.turnSystem.moveCounter + 1
                
                local teamUnits = 0
                for _, unit in ipairs(units) do
                    if unit.team == game.turnSystem:getCurrentPlayer().team then
                        teamUnits = teamUnits + 1
                    end
                end
                
                if game.turnSystem.moveCounter >= teamUnits then
                    game.turnSystem:endTurn()
                end
            else
                -- Check if another unit of the same team is touched
                for _, unit in ipairs(units) do
                    if game:unitContainsPoint(unit, touch.x, touch.y) and unit.team == game.turnSystem:getCurrentPlayer().team then
                        game.inGameUI.selectedUnit = unit
                        break
                    end
                end
            end
        else
            for _, unit in ipairs(units) do
                if game:unitContainsPoint(unit, touch.x, touch.y) and unit.team == game.turnSystem:getCurrentPlayer().team then
                    game.inGameUI.selectedUnit = unit
                    break
                end
            end
        end
    end
end