extends Control

@onready var dialogue_box = $DialogueBox
@onready var dialogue_label = $DialogueBox/DialogueLabel
@onready var result_box = $ResultBox
@onready var report_image = $ResultBox/ReportImage
@onready var restart_btn = $ResultBox/RestartButton
@onready var exit_btn = $ResultBox/ExitButton

var dead_image = preload("res://aee/데드엔딩최종.png")
var dialogue_index = 0
var dialogues = [
	"발자국 소리가 들린다.",
	"가깝다.",
	"불이 꺼졌다.",
	"아.",
]

func _ready():
	restart_btn.pressed.connect(_on_restart)
	exit_btn.pressed.connect(_on_exit)
	result_box.visible = false
	dialogue_box.visible = true
	show_dialogue()

func _input(event):
	if event.is_action_pressed("nextui"):
		dialogue_index += 1
		if dialogue_index >= dialogues.size():
			show_result()
		else:
			show_dialogue()

func show_dialogue():
	dialogue_label.text = dialogues[dialogue_index]

func show_result():
	dialogue_box.visible = false
	result_box.visible = true
	report_image.texture = dead_image

func _on_restart():
	GameManager.game_time = 0.0
	GameManager.progress = 0.0
	GameManager.monster_tension = 0.0
	GameManager.correct_reports = 0
	for room in GameManager.anomalies:
		GameManager.anomalies[room]["active"] = false
		GameManager.anomalies[room]["timer"] = 0.0
	get_tree().change_scene_to_file("res://game_screen.tscn")

func _on_exit():
	get_tree().quit()
