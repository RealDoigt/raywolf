import std.algorithm.mutation;
import std.string;
import std.stdio;
import std.array;
import std.math;
import raylib;

struct Entity
{
    float x, y, angle;

    // La façon que les collisions fonctionnent est qu'on défait ce qui vient d'être fait
    void move(float speed, byte[][] map, float sign)
    {
        auto direction = angle.rotate;

        x += sign * direction.x * speed;
        y += sign * direction.y * speed;

        if (map[cast(int)y][cast(int)x] > 0)
        {
            x -= sign * direction.x * speed;
            y -= sign * direction.y * speed;
        }
    }

    void strafe(float speed, byte[][] map, float sign)
    {
        auto direction = angle.rotate;

        x += sign * direction.y * speed;
        y -= sign * direction.x * speed;

        if (map[cast(int)y][cast(int)x] > 0)
        {
            x -= sign * direction.y * speed;
            y += sign * direction.x * speed;
        }
    }

    Vector2 toVector2()
    {
        Vector2 result = {x, y};
        return result;
    }
}

Vector2 rotate(float angle)
{
    Vector2 result = {angle.cos, -(angle.sin)};
    return result;
}

Vector2 normalize(Vector2 vector)
{
    auto length = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
    Vector2 result = {vector.x / length, vector.y / length};
    return result;
}

bool equalsInIndexSpace(Vector2 a, Vector2 b) { return cast(int)a.x == cast(int)b.x && cast(int)a.y == cast(int)b.y; }

int getBPPMultiplier(Image* img)
{
    switch (img.format)
    {
        case 2, 3, 5, 6: return 2;
        case 4: return 3;
        case 7, 8: return 4;
        case 9: return 12;
        case 10: return 16;
        default: return 1;
    }
}

Color getPixel(Image* img, int x, int y)
{
    if (x < 0 || x > img.width || y < 0 || y > img.height) return Colors.BLACK;

    auto data = cast(ubyte*)img.data;
    auto pixel = data + (y * img.width + x) * getBPPMultiplier(img);
    auto color = GetPixelColor(pixel, img.format);

    return color;
}

