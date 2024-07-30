extends Node2D

var player_hand = []
var dealer_hand = []
var round_one = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/Play_again.hide()
	new_game()

func new_game() -> void:
	player_hand = []
	dealer_hand = []
	ui_toggle(true)
	draw_card(1)
	await get_tree().create_timer(0.5).timeout
	draw_card(1)
	await get_tree().create_timer(0.5).timeout
	draw_card(0)
	await get_tree().create_timer(0.5).timeout
	draw_blank_card()
	await get_tree().create_timer(0.5).timeout
	var hand = count_hand(dealer_hand)
	$UI/Dealer_score.text = str(hand)
	player_round()

# Draws a card. Player function determines who gets the card.
# Dealer = 0, Player = 1
func draw_card(player) -> void:
	# Arrays for each suit and card value
	var suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
	var values = ["A", "2", "3", "4", "5", "6","7", "8", "9", "10", "J", "Q", "K"]
	
	# Preload scene and pick random suit and value.
	var scene = preload("res://Scenes/card.tscn")
	var random_card = scene.instantiate()
	random_card.suit = suits.pick_random()
	random_card.value = values.pick_random()
	random_card.player = player
	
	# Card appears on dealer or player side and moves to center.
	if player == 0:
		$Dealer/Cards.add_child(random_card)
		random_card.global_position = $Dealer/Card_spawner.global_position
		dealer_hand.append(random_card.value)
	else:
		$Player/Cards.add_child(random_card)
		random_card.global_position = $Player/Card_spawner.global_position
		player_hand.append(random_card.value)

# Draws a blank card for the dealer at the beginning of the game.
func draw_blank_card() -> void:
	var scene = preload("res://Scenes/card.tscn")
	var blank_card = scene.instantiate()
	$Dealer/Cards.add_child(blank_card)
	blank_card.global_position = $Dealer/Card_spawner.global_position

func player_round() -> void:
	var hand = count_hand(player_hand)
	$UI/Player_score.text = str(hand)
	if hand == 21:
		dealer_round()
	elif hand > 21:
		bust()
	else:
		ui_toggle(false)

# Count the value of the hand
func count_hand(hand) -> int:
	var score = 0
	var ace_counted = false
	for item in hand:
		if item in ["J", "Q", "K"]:
			score += 10
		if item == "A":
			score += ace_value(score, ace_counted)
			ace_counted = true
		else:
			score += int(item)
	return score

# Get the Value of an Ace depending on what your current score is.
func ace_value(score, ace_counted) -> int:
	if score < 11 and ace_counted != true:
		return 11
	return 1

func dealer_round() -> void:
	ui_toggle(true)
	# Delete blank card if still there.
	
	if dealer_hand.size() == 1:
		var blank_card = $Dealer/Cards.get_child($Dealer/Cards.get_child_count()-1)
		blank_card.free()
	
	# Count Dealers hand
	var hand = count_hand(dealer_hand)
	$UI/Dealer_score.text = str(hand)
	
	# Continue drawing cards if dealer has less than 17.
	while hand < 17:
		draw_card(0)
		await get_tree().create_timer(0.5).timeout
		hand = count_hand(dealer_hand)
		$UI/Dealer_score.text = str(hand)
	
	determine_winner()

func determine_winner() -> void:
	var winner_text
	var player_score = count_hand(player_hand)
	var dealer_score = count_hand(dealer_hand)
	if dealer_score > 21:
		winner_text = "Dealer Bust! You win!"
	elif player_score > dealer_score:
		if player_score == 21:
			winner_text = "Blackjack! You win!"
		else:
			winner_text = "You win!"
	elif player_score < dealer_score:
		winner_text = "Dealer wins"
	else:
		winner_text = "Push"
	$UI/Winner.text = winner_text
	$UI/Play_again.show()


# Function that activates if you have over 21 score
func bust() -> void:
	$UI/Winner.text = "BUST! Dealer wins"
	$UI/Play_again.show()

# Toggles UI on or off
func ui_toggle(boolean):
	if boolean == true:
		$UI/Buttons.hide()
	else:
		$UI/Buttons.show()
		if round_one == false:
			$"UI/Buttons/Double Down".hide()


func _on_hit_pressed() -> void:
	round_one = false
	ui_toggle(true)
	draw_card(1)
	await get_tree().create_timer(0.5).timeout
	player_round()


func _on_stand_pressed() -> void:
	dealer_round()


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_double_down_pressed() -> void:
	ui_toggle(true)
	draw_card(1)
	await get_tree().create_timer(0.5).timeout
	var hand = count_hand(player_hand)
	$UI/Player_score.text = str(hand)
	if hand > 21:
		bust()
	else:
		dealer_round()
