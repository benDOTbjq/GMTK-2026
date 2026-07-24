extends Node3D

@export var item_type: ID.Item

@onready var mesh : MeshInstance3D = $MeshInstance3D
var is_hovered : bool = false

func _ready() -> void:
	$Area3D.input_event.connect(_on_area_3d_input_event)
	$Area3D.mouse_entered.connect(_on_area_3d_mouse_entered)
	$Area3D.mouse_exited.connect(_on_area_3d_mouse_exited)

func _on_area_3d_mouse_entered() -> void:
	is_hovered = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_area_3d_mouse_exited() -> void:
	is_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var gui : GUI = $"../GUI"
		gui._test_item(item_type)
