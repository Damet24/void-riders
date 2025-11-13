## Sistema de configuraciones del juego
##
## Este script gestiona toda la configuración del juego, incluyendo
## la creación, carga y guardado de las preferencias del usuario.
##
## Funcionalidades principales:
## - Carga automática del archivo de configuración al iniciar el juego.
## - Generación de una configuración por defecto si no existe.
## - Lectura y escritura de valores en secciones (Display, Audio, Controls).
## - Emisión de señal `setting_changed` al modificar un valor.
## - Permite restaurar la configuración a valores por defecto.
##
## ```gdscript
## Settings.save_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.MUSIC_VOLUME, 0.8)
## var vol = Settings.get_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.MASTER_VOLUME)
## ```

extends Node

## Señal emitida cuando una configuración cambia.
## 
## @param section (String) - Sección del archivo modificada.
## @param key (String) - Clave dentro de la sección modificada.
## @param value (Variant) - Nuevo valor asignado.
signal setting_changed(section: String, key: String, value: Variant)

## Ruta del archivo donde se almacenan las configuraciones del usuario.
const SETTINGS_FILE_PATH := "user://settings.ini"

## Instancia del archivo de configuración cargado en memoria.
var config := ConfigFile.new()

## Secciones principales del archivo de configuración.
const SECTION := {
	DISPLAY = "Display",
	AUDIO = "Audio",
}

## Claves correspondientes a las opciones de pantalla.
const DISPLAY_KEYS := {
	FULLSCREEN = "Fullscreen",
}

## Claves correspondientes a las opciones de audio.
const AUDIO_KEYS := {
	MASTER_VOLUME = "MasterVolume",
	MUSIC_VOLUME = "MusicVolume",
	SFX_VOLUME = "SFXVolume"
}


## Inicializa el sistema de configuración del juego.
##
## Si el archivo de configuración no existe, se crea uno con valores por defecto.
## Si existe, se carga en memoria para su uso durante la sesión.
func _ready() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		_create_default_settings()
	else:
		config.load(SETTINGS_FILE_PATH)
	
	_apply_display_settings()
	_apply_audio_settings()
	setting_changed.connect(_sync_settings)

## Crea una configuración inicial con valores por defecto.
##
## Este método se ejecuta automáticamente si no se encuentra el archivo
## `settings.ini` en el directorio del usuario.
func _create_default_settings() -> void:
	#region DISPLAY
	config.set_value(SECTION.DISPLAY, DISPLAY_KEYS.FULLSCREEN, true)
	#endregion

	#region AUDIO
	config.set_value(SECTION.AUDIO, AUDIO_KEYS.MASTER_VOLUME, 1.0)
	config.set_value(SECTION.AUDIO, AUDIO_KEYS.MUSIC_VOLUME, 1.0)
	config.set_value(SECTION.AUDIO, AUDIO_KEYS.SFX_VOLUME, 1.0)
	#endregion

	config.save(SETTINGS_FILE_PATH)

## Guarda un valor en una sección específica del archivo de configuración.
##
## @param section (String) - Nombre de la sección (por ejemplo `SECTION.AUDIO`)
## @param key (String) - Clave dentro de la sección (por ejemplo `AUDIO_KEYS.MUSIC_VOLUME`)
## @param value (Variant) - Valor que se desea guardar
##
## 💡 También emite la señal `setting_changed` para notificar a otros nodos.
func save_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE_PATH)
	emit_signal("setting_changed", section, key, value)

## Obtiene el valor de una configuración almacenada.
##
## @param section (String) - Sección del archivo
## @param key (String) - Clave dentro de la sección
## @param default_value (Variant) - Valor por defecto si no existe la clave
##
## @return Variant - El valor almacenado, o `default_value` si no existe
func get_setting(section: String, key: String, default_value: Variant = null) -> Variant:
	return config.get_value(section, key, default_value)


func save_display_setting(key: String, value: Variant) -> void:
	save_setting(SECTION.DISPLAY, key, value)


func get_display_settings(key: String, default_value: Variant = null) -> Variant:
	return get_setting(SECTION.DISPLAY, key, default_value)


func save_audio_setting(key: String, value: Variant) -> void:
	save_setting(SECTION.AUDIO, key, value)


func get_audio_settings(key: String, default_value: Variant = null) -> Variant:
	return get_setting(SECTION.AUDIO, key, default_value)


## Restaura todas las configuraciones a sus valores por defecto.
##
## Borra el archivo actual y genera uno nuevo con la configuración inicial.
func reset_to_defaults() -> void:
	config = ConfigFile.new()
	_create_default_settings()
	setting_changed.emit(SECTION.DISPLAY, DISPLAY_KEYS.FULLSCREEN, get_setting(SECTION.DISPLAY, DISPLAY_KEYS.FULLSCREEN))
	_apply_display_settings()
	_apply_audio_settings()


func _apply_display_settings():
	var fullscreen = get_setting(SECTION.DISPLAY, DISPLAY_KEYS.FULLSCREEN, true)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func _apply_audio_settings():
	var master = get_setting(SECTION.AUDIO, AUDIO_KEYS.MASTER_VOLUME, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master ))

	var music = get_setting(SECTION.AUDIO, AUDIO_KEYS.MUSIC_VOLUME, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music))

	var sfx = get_setting(SECTION.AUDIO, AUDIO_KEYS.SFX_VOLUME, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx))


func _sync_settings(section: String, key: String, value: Variant) -> void:
	match section:
		SECTION.DISPLAY: _sync_display_settings(key, value)
		SECTION.AUDIO: _sync_audio_settings(key, value)

func _sync_display_settings(key: String, value: Variant) -> void:
	if key == DISPLAY_KEYS.FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)

func _sync_audio_settings(key: String, value: Variant) -> void:
	var bus_name := ""
	match key:
		AUDIO_KEYS.MASTER_VOLUME: bus_name = "Master"
		AUDIO_KEYS.MUSIC_VOLUME: bus_name = "Music"
		AUDIO_KEYS.SFX_VOLUME: bus_name = "SFX"
	if bus_name:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(value))
