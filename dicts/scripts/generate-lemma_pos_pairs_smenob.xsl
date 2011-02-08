<?xml version="1.0"?>
<!--+
    | Generates a text file for in the format "LEMMA TAB POS NEWLINE" for the paradigm generation task
    | NB: An XSLT-2.0-processor is needed!
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="text"
	      omit-xml-declaration="yes"
	      indent="no"/>
  
  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="debug" select="true()"/>
  
  <xsl:template match="r">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="e">
    <xsl:variable name="c_lemma" select="lg/l[
				       (@pos = 'n') or
				       (@pos = 'v') or
				       (@pos = 'a') or
				       (@pos = 'actor') or
				       (@pos = 'g3') or
				       (@pos = 'prop') or
				       (@pos = 'pron' and @type='indef' and not(@pg='no')) or
				       (@pos = 'npl') or
				       (@pos = 'num')
				       ]"/>

    <xsl:variable name="c_pos" select="lg/l[
				       (@pos = 'n') or
				       (@pos = 'v') or
				       (@pos = 'a') or
				       (@pos = 'actor') or
				       (@pos = 'g3') or
				       (@pos = 'prop') or
				       (@pos = 'pron' and @type='indef' and not(@pg='no')) or
				       (@pos = 'npl') or
				       (@pos = 'num')
				       ]/@pos"/>

    <xsl:variable name="c_line" select="concat($c_lemma, $tab, $c_pos, $nl)"/>
    
    <xsl:if test="$debug">
      <xsl:message terminate="no">
	<xsl:value-of select="concat('processing ', $c_line, $nl)"/>
	<xsl:value-of select="'   ...........'"/>
      </xsl:message>
    </xsl:if>

    <xsl:value-of select="if (not($c_line = concat($tab, $nl))) then $c_line else ''"/>
    
  </xsl:template>
  
</xsl:stylesheet>

