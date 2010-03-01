<?xml version="1.0"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xhtml="http://www.w3.org/1999/xhtml">

  <xsl:output
       method="xml"
       indent="yes"
       encoding="UTF-8"
       doctype-public="-//XMLmind//DTD nobfkv//FI"
       doctype-system="../script/nobfkv.dtd"
       />

<xsl:template match="r">
 <xsl:text>
</xsl:text>
 <r>
  <xsl:apply-templates select="lics"/>
  <xsl:apply-templates select="e">
    <xsl:sort select="lg/l" lang="no" />
    <xsl:sort select="l" lang="no" />
  </xsl:apply-templates>
  <xsl:apply-templates select="xhtml:script"/>
 </r>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
