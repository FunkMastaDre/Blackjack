class_name card

extends Sprite2D

var suit : String
var value : String
var player : int
@onready var hand = get_parent()
var vector : Vector2


func _ready() -> void:
	calculate_position()
	decide_texture()
	move_to_hand()

### Decides the texture of the card based on the suit and value.
func decide_texture():
	var format_string = "res://Assets/Cards/%s %s.png"
	var texture_path = format_string % [suit, value]
	if suit == "" and value == "":
		texture_path = "res://Assets/Cards/Card Back 2.png"
	texture = load(texture_path)

# Moves card to hand. Position based off calculate_position()
func move_to_hand():
	var tween = create_tween()
	tween.tween_property(self, "position", (hand.position + vector), 0.5)
	await tween.finished

# Decides position of where to move the card to, based on the amount of cards in the player/dealers hand
func calculate_position():
	var hand_size = hand.get_child_count() - 1
	var gap = 30
	if player == 1:
		vector = Vector2(-hand_size * gap, 0)
	else:
		vector = Vector2(hand_size * gap, 0)
