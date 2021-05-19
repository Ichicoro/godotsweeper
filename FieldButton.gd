extends Control
class_name Fieldbox

onready var ClosebombsLabel = $ClosebombsAmount
onready var ExplodedPanel = $Panel2
onready var FlagSprite = $Sprite

signal discover(position)		# position: Vector2
signal mark(position)			# position: Vector2

enum Status {
	HIDDEN,
	MARKED,
	DISCOVERED
}

var blockState: int = Status.HIDDEN setget update_block_state
var hasBomb: bool = false setget update_has_bomb
var amountOfCloseBombs: int = 0 setget update_close_bombs

var holdStartTime: int = 0

func _ready() -> void:
	ExplodedPanel.visible = false
	ClosebombsLabel.visible = false
	FlagSprite.visible = false

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton or event is InputEventScreenTouch):
		return
	if not self.get_global_rect().has_point(event.position):
		return
	if event is InputEventMouseButton and !event.is_pressed() \
		and (event as InputEventMouseButton).button_index == 2:
		if self.blockState == Status.HIDDEN:
			mark()
		else:
			reset()
	if event is InputEventScreenTouch:
		print((event as InputEventScreenTouch).position)
		self.handle_touch(event)
	elif event is InputEventScreenDrag:		# rip this isn't working :(
		self.holdStartTime == 0

func handle_touch(event: InputEventScreenTouch) -> void:
	# If the tile has already been discovered, do nothing
	if self.blockState == Status.DISCOVERED:
		return

	if event.pressed:
		self.holdStartTime = OS.get_ticks_msec()
		self.modulate = Color.darkgray
		yield(get_tree().create_timer(0.250), "timeout")
		handle_auto_hold()
	else:
		if self.holdStartTime == 0:
			return
		var elapsed = OS.get_ticks_msec() - self.holdStartTime
		self.holdStartTime = 0
		print("elapsed: ", elapsed)
		if elapsed > 250:
			if self.blockState == Status.HIDDEN:
				mark()
			else:
				reset()
		else:
			discover()

func handle_auto_hold():
	if self.holdStartTime != 0:
		if self.blockState == Status.HIDDEN:
			mark()
		else:
			reset()
		self.holdStartTime = 0

func discover():
	emit_signal("discover")

func mark():
	emit_signal("mark")

func reset():
	self.blockState = Status.HIDDEN

func get_texture() -> Texture:
	return null

func update_close_bombs(amount: int) -> void:
	amountOfCloseBombs = amount
	ClosebombsLabel.text = str(amount) if amount > 0 else ""

func update_has_bomb(has_bomb: bool) -> void:
	hasBomb = has_bomb
#	ExplodedPanel.visible = has_bomb
#	ClosebombsLabel.visible = not has_bomb

func update_block_state(state: int) -> void:
	blockState = state
	match state:
		Status.HIDDEN:
			self.modulate = Color.white
			ExplodedPanel.visible = false
			ClosebombsLabel.visible = false
			FlagSprite.visible = false
		Status.MARKED:
			self.modulate = Color.darkslategray
			ExplodedPanel.visible = false
			ClosebombsLabel.visible = false
			FlagSprite.visible = true
		Status.DISCOVERED:
			self.modulate = Color.darkgray
			ExplodedPanel.visible = self.hasBomb
			ClosebombsLabel.visible = not self.hasBomb
			FlagSprite.visible = false
