module map.create;
import raylib;
import images;

byte colorToByte(Color color)
{
    // TODO other colors
    if (color == Colors.BLACK) return 0; // plancher
    if (color == Colors.WHITE) return 1; // mur

    // locked doors
    if (color == Colors.RED) return 10;
    if (color == Colors.GREEN) return 11;
    if (color == Colors.BLUE) return 12;
    if (color == Colors.YELLOW) return 13;

    // end of level
    if (color.r == 255 && color.g == 255 && color.b == 132) return 30;

    return 20; // unlocked door
}

byte[][] imageToByteMap(Image* image)
{
    auto map = new byte[][](image.height, image.width);

    for (int y = 0; y < image.height; ++y)
        for (int x = 0; x < image.width; ++x)
            map[y][x] = getPixel(image, x, y).colorToByte;

    return map;
}