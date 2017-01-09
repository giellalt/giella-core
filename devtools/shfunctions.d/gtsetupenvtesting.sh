# -*-Shell-script-*-
# Common GT scripts to test and set the basic environment requirements

set_gthome () {
# GTHOME is loc. of script + ../../
# set_gthome is robust wrt to spaces in dirnames, and also from
# where the script is called (ie it can be called from anywhere).

# First we need to find the full pathname from the root
# to the script file:
    dirname=$(dirname "$0")
    pwd=$(pwd)
#    if dirname = '.' then $pwd contains the full path:
    if [ "$dirname" == "." ]; then
        tmp=$pwd
    # else if dirname contains $HOME then $dirname contains the full path:
    elif [[ "$dirname" =~ $HOME ]]; then
        tmp=$dirname
#    else if pwd = '/' then $dirname contains the full path:
    elif [ "$pwd" == "/" ]; then
        tmp=$dirname
#    else concatenate $pwd and $dirname with a / in between:
    else
        tmp="$pwd/$dirname"
    fi
# Now tmp contains the full path to the setup script, and we
# remove the last 2 dirs to get GTHOME:
    tmp2="${tmp%/*}"
    GTHOME="${tmp2%/*}"
    GTPARENT="${GTHOME%/*}"
    echo
    echo "*** Please be patient, this first step might take a few seconds... ***"
    echo
    echo "GTPARENT has been set to $GTPARENT"
    do_big_exists
    do_free_exists
    do_priv_exists
}

do_isconsole () {
# Test whether we can use Finder popup windows
    ONCONSOLE=NO
    /bin/ps x -U $USER | grep Finder | grep -v grep >/dev/null && ONCONSOLE=YES
    [ "x$SCRIPT_NAME" = "xpostflight" ] && ONCONSOLE=YES 
}

do_login_test () {
# Start a login session to see whether the PATH is already set up for
# the Giellatekno tools.
# PATH and SHELL are written into TMPFILE.
# We have to use basic shell speak here, because we don't know
# which shell will come up.
    /bin/echo -n LOGINSHELL= >$TMPFILE
    /usr/bin/printenv SHELL >>$TMPFILE
    /usr/bin/printenv PATH >>$TMPFILE
    /usr/bin/printenv >>$TMPFILE
}

do_big_exists () {
# Check whether there exists a directory parallell to GTHOME that seems to
# contain the biggies.
# "gt/sme/corp" is used as the test case - it only exists at the immediate
# level below the working copy root in the biggies repository.
# -maxdepth -mindepth is used because of a bug with -depth n on victorio
    BIGDIR=`find $GTPARENT -maxdepth 5 -mindepth 5 -name corp | grep gt/sme/corp 2> /dev/null`
    GTBIG=${BIGDIR/"/trunk/gt/sme/corp"}
    # if nothing is found, it can be because the trunk dir was checked out
    # as well - thus checking one level further down:
    if [ "$BIGDIR" == "" ] ; then
        BIGDIR=`find $GTPARENT -maxdepth 4 -mindepth 4 -name corp | grep gt/sme/corp 2> /dev/null`
        GTBIG=${BIGDIR/"/gt/sme/corp"}
    fi
    if [ "$BIGDIR" != "" ] ;
    then
        BIG_EXISTS=YES
    else
        BIG_EXISTS=NO
        GTBIG=$GTPARENT/big
    fi
}

do_free_exists () {
# Check whether there exists a directory parallell to GTHOME that seems to
# contain the free corpus.
# "freecorpus" is used as the test case - it only exists at the immediate
# level below the working copy root in the biggies repository.
# -maxdepth -mindepth is used because of a bug with -depth n on victorio
    FREEDIR=`find $GTPARENT -maxdepth 1 -mindepth 1 -name freecorpus 2> /dev/null`
    if [ "$FREEDIR" != "" ] ;
    then
        FREE_EXISTS=YES
        GTFREE=${FREEDIR}
    else
        FREE_EXISTS=NO
        GTFREE=$GTPARENT/freecorpus
    fi
}

do_priv_exists () {
	# First set the default values
	PRIV_EXISTS=NO
	GTPRIV=$GTPARENT/priv
	
	# Then search for the directory polderland
	for d in `find $GTPARENT -maxdepth 4 -mindepth 2 -name polderland -type d`
	do
		cd $d
		# Check if we are really are inside a working copy of private
		TESTSTRING=`svn info | grep private 2> /dev/null`
		if [ "$TESTSTRING" != "" ]
		then
			PRIV_EXISTS=YES
			# The polderland dir isn't the "mother" of private, descend down until 
			# are outside the working copy
			while [ "`svn info | grep private`" != "" ]
			do
				GTPRIV=`pwd`
				cd ..
			done
		fi
		cd $GTPARENT
	done
}

make_RC_backup () {
    cp -f $HOME/$RC $HOME/$RC.$BACKUPSUFF
    grep -v 'gt/script/init.d/init\..*sh' $HOME/$RC > $HOME/$RC.$NEWSUFF
}

msg_undo () {
    echo
    echo No changes were made. The $RC.$BACKUPSUFF
    echo and $RC.$NEWSUFF files have been
    echo deleted. Your $RC file is untouched.
    echo
    echo Please rerun the script later, or modify
    echo your $RC file manually.
    echo
}

display_undo (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
    activate
    set dd to display dialog "`msg_title`\n\n`msg_undo`" buttons {"OK"} default button 1 giving up after 20
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
    NO)
    msg_title; echo""; msg_undo
    ;;
    esac
}

undo_setup () {
    rm -f $HOME/$RC.$BACKUPSUFF
    rm -f $HOME/$RC.$NEWSUFF
    display_undo
}

check_links () {
	if (
	     [ -L $GTHOME/gt/sme/zcorp/               ] &&
	     [ -L $GTHOME/gt/smj/zcorp/               ] &&
	     [ -L $GTHOME/gt/sma/zcorp/               ] &&
	     [ -L $GTHOME/techdoc/proof/hyph/testing  ] &&
	     [ -L $GTHOME/techdoc/proof/spell/testing ]
	   ) ; then
		links_ok=YES
	else 
		links_ok=NO
	fi
}
