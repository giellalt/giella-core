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
  <!--  tagging places for a future unification of all add-paradigm scripts: allPos is lang dep -->
  <xsl:variable name="allPos" select="'__n__v__a__prop__actor__num__g3__pron__npl__'"/>
  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="logFile" select="'default'"/>
  <xsl:variable name="logDir" select="'logDir'"/>

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

    <xsl:variable name="current_e" select=".."/>
    
    <lg>
      <xsl:message terminate="no">
	<xsl:value-of select="concat('processing ', ./l/text(), ' ___ pos ', ./l/@pos, $nl)"/>
	<xsl:value-of select="concat('..........................', $nl)"/>
      </xsl:message>
      
      <xsl:apply-templates/>
      
      <!--       <xsl:message terminate="no"> -->
      <!-- 	<xsl:value-of select="concat('AAT ', ' ____________ ', $nl)"/> -->
      <!--       </xsl:message> -->
      
      <xsl:if test="contains($allPos, concat('__', $source_pos, '__')) and not(./l/@pg) and not(./l/@type = 'refl')">
	
	<!-- <xsl:copy-of select="document($document)/result"/> -->
	
	<xsl:if test="not(doc-available($document))">
	  <xsl:if test="$debug">
	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('%%%%%%%%%%', $nl, 
				    'No file ', $document, $nl,
				    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%', $nl)"/>
	    </xsl:message>

	    <xsl:result-document href="{$logDir}/{$source_lemma}_{$source_pos}.{$e}">
	      <r flag="no_xml_file_after_paradigm-generation">
		<xsl:copy-of copy-namespaces="no" select=".."/>
	      </r>
	    </xsl:result-document>
	  </xsl:if>
	</xsl:if>
	
	<xsl:for-each select="document($document)/result/e">
	  <xsl:choose>
	    <xsl:when test="./lg/l = $source_lemma">

	      <xsl:variable name="filtered_analyses">
		<xsl:for-each select="./lg/analysis">
		  <xsl:if test="contains(., '_Allegro')">
		    <analysis>
		      <xsl:value-of select="substring-before(., '_Allegro')"/>
		    </analysis>
		  </xsl:if>
		  <xsl:if test="contains(., '_Use/NVD')">
		    <analysis>
		      <xsl:value-of select="substring-before(., '_Use/NVD')"/>
		    </analysis>
		  </xsl:if>
		  <xsl:if test="not(contains(., '_Allegro') or contains(., '_Use/NVD'))">
		    <xsl:copy-of select="."/>
		  </xsl:if>
		</xsl:for-each>
	      </xsl:variable>
	      
	      <xsl:for-each select="distinct-values($filtered_analyses/*)">
		<analysis>
		  <xsl:copy-of select="."/>
		</analysis>
	      </xsl:for-each>
	      
	      <!--xsl:copy-of copy-namespaces="no" select="./lg/analysis"/ -->

	      <xsl:copy-of copy-namespaces="no" select="./lg/spelling"/>
	      <!-- build miniparadigm -->
	      <xsl:call-template name="get_miniparadigm">
		<xsl:with-param name="pos" select="$source_pos"/>
		<xsl:with-param name="par" select="../paradigm"/>
	      </xsl:call-template>
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
		    <xsl:if test="not($prop_source = '')">
		      <xsl:attribute name="src">
			<xsl:value-of select="$prop_source"/>
		      </xsl:attribute>
		    </xsl:if>

		    <!-- xsl:variable name="filtered_analyses">
		      <xsl:for-each select="./lg/analysis">
			<analysis>
			  <xsl:value-of select="translate(translate(., '_Allegro', ''), '_Use/NVD', '')"/>
			</analysis>
		      </xsl:for-each>
		    </xsl:variable>
		    
		    <lolo>
		      <xsl:copy-of select="distinct-values($filtered_analyses/*)"/>
		    </lolo -->
		    
		    
		    <xsl:copy-of copy-namespaces="no" select="./lg"/>
		    <xsl:copy-of copy-namespaces="no" select="$source_mg"/>
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
		<xsl:copy-of select="./@*[not(. = '')]"/>
		<lg>
		  <l>
		    <xsl:attribute name="pos">
		      <xsl:value-of select="concat($source_pos, '_wf_', ./lg/lemma_ref)"/>
		      <!-- xsl:value-of select="concat(./lg/l/@pos, '_wf_', ./lg/lemma_ref)"/ -->
		    </xsl:attribute>
		    <xsl:value-of select="./lg/l"/>
		  </l>
		  <lemma_ref>
		    <xsl:attribute name="lemmaID">
		      <xsl:value-of select="$source_id"/>
		    </xsl:attribute>
		    <xsl:value-of select="./lg/lemma_ref"/>
		  </lemma_ref>

		  <xsl:variable name="filtered_analyses">
		    <xsl:for-each select="./lg/analysis">
		      <xsl:if test="contains(., '_Allegro')">
			<analysis>
			  <xsl:value-of select="substring-before(., '_Allegro')"/>
			</analysis>
		      </xsl:if>
		      <xsl:if test="contains(., '_Use/NVD')">
			<analysis>
			  <xsl:value-of select="substring-before(., '_Use/NVD')"/>
			</analysis>
		      </xsl:if>
		      <xsl:if test="not(contains(., '_Allegro') or contains(., '_Use/NVD'))">
			<xsl:copy-of select="."/>
		      </xsl:if>
		    </xsl:for-each>
		  </xsl:variable>
		  
		  <xsl:for-each select="distinct-values($filtered_analyses/*)">
		    <analysis>
		      <xsl:copy-of select="."/>
		    </analysis>
		  </xsl:for-each>
		  
		  <xsl:copy-of copy-namespaces="no" select="./lg/spelling"/>
		</lg>
		<xsl:copy-of copy-namespaces="no" select="mg"/>
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
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Sg1') and not(contains(./@ms, '/'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Sg3') and not(contains(./@ms, '/'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Pl3') and not(contains(./@ms, '/'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Sg1') and not(contains(./@ms, '/'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Sg3') and not(contains(./@ms, '/'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Pl3') and not(contains(./@ms, '/'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_ConNeg') and not(contains(./@ms, '/'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="($pos = 'n') or ($pos = 'actor') or ($pos = 'g3') or ($pos = 'pron')">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Gen') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Ill') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'num'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill') and not(contains(./@ms, 'Use/NVD')) 
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Nom') and not(contains(./@ms, 'Use/NVD')) 
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Gen') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <!-- Loc: i/fra -->
      <xsl:if test="$pos = 'prop'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Gen') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Loc') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'npl'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Gen') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Ill') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Loc') and not(contains(./@ms, 'Use/NVD'))
						  and not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'a'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($pos, '_')) = 'Attr'][not(contains(./@ms, 'Use/NVD'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($pos, '_')) = 'Pl_Nom'][not(contains(./@ms, 'Use/NVD'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($pos, '_')) = 'Comp_Attr'][not(contains(./@ms, 'Use/NVD'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($pos, '_')) = 'Comp_Sg_Nom'][not(contains(./@ms, 'Use/NVD'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($pos, '_')) = 'Superl_Sg_Nom'][not(contains(./@ms, 'Use/NVD'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
    </mini_paradigm>
  </xsl:template>
  
</xsl:stylesheet>
