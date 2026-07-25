class_name BookManager extends Node3D


const OPEN_ROT := Vector3(deg_to_rad(45), 0.0, deg_to_rad(7.5))
const COVER_OPEN_ROT := deg_to_rad(-165)
const OPEN_POSITION := Vector3(0.0, 0.94, 0.747)

const CLOSED_ROT := Vector3(deg_to_rad(8.5), 0.0, 0.0)
const CLOSED_POSITION := Vector3(0.0, 0.67, 0.627)
const TRANSITON_TIME := 0.6

const PAGE_TURN_TIME := 0.4
const PAGE_TURN_TIME_H := PAGE_TURN_TIME / 2
const LEFTMOST_PAGE_MIMIC_ROT = Vector3(0.0, 0.0, deg_to_rad(165))
const RIGHTMOST_PAGE_MIMIC_ROT = Vector3.ZERO

const PAGE_DEMON = preload("uid://cw7bgxc78qxub")
const PAGE_CANDLE = preload("uid://dt2vt4lnhrgr7")
const PAGE_TYPE_CHART = preload("uid://da2kt5b4ih837")
const PAGE_PENTAGRAM = preload("uid://c3wknpva8pa1s")
const PAGE_MULTI_PENT = preload("uid://2kxxg7p7qw3d")
const PAGE_NOISE_DEMON = preload("uid://dqieqksa3l20y")
const PAGE_ITEMS_LEFT = preload("uid://b6vi4dhin2lw1")
const PAGE_ITEMS_RIGHT = preload("uid://br53hbh38f47v")

const PAGE_ORDER: Array[Array] = [
	[ID.Page.TYPE_CHART, ID.Page.DEMON],
	[ID.Page.ITEMS_RIGHT, ID.Page.ITEMS_LEFT],
	[ID.Page.MULTIPENT, ID.Page.PENTAGRAM],
	[ID.Page.CANDLE, ID.Page.NOISE_DEMON],
]

var _book_index := 0
var _pages: Dictionary[ID.Page, Node]
var _is_closed := true
var _is_mid_turn := false

var _prev_left_texture: Texture
var _prev_right_texture: Texture

@onready var _curr_left_id := ID.Page.NULL
@onready var _curr_right_id := ID.Page.NULL

@onready var book_without_bend: Node3D = %book_without_bend
@onready var front_cover: MeshInstance3D = %book_without_bend/FrontCover
@onready var left_sub_viewport: SubViewport = %LeftSubViewport
@onready var right_sub_viewport: SubViewport = %RightSubViewport

@onready var page_hinge: Node3D = %PageHinge
@onready var right_content_mesh: MeshInstance3D = %RightContentMesh
@onready var left_content_mesh: MeshInstance3D = %LeftContentMesh
@onready var left_mimic_mesh: MeshInstance3D = %PageHinge/LeftMimicMesh
@onready var right_mimic_mesh: MeshInstance3D = %PageHinge/RightMimicMesh

@onready var _left_viewport_texture: ViewportTexture = left_sub_viewport.get_texture()
@onready var _right_viewport_texture: ViewportTexture = right_sub_viewport.get_texture()


func _ready() -> void:
	_pages[ID.Page.CANDLE] = PAGE_CANDLE.instantiate()
	_pages[ID.Page.DEMON] = PAGE_DEMON.instantiate()
	_pages[ID.Page.TYPE_CHART] = PAGE_TYPE_CHART.instantiate()
	_pages[ID.Page.PENTAGRAM] = PAGE_PENTAGRAM.instantiate()
	_pages[ID.Page.MULTIPENT] = PAGE_MULTI_PENT.instantiate()
	_pages[ID.Page.NOISE_DEMON] = PAGE_NOISE_DEMON.instantiate()
	_pages[ID.Page.ITEMS_RIGHT] = PAGE_ITEMS_RIGHT.instantiate()
	_pages[ID.Page.ITEMS_LEFT] = PAGE_ITEMS_LEFT.instantiate()
	
	front_cover.rotation_degrees = Vector3(0, 90, 180)
	@warning_ignore("int_as_enum_without_cast")
	set_content(PAGE_ORDER[0][0], PAGE_ORDER[0][1])


func next() -> void:
	if _is_closed or _is_mid_turn or _book_index >= PAGE_ORDER.size()-1:
		return
	_book_index += 1
	flip_right(PAGE_ORDER[_book_index][0], PAGE_ORDER[_book_index][1])


func prev() -> void:
	if _is_closed or _is_mid_turn or _book_index <= 0:
		return
	_book_index -= 1
	flip_left(PAGE_ORDER[_book_index][0], PAGE_ORDER[_book_index][1])


