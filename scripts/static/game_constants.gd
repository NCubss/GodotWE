@abstract
class_name GameConstants
## Defines various constants used across the game.

## Represents the Z indexes gameplay elements use.
enum Layers {
	## The background [Parallax2D] node.
	Z_BACKGROUND = -2,
	## The shadows [CanvasGroup] node.
	Z_SHADOWS = -1,
	## Level decorations. (not visual aid objects like arrows)
	Z_DECORATIONS = 0,
	## Semi-solid platforms.
	Z_SEMISOLIDS = 10,
	## One-ways.
	Z_ONE_WAYS = 11,
	## Bridges.
	Z_BRIDGES = 18,
	## Item sprouts.
	Z_SPROUT = 19,
	## Solids and other objects which are not of type [Entity].
	Z_SOLIDS = 20,
	## Arrow objects.
	Z_ARROWS = 21,
	## Deactivated P-blocks.
	Z_OFF_P_BLOCKS = 22,
	## Question blocks during their bounce animation.
	Z_ANIM_BLOCKS = 23,
	## Vines.
	Z_VINES = 28,
	## Burners and Fire Bars.
	Z_FIRE = 29,
	## Bodies of type [Entity].
	Z_ENTITIES = 30,
	## The player's held item, if it is behind the player.
	Z_BEFORE_PLAYER = 37,
	## The player.
	Z_PLAYER = 38,
	## The player's held item, if it is in front of the player.
	Z_AFTER_PLAYER = 39,
	## Various particles.
	Z_PARTICLES = 40,
	## Dead enemies.
	Z_DEAD = 45,
	## The gameplay HUD.
	Z_HUD = 50,
}

## The game's config file path.
const GAME_CONFIG_PATH = "user://SMMWE.cfg"
## A registry of all background scene paths. The hierarchy goes
## [enum Level.GameStyle], [enum Level.LevelTheme], then a [bool] table for
## whether [member SubArea.night_mode] is enabled.
const BACKGROUNDS = {
	Level.GameStyle.SMB: {
		Level.LevelTheme.OVERWORLD: {
			true: "",
			false: "",
		},
		Level.LevelTheme.UNDERGROUND: {
			true: "",
			false: "",
		},
		Level.LevelTheme.UNDERWATER: {
			true: "",
			false: "",
		},
		Level.LevelTheme.CASTLE: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SKY: {
			true: "",
			false: "",
		},
		Level.LevelTheme.AIRSHIP: {
			true: "",
			false: "",
		},
		Level.LevelTheme.DESERT: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SNOW: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MANSION: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FOREST: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FALL: {
			true: "",
			false: "",
		},
		Level.LevelTheme.BEACH: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MOUNTAIN: {
			true: "",
			false: "",
		},
	},
	Level.GameStyle.SMB3: {
		Level.LevelTheme.OVERWORLD: {
			true: "",
			false: "",
		},
		Level.LevelTheme.UNDERGROUND: {
			true: "",
			false: "",
		},
		Level.LevelTheme.UNDERWATER: {
			true: "",
			false: "",
		},
		Level.LevelTheme.CASTLE: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SKY: {
			true: "",
			false: "",
		},
		Level.LevelTheme.AIRSHIP: {
			true: "",
			false: "",
		},
		Level.LevelTheme.DESERT: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SNOW: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MANSION: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FOREST: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FALL: {
			true: "",
			false: "",
		},
		Level.LevelTheme.BEACH: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MOUNTAIN: {
			true: "",
			false: "",
		},
	},
	Level.GameStyle.SMW: {
		Level.LevelTheme.OVERWORLD: {
			true: "",
			false: "uid://ctnffmabe0h4f",
		},
		Level.LevelTheme.UNDERGROUND: {
			true: "",
			false: "",
		},
		Level.LevelTheme.UNDERWATER: {
			true: "",
			false: "",
		},
		Level.LevelTheme.CASTLE: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SKY: {
			true: "",
			false: "",
		},
		Level.LevelTheme.AIRSHIP: {
			true: "",
			false: "",
		},
		Level.LevelTheme.DESERT: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SNOW: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MANSION: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FOREST: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FALL: {
			true: "",
			false: "",
		},
		Level.LevelTheme.BEACH: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MOUNTAIN: {
			true: "",
			false: "",
		},
	},
	Level.GameStyle.NSMBU: {
		Level.LevelTheme.OVERWORLD: {
			true: "",
			false: "",
		},
		Level.LevelTheme.UNDERGROUND: {
			true: "",
			false: "",
		},
		Level.LevelTheme.UNDERWATER: {
			true: "",
			false: "",
		},
		Level.LevelTheme.CASTLE: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SKY: {
			true: "",
			false: "",
		},
		Level.LevelTheme.AIRSHIP: {
			true: "",
			false: "",
		},
		Level.LevelTheme.DESERT: {
			true: "",
			false: "",
		},
		Level.LevelTheme.SNOW: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MANSION: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FOREST: {
			true: "",
			false: "",
		},
		Level.LevelTheme.FALL: {
			true: "",
			false: "",
		},
		Level.LevelTheme.BEACH: {
			true: "",
			false: "",
		},
		Level.LevelTheme.MOUNTAIN: {
			true: "",
			false: "",
		},
	},
}
