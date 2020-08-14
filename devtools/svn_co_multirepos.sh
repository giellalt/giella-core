function print_usage() {
    echo "Usage: $0 [OPTIONS...]"
    echo "Checks out multiple github.com/giellalt repositories using svn,"
    echo "for repo names matching REGEX."
    echo "Uses `gut` to retrieve repo names based on the REGEX."
    echo
    echo "  -h, --help                 print this usage info"
    echo "  -r, --regex REGEX          match repo names against REGEX"
    echo
}

# The default is to check out everything:
regex=.

# manual getopt loop... Mac OS X does not have good getopt
while test $# -ge 1 ; do
    if test x$1 = x--regex -o x$1 = x-r ; then
        regex=$2
        shift
    elif test x$1 = x--help -o x$1 = x-h ; then
        print_usage
        exit 0
    else
        echo
        echo "ERROR: $0: unknown option $1"
        print_usage
        exit 1
    fi
    shift
done


repo_list=$(gut show repositories -o giellalt -r "$regex" | grep RemoteRepo | cut -d'"' -f8)

for repo in $repo_list; do
    repo_url=${repo}.git/trunk
    dir_name=$(echo $repo | rev | cut -d'/' -f1 | rev)
    echo "Checking out $dir_name from $repo_url:"
    svn co $repo_url $dir_name
    echo "-"
done

echo "Done!"
