extends Control


func _ready() -> void:
	if has_node("BackButton"):
		$BackButton.pressed.connect(Bus.book_back.emit)
	if has_node("NextButton"):
		$NextButton.pressed.connect(Bus.book_next.emit)
