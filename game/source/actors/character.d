module actors.character;

import game.math.vectors;
import actors.entity;
import raylib;

abstract class Character : Entity
{
    float angle = 0f;

    ubyte GetHealth() { return health; }
    void SetHealth(ubyte value) { health = value; }

    protected ubyte health;

    // La façon que les collisions fonctionnent est qu'on défait ce qui vient d'être fait
    void move(float speed, byte[][] map, float sign)
    {
        auto direction = angle.rotate;

        x += sign * direction.x * speed;
        y += sign * direction.y * speed;

        if (map[cast(int)y][cast(int)x] > 0)
        {
            x -= sign * direction.x * speed;
            y -= sign * direction.y * speed;
        }
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
    }

    void attack(Character character);
}
