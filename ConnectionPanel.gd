extends PanelContainer

signal host_game
signal join_game

var player_name = ""
var address = ""

func _ready():
	$VBoxContainer/HBoxContainer/HostButton.connect("pressed", self, "_on_host")
	$VBoxContainer/HBoxContainer2/JoinButton.connect("pressed", self, "_on_join")
	$VBoxContainer/HBoxContainer/Name.connect("text_changed", self, "_on_name_change")
	$VBoxContainer/HBoxContainer2/Address.connect("text_changed", self, "_on_address_change")
	_enable_buttons()

func _enable_buttons():
	$VBoxContainer/HBoxContainer/HostButton.disabled = len(player_name) == 0
	$VBoxContainer/HBoxContainer2/JoinButton.disabled = len(player_name) == 0 or len(address) == 0

func _on_name_change(new_name):
	player_name = new_name.strip_edges()
	_enable_buttons()

func _on_address_change(new_address):
	address = new_address.strip_edges()
	_enable_buttons()

func _on_host():
	emit_signal("host_game", player_name)

func _on_join():
	emit_signal("join_game", player_name, address)