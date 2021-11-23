module game.loop.gameover;

import game.math.images;
import raylib;

void showGameOver(Image* buffer, Texture* screen)
{
    auto bg = GenImageColor(buffer.width, buffer.height, Colors.BLACK);
    UpdateTexture(*screen, bg.data);
    bg.UnloadImage;

    while (!WindowShouldClose)
    {
        BeginDrawing();
        scope(exit) EndDrawing();

        DrawTexture(*screen, 0, 0, Colors.WHITE);

        DrawText(cast(char*)"GAME OVER", 14, 13, 100, Colors.MAROON);
        DrawText(cast(char*)"GAME OVER", 10, 10, 100, Colors.RED);
    }
}
