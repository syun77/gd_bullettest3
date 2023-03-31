extends Area2D

onready var _spr = $Sprite
onready var _line = $Line2D

var _velocity = Vector2()

var _spr_list = []

func vanish() -> void:
	if Common.is_particle() == false:
		# パーティクルなし.
		queue_free()
		return
	
	# 逆方向にパーティクルを発生させる.
	var v = _velocity * -1
	var spd = v.length()
	for i in range(4):
		var rad = atan2(-v.y, v.x)
		var deg = rad2deg(rad)
		deg += rand_range(-30, 30)
		var speed = spd * rand_range(0.1, 0.5)
		Common.add_particle(position, 1.0, deg, speed)
	queue_free()

func _ready() -> void:
	if Common.is_change_spr():
		# ショット画像差し替え.
		_spr.texture = load("res://shot2.png")
	
	for i in range(8):
		var rate = 1.0 - ((i+1) / 8.0)
		var spr:Sprite = get_node("./Sprite%d"%i)
		spr.texture = _spr.texture
		if Common.is_trail():
			spr.scale.x = rate
			spr.scale.y = rate
		spr.modulate.a = rate
		_spr_list.append(spr)
		

func set_velocity(deg:float, speed:float) -> void:
	var rad = deg2rad(deg)
	_velocity.x = cos(rad) * speed
	_velocity.y = -sin(rad) * speed

func _physics_process(delta: float) -> void:
	delta *= Common.get_hitslow_rate()
	
	var d = _velocity * delta
	position += d
	
	# 残像の更新.
	# positionに追従してしまうので逆オフセットが必要となる.
	for spr in _spr_list:
		spr.position -= d # すべてのLine2Dの位置を移動量で逆オフセットする.
		spr.visible = Common.is_blur()
	_spr_list[0].position = Vector2.ZERO # 先頭は0でよい.
	_update_blur()
	
	# 画面外に出たら消す.
	if position.x < 0 or position.y < 0:
		queue_free()
	if position.x > 1024 or position.y > 600:
		queue_free()

## 残像の更新.
func _update_blur() -> void:
	for i in range(_spr_list.size()-1):
		var a = _spr_list[i].position
		var b = _spr_list[i+1].position
		# 0.7の重みで線形補間します
		_spr_list[i+1].position = b.linear_interpolate(a, 0.7)

func _on_Shot_area_entered(area: Area2D) -> void:
	# 何かに衝突したら消える.
	vanish()
	
	if area is Enemy:
		# 敵だったらヒット処理.
		area.hit(_velocity)
