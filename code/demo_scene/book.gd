class_name BookManager extends Node3D


const OPEN_ROT := Vector3(deg_to_rad(45), 0.0, deg_to_rad(7.5))
const COVER_OPEN_ROT := deg_to_rad(-165)
const OPEN_POSITION := Vector3(0.0, 0.94, 0.747)

const CLOSED_ROT := Vector3(deg_to_rad(8.5), 0.0, 0.0)
const CLOSED_POSITION := Vector3(0.0, 0.67, 0.627)
const TRANSITON_TIME := 0.6


@onready var book_without_bend: Node3D = %book_without_bend
@onready var front_cover: MeshInstance3D = %book_without_bend/FrontCover


func open() -> void:
	var t:= create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(front_cover, "rotation:x", COVER_OPEN_ROT, TRANSITON_TIME)
	t.parallel()
	t.tween_property(book_without_bend, "rotation", OPEN_ROT, TRANSITON_TIME)


func close() -> void:
	var t:= create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(front_cover, "rotation:x", 0.0, TRANSITON_TIME)
	t.parallel()
	t.tween_property(book_without_bend, "rotation", CLOSED_ROT, TRANSITON_TIME)
