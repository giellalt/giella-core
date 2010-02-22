#!/usr/bin/perl -w
use utf8 ;

while (<>)

{
s/<lemma/<l/g ;
s/<trans/<t/g ;
s/entry>/e>/g ;
s/entry\/>/e\/>/g ;
s/ex>/x>/g ;
s/ex\/>/x\/>/g ;
s/exgr>/xg>/g ;
s/exgr\/>/xg\/>/g ;
s/extr>/xt>/g ;
s/extr\/>/xt\/>/g ;
s/lemma>/l>/g ;
s/lemma\/>/l\/>/g ;
s/mgr>/mg>/g ;
s/mgr\/>/mg\/>/g ;
s/refgr>/refg>/g ;
s/refgr\/>/refg\/>/g ;
s/restr>/re>/g ;
s/restr\/>/re\/>/g ;
s/rootdict>/r>/g ;
s/syngr>/syng>/g ;
s/syngr\/>/syng\/>/g ;
s/trans>/t>/g ;
s/trans\/>/t\/>/g ;
s/trgr>/tg>/g ;
s/trgr\/>/tg\/>/g ;

s/\"<lemma/\"<l/g ;
s/\"<trans/<t/g ;
s/\"entry\"/\"e\"/g ;
s/\"ex\"/\"x\"/g ;
s/\"exgr\"/\"xg\"/g ;
s/\"extr\"/\"xt\"/g ;
s/\"lemma\"/\"l\"/g ;
s/\"mgr\"/\"mg\"/g ;
s/\"refgr\"/\"refg\"/g ;
s/\"restr\"/\"re\"/g ;
s/\"rootdict\"/\"r\"/g ;
s/\"syngr\"/\"syng\"/g ;
s/\"trans\"/\"t\"/g ;
s/\"trgr\"/\"tg\"/g ;

print ;
}
