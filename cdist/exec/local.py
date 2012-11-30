# -*- coding: utf-8 -*-
#
# 2011 Steven Armstrong (steven-cdist at armstrong.cc)
# 2011-2012 Nico Schottelius (nico-cdist at schottelius.org)
#
# This file is part of cdist.
#
# cdist is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cdist is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cdist. If not, see <http://www.gnu.org/licenses/>.
#
#

import io
import os
import sys
import re
import subprocess
import shutil
import logging

import cdist
from cdist import core

class Local(object):
    """Execute commands locally.

    All interaction with the local side should be done through this class.
    Directly accessing the local side from python code is a bug.

    """
    def __init__(self, target_host, out_path, exec_path, add_conf_dirs=None, cache_dir=None):

        self.target_host = target_host
        self.out_path = out_path
        self.exec_path = exec_path

        self._add_conf_dirs = add_conf_dirs

        self._init_log()
        self._init_permissions()
        self._init_paths()
        self._init_cache_dir(cache_dir)
        self._init_conf_dirs()

    @property
    def dist_conf_dir(self):
        return os.path.abspath(os.path.join(os.path.dirname(cdist.__file__), "conf"))

    @property
    def home_dir(self):
        if 'HOME' in os.environ:
            return os.path.join(os.environ['HOME'], ".cdist")
        else:
            return None

    def _init_log(self):
        self.log = logging.getLogger(self.target_host)

    def _init_permissions(self):
        # Setup file permissions using umask
        os.umask(0o077)

    def _init_paths(self):
        # Depending on out_path
        self.bin_path = os.path.join(self.out_path, "bin")
        self.conf_path = os.path.join(self.out_path, "conf")
        self.global_explorer_out_path = os.path.join(self.out_path, "explorer")
        self.object_path = os.path.join(self.out_path, "object")

        # Depending on conf_path
        self.global_explorer_path = os.path.join(self.conf_path, "explorer")
        self.manifest_path = os.path.join(self.conf_path, "manifest")
        self.type_path = os.path.join(self.conf_path, "type")

    def _init_conf_dirs(self):
        self.conf_dirs = []

        # Comes with the distribution
        system_conf_dir = os.path.abspath(os.path.join(os.path.dirname(cdist.__file__), "conf"))
        self.conf_dirs.append(system_conf_dir)

        # Is the default place for user created explorer, type and manifest
        if self.home_dir:
            self.conf_dirs.append(self.home_dir)

        # Add directories defined in the CDIST_PATH environment variable
        if 'CDIST_PATH' in os.environ:
            cdist_path_dirs = re.split(r'(?<!\\):', os.environ['CDIST_PATH'])
            cdist_path_dirs.reverse()
            self.conf_dirs.extend(cdist_path_dirs)

        # Add user supplied directories
        if self._add_conf_dirs:
            self.conf_dirs.extend(self._add_conf_dirs)

    def _init_cache_dir(self, cache_dir):
        if cache_dir:
            self.cache_path = cache_dir
        else:
            if self.home_dir:
                self.cache_path = os.path.join(self.home_dir, "cache")
            else:
                raise cdist.Error("No homedir setup and no cache dir location given")

    def rmdir(self, path):
        """Remove directory on the local side."""
        self.log.debug("Local rmdir: %s", path)
        shutil.rmtree(path)

    def mkdir(self, path):
        """Create directory on the local side."""
        self.log.debug("Local mkdir: %s", path)
        os.makedirs(path, exist_ok=True)

    def run(self, command, env=None, return_output=False):
        """Run the given command with the given environment.
        Return the output as a string.

        """
        assert isinstance(command, (list, tuple)), "list or tuple argument expected, got: %s" % command
        self.log.debug("Local run: %s", command)

        if env is None:
            env = os.environ.copy()
        # Export __target_host for use in __remote_{copy,exec} scripts
        env['__target_host'] = self.target_host

        try:
            if return_output:
                return subprocess.check_output(command, env=env).decode()
            else:
                subprocess.check_call(command, env=env)
        except subprocess.CalledProcessError:
            raise cdist.Error("Command failed: " + " ".join(command))
        except OSError as error:
            raise cdist.Error(" ".join(*args) + ": " + error.args[1])

    def run_script(self, script, env=None, return_output=False):
        """Run the given script with the given environment.
        Return the output as a string.

        """
        command = ["/bin/sh", "-e"]
        command.append(script)

        return self.run(command, env, return_output)

    def create_files_dirs(self):
        self._create_context_dirs()
        self._create_conf_path_and_link_conf_dirs()
        self._link_types_for_emulator()

    def _create_context_dirs(self):
        self.mkdir(self.out_path)

        self.mkdir(self.conf_path)
        self.mkdir(self.global_explorer_out_path)
        self.mkdir(self.bin_path)

    def _create_conf_path_and_link_conf_dirs(self):
        # Link destination directories
        for sub_dir in [ "explorer", "manifest", "type" ]:
            self.mkdir(os.path.join(self.conf_path, sub_dir))

        # Iterate over all directories and link the to the output dir
        for conf_dir in self.conf_dirs:
            self.log.debug("Checking conf_dir %s ..." % (conf_dir))
            for sub_dir in [ "explorer", "manifest", "type" ]:
                current_dir = os.path.join(conf_dir, sub_dir)

                # Allow conf dirs to contain only partial content
                if not os.path.exists(current_dir):
                    continue

                for entry in os.listdir(current_dir):
                    rel_entry_path = os.path.join(sub_dir, entry)
                    src = os.path.join(conf_dir, sub_dir, entry)
                    dst = os.path.join(self.conf_path, sub_dir, entry)

                    # Already exists? remove and link
                    if os.path.exists(dst):
                        os.unlink(dst)
                    
                    self.log.debug("Linking %s to %s ..." % (src, dst))
                    try:
                        os.symlink(src, dst)
                    except OSError as e:
                        raise cdist.Error("Linking %s %s to %s failed: %s" % (sub_dir, src, dst, e.__str__()))

    def _link_types_for_emulator(self):
        """Link emulator to types"""
        src = os.path.abspath(self.exec_path)
        for cdist_type in core.CdistType.list_types(self.type_path):
            dst = os.path.join(self.bin_path, cdist_type.name)
            self.log.debug("Linking emulator: %s to %s", src, dst)

            try:
                os.symlink(src, dst)
            except OSError as e:
                raise cdist.Error("Linking emulator from %s to %s failed: %s" % (src, dst, e.__str__()))
