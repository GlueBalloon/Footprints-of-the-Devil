MainMenu = class()

function MainMenu:init()
    self.options = {"Start New Game", "Load Saved Game"}
    self.selectedOption = 1
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
    -- Implement your logic for starting a new game here
end

function MainMenu:loadSavedGame()
    print("Loading a saved game...")
    -- Implement your logic for loading a saved game here
end
