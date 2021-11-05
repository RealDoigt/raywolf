module actors.player;

import std.algorithm.mutation;
import game.math.vectors;
import actors.observing;
import actors.character;
import raylib;

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

class Player : Character, IObserved
{

    private ubyte ammo;
    private byte[] keys;
    private IObserver[] observers;

    ubyte GetAmmo() { return ammo; }
    void SetAmmo(ubyte value) { ammo = value; } // TODO étendre la fonctionalité
    override void SetHealth (ubyte value) { health = value; } // TODO

    this(float x, float y, ubyte health, ubyte ammo)
    {
        this.x = x;
        this.y = y;
        this.health = health;
        this.ammo = ammo;
    }

    override void move(float speed, byte[][] map, float sign)
    {
        super.move(speed, map, sign);
        alert(map);
    }

    override void strafe(float speed, byte[][] map, float sign)
    {
        super.strafe(speed, map, sign);
        alert(map);
    }

    void addObserver(IObserver io)
    {
        observers ~= io;
    }

    void cleanDeadObservers()
    {
        for (int i = 0; i < observers.length; ++i)
            if (auto observer = cast(Character)observers[i])
                if (observer.GetHealth == 0)
                {
                    observers.remove(i);
                    --i;
                }
    }

    bool hasKey(ColorKey key)
    {
        foreach (ref i; keys)
            if (i == cast(ColorKey)key)
                return true;

        return false;
    }

    void addKey(byte id)
    {
        if (!hasKey(cast(ColorKey)id)) keys ~= id;
    }

    ColorKey[] getKeys()
    {
        ColorKey[] result;

        foreach (ref i; keys) result ~= cast(ColorKey)i;
        return result;
    }

    void alert(byte[][] map)
    {
        foreach (observer; observers) observer.react(toVector2(), map);
    }
}
