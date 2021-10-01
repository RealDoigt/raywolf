import std.stdio;
import std.array;
import std.math;
import raylib;

struct Entity
{
    float x, y, angle;

    void move(float speed, byte[][] map, float sign)
    {
        x += sign * (angle.sin * speed);
        y += sign * (angle.cos * speed);

        if (map[cast(int)y][cast(int)x] > 0)
        {
            x -= sign * (angle.sin * speed);
            y -= sign * (angle.cos * speed);
        }
    }

    void strafe(float speed, byte[][] map, float sign)
    {
        x += sign * (angle.cos * speed);
        y += sign * (angle.sin * speed);

        if (map[cast(int)y][cast(int)x] > 0)
        {
            x -= sign * (angle.cos * speed);
            y -= sign * (angle.sin * speed);
        }
    }
}

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
    // TODO: https://youtu.be/HEb2akswCcw?t=1525
    // TODO: https://www.youtube.com/watch?v=NbSee-XM7WA

    SetTargetFPS(60);
    const int WINDOW_WIDTH = 640, WINDOW_HEIGHT = 480;
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Test");

    auto wallImage = LoadImage("img/bricks.png");
    ImageResize(&wallImage, 32, 32);

    // Génération d'une image qui va servir de gabarit sur lequel l'écran sera dessiné pixel par pixel
    auto buffer = GenImageColor(WINDOW_WIDTH, WINDOW_HEIGHT, Colors.WHITE);
    // Texture qui va prendre l'image plus haut et sera dessiné à partir de la vram pour plus de précision et rapidité
    auto screen = buffer.LoadTextureFromImage;

    Entity player = {2f, 1f, .0f};
    const int MAP_HEIGHT = 16, MAP_WIDTH = 16;

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

        // La façon que les collisions fonctionnent est qu'on défait ce qui vient d'être fait
        if (IsKeyDown(KeyboardKey.KEY_W)) player.move(movementSpeed, map, 1f);
        if (IsKeyDown(KeyboardKey.KEY_S)) player.move(movementSpeed, map, -1f);
        if (IsKeyDown(KeyboardKey.KEY_D)) player.strafe(movementSpeed, map, 1f);
        if (IsKeyDown(KeyboardKey.KEY_A)) player.strafe(movementSpeed, map, -1f);


        for(int x = 0; x < WINDOW_WIDTH; ++x)
        {
            // pour chaque colonne, calcule l'angle du rayon lancé
            float rayAngle = (player.angle - fieldOfView / 2f) + (cast(float)x / cast(float)WINDOW_WIDTH) * fieldOfView;
            float distanceToWall = 0f, eyeX = rayAngle.sin, eyeY = rayAngle.cos, sampleX = 0f;

            auto hitWall = false;

            while (!hitWall && distanceToWall < depth)
            {
                distanceToWall += .01f;

                auto testX = cast(int)(player.x + eyeX * distanceToWall);
                auto testY = cast(int)(player.y + eyeY * distanceToWall);

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
                        Vector2 testPoint = {(player.x + eyeX * distanceToWall), (player.y + eyeY * distanceToWall)};

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

            int ceiling = cast(int)(cast(float)(WINDOW_HEIGHT / 2f) - WINDOW_HEIGHT / (cast(float)distanceToWall));
            int floor = WINDOW_HEIGHT - ceiling;

            Color floorColor = {125, 125, 125, 255};
            Color ceilingColor = {200, 200, 200, 255};

            ubyte shade = 0;

            // calcul de la profondeur en relation avec la distance du mur; plus c'est loin, plus c'est foncé.
            for (float f = 15f; f > 0f; --f)
                if (distanceToWall > depth / f)
                    shade += 5;

            for (int y = 0; y < WINDOW_HEIGHT; ++y)
            {
                if (y <= ceiling) ImageDrawPixel(&buffer, x, y, ceilingColor);

                else if (y > ceiling && y <= floor)
                {
                    auto sampleY = cast(float)(y - ceiling) / cast(float)(floor - ceiling);
                    sampleY *= cast(float)wallImage.height;

                    auto wallColor = getPixel(&wallImage, cast(int)sampleX, cast(int)sampleY);
                    wallColor.a -= shade;

                    ImageDrawPixel(&buffer, x, y, wallColor);
                }

                else ImageDrawPixel(&buffer, x, y, floorColor);
            }
        }

        UpdateTexture(screen, buffer.data);
        DrawTexture(screen, 0, 0, Colors.WHITE);
        DrawFPS(0, 0);
    }

    wallImage.UnloadImage;
    buffer.UnloadImage;

    screen.UnloadTexture;
}
