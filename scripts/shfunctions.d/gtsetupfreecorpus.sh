# -*-Shell-script-*-
# GT setup functions to set up the freecorpus repository.
# $Id: gtsetupfreecorpus.sh 26666 2009-07-01 08:55:09Z sjur $

free_command_csh () {
    FREECMD="\
setenv GTFREE $GTFREE"
}

free_command_sh () {
    FREECMD="\
export GTFREE=$GTFREE"
}

msg_choose_free () {
    echo The Giellatekno code base also contains a set of
    echo free corpus files.
    echo Do you want me to check out this optional
    echo code block for you?
    echo
    echo NB!!! This checkout will take a LOT of TIME.
    echo Just leave the computer running. A new dialog will
    echo pop up when the checkout is finished. You can
    echo use your computer for other tasks in the meantime,
    echo "just don't turn it off or put it to sleep."
    echo
    case $ONCONSOLE in
        YES)
    echo you can answer \\\"No\\\" here  
    echo and do it later manually.
    ;;
	NO)
    echo "You can answer \"No\" here and do it later manually."
    ;;
    esac
    echo
    /bin/echo -n Continue\?
}

display_choose_free () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n\n`msg_choose_free`\n" buttons {"YES", "No, thanks"} default button 2 giving up after 30
      set UserResponse to button returned of dd
   end tell
EOF
   ;;
	NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_choose_free
    /bin/echo -n " [N/y] "
    read answer
    answer=`echo $answer | sed 's/^[nN].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xn" ]; then
       answer="YES"
    fi
    ;;
    esac
}

display_choose_free_do () {
# propose to check out freecorpus:
    case $ONCONSOLE in
        YES)
	    answer=`display_choose_free`
	    ;;
		NO)
	    display_choose_free
	    ;;
	esac
    if [ "$answer" == "YES" ]; then
		if `cd $GTPARENT && svn co -q https://victorio.uit.no/freecorpus` ; then
    		echo "" >> $HOME/$RC.$NEWSUFF
    		echo "$FREECMD" >> $HOME/$RC.$NEWSUFF
            ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$FREECMD"`
            RC_CHANGED=YES
        	. $HOME/$RC.$NEWSUFF
            do_login_test
            if grep GTFREE $TMPFILE >/dev/null 2>&1 ; then
    		    Result="The free corpus part of the Giellatekno resources
has been checked out in $GTPARENT/freecorpus.\n\n"
            else
                Result="The free corpus part of the Giellatekno resources
has been checked out in $GTFREE,
but something went wrong when setting
up \$GTFREE.

Please add text equivalent to the
following to your $RC file:

export GTFREE=$GTFREE\n\n"
            fi
		else
		    Result="Something went wrong when checking out the freecorpus
repository. Please try to run this command manually:

cd "$GTPARENT" && svn co https://victorio.uit.no/freecorpus\n\n"
		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck\n\n"
    fi
    display_result
}

setup_free () {
    if [ "$FREE_EXISTS" == "YES" ]; then
        confirm_free_do
    else
        display_choose_free_do
    fi
}

msg_confirm_free () {
    echo It seems you already have checked out the freecorpus
    echo repository at:
    echo
    echo "$GTFREE"
    echo
    echo Do you want me to set this path as the value of
    echo the environmental variable \$GTFREE?
    echo
    case $ONCONSOLE in
        YES)
    echo You can answer \\\"No\\\" here  
    echo and do it later manually.
    ;;
    NO)
    echo "You can answer \"No\" here and do it later manually."
    ;;
    esac
    echo
    /bin/echo -n Continue\?
}

display_confirm_free () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      try
        set dd to display dialog "`msg_title`\n\n`msg_confirm_free`\n" ¬
        buttons {"No, thanks", "YES"} ¬
        default button "YES" cancel button "No, thanks" ¬
        giving up after 30
        set UserResponse to button returned of dd
      end try
   end tell
EOF
   ;;
    NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_confirm_free
    /bin/echo -n " [Y/n] "
    read answer
    answer=`echo $answer | sed 's/^[yY].*$/y/'`
    if [ -z "$answer" -o "x$answer" == "xy" ]; then
       answer="YES"
    fi
    ;;
    esac
}


confirm_free_do () {
# propose to add existing priv dir as GTPRIV:
    case $ONCONSOLE in
        YES)
        answer=`display_confirm_free`
        ;;
        NO)
        display_confirm_free
        ;;
    esac
    if [ "$answer" == "YES" ]; then
        echo "$FREECMD" >> $HOME/$RC.$NEWSUFF
        . $HOME/$RC.$NEWSUFF
        ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$FREECMD"`
        RC_CHANGED=YES
        do_login_test
        if grep GTFREE $TMPFILE >/dev/null 2>&1 ; then
            Result="The freecorpus section of the Giellatekno
setup should be fine now.\n\n"
        else
            Result="Something went wrong when setting up \$GTFREE.

Please add text equivalent to the
following to your $RC file:
        
export GTFREE=$GTFREE\n\n"
        fi
    else
        Result="OK, as you wish.\nYou are on your own. Good luck\n\n" 
    fi
    display_result
}
