# raywolf
Raywolf was a Wolfenstein-clone engine project made in D using raylib for my ultimate cegep project. If we ignore its very barebones feature set and tooling, the engine has 6 major flaws:
0. A mistake in my projection algorithm makes the walls significantly larger than their height, making them look more rectangular than square like in Wolfenstein 3D. On the plus side, this has an interesting effect on ambiance with some textures.
1. There's a memory leak in my get pixel function. This would normally not be an issue as raylib has its own get pixel, but this was written before that function existed and newer versions of raylib tend to break compatibility with older versions just for the sake of it, so it wasn't really realistic to migrate to 4.0. This will make the game crash, especially in large maps.
2. The NPC thing going on is underdeveleppoed because lack of time. So it goes into walls and walks in straigh lines.
3. I was still pretty new to D when I started to work on this project, so it definitely underutilises D's features.
4. To meet deadlines, the implementation of a lot of things was rushed and need to be rewritten.
5. My raycasting algorithm is very inefficient. It would be very slow on a limited system. 
