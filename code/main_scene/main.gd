extends Control


const SPIN_TIME := 1.0
const SPIN_TIME_HALF := SPIN_TIME / 2

@onready var drill_texture_rect: TextureRect = %TopButtonContainer/DrillTextureRect
@onready var drill_button: Button = %TopButtonContainer/DrillTextureRect/DrillButton
@onready var sun_texture_rect: TextureRect = %TopButtonContainer/SunTextureRect
@onready var sun_button: Button = %TopButtonContainer/SunTextureRect/SunButton
@onready var radar_texture_rect: TextureRect = %TopButtonContainer/RadarTextureRect
@onready var radar_button: Button = %TopButtonContainer/RadarTextureRect/RadarButton

@onready var spooky_texture_rect: TextureRect = %BottomButtonContainer/SpookyTextureRect
@onready var spooky_button: Button = %BottomButtonContainer/SpookyTextureRect/SpookyButton
@onready var vending_texture_rect: TextureRect = %BottomButtonContainer/VendingTextureRect
@onready var vending_button: Button = %BottomButtonContainer/VendingTextureRect/VendingButton
@onready var warehouse_texture_rect: TextureRect = %BottomButtonContainer/WarehouseTextureRect
@onready var warehouse_button: Button = %BottomButtonContainer/WarehouseTextureRect/WarehouseButton

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var _pitch_lookup: Dictionary[TextureRect, float] = {
	drill_texture_rect: randf_range(0.5, 2.0),
	sun_texture_rect: randf_range(0.5, 2.0),
	radar_texture_rect: randf_range(0.5, 2.0),
	spooky_texture_rect: randf_range(0.5, 2.0),
	vending_texture_rect: randf_range(0.5, 2.0),
	warehouse_texture_rect: randf_range(0.5, 2.0),
}

func _ready() -> void:
	drill_button.pressed.connect(_spin_texture.bind(drill_texture_rect))
	sun_button.pressed.connect(_spin_texture.bind(sun_texture_rect))
	radar_button.pressed.connect(_spin_texture.bind(radar_texture_rect))
	spooky_button.pressed.connect(_spin_texture.bind(spooky_texture_rect))
	vending_button.pressed.connect(_spin_texture.bind(vending_texture_rect))
	warehouse_button.pressed.connect(_spin_texture.bind(warehouse_texture_rect))


func _spin_texture(texture_rect: TextureRect) -> void:
	var t1 := create_tween()
	t1.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	var half_rotation = texture_rect.offset_transform_rotation + PI
	t1.tween_property(texture_rect, "offset_transform_rotation", half_rotation, SPIN_TIME_HALF)
	
	t1.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	var end_rotation := texture_rect.offset_transform_rotation + TAU
	t1.tween_property(texture_rect, "offset_transform_rotation", end_rotation, SPIN_TIME)
	
	var t2 = create_tween()
	t2.tween_interval(0.2)
	await t2.finished
	audio_stream_player.pitch_scale = _pitch_lookup[texture_rect]
	audio_stream_player.play()
