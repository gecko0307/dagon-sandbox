import json
import git
import os

deps = {}
with open("dependencies.json", "r") as file:
    dubConfig = json.load(file)
    deps = dubConfig["git"]

dubSelections = {}
dubSelections["fileVersion"] = 1
dubSelections["versions"] = {}

for depName in deps:
    dep = deps[depName]
    repoUrl = dep[0]
    branchName = dep[1]
    dir = ".resolve/" + depName

    if not os.path.exists(".resolve"):
        os.makedirs(".resolve")

    repo = None
    if os.path.exists(dir):
        repo = git.cmd.Git(dir)
    else:
        repo = git.cmd.Git(".resolve")
        repo.clone(repoUrl)
        repo = git.cmd.Git(dir)
        repo.checkout(branchName)

    dubSelections["versions"][depName] = {}
    dubSelections["versions"][depName]["path"] = dir

with open("dub.selections.json", "w") as writeFile:
    json.dump(dubSelections, writeFile)
