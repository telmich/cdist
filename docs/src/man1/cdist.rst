cdist(1)
========

NAME
----
cdist - Usable Configuration Management


SYNOPSIS
--------

::

    cdist [-h] [-q] [-v] [-V] {banner,config,install,inventory,shell} ...

    cdist banner [-h] [-q] [-v]

    cdist config [-h] [-q] [-v] [-b] [-C CACHE_PATH_PATTERN] [-c CONF_DIR]
                 [-i MANIFEST] [-j [JOBS]] [-n] [-o OUT_PATH]
                 [-R [{tar,tgz,tbz2,txz}]] [-r REMOTE_OUT_DIR]
                 [--remote-copy REMOTE_COPY] [--remote-exec REMOTE_EXEC]
                 [-I INVENTORY_DIR] [-A] [-a] [-f HOSTFILE] [-p [HOST_MAX]]
                 [-s] [-t]
                 [host [host ...]] 

    cdist install [-h] [-q] [-v] [-b] [-C CACHE_PATH_PATTERN] [-c CONF_DIR]
                  [-i MANIFEST] [-j [JOBS]] [-n] [-o OUT_PATH]
                  [-R [{tar,tgz,tbz2,txz}]] [-r REMOTE_OUT_DIR]
                  [--remote-copy REMOTE_COPY] [--remote-exec REMOTE_EXEC]
                  [-I INVENTORY_DIR] [-A] [-a] [-f HOSTFILE] [-p [HOST_MAX]]
                  [-s] [-t]
                  [host [host ...]] 

    cdist inventory [-h] [-q] [-v] [-b] [-I INVENTORY_DIR]
                    {add-host,add-tag,del-host,del-tag,list} ...

    cdist inventory add-host [-h] [-q] [-v] [-b] [-I INVENTORY_DIR]
                             [-f HOSTFILE]
                             [host [host ...]]

    cdist inventory add-tag [-h] [-q] [-v] [-b] [-I INVENTORY_DIR]
                            [-f HOSTFILE] [-T TAGFILE] [-t TAGLIST]
                            [host [host ...]]

    cdist inventory del-host [-h] [-q] [-v] [-b] [-I INVENTORY_DIR] [-a]
                             [-f HOSTFILE]
                             [host [host ...]]

    cdist inventory del-tag [-h] [-q] [-v] [-b] [-I INVENTORY_DIR] [-a]
                            [-f HOSTFILE] [-T TAGFILE] [-t TAGLIST]
                            [host [host ...]]

    cdist inventory list [-h] [-q] [-v] [-b] [-I INVENTORY_DIR] [-a]
                         [-f HOSTFILE] [-H] [-t]
                         [host [host ...]]

    cdist shell [-h] [-q] [-v] [-s SHELL]


DESCRIPTION
-----------
cdist is the frontend executable to the cdist configuration management.
It supports different subcommands as explained below.

It is written in Python so it requires :strong:`python`\ (1) to be installed.
It requires a minimal Python version 3.2.

GENERAL
-------
All commands accept the following options:

.. option:: -h, --help

    Show the help screen.

.. option:: -q, --quiet

    Quiet mode: disables logging, including WARNING and ERROR.

.. option:: -v, --verbose

    Increase the verbosity level. Every instance of -v increments the verbosity
    level by one. Its default value is 0 which includes ERROR and WARNING levels.
    The levels, in order from the lowest to the highest, are: 
    ERROR (-1), WARNING (0), INFO (1), VERBOSE (2), DEBUG (3) TRACE (4 or higher).

.. option:: -V, --version

   Show version and exit.


BANNER
------
Displays the cdist banner. Useful for printing
cdist posters - a must have for every office.


CONFIG/INSTALL
--------------
Configure/install one or more hosts.
Install command is currently in beta.

.. option:: -A, --all-tagged

    Use all hosts present in tags db. Currently in beta.

.. option:: -a, --all

    List hosts that have all specified tags, if -t/--tag
    is specified.

.. option:: -b, --beta

    Enable beta functionality.

