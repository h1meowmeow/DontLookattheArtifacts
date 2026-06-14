extends Control

@onready var clock_label = $TopBar/ClockLabel
@onready var progress_bar = $TopBar/ProgressBar
@onready var artifact_image = $CCTVPanel/ArtifactImage
@onready var desc_label = $CCTVPanel/DescriptionLabel
@onready var report_btn = $ReportButton
@onready var normal_btn = $NormalButton
@onready var manual_btn = $ManualButton
@onready var manual_popup = $ManualPopup
@onready var manual_image = $ManualPopup/VBoxContainer/ScrollContainer/ManualImage
@onready var ghost_popup = $GhostPopup
@onready var ghost_timer_label = $GhostPopup/TimerLabel
@onready var emergency_btn = $EmergencyButton
@onready var bgm = $Audio/BGM
@onready var sfx_blackout = $Audio/SFX_Blackout
@onready var sfx_poweron = $Audio/SFX_PowerOn
@onready var sfx_ghost = $Audio/SFX_Ghost
@onready var sfx_emergency = $Audio/SFX_Emergency
@onready var sfx_anomaly = $Audio/SFX_Anomaly
@onready var sfx_heartbeat = $Audio/SFX_Heartbeat
@onready var sfx_footstep = $Audio/SFX_Footstep
@onready var sfx_buttonpre = $Audio/SFX_ButtonPre


@onready var dark_overlay = $DarkOverlay
@onready var flashlight = $DarkOverlay/Flashlight
@onready var keypad = $KeyPad
@onready var keypad_code_label = $KeyPad/CodeLabel
@onready var blackout_input_label = $KeyPad/InputLabel
@onready var blackout_timer_label = $KeyPad/TimerLabel

var current_code = ""
var typed_text = ""
var blackout_active = false
var blackout_timer = 0.0
const BLACKOUT_TIME = 10.0

var ghost_active = false
var ghost_timer = 0.0
const GHOST_TIME = 5.0

var current_room = "room_1"
var current_index = 0

var normal_image = preload("res://aee/빗살무늬토기_원.png")
var anomaly_image = preload("res://aee/빗살무늬토기_변1.png")

var manual_content = """[b]제1전시실 정상 기준[/b]
━━━━━━━━━━━━━━━━
유물 0 · 주먹도끼
정상 설명: 구석기 시대 · 경기도 연천 채집

유물 1 · 빗살무늬토기
정상 설명: 신석기 시대 · 김천 송죽리유적 출토

유물 2 · 청동거울
정상 설명: 청동기 시대 · 대구·경북 지역 수집

유물 3 · 청동검
정상 설명: 청동기 시대 · 대구·경북 지역 수집

[b]제2전시실 정상 기준[/b]
━━━━━━━━━━━━━━━━
유물 0 · 대가야 토기
정상 설명: 가야 시대 · 고령 지산동고분군 출토

유물 1 · 성산동 출토 철기
정상 설명: 가야 시대 · 성주 성산동고분군 출토

유물 2 · 청자 대접
정상 설명: 통일신라 시대 · 기증 유물

유물 3 · 토우
정상 설명: 통일신라 시대 · 경주 황성동유적 출토

유물 4 · 청자잔
정상 설명: 통일신라 시대 · 기증 유물
"""

func _ready():
	bgm.play()
	report_btn.pressed.connect(_on_report)
	normal_btn.pressed.connect(_on_normal)
	manual_btn.pressed.connect(_on_manual)
	$RoomButtons/Room1Button.pressed.connect(func(): switch_room("room_1"))
	$RoomButtons/Room2Button.pressed.connect(func(): switch_room("room_2"))
	$RoomButtons/Room3Button.pressed.connect(func(): switch_room("room_3"))
	switch_room("room_1")
	$ManualPopup/VBoxContainer/CloseButton.pressed.connect(_on_close)
	emergency_btn.pressed.connect(_on_emergency)

	# 정전 초기화
	dark_overlay.visible = false
	keypad.visible = false
	keypad_code_label.visible = false
	ghost_popup.visible = false

	# 숫자 버튼 연결
	for i in range(0, 10):
		$KeyPad/NumPad.get_node("Button%d" % i).pressed.connect(_on_num_pressed.bind(str(i)))
	$KeyPad/NumPad/ButtonStar.pressed.connect(_on_num_confirm)

	# 버튼 초기 비활성화
	for btn in $KeyPad/NumPad.get_children():
		btn.disabled = true

