class_name SpatialGridV2

# Grid dimensions
var width: int = BoidConfigV3.xBound
var height: int = BoidConfigV3.yBound
var depth: int = BoidConfigV3.zBound

var gridSize: int = BoidConfigV3.spatialGridSize

# The grid itself, represented as a 3D array
# {Vector3i : { array of boidNumbers } }
var grid: Dictionary = {}

func _init():
	initGrid()

func initGrid() -> void:
	var gridWidth: int = int(width / gridSize)
	var gridHeight: int = int(height / gridSize)
	var gridDepth: int = int(depth / gridSize)
	
	for x in range(-gridWidth, gridWidth):
		for y in range(-gridHeight, gridHeight):
			for z in range(-gridDepth, gridDepth):
				grid[Vector3i(x, y, z)] = {}

func hash(position: Vector3) -> Vector3i:
	return Vector3i(int(position.x / gridSize), int(position.y / gridSize), int(position.z / gridSize))

func insert(boidNumber: int, hashPos: Vector3i) -> void:
	if grid.has(hashPos):
		grid[hashPos][boidNumber] = null
	
func remove(boidNum: int, hashPos: Vector3i) -> void:
	if grid.has(hashPos):
		if grid[hashPos].has(boidNum):
			grid[hashPos].erase(boidNum)
	
func retrieve(hashPos: Vector3i) -> Dictionary:
	if grid.has(hashPos):
		return grid[hashPos]
	else:
		return Dictionary()
