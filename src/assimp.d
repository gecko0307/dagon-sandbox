module assimp;

import std.stdio;
import std.path;
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

string extension(string filename)
{
    size_t start = filename.length;
    foreach_reverse(i, ch; filename)
    {
        if (ch == '.')
        {
            start = i + 1;
            break;
        }
    }

    if (start < filename.length)
        return filename[start..filename.length];
    else
        return "";
}

class AssimpModel: Owner, Drawable
{
    DynamicArray!Mesh meshes;
    // TODO: materials

    this(Owner o)
    {
        super(o);
    }

    ~this()
    {
        meshes.free();
    }

    void render(GraphicsState* state)
    {
        foreach(mesh; meshes)
        {
            mesh.render(state);
        }
    }

    Mesh createMesh(const(aiMesh)* assimpMesh)
    {
        Mesh mesh = New!Mesh(this);
        meshes.append(mesh);

        mesh.vertices = New!(Vector3f[])(assimpMesh.mNumVertices);
        mesh.normals = New!(Vector3f[])(assimpMesh.mNumVertices);
        mesh.texcoords = New!(Vector2f[])(assimpMesh.mNumVertices);
        mesh.indices = New!(uint[3][])(assimpMesh.mNumVertices);

        for(size_t i = 0; i < assimpMesh.mNumVertices; i++)
        {
            auto v = &assimpMesh.mVertices[i];
            auto n = &assimpMesh.mNormals[i];
            auto t = &assimpMesh.mTextureCoords[0][i];
            mesh.vertices[i] = Vector3f(v.x, v.y, v.z);
            mesh.normals[i] = Vector3f(n.x, n.y, n.z);
            mesh.texcoords[i] = Vector2f(t.x, t.y);
        }

        for(size_t i = 0; i < assimpMesh.mNumFaces; i++)
        {
            auto face = assimpMesh.mFaces[i];
            mesh.indices[i][0] = face.mIndices[0];
            mesh.indices[i][1] = face.mIndices[1];
            mesh.indices[i][2] = face.mIndices[2];
        }

        return mesh;
    }
}

class AssimpAsset: Asset
{
    AssimpModel model;

    this(Owner o)
    {
        super(o);
        model = New!AssimpModel(this);
    }

    ~this()
    {
        release();
    }

    override bool loadThreadSafePart(string filename, InputStream istrm, ReadOnlyFileSystem fs, AssetManager mngr)
    {
        String ext = String(extension(filename));
        writeln(ext);

        ubyte[] buffer = New!(ubyte[])(istrm.size);
        istrm.fillArray(buffer);

        const(aiScene*) scene = aiImportFileFromMemory(cast(char*)buffer.ptr, cast(uint)buffer.length,
            aiPostProcessSteps.Triangulate |
            aiPostProcessSteps.GenSmoothNormals |
            aiPostProcessSteps.GenUVCoords,
            ext.cString);

        if (scene is null)
        {
            writeln("Failed to load model");
            return false;
        }

        foreach(mi; 0..scene.mNumMeshes)
        {
            const(aiMesh)* assimpMesh = scene.mMeshes[mi];
            auto mesh = model.createMesh(assimpMesh);
            mesh.dataReady = true;
        }

        Delete(buffer);
        ext.free();

        return true;
    }

    override bool loadThreadUnsafePart()
    {
        foreach(mesh; model.meshes)
        {
            mesh.prepareVAO();
        }

        return true;
    }

    override void release()
    {
        clearOwnedObjects();
    }
}
