class_name GUI extends Control


var _current_demon: Dictionary

@onready var menu_button: BaseButton = %MenuButton
@onready var table_button: BaseButton = %TableButton
@onready var book_open_button: BaseButton = %BookOpenButton
@onready var book_close_button: BaseButton = %BookCloseButton
@onready var title_button: BaseButton = $TitleButton

@onready var reset_button: Button = %ResetButton
@onready var check_button: Button = %CheckButton
@onready var label: Label = %Label

@onready var salt_button: BaseButton = %SaltButton
@onready var prayer_button: BaseButton = %PrayerButton
@onready var iron_button: BaseButton = %IronButton
@onready var water_button: BaseButton = %WaterButton

@onready var black_screen: ColorRect = %EndScreen
@onready var reload_button: Button = %Reload
@onready var end_message: Label = %EndMessage

func _ready() -> void:
	_current_demon = DemonManager.get_random_demon()
	reset_button.pressed.connect(_reset_demon)
	
	title_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.TABLE))
	table_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.TABLE))
	menu_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.SHELF))
	book_open_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.BOOK))
	book_close_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.TABLE))
	
	salt_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.SALT))
	prayer_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.PRAYER))
	iron_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.IRON))
	water_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.HOLY_WATER))
	
	reload_button.pressed.connect(_reload_level)


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
		-2: label.text = "The demon is\n extremely empowered"
		-1: label.text = "The demon is\n empowered"
		0: label.text = "The demon is\n uneffected"
		3: label.text = "The demon is\n strangely uneffected"
		1: label.text = "The demon is\n weakened"
		2: label.text = "The demon is\nxtremely weakened"

func _show_end_screen(did_win: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	black_screen.show()
	end_message.text = "YOU WIN" if did_win else "YOU LOST"
	reload_button.text = "GO AGAIN" if did_win else "TRY AGAIN"
	var t = get_tree().create_tween()
	t.tween_callback(%EndMessage.show.bind()).set_delay(1.0)
	t.tween_callback(%Reload.show.bind()).set_delay(1.0)

func _reload_level():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	get_tree().reload_current_scene()
