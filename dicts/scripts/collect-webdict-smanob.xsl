<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main collect-dict-parts.xsl dir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>
  
  <xsl:param name="dir" select="'../smanob/src'"/>
  <xsl:param name="outDir" select="'./smanob/wedi_out'"/>
  <xsl:param name="srcl" select="'sma'"/>
  <xsl:param name="trgl" select="'nob'"/>

  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>
  <xsl:variable name="debug" select="'true_gogo'"/>
  <xsl:variable name="nl" select="'&#xa;'"/>


  <xsl:template match="/" name="main">
    <!-- [] | {} -->

    <xsl:variable name="out_tmp">
      <r xml:lang="{$srcl}">
	<xsl:for-each select="for $f in collection(concat($dir, '?select=*.xml'))/r/e return $f">

	  <xsl:variable name="cel">
	    <e>
	      <xsl:copy-of select="./lg" copy-namespaces="no"/>
	      <xsl:for-each select="./mg">
		<mg>
		  <xsl:for-each select="./tg">
		    <tg>
		      <xsl:copy-of select="./*[./@dict = 'yes']/preceding-sibling::re" copy-namespaces="no"/>
		      <xsl:copy-of select="./*[./@dict = 'yes']" copy-namespaces="no"/>
		    </tg>
		  </xsl:for-each>
		</mg>
	      </xsl:for-each>
	    </e>
	  </xsl:variable>

<!-- 	  <xsl:if test="some $c in $cel/e/mg/tg/* satisfies starts-with($c/local-name(), 't') and not(normalize-space($c) = '')"> -->
	    <xsl:copy-of select="$cel"/>
<!-- 	  </xsl:if> -->

      </xsl:for-each>
    </r>
    </xsl:variable>

    <xsl:result-document href="{$outDir}/all_{concat($srcl, $trgl)}.{$e}" format="{$of}">
      <xsl:copy-of select="$out_tmp"/>
    </xsl:result-document>

  </xsl:template>
  
</xsl:stylesheet>

