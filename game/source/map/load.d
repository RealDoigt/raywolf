module map.load;

import actors.character;
import actors.entity;
import actors.item;
import actors.visible;
import actors.player;
import actors.npc;

import std.algorithm;
import std.string;
import std.array;
import std.stdio;
import std.file;
import std.conv;

import raylib;

bool tryLoadMap(char* file, ref byte[][] map)
{
    if (!file.FileExists) return false;

    uint dataSize = 0;

    auto rawMapData = LoadFileData(file, &dataSize);
    auto height = cast(ubyte)rawMapData[1];
    auto width = cast(ubyte)rawMapData[0];

    map = new byte[][](height, width);

    for (int y = 0, i = 2; y < height; ++y)
        for (int x = 0; x < width; ++x, ++i)
            map[y][x] = cast(byte)rawMapData[i];

    rawMapData.UnloadFileData;

    return true;
}

bool tryLoadMapEntities(char* file, ref Player player, ref IVisible[] visibles, Image*[string] images, Sound* attack)
{
    if (!file.FileExists) return false;

    auto rawEntitiesData = to!string(file.LoadFileText).split(";");

    foreach (rawEntity; rawEntitiesData)
    {
        auto data = rawEntity.split(" ");

        switch (data[data.length - 1])
        {
            case "c":

                visibles ~= new Computer(to!float(data[0]), to!float(data[1]), to!ubyte(data[2]), images["npc"], PI / 4f, 6f, cast(ubyte)10, attack);
                break;

            case "i":

                // contains the value as to whether the item is health or not
                if (to!bool(data[3]))
                    visibles ~= new Heal(to!float(data[0]), to!float(data[1]), images["heal"], to!ubyte(data[2]));

                else
                    visibles ~= new Ammunition(to!float(data[0]), to!float(data[1]), images["ammo"], to!ubyte(data[2]));

                break;

            case "k":

                visibles ~= new Key(to!float(data[0]), to!float(data[1]), images["key"], to!byte(data[2]));
                break;

            default:

                // seul le joueur n'a pas un caractère dans sa dernière cellule
                if (!data[3].isNumeric) return false;
                player = new Player(to!float(data[0]), to!float(data[1]), to!ubyte(data[2]), to!ubyte(data[3]));
                break;
        }
    }

    // réparation temporaire en attendant que je trouve comment réparer correctement.
    visibles ~= new Key(0f, 0f, images["key"], 10);

    return true;
}
