class_name BookManager extends Node3D


const OPEN_ROT := Vector3(deg_to_rad(45), 0.0, deg_to_rad(7.5))
const COVER_OPEN_ROT := deg_to_rad(-165)
const OPEN_POSITION := Vector3(0.0, 0.94, 0.747)

const CLOSED_ROT := Vector3(deg_to_rad(8.5), 0.0, 0.0)
const CLOSED_POSITION := Vector3(0.0, 0.67, 0.627)
const TRANSITON_TIME := 0.6

const PAGE_DEMON = preload("uid://cw7bgxc78qxub")
const PAGE_CANDLE = preload("uid://dt2vt4lnhrgr7")
const PAGE_TYPE_CHART = preload("uid://da2kt5b4ih837")

var _pages: Dictionary[ID.Page, Node]

@onready var _curr_left_id := ID.Page.NULL
@onready var _curr_right_id := ID.Page.NULL

@onready var book_without_bend: Node3D = %book_without_bend
@onready var front_cover: MeshInstance3D = %book_without_bend/FrontCover
@onready var left_sub_viewport: SubViewport = %LeftSubViewport
@onready var right_sub_viewport: SubViewport = %RightSubViewport


func _ready() -> void:
	_pages[ID.Page.CANDLE] = PAGE_CANDLE.instantiate()
	_pages[ID.Page.DEMON] = PAGE_DEMON.instantiate()
	_pages[ID.Page.TYPE_CHART] = PAGE_TYPE_CHART.instantiate()
	
	front_cover.rotation_degrees = Vector3(0, 90, 180)


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


func set_content(left: ID.Page, right: ID.Page) -> void:
	if _curr_left_id != ID.Page.NULL:
		left_sub_viewport.remove_child(_pages[_curr_left_id])
	if _curr_right_id != ID.Page.NULL:
		right_sub_viewport.remove_child(_pages[_curr_right_id])
	left_sub_viewport.add_child(_pages[left])
	right_sub_viewport.add_child(_pages[right])
