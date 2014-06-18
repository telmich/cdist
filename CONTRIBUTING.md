WELCOME
-------
Welcome dear hacker! I invite you to a tour of pointers to
get into the usable configuration mangament system, cdist.

The first thing to know is probably that cdist is brought to
you by people who care about how code looks like and who think
twice before merging or implementing a feature: Less features
with good usability are far better than the opposite.


REPORTING BUGS
--------------
If you believe you've found a bug and verified that it is
in the latest version, drop a mail to the cdist mailing list,
subject prefixed with "[BUG] " or create an issue on github.


CODING CONVENTIONS (EVERYWHERE)
-------------------------------
If something should be better done or needs to fixed, add the word `FIXME`
nearby, so grepping for `FIXME` gives all positions that need to be fixed.

Indention is 4 spaces (welcome to the python world).

HOW TO SUBMIT STUFF FOR INCLUSION INTO UPSTREAM CDIST
-----------------------------------------------------
If you did some cool changes to cdist, which you value as a benefit for
everybody using cdist, you're welcome to propose inclusion into upstream.

There are though some requirements to ensure your changes don't break others
work nor kill the authors brain:

- All files should contain the usual header (Author, Copying, etc.)
- Code submission must be done via git
- Do not add `cdist/conf/manifest/init` - This file should only be touched in your
  private branch!
- Code to be included should be branched of the upstream "master" branch
   - Exception: Bugfixes to a version branch
- On a merge request, always name the branch I should pull from
- Always ensure **all** manpages build. Use `./build man` to test.
- If you developed more than **one** feature, consider submitting them in
  separate branches. This way one feature can already be included, even if
  the other needs to be improved.

As soon as your work meets these requirements, write a mail
for inclusion to the mailinglist _cdist at cdist -- at -- l.schottelius.org_
or open a pull request at http://github.com/telmich/cdist.


HOW TO SUBMIT A NEW TYPE
------------------------
For detailled information about types, see cdist-type(7).

Submitting a type works as described above, with the additional requirement
that a corresponding manpage named man.text in asciidoc format with
the manpage-name `cdist-type__NAME` is included in the type directory
AND asciidoc is able to compile it (i.e. do NOT have to many `=` in the second
line).

Warning: Submitting "exec" or "run" types that simply echo their parameter in
`gencode-*` will not be accepted, because they are of no use. Every type can output
code and thus such a type introduces redundant functionality that is given by
core cdist already.


EXAMPLE GIT WORKFLOW
---------------------
The following workflow works fine for most developers:

```sh
# get latest upstream master branch
git clone https://github.com/telmich/cdist.git

# update if already existing
cd cdist; git fetch -v; git merge origin/master

# create a new branch for your feature/bugfix
cd cdist # if you haven't done before
git checkout -b documentation_cleanup

# *hack*
*hack*

# clone the cdist repository on github if you haven't done so

# configure your repo to know about your clone (only once)
git remote add github git@github.com:YOURUSERNAME/cdist.git

# push the new branch to github 
git push github documentation_cleanup

# (or everything)
git push --mirror github

# create a pull request at github (use a browser)
# *fixthingsbecausequalityassurancefoundissuesinourpatch*
*hack*

# push code to github again
git push ... # like above

# add comment that everything should be green now (use a browser)

# go back to master branch
git checkout master

# update master branch that includes your changes now
git fetch -v origin
git diff master..origin/master
git merge origin/master
```

If at any point you want to go back to the original master branch, you can
use `git stash` to stash your changes away:

```sh
# assume you are on documentation_cleanup
git stash

# change to master and update to most recent upstream version
git checkout master
git fetch -v origin
git merge origin/master
```

Similar when you want to develop another new feature, you go back
to the master branch and create another branch based on it:

```sh
# change to master and update to most recent upstream version
git checkout master
git fetch -v origin
git merge origin/master

git checkout -b another_feature
```

(you can repeat the code above for as many features as you want to develop
in parallel)


SEE ALSO
--------
For more information see the docs in the `doc/` dir.


COPYING
-------
Copyright (C) 2011-2013 Nico Schottelius. Free use of this software is
granted under the terms of the GNU General Public License version 3 (GPLv3).
