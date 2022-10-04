extends Spatial

class_name Supermarket3d

export(NodePath) var camera_np
export(NodePath) var scan_camera_np
export(NodePath) var scan_package_holder_np
export(NodePath) var button_panel_np
export(NodePath) var button_mesh_np
export(NodePath) var hand_node_np
export(NodePath) var scanner_np
export(NodePath) var scanner_screen_texturerect_np
export(NodePath) var scanner_screen_center_np
export(NodePath) var scanner_error_screen_np
export(NodePath) var scanner_disabled_screen_np
export(NodePath) var scanner_price_screen_np
export(NodePath) var scanner_price_rtb_np
export(NodePath) var scanner_laser_np
export(NodePath) var scanner_anim_np
export(NodePath) var scanner_on_charger_np
export(NodePath) var debug_label_np
export(NodePath) var keyboard_texturerect_np
export(NodePath) var keyboard_line_edit_np
export(NodePath) var keyboard_error_label_np
export(NodePath) var keyboard_price_screen_np
export(NodePath) var keyboard_price_rtb_np
export(NodePath) var score_label_np
export(NodePath) var time_label_np
export(NodePath) var danger_zone_mesh_np
export(NodePath) var danger_zone_hud_np
export(NodePath) var danger_zone_label_np
export(NodePath) var danger_zone_animation_np
export(NodePath) var red_button_texturerect_np
export(NodePath) var red_button_pressed_texturerect_np
export(NodePath) var clock_progress_np
export(NodePath) var clock_progress_label_np
export(NodePath) var new_package_label_np

onready var camera = get_node(camera_np) as Camera
onready var scan_camera = get_node(scan_camera_np) as Camera
onready var scan_package_holder = get_node(scan_package_holder_np) as Spatial
onready var button_panel = get_node(button_panel_np) as PanelContainer
onready var button_mesh = get_node(button_mesh_np) as MeshInstance
onready var hand_node = get_node(hand_node_np) as Node2D
onready var scanner = get_node(scanner_np) as Sprite
onready var scanner_screen_texturerect = get_node(scanner_screen_texturerect_np) as TextureRect
onready var scanner_screen_center = get_node(scanner_screen_center_np) as Position2D
onready var scanner_error_screen = get_node(scanner_error_screen_np) as TextureRect
onready var scanner_disabled_screen = get_node(scanner_disabled_screen_np) as TextureRect
onready var scanner_price_screen = get_node(scanner_price_screen_np) as TextureRect
onready var scanner_price_rtb = get_node(scanner_price_rtb_np) as RichTextLabel
onready var scanner_laser = get_node(scanner_laser_np) as Line2D
onready var scanner_anim = get_node(scanner_anim_np) as AnimationPlayer
onready var scanner_on_charger = get_node(scanner_on_charger_np) as Sprite
onready var debug_label = get_node(debug_label_np) as Label
onready var keyboard_texturerect = get_node(keyboard_texturerect_np) as Sprite
onready var keyboard_line_edit = get_node(keyboard_line_edit_np) as LineEdit
onready var keyboard_error_label = get_node(keyboard_error_label_np) as Label
onready var keyboard_price_screen = get_node(keyboard_price_screen_np) as TextureRect
onready var keyboard_price_rtb = get_node(keyboard_price_rtb_np) as RichTextLabel
onready var score_label = get_node(score_label_np) as Label
onready var time_label = get_node(time_label_np) as Label
onready var danger_zone_mesh = get_node(danger_zone_mesh_np) as MeshInstance
onready var danger_zone_hud = get_node(danger_zone_hud_np) as Control
onready var danger_zone_label = get_node(danger_zone_label_np) as Label
onready var danger_zone_animation = get_node(danger_zone_animation_np) as AnimationPlayer
onready var red_button_texturerect = get_node(red_button_texturerect_np) as TextureRect
onready var red_button_pressed_texturerect = get_node(red_button_pressed_texturerect_np) as TextureRect
onready var clock_progress = get_node(clock_progress_np) as TextureProgress
onready var clock_progress_label = get_node(clock_progress_label_np) as Label
onready var new_package_label = get_node(new_package_label_np) as Label

var hand_node_offset: Vector2

export(float) var hand_min_y = 550
export(bool) var scanner_in_hands setget set_scanner_hands, get_scanner_hands

