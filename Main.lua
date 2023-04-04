-- Footprints Of The Devil

function setup()
    viewer.mode = OVERLAY
    parameter.boolean("show3D", true)
    parameter.watch("selected")
     
    rows = 10
    columns = 10
    cellSize = 50
    
    gridData = GridData(rows, columns)
    gridData:placeUnitData(Unit(), 2,7)
    
    grid2D = Grid2D(gridData, cellSize)
    grid3D = Grid3D(gridData, 3)
    
    gridData:placeUnitData(Unit(), 5, 5)
    scene = grid3D.scene    

    -- Run the test
    -- testGridData()
end

function draw()
    background(40, 40, 50)
    if not show3D then
        grid2D:draw()
        grid2D:touched(CurrentTouch)
    else
        grid3D:draw(DeltaTime)
    end
    selected = tostring(gridData.selectedR).." "..tostring(gridData.selectedC)
end

function touched(touch)
    if not show3D then
        grid2D:touched(touch)
    else
        grid3D:touched(touch)
    end 
end
