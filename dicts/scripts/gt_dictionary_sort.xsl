<?xml version="1.0"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xhtml="http://www.w3.org/1999/xhtml">

  <xsl:output
       method="xml"
       indent="yes"
       encoding="UTF-8"
       doctype-public="-//DivvunGiellatekno//DTD Dictionaries//Multilingual"
       doctype-system="../script/gt_dictionary.dtd"
       />

  <!-- This is the real sorting routine:
       It sorts primarily on lemma groups + lemma (lg/l), and
       secondarily on articles with only lemma (l). That is, it will
       correctly sort both variants. Norwegian is chosen as the collating
       language since there is no support for Sámi yet (although that is
       not tested, it is just an assumption based on my knowledge about the
       sorting standardisation process). -->
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
