module game.loop.minimap;
import game.math.images;
import actors.player;
import raylib;

enum SQUARE_SIZE = 3; // how big the exploration size is

void updateMiniMap(byte[][] map, Image* miniMap, Player player)
{
    for (int squareY = cast(int)(player.y - 1f), i = 0; i < SQUARE_SIZE && squareY < miniMap.height; ++squareY, ++i)
        for (int squareX = cast(int)(player.x - 1f), j = 0; j < SQUARE_SIZE && squareX < miniMap.width; ++squareX, ++j)
        {
            auto color = Colors.BLANK;

            if (squareX == cast(int)player.x && squareY == cast(int)player.y) color = Colors.GREEN;
            else if (map[squareY][squareX] > 0) color = Colors.WHITE;

            ImageDrawPixel(miniMap, squareX, squareY, color);
        }
}

void drawMiniMap(Image* buffer, Image* miniMap)
{
    auto bigMiniMap = ImageCopy(*miniMap);
    ImageResizeNN(&bigMiniMap, miniMap.width << 2, miniMap.height << 2);

    // TODO redo by taking into account window size and have the map be dynamic
    for (int y = 0; y < bigMiniMap.height && y < buffer.height; ++y)
        for (int x = 0; x < bigMiniMap.width && x < buffer.width; ++x)
        {
            auto color = getPixel(&bigMiniMap, x, y);
            if (color != Colors.BLANK) ImageDrawPixel(buffer, x, y + 150, color);
        }

    bigMiniMap.UnloadImage;
}
