class_name EntityManager
extends Node2D


func _ready() -> void:
	GameControl.entities = self


func add_entity(entity: Node2D):
	$Objects.add_child(entity)


func remove_all() -> void:
	for child in $Objects.get_children():
		if child.is_in_group("player"): continue
		child.queue_free()
