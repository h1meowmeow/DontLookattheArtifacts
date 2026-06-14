extends Control

@onready var start_btn = $ButtonGroup/StartButton
@onready var exit_btn = $ButtonGroup/ExitButton
@onready var flashlight = $Flashlight

func _ready():
	start_btn.pressed.connect(_on_start)
	exit_btn.pressed.connect(_on_exit)
	flashlight.position = get_global_mouse_position()

func _process(_delta):
	if flashlight.process_mode != PROCESS_MODE_DISABLED:
		flashlight.position = flashlight.position.lerp(get_global_mouse_position(), 0.15)

func _on_start():
	flashlight.process_mode = PROCESS_MODE_DISABLED
	
	var light_tween = create_tween()
	light_tween.set_parallel(true)
	light_tween.set_trans(Tween.TRANS_QUAD)
	light_tween.set_ease(Tween.EASE_OUT)
	
	light_tween.tween_property(flashlight, "scale", Vector2(20.0, 20.0), 0.5)
	light_tween.tween_property(flashlight, "energy", 5.0, 0.8)
	
	light_tween.chain().tween_callback(func():
		GameManager.is_playing = true
		get_tree().change_scene_to_file("res://game_screen.tscn")
	)

func _on_exit():
	get_tree().quit()
