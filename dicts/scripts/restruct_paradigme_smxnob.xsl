<?xml version="1.0"?>
<!--+
    | NB: An XSLT-2.0-processor is needed!
    | 
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:fn="fn"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs fn local">
    
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      omit-xml-declaration="no"
	      indent="yes"/>
  

<xsl:function name="local:distinct-deep" as="node()*">
  <xsl:param name="nodes" as="node()*"/> 
 
  <xsl:sequence select=" 
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(local:is-node-in-sequence-deep-equal(
                          .,$nodes[position() &lt; $seq]))]
 "/>
   
</xsl:function>

<xsl:function name="local:is-node-in-sequence-deep-equal" as="xs:boolean">
  <xsl:param name="node" as="node()?"/> 
  <xsl:param name="seq" as="node()*"/> 
 
  <xsl:sequence select=" 
   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 "/>
   
</xsl:function>


  <!--   Input file in text format: as parameter -->
  <xsl:param name="file" select="'default.xml'"/>
  <xsl:param name="path" select="'.'"/>
  <xsl:param name="outputDir" select="'XML_out'"/>
  <xsl:param name="lang" select="'sme'"/>

  <!-- Patterns for the feature values -->
  <xsl:variable name="e" select="'xml'"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($file, '/'))[last()], '.xml')"/>
  <xsl:variable name="debug" select="false()"/>
  <xsl:variable name="nl" select="'&#xa;'"/>

  <xsl:template match="/" name="main">
    
    <xsl:variable name="result">
      <result>
	<xsl:variable name="lemma" select="doc($file)/paradigm/lemma"/>
	<xsl:variable name="pos" select="doc($file)/paradigm/pos"/>

	<xsl:variable name="big_paradigm">
	  <big_paradigm>
	    <xsl:for-each-group select="doc($file)/paradigm/analysis" group-by="./@ms">
	      <analysis>
		<xsl:attribute name="ms">
		  <xsl:value-of select="./@ms"/>
		</xsl:attribute>
		
		<xsl:variable name="singleForms" as="node()*">
		  <xsl:variable name="wforms" as="node()*">
		    <xsl:for-each select="current-group()">
		      <xsl:copy-of select="wordform"/>
		    </xsl:for-each>
		  </xsl:variable>
		  <forms>
		    <xsl:copy-of select="local:distinct-deep($wforms)"/>
		  </forms>
		</xsl:variable>
		
		<xsl:variable name="iForms" as="node()*">
		  <xsl:if test="$lang = 'sma'">
		    <xsl:for-each select="$singleForms/wordform[not(contains(./text(), '-'))]">
		      <xsl:variable name="curr_ndl" select="./text()"/>
		      <wordform>
			<xsl:attribute name="value">
			  <xsl:value-of select="$curr_ndl"/>
			</xsl:attribute>
			<xsl:variable name="spellings">
			  <xsl:for-each select="../wordform[contains(text(), '-')]">
			    <xsl:if test="replace(text(), '-', '') = $curr_ndl">
			      <var>
				<xsl:value-of select="."/>
			      </var>
			    </xsl:if>
			  </xsl:for-each>
			</xsl:variable>
			<xsl:if test="not($spellings = '')">
			  <spelling>
			    <xsl:copy-of select="$spellings"/>
			  </spelling>
			</xsl:if>
		      </wordform>
		    </xsl:for-each>
		  </xsl:if>

		  <xsl:if test="$lang = 'sme'">
		    <xsl:for-each select="$singleForms/wordform">
		      <xsl:variable name="curr_ndl" select="./text()"/>
		      <wordform>
			<xsl:attribute name="value">
			  <xsl:value-of select="$curr_ndl"/>
			</xsl:attribute>
			<xsl:variable name="spellings">
			  <xsl:for-each select="../wordform[contains(text(), '-')]">
			    <var>
			      <xsl:value-of select="."/>
			    </var>
			  </xsl:for-each>
			</xsl:variable>
			<xsl:if test="not($spellings = '')">
			  <spelling>
			    <xsl:copy-of select="$spellings"/>
			  </spelling>
			</xsl:if>
		      </wordform>
		    </xsl:for-each>
		  </xsl:if>
		</xsl:variable>
		
		<xsl:copy-of select="$iForms"/>
		
	      </analysis>
	    </xsl:for-each-group>
	  </big_paradigm>
	</xsl:variable>

	<xsl:variable name="paradigm">
	  <paradigm>
	    <xsl:for-each select="$big_paradigm/big_paradigm/analysis[./wordform]">
	      <analysis>
		<xsl:copy-of select="@*"/>
		<xsl:for-each select="wordform">
		  <wordform>
		    <xsl:copy-of select="@*"/>
		  </wordform>
		</xsl:for-each>
	      </analysis>
	    </xsl:for-each>
	  </paradigm>
	</xsl:variable>
	
	<xsl:if test="$paradigm/paradigm/analysis/wordform">
	  <xsl:copy-of select="$paradigm"/>
	</xsl:if>
	
	<xsl:for-each-group select="$paradigm/paradigm/analysis/wordform[not(ends-with(./@value, '-'))]" group-by="./@value">
	  <e>
	    <lg>
	      <l>
		<xsl:attribute name="pos">
		  <xsl:value-of select="$pos"/>
		</xsl:attribute>
		<xsl:value-of select="current-grouping-key()"/>
	      </l>
	      <lemma_ref>
		<xsl:value-of select="$lemma"/>
	      </lemma_ref>
	      <xsl:copy-of select="spelling"/>
	      <xsl:for-each select="current-group()">
		<analysis>
		  <xsl:value-of select="../@ms"/>
		</analysis>
	      </xsl:for-each>
	    </lg>
	  </e>
	</xsl:for-each-group>

      </result>
    </xsl:variable>
    
    <xsl:if test="some $node in $result/result/paradigm/analysis satisfies starts-with($node/@ms, 'v1_')">

      <xsl:if test="$debug">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('gogo ', $nl)"/>
	</xsl:message>
      </xsl:if>

      <xsl:for-each select="('v1', 'v2', 'v3', 'v4', 'v5')">
	<xsl:variable name="current_tag" select="."/>
	<xsl:variable name="l_result">
	  <result>
	    <paradigm>
	      <xsl:copy-of select="$result/result/paradigm/analysis[starts-with(./@ms, $current_tag)]"/>
	    </paradigm>
	    <xsl:copy-of select="$result/result/e[some $node in ./lg/analysis satisfies starts-with($node, $current_tag)]"/>
	  </result>
	</xsl:variable>

	<xsl:result-document href="{$path}/{$outputDir}/{$file_name}_{.}.{$e}">
	  <xsl:copy-of select="$l_result"/>
	</xsl:result-document>
      </xsl:for-each>
    </xsl:if>
    
    <xsl:if test="every $node in $result/result/paradigm/analysis satisfies
		  not(starts-with($node/@ms, 'v1_') or 
		  starts-with($node/@ms, 'v2_') or
		  starts-with($node/@ms, 'v3_') or
		  starts-with($node/@ms, 'v4_') or
		  starts-with($node/@ms, 'v5_'))">
      
      <xsl:if test="$debug">
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('logo ', $nl)"/>
	</xsl:message>
      </xsl:if>

      <xsl:result-document href="{$path}/{$outputDir}/{$file_name}.{$e}">
	<xsl:copy-of select="$result"/>
      </xsl:result-document>
    </xsl:if>
    
  </xsl:template>
  
</xsl:stylesheet>

