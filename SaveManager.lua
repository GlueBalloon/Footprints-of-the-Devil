SaveManager = class()

function SaveManager:init()
    self.keyPrefix = "savedGame_"
end

function SaveManager:save(slot, gameData)
    local jsonData = json.encode(gameData)
    saveProjectData(self.keyPrefix .. slot, jsonData)
end

function SaveManager:load(slot)
    local jsonData = readProjectData(self.keyPrefix .. slot)
    if jsonData then
        return json.decode(jsonData)
    else
        print("No saved game found in slot " .. slot)
        return nil
    end
end