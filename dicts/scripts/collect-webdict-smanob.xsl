<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main collect-dict-parts.xsl dir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs xhtml">

<!--   <xsl:strip-space elements="*"/> -->
<!--   <xsl:output method="xml" -->
<!-- 	      encoding="UTF-8" -->
<!-- 	      omit-xml-declaration="no" -->
<!-- 	      doctype-system="../../scripts/gt_dictionary.dtd" -->
<!-- 	      doctype-public="-//XMLmind//DTD gt_dictionary//SE" -->
<!-- 	      indent="yes"/> -->

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
	<xsl:for-each select="for $f in collection(concat($dir, '?select=*.xml'))/r/e[not(./lg/l/@pos = 'prop')][not(./lg/l/@pos = 'propPl')] return $f">

	  <xsl:variable name="cel">
	    <e>
	      <xsl:copy-of select="./lg" copy-namespaces="no"/>
	      <xsl:for-each select="./mg[not(./@xml:lang = 'sme')]">
		<mg>
		  <xsl:for-each select="./tg[./@xml:lang = 'nob']">
		    <tg>
		      <xsl:copy-of select="./*" copy-namespaces="no"/>
		    </tg>
		  </xsl:for-each>
		</mg>
	      </xsl:for-each>
	    </e>
	  </xsl:variable>

	  <!-- this check seems not superfluous, hence no need of a tmp variable for that -->

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

