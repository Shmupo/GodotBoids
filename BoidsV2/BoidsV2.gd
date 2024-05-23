class_name BoidV2
extends Sprite3D

var spatialGrid: SpatialGridV1
var velocity: Vector3 = Vector3.ZERO
var currentGridNum: String

# calculate average heading and position of neighbors in one pass
func getAvgValues(gridCell: String) -> Array:
	var avgHeading: Vector3 = Vector3.ZERO 
	var avgPosition: Vector3 = Vector3.ZERO 
	
	if spatialGrid.gridAverageValues.has(gridCell):
		var gridAvgVals = spatialGrid.gridAverageValues[gridCell]
		avgHeading = gridAvgVals[0]
		avgPosition = gridAvgVals[1]
		
	return [avgHeading, avgPosition]

# alignment force
func getAlignment(avgHeading: Vector3) -> Vector3:
	return avgHeading

# cohesion force
func getCohesion(avgPos: Vector3) -> Vector3:
	return (avgPos - global_position).normalized()

# separation force - not averaged
func getSeparation(gridCell: String) -> Vector3:
	var sepVec: Vector3 = Vector3.ZERO
	
	var neighborBoids: Array = []
	if spatialGrid.grid.has(gridCell):
		neighborBoids = spatialGrid.grid[gridCell]
	
	for neighbor in neighborBoids:
		sepVec += global_position - neighbor.global_position
		
	return sepVec

# adds forces to velocity
func calculateMoveVector() -> void:
	var avgVals: Array = getAvgValues(currentGridNum)
	# separation does not use avg values variable - need to calculate before cohesion and alignment
	var separation: Vector3 = getSeparation(currentGridNum)
	var cohesion: Vector3 = getCohesion(avgVals[1])
	var alignment: Vector3 = getAlignment(avgVals[0])
	
	var numNeighbors: int = spatialGrid.getNumBoidsInCell(currentGridNum)
	
	# add push force away from border to velocity
	addBoundsForce()
	
	if numNeighbors != 0:
		separation /= numNeighbors
		velocity += (alignment - velocity) * BoidConfigV2.alignmentMod
		velocity += (cohesion - velocity) * BoidConfigV2.cohesionMod
		velocity += separation * BoidConfigV2.separationMod
		
	velocity.limit_length(BoidConfigV2.maxSpeed)
	if velocity.length() < BoidConfigV2.minSpeed:
		velocity = velocity.normalized() * BoidConfigV2.minSpeed

# moves boid away from border
func addBoundsForce() -> void:
	var xBound = BoidConfigV2.xBound
	var yBound = BoidConfigV2.yBound
	var zBound = BoidConfigV2.zBound
	var turnFactor = BoidConfigV2.turnFactor
	
	var posX = position.x
	var posY = position.y
	var posZ = position.z
	
	if posX > xBound:
		velocity.x -= turnFactor
	elif posX < -xBound:
		velocity.x += turnFactor
		
	if posY > yBound:
		velocity.y -= turnFactor
	elif posY < -yBound:
		velocity.y += turnFactor
		
	if posZ > zBound:
		velocity.z -= turnFactor
	elif posZ < -zBound:
		velocity.z += turnFactor

# apply velocity to position every frame
# updated via the SpatialGrid to ensure the grid has properly updated
func _process(delta):
	calculateMoveVector()
	#rotation = rotation.move_toward(velocity, delta)
	global_position += velocity * delta
