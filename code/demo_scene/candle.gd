extends OmniLight3D
class_name Candle

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var particle_spawner: CPUParticles3D = $CPUParticles3D

@export_range(0.0, 1.0) var flickerAdvance : float
var original_range: float

func _ready() -> void:
	original_range = omni_range
	animationPlayer.advance(flickerAdvance)

func turn_off():
	animationPlayer.pause()
	omni_range = 0
	particle_spawner.emitting = false

func turn_on():
	animationPlayer.play("flicker")
	omni_range = original_range
	particle_spawner.emitting = true