export(float) var scanner_malfunction_chance_percent_per_second = 0.4
var scanner_malfunction_accumulated_second_used:float = 0.0
var last_scanner_malfunction_test_time:float = 0.0
var delay_between_scanner_malfunction_test: float = 1.0
var shake_sum:float = 0.0
var shake_target:float = 5000.0
var shake_previous_mouse_pos: Vector2

export var conveyor_visual_speed:float = 0.10

func set_scanner_hands(value:bool):
	scanner.visible = value
	scanner_on_charger.visible = not value
	if value:
		hand_node_offset = Vector2(-15,80)
	else: 
		hand_node_offset = Vector2()

func get_scanner_hands():
	return scanner.visible

func is_scanner_worling():
	return scanner_disabled_screen.visible == false

var scan_package: Package
var danger_zone_package = []

func load_products():
	for product_scene in Game.barcode_location_per_product.keys():
		package_scenes.append(load(product_scene))

func _ready():
	
	Music.play(load("res://Sounds/Musics/ExtendedSteady_BeatsToMakeMinimumWageTo.ogg"))
	
	load_products()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_scanner_hands(false)
#	set_viewport_texture()
	set_editor_azerty()

	if scan_package_holder.get_child_count() >= 1:
#		scan_package = scan_package_holder.get_child(0)
		scan_package_holder.get_child(0).queue_free()
	button_panel.visible = false
	button_mesh.visible = false
	spawn_package()
	
	scanner_error_screen.visible = false
	scanner_disabled_screen.visible = false
	keyboard_line_edit.visible = false
	keyboard_error_label.visible = false
	score_label.text = str(Game.score)
	time_label.text = Game.get_time_str()
	update_danger_zone_visuals()
	scanner_price_screen.visible = false
	keyboard_price_screen.visible = false
	new_package_label.visible = false
	
	k_ready()
	
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
	check_shake()	
	update_clock(delta)
	k_on_process()
	
	move_belt_visual(delta)
	
func move_belt_visual(delta):
	$BeltVisual.get_active_material(0).uv1_offset.x -= delta * conveyor_visual_speed
	
func update_clock(delta):
	Game.time += delta
	time_label.text = Game.get_time_str()	
	clock_progress.value = $Timer.time_left
	clock_progress_label.text = str(round($Timer.time_left))
	
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

func check_shake():
	if is_scanner_worling():
		return
		
	var mouse_postion = get_viewport().get_mouse_position() as Vector2
	
	var frame_move = mouse_postion.distance_to(shake_previous_mouse_pos)
	shake_sum += frame_move
	if shake_sum >= shake_target:
		scanner_disabled_screen.visible = false
		
	shake_previous_mouse_pos = mouse_postion

