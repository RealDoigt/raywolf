module actors.item;
import actors.entity;
enum ColorKey : byte
{
    Red     = 10,
    Green   = 11,
    Blue    = 12,
    Yellow  = 13,
    Purple  = 14,
    Teal    = 15,
    Orange  = 16,
    Lime    = 17,
    Magenta = 18,
    Cyan    = 19,
    Invalid =  0
}

class Item : Entity
{
    private bool isHealth;
    ubyte points; // can represent either hp or ammo

    this (float x, float y, ubyte points)
    {
        this.x = x;
        this.y = y;
        isHealth = true;
        this.points = points;
    }

    this (float x, float y, ubyte points, bool isHealth)
    {
        this.x = x;
        this.y = y;
        this.points = points;
        this.isHealth = isHealth;
    }

    bool IsHealth()
    {
        return isHealth;
    }
}

class Key : Entity
{
    ColorKey color;

    this (float x, float y, ColorKey key)
    {
        this.x = x;
        this.y = y;
        color = key;
    }
}
