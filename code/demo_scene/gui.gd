class_name GUI extends Control


var _current_demon: Dictionary

@onready var menu_button: TextureButton = %MenuButton
@onready var table_button: TextureButton = %TableButton
@onready var book_button: TextureButton = %BookButton
@onready var book_prev_button: TextureButton = %BookPrevButton
@onready var book_next_button: TextureButton = %BookNextButton
@onready var title_button: TextureButton = $TitleButton

@onready var reset_button: Button = %ResetButton
@onready var check_button: Button = %CheckButton
@onready var label: Label = %Label


func _ready() -> void:
	_current_demon = DemonManager.get_random_demon()
	reset_button.pressed.connect(_reset_demon)
	check_button.pressed.connect(_test_demon)


func _reset_demon() -> void:
	_current_demon = DemonManager.get_random_demon()
	label.text = ""

func _test_demon() -> void:
	($"../" as Level).guess_demon(ID.DemonType.LUCIFERIAN, ID.DemonType.NONE)

func _print_demon() -> void:
	label.text = (
		DemonManager.TYPE_TO_STRING[_current_demon.type_1] + 
		", " +
		DemonManager.TYPE_TO_STRING[_current_demon.type_2] +
		"\n" +
		str(_current_demon.item_effectiveness)
	)
	print(DemonManager.TYPE_TO_STRING[_current_demon.type_1], ", ", DemonManager.TYPE_TO_STRING[_current_demon.type_2])
	print(_current_demon.item_effectiveness)


func _test_item(item_id: ID.Item) -> void:
	print(_current_demon.item_effectiveness[item_id])
	match _current_demon.item_effectiveness[item_id]:
		-2: label.text = "The demon is\n extremely empowered"
		-1: label.text = "The demon is\n empowered"
		0: label.text = "The demon is\n uneffected"
		3: label.text = "The demon is\n strangely uneffected"
		1: label.text = "The demon is\n weakened"
		2: label.text = "The demon is\nxtremely weakened"
		
