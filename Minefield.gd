extends Control

signal won(time)
signal lost(time, discovered)

enum GameState {
	WAITING,
	IN_GAME,
	PAUSED,
	FINISHED
}

onready var grid: GridContainer = $CenterContainer/GridContainer
onready var button = preload("res://FieldButton.tscn")
var gridSize: Vector2 = Vector2(0, 0)
var amountOfMines: int = 0
var totalGameTime: int = 0
var gameState: int = GameState.WAITING

var gridData = []
var amountOfDiscoveredBlocks: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_field(Vector2(20, 15), 105)

func _process(delta) -> void:
	match gameState:
		GameState.IN_GAME:
			totalGameTime += delta
		_:
			pass

func create_field(size: Vector2, amountOfMines: int) -> void:
	randomize()
	self.amountOfMines = amountOfMines
	self.gridSize = size
	grid.columns = size.x as int
	for y in range(size.y):
		var temp = []
		for x in range(size.x):
			var item = button.instance() as Fieldbox
			item.connect("discover", self, "handle_discovery", [Vector2(x, y)])
			item.connect("mark", self, "handle_marking", [Vector2(x, y)])
			temp.append(item)
			grid.add_child(item)
		gridData.append(temp)
	print(gridData[0])
	amountOfDiscoveredBlocks = 0

func generate_mines(amount: int, clickPos: Vector2) -> void:
	if amount <= 0: return
	
	for k in range(amount):
		var x = -1
		var y = -1
		while (gridData[y][x].hasBomb) \
			or (x == -1 and y == -1) \
			or (x in range(clickPos.x-3, clickPos.x+3) and y in range(clickPos.y-3, clickPos.y+3)):
			x = randi() % gridSize.x as int
			y = randi() % gridSize.y as int
		gridData[y][x].hasBomb = true
		for xx in range(-1, 2):
			for yy in range(-1, 2):
				if (y+yy == -1 or y+yy == gridSize.y) or x+xx == -1 or x+xx == gridSize.x:
					continue
				if not (yy == 0 and xx == 0):
					gridData[y+yy][x+xx].amountOfCloseBombs += 1
				else:
					gridData[y+yy][x+xx].amountOfCloseBombs = 0


func get_amount_of_bombs(position: Vector2) -> int:
	var sum = 0
	for x in range(-1, 2):
		for y in range(-1, 2):
			if not (y == 0 and x == 0):
				sum += 1 if (gridData[position.x + x][position.y + y] as Fieldbox).hasBomb else 0
	return sum

func handle_discovery(position: Vector2) -> void:
	if amountOfDiscoveredBlocks == 0 and gameState == GameState.WAITING:
		gameState = GameState.IN_GAME
		generate_mines(amountOfMines, position)
	
	if gameState != GameState.IN_GAME: return
	
	var data = gridData[position.y][position.x] as Fieldbox
	data.blockState = Fieldbox.Status.DISCOVERED
	if data.hasBomb:
		lose()
		return
	else:
		amountOfDiscoveredBlocks += 1
		if gridSize.x * gridSize.y - amountOfDiscoveredBlocks == amountOfMines:
			win()
	if data.amountOfCloseBombs == 0:
		for vec in [Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1)]:
			var calcPosX = position.x + vec.x
			var calcPosY = position.y + vec.y
			if (calcPosY == -1 or calcPosY == gridSize.y) or calcPosX == -1 or calcPosX == gridSize.x:
				continue
			var nextData = gridData[calcPosY][calcPosX]
			if not nextData.hasBomb \
				and nextData.blockState == Fieldbox.Status.HIDDEN:
				nextData.discover()
		for vec in [Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]:
			var calcPosX = position.x + vec.x
			var calcPosY = position.y + vec.y
			if (calcPosY == -1 or calcPosY == gridSize.y) or calcPosX == -1 or calcPosX == gridSize.x:
				continue
			var nextData = gridData[calcPosY][calcPosX]
			if nextData.amountOfCloseBombs > 0 \
				and not nextData.hasBomb \
				and nextData.blockState == Fieldbox.Status.HIDDEN:
				nextData.discover()

func handle_marking(position: Vector2) -> void:
	if gameState != GameState.IN_GAME: return
	
	var data = gridData[position.y][position.x] as Fieldbox
	data.blockState = Fieldbox.Status.MARKED

func win():
	print("won! winner winner chicken dinner :)")
	gameState = GameState.FINISHED
	emit_signal("won", totalGameTime)

func lose():
	print("found bomb. ur ded.")
	gameState = GameState.FINISHED
	emit_signal("lost", totalGameTime, amountOfDiscoveredBlocks)
