working in the tull-directory.
with the command
tull>java -Xmx16800m -Dfile.encoding=UTF8 net.sf.saxon.Transform -it:main gtdict2simple-apertiumdix.xsl inFile=tull.xml 

the following has been generated.

tull>ls out_simple-apertium
tull.xml

A short sight at the output file
revealed that some attribute value (pos?) is missing.

      <e>
         <p>
            <l>helppo<s n=""/>
            </l>
            <r>enkel, lett </r>
         </p>
      </e>

 ==> this indicates that there are some old pos-value mapping in the mapPOS-file that
     have to be updated or aligned to those in the fkvnob data.

