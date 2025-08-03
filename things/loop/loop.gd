@tool
extends Node3D

enum LoopColor {
	GRAY,
	BLUE,
	GREEN,
	RED,
	CYAN,
	YELLOW,
	MAGENTA,
	TURQUOISE,
	ORANGE,
	PURPLE,
}

@export var color := LoopColor.GRAY:
	set(value):
		color = value
		recolor()

@export var x1 := -2.0:
	set(value):
		x1 = value
		rebuild()
@export var z1 := -3.0:
	set(value):
		z1 = value
		rebuild()
@export var x2 := 2.0:
	set(value):
		x2 = value
		rebuild()
@export var z2 := 3.0:
	set(value):
		z2 = value
		rebuild()

@onready var node_1: Node3D = $Node1
@onready var node_2: Node3D = $Node2
@onready var node_3: Node3D = $Node3
@onready var node_4: Node3D = $Node4

@onready var corner_1: MeshInstance3D = %Corner1
@onready var segment_1: MeshInstance3D = %Segment1
@onready var corner_2: MeshInstance3D = %Corner2
@onready var segment_2: MeshInstance3D = %Segment2
@onready var corner_3: MeshInstance3D = %Corner3
@onready var segment_3: MeshInstance3D = %Segment3
@onready var corner_4: MeshInstance3D = %Corner4
@onready var segment_4: MeshInstance3D = %Segment4

@onready var point_1: MeshInstance3D = %Point1
@onready var cap_1a: MeshInstance3D = %Cap1a
@onready var cap_1b: MeshInstance3D = %Cap1b
@onready var cap_2: MeshInstance3D = %Cap2
@onready var cap_4: MeshInstance3D = %Cap4


func _ready() -> void:
	rebuild()
	recolor()


func rebuild():
	if not is_inside_tree():
		return;
	node_1.position = Vector3(x1, 0, z1)
	
	segment_1.position.x = x1
	segment_1.position.z = (z2 + z1) / 2
	segment_1.scale.x = abs(z2 - z1) - 1.0
	
	node_2.position = Vector3(x1, 0, z2)
	
	segment_2.position.z = z2
	segment_2.position.x = (x2 + x1) / 2
	segment_2.scale.x = abs(x2 - x1) - 1.0
	
	node_3.position = Vector3(x2, 0, z2)
	
	segment_3.position.x = x2
	segment_3.position.z = (z2 + z1) / 2
	segment_3.scale.x = abs(z2 - z1) - 1.0
	
	node_4.position = Vector3(x2, 0, z1)
	
	segment_4.position.z = z1
	segment_4.position.x = (x2 + x1) / 2
	segment_4.scale.x = abs(x2 - x1) - 1.0
	

	var x_flip = x2 < x1
	var z_flip = z2 < z1
	var s = Vector3(1, 1, 1)
	if x_flip and z_flip:
		s = Vector3(-1, 1, -1)
	elif x_flip:
		s = Vector3(-1, -1, 1)
	elif z_flip:
		s = Vector3(1, -1, -1)
	node_1.scale = s
	node_2.scale = s
	node_3.scale = s
	node_4.scale = s
	
	
	for child in get_children():
		child.hide()
		for subchild in child.get_children():
			subchild.hide()
	node_1.show()
	node_2.show()
	node_3.show()
	node_4.show()
	var x_degen = abs(x2 - x1) < 0.1
	var z_degen = abs(z2 - z1) < 0.1
	if x_degen and z_degen:
		point_1.show()
	elif x_degen:
		cap_1a.show()
		segment_1.show()
		cap_2.show()
	elif z_degen:
		cap_1b.show()
		segment_4.show()
		cap_4.show()
	else:
		corner_1.show()
		segment_1.show()
		corner_2.show()
		segment_2.show()
		corner_3.show()
		segment_3.show()
		corner_4.show()
		segment_4.show()

func recolor():
	if not is_inside_tree():
		return;
	var c = Color(0, 0, 0)
	match color:
		LoopColor.GRAY:
			c = Color(0.5, 0.5, 0.5)
		LoopColor.BLUE:
			c = Color(0, 0, .6)
		LoopColor.GREEN:
			c = Color(0, .6, 0)
		LoopColor.RED:
			c = Color(.6, 0, 0)
		LoopColor.CYAN:
			c = Color(0, .6, .6)
		LoopColor.YELLOW:
			c = Color(.6, .6, 0)
		LoopColor.MAGENTA:
			c = Color(.7, 0, .7)
		LoopColor.TURQUOISE:
			c = Color(0, .4, .4)
		LoopColor.ORANGE:
			c = Color(.7, .4, 0)
		LoopColor.PURPLE:
			c = Color(.4, 0, .7)
	corner_1.material_override.albedo_color = c;

func get_points():
	# TODO: this feels pretty terrible
	var result = []
	for x in range(min(round(x1), round(x2)), max(round(x1), round(x2)) + 1) :
		result.push_back(Vector3(x, 0, z1))
		result.push_back(Vector3(x, 0, z2))
	for z in range(min(round(z1), round(z2)) + 1, max(round(z1), round(z2))):
		result.push_back(Vector3(x1, 0, z))
		result.push_back(Vector3(x2, 0, z))
	return result
