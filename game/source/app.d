import std.algorithm.mutation;
import std.stdio;
import std.string;

import game.math.statistics;
import game.math.images;
import game.math.consts;
import game.loop.gameplay;
import game.loop.gameover;

import map;
import actors;
import raylib;

import menu.preferences;
import menu.settings;

void main()
{
    string[] levelList;
    if (!tryLoadLevelList(levelList) && !levelList.length)
    {
        "No map found".writeln;
        return;
    }

    SetTargetFPS(60);
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Test");

    InitAudioDevice();
    1f.SetMasterVolume;

    auto monsterSound = LoadSound("snd/swipe_16.wav");
    auto ceilingImage = LoadImage("img/sky.png");
    ImageResize(&ceilingImage, 128, 128);

    Image[string] images;
    images["ceiling"] = ceilingImage;
    images["health"] = "img/health.png".getImage;
    images["wall"] = "img/forest.png".getImage;
    images["ammo"] = "img/ammo.png".getImage;
    images["key"] = "img/key.png".getImage;
    images["npc"] = "img/npc.png".getImage;

    images["door"] = "img/forest_path.png".getImage;
    images["locked door"] = "img/locked_forest_path.png".getImage;

    IVisible[] items;
    Player player;
    byte[][] map;

    Texture screen;
    Image buffer;

    drawPreferencesMenu();

    auto currentMapIndex = 0;
    auto shouldContinue = true;

    do
    {
        // Génération d'une image qui va servir de gabarit sur lequel l'écran sera dessiné pixel par pixel
        buffer = GenImageColor(WINDOW_WIDTH, WINDOW_HEIGHT, Colors.WHITE);
        // Texture qui va prendre l'image plus haut et sera dessiné à partir de la vram pour plus de précision et rapidité
        screen = buffer.LoadTextureFromImage;

        if (!tryLoadMapEntities(cast(char*)("maps/%d.mae".format(currentMapIndex)).toStringz, player, items, images, &monsterSound))
        {
            "Échec de la génération des entités".writeln;
            break;
        }

        if (!tryLoadMap(cast(char*)("maps/%d.map".format(currentMapIndex)).toStringz, map))
        {
            "Échec de la génération de la carte".writeln;
            break;
        }

        play(&buffer, &screen, map, player, images, items);

        if (levelCleared)
        {
            ++currentMapIndex;
            levelCleared = false;

            if (currentMapIndex >= levelList.length) shouldContinue = false;
        }

        else shouldContinue = endGame(&buffer, &screen);
    }
    while (shouldContinue);

    screen.UnloadTexture;

    foreach(key; images.keys)
        images[key].UnloadImage;

    buffer.UnloadImage;
    monsterSound.UnloadSound;

    CloseAudioDevice();
}
