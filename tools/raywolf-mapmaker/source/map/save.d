module map.save;

import actors.character;
import actors.entity;
import actors.item;
import std.format;
import std.array;
import std.file;
import raylib;

void saveMap(string file, ref byte[][] map)
{
    // on combine la largeur et hauteur, puis on ajoute ces infos-là même dans le buffer.
    auto buffer = new ubyte[](map.length * map[0].length + 2);
    buffer[0] = cast(ubyte)map[0].length; // largeur
    buffer[1] = cast(ubyte)map.length; // hauteur

    for (int y = 0, i = 2; y < map.length; ++y)
        for (int x = 0; x < map[0].length; ++x, ++i)
            buffer[i] = cast(ubyte)map[y][x];

    write(file, buffer);
}

void saveMapEntities(char* file, Character player, Entity[] entities)
{
    auto buffer = new string[](entities.length + 1);

    buffer[0] = format("%f %f %d %d;", player.x, player.y, player.health, player.ammo);

    for (int i = 1; i < entities.length; ++i)
    {
        buffer[i] = format("%f %f ", entities[i].x, entities[i].y);

        if (auto key = cast(Key)entities[i]) buffer[i] ~= format("%d k;", cast(byte)key.color);

        else if (auto item = cast(Item)entities[i]) buffer[i] ~= format("%d %s i;", item.points, item.IsHealth());

        else
        {
            auto npc = cast(Character)entities[i];
            buffer[i] ~= format("%d c;", npc.health);
        }
    }

    SaveFileText(file, cast(char*)(buffer.join));
}
