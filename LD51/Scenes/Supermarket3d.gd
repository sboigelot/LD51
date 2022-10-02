extends Spatial

class_name Supermarket3d

var scan_package: Package

export(NodePath) var camera_np
export(NodePath) var scan_camera_np
export(NodePath) var scan_package_holder_np
export(NodePath) var supermarket2d_np
export(NodePath) var hand_node_np
export(NodePath) var scanner_np
export(NodePath) var scanner_screen_texturerect_np
export(NodePath) var scanner_screen_center_np
export(NodePath) var scanner_laser_np
export(NodePath) var scanner_anim_np
export(NodePath) var scanner_on_charger_np
export(NodePath) var debug_label_np

onready var camera = get_node(camera_np) as Camera
onready var scan_camera = get_node(scan_camera_np) as Camera
onready var scan_package_holder = get_node(scan_package_holder_np) as Spatial
onready var hand_node = get_node(hand_node_np) as Node2D
onready var scanner = get_node(scanner_np) as Sprite
onready var scanner_screen_texturerect = get_node(scanner_screen_texturerect_np) as TextureRect
onready var scanner_screen_center = get_node(scanner_screen_center_np) as Position2D
onready var scanner_laser = get_node(scanner_laser_np) as Line2D
onready var scanner_anim = get_node(scanner_anim_np) as AnimationPlayer
onready var scanner_on_charger = get_node(scanner_on_charger_np) as Sprite
onready var debug_label = get_node(debug_label_np) as Label

export(float) var hand_min_y

export(bool) var scanner_in_hands setget set_scanner_hands, get_scanner_hands
func set_scanner_hands(value:bool):
	scanner.visible = value
	scanner_on_charger.visible = not value
func get_scanner_hands():
	return scanner.visible

func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_scanner_hands(false)
#	set_viewport_texture()

	if scan_package_holder.get_child_count() >= 1:
		scan_package = scan_package_holder.get_child(0)
	spawn_package()

func set_viewport_texture(viewport:Viewport):
	var path = viewport.get_path()
	var texture = ViewportTexture.new()
	texture.viewport_path = path
	scanner_screen_texturerect.texture = texture

func _process(delta):
	process_keyboard_rotate()
	move_hand_to_cursor()
	toggle_scan_anim()
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
	hand_node.position = mouse_postion
	
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if hand_node.position.y < hand_min_y:
		hand_node.position.y = hand_min_y
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func toggle_scan_anim():
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
		package.transform = Transform()
		scan_package = package

func _physics_process(delta):

	var direction = Vector3.RIGHT
	var velocity = direction * conveyor_speed

	for child in $ConveyorBelt.get_children():
		if child is Package:
			var package = child as Package
			package.move_and_slide(velocity * delta)

func move_scan_camera():
	var screen_extend = Vector2(8.65,4.75)
	var cam_translation_range = screen_extend * 2

	var mouse_postion = get_viewport().get_mouse_position() as Vector2
	var mouse_screen_percentage = Vector2(
		mouse_postion.x / OS.window_size.x,
		mouse_postion.y / OS.window_size.y
	)
	
	var scanner_position = scanner_screen_center.global_position
	var scanner_position_screen_percentage = Vector2(
		scanner_position.x / OS.window_size.x,
		scanner_position.y / OS.window_size.y
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
