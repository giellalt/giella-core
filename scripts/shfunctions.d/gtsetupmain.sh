# -*-Shell-script-*-
# GT setup functions to set up the main repository environments
# $Id$

msg_choose () {
    echo If you do not want me to do this, 
    case $ONCONSOLE in
        YES)
    echo you can answer \\\"No\\\" here  
    echo and do it later manually.
    ;;
	NO)
    echo "you can answer \"No\" here and do it later manually."
    ;;
    esac
    echo
    /bin/echo -n Continue\?
}

src_command_csh () {
    SOURCECMD="\
setenv GTHOME $GTHOME"
}

src_command_sh () {
    SOURCECMD="\
export GTHOME=$GTHOME"
}

init_command_csh () {
    INITCMD="\
test -r $GTHOME/gt/script/init.d/init.csh && \
source $GTHOME/gt/script/init.d/init.csh"
}

init_command_sh () {
    INITCMD="\
test -r $GTHOME/gt/script/init.d/init.sh && . $GTHOME/gt/script/init.d/init.sh"
}

display_choose () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      set userCanceled to false
      try
      set dd to display dialog ¬
      "`msg_title`\nYour login shell: $LOGINSHELL\n\n`$MSG` \n\n`msg_choose`" ¬
      buttons {"No, thanks", "YES"} ¬
      default button 2 cancel button 1¬
      giving up after 30
      set UserResponse to button returned of dd
      on error number -128
        set userCanceled to true
      end try
   end tell
EOF
   ;;
	NO)
# display choice dialog
    msg_title; echo "Your login shell: $LOGINSHELL"; echo ""
    $MSG; echo ""
    msg_choose
    /bin/echo -n " [Y/n] "
    read answer
    answer=`echo $answer | sed 's/^[yY].*$/y/'`
    if [ ! -z "$answer" -a "x$answer" != "xy" ]; then
       answer="No, thanks"
    else
        answer="YES"
    fi
    ;;
    esac
}

display_choose_do (){
# propose choice, append line to startup script, and verify if it worked
    case $ONCONSOLE in
        YES)
    answer=`display_choose`
    ;;
	NO)
    display_choose
    ;;
    esac
    if [ "$answer" == "YES" ]; then
	echo "" >> $HOME/$RC.$NEWSUFF
	echo "$SOURCECMD" >> $HOME/$RC.$NEWSUFF
	chown $USER $HOME/$RC.$NEWSUFF
    ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$SOURCECMD"`
    RC_CHANGED=YES
	. $HOME/$RC.$NEWSUFF
	do_login_test
	if grep GTHOME $TMPFILE >/dev/null 2>&1 ; then
	    Result="Your Giellatekno setup for the main
section should be fine now.\n\n"
	else
	    Result="
Hmm. I tried my best, but it still does not work.
The code I put into $RC has no effect.\n
Please check your $LOGINSHELL startup scripts.
Perhaps some other file like\n
	    ~/.login\n
is resetting the PATH after $RC is executed.\n\n"
	fi		    
    else
	Result="OK, as you wish.\nYou are on your own. Good luck\n\n"
    fi
    display_result
}

add_init_command () {
	echo "" >> $HOME/$RC.$NEWSUFF
	echo "$INITCMD" >> $HOME/$RC.$NEWSUFF
    ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$INITCMD"`
    RC_CHANGED=YES
}
