<?xml version="1.0"?>
<!--+
    | 
    | merges the doubled entries as a result of the source_lang-files inversion process 
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_SCRIPT inFile=INPUT_FILE.xml
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:functx="http://www.functx.com"
		exclude-result-prefixes="xs functx">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:function name="functx:is-node-in-sequence-deep-equal" as="xs:boolean" 
		xmlns:functx="http://www.functx.com" >
    <xsl:param name="node" as="node()?"/> 
    <xsl:param name="seq" as="node()*"/> 
    
    <xsl:sequence select=" 
			  some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
			  "/>
    
  </xsl:function>
  
  <xsl:function name="functx:distinct-deep" as="node()*" 
		xmlns:functx="http://www.functx.com" >
    <xsl:param name="nodes" as="node()*"/> 
    
    <xsl:sequence select=" 
			  for $seq in (1 to count($nodes))
			  return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
			  .,$nodes[position() &lt; $seq]))]
			  "/>
  </xsl:function>
  
  <!-- Input files -->
  <xsl:param name="inFile" select="'default.xml'"/>
  
  <!-- Output dir, files -->
  <xsl:variable name="outputDir" select="'uniq_ePosMerged'"/>
  
  <!-- Patterns for the feature values -->
  <xsl:variable name="output_format" select="'xml'"/>
  <xsl:variable name="e" select="$output_format"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>
  
  <xsl:template match="/" name="main">
    <xsl:choose>
      <xsl:when test="doc-available($inFile)">
	<xsl:variable name="out_tmp">
	  <r>
	    <xsl:copy-of select="doc($inFile)/r/@*"/>
	    <xsl:for-each-group select="doc($inFile)/r/e" group-by="./lg/l">
	      <xsl:if test="count(current-group()) = 1">
		<xsl:copy-of select="current-group()"/>
	      </xsl:if>
	      <xsl:if test="not(count(current-group()) = 1)">
		<xsl:for-each-group select="current-group()" group-by="./lg/l/@pos">
		  <xsl:if test="count(current-group()) = 1">
		    <xsl:copy-of select="current-group()"/>
		  </xsl:if>
		  
		  <xsl:if test="not(count(current-group()) = 1)">
		    <e>
		      <!-- 		      <xsl:attribute name="counter"> -->
		      <!-- 			<xsl:value-of select="count(current-group())"/> -->
		      <!-- 		      </xsl:attribute> -->
		      
		      <xsl:copy-of select="current-group()[1]/@*"/>
		      <xsl:copy-of select="current-group()[1]/lg"/>
		      <xsl:if test="./apps">
			<apps>
			  <xsl:copy-of select="current-group()//app"/>
			</apps>
		      </xsl:if>
		      
		      <xsl:copy-of select="functx:distinct-deep(current-group()//mg)"/>
		      
		      <!-- 		  <semantics> -->
		      <!-- 		    <xsl:for-each select="distinct-values(current-group()//semantics/sem/@*)"> -->
		      <!-- 		      <sem> -->
		      <!-- 			<xsl:attribute name="class"> -->
		      <!-- 			  <xsl:value-of select="."/> -->
		      <!-- 			</xsl:attribute> -->
		      <!-- 		      </sem> -->
		      <!-- 		    </xsl:for-each> -->
		      <!-- 		  </semantics> -->
		      <!-- 		  <sources> -->
		      <!-- 		    <xsl:for-each select="distinct-values(current-group()//sources/book/@*)"> -->
		      <!-- 		      <book> -->
		      <!-- 			<xsl:attribute name="name"> -->
		      <!-- 			  <xsl:value-of select="."/> -->
		      <!-- 			</xsl:attribute> -->
		      <!-- 		      </book> -->
		      <!-- 		    </xsl:for-each> -->
		      <!-- 		  </sources> -->
		      <!-- 		  <ctrl_entry> -->
		      <!-- 		    <xsl:copy-of select="current-group()"/> -->
		      <!-- 		  </ctrl_entry> -->
		      
		    </e>
		  </xsl:if>
		</xsl:for-each-group>
		
	      </xsl:if>
	      </xsl:for-each-group>
	  </r>
	</xsl:variable>
	
	<!-- out -->
	<xsl:result-document href="{$outputDir}/{$file_name}.{$e}" format="{$output_format}">
	  <xsl:copy-of select="$out_tmp"/>
	</xsl:result-document>

      </xsl:when>
      <xsl:otherwise>
	<xsl:text>Cannot locate: </xsl:text><xsl:value-of select="$inFile"/><xsl:text>&#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>


