## Gestor global de estados dinámicos de objetos.
##
## Este script permite almacenar, modificar y consultar propiedades
## arbitrarias asociadas a objetos del juego, usando su `instance_id()`
## como clave única.
##
## Se puede usar para registrar información temporal o persistente
## sobre entidades (por ejemplo: enemigos activados, interruptores usados,
## progreso de nivel, etc.).
##
## Ejemplo:
## ```
## var id = enemy.get_instance_id()
## ObjectState.add_property(id, "is_alerted", true)
##
## if ObjectState.get_property(id, "is_alerted"):
##     enemy.shoot_player()
## ```

extends Node

## Diccionario principal que almacena los estados.
## Estructura: { object_id: { "propiedad": valor, ... }, ... }
var _states: Dictionary = {}


## Verifica si existe un registro de estado para un objeto dado.
##
## @param key ID de instancia del objeto (`get_instance_id()`).
## @return `true` si el objeto tiene estados registrados.
func is_set(key: int) -> bool:
	return _states.get(key) != null


## Asegura que exista una entrada en `_states` para el objeto especificado.
##
## Si el objeto no existe, se inicializa un diccionario vacío para él.
func _check_object(key: int) -> void:
	if _states.get(key) == null:
		_states[key] = {}


## Agrega una nueva propiedad para un objeto.
##
## Si la propiedad ya existe, será reemplazada.
##
## @param obj_id ID de instancia del objeto (`get_instance_id()`).
## @param key Nombre de la propiedad a registrar.
## @param value Valor asociado a la propiedad.
func add_property(obj_id: int, key: String, value) -> void:
	_check_object(obj_id)
	_states[obj_id][key] = value


## Modifica (o crea) una propiedad existente en el objeto especificado.
##
## Funcionalmente igual a `add_property()`, pero más semántico
## para casos donde se quiere sobrescribir valores existentes.
func set_property(obj_id: int, key: String, value) -> void:
	_check_object(obj_id)
	_states[obj_id][key] = value


## Obtiene el valor de una propiedad asociada a un objeto.
##
## @param obj_id ID de instancia del objeto (`get_instance_id()`).
## @param key Nombre de la propiedad a consultar.
## @return Valor almacenado, o `null` si no existe.
func get_property(obj_id: int, key: String):
	var obj = _states.get(obj_id)
	if obj != null:
		return obj.get(key)
	else:
		return null


## Imprime en consola todos los estados almacenados,
## mostrando el nombre de la instancia (si aún existe)
## y sus propiedades asociadas.
##
## Ejemplo de salida:
## ```
## Enemy: { "is_alerted": true, "health": 50 }
## Crate: { "opened": true }
## ```
func print_state() -> void:
	for item in _states:
		var node = instance_from_id(item)
		if node != null:
			print(node.name, ": ", _states[item])
		else:
			print("[Objeto eliminado] ID:", item, ": ", _states[item])
