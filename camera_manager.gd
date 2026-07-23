extends Camera3D
class_name CameraManager

static var _instance: CameraManager

enum CameraMode
{
	TABLE,
	SHELF,
	BOOK
}

@export var mode_transition_time: float = .75
@export var table_rotation: Vector3
@export var shelf_rotation: Vector3
@export var book_rotation: Vector3

func _ready() -> void:
	_instance = self
	_update_camera_mode(CameraMode.TABLE)

func _update_camera_mode(new_mode: CameraMode):
	var target_rotation
	match new_mode:
		CameraMode.TABLE: target_rotation = Basis.from_euler(table_rotation)
		CameraMode.SHELF: target_rotation = Basis.from_euler(shelf_rotation)
		CameraMode.BOOK: target_rotation = Basis.from_euler(book_rotation)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "basis", target_rotation, mode_transition_time).set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

static func update_camera_mode(new_mode: CameraMode):
	_instance._update_camera_mode(new_mode)
	pass
