class_name SpatialGridV1

var boids: Array[BoidV2] = []

var gridCubesX: int = ceili(BoidConfigV2.xBound / BoidConfigV2.spatialGridSize) * 2
var gridCubesY: int = ceili(BoidConfigV2.yBound / BoidConfigV2.spatialGridSize) * 2
var gridCubesZ: int = ceili(BoidConfigV2.zBound / BoidConfigV2.spatialGridSize) * 2

# TODO may need to add border buffer for grid

# { gridNumber : [boids...] }
var grid: Dictionary = {}

# { gridNumber : [avgHeading, avgPosition] }
var gridAverageValues: Dictionary = {}

func _init():
	createGrid()

# grid starts at -BoidConfigV2.Bound and ends at BoidConfigV2.Bound
# i.e. -50 to 50 if BoidConfigV2.Bound = 50
# make sure bounds and grid size divide out into an integer for best results
func createGrid() -> void:
	var numGrid: int = 0
	
	for cubeNumX in gridCubesX:
		for cubeNumY in gridCubesY:
			for cubeNumZ in gridCubesZ:
				grid[str(cubeNumX) + " " + str(cubeNumY) + " " + str(cubeNumZ)] = []
				gridAverageValues[str(cubeNumX) + " " + str(cubeNumY) + " " + str(cubeNumZ)] = []
				
				numGrid += 1
			
	print("Created SpatialGrid with ", numGrid, " squares.")
	
func getNumBoidsInCell(cell: String) -> int:
	if grid.has(cell):
		return grid[cell].size()
	else:
		return 0
	
func getBoidsInCell(cell: String) -> Array:
	if grid.has(cell):
		return grid[cell]
	else:
		return []
		
func getBoidsInNeighborCell(cell: String) -> Array:
	var neighborBoids: Array = []
	
	var gridNums: PackedStringArray = cell.split(" ")
	
	var gridXNum: int = int(gridNums[0])
	var gridYNum: int = int(gridNums[1])
	var gridZNum: int = int(gridNums[2])
	
	# get 3x3 grid of all boids around the given cell
	for x in range(gridXNum - 1, gridXNum + 2):
		for y in range(gridYNum - 1, gridXNum + 2):
			for z in range(gridZNum - 1, gridXNum + 2):
				neighborBoids.append_array(getBoidsInCell(str(x) + " " + str(y) + " " + str(z)))
	
	return neighborBoids
		
func updateGridAndBoids(delta: float) -> void:
	for gridNum in grid:
		grid[gridNum].clear()
	
	# assign grid numbers to boids and place boid in grid cell
	for boid in boids:
		var boidGridNum: String = ""
		var boidPos: Vector3 = boid.global_position
		var boidXGrid: int = ceili(boidPos.x / BoidConfigV2.spatialGridSize) + gridCubesX / 2
		var boidYGrid: int = ceili(boidPos.y / BoidConfigV2.spatialGridSize) + gridCubesY / 2
		var boidZGrid: int = ceili(boidPos.z / BoidConfigV2.spatialGridSize) + gridCubesZ / 2
		boidGridNum += str(boidXGrid) + " " + str(boidYGrid) + " " + str(boidZGrid)
		
		boid.currentGridNum = boidGridNum
		
		if grid.has(boidGridNum):
			grid[boidGridNum].append(boid)
			
	# update grid average values
	for gridNum in grid:
		if not grid[gridNum].is_empty():
			var avgHeading: Vector3 = Vector3.ZERO
			var avgPos: Vector3 = Vector3.ZERO
			
			# for 3x3
			var surroundingBoids: Array = getBoidsInNeighborCell(gridNum)
			# for 1x1
			#var surroundingBoids = getBoidsInCell(gridNum)
			var numBoids: int = surroundingBoids.size()
			
			if numBoids != 0:
				for boid in surroundingBoids:
					avgHeading += boid.velocity
					avgPos += boid.global_position
					
				avgHeading /= numBoids
				avgPos /= numBoids
				
				gridAverageValues[gridNum] = [avgHeading, avgPos]
			else:
				gridAverageValues[gridNum] = [Vector3.ZERO, Vector3.ZERO]
