extends Control


@onready var button: Button = $Button
@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D


func _ready() -> void:
	button.pressed.connect(AudioManager.oneshot.bind(ID.SFX.PAGE_RIGHT))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mesh_instance_2d.position = event.position
