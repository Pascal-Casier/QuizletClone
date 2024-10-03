extends Node


var decks = {}

func create_deck(deck_name):
	if not decks.has(deck_name):
		decks[deck_name] = []

func add_card_to_deck(deck_name, question, answer):
	if decks.has(deck_name):
		decks[deck_name].append({"question": question, "answer": answer})

func get_decks():
	return decks.keys()

func get_cards_in_deck(deck_name):
	return decks.get(deck_name, [])
