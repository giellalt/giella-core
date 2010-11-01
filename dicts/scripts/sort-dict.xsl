<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the collation language
    | Usage: xsltproc - -param sortlang 'fi' path/to/sort-dict.xsl XMLFILEIN > XMLOUT
    |                ( ^ remove the space between the two hyphens in real use)
    +-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:param name="sortlang" select="'no'"/>

  <xsl:template match="r|rootdict">
  <xsl:text>
</xsl:text>
    <xsl:element name="{local-name(.)}">
      <xsl:apply-templates select="e|entry">
        <xsl:sort select="apps/app/sources/book/@name" lang="$sortlang" />
        <xsl:sort select="lg/l" lang="$sortlang" />
        <xsl:sort select="lemma" lang="$sortlang" />
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
