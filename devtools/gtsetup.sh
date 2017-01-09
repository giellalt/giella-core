#!/bin/bash
#
# Shell script for preparing the user's shell startup scripts for Giellatekno

# Giellatekno - a set of tools for analysing and processing a number
#               of human languages, expecially but not restricted to
#               the Sámi languages. The Giellatekno toolset also includes
#               support for buildling end-user tools such as proofing
#               tools and electronic dictionaries.
# The setup and init scripts (ao this file) are based on similar scripts
#               from the Fink project (http://www.finkproject.org/).
# This file is based on the file /sw/bin/pathsetup.sh in the Fink distro.
# Copyright (c) 2003-2005 Martin Costabel
# Copyright (c) 2003-2007 The Fink Package Manager Team
# Copyright (c) 2009-2011 The Divvun and Giellatekno teams
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


# This version is tested for csh type user login shells and for bash, 
# for other sh type shells it does nothing.

# The following environmental variables are defined:
#
# export GTHOME - location of the main svn working copy, always defined
# export GTBIG - location of the biggies working copy, only if the biggies
#                 repository is checked out
# export GTPRIV - location of the private working copy, only if the private
#                 repository is checked out
# 

# Where am I:
case "$0" in
    /*)
        SCRIPTPATH=$(dirname "$0")
        ;;
    *)
        PWD=`pwd`
        SCRIPTPATH=$(dirname "$PWD/$0")
        ;;
esac

# Global variables:
BACKUPSUFF=gtbackup
NEWSUFF=gtnew

# source common functions and settings
source "${SCRIPTPATH}"/shfunctions.d/gtsetupenvtesting.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetupcommondialogs.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetupmain.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetupbiggies.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetupfreecorpus.sh
source "${SCRIPTPATH}"/shfunctions.d/gtsetuppriv.sh

### Main program:

# A temporary file for communicating with a login shell 
# mktemp is in different places on mac and linux
if [ -x /usr/bin/mktemp ] || [ -x /bin/mktemp ] ; then
    TMPFILE=`mktemp /tmp/resu.XXXXXX`
fi

# Are we logged in at the console?
do_isconsole

# Run a login shell to see whether the Giellatekno paths are already set up.
do_login_test

# Check whether the environment is already in place:
if grep GTHOME $TMPFILE >/dev/null 2>&1 ; then
    main_setup_done=YES
fi
if grep GTBIG $TMPFILE >/dev/null 2>&1 ; then
    big_setup_done=YES
fi
if grep GTFREE $TMPFILE >/dev/null 2>&1 ; then
    free_setup_done=YES
fi
if grep GTPRIV $TMPFILE >/dev/null 2>&1 ; then
    priv_setup_done=YES
fi

if ( [ "$big_setup_done"  == "YES" ] ) ; then
	check_links
fi

# Variable to record whether the RC file was actually changed:
RC_CHANGED=NO
ALL_RC_CHANGES=""

# Look whether $GTHOME was in the ENV.
# TODO: Test for other sensible things, too. 
if ( [ "$main_setup_done" == "YES" ] &&
     [ "$big_setup_done"  == "YES" ] &&
     [ "$free_setup_done" == "YES" ] &&
     [ "$priv_setup_done" == "YES" ] &&
     [ "$links_ok"        == "YES" ]  ) ; then
    # Yes: everything is already set up
    display_already_setup
elif ( [ "$main_setup_done" == "YES" ] &&
       [ "$big_setup_done"  == "YES" ] &&
       [ "$free_setup_done" == "YES" ] &&
       [ "$priv_setup_done" == "YES" ] &&
       [ "$links_ok"        == "NO"  ]  ) ; then
    # Yes: everything but links are already set up
    display_mostly_setup
    link_biggies
    display_links_done
else
    # No: we need to do something

    # Set GTHOME based on the location of this setup script.
    # Does also check for the existence of big and private working copies.
    set_gthome

    eval `grep LOGINSHELL $TMPFILE`
    if [ -z $LOGINSHELL ]; then
        Result="\nYour startup scripts contain an error.\nI am giving up. Bye.\n"
        display_result
        exit
    fi
    LOGINSHELL=`basename $LOGINSHELL`
    case $LOGINSHELL in
    *csh)
        # For csh and tcsh
        src_command_csh
        big_command_csh
        free_command_csh
        priv_command_csh
        init_command_csh
        if [ -f $HOME/.tcshrc ]; then
            RC=.tcshrc
        elif [ -f $HOME/.cshrc ]; then
            RC=.cshrc
        else
            RC=new
        fi
         case $RC in
        new)
            RC=.cshrc
            MSG=msg_create
            ;;
        *)
            MSG=msg_append
            make_RC_backup
            ;;
        esac
        if [ "$main_setup_done" == "YES" ]; then
            if [ "$big_setup_done" == "YES" ]; then
                if [ "$free_setup_done" == "YES" ]; then
                    # Set up priv only, the rest is ok:
                    display_setup_priv
                else
                    # Set up priv and free
                    setup_free
                    display_setup_priv
                fi
            else
                setup_big
                setup_free
                display_setup_priv
            fi
        else
            # set up all four:
            display_choose_do
            setup_big
            setup_free
            display_setup_priv
        fi
        add_init_command
        ;;
    bash)
        # Only bash here; other sh type shells are not supported
        src_command_sh
        big_command_sh
        free_command_sh
        priv_command_sh
        init_command_sh
        if [ -f $HOME/.bash_profile ]; then
            RC=.bash_profile
        elif [ -f $HOME/.bash_login ]; then
            RC=.bash_login
        elif [ -f $HOME/.profile ]; then
            RC=.profile
        elif [ -f $HOME/.bashrc ]; then
            RC=.bashrc
        else
            RC=new
        fi
        case $RC in
          new)
            RC=.profile
            MSG=msg_create
          ;;
          *)
            MSG=msg_append
            make_RC_backup
          ;;
        esac
        if [ "$main_setup_done" == "YES" ]; then
            if [ "$big_setup_done" == "YES" ]; then
                if [ "$free_setup_done" == "YES" ]; then
                    # Set up priv only, the rest is ok:
                    display_setup_priv
                else
                    # Set up priv and free
                    setup_free
                    display_setup_priv
                fi
            else
                setup_big
                setup_free
                display_setup_priv
            fi
        else
            # set up all four:
            display_choose_do
            setup_big
            setup_free
            display_setup_priv
        fi
        add_init_command
        if [ "$RC_CHANGED" == "YES" ]; then
          confirm_changes
        else
          undo_setup
        fi
        ;;
    *)
    # Any shell except *csh and bash
    Result="\n
Since you have changed your login shell to $LOGINSHELL,
I am confident that you know what you are doing.\n
So now add lines equivalent to
    
    export GTHOME=$GTHOME
    export GTBIG=$GTBIG
    export GTFREE=$GTFREE
    export GTPRIV=$GTPRIV
    source \$GTHOME/gt/script/init.d/init.sh

to one of your $LOGINSHELL startup scripts
and you will be set up for using the Giellatekno tools.
    
    Have a nice day.
        \n"
    display_result
    ;;
    esac
fi

rm -f $TMPFILE

# End of program.
