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

<xsl:template match="lics">
  <h4>Copyright Notes</h4>
  <xsl:apply-templates/>
  <hr/>
</xsl:template>

<xsl:template match="lic">
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="ref">
  <small>Please refer to this source code with the following <b>attribution
  text</b>:</small><br/>
  "<xsl:apply-templates/>"
</xsl:template>

<xsl:template match="sourcenote">
  <p><b><xsl:apply-templates/></b></p>
</xsl:template>

<xsl:template match="a">
 <a href="{.}">
  <xsl:apply-templates/>
 </a>
</xsl:template>

<xsl:template match="e">
 <p>
  <xsl:apply-templates select="lg"/>
  <xsl:choose>
   <xsl:when test="count(./mg) > 1">
    <ol>
     <xsl:apply-templates select="mg">
      <xsl:with-param name="multi" select="1"/>
     </xsl:apply-templates>
    </ol>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates select="mg">
     <xsl:with-param name="multi" select="0"/>
    </xsl:apply-templates>
   </xsl:otherwise>
  </xsl:choose>
 </p>
</xsl:template>

<xsl:template match="l">
 <b>
  <xsl:apply-templates/>
 </b>
 <sup>
  <xsl:value-of select="./@pos"/>
 </sup>
 <xsl:text> </xsl:text>
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
  <xsl:param name="multi"/>
  <xsl:choose>
   <xsl:when test="$multi = 1">
    <li>
     <xsl:apply-templates/>
    </li>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="tg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="t">
  <xsl:apply-templates/>,
</xsl:template>
<xsl:template match="t[last()]">
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
