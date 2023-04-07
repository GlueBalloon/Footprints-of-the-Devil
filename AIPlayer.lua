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

