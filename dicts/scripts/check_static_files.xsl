<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_FILE inputDir=DICT_SOURCE_DIR
    | Ex: in gtsvn/words/dicts
    | java -Xmx2048m net.sf.saxon.Transform -it main scripts/check_dict_entry.xsl inDir=../smenob/src
    | 
    | The doublings (twins) are collected based on the <l> element: if two entries N and M have exactly the same <l> element 
    | (i.e., all attributes and lemma string) then N and M are twins.
    | Hint: to disabiguate two apparent twins put an extra attribute to one of them (or the same attr with two different values)
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:functx="http://www.functx.com"
		exclude-result-prefixes="xs xhtml functx">

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

  <xsl:param name="inFile" select="'gogo_file'"/>
  <xsl:param name="inDir" select="'../smenob/xtatx'"/>
  <xsl:variable name="outDir" select="'.'"/>
  <xsl:variable name="outFile" select="'test-results'"/>
  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>
  <xsl:variable name="debug" select="'true()'"/>
  <xsl:variable name="nl" select="'&#xa;'"/>

  <xsl:template match="/" name="main">

    <xsl:variable name="output">
      <xsl:for-each select="for $f in collection(concat($inDir,'?recurse=no;select=*.xml;on-error=warning')) return $f">
	
	<xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	<xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	<xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	
	<xsl:if test="$debug">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
	    <xsl:value-of select="concat('processing file ', $current_file, $nl)"/>
	    <xsl:value-of select="'-----------------------------------------'"/>
	  </xsl:message>
	</xsl:if>
	
	<file name="{$current_file}" ls="{count(.//e[.//mini_paradigm])}" ws="{count(.//e[not(.//mini_paradigm)])}">
	  <ls>
	    <xsl:for-each select="./r/e[.//mini_paradigm]">

	      <xsl:variable name="dictID">
		<xsl:call-template name="getID">
		  <xsl:with-param name="theLG" select="./lg"/>
		</xsl:call-template>
	      </xsl:variable>

	      <xsl:if test="$debug">
		<xsl:message terminate="no">
		  <xsl:value-of select="concat('dictID ', $dictID, $nl)"/>
		  <xsl:value-of select="'.............................................................................'"/>
		</xsl:message>
	      </xsl:if>
	      <l str="{./lg/l}" id="{$dictID}" out="{count(.//mini_paradigm//wordform)}" in="{count(..//lemma_ref[./@lemmaID = $dictID])}"/>
	    </xsl:for-each>
	  </ls>
	  <ws>
	    <xsl:for-each select="./r/e[not(.//mini_paradigm)]">
	      <w str="{./lg/l}" l_ref="{count(.//lemma_ref)}">
		<xsl:copy-of copy-namespaces="no" select=".//lemma_ref"/>
	      </w>
	    </xsl:for-each>
	  </ws>
	</file>
	
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{$outFile}.{$e}" format="{$of}">
      <test>
	<xsl:copy-of select="$output"/>
      </test>
    </xsl:result-document>
    
  </xsl:template>

  <xsl:template name="getID">
    <xsl:param name="theLG"/>
    <xsl:variable name="attr_values">
      <xsl:for-each select="$theLG/l/@*">
	<xsl:text>_</xsl:text>
	<xsl:value-of select="normalize-space(.)" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="concat(lg/l, $attr_values)"/>
  </xsl:template>
  
</xsl:stylesheet>