.. option:: -C CACHE_PATH_PATTERN, --cache-path-pattern CACHE_PATH_PATTERN

    Sepcify custom cache path pattern. If it is not set then
    default hostdir is used. For more info on format see
    :strong:`CACHE PATH PATTERN FORMAT` below.

.. option:: -c CONF_DIR, --conf-dir CONF_DIR

    Add a configuration directory. Can be specified multiple times.
    If configuration directories contain conflicting types, explorers or
    manifests, then the last one found is used.

.. option:: -f HOSTFILE, --file HOSTFILE

    Read specified file for a list of additional hosts to operate on
    or if '-' is given, read stdin (one host per line).
    If no host or host file is specified then, by default,
    read hosts from stdin. For the file format see
    :strong:`HOSTFILE FORMAT` below.

.. option:: -I INVENTORY_DIR, --inventory INVENTORY_DIR

    Use specified custom inventory directory. Inventory
    directory is set up by the following rules: if this
    argument is set then specified directory is used, if
    CDIST_INVENTORY_DIR env var is set then its value is
    used, if HOME env var is set then ~/.cdit/inventory is
    used, otherwise distribution inventory directory is
    used.

.. option:: -i MANIFEST, --initial-manifest MANIFEST

    Path to a cdist manifest or - to read from stdin.

.. option:: -j [JOBS], --jobs [JOBS]

    Operate in parallel in specified maximum number of
    jobs. Global explorers, object prepare and object run
    are supported. Without argument CPU count is used by
    default. Currently in beta.

.. option:: -n, --dry-run

    Do not execute code.

.. option:: -o OUT_PATH, --out-dir OUT_PATH

    Directory to save cdist output in.

.. option:: -p [HOST_MAX], --parallel [HOST_MAX]

    Operate on multiple hosts in parallel for specified
    maximum hosts at a time. Without argument CPU count is
    used by default.

.. option:: -R [{tar,tgz,tbz2,txz}], --use-archiving [{tar,tgz,tbz2,txz}]

    Operate by using archiving with compression where
    appropriate. Supported values are: tar - tar archive,
    tgz - gzip tar archive (the default), tbz2 - bzip2 tar
    archive and txz - lzma tar archive. Currently in beta.

.. option:: -r REMOTE_OUT_PATH, --remote-out-dir REMOTE_OUT_PATH

    Directory to save cdist output in on the target host.

.. option:: -s, --sequential

    Operate on multiple hosts sequentially (default).

.. option:: --remote-copy REMOTE_COPY

    Command to use for remote copy (should behave like scp).

.. option:: --remote-exec REMOTE_EXEC

    Command to use for remote execution (should behave like ssh).

.. option:: -t, --tag

    Host is specified by tag, not hostname/address; list
    all hosts that contain any of specified tags.
    Currently in beta.

HOSTFILE FORMAT
~~~~~~~~~~~~~~~
The HOSTFILE contains one host per line.
A comment is started with '#' and continues to the end of the line.
Any leading and trailing whitespace on a line is ignored.
Empty lines are ignored/skipped.


The Hostfile lines are processed as follows. First, all comments are
removed. Then all leading and trailing whitespace characters are stripped.
If such a line results in empty line it is ignored/skipped. Otherwise,
host string is used.

CACHE PATH PATTERN FORMAT
~~~~~~~~~~~~~~~~~~~~~~~~~
Cache path pattern specifies path for a cache directory subdirectory.
In the path, '%N' will be substituted by the target host, '%h' will
be substituted by the calculated host directory, '%P' will be substituted
by the current process id. All format codes that
:strong:`python` :strong:`datetime.strftime()` function supports, except
'%h', are supported. These date/time directives format cdist config/install
start time.

If empty pattern is specified then default calculated host directory
is used.

Calculated host directory is a hash of a host cdist operates on.

Resulting path is used to specify cache path subdirectory under which
current host cache data are saved.


INVENTORY
---------
Manage inventory database.
Currently in beta with all sub-commands.


INVENTORY ADD-HOST
------------------
Add host(s) to inventory database.

.. option:: host

    Host(s) to add.

