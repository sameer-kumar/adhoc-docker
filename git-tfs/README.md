# git-tfs
This is a Windows server core docker image containing git-tf tool and its dependency.

Git-TF is a set of cross-platform, command line tools that facilitate sharing of changes between TFS and Git.

You can run clone command to clone a TFVC repo into a git repo.
```
git-tf clone --deep http://tfsCollectionUrl '$\TFSProject' c:\temp\collectionName\projectName
```

You can find more information [here](https://archive.codeplex.com/?p=gittf).