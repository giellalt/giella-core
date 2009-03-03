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

	<xsl:variable name="mini_paradigm">
	  <mini_paradigm>
	    <xsl:for-each select="doc($file)/paradigm/analysis">

	      <xsl:choose>
		<xsl:when test="$pos = 'a'">
		  <xsl:choose>
		    <xsl:when test="./@ms = 'Attr' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		    <xsl:when test="./@ms = 'Pl_Nom' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		    <xsl:when test="./@ms = 'Comp_Sg_Nom' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		    <xsl:when test="./@ms = 'Superl_Sg_Nom' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		  </xsl:choose>
		</xsl:when>

		<xsl:when test="$pos = 'n' and not(starts-with(./@ms, 'Prop'))">
		  <xsl:choose>
		    <xsl:when test="./@ms = 'Sg_Gen' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		    <xsl:when test="./@ms = 'Sg_Ill' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		    <xsl:when test="./@ms = 'Pl_Ill' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		  </xsl:choose>
		</xsl:when>

		<xsl:when test="$pos = 'n' and starts-with(./@ms, 'Prop')">
		  <xsl:choose>
		    <xsl:when test="ends-with(./@ms, 'Gen')">
		      <xsl:if test="(./@ms = 'Prop_Sg_Gen' and not(. = '')) and 
				    (./preceding-sibling::analysis[./@ms = 'Prop_Pl_Gen' and not(. = '')] or 
				    ./following-sibling::analysis[./@ms = 'Prop_Pl_Gen' and not(. = '')])">
			<xsl:copy-of select="."/>
		      </xsl:if>

		      <xsl:if test="(./@ms = 'Prop_Pl_Gen' and not(. = '')) and 
				    not(./preceding-sibling::analysis[./@ms = 'Prop_Sg_Gen' and not(. = '')] or 
				    ./following-sibling::analysis[./@ms = 'Prop_Sg_Gen' and not(. = '')])">
			<xsl:copy-of select="."/>
		      </xsl:if>
		    </xsl:when>

		    <xsl:when test="ends-with(./@ms, 'Ill')">
		      <xsl:if test="(./@ms = 'Prop_Sg_Ill' and not(. = '')) and 
				    (./preceding-sibling::analysis[./@ms = 'Prop_Pl_Ill' and not(. = '')] or 
				    ./following-sibling::analysis[./@ms = 'Prop_Pl_Ill' and not(. = '')])">
			<xsl:copy-of select="."/>
		      </xsl:if>

		      <xsl:if test="(./@ms = 'Prop_Pl_Ill' and not(. = '')) and 
				    not(./preceding-sibling::analysis[./@ms = 'Prop_Sg_Ill' and not(. = '')] or 
				    ./following-sibling::analysis[./@ms = 'Prop_Sg_Ill' and not(. = '')])">
			<xsl:copy-of select="."/>
		      </xsl:if>
		    </xsl:when>
		  </xsl:choose>
		</xsl:when>

		<xsl:when test="$pos = 'v'">
		  <xsl:choose>
		    <xsl:when test="(ends-with(./@ms, 'Ind_Prs_Sg1') or
				     ends-with(./@ms, 'Ind_Prt_Sg1') or
				     ends-with(./@ms, 'Ind_Prs_Pl3') or
				     ends-with(./@ms, 'Ind_Prt_Sg3') or
				     ends-with(./@ms, 'Ind_Prs_Sg3') or
				     ends-with(./@ms, 'Ind_Prt_Pl3') or
				     ends-with(./@ms, 'Ind_Prs_ConNeg'))
				     and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		  </xsl:choose>
		</xsl:when>
		
		<xsl:when test="$pos = 'num'">
		  <xsl:choose>
		    <xsl:when test="./@ms = 'Pl_Nom' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		    <xsl:when test="./@ms = 'Sg_Ill' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		    <xsl:when test="./@ms = 'Pl_Gen' and not(. = '')">
		      <xsl:copy-of select="."/>
		    </xsl:when>
		  </xsl:choose>
		</xsl:when>

	      </xsl:choose>
	    </xsl:for-each>
	  </mini_paradigm>
	</xsl:variable>
	
	<xsl:variable name="interim">
	  <interim>
	    <xsl:for-each-group select="doc($file)/paradigm/analysis" group-by="./@ms">
	      <anal>
		<xsl:attribute name="poss">
		  <xsl:value-of select="./@ms"/>
		</xsl:attribute>
		<xsl:variable name="wforms" as="node()*">
		  <xsl:for-each select="current-group()">
		    <xsl:copy-of select="wordform"/>
		  </xsl:for-each>
		</xsl:variable>
		<xsl:copy-of select="local:distinct-deep($wforms)"/> 
	      </anal>
	    </xsl:for-each-group>
	  </interim>
	</xsl:variable>

	<xsl:copy-of select="$mini_paradigm"/>
	
	<xsl:for-each-group select="$interim/interim/anal/wordform" group-by=".">
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
	      <xsl:for-each select="current-group()">
		<analysis>
		  <xsl:value-of select="../@poss"/>
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

