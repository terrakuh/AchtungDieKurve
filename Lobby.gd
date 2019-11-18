extends Control

var _player_name

func _ready():
	get_tree().paused = true
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().connect("network_peer_connected", players, "synchronize_with")
	get_tree().connect("connected_to_server", self, "_say_player_hello")
	players.connect("player_added", self, "_on_player_added")
	$ConnectionPanel.connect("host_game", self, "_on_host")
	$ConnectionPanel.connect("join_game", self, "_on_join")
	$PlayerList.connect("game_started", self, "_on_game_start")
	$PlayerList.connect("player_ready", players, "s_set_player_color")

func _on_game_start():
	print("starting round")
	players.reset_round()
	rpc("s_start_game")

sync func s_start_game():
	hide()
	get_tree().paused = false

func _on_player_added(player, color):
	if color:
		$PlayerList.s_ready_player(player.player_name, color)
	else:
		$PlayerList.join_player(player.player_name)

func _say_player_hello():
	var id = get_tree().get_network_unique_id()
	players.rpc("s_create_player", id, _player_name)

func _on_network_success(player_name):
	_player_name = player_name
	$ConnectionPanel.hide()
	$PlayerList.init(player_name)
	$PlayerList.show()

func _on_host(player_name):
	var network = NetworkedMultiplayerENet.new()
	var err = network.create_server(gamestate.DEFAULT_PORT, gamestate.MAX_PLAYERS)
	
	if err:
		$ErrorDialog.dialog_text = "Failed with: " + str(err)
		$ErrorDialog.popup()
		return
	
	get_tree().network_peer = network
	_on_network_success(player_name)
	_say_player_hello()

func _on_join(player_name, address):
	var network = NetworkedMultiplayerENet.new()
	var err = network.create_client(address, gamestate.DEFAULT_PORT)
	
	if err:
		$ErrorDialog.dialog_text = "Failed with: %s" % str(err)
		$ErrorDialog.popup()
		return
	
	get_tree().network_peer = network
	_on_network_success(player_name)






