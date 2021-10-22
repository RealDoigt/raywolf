module actors.entity;
import raylib;

abstract class Entity
{
    float x, y;

    Vector2 toVector2()
    {
        Vector2 result = {x, y};
        return result;
    }
}
