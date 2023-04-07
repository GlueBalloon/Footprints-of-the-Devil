
Map = class()

function Map:init()
    self.gridSize = 12
    local inset = math.min(WIDTH, HEIGHT) * 0.08
    self.cellSize = (math.min(WIDTH, HEIGHT) - 2 * inset) / self.gridSize
    self.offsetX = (WIDTH - (self.cellSize * self.gridSize)) / 2
    self.offsetY = (HEIGHT - (self.cellSize * self.gridSize)) / 2
    self.terrain = {}
    self.units = {}
    self.cellColors = {}
    self.fakePixelsPerSide = 3
    self.smallCellSize = self.cellSize / self.fakePixelsPerSide -- Calculate the size of the smaller rects
    

    
    self.smallCellColors = {}
    local noiseScale = 0.975
    local noiseMaker = craft.noise.perlin()
    

    local offset = 200
    for i = 1, self.gridSize do
        self.smallCellColors[i] = {}
        for j = 1, self.gridSize do
            self.smallCellColors[i][j] = {}
            for k = 1, self.fakePixelsPerSide do
                self.smallCellColors[i][j][k] = {}
                for l = 1, self.fakePixelsPerSide do
                    local noiseValue = noiseMaker:getValue(
                    (i * noiseScale) + (l * offset),
                    (j * noiseScale) + (l * offset),
                    (k * noiseScale) + (l * offset)
                    )
                    local t = (noiseValue + 1) / 2 -- Normalize the noise value to [0, 1]
                    self.smallCellColors[i][j][k][l] = self:lerpColorBeigeToRust(t)
                end
            end
        end
    end

    rectWidth = 360
    rectHeight = 360
    rectX = (WIDTH - rectWidth) / 2
    rectY = (HEIGHT - rectHeight) / 2
    perlinNoise = craft.noise.perlin()
    offsetX = math.random(0, 10000)
    offsetY = math.random(0, 10000)
    
    self.perlinNoise = craft.noise.perlin()
    self.offsetXNoise = math.random(0, 10000)
    self.offsetYNoise = math.random(0, 10000)
    
    local noiseScale = 0.01
    for i = 1, self.gridSize do
        self.smallCellColors[i] = {}
        for j = 1, self.gridSize do
            self.smallCellColors[i][j] = {}
            for k = 1, self.fakePixelsPerSide do
                self.smallCellColors[i][j][k] = {}
                for l = 1, self.fakePixelsPerSide do
                    local noiseValue = self.perlinNoise:getValue(
                    (self.offsetX + (i - 1) * self.cellSize + (k - 1) * self.smallCellSize + self.offsetXNoise) * noiseScale, 
                    (self.offsetY + (j - 1) * self.cellSize + (l - 1) * self.smallCellSize + self.offsetYNoise) * noiseScale, 
                    0
                    )
                    self.smallCellColors[i][j][k][l] = self:lerpColorBeigeToRust(noiseValue)
                end
            end
        end
    end
end

function Map:drawPerlinNoisePattern(x, y, width, height, squareSize, noiseGenerator)
    local scaleFactor = 0.01 -- Controls the "zoom" level of the noise
    for i = x, x + width, squareSize do
        for j = y, y + height, squareSize do
            local noiseValue = noiseGenerator:getValue((i + self.offsetXNoise) * scaleFactor, (j + self.offsetYNoise) * scaleFactor, 0)
            fill(Map:lerpColorBeigeToRust(noiseValue))
            rect(i, j, squareSize, squareSize)
        end
    end
end



function Map:lerpColorBeigeToRust(t)
    function lerp(a, b, t)
        return a + (b - a) * t
    end
    local beige = color(245, 222, 179)
    local rust = color(183, 65, 14)
 --local beige = color(245, 245, 220)
 --   local rust = color(226, 190, 165)
    local rust = color(226, 150, 117)
    local r = lerp(beige.r, rust.r, t)
    local g = lerp(beige.g, rust.g, t)
    local b = lerp(beige.b, rust.b, t)
    local returnColor = color(r, g, b)
    return returnColor
end

function Map:update()
    -- Update units and other map elements here
end

function Map:draw()
    pushStyle()
    noStroke()
    
    -- Draw cell backgrounds with smaller rects
    for i = 1, self.gridSize do
        for j = 1, self.gridSize do
            for k = 1, self.fakePixelsPerSide do
                for l = 1, self.fakePixelsPerSide do
                    local smallCellColor = self.smallCellColors[i][j][k][l]
                    fill(smallCellColor)
                    rect(self.offsetX + (i - 1) * self.cellSize + (k - 1) * self.smallCellSize,
                    self.offsetY + (j - 1) * self.cellSize + (l - 1) * self.smallCellSize,
                    self.smallCellSize + 2, self.smallCellSize + 2)
                end
            end
        end
    end
    
    stroke(220, 176, 143)
    strokeWidth(2)
    -- Draw grid lines
    for i = 0, self.gridSize do
        line(self.offsetX + i * self.cellSize, self.offsetY, self.offsetX + i * self.cellSize, self.offsetY + self.gridSize * self.cellSize)
        line(self.offsetX, self.offsetY + i * self.cellSize, self.offsetX + self.gridSize * self.cellSize, self.offsetY + i * self.cellSize)
    end
    popStyle()
   self: drawPerlinNoisePattern(rectX, rectY, rectWidth, rectHeight, 10, self.perlinNoise)
end


function Map:pointToCellRowAndColumn(x, y)
    local col = math.floor((x - self.offsetX) / self.cellSize) + 1
    local row = math.floor((y - self.offsetY) / self.cellSize) + 1
    
    if col < 1 or col > self.gridSize or row < 1 or row > self.gridSize then
        return nil, nil
    end
    
    return row, col
end

function Map:randomColorBetweenBeigeAndRust()
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    
    local beige = {245/255, 245/255, 220/255}
    local rust = {226/255, 190/255, 165/255}
    local t = math.random()
    
    local r = lerp(beige[1], rust[1], t)
    local g = lerp(beige[2], rust[2], t)
    local b = lerp(beige[3], rust[3], t)
    
    return color(r, g, b)
end



