import std.algorithm.mutation;
import game.math.statistics;
import game.math.images;
import game.math.consts;
import game.loop.gameplay;
import game.loop.gameover;
import actors;
import raylib;

import menu.preferences;
import menu.settings;

void main()
{
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

    Texture screen;
    Player player;
    Image buffer;

    drawPreferencesMenu();

    do
    {
        // Génération d'une image qui va servir de gabarit sur lequel l'écran sera dessiné pixel par pixel
        buffer = GenImageColor(WINDOW_WIDTH, WINDOW_HEIGHT, Colors.WHITE);
        // Texture qui va prendre l'image plus haut et sera dessiné à partir de la vram pour plus de précision et rapidité
        screen = buffer.LoadTextureFromImage;

        player = new Player(2f, 1f, cast(ubyte)(20 - difficulty), 5);

        byte[][] map =
        [
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 1,12, 1, 1, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0,20, 0, 0, 0, 1, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        ];

        IVisible[] items =
        [
            new Key(1.5f, 3.5f, &images["key"], 12),
            new Heal(1.5f, 4.5f, &images["health"], 10),
            new Ammunition(3.5f, 1.5f, &images["ammo"], 5),
            cast(IVisible)(new Computer(7.5f, 8.5f, 6, &images["npc"], FIELD_OF_VIEW, 6f, 10, &monsterSound)),

            new Key(0f, 0f, &images["key"], 10) // réparation temporaire en attendant que je trouve comment réparer correctement.
        ];

        player.addObserver(cast(IObserver)items[3]);
        play(&buffer, &screen, map, player, images, items);
    }
    while (!player.GetHealth() && endGame(&buffer, &screen));

    screen.UnloadTexture;

    foreach(key; images.keys)
        images[key].UnloadImage;

    buffer.UnloadImage;
    monsterSound.UnloadSound;

    CloseAudioDevice();
}
