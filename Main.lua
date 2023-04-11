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
    game:touchInput(touch)
end