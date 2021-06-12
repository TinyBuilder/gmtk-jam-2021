extends RigidBody2D

export (int) var run_speed = 100
export (int) var max_force = 1000
export (int) var max_speed = 100
export (int) var jump_speed = -400
export (int) var gravity = 1200
export (int) var max_distance = 100

var force = Vector2()
var jumping = false
var boulder = null
var tether = Vector2()

const Chain = preload("res://Chain.tscn")
var chains = []


func _ready():
	if get_parent().has_node("Boulder"):
		print("boulder found")
		boulder = get_parent().get_child(1)
		for i in range(20):
			chains.append(Chain.instance())
			print(chains[i-1])
			add_child(chains[i-1])

func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	
	force.x = 0
	
	if right:
		force.x += run_speed
	if left:
		force.x -= run_speed
		
	if abs(force.x) > max_force:
		force.x = (force.x / abs(force.x)) * max_force

func _process(delta):
	get_input()
	tether = boulder.position - position
	var i = 1
	for chain in chains:
		chain.set_position(position + (tether / i))
		i += 1

func _physics_process(delta):
	if tether.length() > max_distance:
		apply_central_impulse(tether.normalized() * (tether.length() - max_distance))
		boulder.apply_central_impulse(tether.normalized() * -1 * (tether.length() - max_distance) / 20)
	else:
		apply_central_impulse(force)
	
func _integrate_forces(state):
	if abs(get_linear_velocity().x) > max_speed or abs(get_linear_velocity().y) > max_speed:
		var new_speed = get_linear_velocity().normalized()
		new_speed *= max_speed
		set_linear_velocity(new_speed)
