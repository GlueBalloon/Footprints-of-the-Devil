-- Footprints Of The Devil

function setup()
    displayMode(OVERLAY)
    rows = 10
    columns = 10
    cellSize = 50
    
    gridData = GridData(rows, columns)
    gridData:addUnit(2,7)
    
    grid2D = Grid2D(gridData, cellSize)
    grid3D = Grid3D(gridData, 4)
    
    gridData:addUnit(5, 5)
    scene = grid3D.scene    
    parameter.boolean("show3D", true)
    -- Run the test
    -- testGridData()
end

function draw()
    background(40, 40, 50)
    if not show3D then
        grid2D:draw()
        grid2D:touched(CurrentTouch)
    else
        grid3D:draw()
        grid3D:update(DeltaTime)
        
        if CurrentTouch.state == BEGAN then
            grid3D:touchPressed(CurrentTouch)
        elseif CurrentTouch.state == ENDED or CurrentTouch.state == CANCELLED then
            grid3D:touchReleased(CurrentTouch)
        end
    end 
end
