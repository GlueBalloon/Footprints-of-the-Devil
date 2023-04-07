-- Unit Class
Unit = class()

-- Unit Class
function Unit:init(team, strength, x, y, aColor)
    self.team = team
    self.strength = strength
    self.x = x
    self.y = y
    self.level = 1
    self.color = aColor or color(236, 217, 67)
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

function Unit:attack(target)
    local damage = self.strength + self:getFlankingBonus(target)
    target.strength = target.strength - damage
    
    if target.strength <= 0 then
        target:destroy()
    end
end

function Unit:getFlankingBonus(target)
    local flankingBonus = 0
    if self.team == "sapiens" then
        local flankedSides = 0
        local neighbors = {
            {x = target.x - 1, y = target.y},
            {x = target.x + 1, y = target.y},
            {x = target.x, y = target.y - 1},
            {x = target.x, y = target.y + 1}
        }
        
        for _, neighbor in ipairs(neighbors) do
            local unit = getUnitAt(neighbor.x, neighbor.y)
            if unit and unit.team == "sapiens" then
                flankedSides = flankedSides + 1
            end
        end
        
        if flankedSides >= 2 then
            flankingBonus = 2 -- Adjust this value for the desired flanking bonus
        end
    end
    
    return flankingBonus
end

function Unit:destroy()
    -- Remove unit from the game
end

function Unit:levelUp()
    self.level = self.level + 1
    self.strength = self.strength + 1 -- Adjust this value for the desired strength increase per level
end

-- Helper function to get the unit at a specific grid position
function getUnitAt(x, y)
    -- Implement this function to look up units in your game's data structures
end



-- Unit Manager Class
UnitManager = class()

function UnitManager:init()
    self.units = {}
end

function UnitManager:createUnit(team, strength, x, y, aColor)
    local unit = Unit(team, strength, x, y, aColor)
    table.insert(self.units, unit)
end

function UnitManager:getUnits()
    return self.units
end


