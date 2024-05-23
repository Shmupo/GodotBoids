class_name BoidGeneratorV2
extends Node

var spatialGrid: SpatialGridV1 = SpatialGridV1.new()

func _ready():
	generateNBoids()

# randomize boid placement within bounds upon creation
func placeBoidRandInBounds(boid: BoidV2) -> void:
	boid.position = Vector3(
		randf_range(-BoidConfigV1.xBound, BoidConfigV1.xBound),
		randf_range(-BoidConfigV1.yBound, BoidConfigV1.yBound),
		randf_range(-BoidConfigV1.zBound, BoidConfigV1.zBound),
		)
		
# randomize boid speed upon creation
func setBoidRandSpeed(boid: BoidV2) -> void:
	boid.velocity = Vector3(
		randf_range(-BoidConfigV1.maxSpeed, BoidConfigV1.maxSpeed),
		randf_range(-BoidConfigV1.maxSpeed, BoidConfigV1.maxSpeed),
		randf_range(-BoidConfigV1.maxSpeed, BoidConfigV1.maxSpeed),
	)

func generateNBoids() -> void:
	for x in BoidConfigV2.numBoids:
		var boidV2: BoidV2 = createBoidV2()
		boidV2.spatialGrid = spatialGrid
		setBoidRandSpeed(boidV2)
		placeBoidRandInBounds(boidV2)
		
		spatialGrid.boids.append(boidV2)
		
		add_child(boidV2)
		
func createBoidV2() -> BoidV2:
	var boidV2: BoidV2 = BoidV2.new()
	boidV2.texture = BoidConfigV2.boidImg
	boidV2.scale = BoidConfigV2.boidScale
	return boidV2

func _process(delta):
	spatialGrid.updateGridAndBoids(delta)
