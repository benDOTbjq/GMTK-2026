extends Node3D


@onready var gui: GUI = $GUI
@onready var camera_3d: CameraManager = $Camera3D


func _ready() -> void:
	gui.menu_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.SHELF))
	gui.table_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.TABLE))
	gui.book_button.pressed.connect(camera_3d.update_camera_mode.bind(ID.CameraMode.BOOK))
