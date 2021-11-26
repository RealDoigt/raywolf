module game.loop.doorinfo;
import actors.player;
import std.stdio;

enum DoorType : byte
{
    NotDoor,
    Unlocked,
    LevelEnd = 30,
    Red      = 10,
    Green    = 11,
    Blue     = 12,
    Yellow   = 13,
    Purple   = 14,
    Teal     = 15,
    Orange   = 16,
    Lime     = 17,
    Magenta  = 18,
    Cyan     = 19
}

struct Door
{
    float distanceToPlayer;
    DoorType type;
    int x, y;
}

class DoorInfo
{
    private Door[] doors;

    void add(float distance, int x, int y, byte value)
    {
        auto newType = cast(DoorType)value;

        if (value < 10 || value > 30) newType = DoorType.NotDoor;
        else if (value < 30 && value > 19) newType = DoorType.Unlocked;
        else if (value == 30) newType = DoorType.LevelEnd;

        Door newDoor = {distance, newType, x, y};
        doors ~= newDoor;
    }

    // trouve la porte la plus compatible;
    // -> Le joueur a la clef pour l'ouvrir (ou la porte est débarrée).
    // -> La porte est proche.
    // -> La porte la plus proche des portes proches.
    Door getDoor(ColorKey[] keys)
    {
        Door[] playerCanOpen;

        // trouve toutes les portes que le joueur peut ouvrir
        foreach (door; doors)
        {
            if (door.type == DoorType.NotDoor) continue;

            else if (door.type == DoorType.Unlocked || door.type == DoorType.LevelEnd)
            {
                playerCanOpen ~= door;
                continue;
            }

            foreach (key; keys)
                if (cast(DoorType)key == door.type)
                    playerCanOpen ~= door;
        }

        if (!playerCanOpen.length) return Door(0f, DoorType.NotDoor, 0, 0);

        Door[] playerIsNearTo;

        foreach (door; playerCanOpen)
            if (door.distanceToPlayer < 1.3f)
                playerIsNearTo ~= door;

        if (!playerIsNearTo.length) return Door(0f, DoorType.NotDoor, 0, 0);

        auto nearestDoor = playerIsNearTo[0];

        for (int i = 1; i < playerIsNearTo.length; ++i)
            if (playerIsNearTo[i].distanceToPlayer < nearestDoor.distanceToPlayer)
                nearestDoor = playerIsNearTo[i];

        return nearestDoor;
    }

    void clear()
    {
        doors.destroy;
    }
}


