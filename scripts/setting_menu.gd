extends Control

@onready var fullscreen_check: CheckBox = $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FullscreenCheck
@onready var master_volume: HSlider = $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer2/MasterVolume
@onready var music_volume: HSlider = $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer3/MusicVolume
@onready var sfx_volume: HSlider = $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer4/SfxVolume
@onready var back: Button = $PanelContainer/MarginContainer/VBoxContainer2/Back

func _ready() -> void:
	# Cargar los valores actuales desde el sistema de configuración
	var master_value = Settings.get_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.MASTER_VOLUME, 1.0)
	var music_value = Settings.get_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.MUSIC_VOLUME, 1.0)
	var sfx_value = Settings.get_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.SFX_VOLUME, 1.0)
	var fullscreen_value = Settings.get_setting(Settings.SECTION.DISPLAY, Settings.DISPLAY_KEYS.FULLSCREEN, true)

	# Asignar valores iniciales a los controles
	master_volume.value = master_value
	music_volume.value = music_value
	sfx_volume.value = sfx_value
	fullscreen_check.button_pressed = fullscreen_value

	# Conectar eventos de los controles
	master_volume.value_changed.connect(_on_master_volume_changed)
	music_volume.value_changed.connect(_on_music_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back.pressed.connect(_on_back_pressed)


func _on_master_volume_changed(value: float) -> void:
	Settings.save_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.MASTER_VOLUME, value)

func _on_music_volume_changed(value: float) -> void:
	Settings.save_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.MUSIC_VOLUME, value)

func _on_sfx_volume_changed(value: float) -> void:
	Settings.save_setting(Settings.SECTION.AUDIO, Settings.AUDIO_KEYS.SFX_VOLUME, value)

func _on_fullscreen_toggled(pressed: bool) -> void:
	Settings.save_setting(Settings.SECTION.DISPLAY, Settings.DISPLAY_KEYS.FULLSCREEN, pressed)

func _on_back_pressed():
	GameControl.interface.back()
