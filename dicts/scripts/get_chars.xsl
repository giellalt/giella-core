<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_FILE inputDir=DIR
    | 
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
  <xsl:output method="text" name="txt"
	      encoding="UTF-8"/>

<xsl:function name="functx:chars" as="xs:string*" 
              xmlns:functx="http://www.functx.com" >
  <xsl:param name="arg" as="xs:string?"/> 
 
  <xsl:sequence select=" 
   for $ch in string-to-codepoints($arg)
   return codepoints-to-string($ch)
 "/>
   
</xsl:function>

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
  
  <xsl:param name="inFile" select="'gogo_file'"/>
  <xsl:param name="inDir" select="'../../src'"/>
  <xsl:variable name="outDir" select="'xxx_out_xxx'"/>
  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>
  <xsl:variable name="debug" select="'true_gogo'"/>
  <xsl:variable name="nl" select="'&#xa;'"/>
  <xsl:variable name="lang" select="'sme'"/>
  
  <xsl:template match="/" name="main">

    <xsl:variable name="big_string">
      <xsl:for-each select="for $f in collection(concat($inDir,'?recurse=no;select=*.xml;on-error=warning')) return $f">
	
	<xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	<xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	<xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	
	<xsl:if test="$debug = 'true_gogo'">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
	    <xsl:value-of select="concat('processing file ', $current_file, $nl)"/>
	    <xsl:value-of select="'-----------------------------------------'"/>
	  </xsl:message>
	</xsl:if>
	<!-- glue all lemma strings to a big string -->
	<xsl:for-each select="./r/e/lg/l">
	  <xsl:value-of select="."/>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <!-- split the string into characters separated by whitespace -->
    <xsl:variable name="solo_letter">
      <xsl:value-of select="functx:chars($big_string)"/>
    </xsl:variable>
    <!-- uniq the characters and sort them by default -->
    <xsl:variable name="abc">
      <abc xml:lang="{$lang}">
	<xsl:for-each select="distinct-values(tokenize($solo_letter, ' '))">
	  <xsl:sort select="."/>
	  <xsl:if test="not(normalize-space(.) = '')">
	    <l>
	      <xsl:value-of select="normalize-space(.)"/>
	    </l>
	  </xsl:if>
	</xsl:for-each>
      </abc>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{$lang}_letters.{$e}" format="{$of}">
      <xsl:copy-of select="$abc"/>
    </xsl:result-document>
  </xsl:template>

<!-- no duplicates -->
<!--    <xsl:variable name="unique-list" -->
<!--      select="//state[not(.=following::state)]" />    -->
<!--    <xsl:for-each select="$unique-list"> -->
<!--  <xsl:value-of select="." /> -->
<!--    </xsl:for-each> -->
  
<!--       <xsl:copy-of select="functx:distinct-deep($oll//l)"/> -->

<!-- 	<xsl:value-of select="distinct-values($solo_letter/*)"/> -->

</xsl:stylesheet>
