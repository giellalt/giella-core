<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main collect-dict-parts.xsl dir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>
  
  <xsl:param name="lic-file" select="'x'"/>

  <xsl:template match="r">
  <xsl:text>
</xsl:text>
    <r>
      <xsl:copy-of select="document($lic-file)"/>
      <xsl:apply-templates select="e">
        <xsl:sort select="lg/l" lang="no" />
      </xsl:apply-templates>
    </r>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
