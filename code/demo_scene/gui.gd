extends Control


var _current_demon: Dictionary

@onready var water_button: Button = %WaterButton
@onready var salt_button: Button = %SaltButton
@onready var iron_button: Button = %IronButton
@onready var prayer_button: Button = %PrayerButton
@onready var reset_button: Button = %ResetButton
@onready var check_button: Button = %CheckButton
@onready var label: Label = %Label


func _ready() -> void:
	_current_demon = DemonManager.get_random_demon()
	reset_button.pressed.connect(_reset_demon)
	check_button.pressed.connect(_print_demon)

	water_button.pressed.connect(_test_item.bind(ID.Item.HOLY_WATER))
	salt_button.pressed.connect(_test_item.bind(ID.Item.SALT))
	iron_button.pressed.connect(_test_item.bind(ID.Item.IRON))
	prayer_button.pressed.connect(_test_item.bind(ID.Item.PRAYER))


func _reset_demon() -> void:
	_current_demon = DemonManager.get_random_demon()
	label.text = ""


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
		-2: label.text = "The demon is\nEmpowered"
		-1: label.text = "The demon is\nUneffected"
		0: label.text = "The demon is\nMildly effected"
		1: label.text = "The demon is\nStrongly effected"
		2: label.text = "The demon is\nExtremely effected"
