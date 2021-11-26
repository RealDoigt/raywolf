module map.load;

import actors.character;
import actors.entity;
import actors.item;

import std.algorithm;
import std.string;
import std.array;
import std.stdio;
import std.file;
import std.conv;

import raylib;

void writeUnfinishedError(int lineCount)
{
    writeln("expected a ; before line %d".format(lineCount));
}

float colorStringToFloat(string color)
{
    switch (color)
    {
        case "red":     return 10f;
        case "green":   return 11f;
        case "blue":    return 12f;
        case "yellow":  return 13f;
        case "purple":  return 14f;
        case "teal":    return 15f;
        case "orange":  return 16f;
        case "lime":    return 17f;
        case "magenta": return 18f;
        case "cyan":    return 19f;
        default:        return  0f; // invalid
    }
}

bool getEntities(ref float[string][string] rawEntities, string[] rawEntityData)
{
    auto readingEntity = false, playerIsDone = false;

    auto lineCount = 0;
    auto currentEntity = "";

    void setState(string object, string attribute, float value)
    {
        currentEntity = format("%s_%d", object, lineCount);
        rawEntities[currentEntity][attribute] = value;
        readingEntity = true;
    }

    // assembler les paramètres pour construire les classes
    foreach (str; rawEntityData)
    {
        ++lineCount;

        if (str.startsWith("#")) continue;

        switch (str)
        {
            case "player":

                if (readingEntity)
                {
                    writeUnfinishedError(lineCount);
                    return false;
                }

                if (playerIsDone)
                {
                    writeln("there cannot be more than one player definition. There's an extra at line %d".format(lineCount));
                    return false;
                }

                setState("character", "isPlayer", 1f);
                playerIsDone = true;
                break;

            case "character":

                if (readingEntity)
                {
                    writeUnfinishedError(lineCount);
                    return false;
                }

                setState("character", "isPlayer", 0f);
                break;

            case "health":

                if (readingEntity)
                {
                    writeUnfinishedError(lineCount);
                    return false;
                }

                setState("item", "isHealth", 1f);
                break;

            case "ammo":

                if (readingEntity)
                {
                    writeUnfinishedError(lineCount);
                    return false;
                }

                setState("item", "isHealth", 0f);
                break;

            case "key":

                if (readingEntity)
                {
                    writeUnfinishedError(lineCount);
                    return false;
                }

                setState("key", "key", 0f);
                break;

            default: break;
        }

        if (str.startsWith("."))
        {
            if (!readingEntity)
            {
                writeln("%s at line %d is supposed to be a property, however it is cut off from its parent object. You probably misplaced a ; just before that line.".format(str, lineCount));
                return false;
            }

            auto keyValuePair = str.split("=");
            keyValuePair[0] = keyValuePair[0].strip;
            keyValuePair[1] = keyValuePair[1].strip;

            if (keyValuePair.length < 2)
            {
                writeln("expected a value after %s at line %d, property cannot be empty. If you want the property to have the default value, don't define it instead.".format(str, lineCount));

                return false;
            }

            // on enlève le point du nom de l'attribut
            keyValuePair[0] = keyValuePair[0][1..keyValuePair[0].length];

            // on enlève le ; de la valeur s'il est à la fin de la chaîne.
            if (keyValuePair[1].endsWith(";")) keyValuePair[1] = keyValuePair[1][0..keyValuePair[1].length - 1];

            float value;

            if (currentEntity.canFind("key") && keyValuePair[0].canFind("color"))
            {
                value = keyValuePair[1].colorStringToFloat;

                if (!value)
                {
                    writeln("invalid color value %s at line %d".format(str, lineCount));
                    return false;
                }
            }

            else
            {
                if (!keyValuePair[1].isNumeric)
                {
                    writeln("the value at line %d should be a number".format(lineCount));
                    return false;
                }

                value = to!float(keyValuePair[1]);
            }

            // on met la valeur de l'attribut dans la collection d'entités
            rawEntities[currentEntity][keyValuePair[0]] = value;
        }

        if (str.endsWith(";"))
        {
            if (!readingEntity) writeln("redundant ; at line %d".format(lineCount));
            readingEntity = false;
        }
    }

    return true;
}

bool tryLoadMapEntities(string file, ref Character player, ref Entity[] entities)
{
    if (!file.exists) return false;

    float[string][string] rawEntities;

    if (!getEntities(rawEntities, file.readText.splitLines)) return false;

    // construire les classes
    foreach (str; rawEntities.keys)
    {
        auto classType = str.split("_")[0];
        auto classAttributes = rawEntities[str].keys;

        auto x = classAttributes.canFind("x") ? rawEntities[str]["x"] : 0f;
        auto y = classAttributes.canFind("y") ? rawEntities[str]["y"] : 0f;

        switch (classType)
        {
            case "character":

                auto health = classAttributes.canFind("health") ? rawEntities[str]["health"] : 20f;

                if (rawEntities[str]["isPlayer"] == 1f)
                {
                    auto ammo = classAttributes.canFind("ammo") ? rawEntities[str]["ammo"] : 5f;
                    player = new Character(x, y, cast(ubyte)health, cast(ubyte)ammo);
                }

                else entities ~= new Character(x, y, cast(ubyte)health);
                break;

            case "item":

                auto value = classAttributes.canFind("value") ? rawEntities[str]["value"] : 5f;
                auto isHealth = cast(bool)rawEntities[str]["isHealth"];

                entities ~= new Item(x, y, cast(ubyte)value, isHealth);
                break;

            case "key":

                auto color = cast(ColorKey)rawEntities[str]["color"];
                entities ~= new Key(x, y, color);
                break;

            default:

                writeln("unexpected error; invalid class type: %s".format(classType));
                return false;
        }
    }

    return true;
}
