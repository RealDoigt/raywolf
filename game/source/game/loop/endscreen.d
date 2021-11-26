module game.loop.endscreen;
import std.string;
import raylib;

void displayEndLevelScreen(int killCount)
{
    auto shouldContinue = true;

    while (!WindowShouldClose() && shouldContinue)
    {
        ClearBackground(Colors.BLACK);
        BeginDrawing();

        scope(exit) EndDrawing();

        if (IsKeyReleased(KeyboardKey.KEY_C)) break;

        DrawText("MISSION RÉUSSIE!".ptr, 11, 12, 25, Colors.DARKGREEN);
        DrawText("MISSION RÉUSSIE!".ptr, 10, 10, 25, Colors.GREEN);

        DrawText("Monstres tués: %d".format(killCount).toStringz, 10, 45, 20, Colors.PURPLE);
        DrawText("Appuyez sur C pour continuer".ptr, 10, 60, 20, Colors.PURPLE);
    }
}
