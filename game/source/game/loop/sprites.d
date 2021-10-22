module game.loop.sprites;

import game.math.vectors;
import game.math.images;
import game.math.consts;
import actors.player;
import std.math;
import std.stdio;
import raylib;

void drawSprites(Vector2[] items, Player player, float halfView, float depth, ref float[WINDOW_WIDTH] depthBuffer, Image* spriteImage, Image* buffer)
{
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

                    auto color = getPixel(spriteImage, cast(int)(sample.x * spriteImage.width), cast(int)(sample.y * spriteImage.height));

                    int itemColumn = cast(int)(itemMiddle + x - itemWidth / 2f);

                    if (itemColumn >= 0 && itemWidth < WINDOW_WIDTH && depthBuffer[itemColumn] >= distanceToPlayer)
                    {
                        ImageDrawPixel(buffer, itemColumn, ceiling + y, color);
                        depthBuffer[itemColumn] = distanceToPlayer;
                    }
                }
        }
    }
}
