module assimp;

import std.stdio;
import dagon;
import bindbc.assimp;

static this()
{
    AssimpSupport assimpSupport = loadAssimp();
    if (assimpSupport != AssimpSupport.assimp500)
    {
        if (assimpSupport == AssimpSupport.badLibrary)
           writeln("Warning: failed to load some Assimp functions. It seems that you have an old version of Assimp. Dagon will try to use it, but it is recommended to install Assimp 5");
       else
           exitWithError("Error: Assimp library is not found. Please, install Assimp 5");
    }
}


class AssimpAsset: Asset
{
    Mesh mesh;

    this(Owner o)
    {
        super(o);
        mesh = New!Mesh(this);
    }

    ~this()
    {
        release();
    }

    override bool loadThreadSafePart(string filename, InputStream istrm, ReadOnlyFileSystem fs, AssetManager mngr)
    {
        ubyte[] buffer = New!(ubyte[])(istrm.size);
        istrm.fillArray(buffer);

        const(aiScene*) scene = aiImportFileFromMemory(cast(char*)buffer.ptr, cast(uint)istrm.size,
            aiPostProcessSteps.Triangulate |
            aiPostProcessSteps.GenSmoothNormals |
            aiPostProcessSteps.GenUVCoords,
            "".ptr);
        return true;
    }

    override bool loadThreadUnsafePart()
    {
        //mesh.prepareVAO();
        return true;
    }

    override void release()
    {
        clearOwnedObjects();
    }
}
