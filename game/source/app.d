import std.algorithm.mutation;
import game.loop.ceiling;
import game.math.vectors;
import game.math.images;
import game.math.consts;
import actors.observing;
import game.loop.walls;
import actors.visible;
import actors.entity;
import actors.player;
import actors.item;
import actors.npc;
import std.string;
import std.stdio;
import std.array;
import std.math;
import raylib;

void main()
{
    SetTargetFPS(60);
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Test");

    auto ceilingImage = LoadImage("img/sky.png");
    ImageResize(&ceilingImage, 128, 128);

    auto healthImage = getImage(cast(char*)"img/health.png");
    auto wallImage = getImage(cast(char*)"img/forest.png");
    auto ammoImage = getImage(cast(char*)"img/ammo.png");
    auto keyImage = getImage(cast(char*)"img/key.png");
    auto npcImage = getImage(cast(char*)"img/npc.png");

    // Génération d'une image qui va servir de gabarit sur lequel l'écran sera dessiné pixel par pixel
    auto buffer = GenImageColor(WINDOW_WIDTH, WINDOW_HEIGHT, Colors.WHITE);
    // Texture qui va prendre l'image plus haut et sera dessiné à partir de la vram pour plus de précision et rapidité
    auto screen = buffer.LoadTextureFromImage;

    auto player = new Player(2f, 1f, 20, 5);
    const int MAP_HEIGHT = 16, MAP_WIDTH = 16;

    byte[][] map =
    [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ];

    float fieldOfView = raylib.PI / 4f, depth = 16f;

    IVisible[] items =
    [
        new Key(1.5f, 3.5f, &keyImage, 12),
        new Heal(1.5f, 4.5f, &healthImage, 10),
        new Ammunition(3.5f, 1.5f, &ammoImage, 5),
        cast(IVisible)(new Computer(7.5f, 8.5f, 10, &npcImage, fieldOfView, 6f, 10)),

        new Key(0f, 0f, &keyImage, 10) // réparation temporaire en attendant que je trouve comment réparer correctement.
    ];

    player.addObserver(cast(IObserver)items[3]);

    int[] indicesToRemove;
    float[WINDOW_WIDTH] depthBuffer;

    while (!WindowShouldClose())
    {
        ClearBackground(Colors.BLACK);
        BeginDrawing();

        scope(exit) EndDrawing();

        auto elapsedTime = GetFrameTime();
        auto rotationSpeed = elapsedTime * 2f;
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

        // drawing sprites
        for (int i = 0; i < items.length - 1; ++i)
        {
            // est-ce que l'objet peut être vu? distance par rapport au joueur
            // le vecteur de la différence entre l'objet et le joueur est réutilisé plus tard,
            // c'est pourquoi c'est fait en deux étapes.
            Vector2 vector = {(cast(Entity)(items[i])).x - player.x, (cast(Entity)(items[i])).y - player.y};
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

                auto spriteImage = items[i].GetSprite();

                auto itemHeight = floor - ceiling;
                auto itemAspectRatio = cast(float)spriteImage.height / cast(float)spriteImage.width;
                auto itemWidth = itemHeight / itemAspectRatio;
                auto itemMiddle = (.5f * (itemAngle / halfView) + .5f) * cast(float)WINDOW_WIDTH;

                // dessiner sprite
                for (int x = 0; x < itemWidth; ++x)
                    for (int y = 0; y < itemHeight; ++y)
                    {
                        Vector2 sample = {cast(float)x / itemWidth, cast(float)y / itemHeight};

                        auto color = getPixel(spriteImage, cast(int)(sample.x * spriteImage.width), cast(int)(sample.y * spriteImage.height));

                        int itemColumn = cast(int)(itemMiddle + x - itemWidth / 2f);

                        if (color.a == 255 && itemColumn >= 0 && itemWidth < WINDOW_WIDTH && depthBuffer[itemColumn] >= distanceToPlayer)
                        {
                            ImageDrawPixel(&buffer, itemColumn, ceiling + y, color);
                            depthBuffer[itemColumn] = distanceToPlayer;
                        }
                    }
            }
        }

        // setting sprites for deletion.
        for (int i = cast(int)items.length - 1; i > -1; --i)
        {
            // on enlève l'item si le joueur le ramasse et on applique son effet.
            if (equalsInIndexSpace((cast(Entity)items[i]).toVector2(), player.toVector2()))
                if (auto item = cast(Item)items[i])
                {
                    indicesToRemove ~= i;
                    item.UseEffect(player);
                }

            if (auto computer = cast(Computer)items[i])
                if (!computer.GetHealth())
                    indicesToRemove ~= i;
        }

        foreach (i; indicesToRemove) items.remove(i);
        indicesToRemove.destroy;

        // making npcs do something.
        foreach (item; items)
            if (auto npc = cast(Computer)item)
                npc.doSomething(map, player, elapsedTime);

        UpdateTexture(screen, buffer.data);
        DrawTexture(screen, 0, 0, Colors.WHITE);

        // STATS
        DrawFPS(0, 0);
        DrawText(format("Vie: %d", player.GetHealth()).toStringz(), 0, 20, 16, Colors.WHITE);
        DrawText(format("Munitions: %d", player.GetAmmo()).toStringz(), 0, 35, 16, Colors.WHITE);
        DrawText(format("Clefs: %s", player.getKeys()).toStringz(), 0, 50, 16, Colors.WHITE);
    }

    screen.UnloadTexture;

    ceilingImage.UnloadImage;
    healthImage.UnloadImage;
    ammoImage.UnloadImage;
    wallImage.UnloadImage;
    keyImage.UnloadImage;
    buffer.UnloadImage;
}
