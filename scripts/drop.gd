extends Spatial

## variables for the drop function ##
export (Array,Resource) var drop_items : Array
export var auto_start : bool = false
export var drop_number : int = 30
export var delay_between_drop : float = 0.1
export var up_velocity : float = 10
export var forward_velocity : float= 2
export var drop_rotation : float = 30

var instance = null
var spawn_point : Vector3 = Vector3(0,1,0)
var direction : Vector3 = Vector3(1,0,0)
var drop_dir : Vector3
var open : bool = false

## variable for the breakable function ##
export var breakable_chest : Resource
onready var parent = self.get_parent()


func _ready():
	#Drop items when auto_start == true.
	if auto_start : 
		drop()
		
## Only to reset the scene
func _process(delta):
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()
		
## Code to drop items.
func drop():
	#It is looping because we want more than one item to drop.
	for i in drop_number:
		#Instancing a random item from the drop items array.
		instance = drop_items[randi()%3].instance()
		
		#We have to do this. It's the law!
		add_child(instance)
		
		#Setting the instance's translation to the given spawn point.
		instance.translation = spawn_point
		#Setting the instance's transformations to global space.
		instance.set_as_toplevel(true)
		
		#Calculating the direction to drop the item.
		drop_dir = global_transform.origin.direction_to(to_global(direction))
		#Setting the linear velocity and angular velocity of the item to drop in the given direction.
		instance.linear_velocity = Vector3(drop_dir.x*forward_velocity,up_velocity,drop_dir.z*forward_velocity)
		instance.angular_velocity = Vector3(drop_dir.x*drop_rotation,0,drop_dir.z*drop_rotation)
		
		#If delay_between_drop > 0 then it will drop the items one by one.
		yield(get_tree().create_timer(delay_between_drop), "timeout")
		
##Code to break something.
func break_object():
	#Instancing the breakable
	var breakable = breakable_chest.instance()
	
	#I repeat myself. We have to do this. It's the law!
	parent.add_child(breakable)
	
	#Setting the breakable's translation and rotation to the chest.
	breakable.translation = self.translation
	breakable.rotation_degrees = self.rotation_degrees
	
	#Setting the breakable's transformations to global space.
	for i in breakable.get_children():
		i.set_as_toplevel(true)
		
	# Deleting the chest.
	self.queue_free()
	

## Just to open or breake the chest.
## The LEFT CLICK breaks the chest, the RIGHT CLICK opens the chest.
func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if !open:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed == true:
				open = true
				break_object()
			if event.button_index == BUTTON_RIGHT and event.pressed == true:
				open = true
				$AnimationPlayer.play("Open")
