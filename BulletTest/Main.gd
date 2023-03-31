extends Node2D


@onready var _camera = $MainCamera

@onready var _player = $MainLayer/Player
@onready var _main_layer = $MainLayer
@onready var _shot_layer = $ShotLayer
@onready var _bullet_layer = $BulletLayer
@onready var _particle_layer = $ParticleLayer
@onready var _hdr = $WorldEnvironment

func _ready() -> void:
	var layers = {
		"main": _main_layer,
		"shot": _shot_layer,
		"bullet" : _bullet_layer,
		"particle": _particle_layer,
	}
	Common.setup(layers, _player)

func _process(delta: float) -> void:
	pass
