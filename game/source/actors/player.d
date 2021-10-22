module actors.player;

import game.math.vectors;
import actors.observing;
import actors.character;
import raylib;

class Player : Character, IObserved
{

    private ubyte ammo;
    private byte[] inventory;
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
        alert();
    }

    void strafe(float speed, byte[][] map, float sign)
    {
        auto direction = angle.rotate;

        x += sign * direction.y * speed;
        y -= sign * direction.x * speed;

        if (map[cast(int)y][cast(int)x] > 0)
        {
            x -= sign * direction.y * speed;
            y += sign * direction.x * speed;
        }

        alert();
    }

    override void attack(Character character)
    {
        // TODO
    }

    void addKey(byte id)
    {
        foreach (ref i; inventory)
            if (i == id)
                return;

        inventory ~= id;
    }

    void openDoor()
    {
        // TODO
    }

    void alert()
    {
        // TODO
    }
}
