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

class MultiDrawable: Owner, Drawable
{
    DynamicArray!Drawable drawables;

    this(Owner o)
    {
        super(o);
    }

    ~this()
    {
        drawables.free();
    }

    void render(GraphicsState* state)
    {
        foreach(d; drawables)
        {
            d.render(state);
        }
    }
}

class AssimpModel: Owner
{
    Entity rootEntity;
    DynamicArray!Entity entities;
    DynamicArray!Mesh meshes;

    this(Owner o)
    {
        super(o);
    }

    ~this()
    {
        meshes.free();
        entities.free();
    }

    void createMeshes(const(aiScene*) scene)
    {
        foreach(i; 0..scene.mNumMeshes)
        {
            const(aiMesh)* assimpMesh = scene.mMeshes[i];
            auto mesh = createMesh(assimpMesh);
            mesh.dataReady = true;
            meshes.append(mesh);
        }
    }

    Entity createEntity(const(aiScene*) scene, const(aiNode*)node)
    {
        Entity entity = New!Entity(this);

        aiMatrix4x4 t = node.mTransformation;
        Matrix4x4f transformation = matrixf(
            t.a1, t.a2, t.a3, t.a4,
            t.b1, t.b2, t.b3, t.b4,
            t.c1, t.c2, t.c3, t.c4,
            t.d1, t.d2, t.d3, t.d4
        );
        entity.position = transformation.translation;
        entity.rotation = Quaternionf.fromMatrix(transformation);
        entity.scaling = transformation.scaling;

        MultiDrawable md = New!MultiDrawable(this);
        entity.drawable = md;

        foreach(mi; 0..node.mNumMeshes)
        {
            auto meshIndex = node.mMeshes[mi];
            if (meshIndex < meshes.length)
            {
                auto mesh = meshes[node.mMeshes[mi]];
                md.drawables.append(mesh);
            }

            // TODO: material
        }

        foreach(ci; 0..node.mNumChildren)
        {
            const(aiNode*)childNode = node.mChildren[ci];
            auto childEntity = createEntity(scene, childNode);
            entity.addChild(childEntity);
        }

        entities.append(entity);

        return entity;
    }

    Mesh createMesh(const(aiMesh)* assimpMesh)
    {
        Mesh mesh = New!Mesh(this);

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
        //writeln(ext);

        ubyte[] buffer = New!(ubyte[])(cast(size_t)istrm.size);
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

        model.createMeshes(scene);
        model.rootEntity = model.createEntity(scene, scene.mRootNode);

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
