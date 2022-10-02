extends Spatial

class_name Supermarket3d

export(NodePath) var camera_np
export(NodePath) var scan_camera_np
export(NodePath) var scan_package_holder_np
export(NodePath) var supermarket2d_np
export(NodePath) var hand_node_np
export(NodePath) var scanner_np
export(NodePath) var scanner_screen_texturerect_np
export(NodePath) var scanner_screen_center_np
export(NodePath) var scanner_error_screen_np
export(NodePath) var scanner_laser_np
export(NodePath) var scanner_anim_np
export(NodePath) var scanner_on_charger_np
export(NodePath) var debug_label_np
export(NodePath) var keyboard_line_edit_np
export(NodePath) var keyboard_error_label_np

onready var camera = get_node(camera_np) as Camera
onready var scan_camera = get_node(scan_camera_np) as Camera
onready var scan_package_holder = get_node(scan_package_holder_np) as Spatial
onready var hand_node = get_node(hand_node_np) as Node2D
onready var scanner = get_node(scanner_np) as Sprite
onready var scanner_screen_texturerect = get_node(scanner_screen_texturerect_np) as TextureRect
onready var scanner_screen_center = get_node(scanner_screen_center_np) as Position2D
onready var scanner_error_screen = get_node(scanner_error_screen_np) as TextureRect
onready var scanner_laser = get_node(scanner_laser_np) as Line2D
onready var scanner_anim = get_node(scanner_anim_np) as AnimationPlayer
onready var scanner_on_charger = get_node(scanner_on_charger_np) as Sprite
onready var debug_label = get_node(debug_label_np) as Label
onready var keyboard_line_edit = get_node(keyboard_line_edit_np) as LineEdit
onready var keyboard_error_label = get_node(keyboard_error_label_np) as Label

var hand_node_offset: Vector2

export(float) var hand_min_y = 550

export(bool) var scanner_in_hands setget set_scanner_hands, get_scanner_hands
func set_scanner_hands(value:bool):
	scanner.visible = value
	scanner_on_charger.visible = not value
	if value:
		hand_node_offset = Vector2(-15,80)
	else: 
		hand_node_offset = Vector2()
func get_scanner_hands():
	return scanner.visible

var scan_package: Package

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_scanner_hands(false)
#	set_viewport_texture()
	set_editor_azerty()

	if scan_package_holder.get_child_count() >= 1:
#		scan_package = scan_package_holder.get_child(0)
		scan_package_holder.get_child(0).queue_free()
	spawn_package()
	
	scanner_error_screen.visible = false
	keyboard_line_edit.visible = false
	keyboard_error_label.visible = false
	
func set_editor_azerty():
	if not OS.is_debug_build():
		return
		
	change_keybind("ui_up", KEY_Z)
	change_keybind("ui_left", KEY_Q)
	
func change_keybind(action_name, scan_code):
	var actions = InputMap.get_action_list(action_name)
	var last_action = actions[actions.size() - 1] as InputEventKey
	last_action.scancode = scan_code
		
func set_viewport_texture(viewport:Viewport):
	var path = viewport.get_path()
	var texture = ViewportTexture.new()
	texture.viewport_path = path
	scanner_screen_texturerect.texture = texture

func _process(delta):
	process_keyboard_rotate()
	move_hand_to_cursor()
	toggle_scan_anim(delta)
	move_scan_camera()

func process_keyboard_rotate():
	if Input.is_action_just_pressed("ui_down"):
		_on_DownButton_pressed()
	if Input.is_action_just_pressed("ui_up"):
		_on_UpButton_pressed()
	if Input.is_action_just_pressed("ui_left"):
		_on_LeftButton_pressed()
	if Input.is_action_just_pressed("ui_right"):
		_on_RightButton_pressed()