.. option:: -b, --beta

    Enable beta functionality.

.. option:: -f HOSTFILE, --file HOSTFILE

    Read additional hosts to add from specified file or
    from stdin if '-' (each host on separate line). If no
    host or host file is specified then, by default, read
    from stdin. Hostfile format is the same as config hostfile format.


.. option:: -I INVENTORY_DIR, --inventory INVENTORY_DIR

    Use specified custom inventory directory. Inventory
    directory is set up by the following rules: if this
    argument is set then specified directory is used, if
    CDIST_INVENTORY_DIR env var is set then its value is
    used, if HOME env var is set then ~/.cdist/inventory is
    used, otherwise distribution inventory directory is
    used.


INVENTORY ADD-TAG
-----------------
Add tag(s) to inventory database.

.. option:: host

    List of host(s) for which tags are added.

.. option:: -b, --beta

    Enable beta functionality.

.. option:: -f HOSTFILE, --file HOSTFILE

    Read additional hosts to add tags from specified file
    or from stdin if '-' (each host on separate line). If
    no host or host file is specified then, by default,
    read from stdin. If no tags/tagfile nor hosts/hostfile
    are specified then tags are read from stdin and are
    added to all hosts. Hostfile format is the same as config hostfile format.

.. option:: -I INVENTORY_DIR, --inventory INVENTORY_DIR

    Use specified custom inventory directory. Inventory
    directory is set up by the following rules: if this
    argument is set then specified directory is used, if
    CDIST_INVENTORY_DIR env var is set then its value is
    used, if HOME env var is set then ~/.cdist/inventory is
    used, otherwise distribution inventory directory is
    used.

.. option:: -T TAGFILE, --tag-file TAGFILE

    Read additional tags to add from specified file or
    from stdin if '-' (each tag on separate line). If no
    tag or tag file is specified then, by default, read
    from stdin. If no tags/tagfile nor hosts/hostfile are
    specified then tags are read from stdin and are added
    to all hosts. Tagfile format is the same as config hostfile format.

.. option:: -t TAGLIST, --taglist TAGLIST

    Tag list to be added for specified host(s), comma
    separated values.


INVENTORY DEL-HOST
------------------
Delete host(s) from inventory database.

.. option:: host

    Host(s) to delete.

.. option:: -a, --all

    Delete all hosts.

.. option:: -b, --beta

    Enable beta functionality.

.. option:: -f HOSTFILE, --file HOSTFILE

    Read additional hosts to delete from specified file or
    from stdin if '-' (each host on separate line). If no
    host or host file is specified then, by default, read
    from stdin. Hostfile format is the same as config hostfile format.

.. option:: -I INVENTORY_DIR, --inventory INVENTORY_DIR

    Use specified custom inventory directory. Inventory
    directory is set up by the following rules: if this
    argument is set then specified directory is used, if
    CDIST_INVENTORY_DIR env var is set then its value is
    used, if HOME env var is set then ~/.cdist/inventory is
    used, otherwise distribution inventory directory is
    used.


INVENTORY DEL-TAG
-----------------
Delete tag(s) from inventory database.

.. option:: host

    List of host(s) for which tags are deleted.

.. option:: -a, --all

    Delete all tags for specified host(s).

.. option:: -b, --beta

    Enable beta functionality.

.. option:: -f HOSTFILE, --file HOSTFILE

    Read additional hosts to delete tags for from
    specified file or from stdin if '-' (each host on
    separate line). If no host or host file is specified
    then, by default, read from stdin. If no tags/tagfile
    nor hosts/hostfile are specified then tags are read
    from stdin and are deleted from all hosts. Hostfile
    format is the same as config hostfile format.

.. option:: -I INVENTORY_DIR, --inventory INVENTORY_DIR

    Use specified custom inventory directory. Inventory
    directory is set up by the following rules: if this
    argument is set then specified directory is used, if
    CDIST_INVENTORY_DIR env var is set then its value is
    used, if HOME env var is set then ~/.cdist/inventory is
    used, otherwise distribution inventory directory is
    used.

