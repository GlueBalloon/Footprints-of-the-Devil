
-- Unit class
Unit = class()

function Unit:init(id, icon, state)
    self.id = id or "no id"
    self.icon = icon or readImage(asset.builtin.SpaceCute.Beetle_Ship)
    self.state = state or "default"
end
