#!/usr/bin/perl -w
use utf8 ;

while (<>)

{
s/trgr>/tg>/g ;
s/exgr>/xg>/g ;
s/syngr>/syng>/g ;
s/refgr>/refg>/g ;
s/extr>/xt>/g ;
s/rootdict>/r>/g ;
s/entry>/e>/g ;
s/mgr>/mg>/g ;
s/trans>/t>/g ;
s/<trans/<t/g ;
s/<lemma/<l/g ;
s/lemma>/l>/g ;
s/restr>/re>/g ;

s/\"trgr\"/\"tg\"/g ;
s/\"exgr\"/\"xg\"/g ;
s/\"syngr\"/\"syng\"/g ;
s/\"refgr\"/\"refg\"/g ;
s/\"extr\"/\"xt\"/g ;
s/\"rootdict\"/\"r\"/g ;
s/\"entry\"/\"e\"/g ;
s/\"mgr\"/\"mg\"/g ;
s/\"trans\"/\"t\"/g ;
s/\"<trans/<t/g ;
s/\"<lemma/\"<l/g ;
s/\"lemma\"/\"l\"/g ;
s/\"restr\"/\"re\"/g ;

print ;
}
