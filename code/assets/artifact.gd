extends Node3D
class_name Artifact

@export var demon_info : DemonInfo
@export var mesh: Node3D

@onready var despawn_particles: CPUParticles3D = $DespawnParticles

func _ready() -> void:
	$Area3D.input_event.connect(_on_area_3d_input_event)
	$Area3D.mouse_entered.connect(_on_area_3d_mouse_entered)
	$Area3D.mouse_exited.connect(_on_area_3d_mouse_exited)

func _on_area_3d_mouse_entered() -> void:
	if get_parent().curr_demon_info == null:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_area_3d_mouse_exited() -> void:
	if get_parent().curr_demon_info == null:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and get_parent().curr_demon_info == null:
		var t = get_tree().create_tween()
		t.tween_property(self, "position", Vector3(0.015, 0.659, -0.292), 0.5).set_trans(Tween.TRANS_CUBIC)
		t.set_ease(Tween.EASE_IN_OUT)
		t.tween_callback(get_parent().setup_demon.bind(self))
		Bus.set_view.emit(ID.CameraMode.TABLE)

func despawn() -> void:
	despawn_particles.emitting = true
	var t = get_tree().create_tween()
	t.tween_callback(mesh.hide.bind()).set_delay(0.5)
	t.tween_callback(mesh.queue_free.bind()).set_delay(0.5)
