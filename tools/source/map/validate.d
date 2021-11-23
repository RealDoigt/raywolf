module map.validate;
import actors.entity;

bool canFit(Entity entity, byte[][] map)
{
    if (cast(int)entity.x < map[0].length && cast(int)entity.y < map.length)
        return true;

    return false;
}

bool canFit(Entity[] entities, byte[][] map)
{
    foreach (e; entities) if (!e.canFit(map)) return false;
    return true;
}
