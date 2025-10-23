# Z indexes and the layer system

GodotWE uses a layer system for managing how gameplay elements are drawn
properly, and it makes use of the `CanvasItem`'s `z_index` property (in
GameMaker, this is basically the `depth` variable.) If the `z_index` is
unspecified, the engine will automatically draw nodes from top to bottom as they
are in the tree. Typically you will see gameplay elements use a custom `z_index`
and have `z_as_relative` disabled. `z_as_relative` makes the final Z index a sum
of this node's and its parent's `z_index`es. Since the `z_index` acts as a layer
number, we don't want it to be relative to the parent, or nodes might suddenly
appear in the wrong Z index.

All Z indexes and layers are defined below. Use these when you're making a new
gameplay element, and change the list if you need to. Try only removing or
adding layers, It might be hard to change what nodes expect other nodes' Z
indexes to be! Remember to update both this file and the `GameConstants` static
class!

## All used Z index values

This is a list of all Z index values used in gameplay elements. These can also
be found as constants in the `GameConstants` static class.
---
- `-2` Background
- `-1` Shadows
- `0` Decorations
- `10` Semisolids
	- `11` One-Ways
	- `19` Bridges
- `20` Solids and Objects
	- `21` Arrows
	- `22` Off P-Blocks
	- `28` Vines
	- `29` Burners and Fire Bars
- `30` Entities
	- `39` Mario
- `40` Particles and Additional Overlays
