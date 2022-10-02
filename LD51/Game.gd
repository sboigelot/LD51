extends Node2D

var win: bool
var score: int
var time: float
var bonus: bool

func new_game():
	randomize()
	
	win = false
	score = 0
	time = 0
	
	get_tree().change_scene("res://Scenes/Supermarket3d.tscn")

	
func defeat():
	win = false
#	current_player_datas.clear()
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
