module game.math.images;
import raylib;

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
