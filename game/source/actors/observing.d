module actors.observing;
import raylib;

interface IObserver
{
    void react(Vector2 position, byte[][] map);
}

interface IObserved
{
    void alert(byte[][] map);
}
