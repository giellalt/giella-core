<?xml version="1.0"?>
<!--+
    | Transforms the NOB-data from text format into xml format
    | Only simple POSs are handled!
    | NB: An XSLT-2.0-processor is needed!
    | The input: NOB data in the given format
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main nobDB_txt2xml.xsl file="INPUT-FILE"
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
  <xsl:param name="file" select="'/Usefullform_bm_u8.txt'"/>
  <xsl:param name="path" select="'.'"/>
  <xsl:param name="outputDir" select="'XML_out'"/>

  <!-- Patterns for the feature values -->
  <xsl:variable name="e" select="'xml'"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($file, '/'))[last()], '.xml')"/>
  
  
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
		  <!-- <xsl:for-each select="$singleForms/wordform[not(contains(./text(), '-'))]"> because of the e-påaste et Co. -->
		  <xsl:for-each select="$singleForms/wordform">
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
		</xsl:variable>
		
		<xsl:copy-of select="$iForms"/>
		
	      </analysis>
	    </xsl:for-each-group>
	  </big_paradigm>
	</xsl:variable>

	<xsl:variable name="paradigm">
	  <paradigm>
	    <xsl:for-each select="$big_paradigm/big_paradigm/analysis">
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
	
	<!-- <xsl:copy-of select="$paradigm"/> -->

	<xsl:for-each-group select="$big_paradigm/big_paradigm/analysis/wordform" group-by="./@value">
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
    
    <xsl:result-document href="{$path}/{$outputDir}/{$file_name}.{$e}">
      <xsl:copy-of select="$result"/>
    </xsl:result-document>
    
  </xsl:template>
  
</xsl:stylesheet>

