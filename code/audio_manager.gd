extends Node


const IS_PRINT_DEBUG := false
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
const AMBIENCE_INCLUSIONS_LU: Dictionary[ID.Ambience, Array] = {
	ID.Ambience.DEFAULT: [
		AMB_BICYCLE_CREAK,
		AMB_CAR_DRIVE_BY,
		AMB_COCKROACH_01,
		AMB_COCKROACH_02,
		AMB_DOG_BARK,
		AMB_DOOR_KNOCK,
		AMB_DOOR_OPEN_CLOSE,
		AMB_OVERHEAD_FOOTSTEPS,
	],
}

const UI_BOOK_CLOSE: AudioStream = preload("uid://bnhj4kipp5q6e")
const UI_BOOK_OPEN: AudioStream = preload("uid://dncoaeilp2w67")
const UI_FLIP_PAGE_LEFT_01: AudioStream = preload("uid://br7ross70mmpu")
const UI_FLIP_PAGE_LEFT_02: AudioStream = preload("uid://dx2bm6tgyxsg7")
const UI_FLIP_PAGE_LEFT_03: AudioStream = preload("uid://dt0ek1r0wsrs7")
const UI_FLIP_PAGE_RIGHT_01: AudioStream = preload("uid://bljtyg516o134")
const UI_FLIP_PAGE_RIGHT_02: AudioStream = preload("uid://db0kvixf60orv")
const UI_FLIP_PAGE_RIGHT_03: AudioStream = preload("uid://bvt6luopty45p")
const UI_SIDE_WHOOSH_01: AudioStream = preload("uid://bogjfni3e0fg0")
const UI_SIDE_WHOOSH_02: AudioStream = preload("uid://d14vsrp826wur")
const UI_SIDE_WHOOSH_03: AudioStream = preload("uid://bwgaa5uycbquj")
const UI_SIDE_WHOOSH_04: AudioStream = preload("uid://cap12bckduird")
const SFX_LU: Dictionary[ID.SFX, Array] = {
	ID.SFX.BOOK_OPEN: [UI_BOOK_OPEN],
	ID.SFX.BOOK_CLOSE: [UI_BOOK_CLOSE],
	ID.SFX.PAGE_LEFT: [UI_FLIP_PAGE_LEFT_01, UI_FLIP_PAGE_LEFT_02, UI_FLIP_PAGE_LEFT_03],
	ID.SFX.PAGE_RIGHT: [UI_FLIP_PAGE_RIGHT_01, UI_FLIP_PAGE_RIGHT_02, UI_FLIP_PAGE_RIGHT_03],
	ID.SFX.WOOSH: [UI_SIDE_WHOOSH_01, UI_SIDE_WHOOSH_02, UI_SIDE_WHOOSH_03, UI_SIDE_WHOOSH_04],
}

const MUSIC_MAIN: AudioStream = preload("uid://021ktgycle2k")

const AMBIENCE_LOOP_LU: Dictionary[ID.Ambience, AudioStream] = {
	ID.Ambience.DEFAULT: AMB_MAIN_01
}
const MUSIC_LOOP_LU: Dictionary[ID.Ambience, AudioStream] = {
	ID.Ambience.DEFAULT: MUSIC_MAIN
}


var _ambience_loop_player: AudioStreamPlayer
var _music_loop_player: AudioStreamPlayer
var _ambience_inclusion_timer: Timer
var _current_ambience_id := ID.Ambience.NULL



func oneshot(id: ID.SFX) -> void:
	if IS_PRINT_DEBUG:
		print("oneshot():", ID.SFX_STRING[id])
	_play_oneshot(SFX_LU[id], &"UI")


func set_ambience(id: ID.Ambience) -> void:
	_current_ambience_id = id
	_ambience_loop_player.stream = AMBIENCE_LOOP_LU[id]
	_music_loop_player.volume_linear = 0.5
	_ambience_loop_player.play()
	_music_loop_player.stream = MUSIC_LOOP_LU[id]
	_music_loop_player.volume_linear = 0.25
	_music_loop_player.play()
	_ambience_inclusion_timer.start(randf_range(INCLUSION_FREQUENCY_RANGE.x, INCLUSION_FREQUENCY_RANGE.y))


func _ready() -> void:
	_music_loop_player = AudioStreamPlayer.new()
	_music_loop_player.bus = &"Muisc"
	add_child(_music_loop_player)
	
	_ambience_loop_player = AudioStreamPlayer.new()
	_ambience_loop_player.bus = &"Ambience"
	add_child(_ambience_loop_player)
	
	_ambience_inclusion_timer = Timer.new()
	add_child(_ambience_inclusion_timer)
	_ambience_inclusion_timer.timeout.connect(func() -> void:
		var inclusions = AMBIENCE_INCLUSIONS_LU[_current_ambience_id]
		_play_oneshot(inclusions, &"Ambience_ext")
	)
	

func _play_oneshot(sfx_group: Array, bus: StringName) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = sfx_group[randi_range(0, sfx_group.size()-1)]
	player.bus = bus
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
