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

        auto resultX = x + sign * direction.x * speed;
        auto resultY = y + sign * direction.y * speed;
        int castX = cast(int)resultX, castY = cast(int)resultY;

        // breaking it down for readability
        if (castX >= map[0].length || castX < 0) return;
        if (castY >= map.length || castY < 0) return;
        if (map[castY][castX] > 0) return;

        x = resultX;
        y = resultY;
    }

    void strafe(float speed, byte[][] map, float sign)
    {
        auto direction = angle.rotate;

        auto resultX = x + sign * direction.y * speed;
        auto resultY = y - sign * direction.x * speed;
        int castX = cast(int)resultX, castY = cast(int)resultY;

        // breaking it down for readability
        if (castX >= map[0].length || castX < 0) return;
        if (castY >= map.length || castY < 0) return;
        if (map[castY][castX] > 0) return;

        x = resultX;
        y = resultY;
    }
}
