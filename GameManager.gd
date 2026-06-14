extends Node

var game_time : float = 0.0
var progress : float = 0.0
var monster_tension : float = 0.0
var correct_reports : int = 0
var is_ending = false  
const TIME_SCALE = 120.0
var is_playing = false
var next_blackout_time = 1000.0
var next_ghost_time = 5000.0

var artifact_data = {
	"room_1": [
	{"name": "주먹도끼", "desc": "구석기 시대 · 경기도 연천 채집", "anomaly_desc": "신석기 시대 · 경기도 연천 채집",
	"image": "res://aee/주먹도끼_원.png", "anomaly_image": "res://aee/주먹도끼_변.png"},
	{"name": "빗살무늬토기", "desc": "신석기 시대 · 김천 송죽리유적 출토", "anomaly_desc": "청동기 시대 · 김천 송죽리유적 출토",
	"image": "res://aee/빗살무늬토기_원.png", "anomaly_image": "res://aee/빗살무늬토기_변1.png"},
	{"name": "청동거울", "desc": "청동기 시대 · 대구·경북 지역 수집", "anomaly_desc": "신석기 시대 · 대구·경북 지역 수집",
	"image": "res://aee/청동거울_원.png", "anomaly_image": "res://aee/청동거울_귀.png"},
	{"name": "청동검", "desc": "청동기 시대 · 대구·경북 지역 수집", "anomaly_desc": "구석기 시대 · 대구·경북 지역 수집",
	"image": "res://aee/청동검_원.png", "anomaly_image": "res://aee/청동검_변형.png"},
],
"room_2": [
	{"name": "대가야 토기", "desc": "가야 시대 · 고령 지산동고분군 출토", "anomaly_desc": "신라 시대 · 고령 지산동고분군 출토",
	"image": "res://aee/대가야토기_원.png", "anomaly_image": "res://aee/대가야토기_변.png"},
	{"name": "성산동 출토 철기", "desc": "가야 시대 · 성주 성산동고분군 출토", "anomaly_desc": "고려 시대 · 성주 성산동고분군 출토",
	"image": "res://aee/성산동출토철기_원.png", "anomaly_image": "res://aee/성산동출토철기_변.png"},
	{"name": "청자 대접", "desc": "통일신라 시대 · 기증 유물", "anomaly_desc": "고려 시대 · 기증 유물",
	"image": "res://aee/청자대접_원.png", "anomaly_image": "res://aee/청자대접_귀.png"},
	{"name": "토우", "desc": "통일신라 시대 · 경주 황성동유적 출토", "anomaly_desc": "가야 시대 · 경주 황성동유적 출토",
	"image": "res://aee/토우_원.png", "anomaly_image": "res://aee/토우_귀.png"},
	{"name": "청자잔", "desc": "통일신라 시대 · 기증 유물", "anomaly_desc": "고려 시대 · 기증 유물",
	"image": "res://aee/청자잔_원.png", "anomaly_image": "res://aee/청자잔_변.png"},
],
"room_3": [
	{"name": "매화백자항아리", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "고려 시대 · 행소박물관 소장",
	"image": "res://aee/매화백자항아리_원.png", "anomaly_image": "res://aee/매화백자항아리_귀.png"},
	{"name": "모란 그림", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "고려 시대 · 행소박물관 소장",
	"image": "res://aee/모란_원.png", "anomaly_image": "res://aee/모란_변.png"},
	{"name": "포도 그림 (낭곡 최석환)", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "고려 시대 · 행소박물관 소장",
	"image": "res://aee/포도도_원.png", "anomaly_image": "res://aee/포도도_귀.png"},
	{"name": "참외 모양 벼루", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "신라 시대 · 행소박물관 소장",
	"image": "res://aee/참외벼루_원.png", "anomaly_image": "res://aee/참외벼루_변.png"},
	{"name": "백수백복 그림", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "고려 시대 · 행소박물관 소장",
	"image": "res://aee/백수백복도_원.png", "anomaly_image": "res://aee/백수백복도_변.png"},
	{"name": "백자 청화 십장생무늬 병", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "고려 시대 · 행소박물관 소장",
	"image": "res://aee/고려청자_원.png", "anomaly_image": "res://aee/고려청자_변.png"},
	{"name": "대나무 필통", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "신라 시대 · 행소박물관 소장",
	"image": "res://aee/대나무필통_원.png", "anomaly_image": "res://aee/대나무필통_변.png"},
	{"name": "포도넝쿨 기와", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "고려 시대 · 행소박물관 소장",
	"image": "res://aee/포도넝쿨기와_원.png", "anomaly_image": "res://aee/포도넝쿨기와_변.png"},
	{"name": "까치와 호랑이 그림", "desc": "조선 시대 · 행소박물관 소장", "anomaly_desc": "고려 시대 · 행소박물관 소장",
	"image": "res://aee/까치와호랑이_원.png", "anomaly_image": "res://aee/까치와호랑이_귀.png"},
	]
}

