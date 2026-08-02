extends OmniLight3D
class_name Candle

#@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var particle_spawner: CPUParticles3D = $CPUParticles3D

@export_range(0.0, 1.0) var flickerAdvance : float
@export var lit_range: float = 1.0
var is_on := false
var next_light_energy: float
var next_omni_range: float

func _ready() -> void:
	omni_range = 1
	pass


func _process(delta: float) -> void:

	if Engine.get_process_frames() % 5 == 0:
		next_light_energy += randfn(1.5, 1.) * delta
		next_light_energy += (0.1-next_light_energy) * 0.1
		next_omni_range +=  randfn(0.8, 0.8) * delta
		next_omni_range += (0.8-next_omni_range) * 0.1
		
	light_energy = lerpf(light_energy, next_light_energy, 0.1)
	omni_range = lerpf(omni_range, next_omni_range, 0.1)

func turn_off(is_silent := false):
	if not is_silent:
		AudioManager.oneshot(ID.SFX.CANDLE_EXTINGUISH)
	#animationPlayer.pause()
	set_process(false)
	light_energy = 0
	omni_range = 0
	particle_spawner.emitting = false
	is_on = false

func turn_on(is_silent := false):
	if not is_silent:
		AudioManager.oneshot(ID.SFX.CANDLE_IGNIGHT)
	#animationPlayer.advance(flickerAdvance)
	#animationPlayer.play("flicker")
	set_process(true)
	light_energy = 1.0#lit_range
	omni_range = 2.0#lit_range
	particle_spawner.emitting = true
	is_on = true
