extends Node

## Calculations
# steer to avoid crowding
var separationMod: float = 3
# steer towards average heading
var alignmentMod: float = 0.4
# steer towards average position
var cohesionMod: float = 0.2

var minSpeed: float = 15
var maxSpeed: float = 30

# keep boid in bounds
var xBound: float = 50
var yBound: float = 30
var zBound: float = 30
var turnFactor: float = 2

## Boid Generation
# Area3D
var numBoids: int = 250
var boidImg: Texture2D = preload("res://BoidArrow.png")
var boidScale: Vector3 = Vector3(3, 3, 3)

## Spatial Grid
# size of each 3d cube in the grid
# try to make this a factor of the bounds or else there may be unexpected results
var spatialGridSize: int = 5
