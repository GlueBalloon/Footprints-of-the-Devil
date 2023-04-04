-- Footprints Of The Devil

-- Main
function setup()
    game = Game()
    
    -- Create players
    local player1 = {id = 1}
    local aiPlayer = AIPlayer(2)
    
    -- Initialize the turn system
    local turnSystem = TurnSystem({player1, aiPlayer})
    
    -- Add this to your setup function:
    inGameUI = InGameUI()
    
    -- Add this to your setup function:
    unitManager = UnitManager()
    
    -- Create some example units (you can replace this with your own unit creation logic)
    unitManager:createUnit("Infantry", 5, 5, 10, 3, 1)
    unitManager:createUnit("Tank", 10, 10, 20, 5, 2)
    
    -- Start the first turn
    turnSystem:startTurn()
    
end

function draw()
    background(40, 40, 50)
    game:update()
    game:draw()
    inGameUI:draw(unitManager:getUnits())
end

function touched(touch)
    local units = unitManager:getUnits()
    if touch.state == BEGAN then
        if inGameUI.selectedUnit then
            inGameUI:moveSelectedUnit(touch.x, touch.y)
            inGameUI.selectedUnit = nil
        else
            for _, unit in ipairs(units) do
                local unitX, unitY = unit.x * 32, unit.y * 32
                if touch.x >= unitX and touch.x <= unitX + 32 and touch.y >= unitY and touch.y <= unitY + 32 then
                    inGameUI:selectUnit(units, unit.x, unit.y)
                    break
                end
            end
        end
    end
end


-- Game
Game = class()

function Game:init()
    self.gameState = "mainMenu"
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

-- Map
Map = class()

function Map:init()
    self.terrain = {}
    self.units = {}
end

function Map:update()
    -- Update units and other map elements here
end

function Map:draw()
    -- Draw terrain, units, and other map elements here
end

AIPlayer = class()

function AIPlayer:init(id)
    self.id = id
end

function AIPlayer:takeTurn(units, map)
    -- Implement your AI logic here
    for _, unit in ipairs(units) do
        if unit.owner == self.id then
            self:moveUnit(unit, map)
            self:attackEnemy(unit, units)
        end
    end
end

function AIPlayer:moveUnit(unit, map)
    -- Basic move logic: Move towards the closest enemy unit
    local target = self:findClosestEnemy(unit, map.units)
    if target then
        local dx = target.x - unit.x
        local dy = target.y - unit.y
        local moveX = dx > 0 and 1 or -1
        local moveY = dy > 0 and 1 or -1
        unit.x = unit.x + moveX
        unit.y = unit.y + moveY
    end
end

function AIPlayer:attackEnemy(unit, units)
    -- Basic attack logic: Attack adjacent enemy units
    for _, target in ipairs(units) do
        if target.owner ~= self.id then
            local distX = math.abs(unit.x - target.x)
            local distY = math.abs(unit.y - target.y)
            if distX <= 1 and distY <= 1 then
                print("AI unit attacks enemy unit")
                -- Implement attack logic here
            end
        end
    end
end

function AIPlayer:findClosestEnemy(unit, units)
    local closestEnemy = nil
    local minDist = math.huge
    for _, target in ipairs(units) do
        if target.owner ~= self.id then
            local dist = math.sqrt((unit.x - target.x) ^ 2 + (unit.y - target.y) ^ 2)
            if dist < minDist then
                minDist = dist
                closestEnemy = target
            end
        end
    end
    return closestEnemy
end

