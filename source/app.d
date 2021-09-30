import std.container;
import std.stdio;
import std.math;
import raylib;

bool isLower(Vector2* left, Vector2* right) { return left.x < right.y;}

void sort(DList!Vector2* list)
{

}

void main()
{

    const int WINDOW_WIDTH = 640, WINDOW_HEIGHT = 480;
    SetTargetFPS(60);
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Test");

    float playerX = 2.0f, playerY = 1.0f, playerAngle = .0f;
    const int MAP_HEIGHT = 16, MAP_WIDTH = 16;

    float fieldOfView = 3.1416f / 4f, depth = 16f;

    byte[16][16] map =
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
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) playerAngle -= rotationSpeed;
        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) playerAngle += rotationSpeed;

        // La façon que les collisions fonctionnent est qu'on défait ce qui vient d'être fait
        if (IsKeyDown(KeyboardKey.KEY_W))
        {
            playerX += sin(playerAngle) * movementSpeed;
            playerY += cos(playerAngle) * movementSpeed;

            if (map[cast(int)playerY][cast(int)playerX] > 0)
            {
                playerX -= sin(playerAngle) * movementSpeed;
                playerY -= cos(playerAngle) * movementSpeed;
            }
        }

        if (IsKeyDown(KeyboardKey.KEY_S))
        {
            playerX -= sin(playerAngle) * movementSpeed;
            playerY -= cos(playerAngle) * movementSpeed;

            if (map[cast(int)playerY][cast(int)playerX] > 0)
            {
                playerX += sin(playerAngle) * movementSpeed;
                playerY += cos(playerAngle) * movementSpeed;
            }
        }

        if (IsKeyDown(KeyboardKey.KEY_A))
        {
            playerX -= cos(playerAngle) * movementSpeed;
            playerY -= sin(playerAngle) * movementSpeed;

            if (map[cast(int)playerY][cast(int)playerX] > 0)
            {
                playerX += cos(playerAngle) * movementSpeed;
                playerY += sin(playerAngle) * movementSpeed;
            }
        }

        if (IsKeyDown(KeyboardKey.KEY_D))
        {
            playerX += cos(playerAngle) * movementSpeed;
            playerY += sin(playerAngle) * movementSpeed;

            if (map[cast(int)playerY][cast(int)playerX] > 0)
            {
                playerX -= cos(playerAngle) * movementSpeed;
                playerY -= sin(playerAngle) * movementSpeed;
            }
        }


        for(int x = 0; x < WINDOW_WIDTH; ++x)
        {
            // pour chaque colonne, calcule l'angle du rayon lancé
            float rayAngle = (playerAngle - fieldOfView / 2f) + (cast(float)x / cast(float)WINDOW_WIDTH) * fieldOfView;

            float distanceToWall = 0f, eyeX = sin(rayAngle), eyeY = cos(rayAngle);

            auto hitWall = false, hitCellEdge = false;

            while (!hitWall && distanceToWall < depth)
            {
                distanceToWall += .1f;

                auto testX = cast(int)(playerX + eyeX * distanceToWall);
                auto testY = cast(int)(playerY + eyeY * distanceToWall);

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

                        auto points = DList!Vector2(); // distance, point (angle entre les vecteurs)

                        for (int xx = 0; xx < 2; ++xx)
                            for (int yy = 0; yy < 2; ++yy)
                            {
                                Vector2 vec = {cast(float)testX + xx - playerX, cast(float)testY + yy - playerY};

                                float magnitude = sqrt(vec.x * vec.x + vec.y * vec.y);
                                float dot = (eyeX * vec.x / magnitude) + (eyeY * vec.y / magnitude);

                                Vector2 point = {magnitude, dot};
                                points.insertBack(point);
                            }

                        // classer les paires du plus proche au plus loin

                    }
                }
            }

            int ceiling = cast(int)(cast(float)(WINDOW_HEIGHT / 2f) - WINDOW_HEIGHT / (cast(float)distanceToWall));
            int floor = WINDOW_HEIGHT - ceiling;

            ubyte shade = 0;
            Color wallColor = {0, 255, 0, 255};
            Color floorColor = {125, 125, 125, 255};
            Color ceilingColor = {200, 200, 200, 255};

            // calcul de la profondeur en relation avec la distance du mur; plus c'est loind, plus c'est foncé.
            for (float f = 15f; f > 0f; --f)
                if (distanceToWall > depth / f)
                    shade += 5;

            // changement de l'ombrage en diminuant l'opacité
            wallColor.a -= shade;

            for (int y = 0; y < WINDOW_HEIGHT; ++y)
            {
                auto distanceTopBottom = 1f - ((cast(float)y - WINDOW_HEIGHT / 2f) / (cast(float)WINDOW_HEIGHT / 2f));

                if (distanceTopBottom < .2f) shade = 0;
                else if (distanceTopBottom < .4f) shade = 20;
                else if (distanceTopBottom < .6f) shade = 50;
                else if (distanceTopBottom < .8f) shade = 80;
                else if (distanceTopBottom < 1f) shade = 120;
                else shade = 255;

                //floorColor.a -= shade;
                ceilingColor.a -= shade;

                if (y <= ceiling) DrawPixel(x, y, ceilingColor);
                else if (y > ceiling && y <= floor) DrawPixel(x, y, wallColor);
                else DrawPixel(x, y, floorColor);
            }
        }
        DrawFPS(0, 0);

    }
}
