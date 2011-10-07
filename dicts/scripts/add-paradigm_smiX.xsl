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

  <xsl:output method="text" name="txt"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:output method="xml" name="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:param name="inFile" select="'default.xml'"/>
  <xsl:param name="gtpath" select="'gogo-input-files'"/>
  <xsl:param name="outputDir" select="'gogo-output-files'"/>
  <xsl:variable name="outFormat" select="'xml'"/>
  <xsl:variable name="e" select="$outFormat"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>

  <!--  tagging places for a future unification of all add-paradigm scripts: allPos is lang dep -->
  <xsl:variable name="allPos" select="'__n__v__a__prop__actor__num__g3__pron__npl__'"/>
  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="logFile" select="'default'"/>
  <xsl:variable name="logDir" select="'logDir'"/>
  <xsl:variable name="lang" select="'sme'"/>

  <xsl:variable name="e" select="'xml'"/>
  <!--   <xsl:variable name="outputDir" select="'xml-out'"/> -->
  
  <xsl:template match="/" name="main">
    <r>
      <xsl:copy-of select="document($inFile)/r/@*"/>
      <xsl:for-each select="document($inFile)/r/e">

	<xsl:variable name="generated_data" select="concat('file:', $gtpath, '/', l, '_', l/@pos, '.xml')"/>

	<xsl:if test="doc-available($generated_data)">
	  <xsl:if test="$debug">
	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('=======', $nl, 
				    'Processing ', $document, $nl,
				    '=====================================', $nl)"/>
	    </xsl:message>
	  </xsl:if>
	  
	  <e>
	    <xsl:copy-of select="./@*"/>
	  </e>
	</xsl:if>
	
	<xsl:if test="doc-available($generated_data)">
	  <xsl:if test="$debug">
	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('=======', $nl, 
				    'Processing ', $document, $nl,
				    '=====================================', $nl)"/>
	    </xsl:message>
	  </xsl:if>
	  
	  <e>
	    <xsl:copy-of select="./@*"/>
	  </e>
	</xsl:if>
      </xsl:for-each>
    </r>
    
    
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


    <xsl:if test="doc-available($document)">
      <xsl:if test="$debug">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('=======', $nl, 
				'Processing ', $document, $nl,
				'=====================================', $nl)"/>
	</xsl:message>
      </xsl:if>
      
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
	  
	  <xsl:for-each select="document($document)/result/e">
	    <xsl:choose>
	      <xsl:when test="./lg/l = $source_lemma">
		<xsl:copy-of copy-namespaces="no" select="./lg/analysis"/>
		<xsl:copy-of copy-namespaces="no" select="./lg/spelling"/>
		<!-- build miniparadigm -->
		<xsl:call-template name="get_miniparadigm">
		  <xsl:with-param name="lang" select="$lang"/>
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
			<xsl:value-of select="concat(./lg/l/@pos, '_wf_', ./lg/lemma_ref)"/>
		      </xsl:attribute>
		      <xsl:value-of select="./lg/l"/>
		    </l>
		    <lemma_ref>
		      <xsl:attribute name="lemmaID">
			<xsl:value-of select="$source_id"/>
		      </xsl:attribute>
		      <xsl:value-of select="./lg/lemma_ref"/>
		    </lemma_ref>
		    
		    <xsl:copy-of copy-namespaces="no" select="./lg/analysis"/>
		    <xsl:copy-of copy-namespaces="no" select="./lg/spelling"/>
		  </lg>
		  <xsl:copy-of copy-namespaces="no" select="mg"/>
		</e>
	      </xsl:for-each>
	    </r>
	  </xsl:result-document>
	  
	</xsl:if>
      </lg>
      
    </xsl:if>
    
    <xsl:if test="not(doc-available($document))">
      <xsl:if test="$debug">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('%%%%%%%%%%', $nl, 
				'No ', $document, $nl,
				'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%', $nl)"/>
	</xsl:message>
	
	<xsl:result-document href="{$logDir}/{$source_lemma}_{$source_pos}.{$e}">
	  <r flag="no_xml_file_after_paradigm-generation">
	    <xsl:copy-of copy-namespaces="no" select=".."/>
	  </r>
	</xsl:result-document>
      </xsl:if>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="node()|@*" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="get_miniparadigm">
    <xsl:param name="lang"/>
    <xsl:param name="pos"/>
    <xsl:param name="par"/>
    <mini_paradigm>
      <xsl:if test="$pos = 'v'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Sg1') and not(contains(./@ms, '/'))]
						  [./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Sg3') and not(contains(./@ms, '/'))]
						  [./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Pl3') and not(contains(./@ms, '/'))]
						  [./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Sg1') and not(contains(./@ms, '/'))]
						  [./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Sg3') and not(contains(./@ms, '/'))]
						  [./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Pl3') and not(contains(./@ms, '/'))]
						  [./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_ConNeg') and not(contains(./@ms, '/'))]
						  [./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="($pos = 'n') or ($pos = 'actor') or ($pos = 'g3') or ($pos = 'pron')">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Gen')][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill')][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Ill')][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'num'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill')][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Nom')][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Gen')][./wordform/@value]"/>
      </xsl:if>
      <!-- Loc: i/fra -->
      <xsl:if test="$pos = 'prop'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Sg_Gen'][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Sg_Ill'][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Sg_Loc'][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'npl'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Pl_Gen'][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Pl_Ill'][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Pl_Loc'][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'a'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Attr'][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Pl_Nom'][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Comp_Sg_Nom'][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[./@ms = 'Superl_Sg_Nom'][./wordform/@value]"/>
      </xsl:if>
    </mini_paradigm>
  </xsl:template>
  
</xsl:stylesheet>
