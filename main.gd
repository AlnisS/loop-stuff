extends Node3D

const LOOP = preload("res://things/loop/loop.tscn")

const RAY_LENGTH = 1000

var hovered_tile: Node3D = null
var dloop: Node3D = null
var is_drawing_loop := false
var next_color = 1

func _physics_process(delta):
	update_hovered_tile()
	
	if hovered_tile:
		if Input.is_action_just_pressed("click"):
			is_drawing_loop = true
		if !dloop:
			dloop = LOOP.instantiate()
			dloop.x1 = hovered_tile.position.x
			dloop.x2 = hovered_tile.position.x
			dloop.z1 = hovered_tile.position.z
			dloop.z2 = hovered_tile.position.z
			dloop.color = 0  # gray
			dloop.position.y = 0.2
			$Level/Loops.add_child(dloop)
		if !is_drawing_loop:
			dloop.x1 = hovered_tile.position.x
			dloop.z1 = hovered_tile.position.z
		dloop.x2 = hovered_tile.position.x
		dloop.z2 = hovered_tile.position.z

	if Input.is_action_just_released("click"):
		# TODO: does this always clean up properly?
		is_drawing_loop = false
		if dloop:
			if is_dloop_valid():
				remove_overlapping_loops()
				advance_next_color()
				dloop.position.y = 0
				dloop = null
			else:
				dloop.queue_free()
				dloop = null
	
	# remove placeholder loop when mouse isn't over a tile
	if !hovered_tile and !is_drawing_loop and dloop:
		dloop.queue_free()
		dloop = null
	
	if dloop:
		if is_dloop_valid():
			dloop.color = next_color
		else:
			dloop.color = 0
	# TODO: check loop validity & color based on whether it is OK
	
	recalculate_covered_tiles()

func is_dloop_valid() -> bool:
	if abs(dloop.x1 - dloop.x2) < 0.9:
		return false
	if abs(dloop.z1 - dloop.z2) < 0.9:
		return false
	return true

func remove_overlapping_loops():
	if dloop:
		var d_points = dloop.get_points()
		for l in $Level/Loops.get_children():
			if dloop != l:
				remove_if_overlaps(l, d_points)

func remove_if_overlaps(l, pts):
	for lp in l.get_points():
		for pt in pts:
			if is_equal_approx(lp.x, pt.x) and is_equal_approx(lp.z, pt.z):
				l.queue_free()
				return

func advance_next_color():
	next_color += 1
	if next_color > 9:
		next_color = 1

func recalculate_covered_tiles():
	var covered = []
	for loop in $Level/Loops.get_children():
		covered.append_array(loop.get_points())
	for tile in $Level/Tiles.get_children():
		tile.covered = false
		for point in covered:
			if is_equal_approx(point.x, tile.position.x) and is_equal_approx(point.z, tile.position.z):
				tile.covered = true
				break

func update_hovered_tile():
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	var result = space_state.intersect_ray(query)
	if result:
		var collider: StaticBody3D = result.collider
		var tile: Node3D = collider.get_parent()
		hovered_tile = tile
	else:
		hovered_tile = null
