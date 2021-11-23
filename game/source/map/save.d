module map.save;

import actors.character;
import actors.visible;
import actors.entity;
import actors.player;
import actors.item;
import actors.npc;
import std.format;
import std.array;
import std.file;
import raylib;

// cette fonction sert uniquement à prévenir un blocage dans une situation où le joueur ramasse une
// clef sans l'utiliser. Si le joueur sauvegarde, toutes les portes qu'il aurait eut le pouvoir
// d'ouvrir sont ouvertes.
byte[][] removeLockedDoors(Player player, ref byte[][] map)
{
    auto newMap = new byte[][](map.length, map[0].length);

    for (int y = 0, i = 2; y < newMap.length; ++y)
        for (int x = 0; x < newMap[0].length; ++x, ++i)
        {
            if (newMap[y][x] > 9 && newMap[y][x] < 20 && player.hasKey(cast(ColorKey)newMap[y][x]))
                newMap[y][x] = 0;

            else newMap[y][x] = map[y][x];
        }

    return newMap;
}

void saveMap(string file, Player player, ref byte[][] map)
{
    auto newMap = removeLockedDoors(player, map);

    // on combine la largeur et hauteur, puis on ajoute ces infos-là même dans le buffer.
    auto buffer = new ubyte[](newMap.length * newMap[0].length + 2);
    buffer[0] = cast(ubyte)newMap[0].length; // largeur
    buffer[1] = cast(ubyte)newMap.length; // hauteur

    for (int y = 0, i = 2; y < newMap.length; ++y)
        for (int x = 0; x < newMap[0].length; ++x, ++i)
            buffer[i] = cast(ubyte)newMap[y][x];

    write(file, buffer);
}

void saveMapEntities(char* file, Player player, IVisible[] entities)
{
    auto buffer = new string[](entities.length + 1);

    buffer[0] = format("%f %f %d %d;", player.x, player.y, player.GetHealth(), player.GetAmmo());

    for (int i = 1; i < entities.length; ++i)
    {
        auto entity = cast(Entity)entities[i];
        buffer[i] = format("%f %f ", entity.x, entity.y);

        if (auto key = cast(Key)entity) buffer[i] ~= format("%d k;", cast(ColorKey)key.getKeyId());

        else if (auto heal = cast(Heal)entity) buffer[i] ~= format("%d %s i;", heal.getEffect(), true);

        else if (auto ammo = cast(Ammunition)entity) buffer[i] ~= format("%d %s i;", ammo.getQuantity(), false);

        else
        {
            auto npc = cast(Computer)entity;
            buffer[i] ~= format("%d c;", npc.GetHealth());
        }
    }

    SaveFileText(file, cast(char*)(buffer.join));
}
