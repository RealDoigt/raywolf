module game.loop.walls;

import game.loop.doorinfo;
import game.math.vectors;
import game.math.consts;
import game.math.images;
import actors.player;
import std.math;
import raylib;

void drawWallsAndFloor(Player player, byte[][] map, float halfView, float fieldOfView, int mapWidth, int mapHeight,  float depth, ref float[WINDOW_WIDTH] depthBuffer, Image* wallImage, Image* buffer, DoorInfo doorInfo)
{
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
            if (testX < 0 || testX >= mapWidth || testY < 0 || testY >= mapHeight)
            {
                hitWall = true; // ça fait comme si la profondeur était au max
                distanceToWall = depth;
            }

            else
            {
                // Test si le rayon touche un mur
                if (map[testY][testX] > 0)
                {
                    hitWall = true;
                    doorInfo.add(distanceToWall, testX, testY, map[testY][testX]);

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

                auto wallColor = getPixel(wallImage, cast(int)sampleX, cast(int)sampleY);
                ImageDrawPixel(buffer, x, y, wallColor);
            }

            else if (y >= floor) ImageDrawPixel(buffer, x, y, floorColor);
        }
    }
}
