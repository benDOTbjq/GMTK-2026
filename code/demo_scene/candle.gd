extends OmniLight3D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@export_range(0.0, 1.0) var flickerAdvance : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#animationPlayer.advance(randf_range(0.0, 1.0))
	animationPlayer.advance(flickerAdvance)
