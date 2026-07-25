extends Node3D
class_name Level

@onready var gui: GUI = $GUI
@onready var camera_3d: CameraManager = $Camera3D
@onready var book: BookManager = $Book

@onready var wall_sprite: Sprite3D = $DemonWallSprite
@onready var table_sprite: Sprite3D = $DemonTableSprite
@onready var pentagram_sprite_3d: Sprite3D = $PentagramSprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var curr_demon_info: DemonInfo = null
var shadow_frame_id: int = 0
var shadow_frame_time: float = 0
var dialog_box_alive_time: float = 0

var curr_actions: int = -1
var items_used: Array[ID.Item]

func _ready() -> void:
	gui.menu_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.SHELF))
	gui.table_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.TABLE))
	gui.book_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.BOOK))
	gui.book_prev_button.pressed.connect(book.prev)
	gui.book_next_button.pressed.connect(book.next)
	
	gui.book_button.pressed.connect(book.open)
	gui.menu_button.pressed.connect(book.close)
	gui.table_button.pressed.connect(book.close)
	
	book.set_content(ID.Page.TYPE_CHART, ID.Page.DEMON)
	book.close()
	AudioManager.set_ambience(ID.Ambience.DEFAULT)

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

func setup_demon(artifact: Artifact) -> void:
	curr_demon_info = artifact.demon_info
	curr_actions = curr_demon_info.actions
	shadow_frame_id = 0
	items_used.clear()
	
	var frame = curr_demon_info.shadow_anim.get_frame_texture("default", shadow_frame_id)
	wall_sprite.texture = frame
	table_sprite.texture = frame
	animation_player.play("spawn_shadow")

func use_item(item: ID.Item) -> void:
	if items_used.has(item):
		show_dialog("You already used this item")
		return
	
	var effectiveness = DemonManager.check_item_effectivness(item, curr_demon_info.type1, curr_demon_info.type2)
	if effectiveness == 3:
		show_dialog("The demon is strangely uneffected")
		effectiveness = 0
	else:
		match effectiveness:
			-2: show_dialog("The demon is extremely empowered")
			-1: show_dialog("The demon is empowered")
			0: show_dialog("The demon is uneffected")
			1: show_dialog("The demon is weakned")
			2: show_dialog("The demon is extremely weakned")
	
	curr_actions += effectiveness - 1
	items_used.append(item)
	
	if curr_actions <= 0:
		show_dialog("you lost")

func guess_demon(type1: ID.DemonType, type2: ID.DemonType) -> void:
	if type1 == curr_demon_info.type1 and type2 == curr_demon_info.type2:
		animation_player.play_backwards("spawn_shadow")
	else:
		curr_actions -= 2

func clear_curr_demon() -> void:
	if curr_demon_info == null:
		return
	

func show_dialog(text: String) -> void:
	%DialogBox.visible = true
	%BubbleText.text = text
