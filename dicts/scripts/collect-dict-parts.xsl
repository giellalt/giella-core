<?xml version="1.0"?>
<!DOCTYPE topic PUBLIC "-//OASIS//DTD DITA Topic//EN" "dummy.dtd">

<!--+
    | 
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main collect-dict-parts.xsl inDir=INPUT_DIR > PATH_TO_OUTPUT_FILE
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      doctype-system="../../scripts/gt_dictionary.dtd"
	      doctype-public="-//DivvunGiellatekno//DTD Dictionaries//Multilingual"
	      indent="yes"/>
  
  <xsl:param name="inDir" select="'.'"/>

  <xsl:template match="/" name="main">

    <!-- parametrize href values! -->

    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/css" href="../../scripts/gt_dictionary.css"</xsl:text>
    </xsl:processing-instruction>
    
    <xsl:text>
</xsl:text>

    <!--xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/xsl" href="../../scripts/gt_dictionary.xsl"</xsl:text>
    </xsl:processing-instruction-->

    <!-- why does that '&#xa;' not function? -->
    <xsl:text>
</xsl:text>

<!-- collection('PATH?recurse=yes;select=*.xml') -->
<!-- collection('PATH?select=*.xml') -->

    <r>
      <!-- This is an old filter based on the expericenes with the previus dict entry content: use just in case you need it. -->
      <!-- 
	   <xsl:copy-of select="collection(concat($inDir, '?select=*.xml'))/r/e[not(contains(normalize-space(lg/l), ' '))][not(contains(normalize-space(lg/l), '_'))][not(contains(normalize-space(lg/l), '?'))][not(contains(normalize-space(lg/l), '('))][not(starts-with(normalize-space(lg/l), '-'))][not(ends-with(normalize-space(lg/l), '-'))][not(normalize-space(lg/l) = '')]"/>
      -->

      <!-- unrestricted collect: filter if needed! -->
      <xsl:copy-of copy-namespaces="no" select="collection(concat($inDir, '?recurse=no;select=*.xml'))/r/e"/>
    </r>
  </xsl:template>
  
</xsl:stylesheet>
