extends Node3D

@export var covered := false:
	set(value):
		covered = value
		$Mesh.visible = !covered