func toggle_scan_anim(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if get_scanner_hands():
			test_and_trigger_scanner_malfunction(delta)
			
			if not scanner_anim.is_playing():
				scanner_anim.play("Scan")
				scanner_laser.visible = true
	else:
		scanner_laser.visible = false
		if scanner_anim.is_playing():
			scanner_anim.stop()
			
func test_and_trigger_scanner_malfunction(delta):
	scanner_malfunction_accumulated_second_used += delta
	
	if Game.time < last_scanner_malfunction_test_time + delay_between_scanner_malfunction_test:
		return
		
	last_scanner_malfunction_test_time = Game.time
	
	var chance_percent = scanner_malfunction_accumulated_second_used * scanner_malfunction_chance_percent_per_second
	var chance = (randi() % 100)
	if chance <= chance_percent:
		trigger_scanner_malfunction()

func trigger_scanner_malfunction():
	shake_sum = 0
	shake_previous_mouse_pos = get_viewport().get_mouse_position() as Vector2
	scanner_malfunction_accumulated_second_used = 0
	scanner_disabled_screen.visible = true	
	
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

var package_scenes = []

func _on_Supermarket_rotate_package(add_rotation):
	rotate_package(add_rotation)

func rotate_package(add_rotation: Vector2):
	if scan_package == null:
		return
	scan_package.add_to_target_rotation(add_rotation)


func _on_Timer_timeout():
	k_on_timer()	
	spawn_new_package_group()

var spawn_counter= {
	0: 2,
	20: 3,
	40: 4,
	60: 5
}
func spawn_new_package_group():
	blink_new_package_label()
	
	var count = 0
	for threshold in spawn_counter.keys():
		if Game.time > threshold:
			count = spawn_counter[threshold]
	
	for i in count:
		spawn_package()
		yield(get_tree().create_timer(1),"timeout")

func spawn_package():
	var product_id = randi() % package_scenes.size()
	var scene = package_scenes[product_id]
	var instance = scene.instance()
	var spawn_positions = [
		$ConveyorBelt/PackageSpawnLocations/Location1.transform,
		$ConveyorBelt/PackageSpawnLocations/Location2.transform,
		$ConveyorBelt/PackageSpawnLocations/Location3.transform,
		$ConveyorBelt/PackageSpawnLocations/Location4.transform,
	]
	$ConveyorBelt.add_child(instance)
	instance.transform = spawn_positions[randi() % spawn_positions.size()]
	instance.connect("clicked", self, "on_conveyor_belt_package_clicked")

#	Rotate randomly UP
	var axis = Vector3.UP
	var rotation_radiant = deg2rad(randi() % 360)
	instance.transform.basis = instance.transform.basis.rotated(axis, rotation_radiant)

#	Rotate randomly LEFT
#	var rotation_count = Vector2(randi() % 4, randi() % 4)
#	instance.add_to_target_rotation(rotation_count * 90)

#	scale
	instance.scale = package_scale_on_belt

func on_conveyor_belt_package_clicked(package: Package):
	if scan_package_holder.get_child_count() == 0:
		package.get_parent().remove_child(package)
		scan_package_holder.add_child(package)
		package.disconnect("clicked", self, "on_conveyor_belt_package_clicked")
		package.connect("barcode_scanned", self, "_on_Package_barcode_scanned")
		package.connect("scan_error", self, "_on_Package_scan_error")
		package.transform = Transform()
		
		scan_package = package
#		button_panel.visible = true
		button_mesh.visible = true
		
		var grab_id = (1+(randi()%8)-1)
		SfxManager.play("grab%d" % grab_id)

func _on_Package_barcode_scanned(package, barcode):
	if get_scanner_hands() and is_scanner_worling():
		SfxManager.play("Scan")
		add_score(scan_package.price)
		move_package_to_exit_belt(package)

func _on_Package_scan_error(package, barcode):
	blink_keyboard_modulate()
	blink_scanner_error()

func blink_scanner_error():
	scanner_error_screen.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	scanner_error_screen.visible = false

func add_score(score):
	Game.score += score
	score_label.text = str(Game.score)
	blink_scanner_price(score)

func _on_TrashButton_pressed():
	if scan_package != null:
		add_score(-scan_package.price*2)
		move_package_to_exit_belt(scan_package)
	
func move_package_to_exit_belt(package: Package):
	
	scan_package = null
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
	button_panel.visible = false
	button_mesh.visible = false

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
				
		SfxManager.play("Scan")
		add_score(scan_package.price)
		move_package_to_exit_belt(scan_package)

func blink_keyboard_modulate():
	for i in 2:
		keyboard_texturerect.modulate = Color.red
		yield(get_tree().create_timer(0.2), "timeout")
		keyboard_texturerect.modulate = Color.white
		yield(get_tree().create_timer(0.2), "timeout")
	SfxManager.play("Error")

func blink_new_package_label():
	new_package_label.visible = true
	yield(get_tree().create_timer(1.5), "timeout")
	new_package_label.visible = false

func blink_keyboard_label():
	if keyboard_error_label.visible:
		return		
	keyboard_error_label.visible = true
	yield(get_tree().create_timer(0.4), "timeout")
	keyboard_error_label.visible = false
	SfxManager.play("Error")

func blink_scanner_price(price:int):
	scanner_price_screen.visible = true
	keyboard_price_screen.visible = true
	scanner_price_rtb.bbcode_text = "[center]%d[img=32]res://Sprites/coin.png[/img][/center]" % price
	keyboard_price_rtb.bbcode_text = scanner_price_rtb.bbcode_text
	yield(get_tree().create_timer(0.4), "timeout")
	scanner_price_screen.visible = false
	keyboard_price_screen.visible = false

func _on_KeyboardLineEdit_text_changed(new_text:String):
#	SfxManager.play("buttonpress")
	if new_text == "":
		return		
	var last = new_text[new_text.length() - 1]
	SfxManager.play("key"+last)


func _on_LooseArea_body_entered(body):
	if not body is Package:
		return
	danger_zone_package.append(body)
	
	if danger_zone_package.size() >= 6:
		Game.defeat()
		return
		
	update_danger_zone_visuals()

func update_danger_zone_visuals():
	var was_visible = danger_zone_hud.visible
	danger_zone_mesh.visible = danger_zone_package.size() >= 3
	danger_zone_hud.visible = danger_zone_package.size() >= 3
	
	danger_zone_label.text = str(danger_zone_package.size())
	if danger_zone_hud.visible and not danger_zone_animation.is_playing():
		danger_zone_animation.play("BlinkText")
		
	if not was_visible and danger_zone_hud.visible:
		SfxManager.play("failalarm")

func _on_LooseArea_body_exited(body):
	if not body is Package:
		return
	if danger_zone_package.has(body):
		danger_zone_package.erase(body)
	update_danger_zone_visuals()


func _on_RedButton_pressed():
	if red_button_pressed_texturerect.visible:
		return
	SfxManager.play("back")
	set_scanner_hands(false)
	red_button_texturerect.visible = false
	red_button_pressed_texturerect.visible = true
	k_push_away()
	yield(get_tree().create_timer(0.2),"timeout")
	red_button_texturerect.visible = true
	red_button_pressed_texturerect.visible = false


func _on_QuitButton_pressed():
	Game.defeat()


################################################################################
#		KAREN
################################################################################

export(NodePath) var karen_np
export(NodePath) var speech_bubble_spawn_locations_np
export(NodePath) var speech_bubble_plaholder_np
export(NodePath) var karen_button_help_container_np
export(NodePath) var karen_button_help_animation_np

onready var karen = get_node(karen_np) as MeshInstance
onready var speech_bubble_spawn_locations = get_node(speech_bubble_spawn_locations_np) as Spatial
onready var speech_bubble_plaholder = get_node(speech_bubble_plaholder_np) as Spatial
onready var karen_button_help_container = get_node(karen_button_help_container_np) as Container
onready var karen_button_help_animation = get_node(karen_button_help_animation_np) as AnimationPlayer

const speech_bubble_scene = preload("res://Scenes/SpeechBubble.tscn")
const speech_bubble_scene1 = preload("res://Scenes/SpeechBubble2.tscn")
const speech_bubble_scene2 = preload("res://Scenes/SpeechBubble3.tscn")

export(float) var karen_chance_percent_per_timer = 7.5
var karen_accumulated_chance: float = 0
var karen_last_bubble_spawn_time:float = 0
export var karen_bubble_spawn_delay:float = 3
export var karen_min_spawn_time: float = 20.0

func k_ready():
	karen.visible = false
	karen_button_help_container.visible = false
	karen_button_help_animation.play("BlinText")
	
	for child in speech_bubble_plaholder.get_children():
		child.queue_free()

func k_on_process():
	if karen.visible:
		k_try_spawn_bubble()

func k_on_timer():
	k_try_spawn_karen()

func k_try_spawn_karen():
	if karen.visible:
		return
		
	if Game.time < karen_min_spawn_time:
		return
		
	karen_accumulated_chance += karen_chance_percent_per_timer
	var chance = randi() % 100
	if chance < karen_accumulated_chance:
		k_spawn_karen()

func k_spawn_karen():
	karen_accumulated_chance = 0
	karen.visible = true
	karen_button_help_container.visible = true

func k_try_spawn_bubble():
	if karen_last_bubble_spawn_time + karen_bubble_spawn_delay < Game.time:
		k_spawn_bubble()
	
func k_spawn_bubble():
	karen_last_bubble_spawn_time = Game.time
	
	var bubble_count = speech_bubble_plaholder.get_child_count()
	var bubble_scene_per_count = {
		0: speech_bubble_scene,
		3: speech_bubble_scene1,
		6: speech_bubble_scene2
	}
	var bubble_scene
	for i in bubble_scene_per_count.keys():
		if bubble_count >= i:
			bubble_scene = bubble_scene_per_count[i]
	
	var spawn_location = speech_bubble_spawn_locations.get_child(
		randi() % speech_bubble_spawn_locations.get_child_count()
	) as Spatial
	
	var instance = bubble_scene.instance() as Spatial
	instance.transform = spawn_location.transform
	instance.translate(Vector3(0, 0.1*speech_bubble_plaholder.get_child_count(), 0))
	speech_bubble_plaholder.add_child(instance)
	
	SfxManager.play("karen%d" % (randi() % 4))

func k_push_away():
	if not karen.visible:
		return
		
	if speech_bubble_plaholder.get_child_count() == 0:
		karen.visible = false
		karen_button_help_container.visible = false
		return
	
	var last_bubble = speech_bubble_plaholder.get_child(
		speech_bubble_plaholder.get_child_count() - 1
	)
	last_bubble.queue_free()


