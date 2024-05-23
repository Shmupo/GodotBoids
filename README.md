# GodotBoids
Three versions of simulating boid clusters using Godot Engine 4.2

## HOW TO USE:
Godot Engine 4.2 will be required.
Place all files as they are into a folder.
Open the godot project manager and press import.
Once imported, you should get an option to run the project.

### Different Scenes
Each version of the boids are split into different scenes of simlar name within each BoidsV# folder.
Simply run these scenes.
To change configurations, such as force modifiers and number of boids, refer to the InfoV#.txt and change the corresponding values within the BoidConfigV#.gd.
Note: For BoidV3, changing the number of boids is different - see InfoV3.txt.

The naming of components are based of the iteration number, not what version of Boids they are filed in.
Example: SpatialGridV1 is located within the BoidsV2 file because it is the first iteration of the SpatialGrid.

Included in each scene is a simple Label node that displays the fps grabbed directly from the engine.

## V1 - Area3D
This version uses a Sprite3D node, and Area3D, and SphereCollisionShape.
Neighbor detection is done via signaling by the Area3D.
When a node enters the SphereCollisionShape, it is added to the boid's array of neighbor boids to perform calculations.
Initialization of boids is slow.
This version is the most accurate among the other versions, but not the most optimal.
See BoidsV1/InfoV1.text for more info and how to play with the settings.

## V2 - Spatial Grid
This version uses a spatial grid to obtain neighbor boids, rather than an Area3D.
Boids only consist of a single Sprite3D, leading to fast initialization.
The spatial grid, however is not optimal and actually leads to worse performance than V1 in some cases.
See BoidsV2/InfoV2.txt for more info and how to play with the settings.

## V3 - Spatial Hash Grid + Multimesh instancing
This version effectively utilizes the capabilities of Godot, as well as a more optimized Spatial Hash Grid.
This can easily run hundreds of boids (2k at 100fps on my computer).
Boids are drawn using a multimesh, effectively utilizing the GPU much more efficiently.
Calculations are also done per grid cell within the spatial grid, reducing the repeated calculations for average values when calculating cohesion and alignment.
Initialization of boids is very fast.
This version is the most optimal, but does come with a cost to the accuracy of boid cluster behaviour, which is noticable around grid lines and depending on the configuration.
See BoidsV3/Infov3.txt for more info and how to play with the settings.

## Calculations
In general, the cohesion, alignment, and separation calculation are as follows : 
  Alignment : (averageHeading - boidVelocity) * alignmentModifier
  Cohesion : ((average position - boidPosition) - boidVelocity ) * cohesionModifier
  Separation : (boidPosition - neighborPosition) * separationModifier

