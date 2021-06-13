extends Area2D


# Declare member variables here. Examples:
export (NodePath) var Gate

var pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	if get_parent().has_node("Boulder"):
#		print("boulder found")
#		boulder = get_parent().get_child(1)
#		boulder.connect("body_entered", self, "_pushed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



#func _pushed(body):
#	self.get_node(Gate).global_position.y += 16


func _on_Button_body_entered(body):
	if body.get_name() == "Boulder" and not pressed:
		pressed = true
		get_node(Gate).global_position.y += 94
		$AnimatedSprite.play("pressed")
