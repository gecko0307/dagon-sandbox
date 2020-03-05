module main;

import std.stdio;
import dagon;
import forest;

class MyGame: Game
{
    this(uint w, uint h, bool fullscreen, string title, string[] args)
    {
        super(w, h, fullscreen, title, args);
        currentScene = New!ForestScene(this);
    }
}

void main(string[] args)
{
    version(Mimalloc)
    {
        import bindbc.mimalloc;
        import mimallocator;

        writeln("Using mimalloc");
        loadMimalloc();
        globalAllocator = Mimallocator.instance();
    }

    MyGame game = New!MyGame(1280, 720, false, "Dagon Sanbox", args);
    game.run();
    Delete(game);

    writeln(allocatedMemory);
}
