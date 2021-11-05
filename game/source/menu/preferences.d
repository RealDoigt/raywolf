module menu.preferences;
import game.math.consts;
import menu.settings;
import raylib;

enum EASY_POS      = 30;
enum MEDIUM_POS    = 60;
enum HARD_POS      = 90;
enum VERY_HARD_POS = 120;
enum START_POS     = 150;
enum INCREMENT_POS = 30;

void drawPreferencesMenu()
{
    auto fourthWidth = WINDOW_WIDTH >> 2;

    while (!WindowShouldClose)
    {
        ClearBackground(Colors.BLACK);
        BeginDrawing();

        scope(exit) EndDrawing();

        DrawText("Facile", fourthWidth, EASY_POS, 30, Colors.WHITE);
        DrawText("Normal", fourthWidth, MEDIUM_POS, 30, Colors.WHITE);
        DrawText("Difficile", fourthWidth, HARD_POS, 30, Colors.WHITE);
        DrawText("Impossible", fourthWidth, VERY_HARD_POS, 30, Colors.WHITE);

        DrawText("Commencer", fourthWidth, START_POS, 25, Colors.GREEN);

        if (IsMouseButtonReleased(0)) // left mouse button
        {
            auto mouseY = GetMouseY();

            if (mouseY >= EASY_POS && mouseY < EASY_POS + INCREMENT_POS)
                difficulty = 0;

            else if (mouseY >= MEDIUM_POS && mouseY < MEDIUM_POS + INCREMENT_POS)
                difficulty = 1;

            else if (mouseY >= HARD_POS && mouseY < HARD_POS + INCREMENT_POS)
                difficulty = 2;

            else if (mouseY >= VERY_HARD_POS && mouseY < VERY_HARD_POS + INCREMENT_POS)
                difficulty = 3;

            else if (mouseY >= START_POS && mouseY < START_POS + INCREMENT_POS)
                return;
        }

        DrawLine(fourthWidth, (difficulty + 1) * INCREMENT_POS + 25, fourthWidth << 1, (difficulty + 1) * INCREMENT_POS + 25, Colors.GREEN);
    }
}
