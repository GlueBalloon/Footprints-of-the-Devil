-- In-Game UI
InGameUI = class()

function InGameUI:init()
    self.selectedUnit = nil
end

function InGameUI:draw(units)
    if self.selectedUnit then
        self:drawSelectedUnitInfo(self.selectedUnit)
    end
    
    for _, unit in ipairs(units) do
        self:drawUnit(unit)
    end
end

function InGameUI:drawUnit(unit)
    -- Draw the unit on the map (assuming map coordinates are in pixels)
    sprite(asset.builtin.SpaceCute.Beetle_Ship, unit.x * 32, unit.y * 32, 32, 32)
end

function InGameUI:drawSelectedUnitInfo(unit)
    -- Draw the selected unit's info (health, attack, etc.) in a corner of the screen
    local textX, textY = 20, HEIGHT - 20
    text("Unit Type: " .. unit.type, textX, textY)
    text("Health: " .. unit.health, textX, textY - 20)
    text("Attack: " .. unit.attack, textX, textY - 40)
    text("Defense: " .. unit.defense, textX, textY - 60)
end

function InGameUI:selectUnit(units, x, y)
    if not units then
        return
    end
    for _, unit in ipairs(units) do
        if unit.x * 32 == x and unit.y * 32 == y then
            self.selectedUnit = unit
            return
        end
    end
    self.selectedUnit = nil
end

function InGameUI:moveSelectedUnit(x, y)
    if self.selectedUnit then
        self.selectedUnit.x = x // 32
        self.selectedUnit.y = y // 32
    end
end

