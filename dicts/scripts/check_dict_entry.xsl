<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main THIS_FILE inputDir=DIR
    | 
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
  <xsl:param name="inDir" select="'ind'"/>
  <xsl:variable name="outDir" select="'.'"/>
  <xsl:variable name="outFile" select="'test-results'"/>
  <xsl:variable name="of" select="'xml'"/>
  <xsl:variable name="e" select="$of"/>
  <xsl:variable name="debug" select="'true_gogo'"/>
  <xsl:variable name="nl" select="'&#xa;'"/>

  <xsl:template match="/" name="main">

    <xsl:variable name="output">
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
	
	<file name="{$current_file}">
	  <entries>
	    <counter total="{count(.//e)}"/>

	    <xsl:variable name="twins">
	      <twins>
		<xsl:for-each select=".//e">
		  <xsl:variable name="current_lemma" select="normalize-space(./lg/l/text())"/>
		  <xsl:variable name="lemma_freq" select="count(../e[$current_lemma = normalize-space(./lg/l/text())])"/>
		  <xsl:variable name="follow_lemma" select="count(following-sibling::e[normalize-space(./lg/l/text()) = $current_lemma])"/>

		  <xsl:if test="functx:is-node-in-sequence-deep-equal(./lg/l, following-sibling::e[normalize-space(./lg/l/text()) = $current_lemma]/lg/l)">
		    <lemma>
		      <xsl:value-of select="./lg/l"/>
		    </lemma>
		  </xsl:if>
		</xsl:for-each>
		
		<!-- 	      <xsl:for-each select=".//e"> -->
		
		<!-- 		<xsl:if test="$debug = 'true_gogo'"> -->
		<!-- 		  <xsl:message terminate="no"> -->
		<!-- 		    <xsl:value-of select="concat('processing entry ', ./lg/l/text(), $nl)"/> -->
		<!-- 		    <xsl:value-of select="'.............................................................'"/> -->
		<!-- 		  </xsl:message> -->
		<!-- 		</xsl:if> -->
		
		<!-- 		<xsl:variable name="current_lemma" select="normalize-space(./lg/l/text())"/> -->
		<!-- 		<xsl:variable name="lemma_freq" select="count(../e[$current_lemma = normalize-space(./lg/l/text())])"/> -->
		<!-- 		<xsl:variable name="follow_lemma" select="count(following-sibling::e[normalize-space(./lg/l/text()) = $current_lemma])"/> -->
		
		<!-- 		<xsl:if test="($lemma_freq &gt; 1) and ($follow_lemma = 0)"> -->
		<!-- 		  <lemma counter="{$lemma_freq}"> -->
		<!-- 		    <xsl:value-of select="./lg/l"/> -->
		<!-- 		  </lemma> -->
		<!-- 		</xsl:if> -->
		<!-- 	      </xsl:for-each> -->
		
	      </twins>
	    </xsl:variable>
	    <xsl:if test="not(count($twins//lemma) = 0)">
	      <xsl:copy-of select="$twins"/>
	    </xsl:if>
	  </entries>
	</file>
	
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:result-document href="{$outDir}/{$outFile}.{$e}" format="{$of}">
      <test>
	<xsl:copy-of select="$output"/>
      </test>
    </xsl:result-document>
    
    
  </xsl:template>
  
</xsl:stylesheet>
