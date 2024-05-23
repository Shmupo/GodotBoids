class_name BoidV1
extends Sprite3D

# neighbors boids array
var neighborBoids: Array = []

# connect area3D exit and enter signals for neighbor assignment
func _ready():
	if get_child(0) != null:
		get_child(0).area_entered.connect(areaEnter)
		get_child(0).area_exited.connect(areaExit)

# add boid as neighbor if enter area3D
func areaEnter(area: Area3D) -> void:
	neighborBoids.append(area.get_parent())
	
# remove boid as neighber if exit area3D
func areaExit(area: Area3D) -> void:
	neighborBoids.remove_at(neighborBoids.find(area.get_parent()))

# Calculations
var velocity: Vector3 = Vector3.ZERO

# calculate average heading and position of neighbors in one pass
func getAvgValues() -> Array:
	var avgHeading: Vector3 = Vector3.ZERO 
	var avgPosition: Vector3 = Vector3.ZERO 
	
	for neighbor in neighborBoids:
		avgHeading += neighbor.velocity
		avgPosition += neighbor.global_position
		
	return [avgHeading, avgPosition]

# alignment force - not avaraged
func getAlignment(avgHeading: Vector3) -> Vector3:
	return avgHeading

# cohesion force - not averaged
func getCohesion(avgPos: Vector3) -> Vector3:
	return (avgPos - global_position).normalized()

# separation force - not averaged
func getSeparation() -> Vector3:
	var sepVec: Vector3 = Vector3.ZERO
	var separationRangeSquared: float = BoidConfigV1.separationRangeSquared
	for neighbor in neighborBoids:
		if global_position.distance_squared_to(neighbor.global_position) < separationRangeSquared:
			sepVec += global_position - neighbor.global_position
		
	return sepVec

# adds forces to velocity
func calculateMoveVector() -> void:
	var avgVals: Array = getAvgValues()
	# separation does not use avg values variable - need to calculate before cohesion and alignment
	var separation: Vector3 = getSeparation()
	var neighbors: int = neighborBoids.size()
	
	# average out values
	if neighbors != 0:
		avgVals[0] /= neighbors
		avgVals[1] /= neighbors
		separation /= neighbors
	
	var cohesion: Vector3 = getCohesion(avgVals[1])
	var alignment: Vector3 = getAlignment(avgVals[0])
	
	# add push force away from border to velocity
	addBoundsForce()
	
	if neighbors != 0:
		velocity += (alignment - velocity) * BoidConfigV1.alignmentMod
		velocity += (cohesion - velocity) * BoidConfigV1.cohesionMod
		velocity += separation * BoidConfigV1.separationMod
		
		velocity.limit_length(BoidConfigV1.maxSpeed)
		if velocity.length() < BoidConfigV1.minSpeed:
			velocity = velocity.normalized() * BoidConfigV1.minSpeed

# moves boid away from border
func addBoundsForce() -> void:
	var xBound = BoidConfigV1.xBound
	var yBound = BoidConfigV1.yBound
	var zBound = BoidConfigV1.zBound
	var turnFactor = BoidConfigV1.turnFactor
	
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
func _process(delta):
	calculateMoveVector()
	#rotation = rotation.move_toward(velocity, delta)
	global_position += velocity * delta