func move_hand_to_cursor():
#	hand_node.position = get_global_mouse_position()
	var mouse_postion = get_viewport().get_mouse_position() as Vector2
	hand_node.position = mouse_postion + hand_node_offset
	
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if hand_node.position.y < hand_min_y:
		hand_node.position.y = hand_min_y
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func toggle_scan_anim(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if get_scanner_hands():
			if not scanner_anim.is_playing():
				scanner_anim.play("Scan")
				scanner_laser.visible = true
	else:
		scanner_laser.visible = false
		if scanner_anim.is_playing():
			scanner_anim.stop()
			
func _on_DownButton_pressed():
	rotate_package(Vector2(90,0))

func _on_UpButton_pressed():
	rotate_package(Vector2(-90,0))

func _on_LeftButton_pressed():
	rotate_package(Vector2(0,90))

func _on_RightButton_pressed():
	rotate_package(Vector2(0,-90))

func _on_ScannerChargerButton_pressed():
	set_scanner_hands(not get_scanner_hands())
	
export(Vector3) var package_scale_on_belt = Vector3(0.75,0.75,0.75)

export(float) var conveyor_speed = 60.0

const package_scene = preload("res://Scenes/Package.tscn")

func _on_Supermarket_rotate_package(add_rotation):
	rotate_package(add_rotation)

func rotate_package(add_rotation: Vector2):
	if scan_package == null:
		return
	scan_package.add_to_target_rotation(add_rotation)

func _on_Timer_timeout():
	spawn_package()

func spawn_package():
	var instance = package_scene.instance()
	var spawn_positions = [
		$ConveyorBelt/PackageSpawnLocations/Location1.transform,
		$ConveyorBelt/PackageSpawnLocations/Location2.transform,
		$ConveyorBelt/PackageSpawnLocations/Location3.transform,
		$ConveyorBelt/PackageSpawnLocations/Location4.transform,
	]
	instance.transform = spawn_positions[randi() % spawn_positions.size()]
	instance.connect("clicked", self, "on_conveyor_belt_package_clicked")

#	Rotate randomly
	var axis = Vector3.UP
	var rotation_radiant = deg2rad(randi() % 360)
	instance.transform.basis = instance.transform.basis.rotated(axis, rotation_radiant)

#	scale
	instance.scale = package_scale_on_belt
	$ConveyorBelt.add_child(instance)

func on_conveyor_belt_package_clicked(package: Package):
	if scan_package_holder.get_child_count() == 0:
		package.get_parent().remove_child(package)
		scan_package_holder.add_child(package)
		package.disconnect("clicked", self, "on_conveyor_belt_package_clicked")
		package.connect("barcode_scanned", self, "_on_Package_barcode_scanned")
		package.connect("scan_error", self, "_on_Package_scan_error")
		package.transform = Transform()
		scan_package = package

func _on_Package_barcode_scanned(package, barcode):
	if get_scanner_hands():
			move_package_to_exit_belt(package)

func _on_Package_scan_error(package, barcode):
	scanner_error_screen.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	scanner_error_screen.visible = false

func move_package_to_exit_belt(package: Package):
	if scan_package_holder.get_child_count() == 0:
		return
	package.get_parent().remove_child(package)
	$ConveyorBelt2.add_child(package)
	var spawn_positions = [
		$ConveyorBelt2/PackageSpawnLocations/Location1.transform,
		$ConveyorBelt2/PackageSpawnLocations/Location2.transform,
		$ConveyorBelt2/PackageSpawnLocations/Location3.transform,
		$ConveyorBelt2/PackageSpawnLocations/Location4.transform,
	]
	package.transform = spawn_positions[randi() % spawn_positions.size()]

func _physics_process(delta):
	move_package_in_coveryor_belt(delta, $ConveyorBelt)
	move_package_in_coveryor_belt(delta, $ConveyorBelt2)
	free_exited_packages($ConveyorBelt2)
	
func move_package_in_coveryor_belt(delta, belt):
	var direction = Vector3.RIGHT
	var velocity = direction * conveyor_speed

	for child in belt.get_children():
		if child is Package:
			var package = child as Package
			package.move_and_slide(velocity * delta)

func free_exited_packages(belt):
	for child in belt.get_children():
		if child is Package and child.translation.x > 10:
			var package = child as Package
			package.queue_free()

func move_scan_camera():
	var screen_extend = Vector2(8.65,4.75)
	var cam_translation_range = screen_extend * 2

	var fullscreen_pixel_size = OS.window_size
	fullscreen_pixel_size = Vector2(1920,1080)

	var mouse_postion = get_viewport().get_mouse_position() as Vector2
	var mouse_screen_percentage = Vector2(
		mouse_postion.x / fullscreen_pixel_size.x,
		mouse_postion.y / fullscreen_pixel_size.y
	)
	
	var scanner_position = scanner_screen_center.global_position
	var scanner_position_screen_percentage = Vector2(
		scanner_position.x / fullscreen_pixel_size.x,
		scanner_position.y / fullscreen_pixel_size.y
	)

	scan_camera.translation.x = (scanner_position_screen_percentage.x * cam_translation_range.x) - screen_extend.x
	scan_camera.translation.z = (scanner_position_screen_percentage.y * cam_translation_range.y) - screen_extend.y

	debug_label.text = ("mouse%%:\n\tx: %s\n\ty: %s\n"%[
		round(mouse_screen_percentage.x*100),
		round(mouse_screen_percentage.y*100)
	] +
	"screen center%%:\n\tx: %s\n\ty: %s\n"%[
		round(scanner_position_screen_percentage.x*100),
		round(scanner_position_screen_percentage.y*100)
	] +
	"cam translation:\n\tx: %s\n\tzx: %s\n"%[
		scan_camera.translation.x,
		scan_camera.translation.z
	])

func _on_KeyboardButton_pressed():
	keyboard_line_edit.text = ""
	keyboard_line_edit.visible = true
	keyboard_line_edit.grab_focus()
	set_scanner_hands(false)

func _on_KeyboardLineEdit_text_entered(new_text):
	keyboard_line_edit.visible = false
	var numbers = []
	for character in new_text:
		numbers.append(int(character))
	
	if scan_package != null:
		var solution = scan_package.barcode.numbers
		if solution.size() != numbers.size():
			blink_keyboard_label()
			return
		for i in solution.size():
			if solution[i] != numbers[i]:
				blink_keyboard_label()
				return
		move_package_to_exit_belt(scan_package)
		
func blink_keyboard_label():
	keyboard_error_label.visible = true
	yield(get_tree().create_timer(0.4), "timeout")
	keyboard_error_label.visible = false
	
