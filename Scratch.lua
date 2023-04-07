--[[
code
-- Create a table to store cell colors for smaller rects
self.smallCellColors = {}
local noiseScale = 0.1

for i = 1, self.gridSize do
self.smallCellColors[i] = {}
for j = 1, self.gridSize do
self.smallCellColors[i][j] = {}
for k = 1, self.fakePixelsPerSide do
self.smallCellColors[i][j][k] = {}
for l = 1, self.fakePixelsPerSide do
local noiseValue = craft.noise.perlin(i * noiseScale, j * noiseScale, k * noiseScale, l * noiseScale)
local t = (noiseValue + 1) / 2 -- Transform noiseValue from the range [-1, 1] to [0, 1]
self.smallCellColors[i][j][k][l] = self:lerpColorBeigeToRust(t)
end
end
end
end
Additionally, you need to create a lerpColorBeigeToRust function that interpolates between beige and rust colors based on the given t value:

lua
Copy code
function Map:lerpColorBeigeToRust(t)
local beige = color(245, 222, 179)
local rust = color(183, 65, 14)
local r = lerp(beige.r, rust.r, t)
local g = lerp(beige.g, rust.g, t)
local b = lerp(beige.b, rust.b, t)
return color(r, g, b)
end

]]