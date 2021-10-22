import std.algorithm.mutation;
import game.loop.ceiling;
//import game.loop.sprites;
import game.math.vectors;
import game.math.images;
import game.math.consts;
import game.loop.walls;
import actors.player;
import std.string;
import std.stdio;
import std.array;
import std.math;
import raylib;

void main()
{
    SetTargetFPS(60);
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Test");

    auto wallImage = LoadImage("img/forest.png");
    ImageResize(&wallImage, 32, 32);

    auto ceilingImage = LoadImage("img/sky.png");
    ImageResize(&ceilingImage, 128, 128);

    auto spriteImage = LoadImage("img/circle.png");
    ImageResize(&spriteImage, 32, 32);

    // Génération d'une image qui va servir de gabarit sur lequel l'écran sera dessiné pixel par pixel
    auto buffer = GenImageColor(WINDOW_WIDTH, WINDOW_HEIGHT, Colors.WHITE);
    // Texture qui va prendre l'image plus haut et sera dessiné à partir de la vram pour plus de précision et rapidité
    auto screen = buffer.LoadTextureFromImage;

    Player player = new Player(2f, 1f, 20, 5);
    const int MAP_HEIGHT = 16, MAP_WIDTH = 16;

    ubyte points = 0;

    byte[][] map =
    [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1],
        [1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1],
        [1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1],
        [1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1],
        [1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1],
        [1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ];

    float fieldOfView = raylib.PI / 4f, depth = 16f;

    Vector2[] items =
    [
        {1.5f, 3.5f},
        {3.5f, 9.5f},
        {11.5f, 1.5f}
    ];

    int[] indicesToRemove;

    float[WINDOW_WIDTH] depthBuffer;

    while (!WindowShouldClose())
    {
        ClearBackground(Colors.BLACK);
        BeginDrawing();
        scope(exit) EndDrawing();

        auto elapsedTime = GetFrameTime();
        auto rotationSpeed = elapsedTime * .8f;
        auto movementSpeed = elapsedTime * 5f;

        // Contrôles
        // S'occupe des rotations
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) player.angle -= rotationSpeed;
        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) player.angle += rotationSpeed;

        if (IsKeyDown(KeyboardKey.KEY_W)) player.move(movementSpeed, map, 1f);
        if (IsKeyDown(KeyboardKey.KEY_S)) player.move(movementSpeed, map, -1f);
        if (IsKeyDown(KeyboardKey.KEY_D)) player.strafe(movementSpeed, map, 1f);
        if (IsKeyDown(KeyboardKey.KEY_A)) player.strafe(movementSpeed, map, -1f);

        auto halfView = fieldOfView / 2f;
        auto halfViewCos = halfView.cos;

        auto cameraDirection0 = rotate(player.angle - halfView);
        auto cameraDirection1 = rotate(player.angle + halfView);

        drawCeiling(cameraDirection0, cameraDirection1, halfViewCos, player, &ceilingImage, &buffer);
        drawWallsAndFloor(player, map, halfView, fieldOfView, MAP_WIDTH, MAP_HEIGHT, depth, depthBuffer, &wallImage, &buffer);

        //drawSprites(items, player, halfView, depth, depthBuffer, &spriteImage, &wallImage);

        // sprites
        for (int i = 0; i < items.length; ++i)
        {
            // est-ce que l'objet peut être vu? distance par rapport au joueur
            // le vecteur de la différence entre l'objet et le joueur est réutilisé plus tard,
            // c'est pourquoi c'est fait en deux étapes.
            Vector2 vector = {items[i].x - player.x, items[i].y - player.y};
            auto distanceToPlayer = sqrt(pow(vector.x, 2) + pow(vector.y, 2));

            auto eye = rotate(player.angle);
            auto itemAngle = atan2(eye.y, eye.x) - atan2(vector.y, vector.x);

            if (itemAngle < -raylib.PI) itemAngle += TAU;
            if (itemAngle > raylib.PI) itemAngle -= TAU;

            auto playerCanSee = itemAngle.abs < halfView;

            if (playerCanSee && distanceToPlayer >= 0.5f && distanceToPlayer < depth)
            {
                int height = cast(int)(WINDOW_HEIGHT/(cast(float)distanceToPlayer)) >> 1;
                int ceiling = -height + WINDOW_HALF_HEIGHT;
                int floor = height + WINDOW_HALF_HEIGHT;

                auto itemHeight = floor - ceiling;
                auto itemAspectRatio = cast(float)spriteImage.height / cast(float)spriteImage.width;
                auto itemWidth = itemHeight / itemAspectRatio;
                auto itemMiddle = (.5f * (itemAngle / halfView) + .5f) * cast(float)WINDOW_WIDTH;

                // dessiner sprite
                for (int x = 0; x < itemWidth; ++x)
                    for (int y = 0; y < itemHeight; ++y)
                    {
                        Vector2 sample = {cast(float)x / itemWidth, cast(float)y / itemHeight};

                        auto color = getPixel(&spriteImage, cast(int)(sample.x * spriteImage.width), cast(int)(sample.y * spriteImage.height));

                        int itemColumn = cast(int)(itemMiddle + x - itemWidth / 2f);

                        if (itemColumn >= 0 && itemWidth < WINDOW_WIDTH && depthBuffer[itemColumn] >= distanceToPlayer)
                        {
                            ImageDrawPixel(&buffer, itemColumn, ceiling + y, color);
                            depthBuffer[itemColumn] = distanceToPlayer;
                        }
                    }
            }
        }

        // items. En ce moment chaque sprite est traité comme un objet, mais ça changera à l'avenir
        for (int i = cast(int)items.length - 1; i > -1; --i)
        {
            // on enlève l'item si le joueur le ramasse et on applique son effet.
            // Pour l'instant on fait juste ajouter des points, mais il y aura d'autres effets
            if (equalsInIndexSpace(items[i], player.toVector2()))
            {
                ++points;
                indicesToRemove ~= i;
            }
        }

        foreach (i; indicesToRemove) items.remove(i);
        indicesToRemove.destroy;

        UpdateTexture(screen, buffer.data);
        DrawTexture(screen, 0, 0, Colors.WHITE);

        DrawFPS(0, 0);
        DrawText(format("points: %d", points).toStringz(), 0, 20, 16, Colors.WHITE);
    }

    ceilingImage.UnloadImage;
    spriteImage.UnloadImage;
    wallImage.UnloadImage;
    buffer.UnloadImage;

    screen.UnloadTexture;
}
