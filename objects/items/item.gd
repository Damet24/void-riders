class_name Item
extends Area2D


@export var audio: AudioStreamPlayer
@export var timer: Timer


func _ready() -> void:
	body_entered.connect(callback)
	timer.timeout.connect(destroy)
	timer.start()


func destroy():
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished.connect(queue_free)


func action():
	print("native action")


func callback(_body: Node2D):
	action()
	if audio:
		audio.play()
		await audio.finished
		queue_free()
	else:
		queue_free()