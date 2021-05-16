extends Control

onready var grid: GridContainer = $GridContainer
onready var button = preload("res://FieldButton.tscn")
var gridSize: Vector2 = Vector2(0, 0)

var gridData = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    create_field(Vector2(15, 10))

func create_field(size: Vector2) -> void:
    self.gridSize = size
    grid.columns = size.x as int
    for y in range(size.y):
        var temp = []
        for x in range(size.x):
            var item = button.instance() as Fieldbox
            item.connect("discover", self, "handle_discovery", [Vector2(x, y)])
            temp.append(item)
            grid.add_child(item)
        gridData.append(temp)


func get_amount_of_bombs(position: Vector2) -> int:
    var sum = 0
    for x in range(-1, 2):
        for y in range(-1, 2):
            if not (y == 0 and x == 0):
                sum += 1 if (gridData[position.x + x][position.y + y] as Fieldbox).hasBomb else 0
    return sum

func handle_discovery(position: Vector2) -> void:
    print("owo discovered @ ", position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
