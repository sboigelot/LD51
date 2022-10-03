extends Control

export(NodePath) var np_victory_label
export(NodePath) var np_retry_button
export(NodePath) var np_score_label
export(NodePath) var np_time_label

onready var victory_label = get_node(np_victory_label) as Label
onready var retry_button = get_node(np_retry_button) as Button
onready var score_label = get_node(np_score_label) as Label
onready var time_label = get_node(np_time_label) as Label

var reloading_leaderboard: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update_ui(Game.win, Game.score, Game.time)
	
	Leaderboard.connect("entry_added", self, "on_score_added")
	Leaderboard.connect("error", self, "on_leaderboard_error")
	Leaderboard.connect("top_score_updated", self, "on_leaderboard_score_updated")
	Leaderboard.connect("top_time_updated", self, "on_leaderboard_time_updated")
	
func reload_leaderboard():
	reloading_leaderboard = true
	Leaderboard.get_top_score()
	
func update_ui(win:bool, score:int, time:float):
	victory_label.text = "Victory" if win else "Fired!"
	retry_button.visible = true #not win
	
	score_label.text = "%d" % score
	
	var seconds = floor(Game.time)
	var minutes = floor(seconds / 60)
	seconds -= minutes * 60
	var miliseconds = round((Game.time - seconds)*10)
	time_label.text = "%02d:%02d:%02d" % [
		minutes,
		seconds,
		miliseconds
	] 

func _on_BackToMenuButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func _on_RetryButton_pressed():
	Game.new_game()

func on_score_added():
	Leaderboard.get_top_score()
	Leaderboard.get_top_time()
	
func on_leaderboard_error():
	printerr("Error loading leaderboard")
	
func on_leaderboard_score_updated():
	Leaderboard.get_top_time()
	
func on_leaderboard_time_updated():
	reloading_leaderboard = false
	on_leaderboard_loaded()
	
func on_leaderboard_loaded():
	pass
