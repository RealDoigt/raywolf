import std.stdio;
import std.array;
import std.file;
import std.string;

import map.load;
import map.save;
import map.create;
import map.validate;

import actors.character;
import actors.entity;
import actors.item;

import raylib;

void main(string[] args)
{
    auto mapFound = false;
    auto entitiesFound = false;
    string mapFile;
    string entitiesFile;

    foreach (arg; args)
    {
        if (mapFound && entitiesFound) break;

        if (arg.endsWith(".png") && !mapFound)
        {
            mapFound = true;
            mapFile = arg;
        }

        else if (arg.endsWith(".sson") && !entitiesFound)
        {
            entitiesFound = true;
            entitiesFile = arg;
        }
    }

    if (!mapFound)
    {
        "map file (png image) missing from args".writeln;
        return;
    }

    if (!entitiesFound)
    {
        "map entities file (sson) missing from args".writeln;
        return;
    }

    if (!mapFile.exists)
    {
        "can't find the map file".writeln;
        mapFile.writeln;
        return;
    }

    auto image = LoadImage(cast(char*)mapFile);
    auto map = imageToByteMap(&image);
    image.UnloadImage;

    Character player;
    Entity[] entities;

    if (!tryLoadMapEntities(entitiesFile, player, entities))
    {
        "failed to build map entities".writeln;
        return;
    }

    if (!player.canFit(map))
    {
        "The player is out of bounds".writeln;
        return;
    }

    if (!entities.canFit(map))
    {
        "One or more of the non-player entities are out of bounds".writeln;
        return;
    }

    saveMap(mapFile.split(".")[0] ~ ".map", map);
    saveMapEntities(cast(char*)(entitiesFile.split(".")[0] ~ ".mae"), player, entities);
}
