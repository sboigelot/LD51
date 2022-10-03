extends Node2D

var win: bool
var score: int
var time: float
var bonus: bool

enum BARCODE_LOCATION {
	FRONT,
	LEFT,
	BOTTOM,
	RIGHT,
	TOP,
	BACK
}

var valid_locations_per_product = {
	"res://Products/y30z130/Poopalot/Package.tscn" : 	[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.LEFT,BARCODE_LOCATION.BOTTOM,BARCODE_LOCATION.RIGHT,BARCODE_LOCATION.TOP,BARCODE_LOCATION.BACK],
	"res://Products/Cylender/Beans/Package.tscn" : 		[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.LEFT,BARCODE_LOCATION.BOTTOM,BARCODE_LOCATION.RIGHT,BARCODE_LOCATION.TOP,BARCODE_LOCATION.BACK],
	"res://Products/Cylender/JamJam/Package.tscn" : 	[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.LEFT,BARCODE_LOCATION.BOTTOM,BARCODE_LOCATION.RIGHT,BARCODE_LOCATION.TOP,BARCODE_LOCATION.BACK],
	"res://Products/Puppet/Bu/Package.tscn" : 			[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.LEFT,BARCODE_LOCATION.BOTTOM,BARCODE_LOCATION.RIGHT,BARCODE_LOCATION.TOP,BARCODE_LOCATION.BACK],
	"res://Products/Puppet/Togis/Package.tscn" : 		[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.LEFT,BARCODE_LOCATION.BOTTOM,BARCODE_LOCATION.RIGHT,BARCODE_LOCATION.TOP,BARCODE_LOCATION.BACK],
	"res://Products/DvdBox/GateBuilder/Package.tscn" : 	[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.BACK],
	"res://Products/DvdBox/Kawai/Package.tscn" : 		[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.BACK],
	"res://Products/DvdBox/Dalai/Package.tscn" : 		[BARCODE_LOCATION.FRONT,BARCODE_LOCATION.BACK],
}
var barcode_location_per_product = {}

func clear_data():
	randomize()	
	randomize_barcode_locations()
	win = false
	score = 0
	time = 0
	
func _ready():
	 clear_data()
	
func get_time_str():
	return  to_time_str(time)
	
func to_time_str(_time):	
	var minutes = floor(_time / 60)
	var seconds = floor(fmod(_time,60))
	var txt = "%02d:%02d" % [
		minutes,
		seconds
	]
	return txt

func new_game():
	clear_data()
	get_tree().change_scene("res://Scenes/Supermarket3d.tscn")

func randomize_barcode_locations():
	barcode_location_per_product.clear()
	for product in valid_locations_per_product.keys():
		var valid_locations = valid_locations_per_product[product]
		barcode_location_per_product[product] = valid_locations[
			randi() % valid_locations.size()
		]
	
func defeat():
	win = false
	get_tree().change_scene("res://Scenes/VictoryScreen.tscn")

func victory():
	win = true
	get_tree().change_scene("res://Scenes/VictoryScreen.tscn") 

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		print(get_tree().current_scene.filename)
		if get_tree().current_scene != null and get_tree().current_scene.filename != "res://Scenes/MainMenu.tscn":
			get_tree().change_scene("res://Scenes/MainMenu.tscn")
			win = false
		else:
			get_tree().quit()
		
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)

