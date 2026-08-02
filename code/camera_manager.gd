extends Camera3D
class_name CameraManager

@export var mode_transition_time: float = .75
@export var mode_transition_slow_time: float = 1.5
@export var table_rotation: Vector3
@export var shelf_rotation: Vector3
@export var book_rotation: Vector3
@export var title_rotation: Vector3

var shake_fade: float = 5.0
var curr_shake_strengh: float = 0.0

var _title_position := Vector3(0.007, 1.573, -0.252)
var _default_position := Vector3(0.015, 1.379, 0.945)
var _look_left_offset := Vector3(0.0, deg_to_rad(2.5), 0.0)
var _look_right_offset := Vector3(0.0, deg_to_rad(-2.5), 0.0)
var _look_down_offset := Vector3(deg_to_rad(-2.5), 0.0, 0.0)
var _look_up_offset := Vector3(deg_to_rad(2.5), 0.0, 0.0)
var _last_mode := ID.CameraMode.TITLE
var _hover_tween: Tween
var _main_tween: Tween

func _ready() -> void:
	rotation_degrees = title_rotation
	position = _title_position
	Bus.hover_view.connect(on_hover)


func on_hover(view_id: ID.CameraMode, is_hover: bool) -> void:
	if _main_tween != null and _main_tween.is_valid(): 
		return
	
	var current_rotation = table_rotation if _last_mode == ID.CameraMode.TABLE else (book_rotation if _last_mode == ID.CameraMode.BOOK else shelf_rotation)
	var hover_rot := Vector3.ZERO
	if view_id == ID.CameraMode.SHELF and _last_mode != ID.CameraMode.SHELF:
		hover_rot =  current_rotation + _look_left_offset if is_hover else current_rotation
	if view_id == ID.CameraMode.TABLE and _last_mode == ID.CameraMode.SHELF:
		hover_rot = current_rotation + _look_right_offset if is_hover else current_rotation
	if view_id == ID.CameraMode.TABLE and _last_mode == ID.CameraMode.BOOK:
		hover_rot =  book_rotation + _look_up_offset if is_hover else book_rotation
	if view_id == ID.CameraMode.BOOK and _last_mode == ID.CameraMode.TABLE:
		hover_rot =  table_rotation + _look_down_offset if is_hover else table_rotation
	
	if hover_rot == Vector3.ZERO:
		return
		
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.stop()
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_hover_tween.tween_property(self, "rotation", hover_rot, 0.2)
	

func _process(delta: float) -> void:
	if curr_shake_strengh > 0:
		curr_shake_strengh = lerpf(curr_shake_strengh, 0 , delta * shake_fade)
		position = _default_position + Vector3(randf_range(-curr_shake_strengh, curr_shake_strengh), 
												randf_range(-curr_shake_strengh, curr_shake_strengh), 
												randf_range(-curr_shake_strengh, curr_shake_strengh))

func shake_camera(strength: float) -> void:
	curr_shake_strengh = strength

func update_camera_mode(new_mode: ID.CameraMode, is_slow := false):
	if new_mode == _last_mode:
		return
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.stop()
		_hover_tween.kill()
	var target_rotation
	match new_mode:
		ID.CameraMode.TABLE: target_rotation = Basis.from_euler(table_rotation)
		ID.CameraMode.SHELF: target_rotation = Basis.from_euler(shelf_rotation)
		ID.CameraMode.BOOK: target_rotation = Basis.from_euler(book_rotation)
	_main_tween = create_tween()
	_main_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_main_tween.tween_property(self, "basis", target_rotation, mode_transition_slow_time if is_slow else mode_transition_time)
	if _last_mode == ID.CameraMode.TITLE:
		_main_tween.parallel()
		_main_tween.tween_property(self, "position", _default_position, mode_transition_time)
		
	_last_mode = new_mode
