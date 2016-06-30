cdist-type__line(7)
===================

NAME
----
cdist-type__line - Manage lines in files


DESCRIPTION
-----------
This cdist type allows you to add lines and remove lines from files.


REQUIRED PARAMETERS
-------------------

OPTIONAL PARAMETERS
-------------------
state
    'present' or 'absent', defaults to 'present'

line
    Specifies the line which should be absent or present

    Must be present, if state is present.
    Must not be combined with regex, if state is absent.

regex
    If state is present, search for this pattern and add
    given line, if the given regular expression does not match.

    In case of absent, ensure all lines matching the
    regular expression are absent.

    The regular expression is interpreted by grep.

    Must not be combined with line, if state is absent.

file
    If supplied, use this as the destination file.
    Otherwise the object_id is used.

onchange::
   the code to run if the file changes


EXAMPLES
--------

.. code-block:: sh

    # Manage the DAEMONS line in rc.conf
    __line daemons --file /etc/rc.conf --line 'DAEMONS=(hwclock !network sshd crond postfix)'

    # Ensure the home mount is present in /etc/fstab - explicitly make it present
    __line home-fstab \
        --file /etc/fstab \
        --line 'filer.fs:/vol/home /home  nfs    defaults        0 0' \
        --onchange 'mount /home' \
        --state present

    # Removes the line specifiend in "include_www" from the file "lighttpd.conf"
    __line legacy_timezone --file /etc/rc.conf --regex 'TIMEZONE=.*' --state absent


SEE ALSO
--------
:manpage:`grep`\ (1)


AUTHORS
-------
Nico Schottelius <nico-cdist--@--schottelius.org>


COPYING
-------
Copyright \(C) 2012-2013 Nico Schottelius. Free use of this software is
granted under the terms of the GNU General Public License version 3 (GPLv3).
