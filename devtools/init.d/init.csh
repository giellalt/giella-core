# init.csh
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

# Add predefined lookup aliases for all languages:
source $GTHOME/gt/script/init.d/lookup-init.csh

# Alias for svn update
alias svnup "pushd $GTHOME && svn up && popd ; \
    test -n \"$GTBIG\"  && test -x $GTBIG  && pushd $GTBIG  && svn up && popd ; \
    test -n \"$GTFREE\" && test -x $GTFREE && pushd $GTFREE && svn up && popd ; \
    test -n \"$GTPRIV\" && test -x $GTPRIV && pushd $GTPRIV && svn up && popd"

# Standardised aliases for Giellatekno work:
alias victorio 'ssh victorio.uit.no'
alias vic 'ssh victorio.uit.no'
alias g5 'ssh divvun.no'
alias xs 'ssh divvun.no'

# forrest run port 8 og 9
alias f8 "forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8\""
alias f9 "forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djetty.port=8889\""
alias f7 "forrest run -Dforrest.jvmargs=\"-Dfile.encoding=utf-8 -Djetty.port=8887\""

alias  saxonXQ "java net.sf.saxon.Query"
alias saxonXSL "java net.sf.saxon.Transform"
alias xquery "saxonXQ"
alias xslt2 "saxonXSL"
alias xsl2 "saxonXSL"

# Unicode/UTF-8 aware rev:
alias rev "perl -nle 'print scalar reverse \$_'"

# utility command
alias path "echo $PATH | tr ':' '\n'"

# define append_path and prepend_path to add directory paths, e.g. PATH, MANPATH.
# add to end of path
alias append_path 'if ( $\!:1 !~ \!:2\:* && $\!:1 !~ *\:\!:2\:* && $\!:1 !~ *\:\!:2 && $\!:1 !~ \!:2 ) setenv \!:1 ${\!:1}\:\!:2'
# add to front of path
alias prepend_path 'if ( $\!:1 !~ \!:2\:* && $\!:1 !~ *\:\!:2\:* && $\!:1 !~ *\:\!:2 && $\!:1 !~ \!:2 ) setenv \!:1 \!:2\:${\!:1}; if ( $\!:1 !~ \!:2\:* ) setenv \!:1 \!:2`echo \:${\!:1} | /usr/bin/sed -e s%^\!:2\:%% -e s%:\!:2\:%:%g -e s%:\!:2\$%%`'

# setup the Giellatekno path. We assume that the Giellatekno directory exists.
if ( $?PATH ) then
    prepend_path PATH $GTHOME/gt/script
else
    setenv PATH $GTHOME/gt/script:/bin:/sbin:/usr/bin:/usr/sbin
endif

# setup the path to private bins if $GTPRIV is defined:
if ( $?GTPRIV ) then
    prepend_path PATH $GTPRIV/polderland/bin
endif

set osMajorVersion = `uname -r | cut -d. -f1`
set osMinorVersion = `uname -r | cut -d. -f2`

if ( $?CLASSPATH ) then
  prepend_path CLASSPATH ~/lib/saxon9.jar
else
  setenv CLASSPATH ~/lib/saxon9.jar
endif

# Perl setup:
setenv PERL_UNICODE ""
if ( $?PERL5LIB ) then
  prepend_path PERL5LIB $GTHOME/gt/script
else
  setenv PERL5LIB $GTHOME/gt/script
endif

# If MacPorts is installed, make sure it is also availble in the environment.
# This is especially important on the XServe.
if ( -d /opt/local/bin ) then
	prepend_path PATH     /opt/local/bin:/opt/local/sbin
	append_path  MANPATH  /opt/local/share/man
	append_path  INFOPATH /opt/local/share/info
endif

# This environment variable will by default exclude the .svn subdirs from being
# searched when grepping files, which is almost always what you want.
# It requires at least GNU grep 2.5.3. Default on Snow Leopard is 2.5.0, via
# MacPorts GNU grep 2.7.0 or newer is available
setenv GREP_OPTIONS "--exclude-dir=\.svn"
