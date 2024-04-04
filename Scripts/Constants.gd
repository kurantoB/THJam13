enum UnitType {
	PLAYER,
	NPC,
}

enum ActionType {
	JUMP,
	MOVE,
	RECOIL,
	DASH
}

enum UnitCondition {
	CURRENT_ACTION,
	IS_ON_GROUND,
	MOVING_STATUS,
	IS_INVINCIBLE,
}

enum UnitCurrentAction {
	IDLE,
	JUMPING,
	RECOILING,
}

enum UnitMovingStatus {
	IDLE,
	MOVING,
	DASHING,
}

enum PlayerInput {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	GBA_A,
	GBA_B,
	GBA_START,
	GBA_SELECT,
}

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

enum MapElemType {
	SQUARE,
	SLOPE_LEFT,
	SLOPE_RIGHT,
	SMALL_SLOPE_LEFT_1,
	SMALL_SLOPE_LEFT_2,
	SMALL_SLOPE_RIGHT_1,
	SMALL_SLOPE_RIGHT_2,
	LEDGE,
}

enum SpriteClass {
	IDLE,
	WALK,
	JUMP,
	RECOIL,
	DASH
}

const UNIT_TYPE_ACTIONS = {
	UnitType.PLAYER: [
		ActionType.JUMP,
		ActionType.MOVE,
		ActionType.DASH
	],
	UnitType.NPC: [
		ActionType.MOVE,
	],
}

# in seconds
const ACTION_TIMERS = {
	UnitType.PLAYER: {},
	UnitType.NPC: {}
}

const UNIT_TYPE_CURRENT_ACTIONS = {
	UnitType.PLAYER: [
		UnitCurrentAction.IDLE,
		UnitCurrentAction.JUMPING,
	],
	UnitType.NPC: [
		UnitCurrentAction.IDLE,
	],
}

# default conditions
const UNIT_TYPE_CONDITIONS = {
	UnitType.PLAYER: {
		UnitCondition.CURRENT_ACTION: UnitCurrentAction.IDLE,
		UnitCondition.IS_ON_GROUND: false,
		UnitCondition.MOVING_STATUS: UnitMovingStatus.IDLE,
		UnitCondition.IS_INVINCIBLE: false,
	},
	UnitType.NPC: {
		UnitCondition.CURRENT_ACTION: UnitCurrentAction.IDLE,
		UnitCondition.IS_ON_GROUND: false,
		UnitCondition.MOVING_STATUS: UnitMovingStatus.IDLE,
	},
}

# in seconds
const CURRENT_ACTION_TIMERS = {
	UnitType.PLAYER: {
		UnitCurrentAction.JUMPING: 0.2
	},
	UnitType.NPC: {}
}

const UNIT_CONDITION_TIMERS = {
	# condition type: [duration, on value, off value]
	UnitType.PLAYER: {
		UnitCondition.IS_INVINCIBLE: [2.5, true, false],
	},
	UnitType.NPC: {},
}

# Position relative to player's origin, list of directions to check for collision
const ENV_COLLIDERS = {
	UnitType.PLAYER: [
		[Vector2(0, 1.125), [Direction.LEFT, Direction.UP, Direction.RIGHT]],
		[Vector2(-.25, 0.6), [Direction.LEFT]],
		[Vector2(.25, 0.6), [Direction.RIGHT]],
		[Vector2(-.25, 1.125), [Direction.LEFT, Direction.UP]],
		[Vector2(.25, 1.125), [Direction.RIGHT, Direction.UP]],
		# contact with ground is at (0, 0)
		[Vector2(0, 0), [Direction.LEFT, Direction.DOWN, Direction.RIGHT]],
	],
	UnitType.NPC: [
		[Vector2(0, 1.5), [Direction.LEFT, Direction.UP, Direction.RIGHT]],
		[Vector2(-.25, .25), [Direction.LEFT]],
		[Vector2(.25, .25), [Direction.RIGHT]],
		[Vector2(-.25, 1.25), [Direction.LEFT]],
		[Vector2(.25, 1.25), [Direction.RIGHT]],
		[Vector2(0, 0), [Direction.LEFT, Direction.DOWN, Direction.RIGHT]],
	],
}

const INPUT_MAP = {
	PlayerInput.UP: "ui_up",
	PlayerInput.DOWN: "ui_down",
	PlayerInput.LEFT: "ui_left",
	PlayerInput.RIGHT: "ui_right",
	PlayerInput.GBA_A: "gba_a",
	PlayerInput.GBA_B: "gba_b",
	PlayerInput.GBA_START: "gba_start",
	PlayerInput.GBA_SELECT: "gba_select",
}

const TILE_SET_MAP_ELEMS = {
	"TestTileSet": {
		MapElemType.SQUARE: [0, 8, 9],
		MapElemType.SLOPE_LEFT: [1],
		MapElemType.SLOPE_RIGHT: [2],
		MapElemType.SMALL_SLOPE_LEFT_1: [3],
		MapElemType.SMALL_SLOPE_LEFT_2: [4],
		MapElemType.SMALL_SLOPE_RIGHT_1: [6],
		MapElemType.SMALL_SLOPE_RIGHT_2: [5],
		MapElemType.LEDGE: [7],
	},
}

const UNIT_SPRITES = {
	# Sprite-class: [Is-animation?, Nodes]
	UnitType.PLAYER: {
		SpriteClass.IDLE: [false, ["Idle"]],
		SpriteClass.WALK: [true, ["Walk"]],
		SpriteClass.JUMP: [false, ["Jump1"]],
		SpriteClass.DASH: [true, ["Dash"]]
	},
	UnitType.NPC: {
		SpriteClass.IDLE: [false, ["Idle"]],
		SpriteClass.WALK: [true, ["Walk"]],
		SpriteClass.JUMP: [false, ["Jump2"]],
	},
}

const UNIT_TYPE_MOVE_SPEEDS = {
	UnitType.PLAYER: 6,
	UnitType.NPC: 3,
}
const DASH_SPEED = 12

const UNIT_TYPE_JUMP_SPEEDS = {
	UnitType.PLAYER: 13,
}

const SCALE_FACTOR = 2.5
const GRID_SIZE = 16 # pixels
const GRAVITY = 50
const MAX_FALL_SPEED = -25
const ACCELERATION = 45
const QUANTUM_DIST = 0.001
const SPAWN_DISTANCE = 10
const HURT_PAUSE_DURATION = .67 # seconds
const COINS_PER_LIFE = 10

# specialized constants
const FLASH_CYCLE = 0.15
