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
    local units = game.unitManager:getUnits()
    if touch.state == BEGAN then
        local row, col = game.map:pointToCellRowAndColumn(touch.x, touch.y)
        if game.inGameUI.selectedUnit then
            local validMove = game.inGameUI:isValidMove(game.inGameUI.selectedUnit, row, col)
           -- print("validMove", validMove)
            if validMove then
                local unitX, unitY = game.map.offsetX + (col - 1) * game.map.cellSize, game.map.offsetY + (row - 1) * game.map.cellSize
                game.inGameUI.selectedUnit.x, game.inGameUI.selectedUnit.y = unitX, unitY
                game.inGameUI.selectedUnit = nil
                game.turnSystem:endTurn()
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


function touched(touch)
    local units = game.unitManager:getUnits()
    if touch.state == BEGAN then
        local row, col = game.map:pointToCellRowAndColumn(touch.x, touch.y)
        if game.inGameUI.selectedUnit then
            local validMove = game.inGameUI:isValidMove(game.inGameUI.selectedUnit, row, col, game.unitManager.units)
         --   print("validMove", validMove)
            if validMove then
                local unitX, unitY = game.map:cellRowAndColumnToPoint(row, col)
                game.inGameUI.selectedUnit.x, game.inGameUI.selectedUnit.y = unitX + game.map.cellSize / 2, unitY + game.map.cellSize / 2
                game.inGameUI.selectedUnit = nil
                game.turnSystem:endTurn()
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
