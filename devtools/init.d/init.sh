# init.sh
#
# to use the Giellatekno tools, please run the script
#
#  gt/script/gtsetup.sh
#
# That script will set up a number of environmental variables,
# and make sure this file is read as part of the login process.

#
# Giellatekno - a set of tools for analysing and processing a number
#               of human languages, expecially but not restricted to
#               the Sámi languages. The Giellatekno toolset also includes
#               support for buildling end-user tools such as proofing
#               tools and electronic dictionaries.
# The setup and init scripts (ao this file) are based on similar scripts
#               from the Fink project (http://www.finkproject.org/).
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2004 The Fink Team
# Copyright (c) 2009 The Divvun and Giellatekno teams
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
#

# Define GTCORE as relative to GTHOME for now. The use of GTHOME should be
# discouraged, and be replaced with GTCORE. Only GTCORE should be needed,
# everything else should be optional, but presently that is not the case.
#export GTCORE=$GTHOME/gtcore
export GTCORE=$GTHOME/giella-core

# Add predefined lookup aliases for all languages:
. $GTHOME/gt/script/init.d/lookup-init.sh

# Alias for svn update
alias svnup="svn up $GTHOME $GTBIG $GTFREE $GTPRIV $GTHOME/art"

# Sorting Cyrillic lists


# Standardised aliases for Giellatekno work:
alias victorio='ssh victorio.uit.no'
alias      vic='ssh victorio.uit.no'
alias       xs='ssh       divvun.no'
alias    gtlab='ssh    gtlab.uit.no'
alias    gtsvn='ssh    gtsvn.uit.no'
alias    gtweb='ssh    gtweb.uit.no'
alias  gtoahpa='ssh  gtoahpa.uit.no'

# forrest run port 8 og 9
alias fo="forrest     -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true\""
alias f8="forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true\""
alias f9="forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true -Djetty.port=8889\""
alias f7="forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djava.awt.headless=true -Djetty.port=8887\""

alias saxonXQ="java -Xmx2048m net.sf.saxon.Query"
alias saxonXSL="java -Xmx2048m net.sf.saxon.Transform"
alias xquery="saxonXQ"
alias xslt2="saxonXSL"
alias xsl2="saxonXSL"

# Unicode/UTF-8 aware rev:
alias rev="perl -nle 'print scalar reverse \$_'"
alias sortr='LC_ALL="ru" sort'


# utility command
alias path='echo -e ${PATH//:/\\n}'

# define append_path and prepend_path to add directory paths, e.g. PATH, MANPATH.
# add to end of path
append_path()
{
  if ! eval test -z "\"\${$1##*:$2:*}\"" -o -z "\"\${$1%%*:$2}\"" -o -z "\"\${$1##$2:*}\"" -o -z "\"\${$1##$2}\"" ; then
    eval "$1=\$$1:$2"
  fi
}

# add to front of path
prepend_path()
{
  if ! eval test -z "\"\${$1##*:$2:*}\"" -o -z "\"\${$1%%*:$2}\"" -o -z "\"\${$1##$2:*}\"" -o -z "\"\${$1##$2}\"" ; then
    eval "$1=$2:\$$1"
  fi
}

# setup the Giellatekno path. We assume that the Giellatekno directory exists.
if [ -z "$PATH" ]; then
  PATH=$GTHOME/gt/script:/bin:/sbin:/usr/bin:/usr/sbin
else
  # If MacPorts is installed, make sure it is also available in the environment.
  # This is especially important on the XServe.
  if [ -d /opt/local ]; then
    prepend_path PATH /opt/local/sbin
    prepend_path PATH /opt/local/bin
    prepend_path PATH /opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin
    export MANPATH=/opt/local/share/man:${MANPATH}
    export INFOPATH=/opt/local/share/info:${INFOPATH}
    export CPATH=/opt/local/include:/usr/local/include:/usr/include:${CPATH}
  fi

  # Make sure these paths are inserted before any "system" paths
  # This way locally installed programs will appear before system instaled ones

  PATH=/usr/local/bin:$PATH
  prepend_path PATH $HOME/.local/bin
  prepend_path PATH $HOME/Library/Python/2.7/bin
  prepend_path PATH $HOME/bin
  prepend_path PATH $GTHOME/gt/script
  prepend_path PATH $GTHOME/gt/script/corpus
  prepend_path PATH $GTCORE/scripts
fi

# setup the path to private bins if $GTPRIV is defined:
if [ -n "$GTPRIV" ]; then
  prepend_path PATH $GTPRIV/polderland/bin
fi

export PATH

osMajorVer=`uname -r | cut -d. -f1`
osMinorVer=`uname -r | cut -d. -f2`

# add Saxon to the classpath looking for it in /opt/ and $HOME/lib/
if [ -z "$CLASSPATH" ]; then
  CLASSPATH=/opt/local/share/java/saxon9he.jar:$HOME/lib/saxon9he.jar:$HOME/lib/saxon9.jar
else
  CLASSPATH=/opt/local/share/java/saxon9he.jar:$HOME/lib/saxon9he.jar:$HOME/lib/saxon9.jar:${CLASSPATH}
fi
export CLASSPATH

# Perl setup:
export PERL_UNICODE=""
if [ -z "$PERL5LIB" ]; then
  PERL5LIB=$GTHOME/gt/script
else
  prepend_path PERL5LIB $GTHOME/gt/script
fi
export PERL5LIB

# This environment variable will by default exclude the .svn subdirs from being
# searched when grepping files, which is almost always what you want.
# It requires at least GNU grep 2.5.3. Default on Snow Leopard is 2.5.0, via
# MacPorts GNU grep 2.7.0 or newer is available
#export GREP_OPTIONS="--exclude-dir=\.svn"

# If we are on the XServe or victorio, then set GTBOUND:
HOSTN=$(hostname)
if [ "$HOSTN" = "giellatekno.uit.no" ] ; then
    export GTBOUND="/Users/hoavda/Public/corp/boundcorpus"
elif [ "$HOSTN" = "gtsvn.uit.no" ] ; then
    export GTBOUND=/home/apache_corpus/boundcorpus
fi

