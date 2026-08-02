extends Node

@warning_ignore_start("unused_signal")

signal book_back
signal book_next

signal name_selected(combined_type_id: int, name: String)

signal set_view(view_id: ID.CameraMode)
signal use_item(item_id: ID.Item)

signal hover_item(item_id: ID.Item, is_hover: bool)
signal hover_view(view_id: ID.CameraMode, is_hover: bool)
