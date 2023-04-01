extends Node2D


@onready var _camera = $MainCamera

@onready var _player = $MainLayer/Player
@onready var _main_layer = $MainLayer

@onready var _shot_layer = $ShotLayer
@onready var _bullet_layer = $BulletLayer
@onready var _particle_layer = $ParticleLayer
## UI
@onready var _checkbox_destroy = $UILayer/CheckBoxDestroy
@onready var _checkbox_absorb = $UILayer/CheckBoxAbsorb
@onready var _checkbox_reflect = $UILayer/CheckBoxReflect
@onready var _checkbox_buzz = $UILayer/CheckBoxBuzz

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1024*2, 600*2))
	
	var layers = {
		"main": _main_layer,
		"shot": _shot_layer,
		"bullet" : _bullet_layer,
		"particle": _particle_layer,
	}
	Common.setup(layers, _player)

func _process(delta: float) -> void:
	_update_ui()

func _update_ui() -> void:
	Common.is_destroy = _checkbox_destroy.button_pressed
	Common.is_absorb = _checkbox_absorb.button_pressed
	Common.is_reflect = _checkbox_reflect.button_pressed
	Common.is_buzz = _checkbox_buzz.button_pressed
