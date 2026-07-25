extends Node


const IS_PRINT_DEBUG := false
const INCLUSION_FREQUENCY_RANGE := Vector2(10, 300) # seconds
const MAX_VOL_MUSIC := 0.7
const MAX_VOL_AMB := 0.7
const MAX_VOL_UI := 0.5

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
const UI_DIALOGUE_01: AudioStream = preload("uid://bpthv82l2noyy")
const UI_DIALOGUE_02: AudioStream = preload("uid://ckmlrc3sc01cc")
const UI_PENTAGRAM: AudioStream = preload("uid://bg4d1yftwo1pa")
const UI_SUMMON_01: AudioStream = preload("uid://dys3hxiqexcf3")
const UI_SUMMON_02: AudioStream = preload("uid://bscwkfxlj6es1")
const UI_SUMMON_03: AudioStream = preload("uid://dkjxq8jsojism")
const UI_NAME_HOVER: AudioStream = preload("uid://d1one3gjcmesg")
const UI_NAME_SELECT: AudioStream = preload("uid://bstltd1aiuioh")

const SFX_LU: Dictionary[ID.SFX, Array] = {
	ID.SFX.BOOK_OPEN: [UI_BOOK_OPEN],
	ID.SFX.BOOK_CLOSE: [UI_BOOK_CLOSE],
	ID.SFX.PAGE_LEFT: [UI_FLIP_PAGE_LEFT_01, UI_FLIP_PAGE_LEFT_02, UI_FLIP_PAGE_LEFT_03],
	ID.SFX.PAGE_RIGHT: [UI_FLIP_PAGE_RIGHT_01, UI_FLIP_PAGE_RIGHT_02, UI_FLIP_PAGE_RIGHT_03],
	ID.SFX.WOOSH: [UI_SIDE_WHOOSH_01, UI_SIDE_WHOOSH_02, UI_SIDE_WHOOSH_03, UI_SIDE_WHOOSH_04],
	ID.SFX.VOICE: [UI_DIALOGUE_01, UI_DIALOGUE_02],
	ID.SFX.SUMMON: [UI_SUMMON_01, UI_SUMMON_02, UI_SUMMON_03],
	ID.SFX.NAME_HOVER: [UI_NAME_HOVER],
	ID.SFX.NAME_SELECT: [UI_NAME_SELECT],
}

const SFX_LOOP_LU: Dictionary[ID.SFXLoop, AudioStream] = {
	ID.SFXLoop.PENAGRAM: UI_PENTAGRAM
}

const MUSIC_MAIN: AudioStream = preload("uid://021ktgycle2k")
const MUSIC_TITLE: AudioStream = preload("uid://c6mop3b2wchgt")

const AMBIENCE_LOOP_LU: Dictionary[ID.Ambience, AudioStream] = {
	ID.Ambience.DEFAULT: AMB_MAIN_01,
}
const MUSIC_LOOP_LU: Dictionary[ID.Music, AudioStream] = {
	ID.Music.DEFAULT: MUSIC_MAIN,
	ID.Music.TITLE: MUSIC_TITLE,
}


var _ambience_loop_player: AudioStreamPlayer
var _music_loop_player: AudioStreamPlayer
var _ambience_inclusion_timer: Timer
var _current_ambience_id := ID.Ambience.NULL
var _current_music_id := ID.Music.NULL
var _current_sfx_loops: Dictionary[ID.SFXLoop, AudioStreamPlayer]


func loop(id: ID.SFXLoop, start := true) -> void:
	if IS_PRINT_DEBUG:
		print("loop():", ID.SFX_STRING[id])
	if start:
		if _current_sfx_loops.has(id):
			return
		var player = AudioStreamPlayer.new()
		player.stream = SFX_LOOP_LU[id]
		player.bus = &"UI"
		player.volume_linear = MAX_VOL_UI
		add_child(player)
		player.play()
		_current_sfx_loops[id] = player
	else:
		if not _current_sfx_loops.has(id):
			return
		var t := create_tween()
		t.tween_property(_current_sfx_loops[id], "volume_linear", 0.0, 2.0)
		await t.finished
		_current_sfx_loops[id].queue_free()
		_current_sfx_loops[id] = null


func oneshot(id: ID.SFX) -> void:
	if IS_PRINT_DEBUG:
		print("oneshot():", ID.SFX_STRING[id])
	_play_oneshot(SFX_LU[id], &"UI")


func set_ambience(id: ID.Ambience, trans_time := 2.0) -> void:
	if id == _current_ambience_id:
		return
	
	var new_ambience_loop_player: AudioStreamPlayer
	if id != ID.Ambience.NULL:
		new_ambience_loop_player = AudioStreamPlayer.new()
		new_ambience_loop_player.bus = &"Ambience"
		new_ambience_loop_player.stream = AMBIENCE_LOOP_LU[id]
		new_ambience_loop_player.autoplay = true
		new_ambience_loop_player.volume_linear = 0
		add_child(new_ambience_loop_player)
	
	var t := create_tween()
	t.set_parallel()
	if _ambience_loop_player != null:
		t.tween_property(_ambience_loop_player, "volume_linear", 0.0, trans_time)
	if id != ID.Ambience.NULL:
		t.tween_property(new_ambience_loop_player, "volume_linear", MAX_VOL_AMB, trans_time)
	await t.finished
	
	if _ambience_loop_player != null:
		_ambience_loop_player.queue_free()
	_ambience_loop_player = new_ambience_loop_player if id != ID.Ambience.NULL else null
	_current_ambience_id = id
	_ambience_inclusion_timer.start(randf_range(INCLUSION_FREQUENCY_RANGE.x, INCLUSION_FREQUENCY_RANGE.y))


func set_music(id: ID.Music, trans_time := 2.0) -> void:
	if id == _current_music_id:
		return
	
	var new_music_loop_player: AudioStreamPlayer
	if id != ID.Music.NULL:
		new_music_loop_player = AudioStreamPlayer.new()
		new_music_loop_player.bus = &"Music"
		new_music_loop_player.stream = MUSIC_LOOP_LU[id]
		new_music_loop_player.autoplay = true
		new_music_loop_player.volume_linear = 0
		add_child(new_music_loop_player)
	
	var t := create_tween()
	t.set_parallel()
	if _music_loop_player != null:
		t.tween_property(_music_loop_player, "volume_linear", 0.0, trans_time)
	if id != ID.Music.NULL:
		t.tween_property(new_music_loop_player, "volume_linear", MAX_VOL_MUSIC, trans_time)
	await t.finished
	
	if _music_loop_player != null:
		_music_loop_player.queue_free()
	_music_loop_player = new_music_loop_player if id != ID.Music.NULL else null
	_current_music_id = id


func _ready() -> void:
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
	player.volume_linear = MAX_VOL_UI
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
