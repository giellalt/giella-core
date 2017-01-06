# -*-Shell-script-*-
# GT setup functions to set up the big repository.

big_command_csh () {
    BIGCMD="\
setenv GTBIG $GTBIG"
}

big_command_sh () {
    BIGCMD="\
export GTBIG=$GTBIG"
}

msg_choose_big () {
    echo The Giellatekno code base also contain some rather big 
    echo files that are not required in most cases. They are helpful
    echo when doing proofing tools testing, and speech technology
    echo development.
    echo
    echo Do you want me to check out this optional
    echo code block for you? It is about 500 Mb downloaded data,
    echo and will occupy roughly 1 Gb on your disk.
    echo The default is to NOT check out this part.
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

display_choose_big () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n\n`msg_choose_big`\n" buttons {"YES", "No, thanks"} default button 2 giving up after 30
      set UserResponse to button returned of dd
   end tell
EOF
   ;;
	NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_choose_big
    /bin/echo -n " [N/y] "
    read answer
    answer=`echo $answer | sed 's/^[nN].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xn" ]; then
       answer="YES"
    fi
    ;;
    esac
}

link_biggies () {
	ln -sf $GTBIG/gt/sme/corp $GTHOME/gt/sme/zcorp
	ln -sf $GTBIG/gt/smj/corp $GTHOME/gt/smj/zcorp
	ln -sf $GTBIG/gt/sma/corp $GTHOME/gt/sma/zcorp
	ln -sf $GTBIG/techdoc/proof/hyph/testing $GTHOME/techdoc/proof/hyph/testing
	ln -sf $GTBIG/techdoc/proof/spelling/testing $GTHOME/techdoc/proof/spell/testing
}

display_choose_big_do () {
# propose to check out big:
    case $ONCONSOLE in
        YES)
	    answer=`display_choose_big`
	    ;;
		NO)
	    display_choose_big
	    ;;
	esac
    if [ "$answer" == "YES" ]; then
		if `cd $GTPARENT && svn co -q https://victorio.uit.no/biggies/trunk big` ; then
    		link_biggies
    		echo "" >> $HOME/$RC.$NEWSUFF
    		echo "$BIGCMD" >> $HOME/$RC.$NEWSUFF
            ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$BIGCMD"`
            RC_CHANGED=YES
        	. $HOME/$RC.$NEWSUFF
            do_login_test
            if grep GTBIG $TMPFILE >/dev/null 2>&1 ; then
    		    Result="The Biggies part of the Giellatekno resources
have been checked out in $GTPARENT/big.

I also added symbolic links within some language
dirs to corpus resources for testing purposes.
Check out gt/GTLANG/zcorp/.\n\n"
            else
                Result="The biggies part of the Giellatekno resources
have been checked out in $GTBIG,
but something went wrong when setting
up \$GTBIG.

Please add text equivalent to the
following to your $RC file:

export GTBIG=$GTBIG\n\n"
            fi
		else
		    Result="Something went wrong when checking out the biggies
repository. Please try to run this command manually:

cd "$GTPARENT" && svn co https://victorio.uit.no/biggies/trunk big\n\n"
		fi		    
    else
		Result="OK, as you wish.\nYou are on your own. Good luck\n\n"
    fi
    display_result
}

setup_big () {
    if [ "$BIG_EXISTS" == "YES" ]; then
        confirm_big_do
    else
        display_choose_big_do
    fi
}

msg_confirm_big () {
    echo It seems you already have checked out the big
    echo repository at:
    echo
    echo "$GTBIG"
    echo
    echo Do you want me to set this path as the value of
    echo the environmental variable \$GTBIG?
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

display_confirm_big () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      try
        set dd to display dialog "`msg_title`\n\n`msg_confirm_big`\n" ¬
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
    msg_confirm_big
    /bin/echo -n " [Y/n] "
    read answer
    answer=`echo $answer | sed 's/^[yY].*$/y/'`
    if [ -z "$answer" -o "x$answer" == "xy" ]; then
       answer="YES"
    fi
    ;;
    esac
}


confirm_big_do () {
# propose to add existing priv dir as GTPRIV:
    case $ONCONSOLE in
        YES)
        answer=`display_confirm_big`
        ;;
        NO)
        display_confirm_big
        ;;
    esac
    if [ "$answer" == "YES" ]; then
        link_biggies
        echo "$BIGCMD" >> $HOME/$RC.$NEWSUFF
        . $HOME/$RC.$NEWSUFF
        ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$BIGCMD"`
        RC_CHANGED=YES
        do_login_test
        if grep GTBIG $TMPFILE >/dev/null 2>&1 ; then
            Result="The big section of the Giellatekno
setup should be fine now.\n\n"
        else
            Result="Something went wrong when setting up \$GTBIG.

Please add text equivalent to the
following to your $RC file:
        
export GTBIG=$GTBIG\n\n"
        fi
    else
        Result="OK, as you wish.\nYou are on your own. Good luck\n\n" 
    fi
    display_result
}
