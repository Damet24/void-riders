class_name CameraControl
extends Camera2D


enum SHAKE {
	SOFT,
	MEDIUM,
	HARD
}


@export var soft_shake: float = 1.0
@export var medium_shake: float = 5.0
@export var hard_shake: float = 10.0
@export var shake_fade: float = 5.0
var _shake_stength: float = 0.0


func _ready() -> void:
	GameControl.camera = self
	trigger_shake()


func _get_intensity(type: SHAKE) -> float:
	match type:
		SHAKE.SOFT:
			return soft_shake
		SHAKE.MEDIUM:
			return medium_shake
		SHAKE.HARD:
			return hard_shake
		_:
			return 0.0


func trigger_shake(type: SHAKE = SHAKE.MEDIUM) -> void:
	_shake_stength = _get_intensity(type)

func _process(delta: float) -> void:
	if _shake_stength > 0:
		_shake_stength = lerp(_shake_stength, 0.0, shake_fade * delta)
		offset = Vector2(randf_range(-_shake_stength, _shake_stength), randf_range(-_shake_stength, _shake_stength))
