module actors.npc;

import game.math.vectors;
import actors.character;
import actors.observing;
import actors.visible;
import actors.character;
import actors.observing;
import raylib;

class Computer : Character, IObserver, IVisible
{
    private Image* sprite;

    this(float x, float y, ubyte health, Image* sprite)
    {
        this.x = x;
        this.y = y;
        this.health = health;
        this.sprite = sprite;
    }

    Image* GetSprite()
    {
        return sprite;
    }

    void react(Vector2 position)
    {
        // TODO
    }

    void turn()
    {
        // TODO
    }

    override void attack(Character character)
    {
        // TODO
    }
}
