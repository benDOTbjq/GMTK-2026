extends Node3D

@onready var gui: GUI = $GUI
@onready var camera_3d: CameraManager = $Camera3D
@onready var book: BookManager = $Book

@onready var wall_sprite: Sprite3D = $DemonWallSprite
@onready var table_sprite: Sprite3D = $DemonTableSprite

@export var test_demon: DemonInfo
var curr_demon_info : DemonInfo

func _ready() -> void:
	gui.menu_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.SHELF))
	gui.table_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.TABLE))
	gui.book_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.BOOK))
	
	gui.book_button.pressed.connect(book.open)
	gui.menu_button.pressed.connect(book.close)
	gui.table_button.pressed.connect(book.close)
	
	curr_demon_info = test_demon
	setup_demon()

func setup_demon() -> void:
	wall_sprite.texture = curr_demon_info.shadow_texture
	table_sprite.texture = curr_demon_info.shadow_texture
	
	#var tween = get_tree().create_tween()
	#tween 
