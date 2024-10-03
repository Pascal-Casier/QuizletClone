extends Control

@onready var word : LineEdit = $bgd/MarginContainer/HBoxContainer2/LineEdit
@onready var traduction: LineEdit = $bgd/MarginContainer/HBoxContainer2/LineEdit2
@onready var deck_selector: OptionButton = $bgd/MarginContainer/HBoxContainer3/OptionButton
@onready var lbl_confirm: Label = %lblConfirm

var current_deck = ""



func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_btn_save_pressed() -> void:
	var question = str(word.text)
	var answer = str(traduction.text)
	if current_deck != "" and question != "" and answer != "":
		print ("mot : ", question, " traduction : ", answer)
		word.text = ""
		traduction.text = ""	
		lbl_confirm.text = "Card added to : " + current_deck

func _on_deck_selected(index: int) -> void:
	current_deck = deck_selector.get_item_text(index)
	
