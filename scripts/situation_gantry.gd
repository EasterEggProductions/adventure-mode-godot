extends Node3D

@onready var raycast: RayCast3D = $RayCast3D
# Reference to the player node. Adjust the path according to your scene tree structure.
var player_path: String = "/root/level_test/actor"
var player: CharacterBody3D

func _ready():
    raycast.enabled = true
    # Ensure the player node exists and is accessible.
    if has_node(player_path):
        player = get_node(player_path) as Node3D

func _physics_process(delta):
    if player:
        # Update the TerrainDetector's position to be right above/below the player.
        # This example assumes you want it to hover a certain distance directly above the player.
        # Adjust the Vector3 offset as needed for your game's logic.
        global_transform.origin = player.global_transform.origin + Vector3(0, -1, 0)

        var ray_start_position = player.global_transform.origin + Vector3(2 , 0, 0)
        global_transform.origin = ray_start_position

        if raycast.is_colliding():
            var collision_detection = raycast.get_collider()
            if collision_detection:
                print("COLLIDING WITH", collision_detection.get_parent().name)
            else:
                print("NO NAME PROPERTY MAYBE")
        else:
            print("NO COLLISION AT ALL")

