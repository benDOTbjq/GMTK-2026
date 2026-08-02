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
@onready var reload_button_try_play: Label = %TryPlay
@onready var end_message: Control = %EndMessage
@onready var end_message_label_2: Label = %EndMessageLabel2
@onready var letterbox: Control = %Letterbox

@onready var dialog_box: AnimatedSprite2D = %DialogBox
@onready var bubble_text: Label = %BubbleText


func set_letterbox(is_letterbox: bool) -> void:
	letterbox.mouse_filter =Control.MOUSE_FILTER_STOP if is_letterbox else Control.MOUSE_FILTER_IGNORE
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT if is_letterbox else Tween.EASE_IN)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(letterbox, "offset_transform_scale", Vector2.ONE * (1.0 if is_letterbox else 1.16), 0.2)


func _ready() -> void:
	_current_demon = DemonManager.get_random_demon()
	reset_button.pressed.connect(_reset_demon)
	
	title_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.TABLE))
	table_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.TABLE))
	table_button.mouse_entered.connect(Bus.hover_view.emit.bind(ID.CameraMode.TABLE, true))
	table_button.mouse_exited.connect(Bus.hover_view.emit.bind(ID.CameraMode.TABLE, false))
	menu_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.SHELF))
	menu_button.mouse_entered.connect(Bus.hover_view.emit.bind(ID.CameraMode.SHELF, true))
	menu_button.mouse_exited.connect(Bus.hover_view.emit.bind(ID.CameraMode.SHELF, false))
	book_open_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.BOOK))
	book_open_button.mouse_entered.connect(Bus.hover_view.emit.bind(ID.CameraMode.BOOK, true))
	book_open_button.mouse_exited.connect(Bus.hover_view.emit.bind(ID.CameraMode.BOOK, false))
	book_close_button.pressed.connect(Bus.set_view.emit.bind(ID.CameraMode.TABLE))
	book_close_button.mouse_entered.connect(Bus.hover_view.emit.bind(ID.CameraMode.TABLE, true))
	book_close_button.mouse_exited.connect(Bus.hover_view.emit.bind(ID.CameraMode.TABLE, false))
	
	salt_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.SALT))
	salt_button.mouse_entered.connect(Bus.hover_item.emit.bind(ID.Item.SALT, true))
	salt_button.mouse_exited.connect(Bus.hover_item.emit.bind(ID.Item.SALT, false))
	prayer_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.PRAYER))
	prayer_button.mouse_entered.connect(Bus.hover_item.emit.bind(ID.Item.PRAYER, true))
	prayer_button.mouse_exited.connect(Bus.hover_item.emit.bind(ID.Item.PRAYER, false))
	iron_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.IRON))
	iron_button.mouse_entered.connect(Bus.hover_item.emit.bind(ID.Item.IRON, true))
	iron_button.mouse_exited.connect(Bus.hover_item.emit.bind(ID.Item.IRON, false))
	water_button.pressed.connect(Bus.use_item.emit.bind(ID.Item.HOLY_WATER))
	water_button.mouse_entered.connect(Bus.hover_item.emit.bind(ID.Item.HOLY_WATER, true))
	water_button.mouse_exited.connect(Bus.hover_item.emit.bind(ID.Item.HOLY_WATER, false))
	
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
	AudioManager.loop(ID.SFXLoop.PENAGRAM, false)
	black_screen.show()
	end_message_label_2.text = "WIN" if did_win else "DIED"
	reload_button_try_play.text = "PLAY" if did_win else "TRY"
	var t = get_tree().create_tween()
	t.tween_callback(%EndMessage.show.bind()).set_delay(1.0)
	if did_win:
		t.tween_callback(%ThankYou.show.bind()).set_delay(1.0)
	t.tween_callback(%Reload.show.bind()).set_delay(1.0)

func _reload_level():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	get_tree().reload_current_scene()
	
