extends Node3D
class_name Level

@onready var gui: GUI = $GUI
@onready var camera_3d: CameraManager = $Camera3D
@onready var book: BookManager = $Book

@onready var wall_sprite: Sprite3D = $DemonWallSprite
@onready var table_sprite: Sprite3D = $DemonTableSprite
@onready var pentagram_sprite_3d: Sprite3D = $PentagramSprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var curr_demon_info : DemonInfo = null
var shadow_frame_id: int = 0
var shadow_frame_time: float = 0

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
	AudioManager.set_ambience(ID.Ambience.DEFAULT)

func _process(delta: float) -> void:
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
	shadow_frame_id = 0
	var frame = curr_demon_info.shadow_anim.get_frame_texture("default", shadow_frame_id)
	wall_sprite.texture = frame
	table_sprite.texture = frame
	animation_player.play("spawn_shadow")
