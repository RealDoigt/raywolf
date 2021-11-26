module game.loop.walltexture;

import game.loop.doorinfo;
import game.math.images;
import std.stdio;

import raylib;

// Cette fonction retourne le bon pixel selon la valeur sur laquelle pointe l'index dans le tableau
Color fetchPixel(byte value, Image* image, float sampleX, float sampleY)
{

    auto pixel = getPixel(image, cast(int)sampleX, cast(int)sampleY);
    if (!(pixel.r > pixel.b + 80u && pixel.r > pixel.g + 80u) || value < 10 || value > 19) return pixel;

    switch (cast(DoorType)value)
    {
        case DoorType.Red: return Colors.RED;
        case DoorType.Green: return Colors.GREEN;
        case DoorType.Blue: return Colors.BLUE;
        case DoorType.Yellow: return Colors.YELLOW;
        case DoorType.Purple: return Colors.PURPLE;
        case DoorType.Teal: return *(new Color(0, 180, 150, 255));
        case DoorType.Orange: return Colors.ORANGE;
        case DoorType.Lime: return Colors.LIME;
        case DoorType.Magenta: return Colors.MAGENTA;
        default: return *(new Color(0, 150, 180, 255));
    }
}

// Cette fonction retourne un index sur la bonne image selon la valeur sur laquelle pointe l'index dans le tableau
string fetchImage(byte value)
{
    if (value > 19) return "door";
    if (value > 9) return "locked door";

    return "wall";
}
