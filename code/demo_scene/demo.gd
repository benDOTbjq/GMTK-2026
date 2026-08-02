extends Node3D
class_name Level

@onready var gui: GUI = $GUI
@onready var camera_3d: CameraManager = $Camera3D
@onready var book: BookManager = $Book

@onready var wall_sprite: Sprite3D = $DemonWallSprite
@onready var table_sprite: Sprite3D = $DemonTableSprite
@onready var pentagram_sprite_3d: Sprite3D = $PentagramSprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_label_3d: Label3D = %TitleLabel3D

@export var candles: Array[Candle] = []
@onready var name_label_3d: Label3D = %NameLabel3D

var name_start_transform := Transform3D(Vector3(0.089284, 0.007715, 0.008302), Vector3(0.000562, 0.062834, -0.064433), Vector3(-0.011319, 0.063972, 0.062285), Vector3(0.164, 0.9, 0.632))
var name_mid_transform := Transform3D(Vector3(0.09, 0.0, 0.0), Vector3(0.0, 0.09, 0.0), Vector3(0.0, 0.0, 0.09), Vector3(0.0, 0.026, -0.234))


var curr_view := ID.CameraMode.TITLE
var curr_artifact: Artifact = null
var curr_demon_info: DemonInfo = null
var shadow_frame_id: int = 0
var shadow_frame_time: float = 0
var dialog_box_alive_time: float = 0

var shadow_shake_strengh: float = 0.0
var shadow_shake_fade: float = 5.0

var curr_actions: int = -1
var items_used: Array[ID.Item]

var demons_number: int = 9

func _ready() -> void:
	Bus.set_view.connect(_view_state_change)
	Bus.use_item.connect(use_item)
	book.close()
	AudioManager.set_music(ID.Music.TITLE, 0.0)
	Bus.name_selected.connect(_guess_name)
	name_label_3d.visible = false
	for candle in candles:
		candle.turn_on(true)


func _guess_name(combined_type_id: int, demon_name: String) -> void:
	if curr_demon_info == null:
		show_dialog("Not yet")
		return
	if combined_type_id == DemonManager.get_combined_type_id(curr_demon_info.type1, curr_demon_info.type2):
		AudioManager.oneshot(ID.SFX.EXORCISE_SUCCESS)
	else:
		AudioManager.oneshot(ID.SFX.EXORCISE_FAIL)
	name_label_3d.visible = true
	name_label_3d.text = demon_name
	name_label_3d.global_transform = name_start_transform
	camera_3d.update_camera_mode(ID.CameraMode.TABLE, true)
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(name_label_3d, "transform", name_mid_transform, 1.5)
	await t.finished
	name_label_3d.visible = false
	guess_demon(combined_type_id)
	_view_state_change(ID.CameraMode.TABLE)

func _view_state_change(next_view: ID.CameraMode) -> void:
	if next_view == curr_view:
		return
	
	gui.book_open_button.visible = true
	gui.book_close_button.visible = false
	gui.salt_button.visible = false
	gui.prayer_button.visible = false
	gui.iron_button.visible = false
	gui.water_button.visible = false
	gui.table_button.visible = false
	
	match curr_view:
		ID.CameraMode.TITLE:
			_exit_title()
		ID.CameraMode.BOOK:
			book.close()
	
	match next_view:
		ID.CameraMode.BOOK:
			book.open()
			gui.book_open_button.visible = false
			gui.book_close_button.visible = true
		ID.CameraMode.TABLE:
			gui.salt_button.visible = true
			gui.prayer_button.visible = true
			gui.iron_button.visible = true
			gui.water_button.visible = true
		ID.CameraMode.SHELF:
			gui.book_open_button.visible = false
			gui.table_button.visible = true
			
	if next_view != ID.CameraMode.BOOK and curr_view != ID.CameraMode.BOOK:
		AudioManager.oneshot(ID.SFX.WOOSH)
	camera_3d.update_camera_mode(next_view)
	curr_view = next_view


func _process(delta: float) -> void:
	if %DialogBox.visible:
		dialog_box_alive_time += delta
		if dialog_box_alive_time >= 5.0:
			%DialogBox.visible = false
			dialog_box_alive_time = 0
	
	if curr_demon_info != null:
		var total = curr_demon_info.shadow_anim.get_frame_count("default")
		var curr_frame_time = 0.05 #curr_demon_info.shadow_anim.get_frame_duration("default", shadow_frame_id)
		
		#pentagram_sprite_3d.global_position = Vector3(0.014, 0.775, -0.228) + (delta * Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)))
		pentagram_sprite_3d.rotation.z += delta * 0.5
		shadow_frame_time += delta
		if shadow_frame_time > curr_frame_time:
			shadow_frame_time -= curr_frame_time
			shadow_frame_id = (shadow_frame_id + 1) % total
			wall_sprite.texture = curr_demon_info.shadow_anim.get_frame_texture("default", shadow_frame_id)
			table_sprite.texture = curr_demon_info.shadow_anim.get_frame_texture("default", shadow_frame_id)
	
	if shadow_shake_strengh > 0:
		shadow_shake_strengh = lerpf(shadow_shake_strengh, 0 , delta * shadow_shake_fade)
		var table_shake = Vector3(randf_range(-shadow_shake_strengh, shadow_shake_strengh), 0.0, randf_range(-shadow_shake_strengh, shadow_shake_strengh))
		var wall_shake = Vector3(randf_range(-shadow_shake_strengh, shadow_shake_strengh), randf_range(-shadow_shake_strengh, shadow_shake_strengh), 0.0)
		table_sprite.position = Vector3(0.957, 0.653, -0.143) + table_shake
		wall_sprite.position = Vector3(0.0, 0.699, -1.734) + wall_shake

