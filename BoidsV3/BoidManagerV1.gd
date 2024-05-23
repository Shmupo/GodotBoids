class_name BoidManagerV1
extends MultiMeshInstance3D

## generates and controls the movements of boids
var numBoids: int = multimesh.instance_count

# { boidNum : RID }
var boidNums: Dictionary = {}

# { boidNum : position }
var instancePositions: Dictionary = {}

# { boidNum : velocity }
var instanceVelocities: Dictionary = {}
	
var spatialHashGrid: SpatialGridV2 = SpatialGridV2.new()

var xBound: int = BoidConfigV3.xBound
var yBound: int = BoidConfigV3.yBound
var zBound: int = BoidConfigV3.zBound
var turnFactor: float = BoidConfigV3.turnFactor
	
func _ready():
	initInstancePos()
	initInstanceRandDirection()

func initInstancePos() -> void:
	for instance in range(numBoids):
		var transform3D: Transform3D = multimesh.get_instance_transform(instance)
		transform3D.origin = Vector3(randf_range(-BoidConfigV3.xBound, BoidConfigV3.xBound), 
			randf_range(-BoidConfigV3.yBound, BoidConfigV3.yBound), 
			randf_range(-BoidConfigV3.zBound, BoidConfigV3.zBound))
		multimesh.set_instance_transform(instance, transform3D)
		instancePositions[instance] = multimesh.get_instance_transform(instance).origin
		
func initInstanceRandDirection() -> void:
	for instance in range(numBoids):
		instanceVelocities[instance] = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))

# Transform3D.origin is the 'position'
# applies velocity to instance from instance velocities
func moveBoids(delta: float) -> void:
	for instance in range(numBoids):
		var prevTransform: Transform3D = multimesh.get_instance_transform(instance)
		var newTransform: Transform3D = Transform3D(prevTransform.basis, prevTransform.origin + instanceVelocities[instance] * delta)
		multimesh.set_instance_transform(instance, newTransform)
		instancePositions[instance] = newTransform.origin
		
		var oldCellPos: Vector3i = spatialHashGrid.hash(prevTransform.origin)
		var newCellPos: Vector3i = spatialHashGrid.hash(newTransform.origin)
		
		if oldCellPos != newCellPos:
			spatialHashGrid.remove(instance, oldCellPos)
			spatialHashGrid.insert(instance, newCellPos)
		
		instanceVelocities[instance] += getBoundForce(newTransform.origin)
		instanceVelocities[instance] = instanceVelocities[instance].limit_length(BoidConfigV3.maxSpeed)
		if instanceVelocities[instance].length() < BoidConfigV3.minSpeed:
			instanceVelocities[instance] = instanceVelocities[instance].normalized() * BoidConfigV3.minSpeed

# iterate through each grid in the spatial grid rather than each boid 
func applyBoidClusterForces() -> void:
	for coord in spatialHashGrid.grid:
		var group: Dictionary = spatialHashGrid.grid[Vector3i(coord)]
		var numOfBoids: int = group.size()
		
		if numOfBoids != 0:
			# average heading + position
			var avgPosition: Vector3 = Vector3.ZERO
			var avgHeading: Vector3 = Vector3.ZERO
			
			for boidNum in group:
				avgPosition += instancePositions[boidNum]
				avgHeading += instanceVelocities[boidNum]
				
			avgPosition /= numOfBoids
			avgHeading /= numOfBoids
			
			for boidNum in group:
				var boidPosition: Vector3 = instancePositions[boidNum]
				var boidVelocity: Vector3 = instanceVelocities[boidNum]
				
				# Alignment
				var alignmentForce: Vector3 = (avgHeading - boidVelocity) * BoidConfigV3.alignmentMod
				# Cohesion
				var cohesionForce: Vector3 = ((avgPosition - boidPosition) - boidVelocity) * BoidConfigV3.cohesionMod
				# Separation
				var separationForce: Vector3 = Vector3.ZERO
				for neighborNum in group:
					if neighborNum != boidNum:  # avoid self comparison
						var neighborPos: Vector3 = instancePositions[neighborNum]
						var distance: float = boidPosition.distance_to(neighborPos)
						if distance < BoidConfigV3.separationRangeSquared:
							separationForce += (boidPosition - neighborPos)
				
				separationForce *= BoidConfigV3.separationMod
				
				# Combine forces
				var totalForce: Vector3 = alignmentForce + cohesionForce + separationForce
				
				# Update velocity
				instanceVelocities[boidNum] += totalForce
				
				# Optionally limit the velocity to a max speed
				var maxSpeed: float = BoidConfigV3.maxSpeed
				if instanceVelocities[boidNum].length() > maxSpeed:
					instanceVelocities[boidNum] = instanceVelocities[boidNum].normalized() * maxSpeed


# add a force when boid reaches the bounds to push it back into the bounds
func getBoundForce(boidPos: Vector3) -> Vector3:
	var force: Vector3 = Vector3.ZERO
	
	if boidPos.x < -xBound:
		force.x += turnFactor
	elif boidPos.x > xBound:
		force.x += -turnFactor
	if boidPos.y < -yBound:
		force.y += turnFactor
	elif boidPos.y > yBound:
		force.y += -turnFactor
	if boidPos.z < -zBound:
		force.z += turnFactor
	elif boidPos.z > zBound:
		force.z += -turnFactor
		
	return force
		
func _process(delta):
	applyBoidClusterForces()
	moveBoids(delta)
