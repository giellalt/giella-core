<?xml version="1.0"?>

<!-- anders (2023-09-28):
     Very similar functionality exists in merge_giella_dicts.py
     This file is not referenced in NDS. -->

<!--+
    | 
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main collect-dict-parts.xsl inDir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs xhtml">


  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      doctype-system="../../scripts/gt_dictionary.dtd"
	      doctype-public="-//XMLmind//DTD gt_dictionary//SE"
	      indent="yes"/>
  
  <xsl:param name="inDir" select="'gogoDir'"/>

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
      <xsl:copy-of  copy-namespaces="no" select="collection(concat($inDir, '?select=*.xml'))/r/e[(@usage='vd') and not(./mg/tg/t='XXXX')]"/>
      <!-- xsl:copy-of  copy-namespaces="no" select="collection(concat($inDir, '?select=*.xml'))/r/e[(@usage='vd') and not(./mg/tg/t='XXXX') and not(contains(normalize-space(lg/l), ' '))]"/ -->
      <!--       <xsl:copy-of select="collection(concat($inDir, '?select=*.xml'))/r/e[(@usage='ped' or @src='nj') and not(starts-with(./mg/tg/t,'XX'))]"/> -->
    </r>
  </xsl:template>
  
</xsl:stylesheet>

