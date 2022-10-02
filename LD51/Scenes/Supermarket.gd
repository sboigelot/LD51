extends Node2D

export(NodePath) var supermarket3d_np
onready var supermarket3d = get_node(supermarket3d_np) as Supermarket3d

export(NodePath) var debug_rtl_np
onready var debug_rtl = get_node(debug_rtl_np) as RichTextLabel

export(NodePath) var hand_node_np
onready var hand_node = get_node(hand_node_np) as Node2D
export(float) var hand_min_y

export(NodePath) var scanner_np
onready var scanner = get_node(scanner_np) as Sprite
export(NodePath) var scanner_laser_np
onready var scanner_laser = get_node(scanner_laser_np) as Line2D
export(NodePath) var scanner_anim_np
onready var scanner_anim = get_node(scanner_anim_np) as AnimationPlayer
export(NodePath) var scanner_on_charger_np
onready var scanner_on_charger = get_node(scanner_on_charger_np) as Sprite

export(bool) var scanner_in_hands setget set_scanner_hands, get_scanner_hands
func set_scanner_hands(value:bool):
	scanner.visible = value
	scanner_on_charger.visible = not value
func get_scanner_hands():
	return scanner.visible

func _ready():
	set_scanner_hands(false)

func _process(delta):
#	debug_rtl.text = "x: %d\ny: %d\nz: %d" % [
#		supermarket3d.scan_package.package_model.rotation_degrees.x,
#		supermarket3d.scan_package.package_model.rotation_degrees.y,
#		supermarket3d.scan_package.package_model.rotation_degrees.z
#	]
#
	if Input.is_action_just_pressed("ui_down"):
		_on_DownButton_pressed()
	if Input.is_action_just_pressed("ui_up"):
		_on_UpButton_pressed()
	if Input.is_action_just_pressed("ui_left"):
		_on_LeftButton_pressed()
	if Input.is_action_just_pressed("ui_right"):
		_on_RightButton_pressed()

	hand_node.position = get_global_mouse_position()
	if hand_node.position.y < hand_min_y:
		hand_node.position.y = hand_min_y
		
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
	supermarket3d.rotate_package(Vector2(90,0))

func _on_UpButton_pressed():
	supermarket3d.rotate_package(Vector2(-90,0))

func _on_LeftButton_pressed():
	supermarket3d.rotate_package(Vector2(0,90))

func _on_RightButton_pressed():
	supermarket3d.rotate_package(Vector2(0,-90))

func _on_ScannerChargerButton_pressed():
	set_scanner_hands(not get_scanner_hands())
