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


@onready var corner_1: MeshInstance3D = %Corner1
@onready var segment_1: MeshInstance3D = %Segment1
@onready var corner_2: MeshInstance3D = %Corner2
@onready var segment_2: MeshInstance3D = %Segment2
@onready var corner_3: MeshInstance3D = %Corner3
@onready var segment_3: MeshInstance3D = %Segment3
@onready var corner_4: MeshInstance3D = %Corner4
@onready var segment_4: MeshInstance3D = %Segment4

func _ready() -> void:
	#pass
	rebuild()
	recolor()

#func _process(_delta: float) -> void:
	#rebuild()
	#recolor()

func rebuild():
	if not is_inside_tree():
		return;
	corner_1.position.x = x1
	corner_1.position.z = z1
	
	segment_1.position.x = x1
	segment_1.position.z = (z2 + z1) / 2
	segment_1.scale.x = (z2 - z1) - 1.0
	
	corner_2.position.x = x1
	corner_2.position.z = z2
	
	segment_2.position.z = z2
	segment_2.position.x = (x2 + x1) / 2
	segment_2.scale.x = (x2 - x1) - 1.0
	
	corner_3.position.x = x2
	corner_3.position.z = z2
	
	segment_3.position.x = x2
	segment_3.position.z = (z2 + z1) / 2
	segment_3.scale.x = (z2 - z1) - 1.0
	
	corner_4.position.x = x2
	corner_4.position.z = z1
	
	segment_4.position.z = z1
	segment_4.position.x = (x2 + x1) / 2
	segment_4.scale.x = (x2 - x1) - 1.0

func recolor():
	if not is_inside_tree():
		return;
	var c = Color(0, 0, 0)
	match color:
		LoopColor.GRAY:
			c = Color(0.5, 0.5, 0.5)
		LoopColor.BLUE:
			c = Color(0, 0, .7)
		LoopColor.GREEN:
			c = Color(0, .7, 0)
		LoopColor.RED:
			c = Color(.7, 0, 0)
		LoopColor.CYAN:
			c = Color(0, .7, .7)
		LoopColor.YELLOW:
			c = Color(.7, .7, 0)
		LoopColor.MAGENTA:
			c = Color(.7, 0, .7)
		LoopColor.TURQUOISE:
			c = Color(0, .4, .4)
		LoopColor.ORANGE:
			c = Color(.7, .4, 0)
		LoopColor.PURPLE:
			c = Color(.4, 0, .7)
	corner_1.material_override.albedo_color = c;
