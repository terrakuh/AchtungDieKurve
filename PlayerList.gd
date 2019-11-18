extends PanelContainer

signal player_ready(name, color)
signal game_started()

var _player_name

func _ready():
	$HBoxContainer/VBoxContainer/ReadyButton.connect("pressed", self, "_on_pressed")

func _on_game_start():
	emit_signal("game_started")

func _on_pressed():
	$HBoxContainer/VBoxContainer/ReadyButton.disabled = true
	rpc("s_ready_player", _player_name, $HBoxContainer/ColorPicker.color)

func init(player_name):
	_player_name = player_name
	
	# add start button if this is the server
	if is_network_master():
		$HBoxContainer/VBoxContainer/StartButton.show()
		$HBoxContainer/VBoxContainer/StartButton.connect("pressed", self, "_on_game_start")

func join_player(name):
	$HBoxContainer/VBoxContainer/JoinedList.add_item(name)
	$HBoxContainer/VBoxContainer/StartButton.disabled = $HBoxContainer/VBoxContainer/JoinedList.get_item_count() != 0

sync func s_ready_player(name, color):
	# remove player from joined list
	for i in range($HBoxContainer/VBoxContainer/JoinedList.get_item_count()):
		if $HBoxContainer/VBoxContainer/JoinedList.get_item_text(i) == name:
			$HBoxContainer/VBoxContainer/JoinedList.remove_item(i)
			break
	
	$HBoxContainer/VBoxContainer/StartButton.disabled = $HBoxContainer/VBoxContainer/JoinedList.get_item_count() != 0
	
	# create player color icon
	var image = Image.new()
	image.create(16, 16, false, Image.FORMAT_RGB8)
	image.fill(color)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	# add player to ready list
	$HBoxContainer/VBoxContainer/ReadyList.add_item(name, texture)
	emit_signal("player_ready", name, color)