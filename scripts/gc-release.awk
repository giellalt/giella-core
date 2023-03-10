BEGIN { comment=""; }
/ADD:x/ { comment="#"; }
{printf("%s%s\n", comment, $0);}
/;/ { comment=""; }
