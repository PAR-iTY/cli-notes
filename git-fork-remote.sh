# ---------------------------------------------------------------------#
#
#      INITIALISE A NEW GITHUB REPO WITH GITHUB CLI         
#
# ---------------------------------------------------------------------#

gh repo create --public --source=.

# ---------------------------------------------------------------------#
#
#           INITIALISE A NEW LOCAL COPY OF FORKED REPO
#
# ---------------------------------------------------------------------#

git init

# option 1:

# clone your github fork, this becomes the "origin" remote
git clone https://github.com/<profile>/<repo>.git

# move into your cloned forked repo:
cd <repo>

# option 1:

# to instead preserve local changes add remote
git remote add origin https://github.com/<profile>/<repo>.git

# add your fork's upstream remote that you wish to get updates from:
git remote add upstream https://github.com/<target-profile>/<target-repo>.git

# ---------------------------------------------------------------------#
#
#            FETCH AND MERGE UPSTREAM CHANGES INTO MAIN
#
# ---------------------------------------------------------------------#

# option 1:

# make sure that you're on your main branch:
git checkout main

# update your fork from original repo to keep up with their changes:
git pull upstream main

# if up to date with upstream and accidentally delete in local
# then commit those changes, local will be 'ahead' of upstream
# cannot then pull upstream to get changes back

# Rebase should work better because you can force the commit pointer
# 'backwards' by choosing to rebase main *with* upstream

# ---------------------------------------------------------------------#
#
#                 REBASE MAIN WITH UPSTREAM CHANGES
#
# ---------------------------------------------------------------------#

# option 2:

# Fetch all the branches of that remote into remote-tracking branches
# (this is unnecessary when using git pull option)
git fetch upstream

# Rewrite your main branch so that any commits of yours that
# aren't already in upstream/main are replayed on top of other branch:
git rebase upstream/main

# ---------------------------------------------------------------------#
#
#          CREATE FORK AND LEAVE MAIN IN SYNC WITH UPSTREAM
#
# ---------------------------------------------------------------------#

# this might help avoid making local commits and accidentally
# putting local 'ahead' of upstream even when upstream has new data

# option 1:
git checkout -b <branch-name>

# ...some work and some commits happen...

git fetch upstream

# option 2:

# use rebase instead, then merge to make sure upstream
# has a clean set of commits (ideally one) to evaluate:
git rebase upstream/main

git push origin <branch-name>

# ---------------------------------------------------------------------#
#
#          SYNC FORKED GITHUB REPO WITH UPSTREAM VIA ORIGIN
#
# ---------------------------------------------------------------------#

# now update forked repo main branch to mirror upstream via origin
git push origin main