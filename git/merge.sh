#############################################
# merging
#############################################

git_commit()
{
  # add and commit only tracked and changed files
  git commit -am "$1"
}

git_branch()
{
  # create and checkout branch
  git checkout -b $1

  # append state
  echo $1 >> log.txt

  # commit changes
  git_commit $1
}

# start a repo
git init

# turn off line-ending warnings
git config core.autocrlf false

# create files
touch log.txt .gitignore

# ignore this script
echo '.gitignore
merge.sh
utils.sh' > .gitignore

# add log and commit main as base state
git add log.txt && git commit -m "main is empty"

# create some branches
git_branch "A"
git_branch "B"
git_branch "C"

# make trunk in middle of branching
# note: avoid using 'trunk' as git recognises it and sets it to HEAD
git_branch "my-trunk"

# create branches trunk is unaware of
git_branch "D"
git_branch "E"
git_branch "F"

# update branch that my-trunk is aware of
git checkout B

echo "B*" >> log.txt

git_commit "B*"

# checkout trunk
git checkout my-trunk

# merge B* changes into trunk
git merge B

git_commit "merge B* into my-trunk"

# make a change ahead of merge
echo "my-trunk*" >> log.txt

# commit change
git_commit "my-trunk*"

git status

git log --all --decorate --oneline --graph

# my-trunk* then merge B* --> accepted both changes:

# A
# B
# C
# my-trunk
# my-trunk*
# B*

# merge B* then my-trunk* --> accepted both changes:

# A
# B
# C
# my-trunk
# B*
# my-trunk*