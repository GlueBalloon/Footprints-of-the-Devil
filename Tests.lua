function testGridData()
    local gridData = GridData(3, 3)
    
    -- Add some units
    local unit1 = gridData:addUnit("A", "idle", 1, 1)
    local unit2 = gridData:addUnit("B", "idle", 2, 2)
    local unit3 = gridData:addUnit("C", "idle", 3, 3)
    
    -- Check if the units were added correctly
    assert(gridData:getCell(1, 1):getContent(Content.UNIT) == unit1, "Unit 1 was not placed correctly.")
    assert(gridData:getCell(2, 2):getContent(Content.UNIT) == unit2, "Unit 2 was not placed correctly.")
    assert(gridData:getCell(3, 3):getContent(Content.UNIT) == unit3, "Unit 3 was not placed correctly.")
    
    -- Move some units
    gridData:moveUnit(1, 1, 1, 2)
    gridData:moveUnit(2, 2, 2, 3)
    
    -- Check if the units were moved correctly
    assert(gridData:getCell(1, 1):getContent(Content.UNIT) == nil, "Unit 1 was not moved correctly.")
    assert(gridData:getCell(1, 2):getContent(Content.UNIT) == unit1, "Unit 1 was not moved correctly.")
    assert(gridData:getCell(2, 2):getContent(Content.UNIT) == nil, "Unit 2 was not moved correctly.")
    assert(gridData:getCell(2, 3):getContent(Content.UNIT) == unit2, "Unit 2 was not moved correctly.")
    
    -- Remove some units
    gridData:removeUnit(1, 2)
    gridData:removeUnit(2, 3)
    
    -- Check if the units were removed correctly
    assert(gridData:getCell(1, 2):getContent(Content.UNIT) == nil, "Unit 1 was not removed correctly.")
    assert(gridData:getCell(2, 3):getContent(Content.UNIT) == nil, "Unit 2 was not removed correctly.")
    
    print("All tests passed.")
end


