extends Control

@onready var dialogue_box = $DialogueBox
@onready var dialogue_label = $DialogueBox/DialogueLabel
@onready var result_box = $ResultBox
@onready var report_image = $ResultBox/ReportImage
@onready var night_label = $ResultBox/NightLabel
@onready var scanned_label = $ResultBox/ScannedLabel
@onready var found_label = $ResultBox/FoundLabel
@onready var rating_label = $ResultBox/RatingLabel
@onready var comment_label = $ResultBox/CommentLabel
@onready var restart_btn = $ResultBox/RestartButton
@onready var exit_btn = $ResultBox/ExitButton

var happy_image = preload("res://aee/해피엔딩최종.png")
var bad_image = preload("res://aee/배드엔딩최종.png")
var is_happy = false
var dialogue_index = 0
var dialogues = []

var happy_dialogues = [
	"오전 6시.",
	"살았네.",
	"퇴근.",
	"다음 주 근무는 없었으면 좋겠다.",
]

var bad_dialogues = [
	"오전 6시.",
	"상사한테 전화 왔다.",
	"해고라고 한다.",
	"...뭐, 그럴 수도 있지.",
]

func _ready():
	restart_btn.pressed.connect(_on_restart)
	exit_btn.pressed.connect(_on_exit)
	result_box.visible = false
	dialogue_box.visible = true
	if GameManager.progress >= 0.9:
		is_happy = true
		dialogues = happy_dialogues
	else:
		is_happy = false
		dialogues = bad_dialogues
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
	var scanned = int(GameManager.progress * 19)
	var found = GameManager.correct_reports
	var rating = get_rating()
	if rating == "S" or rating == "A":
		report_image.texture = happy_image
	else:
		report_image.texture = bad_image
	night_label.text = "1"
	scanned_label.text = "%d / 19" % scanned
	found_label.text = "%d" % found
	rating_label.text = "%s" % rating
	comment_label.text = get_comment(rating)

func get_rating() -> String:
	var p = GameManager.progress
	if p >= 0.9:
		return "S"
	elif p >= 0.7:
		return "A"
	elif p >= 0.5:
		return "B"
	elif p >= 0.3:
		return "C"
	else:
		return "D"

func get_comment(rating: String) -> String:
	match rating:
		"S": return "이상 없음. 탁월한 판단력."
		"A": return "대부분 정상 처리됨."
		"B": return "일부 이상 현상 미처리."
		"C": return "다수의 유물 방치 확인됨."
		"D": return "근무 태만. 재계약 불가."
	return ""

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
