<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the path to the collection of XML-files to check
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main THIS_FILE inputDir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="text"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      doctype-system="../scripts/gt_dictionary.dtd"
	      doctype-public="-//XMLmind//DTD gt_dictionary//SE"
	      indent="yes"/>
  
  <xsl:param name="inputDir" select="'.'"/>
  <xsl:variable name="outputDir" select="'no-analysis'"/>
  <xsl:variable name="e" select="'txt'"/>


  <xsl:template match="/" name="main">

    <xsl:variable name="emptyFiles">
      <emptyFiles>
	<xsl:for-each select="collection(concat($inputDir, '?select=*.xml'))">
	  <xsl:if test="./r[not(./node())]">
	    <xsl:variable name="lemma_pos" select="substring-before(tokenize(document-uri(.), '/')[last()], '.xml')"/>
	    <xsl:variable name="lemma" select="substring-before($lemma_pos, '_')"/>
	    <xsl:variable name="pos" select="substring-after($lemma_pos, '_')"/>
	    
	    <lemma>
	      <xsl:attribute name="pos">
		<xsl:value-of select="$pos"/>
	      </xsl:attribute>
		<xsl:value-of select="$lemma"/>
	    </lemma>
	  </xsl:if>
	</xsl:for-each>
      </emptyFiles>
    </xsl:variable>

    <xsl:variable name="emptyFiles_pos">
      <emptyFiles>
	<xsl:for-each-group select="$emptyFiles/emptyFiles/lemma" group-by="./@pos">
	  <xsl:element name="pos">
	    <xsl:attribute name="posval">
	      <xsl:value-of select="current-grouping-key()"/>
	    </xsl:attribute>
	    <xsl:for-each select="current-group()">
	      <xsl:element name="lemma">
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:for-each>
	  </xsl:element>
	</xsl:for-each-group>
      </emptyFiles>
    </xsl:variable>
    
    <!--     <xsl:copy-of select="$emptyFiles_pos"/> -->
    
    <!-- output the data into separate txt-files: pos it the file name descriptor-->
    <xsl:for-each select="$emptyFiles_pos/emptyFiles/pos">
      <xsl:result-document href="{$outputDir}/missing_analysis_{./@posval}.{$e}">
	<xsl:for-each select="./lemma">
	  <xsl:value-of select="concat(., '&#xa;')"/>
	</xsl:for-each>
      </xsl:result-document>
    </xsl:for-each>
    
    
  </xsl:template>
  
</xsl:stylesheet>
