<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html"/>

<xsl:template match="r">
<html>
 <head><meta charset="UTF-8"/>
 </head>
 <body>
  <xsl:apply-templates/>
 </body>
</html>
</xsl:template>

<xsl:template match="e">
 <p>
  <xsl:apply-templates/>
 </p>
</xsl:template>

<xsl:template match="l">
 <b>
  <xsl:apply-templates/>
 </b>
</xsl:template>

<!--
<xsl:template match="l/@pos">
 <sup>
  <xsl:apply-templates/>
 </sup>
</xsl:template>

<xsl:template match="lc">
 <i>
  <xsl:apply-templates/>
 </i>
</xsl:template>

<xsl:template match="pos">
 <sup>
  <xsl:apply-templates/>
 </sup>
</xsl:template>
-->

<xsl:template match="mg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="t">

  <xsl:apply-templates/>
</xsl:template>

<!--
<xsl:template match="t pos">
 <sup>
  <xsl:apply-templates/>
 </sup>
</xsl:template>
-->

<xsl:template match="xg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x">
  <i><b><small>
   <xsl:apply-templates/>
 </small></b></i>
</xsl:template>

<xsl:template match="xt">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