.. option:: -T TAGFILE, --tag-file TAGFILE

    Read additional tags from specified file or from stdin
    if '-' (each tag on separate line). If no tag or tag
    file is specified then, by default, read from stdin.
    If no tags/tagfile nor hosts/hostfile are specified
    then tags are read from stdin and are added to all
    hosts. Tagfile format is the same as config hostfile format.

.. option:: -t TAGLIST, --taglist TAGLIST

    Tag list to be deleted for specified host(s), comma
    separated values.


INVENTORY LIST
--------------
List inventory database.

.. option::  host

    Host(s) to list.

.. option:: -a, --all

    List hosts that have all specified tags, if -t/--tag
    is specified.

.. option:: -b, --beta

    Enable beta functionality.

.. option:: -f HOSTFILE, --file HOSTFILE

    Read additional hosts to list from specified file or
    from stdin if '-' (each host on separate line). If no
    host or host file is specified then, by default, list
    all. Hostfile format is the same as config hostfile format.

.. option:: -H, --host-only

    Suppress tags listing.

.. option:: -I INVENTORY_DIR, --inventory INVENTORY_DIR

    Use specified custom inventory directory. Inventory
    directory is set up by the following rules: if this
    argument is set then specified directory is used, if
    CDIST_INVENTORY_DIR env var is set then its value is
    used, if HOME env var is set then ~/.cdist/inventory is
    used, otherwise distribution inventory directory is
    used.

.. option:: -t, --tag

    Host is specified by tag, not hostname/address; list
    all hosts that contain any of specified tags.


SHELL
-----
This command allows you to spawn a shell that enables access
to the types as commands. It can be thought as an
"interactive manifest" environment. See below for example
usage. Its primary use is for debugging type parameters.

.. option:: -s SHELL, --shell SHELL

    Select shell to use, defaults to current shell. Used shell should
    be POSIX compatible shell.


FILES
-----
~/.cdist
    Your personal cdist config directory. If exists it will be
    automatically used.
~/.cdist/inventory
    The home inventory directory. If ~/.cdist exists it will be used as
    default inventory directory.
cdist/conf
    The distribution configuration directory. It contains official types and
    explorers. This path is relative to cdist installation directory.
cdist/inventory
    The distribution inventory directory.
    This path is relative to cdist installation directory.

NOTES
-----
cdist detects if host is specified by IPv6 address. If so then remote_copy
command is executed with host address enclosed in square brackets 
(see :strong:`scp`\ (1)).

EXAMPLES
--------

.. code-block:: sh

    # Configure ikq05.ethz.ch with debug enabled
    % cdist config -vvv ikq05.ethz.ch

    # Configure hosts in parallel and use a different configuration directory
    % cdist config -c ~/p/cdist-nutzung \
        -p ikq02.ethz.ch ikq03.ethz.ch ikq04.ethz.ch

    # Use custom remote exec / copy commands
    % cdist config --remote-exec /path/to/my/remote/exec \
        --remote-copy /path/to/my/remote/copy \
        -p ikq02.ethz.ch ikq03.ethz.ch ikq04.ethz.ch

    # Configure hosts read from file loadbalancers
    % cdist config -f loadbalancers

    # Configure hosts read from file web.hosts using 16 parallel jobs
    # (beta functionality)
    % cdist config -b -j 16 -f web.hosts

    # Display banner
    cdist banner

    # Show help
    % cdist --help

    # Show Version
    % cdist --version

    # Enter a shell that has access to emulated types
    % cdist shell
    % __git
    usage: __git --source SOURCE [--state STATE] [--branch BRANCH]
                 [--group GROUP] [--owner OWNER] [--mode MODE] object_id

    # Install ikq05.ethz.ch with debug enabled
    % cdist install -vvv ikq05.ethz.ch

    # List inventory content
    % cdist inventory list -b

    # List inventory for specified host localhost
    % cdist inventory list -b localhost

    # List inventory for specified tag loadbalancer
    % cdist inventory list -b -t loadbalancer

    # Add hosts to inventory
    % cdist inventory add-host -b web1 web2 web3

    # Delete hosts from file old-hosts from inventory
    % cdist inventory del-host -b -f old-hosts

    # Add tags to specifed hosts
    % cdist inventory add-tag -b -t europe,croatia,web,static web1 web2

    # Add tag to all hosts in inventory
    % cdist inventory add-tag -b -t vm

    # Delete all tags from specified host
    % cdist inventory del-tag -b -a localhost

    # Delete tags read from stdin from hosts specified by file hosts
    % cdist inventory del-tag -b -T - -f hosts

    # Configure hosts from inventory with any of specified tags
    % cdist config -b -t web dynamic

    # Configure hosts from inventory with all specified tags
    % cdist config -b -t -a web dynamic

    # Configure all hosts from inventory db
    $ cdist config -b -A


