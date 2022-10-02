extends Node2D
class_name Supermarket2d

signal rotate_package(add_rotation)

export(NodePath) var hand_node_np
export(NodePath) var scanner_np
export(NodePath) var scanner_texturerect_np
export(NodePath) var scanner_screen_center_np
export(NodePath) var scanner_laser_np
export(NodePath) var scanner_anim_np
export(NodePath) var scanner_on_charger_np
export(NodePath) var scanner_test_label_np

onready var hand_node = get_node(hand_node_np) as Node2D
onready var scanner = get_node(scanner_np) as Sprite
onready var scanner_texturerect = get_node(scanner_texturerect_np) as TextureRect
onready var scanner_screen_center = get_node(scanner_screen_center_np) as Position2D
onready var scanner_laser = get_node(scanner_laser_np) as Line2D
onready var scanner_anim = get_node(scanner_anim_np) as AnimationPlayer
onready var scanner_on_charger = get_node(scanner_on_charger_np) as Sprite
onready var scanner_test_label = get_node(scanner_test_label_np) as Label

export(float) var hand_min_y

export(bool) var scanner_in_hands setget set_scanner_hands, get_scanner_hands
func set_scanner_hands(value:bool):
	scanner.visible = value
	scanner_on_charger.visible = not value
func get_scanner_hands():
	return scanner.visible

func set_viewport_texture(viewport:Viewport):
	var path = viewport.get_path()
	var texture = ViewportTexture.new()
	texture.viewport_path = path
	scanner_texturerect.texture = texture

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_scanner_hands(false)
#	set_viewport_texture()

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		_on_DownButton_pressed()
	if Input.is_action_just_pressed("ui_up"):
		_on_UpButton_pressed()
	if Input.is_action_just_pressed("ui_left"):
		_on_LeftButton_pressed()
	if Input.is_action_just_pressed("ui_right"):
		_on_RightButton_pressed()

	hand_node.position = get_global_mouse_position()
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if hand_node.position.y < hand_min_y:
		hand_node.position.y = hand_min_y
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
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
	emit_signal("rotate_package", Vector2(90,0))

func _on_UpButton_pressed():
	emit_signal("rotate_package", Vector2(-90,0))

func _on_LeftButton_pressed():
	emit_signal("rotate_package", Vector2(0,90))

func _on_RightButton_pressed():
	emit_signal("rotate_package", Vector2(0,-90))

func _on_ScannerChargerButton_pressed():
	set_scanner_hands(not get_scanner_hands())
