extends Control

@export var num_phrases: int = 2  # Nombre de phrases à traduire
@export var phrases_pt: Array[String] = ["Olá, como você está?", "Eu gosto de programar."]
@export var phrases_fr: Array[String] = ["Bonjour, comment ça va?", "J'aime programmer."]
@export var phrases_audio: Array[AudioStream] = []
@export var talking_voices : Array[AudioStream]

@onready var correct_icon = preload("res://assets/correct-48.png")
@onready var incorrect_icon = preload("res://assets/incorrect-48.png")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var correct_sound = preload("res://assets/correct2.ogg")
@onready var incorrect_sound = preload("res://assets/incorrect2.ogg")
@onready var audio_stream_player_correct: AudioStreamPlayer = $AudioStreamPlayerCorrect
@onready var listen_button: Button = %ListenButton
@onready var phrase_audio_player: AudioStreamPlayer = $PhraseAudioPlayer


var current_phrases = []
var incorrect_phrases = []  # Liste pour les phrases incorrectes
var selected_words = []
var current_phrase = {}
var last_phrase_index = -1  # Variable pour suivre l'index de la dernière phrase utilisée
var score = 0  # Variable pour suivre le score
var total_attempts = 0  # Variable pour suivre le nombre total de tentatives
var incorrect_words = []  # Liste pour les mots incorrects
var previously_incorrect_phrases = []  # Liste pour les phrases incorrectes déjà proposées

func _ready():
	randomize()  # Initialiser le générateur de nombres aléatoires
	load_new_phrases()
	
	# Connecter le bouton "Corriger" à la fonction _on_correct_button_pressed
	var correct_button = get_node("%CorrectButton")
	correct_button.pressed.connect(_on_correct_button_pressed)
	
	listen_button.pressed.connect(_on_listen_button_pressed)

func load_new_phrases():
	current_phrases.clear()
	for i in range(num_phrases):
		var index = randi() % phrases_pt.size()
		# Assurer que la nouvelle phrase est différente de la dernière
		while index == last_phrase_index:
			index = randi() % phrases_pt.size()
		current_phrases.append({
			"pt": phrases_pt[index],
			"fr": phrases_fr[index],
			"audio": phrases_audio[index] if index < phrases_audio.size() else null
		})
		last_phrase_index = index  # Mettre à jour l'index de la dernière phrase utilisée
	load_new_phrase()
	
	
func load_new_phrase():
	if current_phrases.size() > 0:
		current_phrase = current_phrases.pop_front()
		var words = current_phrase["fr"].split(" ")
		words = shuffle_array(words)
		create_buttons(words)
		update_labels(current_phrase)
		
		listen_button.visible = current_phrase in previously_incorrect_phrases  # Afficher si c'est une phrase incorrecte précédente
	else:
		if incorrect_phrases.size() > 0:
			current_phrases = incorrect_phrases.duplicate()
			incorrect_phrases.clear()
			load_new_phrase()
		else:
			show_final_score()


func create_buttons(words):
	var button_container = get_node("%ButtonContainer")
	# Clear previous buttons
	for child in button_container.get_children():
		button_container.remove_child(child)
		child.queue_free()
	
	for word in words:
		var button = Button.new()
		button.text = word
		button.add_to_group("button")
		button.pressed.connect(_on_button_pressed.bind(word))
		button.mouse_entered.connect(_on_button_mouse_entered)
		button_container.add_child(button)

func _on_button_pressed(word):
	audio_stream_player.pitch_scale = 1
	audio_stream_player.play()
	selected_words.append(word)
	update_labels()
	disable_button(word)  # Désactiver le bouton après qu'il ait été pressé
	if selected_words.size() == current_phrase["fr"].split(" ").size():
		check_phrase()
		
func _on_listen_button_pressed():
	if current_phrase["audio"]:
		phrase_audio_player.stream = current_phrase["audio"]
		phrase_audio_player.play()		


func _on_button_mouse_entered():
	audio_stream_player.pitch_scale = 2
	audio_stream_player.play()
	
func disable_button(word):
	var button_container = get_node("%ButtonContainer")
	for button in button_container.get_children():
		if button.text == word:
			button.disabled = true

func enable_button(word):
	var button_container = get_node("%ButtonContainer")
	for button in button_container.get_children():
		if button.text == word:
			button.disabled = false

func _on_correct_button_pressed():
	if selected_words.size() > 0:
		var last_word = selected_words.pop_back()  # Supprimer le dernier mot proposé
		enable_button(last_word)  # Réactiver le bouton correspondant
		update_labels()

func check_phrase():
	var success_label = get_node("%SuccessLabel")
	var error_label = get_node("%ErrorLabel")
	
	total_attempts += 1  # Incrémenter le nombre total de tentatives
	
	if " ".join(selected_words) == current_phrase["fr"]:
		success_label.text = "Correct !"
		error_label.text = ""
		%CorrectIcon.texture = correct_icon
		%CorrectIcon.show()
		audio_stream_player_correct.stream = correct_sound
		audio_stream_player_correct.play()
		score += 1  # Incrémenter le score pour une réponse correcte
		
		#// Retirer la phrase de la liste des incorrectes
		if current_phrase in previously_incorrect_phrases:
			previously_incorrect_phrases.erase(current_phrase)
	else:
		success_label.text = ""
		error_label.text = "Incorrect !"
		%CorrectIcon.texture = incorrect_icon
		%CorrectIcon.show()
		audio_stream_player_correct.stream = incorrect_sound
		audio_stream_player_correct.play()
		
		#// Ajouter la phrase actuelle à la liste des phrases incorrectes
		if current_phrase not in previously_incorrect_phrases:
			previously_incorrect_phrases.append(current_phrase)

	selected_words.clear()
	
	#// Démarrer le Timer pour un délai d'une seconde
	var delay_timer = get_node("%DelayTimer")
	delay_timer.start(1.0)
	await delay_timer.timeout
	
	hide_feedback_messages()
	load_new_phrase()

func hide_feedback_messages():
	var success_label = get_node("%SuccessLabel")
	var error_label = get_node("%ErrorLabel")
	success_label.text = ""
	error_label.text = ""
	%CorrectIcon.hide()

func update_labels(phrase = null):
	if phrase:
		get_node("%PortugueseLabel").text = "Traduire :\n " + phrase["pt"]
	get_node("%FrenchLabel").text = "Votre traduction :\n" + " ".join(selected_words)

func show_final_score():
	%FrenchLabel.hide()
	var final_score_label = get_node("%FinalScoreLabel")
	final_score_label.text = "Votre score final est : " + str(score) + "/" + str(total_attempts)
	%ButtonExit.show()
	animation_player.play("blink")

func shuffle_array(array):
	var _size = array.size()
	for i in range(_size):
		var rand_index = randi() % _size
		var temp = array[i]
		array[i] = array[rand_index]
		array[rand_index] = temp
	return array

func reset_game():
	#// Réinitialiser les variables
	score = 0
	total_attempts = 0
	incorrect_phrases.clear()
	previously_incorrect_phrases.clear()
	selected_words.clear()
	
	#// Mettre à jour l'affichage
	update_labels()  #// Réinitialise les étiquettes de texte
	%FinalScoreLabel.hide()  #// Masquer le label de score final
	%FrenchLabel.show() # // Afficher à nouveau le label de traduction
	%ButtonExit.hide()  #// Masquer le bouton de sortie
	load_new_phrases()  #// Charger de nouvelles phrases pour commencer le jeu
	animation_player.stop()


func _on_button_exit_pressed() -> void:
	hide()