ENVIRONMENT
-----------
TMPDIR, TEMP, TMP
    Setup the base directory for the temporary directory.
    See http://docs.python.org/py3k/library/tempfile.html for
    more information. This is rather useful, if the standard
    directory used does not allow executables.

CDIST_PATH
    Colon delimited list of config directories.

CDIST_LOCAL_SHELL
    Selects shell for local script execution, defaults to /bin/sh.

CDIST_REMOTE_SHELL
    Selects shell for remote script execution, defaults to /bin/sh.

CDIST_OVERRIDE
    Allow overwriting type parameters.

CDIST_ORDER_DEPENDENCY
    Create dependencies based on the execution order.

CDIST_REMOTE_EXEC
    Use this command for remote execution (should behave like ssh).

CDIST_REMOTE_COPY
    Use this command for remote copy (should behave like scp).

CDIST_INVENTORY_DIR
    Use this directory as inventory directory.

CDIST_BETA
    Enable beta functionality.

CDIST_CACHE_PATH_PATTERN
    Custom cache path pattern.

EXIT STATUS
-----------
The following exit values shall be returned:

0   Successful completion.

1   One or more host configurations failed.


AUTHORS
-------
Originally written by Nico Schottelius <nico-cdist--@--schottelius.org>
and Steven Armstrong <steven-cdist--@--armstrong.cc>.


CAVEATS
-------
When operating in parallel, either by operating in parallel for each host
(-p/--parallel) or by parallel jobs within a host (-j/--jobs), and depending
on target SSH server and its configuration you may encounter connection drops.
This is controlled with sshd :strong:`MaxStartups` configuration options.
You may also encounter session open refusal. This happens with ssh multiplexing
when you reach maximum number of open sessions permitted per network
connection. In this case ssh will disable multiplexing.
This limit is controlled with sshd :strong:`MaxSessions` configuration
options. For more details refer to :strong:`sshd_config`\ (5).

When requirements for the same object are defined in different manifests (see
example below), for example, in init manifest and in some other type manifest
and those requirements differ then dependency resolver cannot detect
dependencies correctly. This happens because cdist cannot prepare all objects first
and run all objects afterwards. Some object can depend on the result of type
explorer(s) and explorers are executed during object run. cdist will detect
such case and display a warning message. An example of such a case:

.. code-block:: sh

    init manifest:
        __a a
        require="__e/e" __b b
        require="__f/f" __c c
        __e e
        __f f
        require="__c/c" __d d
        __g g
        __h h

    type __g manifest:
        require="__c/c __d/d" __a a

    Warning message:
        WARNING: cdisttesthost: Object __a/a already exists with requirements:
        /usr/home/darko/ungleich/cdist/cdist/test/config/fixtures/manifest/init-deps-resolver /tmp/tmp.cdist.test.ozagkg54/local/759547ff4356de6e3d9e08522b0d0807/data/conf/type/__g/manifest: set()
        /tmp/tmp.cdist.test.ozagkg54/local/759547ff4356de6e3d9e08522b0d0807/data/conf/type/__g/manifest: {'__c/c', '__d/d'}
        Dependency resolver could not handle dependencies as expected.

COPYING
-------
Copyright \(C) 2011-2017 Nico Schottelius. Free use of this software is
granted under the terms of the GNU General Public License v3 or later (GPLv3+).
