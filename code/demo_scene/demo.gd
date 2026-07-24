extends Node3D

@onready var gui: GUI = $GUI
@onready var camera_3d: CameraManager = $Camera3D
@onready var book: BookManager = $Book

@onready var wall_sprite: Sprite3D = $DemonWallSprite
@onready var table_sprite: Sprite3D = $DemonTableSprite

@export var test_demon: DemonInfo
var curr_demon_info : DemonInfo = null

var shadow_frame_id: int = 0
var shadow_frame_time: float = 0

func _ready() -> void:
	gui.menu_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.SHELF))
	gui.table_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.TABLE))
	gui.book_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.BOOK))
	
	gui.book_button.pressed.connect(func() -> void:
		book.set_content(ID.Page.TYPE_CHART, ID.Page.DEMON)
		book.open())
	gui.menu_button.pressed.connect(book.close)
	gui.table_button.pressed.connect(book.close)
	
	curr_demon_info = test_demon
	setup_demon()
	AudioManager.set_ambience(ID.Ambience.DEFAULT)

func _process(delta: float) -> void:
	var total = curr_demon_info.shadow_anim.get_frame_count("default")
	var curr_frame_time = 0.05#curr_demon_info.shadow_anim.get_frame_duration("default", shadow_frame_id)
	
	shadow_frame_time += delta
	if shadow_frame_time > curr_frame_time:
		shadow_frame_time -= curr_frame_time
		shadow_frame_id = (shadow_frame_id + 1) % total
		wall_sprite.texture = curr_demon_info.shadow_anim.get_frame_texture("default", shadow_frame_id)
		table_sprite.texture = curr_demon_info.shadow_anim.get_frame_texture("default", shadow_frame_id)

func setup_demon() -> void:
	var frame = curr_demon_info.shadow_anim.get_frame_texture("default", 0)
	wall_sprite.texture = frame
