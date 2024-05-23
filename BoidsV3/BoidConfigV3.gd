extends Node

## Calculations
# steer to avoid crowding
var separationMod: float = 0.1
# steer towards average heading
var alignmentMod: float = 0.2
# steer towards average position
var cohesionMod: float = 0.5

var separationRangeSquared: float = 5
var minSpeed: float = 15
var maxSpeed: float = 20

# keep boid in bounds
var xBound: float = 20
var yBound: float = 10
var zBound: float = 10
var turnFactor: float = 5

## Spatial Grid
# size of each 3d cube in the grid
# try to make this a factor of the bounds or else there may be unexpected results
var spatialGridSize: int = 2
