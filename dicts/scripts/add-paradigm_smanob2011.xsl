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
  <xsl:variable name="allPos" select="'__v__n__pron__prop__propPl__a__num__'"/>
  <xsl:variable name="e" select="'xml'"/>
  <!--   <xsl:variable name="outputDir" select="'xml-out'"/> -->
  
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
    <xsl:variable name="source_id">
      <xsl:variable name="attr_values">
	<xsl:for-each select="l/@*">
	  <xsl:text>_</xsl:text>
	  <xsl:value-of select="normalize-space(.)" />
	</xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="concat(l, $attr_values)"/>
    </xsl:variable>

    <xsl:variable name="source_mg" select="../mg"/>

    <xsl:variable name="prop_source" select="../@src"/>
    
    <lg>

      <xsl:apply-templates/>

      <xsl:if test="contains($allPos, concat('__', $source_pos, '__'))">

	<!-- <xsl:copy-of select="document($document)/result"/> -->

	<xsl:for-each select="document($document)/result/e">
	  <xsl:choose>
	    <xsl:when test="./lg/l = $source_lemma">
	      <xsl:copy-of select="./lg/analysis"/>
	      <xsl:copy-of select="./lg/spelling"/>
	      <!-- build miniparadigm -->
	      <xsl:call-template name="get_miniparadigm">
		<xsl:with-param name="pos" select="$source_pos"/>
		<xsl:with-param name="par" select="../paradigm"/>
	      </xsl:call-template>
	      <!-- <xsl:copy-of select="../paradigm"/> -->
	    </xsl:when>
	    <xsl:otherwise>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
	
	<xsl:variable name="rest">
	  <xsl:for-each select="document($document)/result/e">
	    <xsl:choose>
	      <xsl:when test="./lg/l = $source_lemma">
<!-- 		<xsl:copy-of select="./lg/analysis"/> -->
<!-- 		<xsl:copy-of select="./lg/spelling"/> -->
	      </xsl:when>
	      <xsl:otherwise>
		<r>
		  <e>
<!-- 		    <xsl:if test="./lg/l/@pos = 'prop'"> -->
<!-- 		      <xsl:attribute name="source"> -->
<!-- 			<xsl:value-of select="./@source"/> -->
<!-- 		      </xsl:attribute> -->
<!-- 		    </xsl:if> -->
		    <xsl:copy-of select="./lg"/>
		    <xsl:copy-of select="$source_mg"/>
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
		<xsl:if test="starts-with(./lg/analysis[1], 'Prop')">
		  <xsl:attribute name="src">
		    <xsl:value-of select="$prop_source"/>
		  </xsl:attribute>
		</xsl:if>
		<lg>
		  <l>
		  <!-- change this later, this is too ugly -->
		    <xsl:attribute name="pos">
		      <xsl:if test="starts-with(./lg/analysis[1], 'Prop')">
			<xsl:if test="starts-with(./lg/analysis[1], 'Prop_Plc_Sg')">
			  <xsl:value-of select="concat('prop', '_wf_', ./lg/lemma_ref)"/>
			</xsl:if>
			<xsl:if test="starts-with(./lg/analysis[1], 'Prop_Plc_Pl')">
			  <xsl:value-of select="concat('propPl', '_wf_', ./lg/lemma_ref)"/>
			</xsl:if>
		      </xsl:if>
		      <xsl:if test="not(starts-with(./lg/analysis[1], 'Prop'))">
			<xsl:value-of select="concat(./lg/l/@pos, '_wf_', ./lg/lemma_ref)"/>
		      </xsl:if>
		    </xsl:attribute>
		    
		    <xsl:if test="./lg/l/@pos = 'v'">		    
		      <xsl:if test="not($source_lemma/@class = '')">
			<xsl:attribute name="class">
			  <xsl:value-of select="$source_lemma/@class"/>
			</xsl:attribute>
		      </xsl:if>
		      
		      <xsl:if test="not($source_lemma/@stem ='')">
			<xsl:attribute name="stem">
			  <xsl:value-of select="$source_lemma/@stem"/>
			</xsl:attribute>
		      </xsl:if>
		      
		      <!-- 		    <xsl:if test="not($source_lemma/@umlaut"> -->
		      <!-- 		      <xsl:attribute name="umlaut"> -->
		      <!-- 			<xsl:value-of select="$source_lemma/@umlaut"/> -->
		      <!-- 		      </xsl:attribute> -->
		      <!-- 		    </xsl:if> -->
		      
		    </xsl:if>
		    <xsl:value-of select="./lg/l"/>
		  </l>
		  <lemma_ref>
		    <xsl:attribute name="lemmaID">
		      <xsl:value-of select="$source_id"/>
		    </xsl:attribute>
		    <xsl:value-of select="./lg/lemma_ref"/>
		  </lemma_ref>
		  
		  <xsl:copy-of select="./lg/analysis"/>
		  <xsl:copy-of select="./lg/spelling"/>
		</lg>
		<xsl:copy-of select="mg"/>
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
  
  <xsl:template name="get_miniparadigm">
    <xsl:param name="pos"/>
    <xsl:param name="par"/>
    <mini_paradigm>
      <xsl:if test="$pos = 'v'">
	<xsl:copy-of select="$par/analysis[./@ms = 'Ind_Prs_Sg1']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Ind_Prs_Sg3']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Ind_Prs_Pl3']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Ind_Prt_Sg1']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Ger']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'VGen']"/>
      </xsl:if>
      <xsl:if test="$pos = 'n'">
	<xsl:copy-of select="$par/analysis[./@ms = 'Sg_Gen']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Sg_Ill']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Pl_Ill']"/>
      </xsl:if>
      <xsl:if test="$pos = 'num'">
	<xsl:copy-of select="$par/analysis[./@ms = 'Sg_Gen']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Sg_Ill']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Pl_Ill']"/>
      </xsl:if>
      <xsl:if test="$pos = 'prop'">
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Sg_Gen']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Sg_Ill']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Sg_Ine']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Sg_Ela']"/>
      </xsl:if>
      <xsl:if test="$pos = 'propPl'">
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Pl_Gen']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Pl_Ill']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Pl_Ine']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Prop_Plc_Pl_Ela']"/>
      </xsl:if>
      <xsl:if test="$pos = 'a'">
	<xsl:copy-of select="$par/analysis[./@ms = 'Pred']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Comp_Sg_Nom']"/>
	<xsl:copy-of select="$par/analysis[./@ms = 'Superl_Sg_Nom']"/>
      </xsl:if>
    </mini_paradigm>
  </xsl:template>
  
</xsl:stylesheet>
