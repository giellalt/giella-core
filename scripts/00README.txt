This dir contains script files used by the GTCORE module, a set of tools and
templates required for all work on language files using the new infrastructure.

Some of the files are:

iso-639-3_20110525.txt
----------------------

Downloaded from: http://www.sil.org/iso639-3/download.asp
Original filename: http://www.sil.org/iso639-3/iso-639-3_20110525.tab
Content: tab-separated values with the following fields:

   Id       -- The three-letter 639-3 identifier
   Part2B   -- Equivalent 639-2 identifier of the bibliographic applications 
            -- code set, if there is one
   Part2T   -- Equivalent 639-2 identifier of the terminology applications code 
            -- set, if there is one
   Part1    -- Equivalent 639-1 identifier, if there is one    
   Scope    -- I(ndividual), M(acrolanguage), S(pecial)
   Type     -- A(ncient), C(onstructed),  
            -- E(xtinct), H(istorical), L(iving), S(pecial)
   Ref_Name -- Reference language name 
   Comment  -- Comment relating to one or more of the columns

iso3-to-2.sh
------------
Shell script to return a 2-letter code for a three-letter language code. If no
such code is found, the original code will be returned.
