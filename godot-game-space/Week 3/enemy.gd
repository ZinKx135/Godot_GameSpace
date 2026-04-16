extends CharacterBody2D

var hp = 100

@onready var hp_label = $Label

func _ready():
	add_to_group("enemy")
	update_hp_label()

func take_damage(dmg):
	hp -= dmg
	update_hp_label()
	
	if hp <= 0:
		die()

func update_hp_label():
	hp_label.text = str(hp)

func die():
	queue_free()
