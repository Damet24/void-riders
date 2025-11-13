extends AnimatedSprite2D


@export var sound: AudioStreamPlayer


func _ready() -> void:
	if sound:
		sound.finished.connect(queue_free)
		sound.play()
	else:
		animation_finished.connect(queue_free)
	create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_CUBIC)
