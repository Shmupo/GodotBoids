class_name BoidGeneratorV1
extends Node

var boids: Array

# create boids on node ready
func _ready():
	generateNBoidsV1()
	
# randomize boid placement within bounds upon creation
func placeBoidRandInBounds(boid: BoidV1) -> void:
	boid.position = Vector3(
		randf_range(-BoidConfigV1.xBound, BoidConfigV1.xBound),
		randf_range(-BoidConfigV1.yBound, BoidConfigV1.yBound),
		randf_range(-BoidConfigV1.zBound, BoidConfigV1.zBound),
		)
		
# randomize boid speed upon creation
func setBoidRandSpeed(boid: BoidV1) -> void:
	boid.velocity = Vector3(
		randf_range(-BoidConfigV1.maxSpeed, BoidConfigV1.maxSpeed),
		randf_range(-BoidConfigV1.maxSpeed, BoidConfigV1.maxSpeed),
		randf_range(-BoidConfigV1.maxSpeed, BoidConfigV1.maxSpeed),
	)

# create boid and it's components one at a time, then randomize placement and velocity
func generateNBoidsV1() -> void:
	for x in BoidConfigV1.numBoids:
		var boid: BoidV1 = createBoidV1()
		var area3d: Area3D = createArea3D()
		var collisionShape: CollisionShape3D = createSphereCollision()
		boid.add_child(area3d)
		area3d.add_child(collisionShape)
		add_child(boid)
		
		placeBoidRandInBounds(boid)
		setBoidRandSpeed(boid)
		
		boids.append(boid)

# create boid sprite3D object w/script
func createBoidV1() -> BoidV1:
	var boid: BoidV1 = BoidV1.new()
	boid.texture = BoidConfigV1.boidImg
	boid.scale = BoidConfigV1.boidScale
	return boid

# create boid area3D
func createArea3D() -> Area3D:
	var area3d: Area3D = Area3D.new()
	area3d.add_child(createSphereCollision())
	return area3d
	
# create boid area3D sphere collision shape
func createSphereCollision() -> CollisionShape3D:
	var collisionShape: CollisionShape3D = CollisionShape3D.new()
	var sphereShape: SphereShape3D = SphereShape3D.new()
	sphereShape.radius = BoidConfigV1.sphereRadius / BoidConfigV1.boidScale.length()
	collisionShape.shape = sphereShape
	return collisionShape 
