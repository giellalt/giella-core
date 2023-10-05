<?xml version="1.0"?>
<!--+
    | 
    | script to generated dictionaries from a given gt_dict file
    | Usage: java net.sf.saxon.Transform -it main THIS_SCRIPT inFile=DICT_FILE
    +-->

<!-- java -Xmx2048m net.sf.saxon.Transform -it main gt_sd2tg.xsl inFile= -->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs local xhtml">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  
  <!-- Input files -->
  <xsl:param name="inFile" select="'default.xml'"/>

  <!-- Output dir, files -->
  <xsl:variable name="outputDir" select="'outDir'"/>
  <!-- use only the first translation -->
  <xsl:variable name="modus" select="'all'"/>
  <!--   <xsl:variable name="modus" select="'only_one'"/> -->
  <!-- source language -->
  <xsl:param name="srcl" select="'sme'"/>
  <!-- target language -->
  <xsl:param name="trgl" select="'fin'"/>
  
  <!-- Patterns for the feature values -->
  <xsl:variable name="output_format" select="'xml'"/>
  <xsl:variable name="e" select="$output_format"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>
  
  
  
  <xsl:template match="/" name="main">
    <xsl:choose>
      <xsl:when test="doc-available($inFile)">
	<xsl:variable name="out_tmp">
	  <r>
	    <xsl:attribute name="xml:lang">
	      <xsl:value-of select="$trgl"/>
	    </xsl:attribute>
	    <xsl:for-each select="doc($inFile)/r/e">
	      
	      <xsl:for-each select="./mg/tg/t">
		<e>
		  <lg>
		    <l>
		      <xsl:attribute name="pos">
			<xsl:value-of select="if (not(@pos = '')) then @pos else 'xxx'"/>
		      </xsl:attribute>
		      <xsl:value-of select="normalize-space(.)"/>
		    </l>
		  </lg>
		  <mg>
		    <tg>
		      <t>
			<xsl:attribute name="pos">
			  <xsl:value-of select="../../../lg/l/@pos"/>
			</xsl:attribute>
			<xsl:value-of select="normalize-space(../../../lg/l)"/>
		      </t>
		    </tg>
		  </mg>
		</e>
	      </xsl:for-each>
	    </xsl:for-each>
	  </r>
	</xsl:variable>
	
	

	<!-- out -->
	<xsl:result-document href="{$outputDir}/{$file_name}_{$trgl}.{$e}" format="{$output_format}">
	  <xsl:copy-of select="$out_tmp"/>
	</xsl:result-document>

      </xsl:when>
      <xsl:otherwise>
	<xsl:text>Cannot locate: </xsl:text><xsl:value-of select="$inFile"/><xsl:text>&#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!--   <xsl:template match="*"> -->
<!--     <xsl:element name="{local-name()}"> -->
<!--       <xsl:apply-templates select="*"/> -->
<!--     </xsl:element> -->
<!--   </xsl:template> -->
  


</xsl:stylesheet>


