module game.math.vectors;
import game.math.consts;
import std.math;
import raylib;

Vector2 rotate(float angle)
{
    Vector2 result = {angle.cos, -(angle.sin)};
    return result;
}

Vector2 substract(Vector2 a, Vector2 b)
{
   Vector2 result = {a.x - b.x, a.y - b.y};
   return result;
}

Vector2 normalize(Vector2 vector)
{
    auto length = sqrt(pow(vector.x, 2) + pow(vector.y, 2));
    Vector2 result = {vector.x / length, vector.y / length};
    return result;
}

float getRotation(Vector2 vector)
{
   return atan2(-vector.y, vector.x);
}

// Cette fonction trouve le point t entre a et b selon une échelle de 0 à 1
// par exemple, l'interpolation linéaire de (0, 10, .2f) == 2
static float linearInterpolation(float a, float b, float t) {

  auto difference = fmod(b - a, TAU);
  auto distance = fmod(2.0f * difference, TAU) - difference;

  return a + distance * t;
}

bool equalsInIndexSpace(Vector2 a, Vector2 b) { return cast(int)a.x == cast(int)b.x && cast(int)a.y == cast(int)b.y; }

float getDistance(Vector2 a, Vector2 b) { return sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2)); }
