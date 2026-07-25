extends Camera3D
class_name CameraManager

@export var mode_transition_time: float = .75
@export var table_rotation: Vector3
@export var shelf_rotation: Vector3
@export var book_rotation: Vector3
@export var title_rotation: Vector3

var _title_position := Vector3(0.007, 1.573, -0.252)
var _default_position := Vector3(0.015, 1.379, 0.945)


var _last_mode := ID.CameraMode.TITLE

func _ready() -> void:
	rotation_degrees = title_rotation
	position = _title_position


func update_camera_mode(new_mode: ID.CameraMode):
	var target_rotation
	
	if _last_mode != ID.CameraMode.BOOK and new_mode != ID.CameraMode.BOOK:
		AudioManager.oneshot(ID.SFX.WOOSH)
	
	match new_mode:
		ID.CameraMode.TABLE: target_rotation = Basis.from_euler(table_rotation)
		ID.CameraMode.SHELF: target_rotation = Basis.from_euler(shelf_rotation)
		ID.CameraMode.BOOK: target_rotation = Basis.from_euler(book_rotation)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "basis", target_rotation, mode_transition_time)
	if _last_mode == ID.CameraMode.TITLE:
		tween.parallel()
		tween.tween_property(self, "position", _default_position, mode_transition_time)
		
	_last_mode = new_mode
