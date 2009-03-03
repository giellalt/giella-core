<?xml version="1.0"?>
<!--+
    | Transforms termcenter.xml files into tab-separated entries of sme-nob.
    | Usage: xsltproc termc2txt.xsl termcenter.xml
    | 
    +-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
  
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      indent="yes"/>
  
  <xsl:param name="gtpath" select="'gogo-input-files'"/>
  <xsl:param name="outputDir" select="'gogo-output-files'"/>
  <xsl:variable name="e" select="'xml'"/>
<!--   <xsl:variable name="outputDir" select="'xml-out'"/> -->

<!-- sámediggejoavkku -->
<!-- sámediggejoavku -->

  <xsl:template match="lg">
    <xsl:param name="document" select="concat(
				       'file:',
				       $gtpath,
				       '/',
				       l,
				       '_',
				       l/@pos,
				       '.xml')"/>
    <xsl:variable name="source_lemma" select="l"/>
    <xsl:variable name="source_pos" select="l/@pos"/>
    <xsl:variable name="source_tg" select="../mg/tg"/>

    <lg>
      <xsl:apply-templates/>
      <xsl:if test="l/@pos = 'n'  or
		    l/@pos = 'a'  or
		    l/@pos = 'prop'  or
		    l/@pos = 'num'  or
		    l/@pos = 'v'  ">


	<!-- <xsl:copy-of select="document($document)/result"/> -->

	<xsl:for-each select="document($document)/result/e">
	  <xsl:choose>
	    <xsl:when test="./lg/l = $source_lemma">
	      <xsl:copy-of select="./lg/analysis"/>
	      <xsl:copy-of select="../mini_paradigm"/>
	    </xsl:when>
	    <xsl:otherwise>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
	
	<xsl:variable name="rest">
	  <xsl:for-each select="document($document)/result/e">
	    <xsl:choose>
	      <xsl:when test="./lg/l = $source_lemma">
		<xsl:copy-of select="./lg/analysis"/>
	      </xsl:when>
	      <xsl:otherwise>
		<r>
		  <e>
		    <xsl:copy-of select="./lg"/>
		    <mg>
		      <xsl:copy-of select="$source_tg"/>
		    </mg>
		  </e>
		</r>		
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:for-each>
	</xsl:variable>
	
	<!-- output the data into separate xml-files: pos it the file name -->
	<xsl:result-document href="{$outputDir}/{$source_lemma}_{$source_pos}.{$e}">
	  <r>
	    <xsl:for-each select="$rest/r/e">
	      <e>
		<lg>
		  <l>
		    <xsl:attribute name="pos">
		      <xsl:value-of select="concat(./lg/l/@pos, '_dublu_', ./lg/lemma_ref)"/>
		    </xsl:attribute>
		    <xsl:value-of select="./lg/l"/>
		  </l>
		  <xsl:copy-of select="./lg/lemma_ref"/>
		  <xsl:copy-of select="./lg/analysis"/>
		</lg>
		<xsl:copy-of select="./mg"/>
	      </e>
	    </xsl:for-each>
	  </r>
	</xsl:result-document>

      </xsl:if>
    </lg>
  </xsl:template>
  
  <xsl:template match="node()|@*" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