var anomalies = {
	"room_1": {"active": false, "timer": 0.0, "artifact_index": 0},
	"room_2": {"active": false, "timer": 0.0, "artifact_index": 0},
	"room_3": {"active": false, "timer": 0.0, "artifact_index": 0},
}

var next_anomaly_time = 0.0

func _ready():
	_schedule_next_anomaly()

func _process(delta):
	if is_ending or !is_playing:
		return
	
	game_time += delta * TIME_SCALE

	if game_time >= next_anomaly_time:
		_trigger_random_anomaly()
		_schedule_next_anomaly()

	for room in anomalies:
		if anomalies[room]["active"]:
			anomalies[room]["timer"] += delta
			if anomalies[room]["timer"] >= 30.0:
				monster_tension += delta * 2

	if monster_tension >= 100.0:
		is_ending = true
		get_tree().call_deferred("change_scene_to_file", "res://event_dead.tscn")

	if game_time >= next_blackout_time:
		next_blackout_time = game_time + randf_range(3000.0, 6000.0)
		var game_screen = get_tree().get_first_node_in_group("game_screen")
		if game_screen:
			game_screen.start_blackout()

	if game_time >= next_ghost_time:
		next_ghost_time = game_time + randf_range(4000.0, 7000.0)
		var game_screen = get_tree().get_first_node_in_group("game_screen")
		if game_screen:
			game_screen.start_ghost()

	if game_time >= 28800.0:
		is_ending = true
		end_game()

func _schedule_next_anomaly():
	next_anomaly_time = game_time + randf_range(300.0, 600.0)

func _trigger_random_anomaly():
	print("트리거 호출됨")
	var rooms = anomalies.keys()
	var available = rooms.filter(func(r): return !anomalies[r]["active"])
	if available.is_empty():
		print("가용 방 없음")
		return
	var target = available[randi() % available.size()]
	anomalies[target]["active"] = true
	anomalies[target]["timer"] = 0.0
	anomalies[target]["artifact_index"] = randi() % artifact_data[target].size()
	print("이상현상! 방: ", target, " / 유물 인덱스: ", anomalies[target]["artifact_index"])

func report_anomaly(room_id, artifact_index):
	var anomaly = anomalies[room_id]
	if anomaly["active"] and anomaly["artifact_index"] == artifact_index:
		anomaly["active"] = false
		anomaly["timer"] = 0.0
		progress += 0.1
		correct_reports += 1
		monster_tension = max(0.0, monster_tension - 10.0)
		
		if progress >= 1.0:
			is_ending = true
			get_tree().call_deferred("change_scene_to_file", "res://ending.tscn")
	else:
		monster_tension += 20.0

func end_game():
	if progress >= 0.9:
		get_tree().call_deferred("change_scene_to_file", "res://ending.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://ending.tscn")