func open() -> void:
	if _is_closed:
		AudioManager.oneshot(ID.SFX.BOOK_OPEN)
	var t:= create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(front_cover, "rotation:x", COVER_OPEN_ROT, TRANSITON_TIME)
	t.parallel()
	t.tween_property(book_without_bend, "rotation", OPEN_ROT, TRANSITON_TIME)
	_is_closed = false


func close() -> void:
	if not _is_closed:
		AudioManager.oneshot(ID.SFX.BOOK_CLOSE)
	var t:= create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(front_cover, "rotation:x", 0.0, TRANSITON_TIME)
	t.parallel()
	t.tween_property(book_without_bend, "rotation", CLOSED_ROT, TRANSITON_TIME)
	_is_closed = true


func set_content(left: ID.Page, right: ID.Page) -> void:
	if _curr_left_id != ID.Page.NULL:
		left_sub_viewport.remove_child(_pages[_curr_left_id])
	if _curr_right_id != ID.Page.NULL:
		right_sub_viewport.remove_child(_pages[_curr_right_id])
	left_sub_viewport.add_child(_pages[left])
	right_sub_viewport.add_child(_pages[right])
	_curr_left_id = left
	_curr_right_id = right
	

func flip_right(next_left: ID.Page, next_right: ID.Page) -> void:
	_is_mid_turn = true
	page_hinge.rotation = RIGHTMOST_PAGE_MIMIC_ROT
	_prev_left_texture = ImageTexture.create_from_image(_left_viewport_texture.get_image())
	_prev_right_texture = ImageTexture.create_from_image(_right_viewport_texture.get_image())
	set_content(next_left, next_right)
	right_content_mesh.material_override.albedo_texture = _right_viewport_texture
	left_content_mesh.material_override.albedo_texture = _prev_left_texture
	right_mimic_mesh.material_override.albedo_texture = _left_viewport_texture
	left_mimic_mesh.material_override.albedo_texture = _prev_right_texture
	right_mimic_mesh.visible = true
	left_mimic_mesh.visible = true
	
	AudioManager.oneshot(ID.SFX.PAGE_RIGHT)
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	t.tween_property(page_hinge, "rotation", LEFTMOST_PAGE_MIMIC_ROT, PAGE_TURN_TIME)
	var t2 = create_tween()
	t2.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	t2.tween_property(page_hinge, "scale:x", 0.25, PAGE_TURN_TIME_H)
	t2.set_ease(Tween.EASE_OUT)
	t2.tween_property(page_hinge, "scale:x", 1.0, PAGE_TURN_TIME_H)
	await t.finished
	
	left_content_mesh.material_override.albedo_texture = _left_viewport_texture
	right_mimic_mesh.visible = false
	left_mimic_mesh.visible = false
	_prev_left_texture = null
	_prev_right_texture = null
	_is_mid_turn = false


func flip_left(next_left: ID.Page, next_right: ID.Page) -> void:
	_is_mid_turn = true
	page_hinge.rotation = LEFTMOST_PAGE_MIMIC_ROT
	_prev_left_texture = ImageTexture.create_from_image(_left_viewport_texture.get_image())
	_prev_right_texture = ImageTexture.create_from_image(_right_viewport_texture.get_image())
	set_content(next_left, next_right)
	right_content_mesh.material_override.albedo_texture = _prev_right_texture
	left_content_mesh.material_override.albedo_texture = _left_viewport_texture 
	right_mimic_mesh.material_override.albedo_texture = _prev_left_texture
	left_mimic_mesh.material_override.albedo_texture = _right_viewport_texture
	right_mimic_mesh.visible = true
	left_mimic_mesh.visible = true
	
	AudioManager.oneshot(ID.SFX.PAGE_LEFT)
	var t1 = create_tween()
	t1.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	t1.tween_property(page_hinge, "rotation", RIGHTMOST_PAGE_MIMIC_ROT, PAGE_TURN_TIME)
	var t2 = create_tween()
	t2.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	t2.tween_property(page_hinge, "scale:x", 0.25, PAGE_TURN_TIME_H)
	t2.set_ease(Tween.EASE_OUT)
	t2.tween_property(page_hinge, "scale:x", 1.0, PAGE_TURN_TIME_H)
	await t1.finished
	
	right_content_mesh.material_override.albedo_texture = _right_viewport_texture
	left_content_mesh.material_override.albedo_texture = _left_viewport_texture
	right_mimic_mesh.visible = false
	left_mimic_mesh.visible = false
	_prev_left_texture = null
	_prev_right_texture = null
	_is_mid_turn = false
