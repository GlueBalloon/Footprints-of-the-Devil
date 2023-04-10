-- Footprints Of The Devil

-- Main
function setup()    
    parameter.watch("countdown")
    parameter.watch("selectedUnit")
    game = Game()
    --  game.unitManager:createUnit("sapiens", 5, 400, HEIGHT/2, color(143, 236, 67, 226))
    --  game.unitManager:createUnit("neanderthal", 7, WIDTH/2, 306, color(236, 67, 143, 222))
    --  game.turnSystem:nextTurn()    
end

function draw()
    background(40, 40, 50)
    game:draw(DeltaTime)
    selectedUnit = game.inGameUI.selectedUnit
    countdown = game.turnSystem.timeRemaining
end

function touched(touch)
    if game.turnSystem.turnChangeAnimationInProgress then
        game.inGameUI.selectedUnit = nil
        return
    end
    game.inGameUI:touched(touch)
    local units = game.unitManager.units
    if touch.state == BEGAN then
        local row, col = game.map:pointToCellRowAndColumn(touch.x, touch.y)
        if game.inGameUI.selectedUnit and row and col then
            local validMove = game.inGameUI:isValidMove(game.inGameUI.selectedUnit, row, col, units)
            if validMove then
                local moveCommand = MoveCommand(game, game.inGameUI.selectedUnit, row, col)
                game.invoker:executeCommand(moveCommand)
                
                -- Check for attackable units after a unit has moved
                for _, unit in ipairs(units) do
                    if game.inGameUI:isAttackable(game.inGameUI.selectedUnit, unit) then
                        game.inGameUI:drawCrosshairsOn(unit)
                    else
                        game.inGameUI.crosshairTweens[unit] = nil
                    end 
                end
                
                game.turnSystem.moveCounter = game.turnSystem.moveCounter + 1
                
                local teamUnits = 0
                for _, unit in ipairs(units) do
                    if unit.team == game.turnSystem:getCurrentPlayer().team then
                        teamUnits = teamUnits + 1
                    end
                end
                
                if game.turnSystem.moveCounter >= game.turnSystem.movesPerTurn then
                    game.turnSystem:nextTurn()
                end
            else
                -- Check if another unit of the same team is touched
                for _, unit in ipairs(units) do
                    if game:unitContainsPoint(unit, touch.x, touch.y) then
                        if unit.team == game.turnSystem:getCurrentPlayer().team then
                            game.inGameUI.selectedUnit = unit
                        elseif game.inGameUI:isAttackable(game.inGameUI.selectedUnit, unit) then
                            local attackCommand = AttackCommand(game, game.inGameUI.selectedUnit, unit)
                            game.invoker:executeCommand(attackCommand)
                        end
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
