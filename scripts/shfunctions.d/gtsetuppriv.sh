# -*-Shell-script-*-
# GT setup functions to set up the private repository.
# $Id$

priv_command_csh () {
    PRIVCMD="\
setenv GTPRIV $GTPRIV"
}

priv_command_sh () {
    PRIVCMD="\
export GTPRIV=$GTPRIV"
}

msg_confirm_priv () {
    echo It seems you already have checked out the private
    echo repository at:
    echo
    echo "$GTPRIV"
    echo
    echo Do you want me to set this path as the value of
    echo the environmental variable \$GTPRIV?
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

display_confirm_priv () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      try
        set dd to display dialog "`msg_title`\n\n`msg_confirm_priv`\n" ¬
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
    msg_confirm_priv
    /bin/echo -n " [Y/n] "
    read answer
    answer=`echo $answer | sed 's/^[yY].*$/y/'`
    if [ -z "$answer" -o "x$answer" == "xy" ]; then
       answer="YES"
    fi
    ;;
    esac
}

msg_choose_priv () {
    echo Please provide your username and password
    echo to check out the private repository
    case $ONCONSOLE in
        YES)
    echo in the following two dialogs.
    echo
    echo You can answer \\\"No\\\" here  
    echo and do it later manually.
    ;;
    NO)
    echo
    echo "You can answer \"No\" here and do it later manually."
    ;;
    esac
    echo
    /bin/echo -n Continue\?
}

display_choose_priv () {
    case $ONCONSOLE in
        YES)
# display choice popup
   osascript <<-EOF
   tell application "Finder"
      activate
      try
        set dd to display dialog "`msg_title`\n\n`msg_choose_priv`\n" ¬
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
    msg_choose_priv
    /bin/echo -n " [N/y] "
    read answer
    answer=`echo $answer | sed 's/^[nN].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xn" ]; then
       answer="YES"
    fi
    ;;
    esac
}

msg_ask_username () {
    echo Please provide your username:
    echo
}

display_ask_username () {
    case $ONCONSOLE in
        YES)
# display choice popup
  osascript <<-EOF
  tell application "Finder"
    activate
    set userCanceled to false
    try
      set dd to display dialog "`msg_title`\n\n`msg_ask_username`\n" ¬
      buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" ¬
      giving up after 30 ¬
      default answer ""
      set UserResponse to button returned of dd
    on error number -128
      set userCanceled to true
    end try
    if userCanceled then
        set userName to ""
    else if gave up of dd then
        -- statements to execute if dialog timed out without an answer
        set userName to ""
    else if button returned of dd is "OK" then
      set userName to text returned of dd
    end if
    return userName
  end tell
EOF
   ;;
    NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_ask_username
    /bin/echo -n " [Your user name:] "
    read username
    ;;
    esac
}

msg_ask_password () {
    echo Please provide your password.
    echo
    case $ONCONSOLE in
        YES)
    echo If you mistype the password, you will
    echo have to retype it on the command line
    echo from where you started this setup script.
    echo
    ;;
    esac
    echo Note that you need to be patient.
    echo Checking out can take a lot of time,
    echo depending on your network connection,
    echo trafic, etc.
    echo
}

display_ask_password () {
    case $ONCONSOLE in
        YES)
# display choice popup
  osascript <<-EOF
  tell application "Finder"
    activate
    set userCanceled to false
    try
      set dd to display dialog "`msg_title`\n\n`msg_ask_password`\n" ¬
      buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" ¬
      giving up after 30 ¬
      default answer "" with icon 1 with hidden answer
      set UserResponse to button returned of dd
    on error number -128
      set userCanceled to true
    end try
    if userCanceled then
        set passWrd to ""
    else if gave up of dd then
        -- statements to execute if dialog timed out without an answer
        set passWrd to ""
    else if button returned of dd is "OK" then
      set passWrd to text returned of dd
    end if
    return passWrd
  end tell
EOF
   ;;
    NO)
# display choice dialog
    msg_title; echo ""; echo ""
    msg_ask_password
    /bin/echo -n " [Your password:] "
    read password
    ;;
    esac
}

display_choose_priv_do () {
# propose to check out priv:
    case $ONCONSOLE in
        YES)
        answer=`display_choose_priv`
        ;;
        NO)
        display_choose_priv
        ;;
    esac
    if [ "$answer" == "YES" ]; then
        # ask for username
        case $ONCONSOLE in
            YES)
            username=`display_ask_username`
            ;;
            NO)
            display_ask_username
            ;;
        esac
        # ask for password
        case $ONCONSOLE in
            YES)
            password=`display_ask_password`
            ;;
            NO)
            display_ask_password
            ;;
        esac
        if ([ "$username" != "" ] && [ "$password" != "" ]); then
            if `cd $GTPARENT && svn co --username $username --password $password -q https://victorio.uit.no/private/trunk priv` ; then
                echo "$PRIVCMD" >> $HOME/$RC.$NEWSUFF
                ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$PRIVCMD"`
                RC_CHANGED=YES
                . $HOME/$RC.$NEWSUFF
                do_login_test
                if grep GTPRIV $TMPFILE >/dev/null 2>&1 ; then
                    Result="The private part of the Giellatekno resources
have been checked out in $GTPRIV.\n\n"
                else
                    Result="The private part of the Giellatekno resources
have been checked out in $GTPARENT/priv,
but something went wrong when setting up \$GTPRIV.

Please add text equivalent to the
following to your $RC file:

export GTPRIV=$GTPRIV\n\n"
                fi
            else
                Result="Something went wrong when checking out the private
repository. Please try to run this command manually:

cd $GTPARENT && svn co https://victorio.uit.no/private/trunk priv\n\n"
            fi
            
        else
            Result="You bailed out. Please rerun this
script later to complete the setup.\n\n"
        fi
    else
        Result="OK, as you wish. You are on your own. Good luck.

If you want to do it later manually, use this command:

cd $GTPARENT && svn co https://victorio.uit.no/private/trunk priv\n\n"
    fi
    display_result
}

display_setup_priv () {
    case $ONCONSOLE in
        YES)
        answer=`display_main_big_setup`
        ;;
        NO)
        display_main_big_setup
        ;;
    esac
    if [ "$answer" == "Continue" ]; then
       setup_priv
    fi
}

setup_priv () {
    if [ "$PRIV_EXISTS" == "YES" ]; then
        confirm_priv_do
    else
        display_choose_priv_do
    fi
}

confirm_priv_do () {
# propose to add existing priv dir as GTPRIV:
    case $ONCONSOLE in
        YES)
        answer=`display_confirm_priv`
        ;;
        NO)
        display_confirm_priv
        ;;
    esac
    if [ "$answer" == "YES" ]; then
        echo "$PRIVCMD" >> $HOME/$RC.$NEWSUFF
        ALL_RC_CHANGES=`echo "$ALL_RC_CHANGES\n$PRIVCMD"`
        RC_CHANGED=YES
        . $HOME/$RC.$NEWSUFF
        do_login_test
        if grep GTPRIV $TMPFILE >/dev/null 2>&1 ; then
            Result="The private section of your Giellatekno setup
should be fine now.\n\n"
        else
            Result="Something went wrong when setting up \$GTPRIV.

Please add text equivalent to the
following to your $RC file:
        
export GTPRIV=$GTPRIV\n\n"
        fi
    else
        Result="OK, as you wish.\nYou are on your own. Good luck\n\n"
    fi
    display_result
}
