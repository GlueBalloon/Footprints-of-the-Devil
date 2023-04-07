Player = class()

function Player:init(id, team)
    self.id = id
    self.team = team
end

function Player:draw()
    -- Codea does not automatically call this method
end

function Player:touched(touch)
    -- Codea does not automatically call this method
end
