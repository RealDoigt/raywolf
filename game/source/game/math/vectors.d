module game.math.vectors;
import std.math;
import raylib;

Vector2 rotate(float angle)
{
    Vector2 result = {angle.cos, -(angle.sin)};
    return result;
}

Vector2 normalize(Vector2 vector)
{
    auto length = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
    Vector2 result = {vector.x / length, vector.y / length};
    return result;
}

bool equalsInIndexSpace(Vector2 a, Vector2 b) { return cast(int)a.x == cast(int)b.x && cast(int)a.y == cast(int)b.y; }
