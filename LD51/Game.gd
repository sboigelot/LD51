extends Node2D

var current_level_path = ""
var current_level #: Level

var win: bool
var score: int
var time: float
var tutorial: bool
var bonus: bool

func new_game(with_tutorial:bool = false):
	randomize()
	
	current_level = null
#	current_level_count = 1
#	current_tutorial_level_count = 1
#	current_bonus_level_count = 1
	win = false
	score = 0
	time = 0
	tutorial = with_tutorial
	
	if with_tutorial:
		change_level("res://Levels/A1_tutorial_slot.tscn")
	else:	
		change_level("res://Levels/L01.tscn")

func change_level(path):
	current_level_path = path
	get_tree().change_scene(path)
	
func defeat():
	win = false
#	current_player_datas.clear()
	get_tree().change_scene("res://UI/VictoryScreen.tscn")

func retry_level():
#	respawn_dead_players(true)
	change_level(current_level_path)

func victory():
	win = true
	get_tree().change_scene("res://UI/VictoryScreen.tscn") 

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if current_level != null:
			get_tree().change_scene("res://UI/MainMenu.tscn")
			current_level = null
			win = false
#			current_player_datas.clear()
		else:
			get_tree().quit()
		
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)
