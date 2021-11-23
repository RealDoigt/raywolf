module actors.character;
import actors.entity;

class Character : Entity
{
    ubyte health, ammo;
    private bool isPlayer;

    this (float x, float y, ubyte hp)
    {
        this.x = x;
        this.y = y;
        health = hp;

        isPlayer = false;
    }

    this (float x, float y, ubyte hp, ubyte ammo)
    {
        this.x = x;
        this.y = y;
        health = hp;
        this.ammo = ammo;

        isPlayer = true;
    }

    bool IsPlayer()
    {
        return isPlayer;
    }
}

