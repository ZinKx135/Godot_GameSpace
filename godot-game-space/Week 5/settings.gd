extends CanvasLayer


var master_id
var music_id
var sfx_id


@onready var master_slider = $Master_Slider
@onready var music_slider = $Music_Slider
@onready var sfx_slider = $SFX_Slider

@onready var fullscreen_button = $fullscreen_CheckButton
@onready var resolution_option = $Resolution_OptionButton

@onready var back_button = $Back


var resolutions = [
	Vector2i(854, 480),
	Vector2i(960, 540),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1366, 768)
]

func _ready():
	visible = false

	# AUDIO BUS
	master_id = AudioServer.get_bus_index("Master")
	music_id = AudioServer.get_bus_index("Music")
	sfx_id = AudioServer.get_bus_index("SFX")

	# SETUP RESOLUTION
	setup_resolutions()

	# LOAD SETTINGS
	load_settings()

	# APPLY VOLUME
	_apply_volume()

	# FULLSCREEN CHECK
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen_button.button_pressed = true
	else:
		fullscreen_button.button_pressed = false

func _input(event):
	if event.is_action_pressed("setting"):
		toggle_option()

func toggle_option():
	visible = !visible
	get_tree().paused = visible

func setup_resolutions():
	var screen_size = DisplayServer.screen_get_size()
	for r in resolutions:
		if r.x <= screen_size.x and r.y <= screen_size.y:
			resolution_option.add_item(
				"%dx%d" % [r.x, r.y]
			)

func _apply_volume():
	AudioServer.set_bus_volume_db(
		master_id,
		linear_to_db(master_slider.value)
	)
	AudioServer.set_bus_volume_db(
		music_id,
		linear_to_db(music_slider.value)
	)
	AudioServer.set_bus_volume_db(
		sfx_id,
		linear_to_db(sfx_slider.value)
	)

func _on_Master_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		master_id,
		linear_to_db(value)
	)
	save_settings()

func _on_Music_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		music_id,
		linear_to_db(value)
	)
	save_settings()

func _on_SFX_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		sfx_id,
		linear_to_db(value)
	)
	save_settings()

func _on_fullscreen_CheckButton_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)
	save_settings()

func _on_Resolution_OptionButton_item_selected(index):
	var selected_resolution = resolutions[index]
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_WINDOWED
	)
	fullscreen_button.button_pressed = false
	get_window().size = selected_resolution
	save_settings()

func _on_Back_pressed():
	toggle_option()

func save_settings():
	var config = ConfigFile.new()
	config.set_value(
		"audio",
		"master",
		master_slider.value
	)
	config.set_value(
		"audio",
		"music",
		music_slider.value
	)
	config.set_value(
		"audio",
		"sfx",
		sfx_slider.value
	)
	config.set_value(
		"video",
		"fullscreen",
		fullscreen_button.button_pressed
	)
	config.set_value(
		"video",
		"resolution",
		resolution_option.selected
	)
	config.save("user://settings.cfg")


func load_settings():
	var config = ConfigFile.new()
	var err = config.load(
		"user://settings.cfg"
	)
	if err != OK:
		return
	master_slider.value = config.get_value(
		"audio",
		"master",
		1.0
	)
	music_slider.value = config.get_value(
		"audio",
		"music",
		1.0
	)
	sfx_slider.value = config.get_value(
		"audio",
		"sfx",
		1.0
	)
	fullscreen_button.button_pressed = config.get_value(
		"video",
		"fullscreen",
		false
	)
	var resolution_index = config.get_value(
		"video",
		"resolution",
		0
	)
	resolution_option.select(
		resolution_index
	)
