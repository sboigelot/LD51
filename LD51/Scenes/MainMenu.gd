extends Control

export(NodePath) var np_start_game_button
onready var start_game_button = get_node(np_start_game_button) as Button

export(NodePath) var np_ui_audio_master
export(NodePath) var np_ui_audio_music
export(NodePath) var np_ui_audio_soundfx

export(float) var volume_min = -40
export(float) var volume_max = 6

onready var ui_audio_master = get_node(np_ui_audio_master) as HSlider
onready var ui_audio_music = get_node(np_ui_audio_music) as HSlider
onready var ui_audio_soundfx = get_node(np_ui_audio_soundfx) as HSlider

export(NodePath) var np_webgl_button
onready var webgl_button = get_node(np_webgl_button) as Button

func _ready():
	if OS.get_name() != "HTML5":
		webgl_button.queue_free()
	else:
		webgl_button.visible = true
	update_sound_sliders()
	
func _on_NewGameButton_pressed():
#	SfxManager.play("ui-button-click")
	Game.new_game()

func update_sound_sliders():
	var master_volume:float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	var music_volume:float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	var sfx_volume:float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	
	ui_audio_master.min_value = volume_min
	ui_audio_master.max_value = volume_max
	ui_audio_master.value = master_volume
	
	ui_audio_music.min_value = volume_min
	ui_audio_music.max_value = volume_max
	ui_audio_music.value = music_volume
	
	ui_audio_soundfx.min_value = volume_min
	ui_audio_soundfx.max_value = volume_max
	ui_audio_soundfx.value = sfx_volume

func _on_MasterHSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	SfxManager.play("ui-button-click")

func _on_MusicHSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	SfxManager.play("ui-button-click")

func _on_SoundFxHSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	SfxManager.play("ui-button-click")

func _on_WebGLButton_pressed():
	OS.set_window_fullscreen(true)
	webgl_button.queue_free()

func _on_StartButton_pressed():
	Game.new_game()
