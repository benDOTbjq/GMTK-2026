extends Node


const INCLUSION_FREQUENCY_RANGE := Vector2(2.5, 10.0) # seconds

const AMB_MAIN_01: AudioStream = preload("uid://csdd2e7l3pyhe")
const AMB_BICYCLE_CREAK: AudioStream = preload("uid://cbxyntt4q036w")
const AMB_CAR_DRIVE_BY: AudioStream = preload("uid://cex37rnwuu23c")
const AMB_COCKROACH_01: AudioStream = preload("uid://cc2xxtlmol70j")
const AMB_COCKROACH_02: AudioStream = preload("uid://qb3bamvgw53y")
const AMB_DOG_BARK: AudioStream = preload("uid://dx5vsq4r1au4a")
const AMB_DOOR_KNOCK: AudioStream = preload("uid://b3pcskyowvj5")
const AMB_DOOR_OPEN_CLOSE: AudioStream = preload("uid://dhnbk3rt8eod6")
const AMB_OVERHEAD_FOOTSTEPS: AudioStream = preload("uid://6twy5kl2cxnh")


const DEFAULT_AMBIENCE_INCLUSIONS: Array[AudioStream] = [
	AMB_BICYCLE_CREAK,
	AMB_CAR_DRIVE_BY,
	AMB_COCKROACH_01,
	AMB_COCKROACH_02,
	AMB_DOG_BARK,
	AMB_DOOR_KNOCK,
	AMB_DOOR_OPEN_CLOSE,
	AMB_OVERHEAD_FOOTSTEPS,
]


const AMBIENCE_LOOP_LU: Dictionary[ID.Ambience, AudioStream] = {
	ID.Ambience.DEFAULT: AMB_MAIN_01
}
const AMBIENCE_INCLUSIONS_LU: Dictionary[ID.Ambience, Array] = {
	ID.Ambience.DEFAULT: DEFAULT_AMBIENCE_INCLUSIONS
}


var _ambience_loop_player: AudioStreamPlayer
var _ambience_inclusion_timer: Timer
var _current_ambience_id := ID.Ambience.NULL


func set_ambience(id: ID.Ambience) -> void:
	_current_ambience_id = id
	_ambience_loop_player.stream = AMBIENCE_LOOP_LU[id]
	_ambience_loop_player.play()
	_ambience_inclusion_timer.start(randf_range(INCLUSION_FREQUENCY_RANGE.x, INCLUSION_FREQUENCY_RANGE.y))
	


func _ready() -> void:
	_ambience_loop_player = AudioStreamPlayer.new()
	_ambience_inclusion_timer = Timer.new()
	_ambience_loop_player.bus = &"Ambience"
	add_child(_ambience_loop_player)
	add_child(_ambience_inclusion_timer)
	_ambience_inclusion_timer.timeout.connect(func() -> void:
		var inclusions = AMBIENCE_INCLUSIONS_LU[_current_ambience_id]
		_play_ambience_oneshot(inclusions[randi_range(0, inclusions.size()-1)])
	)
	

func _play_ambience_oneshot(sfx_stream: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = sfx_stream
	player.bus = &"Ambience_ext"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
