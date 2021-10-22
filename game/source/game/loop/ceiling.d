module game.loop.ceiling;
import game.math.vectors;
import game.math.consts;
import game.math.images;
import actors.player;
import raylib;

void drawCeiling(Vector2 cameraDirection0, Vector2 cameraDirection1, float halfViewCos, Player player, Image* ceilingImage, Image* buffer)
{
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

            int textureXIndex = cast(int)(ceilingImage.width * (floorPosition.x - cellX)) & (ceilingImage.width - 1);
            int textureYIndex = cast(int)(ceilingImage.height * (floorPosition.y - cellY)) & (ceilingImage.height - 1);

            floorPosition.x += floorStep.x;
            floorPosition.y += floorStep.y;

            Color ceilingColor;
            ceilingColor = getPixel(ceilingImage, textureXIndex, textureYIndex);
            ImageDrawPixel(buffer, x, WINDOW_HEIGHT - y - 1, ceilingColor);
        }
    }
}
