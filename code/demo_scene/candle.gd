extends OmniLight3D
class_name Candle

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var particle_spawner: CPUParticles3D = $CPUParticles3D

@export_range(0.0, 1.0) var flickerAdvance : float
@export var lit_range: float = 0.5
var is_on := false

func _ready() -> void:
	pass

func turn_off():
	AudioManager.oneshot(ID.SFX.CANDLE_EXTINGUISH)
	animationPlayer.pause()
	omni_range = 0
	particle_spawner.emitting = false
	is_on = false

func turn_on():
	is_on = true
	AudioManager.oneshot(ID.SFX.CANDLE_IGNIGHT)
	animationPlayer.advance(flickerAdvance)
	animationPlayer.play("flicker")
	omni_range = lit_range
	particle_spawner.emitting = true
