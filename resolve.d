module resolve;

import std.stdio;
import std.array: split;
import std.file: readText, exists, mkdir, getcwd, write;
import std.process: execute, Config;
import std.json;
import std.path: absolutePath;

struct Git
{
    string workDir;
    
    this(string dir)
    {
        workDir = dir;
    }
    
    auto cmd(string[] commands)
    {
        return execute(["git"] ~ commands, null, Config.none, size_t.max, workDir);
    }
    
    auto clone(string url)
    {
        return cmd(["clone"] ~ url);
    }
    
    auto checkout(string branchName)
    {
        return cmd(["checkout"] ~ branchName);
    }
}

void run()
{
    string s = readText("dependencies.json");
    JSONValue dubConfig = parseJSON(s);
    JSONValue deps = dubConfig["git"];
    
    JSONValue[string] versions;
    
    foreach(string depName, ref JSONValue _dep; deps)
    {
        string[] s = depName.split(":");
        string packageName = s[0];
        string subpackageName = "";
        if (s.length > 1)
            subpackageName = s[1];
        
        JSONValue dep = deps[packageName];
        string repoUrl = dep.array[0].str;
        string branchName = dep.array[1].str;
        string dir = ".resolve/" ~ packageName;

        if (!exists(".resolve")) 
            mkdir(".resolve");

        Git repo;
        string dirAbs = absolutePath(dir);
        
        if (exists(dir))
        {
            repo = Git(dirAbs);
        }
        else
        {
            repo = Git(absolutePath(".resolve"));
            repo.clone(repoUrl);
            repo = Git(dirAbs);
            repo.checkout(branchName);
        }
        
        if (subpackageName != "")
            versions[depName] = JSONValue(["path": JSONValue(dir)]);
        else
            versions[packageName] = JSONValue(["path": JSONValue(dir)]);
    }
    
    JSONValue dubSelections = JSONValue(
    [
        "fileVersion": JSONValue(1),
        "versions": JSONValue(versions)
    ]);
    
    write("dub.selections.json", dubSelections.toString(JSONOptions.doNotEscapeSlashes));
}

void main()
{
    run();
}