func setup_demon(artifact: Artifact) -> void:
	curr_artifact = artifact
	curr_demon_info = artifact.demon_info
	curr_actions = curr_demon_info.actions
	shadow_frame_id = 0
	items_used.clear()
	
	var frame = curr_demon_info.shadow_anim.get_frame_texture("default", shadow_frame_id)
	wall_sprite.texture = frame
	table_sprite.texture = frame
	animation_player.play("spawn_shadow")
	AudioManager.set_music(ID.Music.DEFAULT)
	AudioManager.loop(ID.SFXLoop.PENAGRAM)
	AudioManager.oneshot(ID.SFX.SUMMON)
	
	update_candles()


func use_item(item: ID.Item) -> void:
	if curr_demon_info == null:
		show_dialog("Not yet")
		return
	
	var is_used := items_used.has(item)
	var effectiveness = DemonManager.check_item_effectivness(item, curr_demon_info.type1, curr_demon_info.type2)
	
	if is_used: 
		match effectiveness:
			3: show_dialog("You already used this item.\nThe demon was strangely uneffected")
			0: show_dialog("You already used this item.\nThe demon was unaffected")
			-2: show_dialog("You already used this item.\nThe demon was extremely empowered")
			-1: show_dialog("You already used this item.\nThe demon was empowered")
			1: show_dialog("You already used this item.\nThe demon was weakened")
			2: show_dialog("You already used this item.\nThe demon was extremely weakened")
	else:
		AudioManager.play_item(item, effectiveness)
		match effectiveness:
			3:
				show_dialog("The demon is strangely uneffected", false)
				effectiveness = 0
			0:
				show_dialog("The demon is unaffected", false)
			-2:
				camera_3d.shake_camera(0.2)
				show_dialog("The demon is extremely empowered", false)
			-1:
				camera_3d.shake_camera(0.1)
				show_dialog("The demon is empowered", false)
			1:
				shadow_shake_strengh = 0.1
				show_dialog("The demon is weakened", false)
			2:
				shadow_shake_strengh = 0.2
				show_dialog("The demon is extremely weakened", false)
		curr_actions += effectiveness - 1
		items_used.append(item)
		update_candles(true)


func guess_demon(combined_type_id: int) -> void:
	if combined_type_id == DemonManager.get_combined_type_id(curr_demon_info.type1, curr_demon_info.type2):
		animation_player.play_backwards("spawn_shadow")
		curr_artifact.despawn()
		curr_artifact = null
		curr_demon_info = null
		curr_actions = 0
		AudioManager.set_music(ID.Music.NULL)
		AudioManager.loop(ID.SFXLoop.PENAGRAM, false)
		
		demons_number -= 1
		if demons_number <= 0:
			gui._show_end_screen(true)
	else:
		curr_actions -= 2
		camera_3d.shake_camera(0.2)
		show_dialog("...That wasn't the\nright name.", false)
		book.close()
		update_candles(true)


func clear_curr_demon() -> void:
	if curr_demon_info == null:
		return


func show_dialog(text: String, is_voice := true) -> void:
	if is_voice:
		AudioManager.oneshot(ID.SFX.VOICE)
	dialog_box_alive_time = 0
	%DialogBox.visible = true
	%BubbleText.text = text


func update_candles(is_check_death := false) -> void:
	gui.set_letterbox(true)
	await create_tween().tween_interval(2.0).finished
	for i in candles.size():
		if i < curr_actions:
			if not candles[i].is_on:
				candles[i].turn_on()
				await create_tween().tween_interval(0.5).finished
		else:
			if candles[i].is_on:
				candles[i].turn_off()
				await create_tween().tween_interval(0.5).finished
	if is_check_death and curr_actions <= 0:
		gui._show_end_screen(false)
	gui.set_letterbox(false)
	


func _exit_title() -> void:
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(title_label_3d, "modulate:a", 0.0, 0.5)
	gui.title_button.queue_free()
	AudioManager.set_ambience(ID.Ambience.DEFAULT)
	AudioManager.set_music(ID.Music.NULL)
	await t.finished
	title_label_3d.queue_free()
	%DialogBox.reparent(camera_3d)
	for candle in candles:
		candle.turn_off(true)