void main()
{
    const float TAU = raylib.PI * 2f;

    SetTargetFPS(60);
    const int WINDOW_WIDTH = 640, WINDOW_HEIGHT = 480, WINDOW_HALF_HEIGHT = WINDOW_HEIGHT >> 1;
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

    Entity player = {2f, 1f, .0f};
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

        // plafond
        for (int y = WINDOW_HALF_HEIGHT + 1; y < WINDOW_HEIGHT; ++y)
        {

            Vector2 rayDirection0 = {cameraDirection0.x / halfViewCos, cameraDirection0.y / halfViewCos};
            Vector2 rayDirection1 = {cameraDirection1.x / halfViewCos, cameraDirection1.y / halfViewCos};

            rayDirection0 = rayDirection0.normalize;
            rayDirection1 = rayDirection1.normalize;

            int positionMiddleY = y - WINDOW_HALF_HEIGHT;
            auto positionZ = .5f * cast(float)WINDOW_HEIGHT;
            auto rowDistance = positionZ / positionMiddleY;

            Vector2 floorStep =
            {
                rowDistance * (rayDirection1.x - rayDirection0.x) / WINDOW_WIDTH,
                rowDistance * (rayDirection1.y - rayDirection0.y) / WINDOW_WIDTH
            };

            Vector2 floorPosition = {player.x + rowDistance * rayDirection0.x, player.y + rowDistance * rayDirection0.y};

            for (int x = 0; x < WINDOW_WIDTH; ++x)
            {
                int cellX = cast(int)floorPosition.x;
                int cellY = cast(int)floorPosition.y;

                int textureXIndex = cast(int)(wallImage.width * (floorPosition.x - cellX)) & (wallImage.width - 1);
                int textureYIndex = cast(int)(wallImage.height * (floorPosition.y - cellY)) & (wallImage.height - 1);

                floorPosition.x += floorStep.x;
                floorPosition.y += floorStep.y;

                Color floorColor, ceilingColor;

                // devront être changés pour avoir leurs propres textures.
                //floorColor = getPixel(&floorImage, textureXIndex, textureYIndex);
                ceilingColor = getPixel(&ceilingImage, textureXIndex, textureYIndex);

                //ImageDrawPixel(&buffer, x, y, floorColor);
                ImageDrawPixel(&buffer, x, WINDOW_HEIGHT - y - 1, ceilingColor);
            }
        }

        // murs et plancher
        for(int x = 0; x < WINDOW_WIDTH; ++x)
        {
            // pour chaque colonne, calcule l'angle du rayon lancé
            float rayAngle = (player.angle - halfView) + (cast(float)x / cast(float)WINDOW_WIDTH) * fieldOfView;
            float distanceToWall = 0f, sampleX = 0f;

            auto eye = rayAngle.rotate;
            auto hitWall = false;

            while (!hitWall && distanceToWall < depth)
            {
                distanceToWall += .01f;

                auto testX = cast(int)(player.x + eye.x * distanceToWall);
                auto testY = cast(int)(player.y + eye.y * distanceToWall);

                // test si le rayon est rendu à l'extérieur de la carte
                if (testX < 0 || testX >= MAP_WIDTH || testY < 0 || testY >= MAP_HEIGHT)
                {
                    hitWall = true; // ça fait comme si la profondeur était au max
                    distanceToWall = depth;
                }

                else
                {
                    // Test si le rayon touche un mur
                    if (map[testY][testX] == 1)
                    {
                        hitWall = true;

                        // Détermine où le rayon touche le mur
                        auto blockMidX = cast(float)testX + .5f, blockMidY = cast(float)testY + .5f;
                        Vector2 testPoint = {(player.x + eye.x * distanceToWall), (player.y + eye.y * distanceToWall)};

                        auto testAngle = atan2(testPoint.y - blockMidY, testPoint.x - blockMidX);

                        // quatre côtés, donc quatres angles à tester
                        if (testAngle >= -raylib.PI * .25f && testAngle < raylib.PI * .25f)
                            sampleX  = testPoint.y - cast(float)testY;

                        if (testAngle >= raylib.PI * .25f && testAngle < raylib.PI * .75f)
                            sampleX  = testPoint.x - cast(float)testX;

                        if (testAngle < -raylib.PI * .25f && testAngle >= -raylib.PI * .75f)
                            sampleX  = testPoint.x - cast(float)testX;

                        if (testAngle >= raylib.PI * .75f || testAngle < -raylib.PI * .75f)
                            sampleX  = testPoint.y - cast(float)testY;

                        sampleX *= cast(float)wallImage.width;
                    }
                }
            }

            int height = cast(int)(WINDOW_HEIGHT/(cast(float)distanceToWall)) >> 1;
            int ceiling = -height + WINDOW_HALF_HEIGHT;
            int floor = height + WINDOW_HALF_HEIGHT;

            // maj buffer de profondeur
            depthBuffer[x] = distanceToWall;

            Color floorColor = {4, 0, 8, 255};

            for (int y = 0; y < WINDOW_HEIGHT; ++y)
            {
                //if (y <= ceiling) ImageDrawPixel(&buffer, x, y, Colors.RAYWHITE);

                if (y > ceiling && y < floor)
                {
                    auto sampleY = cast(float)(y - ceiling) / cast(float)(floor - ceiling);
                    sampleY *= cast(float)wallImage.height;

                    auto wallColor = getPixel(&wallImage, cast(int)sampleX, cast(int)sampleY);
                    ImageDrawPixel(&buffer, x, y, wallColor);
                }

                else if (y >= floor) ImageDrawPixel(&buffer, x, y, floorColor);
            }
        }

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

                        auto color = getPixel(&spriteImage, cast(int)sample.x, cast(int)sample.y);

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
