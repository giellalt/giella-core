<?xml version="1.0"?>
<!--+
    | Generates a text file for in lex format "SOURCE_LEMMA:TARGET_LEMMA # ;"
    | NB: An XSLT-2.0-processor is needed!
    | The input: SOURCE_LANG-TARGET_LANG.xml file(s)
    | Usage: xsltproc  CAT_smenob.xml smenob-pairs.xsl
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="text"
	      omit-xml-declaration="yes"
	      indent="no"/>
  
  <xsl:template match="r">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="e">
<xsl:value-of select="lg/l[
		      (@pos = 'n') or
		      (@pos = 'v') or
		      (@pos = 'a') or
		      (@pos = 'prop') or
		      (@pos = 'num')
		      ]"/><xsl:text>&#x9;</xsl:text><xsl:value-of select="lg/l[
		      (@pos = 'n') or
		      (@pos = 'v') or
		      (@pos = 'a') or
		      (@pos = 'prop') or
		      (@pos = 'num')
		      ]/@pos"/><xsl:text>&#xA;</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>

