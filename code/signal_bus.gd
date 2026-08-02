extends Node

@warning_ignore_start("unused_signal")

signal book_back
signal book_next

signal demon_active(is_demon_active: bool)
signal name_selected(combined_type_id: int, name: String)

signal set_view(view_id: ID.CameraMode)
signal use_item(item_id: ID.Item)
signal show_dialog(dialog: String, is_voiced: bool)

signal hover_item(item_id: ID.Item, is_hover: bool)
signal hover_view(view_id: ID.CameraMode, is_hover: bool)
