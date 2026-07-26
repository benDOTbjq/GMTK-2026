extends Control

enum Demon {
	INFERNAL = 1,
	CELESTIAL = 2,
	CARNAL = 4,
	SPECTRAL = 8,
	ABYSSAL = 16,
	FAEIC = 32,
	LUCIFERIAN = 64,
	FERRIC = 128,
}

const DEMON_NAMES_LU: Dictionary[int, String] = {
	Demon.INFERNAL | Demon.INFERNAL: "tarnonoz",
	Demon.INFERNAL | Demon.CELESTIAL: "xolron",
	Demon.INFERNAL | Demon.CARNAL: "Frankfurter",
	Demon.INFERNAL | Demon.SPECTRAL: "dragthizil",
	Demon.INFERNAL | Demon.ABYSSAL: "jezgaraz",
	Demon.INFERNAL | Demon.FAEIC: "xullmorel",
	Demon.INFERNAL | Demon.LUCIFERIAN: "thagurod",
	Demon.INFERNAL | Demon.FERRIC: "rungralluz",
	
	Demon.CELESTIAL | Demon.CELESTIAL: "xarukath",
	Demon.CELESTIAL | Demon.CARNAL: "kar'gor",
	Demon.CELESTIAL | Demon.SPECTRAL: "sozzinar",
	Demon.CELESTIAL | Demon.ABYSSAL: "ogimaan",
	Demon.CELESTIAL | Demon.FAEIC: "drannonog",
	Demon.CELESTIAL | Demon.LUCIFERIAN: "xur'guzog",
	Demon.CELESTIAL | Demon.FERRIC: "brogdrun",
	
	Demon.CARNAL | Demon.CARNAL: "sozzonaath",
	Demon.CARNAL | Demon.SPECTRAL: "ozran",
	Demon.CARNAL | Demon.ABYSSAL: "trugmillon",
	Demon.CARNAL | Demon.FAEIC: "tharalon",
	Demon.CARNAL | Demon.LUCIFERIAN: "zugdrethon",
	Demon.CARNAL | Demon.FERRIC: "telgroth",
	
	Demon.SPECTRAL | Demon.SPECTRAL: "trog'thon",
	Demon.SPECTRAL | Demon.ABYSSAL: "thigomil",
	Demon.SPECTRAL | Demon.FAEIC: "jugthog",
	Demon.SPECTRAL | Demon.LUCIFERIAN: "brir'goraz",
	Demon.SPECTRAL | Demon.FERRIC: "zugrok",
	
	Demon.ABYSSAL | Demon.ABYSSAL: "sollmamin",
	Demon.ABYSSAL | Demon.FAEIC: "almalod",
	Demon.ABYSSAL | Demon.LUCIFERIAN: "unnozauth",
	Demon.ABYSSAL | Demon.FERRIC: "vezzodok",
	
	Demon.FAEIC | Demon.FAEIC: "takaman",
	Demon.FAEIC | Demon.LUCIFERIAN: "brogthig",
	Demon.FAEIC | Demon.FERRIC: "daggokor",
	
	Demon.FERRIC | Demon.LUCIFERIAN: "xungrumath",
	Demon.FERRIC | Demon.FERRIC: "annin",
	
	Demon.LUCIFERIAN | Demon.LUCIFERIAN: "tharexal",
	
}

@onready var inf_button: TextureButton = $InfButton
@onready var cel_button: TextureButton = $CelButton
@onready var car_button: TextureButton = $CarButton
@onready var spe_button: TextureButton = $SpeButton
@onready var aby_button: TextureButton = $AbyButton
@onready var fae_button: TextureButton = $FaeButton
@onready var luc_button: TextureButton = $LucButton
@onready var fer_button: TextureButton = $FerButton

@onready var name_label: Label = $NinePatchRect2/NameLabel
@onready var name_button: TextureButton = $NinePatchRect2/NameButton

@onready var _start_positions: Dictionary[BaseButton, Vector2] = {
	inf_button: inf_button.position,
	cel_button: cel_button.position,
	car_button: car_button.position,
	spe_button: spe_button.position,
	aby_button: aby_button.position,
	fae_button: fae_button.position,
	luc_button: luc_button.position,
	fer_button: fer_button.position,
}
@onready var _button_types: Dictionary[BaseButton, Demon] = {
	inf_button: Demon.INFERNAL,
	cel_button: Demon.CELESTIAL,
	car_button: Demon.CARNAL,
	spe_button: Demon.SPECTRAL,
	aby_button: Demon.ABYSSAL,
	fae_button: Demon.FAEIC,
	luc_button: Demon.LUCIFERIAN,
	fer_button: Demon.FERRIC,
}

var _selected_buttons: Array[BaseButton] = []

@onready var noise = FastNoiseLite.new()
@export var noise_speed := 0.1
@export var amplitude: float = 20

var _noise_y := 0.0
var _last_combined_type_id := 0

func update_name() -> void:
	_last_combined_type_id = 0
	for button in _selected_buttons:
		_last_combined_type_id |= _button_types[button]
	var next_name = DEMON_NAMES_LU.get(_last_combined_type_id, "")
	var t1 := create_tween()
	t1.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel()
	t1.tween_property(name_label, "offset_transform_scale", Vector2.ONE*0.5, 0.1)
	t1.tween_property(name_label, "modulate:a", 0.0, 0.1)
	await t1.finished
	
	name_label.text = next_name
	var t2 := create_tween()
	t2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
	t2.tween_property(name_label, "offset_transform_scale", Vector2.ONE, 0.3)
	t2.tween_property(name_label, "modulate:a", 1.0, 0.6)
	
	name_button.pressed.connect(Bus.name_selected.emit.bind(_last_combined_type_id))

func _ready() -> void:
	update_name()
	for button: TextureButton in _start_positions.keys():
		button.mouse_entered.connect(_button_hover.bind(button, true))
		button.mouse_exited.connect(_button_hover.bind(button, false))
		button.pressed.connect(func() -> void:
			if button.button_pressed:
				_selected_buttons.push_back(button)
				if _selected_buttons.size() > 2:
					var old_button: BaseButton = _selected_buttons.pop_front()
					old_button.button_pressed = false
					_button_hover(old_button, false)
					_button_colour(old_button)
				
				AudioManager.oneshot(ID.SFX.NAME_SELECT)
			else:
				_selected_buttons.erase(button)
			update_name()
			var t := create_tween()
			t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			t.tween_property(button.get_node(^"Label"), "theme_override_colors/font_color", (Color.CRIMSON if button.button_pressed else Color.BLACK ), 0.2)
		)
		
		
func _button_colour(button: BaseButton) -> void:
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(button.get_node(^"Label"), "theme_override_colors/font_color", (Color.CRIMSON if button.button_pressed else Color.BLACK ), 0.2)


func _button_hover(button: BaseButton, is_hover: bool) -> void:
	is_hover = is_hover or button.button_pressed
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(button, "offset_transform_scale", Vector2.ONE*(1.0 if is_hover else 0.8), 0.1)
	if is_hover:
		AudioManager.oneshot(ID.SFX.NAME_HOVER)


func _process(delta: float) -> void:
	name_label.position = 100.0 * delta * Vector2(randf_range(-1, 1), randf_range(-1, 1))
	_noise_y += noise_speed
	_shake()


func _shake():
	for button: TextureButton in _start_positions.keys():
		button.position.x = _start_positions[button].x + amplitude * noise.get_noise_2d(_start_positions[button].x, _noise_y)
		button.position.y = _start_positions[button].y + amplitude * noise.get_noise_2d(_start_positions[button].y ,_noise_y)
