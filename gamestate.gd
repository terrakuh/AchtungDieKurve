extends Node2D

const DEFAULT_PORT = 80
const MAX_PLAYERS = 8
const HIGHSCORE = 20
const DEFAULT_THICKNESS = 4
const SPEED = 75
var ANGLE = deg2rad(2)

signal size_changed(screen_size, game_size)

var screen_size = Vector2(1200, 600) setget set_screen_size,get_screen_size
var game_size = Vector2(1000, 600) setget ,get_game_size
var _round_ended = false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	players.connect("round_ended", self, "trigger_round_end")

func set_screen_size(size):
	screen_size = size
	game_size = Vector2(size.x - 200, size.y)
	
	emit_signal("size_changed", screen_size, game_size)

func get_screen_size():
	return screen_size

func get_game_size():
	return game_size

sync func s_pause(p):
	get_tree().paused = p

func _input(event):
	if get_tree().has_network_peer() and get_tree().is_network_server():
		if event.is_action_released("main_action"):
			if _round_ended:
				players.reset_round()
				rpc("s_pause", false)
				_round_ended = false

func body_hit_wall(body, new_pos):
	# kill player
	players.rpc("m_kill_player", body.player_name)

sync func s_display_winner(name):
	var alert = AcceptDialog.new()
	add_child(alert)
	alert.dialog_text = "%s won the game" % name
	alert.popup()

func trigger_round_end():
	assert(get_tree().is_network_server())
	print("round ended")
	
	rpc("s_pause", true)
	_round_ended = true
	var highscore = score.get_highscore()
	if highscore[1] >= HIGHSCORE:
		rpc("s_display_winner", highscore[0])