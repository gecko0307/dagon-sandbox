module main;

import std.stdio;
import dagon;
import editor;

class MyGame: Game
{
    this(uint w, uint h, bool fullscreen, string title, string[] args)
    {
        super(w, h, fullscreen, title, args);

        currentScene = New!Editor(this);

        deferredRenderer.setViewport(0, 0, eventManager.windowWidth - 300, eventManager.windowHeight - 40);
        postProcRenderer.setViewport(0, 0, eventManager.windowWidth - 300, eventManager.windowHeight - 40);
        presentRenderer.setViewport(300, 0, eventManager.windowWidth - 300, eventManager.windowHeight - 40);
        hudRenderer.setViewport(0, 0, width, height);
    }

    override void onResize(int width, int height)
    {
        deferredRenderer.setViewport(0, 0, width - 300, height - 40);
        postProcRenderer.setViewport(0, 0, width - 300, height - 40);
        presentRenderer.setViewport(300, 0, width - 300, height - 40);
        hudRenderer.setViewport(0, 0, width, height);
    }
}

version(Mimalloc)
{
    import bindbc.mimalloc;
    import mimallocator;
}

void main(string[] args)
{
    version(Mimalloc)
    {
        writeln("Using mimalloc");
        loadMimalloc();
        globalAllocator = Mimallocator.instance();
    }

    MyGame game = New!MyGame(1280 + 300, 720 + 40, false, "Dagon NG", args);
    game.run();
    Delete(game);

    writeln(allocatedMemory);
}
