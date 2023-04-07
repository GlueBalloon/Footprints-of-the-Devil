
-- Game
Game = class()

function Game:init()
    self.gameState = "inGame"
    local cellsPerSide = 12
    local sideSize = (math.min(WIDTH, HEIGHT)) * 0.8
    local mapX, mapY = 200, 20
    self.map = Map(mapX, mapY, sideSize, sideSize, cellsPerSide)
    local player1 = Player(1, "sapiens")
    local aiPlayer = AIPlayer(2, "neanderthal")
    self.players = {player1, aiPlayer}
    self.turnSystem = TurnSystem(self.players)
    self.unitManager = UnitManager(self.players)
    self.inGameUI = InGameUI(self.map)
    self.saveManager = SaveManager()
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
    self.inGameUI:draw(self.unitManager:getUnits())
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

function Game:unitContainsPoint(unit, x, y)
    local pointRow, pointCol = self.map:pointToCellRowAndColumn(x, y)
    local unitRow, unitCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    
    return pointRow == unitRow and pointCol == unitCol
end

function Game:saveGame(slot)
    local saveData = {
        map = self.map:serialize(),
        units = self.unitManager:serializeUnits(),
    }
    self.saveManager:save(slot, saveData)
end

function Game:loadGame(slot)
    local saveData = self.saveManager:load(slot)
    if saveData then
        self.map:deserialize(saveData.map)
        self.unitManager:deserializeUnits(saveData.units)
    end
end