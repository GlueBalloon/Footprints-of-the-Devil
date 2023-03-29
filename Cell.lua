
Content = {
    UNIT = 1
}

Cell = class()

function Cell:init()
    self.contents = {}
end

function Cell:addContent(contentType, content)
    self.contents[contentType] = content
end

function Cell:removeContent(contentType)
    self.contents[contentType] = nil
end

function Cell:getContent(contentType)
    return self.contents[contentType]
end
