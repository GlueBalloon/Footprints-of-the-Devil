MainMenu = class()

function MainMenu:init()
    self.options = {"Start New Game", "Load Saved Game"}
    self.selectedOption = 1
    self.saveManager = SaveManager()
end

function MainMenu:draw()
    background(40, 40, 40)
    textAlign(CENTER)
    textMode(CORNER)
    
    for i, option in ipairs(self.options) do
        if i == self.selectedOption then
            fill(255, 255, 0)
        else
            fill(255)
        end
        text(option, WIDTH / 2, HEIGHT / 2 + (i * 50))
    end
end

function MainMenu:touched(touch)
    if touch.state == ENDED then
        if touch.y > HEIGHT / 2 and touch.y < HEIGHT / 2 + 50 then
            self:startNewGame()
        elseif touch.y > HEIGHT / 2 + 50 and touch.y < HEIGHT / 2 + 100 then
            self:loadSavedGame()
        end
    end
end

function MainMenu:startNewGame()
    print("Starting a new game...")
    -- Save the current game state before starting a new game
    local gameData = game:serialize()
    saveManager:saveGame(gameData)
    -- Implement your logic for starting a new game here
end

function MainMenu:loadSavedGame()
    print("Loading a saved game...")
    local gameData = saveManager:loadGame()
    if gameData then
        game:deserialize(gameData)
    end
end
