<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the collation language
    | Usage: xsltproc --param sortlang 'fi' path/to/sort-dict.xsl XMLFILEIN > XMLOUT
    | 
    +-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:param name="sortlang" select="'no'"/>

  <xsl:template match="r">
  <xsl:text>
</xsl:text>
    <r>
      <xsl:apply-templates select="e">
        <xsl:sort select="lg/l" lang="$sortlang" />
      </xsl:apply-templates>
    </r>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
