# Gary

Gary is a simple tool for batch-cloning/pulling multiple student submissions via git.

He has no commandline switches at the moment, but expects a "gitlist.csv" in the same folder as himself.

The expected csv format is like this:

    Bergström Mikael,https://github.com/krank/gary

First column is the student's name, second column is a git repo URL. Gary supports a second git repository, in cases where student submissions are made in two parts. There are plans to extend this functionality to allow for an arbitrary number of git repos. Adding a second git repo URL just means adding another column:

    Bergström Mikael,https://github.com/krank/gary,https://github.com/krank/example

Gary will, when invoked, create subfolders in the current folder based on student names.

For students with only one git repo specified, he will then clone that repo into the student's folder.

For students with two repos specified, he will create two subfolders, git1 and git2, and clone the first and the second repo into each subfolder respectively.

Folders that already exist are not duplicated or recreated, and if a local git repo is detected where Gary is supposed to clone one, he pulls instead.

This means Gary can be invoked first to make an initial structure and clone each student's work, then also be called upon to update the local repos.

If the csv file is changed, old folders stay in place but new ones are created (and new repos are cloned).