extends Area2D


# Declare member variables here. Examples:
export (NodePath) var Gate

var pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Switch_body_entered(body):
	if body.name.match("RigidPlayer") and not pressed:
		pressed = true
		get_node(Gate).global_position.y += 94
		$AnimatedSprite.play("toggled")
