module actors.observing;
import raylib;

interface IObserver
{
    void react(Vector2 position);
}

interface IObserved
{
    void alert();
}
