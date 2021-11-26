module actors.npc;

import game.math.vectors;
import game.math.consts;
import actors.character;
import actors.observing;
import actors.character;
import actors.observing;
import actors.visible;
import menu.settings;
import std.stdio;
import std.math;
import raylib;

enum Behaviours : ubyte
{
    Idle,
    Pursue,
    Return,
    Attack,
    Look,
    Flee,
}


class Computer : Character, IObserver, IVisible
{
    private Image* sprite;
    private float fieldOfView, depth, elapsedTime;
    private Vector2 lastPlayerPosition, originalPosition;
    private auto nextAction = Behaviours.Idle;
    private ubyte fearTolerance, initialHealth;
    private Sound* attackNoise;

    ubyte fearLevel = 0;
    auto range = 2f, speed = 2f;

    this(float x, float y, ubyte health, Image* sprite, float fov, float depth, ubyte fearTolerance, Sound* attack)
    {
        this.x = x;
        this.y = y;

        originalPosition.x = x;
        originalPosition.y = y;

        this.health = cast(ubyte)(health + difficulty);
        this.sprite = sprite;
        this.depth = depth;

        initialHealth = health;
        fieldOfView = fov;

        attackNoise = attack;
    }

    Image* GetSprite()
    {
        return sprite;
    }

    void react(Vector2 target, byte[][] map)
    {
        Vector2 vector = {target.x - x, target.y - y};

        auto eye = angle.rotate;
        auto targetAngle = atan2(eye.y, eye.x) - atan2(vector.y, vector.x);

        if (targetAngle < -raylib.PI) targetAngle += TAU;
        if (targetAngle > raylib.PI) targetAngle -= TAU;

        auto distance = getDistance(toVector2(), target);

        auto canHear = distance < depth && !hitsWall(toVector2(), target, map);
        auto canSee = targetAngle.abs < fieldOfView / 2f;
        auto canAttack = distance <= range;

        if (canSee && canHear && canAttack) nextAction = Behaviours.Attack;
        else if (canSee && canHear) nextAction = Behaviours.Pursue;
        else if (canHear) nextAction = Behaviours.Look;

        else if (!equalsInIndexSpace(toVector2(), originalPosition)) nextAction = Behaviours.Return;
        else nextAction = Behaviours.Idle;

        lastPlayerPosition = target;
    }

    private float getMovementSpeed(float elapsedTime) { return elapsedTime * speed; }
    private float getRotationSpeed(float elapsedTime) { return elapsedTime * speed / 2f; }

    // TODO futur lointain: utiliser A* ou quelque chose d'autre dans le genre
    private void moveTowards(Vector2 position, byte[][] map, float elapsedTime)
    {
       // ici l'interpolation est utilisée pour trouver l'angle selon la direction entre
       // la position du npc et du joueur. La direction est obtenue par la soustraction des
       // deux vecteurs. 4% est un chiffre magique qui dicte la rapidité du npc, donc en ce moment,
       // le monstre est à 4% de sa vitesse normale, ce qui aide aussi à faire un mouvement plus
       // fluide. TODO faire augmenter avec la difficulté.
       angle = linearInterpolation(angle, substract(position, toVector2()).getRotation, .04f);
       move(getMovementSpeed(elapsedTime), map, 1f);
    }

    // TODO futur lointain: faire en sorte que les npc peuvent s'attaquer entre eux
    void doSomething(byte[][] map, Character player, float elapsedTime)
    {
        switch (nextAction)
        {
            case Behaviours.Attack:

               // elapsedTime += GetFrameTime();

                //if (elapsedTime > .2f)
               // {
                    auto damage = player.GetHealth() - (2 + difficulty);
                    player.SetHealth(damage < 0 ? 0 : cast(ubyte)damage);
                    PlaySound(*attackNoise);
                   // elapsedTime = 0;
               // }

                break;

            case Behaviours.Pursue: 
                moveTowards(lastPlayerPosition, map, elapsedTime); break;

            case Behaviours.Look:

                auto difference = x - lastPlayerPosition.x;
                if (difference > 0f) angle -= getRotationSpeed(elapsedTime);
                else if (difference < 0f) angle += getRotationSpeed(elapsedTime);
                break;

            case Behaviours.Return: moveTowards(originalPosition, map, elapsedTime); break;

            default: return; // the action of doing nothing, currently used for unimplemented stuff;
        }
    }
}
