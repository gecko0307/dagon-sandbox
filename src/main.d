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
        
        renderer.setViewport(300, 0, eventManager.windowWidth - 300, eventManager.windowHeight - 40);
    }
    
    override void onResize(int width, int height)
    {
        renderer.setViewport(300, 0, width - 300, height - 40);
        hudRenderer.setViewport(0, 0, width, height);
    }
}

void main(string[] args)
{
    MyGame game = New!MyGame(1280, 720, false, "Dagon NG", args);
    game.run();
    Delete(game);
    
    writeln(allocatedMemory);
}
