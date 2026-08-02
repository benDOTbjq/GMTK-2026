extends Node3D


@export var item_type: ID.Item

var _rest_y: float
var _hover_y: float

func _ready() -> void:
	Bus.hover_item.connect(_on_hover)
	_rest_y = global_position.y
	_hover_y = _rest_y + 0.03

func _on_hover(item_id: ID.Item, is_hover: bool) -> void:
	if item_type != item_id:
		return
	var t := create_tween()
	t.set_trans(Tween.TRANS_QUAD if is_hover else Tween.TRANS_BOUNCE)
	t.set_ease(Tween.EASE_IN_OUT if is_hover else Tween.EASE_OUT)
	t.tween_property(self, "global_position:y", (_hover_y if is_hover else _rest_y), 0.2)
