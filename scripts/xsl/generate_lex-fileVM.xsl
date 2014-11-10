<?xml version="1.0"?>
<!--+
    | Generate LexC files from XML
    | NB: An XSLT-2.0-processor is needed!
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main XSLT_SCRIPT inFile="FILE"
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="xs">
    
  <xsl:strip-space elements="*"/>
  <xsl:output method="text"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:variable name="tab" select="'&#x9;'"/>
  <xsl:variable name="spc" select="'&#x20;'"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="cl" select="':'"/>
  <xsl:variable name="scl" select="';'"/>
  <xsl:variable name="us" select="'_'"/>
  <xsl:variable name="qm" select="'&#34;'"/>

  <!-- parameters -->
  <xsl:param name="inFile" select="'default.xml'"/>
  <xsl:param name="outDir" select="'out'"/>
  <xsl:variable name="of" select="'txt'"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="FstEntries" select="count(document($inFile)/r/e[not(@exclude='fst')])"/>
  
  <xsl:template match="/" name="main">
    
    <xsl:choose>
      <xsl:when test="doc-available($inFile)">
	<xsl:variable name="file_name" select="substring-before(tokenize($inFile, '/')[last()], '.xml')"/>
	
	<xsl:if test="$debug">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
	    <xsl:value-of select="concat('processing ', $file_name, $nl)"/>
	    <xsl:value-of select="'   ...........'"/>
	  </xsl:message>
	</xsl:if>
	
	<xsl:choose>
	  <xsl:when test="$FstEntries &gt; 0">
	    
	    <xsl:variable name="lex_name" select="substring-before($file_name, '_')"/>
	    <!-- 2012-08-31 replacing _$lex_name_ with _$file_name_, it seems to work. Jack
		 <xsl:value-of select="concat('LEXICON', $spc, $lex_name, $nl, $nl)"/> -->
	    <xsl:value-of select="concat($nl, 'LEXICON', $spc, $file_name, $nl, $nl)"/>

	    <!-- this might have to be refined: too underspecified as for preceding::lemma-stem combinations -->
	    <!-- xsl:for-each select="./dict/entry[not(contains(./lemma/text(), $us))] the underscore should be replaced by "% "-->
	    <!--xsl:for-each select="document($inFile)/dict/entry[not(./lemma = preceding::entry/lemma and ./stem = preceding::entry/stem)][not(./@exclude='fst')]"-->
	    <xsl:for-each select="document($inFile)/r/e[not(./@exclude='fst')]/lg/stg/st">
	      
	      <xsl:variable name="out">
		<out>
		  <e>
		    <xsl:copy-of select="../../l/@hid"/>
		    <xsl:copy-of select="./@status"/>
		    <xsl:attribute name="stem">
		      <xsl:value-of select="replace(
		                            replace(
		                            replace(normalize-space(.), ' ', '% '),
		                            ':','%:'),
		                            '!','%!')  "/>
		    </xsl:attribute>
		    <xsl:attribute name="pos">
		      <xsl:value-of select="normalize-space(../../l/@pos)"/>
		    </xsl:attribute>
		<xsl:attribute name="cl">
		  <xsl:value-of select="normalize-space(@Contlex)"/>
		</xsl:attribute>
		<xsl:attribute name="t">
		  <!-- This has been replaced with "fin" so progress can be observed  <xsl:value-of select="normalize-space(../../../mg[1]/tg[@xml:lang='eng']/t[1])"/>  -->
		  <!-- This chooser was introduced 2013-05-22 to make sure there was text content in between the quote pair.  -->
		  <xsl:choose>
		    <xsl:when test="../../../mg[1]/tg[@xml:lang='fin']/t[1]">
		      <xsl:value-of select="normalize-space(../../../mg[1]/tg[@xml:lang='fin']/t[1])"/>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:choose>
			<xsl:when test="../../../mg[1]/tg[@xml:lang='fin']/tCtn[1]/t[1]">
			  <xsl:value-of select="normalize-space(../../../mg[1]/tg[@xml:lang='fin']/tCtn[1]/t[1])"/>
			</xsl:when>
			<xsl:otherwise>
			  <xsl:choose>
			    <xsl:when test="../../../mg[1]/tg[@xml:lang='fin']/tf[1]">
			      <xsl:value-of select="normalize-space(../../../mg[1]/tg[@xml:lang='fin']/tf[1])"/>
			    </xsl:when>
			    <xsl:otherwise>
			      <xsl:value-of select="normalize-space(../../../mg[1]/tg[@xml:lang='fin']/td[1])"/>
			    </xsl:otherwise>
			  </xsl:choose>
			</xsl:otherwise>
		      </xsl:choose>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:attribute>
		<!-- xsl:value-of select="normalize-space(../../l)"/ replace underscore by "% "-->
		<xsl:value-of select="replace(
		                      replace(
		                      replace(normalize-space(../../l), ' ', '% '),
		                      ':','%:'),
		                      '!','%!')  "/>		
		  </e>
		</out>
	      </xsl:variable>
	      
	      
	      <xsl:if test="$out/out/e">
		<xsl:for-each select="$out/out/e">
		  <xsl:variable name="current_hid" select="if (./@hid
							   and
							   not(normalize-space(./@hid)=''))
							   then
							   concat('+',./@hid)
							   else concat('','')"/>
		  <xsl:variable name="current_status" select="if (./@status
							   and
							   not(normalize-space(./@status)=''))
							   then
							   concat('+',./@status)
							   else concat('','')"/>
		  <xsl:value-of select="if (./@stem = '') then concat(., $spc, ./@cl, $spc, $spc, $qm, ./@t, $qm, $spc, $scl, $nl)
					else concat(.,$current_hid,$current_status, $cl, ./@stem, $spc, ./@cl, $spc, $spc, $qm, ./@t, $qm, $spc, $scl, $nl)"/>
		</xsl:for-each>
	      </xsl:if>
	    </xsl:for-each>
	    
	  </xsl:when>
	  <xsl:otherwise>
	    <!--xsl:value-of select="concat('File does not contain any usable entries: ', $inFile, $nl)"/>
		<xsl:value-of select="concat('Number of usable entries: ', $FstEntries, $nl)"/-->
	  </xsl:otherwise>
	</xsl:choose>
	
	
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat('Cannot locate file ', $inFile, $nl)"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  
  
  <xsl:variable name="header">
    <xsl:text>
! ========================================================================== !
!                     A lexicon                           
! ========================================================================== !
!
! Automatically generated from XML
! DO NOT EDIT! 
    </xsl:text>
  </xsl:variable>
  
</xsl:stylesheet>
