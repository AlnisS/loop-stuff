extends Node3D

const LOOP = preload("res://things/loop/loop.tscn")

const RAY_LENGTH = 1000

var hovered_tile: Node3D = null
var dloop: Node3D = null
var is_drawing_loop := false
var next_color = 1
var remaining_tiles = -1

var hovered_button = null

@onready var level = $Levels/Level1

var done = false
var time = 0.0


const FOLLOW_SPEED = 4.0

func _process(delta):
	# https://docs.godotengine.org/en/4.4/tutorials/math/interpolation.html#smoothing-motion
	var target_pos = level.position
	var weight = 1 - exp(-FOLLOW_SPEED * delta)
	$CameraBase.position = $CameraBase.position.lerp(target_pos, weight)

func _physics_process(delta):
	if !done:
		time += delta
		var minutes = floor(time / 60.0)
		var seconds = time - (minutes * 60.0)
		var bonus = "0" if seconds < 10 else ""
		$Levels/LevelLast/TotalTime.text = "Time: " + str(int(minutes)) + ":" + bonus + "%00.3f" % seconds
	
	var total_score = 0
	for l in $Levels.get_children():
		total_score += int(l.get_node("Score").text)
	$Levels/LevelLast/TotalScore.text = "Score: " + str(total_score)
	
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
			dloop.position = Vector3(0.002, 0.01, 0.002)
			level.get_node("Loops").add_child(dloop)
		if !is_drawing_loop:
			dloop.x1 = hovered_tile.position.x
			dloop.z1 = hovered_tile.position.z
		dloop.x2 = hovered_tile.position.x
		dloop.z2 = hovered_tile.position.z

	if Input.is_action_just_released("click"):
		is_drawing_loop = false
		if dloop:
			if is_dloop_valid():
				remove_overlapping_loops()
				advance_next_color()
				dloop.position = Vector3.ZERO
				dloop = null
				$Smack.play()
			else:
				if is_equal_approx(dloop.x1, dloop.x2) and is_equal_approx(dloop.z1, dloop.z2):
					remove_overlapping_loops()
				dloop.queue_free()
				dloop = null
	
	# remove placeholder point-loop when mouse isn't over a tile
	if !hovered_tile and !is_drawing_loop and dloop:
		dloop.queue_free()
		dloop = null
	
	if dloop:
		if is_dloop_valid():
			dloop.color = next_color
		else:
			dloop.color = 0
	
	recalculate_covered_tiles()
	recalculate_score()
	
	if Input.is_action_just_pressed("click"):
		if hovered_button == "Back":
			level = level.get_parent().get_child(level.get_index() - 1)
	
	if Input.is_action_just_pressed("ui_left"):
		var idx = level.get_index() - 1
		if idx >= 0:
			level = level.get_parent().get_child(idx)
	
	var next_button = null
	for node in level.get_children():
		if node.name.begins_with("Next"):
			next_button = node
			break
	
	if remaining_tiles == 0 or true:
		if next_button:
			next_button.show()
		if Input.is_action_just_pressed("click"):
			if hovered_button == "Next":
				level = level.get_parent().get_child(level.get_index() + 1)
		elif Input.is_action_just_pressed("ui_right"):
			var nl = level.get_parent().get_child(level.get_index() + 1)
			if nl:
				level = nl
	else:
		next_button.hide()
	
	if level.get_index() == level.get_parent().get_child_count() - 1:
		done = true

func is_dloop_valid() -> bool:
	if abs(dloop.x1 - dloop.x2) < 0.9:
		return false
	if abs(dloop.z1 - dloop.z2) < 0.9:
		return false
	for point in dloop.get_points():
		var point_ok = false
		for tile in level.get_node("Tiles").get_children():
			if is_equal_approx(point.x, tile.position.x) and is_equal_approx(point.z, tile.position.z):
				point_ok = true
				break
		if not point_ok:
			return false
	return true

func remove_overlapping_loops():
	if dloop:
		var d_points = dloop.get_points()
		for l in level.get_node("Loops").get_children():
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
	for loop in level.get_node("Loops").get_children():
		covered.append_array(loop.get_points())
	for tile in level.get_node("Tiles").get_children():
		tile.covered = false
		for point in covered:
			if is_equal_approx(point.x, tile.position.x) and is_equal_approx(point.z, tile.position.z):
				tile.covered = true
				break
	remaining_tiles = 0
	for tile in level.get_node("Tiles").get_children():
		if !tile.covered:
			remaining_tiles += 1

func recalculate_score():
	var score = 0.0
	for loop in level.get_node("Loops").get_children():
		if is_equal_approx(loop.x1, loop.x2) or is_equal_approx(loop.z1, loop.z2):
			continue
		var w = round(abs(loop.x1 - loop.x2))
		var h = round(abs(loop.z1 - loop.z2))
		var a = (w - 1) * (h - 1)
		score += a
	level.get_node("Score").text = str(int(round(score)))

func update_hovered_tile():
	var space_state = get_world_3d().direct_space_state
	var cam = %Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	var result = space_state.intersect_ray(query)
	var old_hovered_tile = hovered_tile
	hovered_tile = null
	hovered_button = null
	if result:
		var collider: StaticBody3D = result.collider
		if collider.collision_layer & 1:
			var tile: Node3D = collider.get_parent()
			hovered_tile = tile
			if hovered_tile != old_hovered_tile:
				$Tick.play()
		
		if collider.collision_layer & 2:
			var label: Label3D = collider.get_parent()
			hovered_button = label.name
		
