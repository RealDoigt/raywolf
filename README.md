# raywolf
![image](https://github.com/RealDoigt/raywolf/assets/57451013/8c6c1e2c-7946-487e-adb6-cc7ef4efec1e)
Raywolf was a Wolfenstein-clone engine project made in D using raylib for my ultimate cegep project. If we ignore its very barebones feature set and tooling, the engine has 7 major flaws:
1. A mistake in my projection algorithm makes the walls significantly larger than their height, making them look more rectangular than square like in Wolfenstein 3D. On the plus side, this has an interesting effect on ambiance with some textures.
2. There's a memory leak in my get pixel function. This would normally not be an issue as raylib has its own get pixel, but this was written before that function existed and newer versions of raylib tend to break compatibility with older versions just for the sake of it, so it wasn't really realistic to migrate to 4.0. This memory leak will make the game crash, especially when using large maps.
3. The NPC thing going on is underdeveleppoed because lack of time. So it goes into walls and walks in straigh lines.
4. I was still pretty new to D when I started to work on this project, so it definitely underutilises D's features.
5. To meet deadlines, the implementation of a lot of things was rushed and need to be rewritten.
6. My raycasting algorithm is very inefficient. It would be very slow on a limited system. 
7. There's an out of bounds error somewhere in the code.

The engine is flawed because it was rushed to meet deadlines and this was made back when I was still very new to D and game engines in general. I have since learned a lot, so I plan to return to this project one day and redo it from scratch but better.
