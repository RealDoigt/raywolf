module actors.item;

import actors.visible;
import actors.entity;
import actors.player;
import actors.character;
import raylib;

abstract class Item : Entity, IVisible
{
    private Image* sprite;

    this(float x, float y, Image* sprite)
    {
        this.x = x;
        this.y = y;
        this.sprite = sprite;
    }

    Image* GetSprite()
    {
        return sprite;
    }

    void UseEffect(Player player);
}

class Key : Item
{
    private byte doorId;

    this(float x, float y, Image* sprite, byte doorId)
    {
        super(x, y, sprite);
        this.doorId = doorId;
    }

    override void UseEffect(Player player) { player.addKey(doorId); }
}

class Heal : Item
{
    // puissance de la médcine
    private ubyte effect;

    this(float x, float y, Image* sprite, ubyte effect)
    {
        super(x, y, sprite);
        this.effect = effect;
    }

    override void UseEffect(Player player) { player.SetHealth(cast(ubyte)(player.GetHealth() + effect <= 255 ? player.GetHealth() + effect : 255)); }
}

class Ammunition : Item
{
    // nombre de munitions
    private ubyte ammo;

    this(float x, float y, Image* sprite, ubyte ammo)
    {
        super(x, y, sprite);
        this.ammo = ammo;
    }

    override void UseEffect(Player player) { player.SetAmmo(cast(ubyte)(player.GetAmmo() + ammo <= 255 ? player.GetAmmo() + ammo : 255)); }
}
