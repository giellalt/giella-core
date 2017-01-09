# -*-Shell-script-*-
# Common GT setup dialog elements.

msg_title () {
    echo ---------------------------------------
    echo Setting up your Giellatekno environment
    echo ---------------------------------------
}

msg_create () {
    echo I will create a file named $RC in your
    echo home directory, containing the line:
    echo
    case $ONCONSOLE in
        YES)
    echo \\\"$SOURCECMD\\\"
    ;;
        NO)
    echo "   \"$SOURCECMD\""
    ;;
    esac
}

msg_append () {
    echo I will append the line:
    echo
    case $ONCONSOLE in 
	YES)
    echo \\\"$SOURCECMD\\\"
    ;;
	NO)
    echo "   \"$SOURCECMD\""
    ;;
    esac
    echo
    echo to a copy of the file $RC in your home directory.
    echo All additions to this file will be reviewed
    echo at the end of the setup process before they
    echo are ported back to the real $RC file.
}		       

display_result () {
# display final result
    case $ONCONSOLE in
        YES)
   osascript <<-EOF
   tell application "Finder"
      activate
      set dd to display dialog "`msg_title`\n$Result\n" buttons {"OK"} default button 1 with icon caution giving up after 20
      set UserResponse to button returned of dd
      return ""
   end tell
EOF
   ;;
	NO)
   printf "$Result" 
   ;;
    esac
}

msg_already_setup (){
    echo Your environment seems to be correctly
    echo set up for Giellatekno already.
}

msg_mostly_setup (){
    echo Your environment seems to be correctly
    echo set up for Giellatekno already, except for
    echo some missing links to dirs in $GTBIG.
    echo I will now add those links.
}

msg_links_done (){
    echo All links to dirs in $GTBIG
    echo are now created. Your Giellatekno
    echo environment should be ready. Please
    echo open a new terminal window to start working.
}

msg_main_only_setup (){
    echo Your environment seems to be correctly
    echo set up for the main part of Giellatekno.
    echo However, you seem to be missing some optional
    echo parts.
}

msg_main_big_setup (){
    echo Your environment seems to be correctly
    echo set up for the public part of Giellatekno.
    echo
    echo There is also a private repository for
    echo people employed on the projects. This
    echo repository is not needed for most tasks,
    echo but it does contain some closed code
    echo required for making the MS Office proofing tools.
    echo
    echo If you know you need this, and have a
    echo user name and password giving you access
    echo to the private repository, then click continue.
    echo Otherwise just skip this part, and you
    echo are done.
}

display_already_setup (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_already_setup`" buttons {"OK"} default button 1 giving up after 20 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_already_setup
    ;;
    esac
}

display_mostly_setup (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_mostly_setup`" buttons {"OK"} default button 1 giving up after 20 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_mostly_setup
    ;;
    esac
}

display_links_done (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_links_done`" buttons {"OK"} default button 1 giving up after 20 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_links_done
    ;;
    esac
}

display_main_big_setup (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_main_big_setup`" buttons {"Skip", "Continue"} default button 1 giving up after 60 
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_main_big_setup
    /bin/echo -n "Continue [N/y] "
    read answer
    answer=`echo $answer | sed 's/^[yY].*$/n/'`
    if [ ! -z "$answer" -a "x$answer" != "xy" ]; then
       answer="Continue"
    fi
    ;;
    esac
}

msg_confirm () {
    echo The following additions have been made
    echo to a **copy** of your $RC file named
    echo $RC.$NEWSUFF:
    echo 
    echo "$ALL_RC_CHANGES"
    echo 
    echo Do you want me to apply these changes
    echo to your current $RC file\?
    echo
    echo A backup copy of your original $RC file
    echo can be found in $HOME/$RC.$BACKUPSUFF
    echo in case there are problems.
    echo
    /bin/echo -n Continue\?
}

display_confirm () {
    case $ONCONSOLE in
        YES)
        # display choice popup
           osascript <<-EOF
           tell application "Finder"
              activate
              set userCanceled to false
              try
              set dd to display dialog ¬
              "`msg_title`\n\n`msg_confirm`" ¬
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
            msg_title; echo ""; echo ""
            msg_confirm
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

confirm_changes () {
    #display summary dialog:
    case $ONCONSOLE in
        YES)
    answer=`display_confirm`
    ;;
	NO)
    display_confirm
    ;;
    esac
    if [ "$answer" == "YES" ] ; then
        # replace old RC file with new:
        mv -f $HOME/$RC.$NEWSUFF $HOME/$RC
        display_all_done
    else
        undo_setup
    fi
}

msg_all_done () {
    echo
    echo Thanks for running the Giellatekno
    echo setup script. Everything should be
    echo ready to start using our language
    echo technology tools now.
    echo
    echo Some useful commands:
    echo
    echo makeall.sh - compile all transducers
    echo "preprocess textfile.txt | usme | less"
    echo "\t   - analyse textfile.txt with the North Sámi transducer"
    echo "svnup\t   - update all Giellatekno svn"
    echo "\t\tworking copies in one batch, from whereever you are."
    echo
}

display_all_done (){
    case $ONCONSOLE in
        YES)
    osascript <<-EOF
    tell application "Finder"
	activate
	set dd to display dialog "`msg_title`\n\n`msg_all_done`" buttons {"OK"} default button 1 giving up after 40
    set UserResponse to button returned of dd
    end tell
EOF
    ;;
	NO)
    msg_title; echo""; msg_all_done
    ;;
    esac
}
