extends Enemy


func _ready():
	super._ready()
	var direction := (GameControl.player_instance.global_position - global_position).normalized()
	rotation = direction.angle()

	velocity = direction * speed
