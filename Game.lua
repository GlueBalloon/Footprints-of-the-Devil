
-- Game
Game = class()

function Game:init()
    self.gameState = "inGame"
    self.map = Map()
end

function Game:update()
    if self.gameState == "inGame" then
        self.map:update()
    end
end

function Game:draw()
    if self.gameState == "inGame" then
        self.map:draw()
    end
end

function Game:serialize()
    -- Convert the game state to a string
    -- You can use a simple format, such as comma-separated values, or use a library to encode the data in JSON or another format
    local serializedData = "gameState=" .. self.gameState
    return serializedData
end

function Game:deserialize(gameData)
    -- Load the game state from a string
    -- You will need to parse the data and update the game state accordingly
    for key, value in string.gmatch(gameData, "(%w+)=(%w+)") do
        if key == "gameState" then
            self.gameState = value
        end
    end
end

function Game:saveGame(slot)
    local saveData = {
        map = self.map:serialize(),
        units = unitManager:serializeUnits(),
    }
    saveManager:save(slot, saveData)
end

function Game:loadGame(slot)
    local saveData = saveManager:load(slot)
    if saveData then
        self.map:deserialize(saveData.map)
        unitManager:deserializeUnits(saveData.units)
    end
end