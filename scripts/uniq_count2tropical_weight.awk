## Copyright (C) 2015 Samediggi & UiT The Arctic University of Norway

## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

# AWK script to calculate the tropical weight of the count of unique strings in
# a corpus. Written by Tommi Pirinen.

BEGIN {
    if (CS <= 0)
    {
        print "define corpus size CS" > "/dev/stderr" ;
        exit(1);
    }
    if (DS <= 0)
    {
        print "define corpus size DS" > "/dev/stderr" ;
        exit(1);
    }
    if (ALPHA <= 0)
    {
        print "define corpus size ALPHA" > "/dev/stderr" ;
        exit(1);
    }
}
NF == 2 {
    printf("%s\t%f\n", $2, -log(($1+ALPHA)/(CS+(ALPHA*DS))));
}
