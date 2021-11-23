module game.math.statistics;
import actors.visible;
import actors.npc;

int countNpc(IVisible[] entities)
{
    int count = 0;

    for (int i; i < entities.length; ++i)
        if (cast(Computer)entities[i])
            ++count;

    return count;
}
