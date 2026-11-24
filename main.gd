extends Node2D

const WORLD := Vector2(1800, 1100)
var player := Vector2(480, 300)
var slime := Vector2(760, 360)
var level := 1
var exp_points := 0
var gold := 0
var message := "Explore the meadow. Move with WASD or arrows; SPACE to attack."
var cooldown := 0.0
var move_touch := Vector2.ZERO
var save_clock := 0.0

func _ready():
    _load_game()

func _process(delta):
    var move := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move.x -= 1
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move.x += 1
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move.y -= 1
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move.y += 1
    move += move_touch
    if move.length() > 1.0: move = move.normalized()
    player += move * 220.0 * delta
    player.x = clampf(player.x, 20, WORLD.x - 20)
    player.y = clampf(player.y, 20, WORLD.y - 20)
    cooldown = maxf(0.0, cooldown - delta)
    save_clock += delta
    if save_clock > 5.0:
        save_clock = 0.0
        _save_game()
    queue_redraw()

func _draw():
    var screen := get_viewport_rect().size
    var cam := player - screen / 2.0
    draw_rect(Rect2(-cam, WORLD), Color("#345b38"))
    for x in range(0, int(WORLD.x), 64):
        for y in range(0, int(WORLD.y), 64):
            if (x / 64 + y / 64) % 2 == 0:
                draw_rect(Rect2(Vector2(x, y) - cam, Vector2(62, 62)), Color("#3c6842"))
    for i in range(18):
        var p := Vector2(100 + (i * 173) % 1550, 100 + (i * 97) % 850) - cam
        draw_rect(Rect2(p + Vector2(-4, 8), Vector2(8, 25)), Color("#70452d"))
        draw_circle(p, 19, Color("#1e472d"))
        draw_circle(p + Vector2(-8, -5), 11, Color("#2c6938"))
    _draw_slime(slime - cam)
    _draw_player(screen / 2.0)
    draw_rect(Rect2(12, 12, 310, 92), Color(0.04, 0.06, 0.08, 0.88))
    draw_string(ThemeDB.fallback_font, Vector2(24, 38), "ETERNAL REALMS", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#f6d98a"))
    draw_string(ThemeDB.fallback_font, Vector2(24, 64), "Level %d   EXP %d/100" % [level, exp_points], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(24, 90), "Gold: %d" % gold, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffdf88"))
    draw_rect(Rect2(12, screen.y - 48, screen.x - 24, 36), Color(0.04, 0.06, 0.08, 0.85))
    draw_string(ThemeDB.fallback_font, Vector2(24, screen.y - 25), message, HORIZONTAL_ALIGNMENT_LEFT, screen.x - 48, 14, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(screen.x - 175, 35), "SPACE / ATTACK", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

func _draw_player(p):
    draw_circle(p + Vector2(0, 8), 13, Color("#26333c"))
    draw_rect(Rect2(p + Vector2(-9, -9), Vector2(18, 24)), Color("#315eaa"))
    draw_circle(p + Vector2(0, -13), 10, Color("#e7b889"))
    draw_rect(Rect2(p + Vector2(-10, -23), Vector2(20, 7)), Color("#593b29"))

func _draw_slime(p):
    draw_circle(p, 17, Color("#8ee66b"))
    draw_circle(p + Vector2(-6, -3), 2, Color("#183c28"))
    draw_circle(p + Vector2(6, -3), 2, Color("#183c28"))

func _input(event):
    if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
        _attack()
    elif event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x > get_viewport_rect().size.x * 0.65:
                _attack()
            elif event.position.y > get_viewport_rect().size.y * 0.55:
                move_touch = (event.position - Vector2(100, get_viewport_rect().size.y - 120)).normalized()
        else:
            move_touch = Vector2.ZERO
    elif event is InputEventScreenDrag and event.position.x < get_viewport_rect().size.x * 0.45:
        move_touch = (event.position - Vector2(100, get_viewport_rect().size.y - 120)).normalized()

func _attack():
    if cooldown > 0.0: return
    cooldown = 0.55
    if player.distance_to(slime) <= 105:
        exp_points += 25
        gold += 5
        slime = Vector2(200 + randf() * 1400, 150 + randf() * 800)
        message = "Slime defeated! +25 EXP, +5 gold."
        if exp_points >= 100:
            exp_points -= 100
            level += 1
            message = "LEVEL UP! You reached level %d." % level
        _save_game()
    else:
        message = "Move closer to the slime before attacking."

func _save_game():
    var data = {"x": player.x, "y": player.y, "level": level, "exp": exp_points, "gold": gold}
    var f = FileAccess.open("user://save.json", FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(data))

func _load_game():
    if not FileAccess.file_exists("user://save.json"): return
    var f = FileAccess.open("user://save.json", FileAccess.READ)
    if not f: return
    var data = JSON.parse_string(f.get_as_text())
    if data is Dictionary:
        player = Vector2(float(data.get("x", 480)), float(data.get("y", 300)))
        level = int(data.get("level", 1))
        exp_points = int(data.get("exp", 0))
        gold = int(data.get("gold", 0))
