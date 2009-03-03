<?xml version="1.0"?>
<!--+
    | 
    | The parameter: the path to the collection of XML-files to check
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_FILE inputDir=DIR
    | 
    +-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      doctype-system="../scripts/gt_dictionary.dtd"
	      doctype-public="-//XMLmind//DTD gt_dictionary//SE"
	      indent="yes"/>
  
  <xsl:param name="inputFile" select="'gogo_file'"/>
  <xsl:param name="inputDir" select="'.'"/>
  <xsl:variable name="outputDir" select="'with-analysis'"/>
  <xsl:variable name="e" select="'xml'"/>


  <xsl:template match="/" name="main">

    <xsl:variable name="nonEmptyfiles">
      <nonEmptyfiles>
	<xsl:for-each select="collection(concat($inputDir, '?select=*.xml'))">
	  <xsl:if test="./r[./node()]">
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
      </nonEmptyfiles>
    </xsl:variable>

    <xsl:variable name="nonEmptyfiles_pos">
      <nonEmptyfiles>
	<xsl:for-each-group select="$nonEmptyfiles/nonEmptyfiles/lemma" group-by="./@pos">
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
      </nonEmptyfiles>
    </xsl:variable>
    
    <xsl:variable name="no_inf">
      <no_inf>
	<xsl:for-each select="doc($inputFile)/r/e[not(./lg/analysis) and ./lg/l[./@pos = 'v']]">
	  <lemma>
	    <xsl:value-of select="./lg/l"/>
	  </lemma>
	</xsl:for-each>
      </no_inf>
    </xsl:variable>
    
    <xsl:copy-of select="$no_inf"/>    

    <!--     <xsl:copy-of select="$nonEmptyfiles_pos"/> -->
    
    <!-- output the data into separate txt-files: pos it the file name descriptor-->
<!--     <xsl:for-each select="$nonEmptyfiles_pos/nonEmptyfiles/pos"> -->
<!--       <xsl:result-document href="{$outputDir}/analyzedItems_{./@posval}.{$e}" method="xml"> -->
<!-- 	<xsl:variable name="current-pos" select="./@posval"/> -->
<!-- 	<xsl:element name="{$current-pos}"> -->
<!-- 	  <xsl:for-each select="./lemma"> -->
<!-- 	    <xsl:copy-of select="."/> -->
<!-- 	     	  <xsl:value-of select="concat(., '&#xa;')"/>  -->
<!-- 	  </xsl:for-each> -->
<!-- 	</xsl:element> -->
<!--       </xsl:result-document> -->
<!--     </xsl:for-each> -->



    <xsl:for-each select="$nonEmptyfiles_pos/nonEmptyfiles/pos[./@posval = 'v']">
      <xsl:result-document href="{$outputDir}/analyzedItems_{./@posval}.txt" method="text">
	<xsl:for-each select="./lemma">
	  <xsl:value-of select="concat(., '&#xa;')"/>
	</xsl:for-each>
      </xsl:result-document>
    </xsl:for-each>
    
    <xsl:result-document href="{$outputDir}/noInf_v.txt" method="text">
      <xsl:for-each select="$no_inf/no_inf/lemma">
	<xsl:value-of select="concat(., '&#xa;')"/>
      </xsl:for-each>
    </xsl:result-document>
    
  </xsl:template>
  
</xsl:stylesheet>
