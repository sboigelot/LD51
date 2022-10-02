extends Area

class_name Barcode

signal clicked(barcode)
signal scanned(barcode)
signal scan_error(barcode)

export(NodePath) var barcode_image_genetaor_np
onready var barcode_image_genetaor = get_node(barcode_image_genetaor_np)

var numbers: Array
var stained: bool
var mouse_over:bool
var scan_timer:float 
var scan_target:float = 0.8
export var percent_chance_of_stained:float = 20

func _ready():
	numbers = []
	for i in (1 + randi() % 4):
		numbers.append(randi() % 10)
	
	stained = (randi() % 100) <= percent_chance_of_stained
	
	change_code(numbers, stained)

func change_code(numbers:Array, stained:bool):
	barcode_image_genetaor.change_code(numbers, stained)

func _process(delta):
	if mouse_over:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			scan_timer += delta
			if scan_timer >= scan_target:
				scan_timer = 0
				if not stained:
					emit_signal("scanned", self)
				else:
					emit_signal("scan_error", self)
			

func _on_Barcode_input_event(camera, event, position, normal, shape_idx):
	if not visible:
		return
	
	if (event is InputEventMouseButton and
		event.pressed and
		event.button_index == BUTTON_LEFT):
			emit_signal("clicked", self)

func _on_Barcode_mouse_entered():
	mouse_over = true
	scan_timer = 0

func _on_Barcode_mouse_exited():
	mouse_over = false
	scan_timer = 0
