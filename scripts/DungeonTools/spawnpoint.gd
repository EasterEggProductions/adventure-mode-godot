@icon("res://art/textures/icons/icon_map_pointer.svg")
class_name Spawnpoint3D
extends Node3D

## A marker node that represents a spawnpoint in a scene.
## Used by ExitZone3Ds to identify valid destinations.

enum Subtype {
	DEFAULT,
	MULTIPLAYER,
	WALK_IN,
}

@export var subtype : Subtype = Subtype.DEFAULT
