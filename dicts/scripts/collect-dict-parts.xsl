<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main collect-dict-parts.xsl dir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      doctype-system="../../scripts/gt_dictionary.dtd"
	      doctype-public="-//XMLmind//DTD gt_dictionary//SE"
	      indent="yes"/>
  
  <xsl:param name="dir" select="'.'"/>

  <xsl:template match="/" name="main">

    <!-- parametrize href values! -->

    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/css" href="../../scripts/gt_dictionary.css"</xsl:text>
    </xsl:processing-instruction>
    
    <xsl:text>
</xsl:text>

    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/xsl" href="../../scripts/gt_dictionary.xsl"</xsl:text>
    </xsl:processing-instruction>

    <!-- why does that '&#xa;' not function? -->
    <xsl:text>
</xsl:text>

<!-- collection('PATH?recurse=yes;select=*.xml') -->
<!-- collection('PATH?select=*.xml') -->

    <r>
      <xsl:copy-of select="collection(concat($dir, '?select=*.xml'))/r/e[not(contains(normalize-space(lg/l), ' '))][not(contains(normalize-space(lg/l), '_'))][not(contains(normalize-space(lg/l), '?'))][not(contains(normalize-space(lg/l), '('))][not(starts-with(normalize-space(lg/l), '-'))][not(ends-with(normalize-space(lg/l), '-'))][not(normalize-space(lg/l) = '')]"/>
    </r>
  </xsl:template>
  
</xsl:stylesheet>
