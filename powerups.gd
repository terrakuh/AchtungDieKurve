extends Node

const INTERVAL = 10
var _rng = RandomNumberGenerator.new()

func _ready():
	var timer = Timer.new()
	timer.wait_time = INTERVAL
	timer.name = "timer"
	timer.connect("timeout", self, "_timeout")
	add_child(timer)
	_rng.randomize()

sync func _s_add_powerup(position, type, action):
	var powerup = preload("res://power_ups/PowerUp.tscn").instance()
	powerup.position = position
	add_child(powerup)
	powerup.init(type, action)

func _timeout():
	var x = _rng.randf_range(50, gamestate.game_size.x - 50)
	var y = _rng.randf_range(50, gamestate.game_size.y - 50)
	rpc("_s_add_powerup", Vector2(x, y), _rng.randi_range(0, 2), _rng.randi_range(0, 0))

sync func _s_reset():
	for child in get_children():
		if child.name != "timer":
			child.queue_free()

func start_round():
	rpc("_s_reset")
	get_node("timer").start()
