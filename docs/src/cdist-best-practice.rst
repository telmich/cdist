Best practice
=============
Practices used in real environments

Passwordless connections
------------------------
It is recommended to run cdist with public key authentication.
This requires a private/public key pair and the entry
"PermitRootLogin without-password" in the sshd server.
See sshd_config(5) and ssh-keygen(1).


Speeding up ssh connections
---------------------------
When connecting to a new host, the initial delay with ssh connections
is pretty big. As cdist makes many connections to each host successive
connections can be sped up by "sharing of multiple sessions over a single
network connection" (quote from ssh_config(5)). This is also called "connection
multiplexing".

Cdist implements this since v4.0.0 by executing ssh with the appropriate
options (`-o ControlMaster=auto  -o ControlPath=/tmp/<tmpdir>/s  -o
ControlPersist=2h`).

Note that the sshd_config on the server can configure the maximum number of
parallel multiplexed connections this with `MaxSessions N` (N defaults to 10
for OpenSSH v7.4).


Speeding up shell execution
----------------------------
On the source host, ensure that /bin/sh is *not* bash: bash is quite slow for
script execution. Instead, you could use dash after installing it::

    ln -sf /bin/dash /bin/sh


Multi master or environment setups
----------------------------------
If you plan to distribute cdist among servers or use different
environments, you can do so easily with the included version
control git. For instance if you plan to use the typical three
environments production, integration and development, you can
realise this with git branches::

    # Go to cdist checkout
    cd /path/to/cdist

    # Create branches
    git branch development
    git branch integration
    git branch production

    # Make use of a branch, for instance production
    git checkout production

Similar if you want to have cdist checked out at multiple machines,
you can clone it multiple times::

    machine-a % git clone git://your-git-server/cdist
    machine-b % git clone git://your-git-server/cdist


Separating work by groups
-------------------------
If you are working with different groups on one cdist-configuration,
you can delegate to other manifests and have the groups edit only
their manifests. You can use the following snippet in
**conf/manifests/init**::

    # Include other groups
    sh -e "$__manifest/systems"

    sh -e "$__manifest/cbrg"


Maintaining multiple configurations
-----------------------------------
When you need to manage multiple sites with cdist, like company_a, company_b
and private for instance, you can easily use git for this purpose.
Including a possible common base that is reused across the different sites::

    # create branches
    git branch company_a company_b common private

    # make stuff for company a
    git checkout company_a
    # work, commit, etc.

    # make stuff for company b
    git checkout company_b
    # work, commit, etc.

    # make stuff relevant for all sites
    git checkout common
    # work, commit, etc.

    # change to private and include latest common stuff
    git checkout private
    git merge common


The following **.git/config** is taken from a real world scenario::

    # Track upstream, merge from time to time
    [remote "upstream"]
       url = git://git.schottelius.org/cdist
       fetch = +refs/heads/*:refs/remotes/upstream/*

    # Same as upstream, but works when being offline
    [remote "local"]
       fetch = +refs/heads/*:refs/remotes/local/*
       url = /home/users/nico/p/cdist

    # Remote containing various ETH internal branches
    [remote "eth"]
       url = sans.ethz.ch:/home/services/sans/git/cdist-eth
       fetch = +refs/heads/*:refs/remotes/eth/*

    # Public remote that contains my private changes to cdist upstream
    [remote "nico"]
       url = git.schottelius.org:/home/services/git/cdist-nico
       fetch = +refs/heads/*:refs/remotes/nico/*

    # The "nico" branch will be synced with the remote nico, branch master
    [branch "nico"]
       remote = nico
       merge = refs/heads/master

    # ETH stable contains rock solid configurations used in various places
    [branch "eth-stable"]
       remote = eth
       merge = refs/heads/stable

Have a look at git-remote(1) to adjust the remote configuration, which allows


Multiple developers with different trust
----------------------------------------
If you are working in an environment that requires different people to
work on the same configuration, but having different privileges, you can
implement this scenario with a gateway host and sudo:

- Create a dedicated user (for instance **cdist**)
- Setup the ssh-pubkey for this user that has the right to configure all hosts
- Create a wrapper to update the cdist configuration in ~cdist/cdist
- Allow every developer to execute this script via sudo as the user cdist
- Allow run of cdist as user cdist on specific hosts on a per user/group basis.

    - f.i. nico ALL=(ALL) NOPASSWD: /home/cdist/bin/cdist config hostabc

For more details consult sudoers(5)


Templating
----------
* create directory files/ in your type (convention)
* create the template as an executable file like files/basic.conf.sh, it will output text using shell variables for the values

.. code-block:: sh

    #!/bin/sh
    # in the template, use cat << eof (here document) to output the text
    # and use standard shell variables in the template
    # output everything in the template script to stdout
    cat << EOF
    server {
      listen                          80;
      server_name                     $SERVERNAME;
      root                            $ROOT;

      access_log /var/log/nginx/$SERVERNAME_access.log
      error_log /var/log/nginx/$SERVERNAME_error.log
    }
    EOF

* in the manifest, export the relevant variables and add the following lines to your manifest:

.. code-block:: console

    # export variables needed for the template
      export SERVERNAME='test"
      export ROOT='/var/www/test'
    # render the template
      mkdir -p "$__object/files"
      "$__type/files/basic.conf.sh" > "$__object/files/basic.conf"
    # send the rendered template
      __file /etc/nginx/sites-available/test.conf  \
        --state present
        --source "$__object/files/basic.conf"


Testing a new type
------------------
If you want to test a new type on a node, you can tell cdist to only use an
object of this type: Use the '--initial-manifest' parameter
with - (stdin) as argument and feed object into stdin
of cdist:

.. code-block:: sh

    # Singleton type without parameter
    echo __ungleich_munin_server | cdist --initial-manifest - munin.panter.ch

    # Singleton type with parameter
    echo __ungleich_munin_node --allow 1.2.3.4 | \
        cdist --initial-manifest - rails-19.panter.ch

    # Normal type
    echo __file /tmp/stdintest --mode 0644 | \
        cdist --initial-manifest - cdist-dev-01.ungleich.ch


Other content in cdist repository
---------------------------------
Usually the cdist repository contains all configuration
items. Sometimes you may have additional resources that
you would like to store in your central configuration
repository (like password files from KeepassX,
Libreoffice diagrams, etc.).

It is recommended to use a subfolder named "non-cdist"
in the repository for such content: It allows you to
easily distinguish what is used by cdist and what is not
and also to store all important files in one
repository.