func _process(delta):
	var total_minutes = int(GameManager.game_time / 60.0)
	var hour = int(22 + total_minutes / 60.0) % 24
	clock_label.text = "%02d:00" % hour
	progress_bar.value = GameManager.progress * 100
	load_artifact()

	if GameManager.monster_tension >= 70.0:
		if !sfx_heartbeat.playing:
			sfx_heartbeat.play()
	else:
		sfx_heartbeat.stop()

	if blackout_active:
		flashlight.global_position = get_viewport().get_mouse_position()
		blackout_timer -= delta
		blackout_timer_label.text = "%.1f" % blackout_timer
		if blackout_timer <= 0.0:
			_blackout_fail()

	if ghost_active:
		ghost_timer -= delta
		ghost_timer_label.text = "%.1f" % ghost_timer
		if ghost_timer <= 0.0:
			_ghost_fail()

func switch_room(room_id):
	current_room = room_id
	current_index = 0
	load_artifact()

func load_artifact():
	var artifact = GameManager.artifact_data[current_room][current_index]
	var anomaly = GameManager.anomalies[current_room]

	if anomaly["active"] and anomaly["artifact_index"] == current_index:
		desc_label.text = artifact["anomaly_desc"]
		if artifact["anomaly_image"] != "":
			artifact_image.texture = load(artifact["anomaly_image"])
		else:
			artifact_image.texture = anomaly_image
		if !sfx_anomaly.playing:
			sfx_anomaly.play()
	else:
		desc_label.text = artifact["desc"]
		if artifact["image"] != "":
			artifact_image.texture = load(artifact["image"])
		else:
			artifact_image.texture = normal_image

func _on_num_confirm():
	if !blackout_active:
		return
	if typed_text == current_code:
		_blackout_success()
	else:
		typed_text = ""
		blackout_input_label.text = ""
		
func start_blackout():
	bgm.stop()
	sfx_blackout.play()
	await get_tree().create_timer(0.7).timeout
	sfx_blackout.stop()

	current_code = "%04d" % randi_range(1000, 9999)
	keypad_code_label.text = "CODE : " + current_code
	keypad_code_label.visible = true
	blackout_input_label.text = ""
	blackout_timer_label.text = "10.0"
	typed_text = ""

	dark_overlay.visible = true
	keypad.visible = true

	for btn in $KeyPad/NumPad.get_children():
		btn.disabled = false 

	blackout_active = true
	blackout_timer = BLACKOUT_TIME

func _on_num_pressed(num: String):
	if !blackout_active:
		return
	sfx_buttonpre.play()
	typed_text += num
	blackout_input_label.text = typed_text

func _blackout_success():
	blackout_active = false
	dark_overlay.visible = false
	keypad.visible = false
	keypad_code_label.visible = false
	for btn in $KeyPad/NumPad.get_children():
		btn.disabled = true
	sfx_poweron.play()
	bgm.play()
	GameManager.monster_tension = max(0.0, GameManager.monster_tension - 10.0)

func _blackout_fail():
	blackout_active = false
	dark_overlay.visible = false
	keypad.visible = false
	keypad_code_label.visible = false
	for btn in $KeyPad/NumPad.get_children():
		btn.disabled = true
	bgm.play()
	GameManager.monster_tension += 30.0

func start_ghost():
	sfx_ghost.play()
	ghost_active = true
	ghost_timer = GHOST_TIME
	ghost_popup.visible = true

func _on_emergency():
	if ghost_active:
		ghost_active = false
		ghost_popup.visible = false
		sfx_ghost.stop()
		sfx_emergency.play()
		GameManager.monster_tension = max(0.0, GameManager.monster_tension - 10.0)

func _ghost_fail():
	ghost_active = false
	ghost_popup.visible = false
	sfx_ghost.stop()
	GameManager.monster_tension += 40.0

func _on_report():
	GameManager.report_anomaly(current_room, current_index)

func _on_normal():
	var room_size = GameManager.artifact_data[current_room].size()
	current_index = (current_index + 1) % room_size
	load_artifact()

func _on_manual():
	manual_popup.visible = !manual_popup.visible

func _on_close():
	manual_popup.visible = false
