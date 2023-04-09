
Map = class()

function Map:init(x, y, width, height, cellsPerSide)
    self.width = width or WIDTH * 0.45
    self.height = height or HEIGHT * 0.45
    self.gridSize = cellsPerSide or 12
    self.cellSize = math.min(width, height) / self.gridSize
    self.offsetX = x or (WIDTH - width) / 2
    self.offsetY = y or (HEIGHT - height) / 2
    self.terrain = {}
    self.units = {}
    self.cellColors = {}
    self.fakePixelsPerSide = 4
    self.smallCellSize = self.cellSize / self.fakePixelsPerSide -- Calculate the size of the smaller rects
    
    self.smallCellColors = {}
    --color pairs
    self.highestElevationColor = color(245, 222, 179)
    self.lowestElevationColor = color(226, 150, 117)
    --or
    self.highestElevationColor = color(217, 203, 171)
    self.lowestElevationColor = color(211, 150, 124)
    --or
    self.highestElevationColor = color(219, 169, 138)
    self.lowestElevationColor = color(192, 107, 68)
    self.perlinNoise = craft.noise.perlin()
    self.offsetXNoise = math.random(0, 10000)
    self.offsetYNoise = math.random(0, 10000)
    local noiseMagnifier = math.random(65, 130) * 0.01
  --  print(noiseMagnifier)
    self.noiseScale = 0.0075 * noiseMagnifier
    for i = 1, self.gridSize do
        self.smallCellColors[i] = {}
        for j = 1, self.gridSize do
            self.smallCellColors[i][j] = {}
            for k = 1, self.fakePixelsPerSide do
                self.smallCellColors[i][j][k] = {}
                for l = 1, self.fakePixelsPerSide do
                    local noiseValue = self.perlinNoise:getValue(
                    (self.offsetX + (i - 1) * self.cellSize + (k - 1) * self.smallCellSize + self.offsetXNoise) * self.noiseScale, 
                    (self.offsetY + (j - 1) * self.cellSize + (l - 1) * self.smallCellSize + self.offsetYNoise) * self.noiseScale, 
                    0
                    )
                    -- Normalize the noiseValue to be between 0 and 1
                    noiseValue = (noiseValue + 1) / 2
                    noiseValue = math.max(0, math.min(1, noiseValue))
                    self.smallCellColors[i][j][k][l] = self:lerpColors(noiseValue, self.highestElevationColor, self.lowestElevationColor)
                end
            end
        end
    end
    parameter.boolean("drawMiniNoise")
    parameter.color("highColor", color(243, 242, 241))
    parameter.color("lowColor", color(211, 150, 124))
    highColor = self.highestElevationColor
    lowColor = self.lowestElevationColor
end

-- Rest of the methods remain unchanged


function Map:lerpColors(amount, color1, color2)
    function lerp(a, b, amount)
        return a + (b - a) * amount
    end
    local r = lerp(color1.r, color2.r, amount)
    local g = lerp(color1.g, color2.g, amount)
    local b = lerp(color1.b, color2.b, amount)
    local returnColor = color(r, g, b)
    return returnColor
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
    
    if drawMiniNoise then
        self:drawPerlinNoisePattern()
    end
end


function Map:pointToCellRowAndColumn(x, y)
    local col = math.floor((x - self.offsetX) / self.cellSize) + 1
    local row = math.floor((y - self.offsetY) / self.cellSize) + 1
    
    if col < 1 or col > self.gridSize or row < 1 or row > self.gridSize then
        return nil, nil
    end
    
    return row, col
end

function Map:cellRowAndColumnToPoint(row, col)
    local x = self.offsetX + (self.cellSize / 2) + (col - 1) * self.cellSize
    local y = self.offsetY + (self.cellSize / 2) + (row - 1) * self.cellSize
    return x, y
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

function Map:drawPerlinNoisePattern(x, y, width, height, squareSize, noiseGenerator)
    x = x or self.offsetX + (self.smallCellSize * 0.7)
    y = y or self.offsetY - (self.smallCellSize * 0.3)
    squareSize = squareSize or self.smallCellSize * 0.967697
    width = width or self.gridSize * squareSize * self.fakePixelsPerSide
    height = height or width
    noiseGenerator = noiseGenerator or self.perlinNoise
    fill(32, 51, 100, 25)
    rect(x - 2, y - 2, (width * 1.025) + 1, (height * 1.025) + 1)
    self.highestElevationColor = highColor
    self.lowestElevationColor = lowColor
    local scaleFactor = self.noiseScale -- Controls the "zoom" level of the noise
    for i = x, x + width, squareSize do
        for j = y, y + height, squareSize do
            local noiseValue = noiseGenerator:getValue((i + self.offsetXNoise) * scaleFactor, (j + self.offsetYNoise) * scaleFactor, 0)
            -- Normalize the noiseValue to be between 0 and 1
            noiseValue = (noiseValue + 1) / 2
            noiseValue = math.max(0, math.min(1, noiseValue))
            fill(Map:lerpColors(noiseValue, self.highestElevationColor, self.lowestElevationColor))
            rect(i, j, squareSize, squareSize)
        end
    end
end

