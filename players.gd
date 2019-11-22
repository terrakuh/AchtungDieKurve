extends Node2D

signal player_added(player, color)
signal round_ended()

const MIN_PLAYER_DISTANCE = 50

# maps names to ids
var _names = {}
# id: name
var _alive = {}

func get_player_count():
	return len(_names)

sync func s_create_player(id, name, color=null):
	print("creating player", id, name)
	var player = preload("res://Player.tscn").instance()
	var history = preload("res://History.tscn").instance()
	var child = Node.new()
	child.name = str(id)
	child.add_child(history)
	child.add_child(player)
	player.position = Vector2(40, 40)
	add_child(child)
	child.set_network_master(id)
	
	# init history and player
	player.init(name)
	history.init(player)
	if color:
		history.color = color
	_names[name] = str(id)
	history.connect("body_entered", self, "t")
	score.rpc("s_set_score", name, 0)
	emit_signal("player_added", player, color)
func t(body):
	print(body)
func synchronize_with(id):
	for child in get_children():
		rpc_id(id, "s_create_player", int(child.name), child.get_node("player").player_name, child.get_node("history").color)

sync func s_set_player_color(name, color):
	get_node(_names[name]).get_node("history").color = color

puppet func p_clean_histories():
	for child in get_children():
		child.get_node("history").reset()
	gamestate.rpc("m_history_cleaned")

func reset_round():
	assert(get_tree().is_network_server())
	
	rpc("p_clean_histories")
	_alive.clear()
	
	# new positions
	var positions = []
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	
	for i in range(get_child_count()):
		while true:
			var x = rnd.randf_range(MIN_PLAYER_DISTANCE, gamestate.game_size.x - MIN_PLAYER_DISTANCE)
			var y = rnd.randf_range(MIN_PLAYER_DISTANCE, gamestate.game_size.y - MIN_PLAYER_DISTANCE)
			var found = false
			for j in positions:
				if (x >= j.x and x <= j.x + MIN_PLAYER_DISTANCE) or (y >= j.y and y <= j.y + MIN_PLAYER_DISTANCE):
					found = true
					break
			if not found:
				positions.append(Vector2(x, y))
				break
		var player = get_child(i).get_node("player")
		player.rpc("s_reset", positions[i], rnd.randf_range(0, 2 * PI))
		_alive[get_child(i).name] = player.player_name
	
	powerups.start_round()

master func m_kill_player(name):
	if _alive.erase(_names[name]):
		get_node(_names[name]).get_node("player").rpc("s_die")
		
		# increment score of all other players
		for alive in _alive:
			score.rpc("s_increment_score", _alive[alive])
		if len(_alive) <= 1:
			emit_signal("round_ended")

func get_alive_players():
	var p = []
	for i in _alive:
		p.append(get_node(i).get_node("player"))
	return p