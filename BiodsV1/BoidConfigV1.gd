extends Node

## Calculations
# steer to avoid crowding
var separationMod: float = 15
# steer towards average heading
var alignmentMod: float = 0.05
# steer towards average position
var cohesionMod: float = 0.05

var separationRangeSquared: float = 10
var minSpeed: float = 15
var maxSpeed: float = 30

# keep boid in bounds
var xBound: float = 50
var yBound: float = 30
var zBound: float = 30
var turnFactor: float = 2

## Boid Generation
# Area3D
var sphereRadius: float = 5
var numBoids: int = 1000
var boidImg: Texture2D = preload("res://BoidArrow.png")
var boidScale: Vector3 = Vector3(3, 3, 3)
