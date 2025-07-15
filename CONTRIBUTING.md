# CONTRIBUTING
saar please




# Godot 4

## Filetypes
Folder
-	As normal.

.tscn - Scene 
-	Core file in Godot 4. Comprised of nodes that form rooted trees; e.g., a scene may contain a character node in turn containing sprite, collision, and camera nodes.
-	Each node or subnode can be associated with a script, functions _process(float: delta) -> void: and _physics_process(float: delta) -> void: (null returning) are invoked every frame, with delta being the global
variable for delta time. 
-	Callback function _input() is conversely called only when there is an input event (when a button is pressed). If an input is held, assume _input() is parsed every frame.
-	Signals may also be connected via the gui to invoke scripts and add arguments to callback.
-	We may wish to agree on the degree of granularity of our scenes; i.e., is a scene for each sub-node reasonable, or a scene for each ‘object’ type (e.g., character, enemy node) in the game world?  

.gd, .c - Script
-	As above, gdscript (.gd) and C (.c) files contain functions. Unsure of interaction between _process() and _physics_process() and C at this stage, though assuming you can invoke functions stored in C through .gd files by calling [reference to containing node; e.g., get_parent(), get_node(), $ prefix for subnode references...].[name of function](args), as is possible with other gdscripts. 
-	Scripts appear to be saved separately to, and are subsequently attached to, scenes (via nodes). The same script appears to be attachable to multiple nodes across multiple scenes, e.g., we may replicate character movement across one or multiple .tscn files containing multiple character nodes by affixing the same player.gd file to them.

.tres - Resource
-	Processed resources for use in the Godot 4 engine, e.g., collision-configured tilesets. Can comprise everything from textures, 3d occluders, 2d or 3d shapes, fonts, extensions, mesh data, etc.
-	We may wish to use resource files for storing configured tilesets, player and enemy visuals, etc. 

.txt, .ini, .xml, etc., - TextFile
-	Any sort of text file, incl. common markups. May be useful for storage/retrieval of configuration options.

## Proposed File Structure
Propose the following file structure: 

* **Res://** - default resource folder
  * **Scenes/** - Contains subfolders for different elements
  * **World/** - Overworld scenes, taking other scene elements as subnodes
  * **Terrain/** - Scene(s) aggregating storage/generation of terrain
  * **Character/** - For player/NPC content
    *  **Player/** - Playable Character(s)
    * **Enemy/** - Enemies
    * **NPC/** - If applicable
  * **Scripts/** - bulk storage for scripts. Enforce naming conventions.
  * **Resources/** - Contains subfolders for organising compiled resources. Enforce naming conventions in all cases.
    * **Terrain/** - bulk storage for terrain resources.
    * **Character/** - bulk storage for character resources.
    * **Sound/** - bulk storage for sound resources.
    * **FX/** - bulk storage for effects (e.g., lighting, if used).
    * **Files/** - working storage for files prior to resource compilation?

## Nodetypes
-  Note, from initial test/build it would appear having player character/enemy node always residing as a TileMap subnode is best practice, enables us to readily reference .position functions from $player (or equiv.) within the TileMap node for powering tile layer runtime updates, and get_parent(). inherited functions, e.g., local_to_map, map_to_local, within the player node. Can also pass properties easily between layers to ensure consistency, e.g., for offsetting collisionboxes and graphics appropriately for the tile dimensions. 
to populate l8r, in word doc
