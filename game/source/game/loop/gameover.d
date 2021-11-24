module game.loop.gameover;

import game.math.images;
import raylib;

bool endGame(Image* buffer, Texture* screen)
{
    auto bg = GenImageColor(buffer.width, buffer.height, Colors.BLACK);
    UpdateTexture(*screen, bg.data);
    bg.UnloadImage;

    while (!WindowShouldClose)
    {
        BeginDrawing();
        scope(exit) EndDrawing();

        if (IsKeyReleased(KeyboardKey.KEY_R)) return true;

        DrawTexture(*screen, 0, 0, Colors.WHITE);

        DrawText("GAME OVER", 14, 13, 100, Colors.MAROON);
        DrawText("GAME OVER", 10, 10, 100, Colors.RED);

        DrawText("Appuyez sur R pour recommencer", 10, 100, 25, Colors.GREEN);
    }

    return false;
}
