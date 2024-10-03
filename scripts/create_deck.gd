extends Control

@onready var line_edit: LineEdit = $ColorRect/MarginContainer/HBoxContainer2/LineEdit

func _ready():
	pass

func _on_Back_pressed():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_btn_save_deck_pressed() -> void:
	var deck_name = line_edit.text
	if deck_name != "":
		DeckManager.create_deck(deck_name)
		get_tree().change_scene_to_file("res://create_card.tscn")
		
	else: 
		line_edit.placeholder_text = "enter a name"


func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

