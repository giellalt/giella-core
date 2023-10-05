<?xml version="1.0"?>
<!--+
    | The parameter: the path to the collection of XML-files to compile
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main (_sax) collect-dict-parts.xsl dir=DIR
    +-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:strip-space elements="*"/>

  <xsl:output method="text" name="txt"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:output method="xml" name="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:param name="inFile" select="'../smenob/d_bin_vvv/smenob_vvv.xml'"/>
  <xsl:param name="inDir" select="'/Users/cipriangerstenberger/main/gt/sme/testing/Runs/run_04/vmax/Gen_tmp/XML_out'"/>
  <xsl:variable name="outDirPath" select="substring-before($inFile, (tokenize($inFile, '/'))[last()])"/>
  <xsl:param name="outDir" select="'xml-rest-paradigm'"/>
  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>
  <xsl:variable name="inFile_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>

  <!--  tagging places for a future unification of all add-paradigm scripts: allPos is lang dep -->
  <xsl:variable name="allPos" select="'__n__v__a__prop__actor__num__g3__pron__npl__'"/>
  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="logFile" select="'default'"/>
  <xsl:variable name="logDir" select="'logDir'"/>
  <xsl:variable name="lang" select="'sme'"/>

  <xsl:template match="/" name="main">
    <r>
      <xsl:copy-of select="document($inFile)/r/@*"/>
      <xsl:for-each select="document($inFile)/r/e">
	<xsl:variable name="current_e" select="."/>
	<xsl:variable name="src_id">
	  <xsl:variable name="attr_values">
	    <xsl:for-each select="./lg/l/@*">
	      <xsl:text>_</xsl:text>
	      <xsl:value-of select="normalize-space(.)" />
	    </xsl:for-each>
	  </xsl:variable>
	  <xsl:value-of select="concat(./lg/l, $attr_values)"/>
	</xsl:variable>

	<xsl:variable name="generated_data">
	  <xsl:for-each select="('1', '2', '3', '4', '5')">
	    <f>
	      <xsl:value-of select="concat('file:', $inDir, '/', $current_e/lg/l, '_', $current_e/lg/l/@pos, '_v', ., '.xml')"/>
	    </f>
	  </xsl:for-each>
	  
	</xsl:variable>

	<xsl:for-each select="for $f in  document($generated_data/f) return $f">
	  <xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	  <xsl:variable name="file_name" select="substring-before($current_file, '.')"/>
	  <xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	  <xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	  
	  <xsl:if test="false()">
	    <xsl:message terminate="no">
	      <xsl:value-of select="concat('processing ', document-uri(.), $nl)"/>
	      <xsl:value-of select="concat('..........................', $nl)"/>
	    </xsl:message>
	  </xsl:if>

	  <!--  xsl:if test="doc-available(.)" -->
	  <xsl:if test="count(./result/paradigm/*) &gt; 0">
	    <xsl:if test="true()">
	      <xsl:message terminate="no">
		<xsl:value-of select="concat('===', $current_file, '===', $nl)"/>
	      </xsl:message>
	    </xsl:if>
	    
	    <!-- xsl:variable name="current_vlemma" select="./result/paradigm/analysis[1]/wordform/@value"/ -->
	    <xsl:variable name="current_vlemma">
	      <xsl:if test="./result/paradigm/analysis[ends-with(./@ms, 'Sg_Nom')][1]/wordform[1] and not(./result/paradigm/analysis[ends-with(./@ms, 'Sg_Nom')][1]/wordform[1]/@value = '')">
		<xsl:value-of select="./result/paradigm/analysis[ends-with(./@ms, 'Sg_Nom')][1]/wordform[1]/@value"/>
	      </xsl:if>
	      <xsl:if test="not(./result/paradigm/analysis[ends-with(./@ms, 'Sg_Nom')] or ./result/paradigm/analysis[ends-with(./@ms, '_Inf')])">
		<xsl:value-of select="./result/paradigm/analysis[ends-with(./@ms, 'Pl_Nom')][1]/wordform[1]/@value"/>
	      </xsl:if>
	      <xsl:if test="./result/paradigm/analysis[ends-with(./@ms, '_Inf')]">
		<xsl:value-of select="./result/paradigm/analysis[ends-with(./@ms, '_Inf')][1]/wordform[1]/@value"/>
	      </xsl:if>
	    </xsl:variable>
	    <xsl:variable name="current_paradigm" select="./result/paradigm"/>
	    <xsl:variable name="current_v" select="(tokenize($file_name, '_'))[last()]"/>
	    
	    <xsl:if test="true()">
	      <xsl:message terminate="no">
		<!-- xsl:value-of select="concat(':::current lemma ', $current_e/lg/l, ' === current_vlemma ', $current_vlemma, $nl)"/ -->
		<xsl:value-of select="concat(':::current lemma ', $current_e/lg/l, ' === ', $nl)"/>
	      </xsl:message>
	    </xsl:if>


	    <!-- do the job! -->
	    <e vform="{$file_name}">
	      <xsl:copy-of select="$current_e/@*"/>
	      <lg>
		<l>
		  <xsl:copy-of select="$current_e/lg/l/@*"/>
		  <xsl:attribute name="current_v">
		    <xsl:value-of select="$current_v"/>
		  </xsl:attribute>
		  <xsl:value-of select="$current_vlemma"/>
		</l>
		<xsl:for-each select="./result/e">
		  <xsl:choose>
		    <xsl:when test="./lg/l = $current_vlemma">
		      <!-- to filter Allegro NVD here -->
		      <xsl:variable name="filtered_analyses">
			<xsl:for-each select="./lg/analysis[starts-with(./text(), $current_v)]">
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
		      
		      <!-- xsl:copy-of copy-namespaces="no" select="./lg/analysis[starts-with(./text(), $current_v)]"/ -->

		      <xsl:copy-of copy-namespaces="no" select="./lg/spelling"/>
		      <!-- build miniparadigm -->
		      <xsl:call-template name="get_miniparadigm">
			<xsl:with-param name="pos" select="$current_e/lg/l/@pos"/>
			<xsl:with-param name="par" select="$current_paradigm"/>
			<xsl:with-param name="var" select="$current_v"/>
		      </xsl:call-template>
		    </xsl:when>
		    <xsl:otherwise>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:for-each>
	      </lg>
	      <xsl:copy-of select="$current_e/mg"/>

	      <xsl:variable name="rest">
		<xsl:for-each select="./result/e">
		  <xsl:choose>
		    <xsl:when test="./lg/l = $current_vlemma">
		      <!-- 		<xsl:copy-of select="./lg/analysis"/> -->
		      <!-- 		<xsl:copy-of select="./lg/spelling"/> -->
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:if test="false()">
			<xsl:message terminate="no">
			  <xsl:value-of select="concat(':::current lemma ', ./lg/l, ' === current_vlemma ', $current_vlemma, $nl)"/>
			</xsl:message>
		      </xsl:if>
		      <r>
			<e>
			  <xsl:copy-of copy-namespaces="no" select="$current_e/@*"/>
			  <xsl:copy-of copy-namespaces="no" select="./lg"/>
			  <xsl:copy-of copy-namespaces="no" select="$current_e/mg"/>
			</e>
		      </r>		
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:for-each>
	      </xsl:variable>

	      <!-- output the data into separate xml-files: pos it the file name -->
	      <xsl:result-document href="smenob/d_bin_vvv/{$outDir}/{$file_name}.{$e}">
		<r>
		  <xsl:for-each select="$rest/r/e">
		    <xsl:if test="false()">
		      <xsl:message terminate="no">
			<xsl:value-of select="concat(':::current lemma ', ./lg/l, ' === current_vlemma ', $current_vlemma, $nl)"/>
		      </xsl:message>
		    </xsl:if>
		    <e>
		      <xsl:copy-of select="./@*[not(. = '')]"/>
		      <lg>
			<l>
			  <xsl:attribute name="pos">
			    <xsl:value-of select="concat($current_e/lg/l/@pos, '_wf_', $current_vlemma[1], '_', $current_v)"/>
			  </xsl:attribute>
			  <xsl:copy-of select="$current_e/lg/l/@*[not(local-name() = 'pos')]"/>
			  <xsl:value-of select="./lg/l"/>
			</l>
			<!-- this should be changed when the internal references for macdict compilation would work:
			concat ALL attr-values of the current_vlemma, not only the pos -->

			<xsl:if test="false()">
			  <xsl:message terminate="no">
			    <xsl:value-of select="concat('KKK_current lemma ', ./lg/l, ' XXX current_vlemma ', $current_vlemma, $nl)"/>
			  </xsl:message>
			</xsl:if>
			

			<lemma_ref lemmaID="{concat($current_vlemma[1], '_', $current_e/lg/l/@pos, '_', $current_v)}">
			  <xsl:value-of select="$current_vlemma"/>
			</lemma_ref>
			<!-- to filter Allegro NVD here -->
			<xsl:variable name="filtered_analyses">
			  <xsl:for-each select="./lg/analysis[starts-with(./text(), $current_v)]">
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
			
			<!-- xsl:copy-of copy-namespaces="no" select="./lg/analysis[starts-with(./text(), $current_v)]"/ -->

			<xsl:copy-of copy-namespaces="no" select="./lg/spelling"/>
		      </lg>
		      <xsl:copy-of copy-namespaces="no" select="mg"/>
		    </e>
		  </xsl:for-each>
		</r>
	      </xsl:result-document>
	      
	    </e>
	  </xsl:if>
	  <!-- /xsl:if -->
	</xsl:for-each>
      </xsl:for-each>
    </r>
  </xsl:template>
  
  <xsl:template name="get_miniparadigm">
    <xsl:param name="pos"/>
    <xsl:param name="par"/>
    <xsl:param name="var"/>
    <mini_paradigm>
      <xsl:if test="$pos = 'v'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Sg1') and not(contains(./@ms, '/'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Sg3') and not(contains(./@ms, '/'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_Pl3') and not(contains(./@ms, '/'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Sg1') and not(contains(./@ms, '/'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Sg3') and not(contains(./@ms, '/'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prt_Pl3') and not(contains(./@ms, '/'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Ind_Prs_ConNeg') and not(contains(./@ms, '/'))]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="($pos = 'n') or ($pos = 'actor') or ($pos = 'g3') or ($pos = 'pron')">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Gen')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Ill')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'num'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Nom')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Gen')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <!-- Loc: i/fra -->
      <xsl:if test="$pos = 'prop'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Gen')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Ill')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Sg_Loc')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'npl'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Gen')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Ill')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[ends-with(./@ms, 'Pl_Loc')]
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
      <xsl:if test="$pos = 'a'">
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($var, '_', upper-case($pos), '_')) = 'Attr']
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($var, '_', upper-case($pos), '_')) = 'Pl_Nom']
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($var, '_', upper-case($pos), '_')) = 'Comp_Attr']
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($var, '_', upper-case($pos), '_')) = 'Comp_Sg_Nom']
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
	<xsl:copy-of copy-namespaces="no" select="$par/analysis[substring-after(./@ms, concat($var, '_', upper-case($pos), '_')) = 'Superl_Sg_Nom']
						  [not(contains(./@ms, 'Allegro'))][./wordform/@value]"/>
      </xsl:if>
    </mini_paradigm>
  </xsl:template>

</xsl:stylesheet>
