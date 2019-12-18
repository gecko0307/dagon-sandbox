module main;

import std.stdio;
import dagon;
import editor;

import bindbc.assimp;

class MyGame: Game
{
    this(uint w, uint h, bool fullscreen, string title, string[] args)
    {
        super(w, h, fullscreen, title, args);

        currentScene = New!Editor(this);
        deferredRenderer.setViewport(0, 0, eventManager.windowWidth - 300, eventManager.windowHeight - 40);
        postProcessingRenderer.setViewport(0, 0, eventManager.windowWidth - 300, eventManager.windowHeight - 40);
        presentRenderer.setViewport(300, 0, eventManager.windowWidth - 300, eventManager.windowHeight - 40);
        hudRenderer.setViewport(0, 0, width, height);
    }

    override void onResize(int width, int height)
    {
        deferredRenderer.setViewport(0, 0, width - 300, height - 40);
        postProcessingRenderer.setViewport(0, 0, width - 300, height - 40);
        presentRenderer.setViewport(300, 0, width - 300, height - 40);
        hudRenderer.setViewport(0, 0, width, height);
    }
}

void main(string[] args)
{
    /*
    version(Mimalloc)
    {
        import bindbc.mimalloc;
        import mimallocator;

        writeln("Using mimalloc");
        loadMimalloc();
        globalAllocator = Mimallocator.instance();
    }
    */

    AssimpSupport assimpSupport = loadAssimp();
    if (assimpSupport != AssimpSupport.assimp500)
    {
        if (assimpSupport == AssimpSupport.badLibrary)
           writeln("Warning: failed to load some Assimp functions. It seems that you have an old version of Assimp. Dagon will try to use it, but it is recommended to install Assimp 5");
       else
           exitWithError("Error: Assimp library is not found. Please, install Assimp 5");
    }

    //enableMemoryProfiler(true);

    MyGame game = New!MyGame(1280 + 300, 720 + 40, false, "Dagon NG", args);
    game.run();
    Delete(game);

    writeln(allocatedMemory);
    //printMemoryLeaks();
}
