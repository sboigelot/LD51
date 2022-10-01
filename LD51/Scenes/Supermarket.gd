extends Node2D

export(NodePath) var supermarket3d_np
onready var supermarket3d = get_node(supermarket3d_np) as Supermarket3d


export(NodePath) var debug_rtl_np
onready var debug_rtl = get_node(debug_rtl_np) as RichTextLabel

func _process(delta):		
	debug_rtl.text = "x: %d\ny: %d\nz: %d" % [
		supermarket3d.scan_package.package_model.rotation_degrees.x,
		supermarket3d.scan_package.package_model.rotation_degrees.y,
		supermarket3d.scan_package.package_model.rotation_degrees.z
	]
	
	if Input.is_action_just_pressed("ui_down"):
		_on_DownButton_pressed()
	if Input.is_action_just_pressed("ui_up"):
		_on_UpButton_pressed()
	if Input.is_action_just_pressed("ui_left"):
		_on_LeftButton_pressed()
	if Input.is_action_just_pressed("ui_right"):
		_on_RightButton_pressed()

func _on_DownButton_pressed():
	supermarket3d.rotate_package(Vector2(90,0))

func _on_UpButton_pressed():
	supermarket3d.rotate_package(Vector2(-90,0))

func _on_LeftButton_pressed():
	supermarket3d.rotate_package(Vector2(0,90))

func _on_RightButton_pressed():
	supermarket3d.rotate_package(Vector2(0,-90))
