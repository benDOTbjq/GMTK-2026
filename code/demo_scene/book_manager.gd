class_name BookManager extends Node3D


const OPEN_ROT := Vector3(deg_to_rad(45), 0.0, deg_to_rad(7.5))
const COVER_OPEN_ROT := deg_to_rad(-165)
const OPEN_POSITION := Vector3(0.0, 0.94, 0.747)

const CLOSED_ROT := Vector3(deg_to_rad(8.5), 0.0, 0.0)
const CLOSED_POSITION := Vector3(0.0, 0.67, 0.627)
const TRANSITON_TIME := 0.6

const PAGE_TURN_TIME := 0.4
const LEFTMOST_PAGE_MIMIC_ROT = Vector3(0.0, 0.0, deg_to_rad(165))
const RIGHTMOST_PAGE_MIMIC_ROT = Vector3.ZERO

const PAGE_DEMON = preload("uid://cw7bgxc78qxub")
const PAGE_CANDLE = preload("uid://dt2vt4lnhrgr7")
const PAGE_TYPE_CHART = preload("uid://da2kt5b4ih837")
const PAGE_PENTAGRAM = preload("uid://c3wknpva8pa1s")


var _pages: Dictionary[ID.Page, Node]
var _is_closed := true


var _left_static_texture: Texture
var _right_static_texture: Texture
var _left_moving_texture: Texture
var _right_moving_texture: Texture

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
	
	front_cover.rotation_degrees = Vector3(0, 90, 180)

var fun := true
func open() -> void:
	if _is_closed:
		AudioManager.oneshot(ID.SFX.BOOK_OPEN)
	else:
		if fun:
			set_content(ID.Page.TYPE_CHART, ID.Page.DEMON)
		else:
			flip_right(ID.Page.CANDLE, ID.Page.PENTAGRAM)
		fun = not fun
		return
	var t:= create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(front_cover, "rotation:x", COVER_OPEN_ROT, TRANSITON_TIME)
	t.parallel()
	t.tween_property(book_without_bend, "rotation", OPEN_ROT, TRANSITON_TIME)
	_is_closed = false
	
	set_content(ID.Page.CANDLE, ID.Page.TYPE_CHART)


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
	page_hinge.rotation = RIGHTMOST_PAGE_MIMIC_ROT
	_left_static_texture = ImageTexture.create_from_image(_left_viewport_texture.get_image())
	_left_moving_texture = ImageTexture.create_from_image(_right_viewport_texture.get_image())
	_right_static_texture = _right_viewport_texture
	_right_moving_texture = _left_viewport_texture
	set_content(next_left, next_right)
	right_content_mesh.material_override.albedo_texture = _right_static_texture
	left_content_mesh.material_override.albedo_texture = _left_static_texture
	right_mimic_mesh.material_override.albedo_texture = _right_moving_texture
	left_mimic_mesh.material_override.albedo_texture = _left_moving_texture
	right_mimic_mesh.visible = true
	left_mimic_mesh.visible = true
	
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	t.tween_property(page_hinge, "rotation", LEFTMOST_PAGE_MIMIC_ROT, PAGE_TURN_TIME)
	await t.finished
	
	right_content_mesh.material_override.albedo_texture = _right_viewport_texture
	left_content_mesh.material_override.albedo_texture = _left_viewport_texture
	right_mimic_mesh.visible = false
	left_mimic_mesh.visible = false
