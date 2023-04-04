-- Unit Class
Unit = class()

function Unit:init(type, x, y, health, attack, defense)
    self.type = type
    self.x = x
    self.y = y
    self.health = health
    self.attack = attack
    self.defense = defense
end

function Unit:move(newPos)
    self.x = newPos.x
    self.y = newPos.y
end

function Unit:attack(target)
    -- Implement attack logic here
end

function Unit:capture(building)
    -- Implement capture logic here
end


-- Unit Manager Class
UnitManager = class()

function UnitManager:init()
    self.units = {}
end

function UnitManager:createUnit(type, x, y, health, attack, defense)
    local unit = Unit(type, x, y, health, attack, defense)
    table.insert(self.units, unit)
end

function UnitManager:getUnits()
    return self.units
end


