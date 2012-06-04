# -*- coding: utf-8 -*-
#
# 2010-2012 Nico Schottelius (nico-cdist at schottelius.org)
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

import os
import subprocess

try:
    with open(os.devnull, 'w') as devnull:
        here = os.path.dirname(os.path.realpath(__file__))
        VERSION = subprocess.check_output(
                    'cd "%s" && git describe' % here,
                    stderr=devnull, shell=True).decode('utf-8')
except:
    VERSION     = "2.0.12"

BANNER = """
             ..          .       .x+=:.        s
           dF           @88>    z`    ^%      :8
          '88bu.        %8P        .   <k    .88
      .   '*88888bu      .       .@8Ned8"   :888ooo
 .udR88N    ^"*8888N   .@88u   .@^%8888"  -*8888888
<888'888k  beWE "888L ''888E` x88:  `)8b.   8888
9888 'Y"   888E  888E   888E  8888N=*8888   8888
9888       888E  888E   888E   %8"    R88   8888
9888       888E  888F   888E    @8Wou 9%   .8888Lu=
?8888u../ .888N..888    888&  .888888P`    ^%888*
 "8888P'   `"888*""     R888" `   ^"F        'Y"
   "P'        ""         ""
"""
DOT_CDIST   = ".cdist"


class Error(Exception):
    """Base exception class for this project"""
    pass

class CdistObjectError(Error):
    """Something went wrong with an object"""
    
    def __init__(self, cdist_object, message):
        self.name = cdist_object.name
        self.source = " ".join(cdist_object.source)
        self.message = message


    def __str__(self):
        return '%s: %s (defined at %s)' % (self.name, self.message, self.source)

def file_to_list(filename):
    """Return list from \n seperated file"""
    if os.path.isfile(filename):
        file_fd = open(filename, "r")
        lines = file_fd.readlines()
        file_fd.close()

        # Remove \n from all lines
        lines = map(lambda s: s.strip(), lines)
    else:
        lines = []

    return lines
