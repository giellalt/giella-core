<?xml version="1.0"?>
<!--+
    | Usage: java net.sf.saxon.Transform -it:main THIS_FILE PARAM_NAME=PARAM_VALUE*
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs local">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      omit-xml-declaration="no"
	      indent="yes"/>

  <xsl:function name="local:substring-before-if-contains" as="xs:string?">
    <xsl:param name="arg" as="xs:string?"/> 
    <xsl:param name="delim" as="xs:string"/> 
    
    <xsl:sequence select=" 
			  if (contains($arg,$delim))
			  then substring-before($arg,$delim)
			  else $arg
			  "/>
  </xsl:function>
  
  <xsl:function name="local:value-intersect" as="xs:anyAtomicType*">
    <xsl:param name="arg1" as="xs:anyAtomicType*"/> 
    <xsl:param name="arg2" as="xs:anyAtomicType*"/> 
    
    <xsl:sequence select=" 
			  distinct-values($arg1[.=$arg2])
			  "/>
  </xsl:function>

  <xsl:function name="local:value-except" as="xs:anyAtomicType*">
    <xsl:param name="arg1" as="xs:anyAtomicType*"/> 
    <xsl:param name="arg2" as="xs:anyAtomicType*"/> 
    
    <xsl:sequence select=" 
			  distinct-values($arg1[not(.=$arg2)])
			  "/>
  </xsl:function>
  
  <xsl:variable name="e" select="'xml'"/>
  <xsl:variable name="outputDir" select="'CompResults'"/>
  <xsl:variable name="outFile" select="'smanob_spelling'"/>
  
  <!-- get input files -->
  <!-- These paths have to be adjusted accordingly -->
  <xsl:param name="file" select="'gogo'"/>
  
  <xsl:template match="/" name="main">
    
    <xsl:choose>
      <xsl:when test="doc-available($file)">

	<xsl:variable name="file_out" as="element()">
	  <r>
	    <xsl:for-each select="doc($file)/r/e">
	      <e>
		<xsl:copy-of select="./@*"/>
		<lg>
		  <xsl:copy-of select="./lg/l"/>
		  <xsl:copy-of select="./lg/lemma_ref"/>
		  <xsl:copy-of select="./lg/analysis"/>
		  
		  <xsl:variable name="theCC">
		    <cc/>
		  </xsl:variable>

		  <xsl:variable name="inVariants">
		    <variants>
		      <v>
			<xsl:value-of select="./lg/l"/>
		      </v>
		      <xsl:for-each select="./lg/spelling/var">
			<v>
			  <xsl:value-of select="."/>
			</v>
		      </xsl:for-each>
		    </variants>
		  </xsl:variable>
		  
		  <xsl:variable name="iParts">
		    <spellings>
		      <xsl:for-each select="$inVariants/variants/v">
			<xsl:call-template name="doIt">
			  <xsl:with-param name="theStr" select="normalize-space(.)"/>
			  <xsl:with-param name="theChar" select="'ï'"/>
			  <xsl:with-param name="theCombis" select="$theCC"/>
			</xsl:call-template>
		      </xsl:for-each>
		    </spellings>
		  </xsl:variable>
		  
		  <xsl:if test="not($iParts = '')">
		    <spellings>      
		      <xsl:call-template name="combineIt">
			<xsl:with-param name="theInput" select="$iParts"/>
		      </xsl:call-template>
		    </spellings>
		  </xsl:if>

		  <xsl:copy-of select="./lg/mini_paradigm"/>

		</lg>
		
		<xsl:copy-of select="./mg"/>
		
	      </e>
	    </xsl:for-each>
	  </r>
	</xsl:variable>

	<xsl:result-document href="{$outputDir}/{$outFile}.{$e}">
	  <xsl:copy-of select="$file_out"/>
	</xsl:result-document>
	
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>Cannot locate: </xsl:text><xsl:value-of select="$file"/><xsl:text>&#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="doIt">
    <xsl:param name="theStr"/>
    <xsl:param name="theChar"/>
    <xsl:param name="theCombis"/>

    <xsl:if test="contains(normalize-space($theStr), 'ï')">
      <xsl:variable name="combis">
	<xsl:if test="not($theCombis/cc/c)">
	  <cc>
	    <c>
	      <xsl:value-of select="concat(substring-before($theStr, $theChar), $theChar)"/>
	    </c>
	    <c>
	      <xsl:value-of select="concat(substring-before($theStr, $theChar), 'i')"/>
	    </c>
	  </cc>
	</xsl:if>
	<xsl:if test="$theCombis/cc/c">
	  <cc>
	    <xsl:for-each select="$theCombis/cc/c">
	      <c>
		<xsl:value-of select="concat(., substring-before($theStr, $theChar), $theChar)"/>
	      </c>
	      <c>
		<xsl:value-of select="concat(., substring-before($theStr, $theChar), 'i')"/>
	      </c>
	    </xsl:for-each>
	  </cc>
	</xsl:if>
      </xsl:variable>
      
      <xsl:call-template name="doIt">
	<xsl:with-param name="theStr" select="substring-after($theStr, $theChar)"/>
	<xsl:with-param name="theChar" select="$theChar"/>
	<xsl:with-param name="theCombis" select="$combis"/>
      </xsl:call-template>

    </xsl:if>
    <xsl:if test="not(contains(normalize-space($theStr), 'ï'))">
      <xsl:if test="not($theCombis/cc/c)">
	<spv>  
	  <xsl:value-of select="$theStr"/>
	</spv>
      </xsl:if>
      <xsl:if test="$theCombis/cc/c">
	<xsl:for-each select="$theCombis/cc/c">
	  <spv>  
	    <xsl:value-of select="concat(., $theStr)"/>
	  </spv>
	</xsl:for-each>
      </xsl:if>
    </xsl:if>

  </xsl:template>
  
  
  
  <xsl:template name="combineIt">
    <xsl:param name="theInput"/>
    
    <xsl:variable name="allSpellings">
      <all>
	<xsl:copy-of select="$theInput/spellings/spv"/>
	<xsl:for-each select="$theInput/spellings/spv">
	  <spv>
	    <xsl:value-of select="translate(., 'æÆ', 'äÄ')"/>
	  </spv>
	</xsl:for-each>
	<xsl:for-each select="$theInput/spellings/spv">
	  <spv>
	    <xsl:value-of select="translate(., 'öÖ', 'øØ')"/>
	  </spv>
	</xsl:for-each>
	<xsl:for-each select="$theInput/spellings/spv">
	  <spv>
	    <xsl:value-of select="translate(., 'æÆöÖ', 'äÄøØ')"/>
	  </spv>
	</xsl:for-each>
      </all>
    </xsl:variable>
    
    <xsl:variable name="uniques" select="distinct-values($allSpellings/all/spv)"/>

    <!--     <out_spell> -->
    <!--       <xsl:copy-of select="$uniques"/> -->
    <!--     </out_spell> -->
    
    <xsl:for-each select="$uniques">
      <spv>
	<xsl:copy-of select="."/>
      </spv>
    </xsl:for-each>

  </xsl:template>
  
</xsl:stylesheet>
