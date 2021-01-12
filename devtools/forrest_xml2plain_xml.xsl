<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	version="1.0"
	>

  <xsl:output method="html" indent="yes" omit-xml-declaration="no" />

  <xsl:template match="document/@xml:lang"/>
  <xsl:template match="document">
    <html>
       <xsl:attribute name="lang">
         <xsl:value-of select="@xml:lang"/>
       </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </html>
  </xsl:template>

  <xsl:template match="header">
    <head>
      <xsl:apply-templates select="@*|node()"/>
    </head>
  </xsl:template>

  <xsl:template match="section">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <xsl:template match="body/section/title">
    <h1>
      <xsl:apply-templates select="@*|node()"/>
    </h1>
  </xsl:template>

  <xsl:template match="body/section/section/title">
    <h2>
      <xsl:apply-templates select="@*|node()"/>
    </h2>
  </xsl:template>

  <xsl:template match="body/section/section/section/title">
    <h3>
      <xsl:apply-templates select="@*|node()"/>
    </h3>
  </xsl:template>

  <xsl:template match="body/section/section/section/section/title">
    <h4>
      <xsl:apply-templates select="@*|node()"/>
    </h4>
  </xsl:template>

  <xsl:template match="body/section/section/section/section/section/title">
    <h5>
      <xsl:apply-templates select="@*|node()"/>
    </h5>
  </xsl:template>

  <xsl:template match="source">
    <xsl:text>&#xa;</xsl:text>
    <pre>
      <xsl:apply-templates select="@*|node()"/>
    </pre>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="p[@class='last_modified']"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
