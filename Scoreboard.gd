extends PanelContainer

func _ready():
	score.connect("scores_changed", self, "_on_score_changed")

func _on_score_changed(new_scores):
	$VBoxContainer/ItemList.clear()
	
	for i in new_scores:
		$VBoxContainer/ItemList.add_item("%s: %d" % i)