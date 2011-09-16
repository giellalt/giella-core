<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main collect-dict-parts.xsl dir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="text"
	      omit-xml-declaration="yes"
	      indent="no"/>
  
  <xsl:param name="dir" select="'.'"/>
  
  <xsl:variable name="nl" select="'&#xa;'"/>

  <xsl:template match="/" name="main">
    <xsl:for-each select="collection(concat($dir, '?select=*.xml'))/r/e[not(@usage='vd')]/lg/l">
      <xsl:value-of select="concat(., $nl)"/>
    </xsl:for-each>

    <xsl:for-each select="collection(concat($dir, '?select=*.xml'))/r/e[not(@usage='vd')]/lg/lsub">
      <xsl:value-of select="concat(., $nl)"/>
    </xsl:for-each>

  </xsl:template>
  
</xsl:stylesheet>
