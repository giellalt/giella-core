<?xml version="1.0"?>
<!--+
    | 
    | compares (ped vs. smenob) and put ped-flags on smenob-entries 
    | Usage: java net.sf.saxon.Transform -it:main cfSmeSmj.xsl
    +-->

<!-- java net.sf.saxon.Transform -it:main THIS_SHEET.xsl inFile=FILE.xml -->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs local">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  
  <!-- Input files -->
  <xsl:param name="inFile" select="'default.xml'"/>
  <xsl:param name="slang" select="'sme'"/>
  <xsl:param name="tlang" select="'sma'"/>

  <!-- Output files -->
  <xsl:param name="outDir" select="'outDir'"/>
  
  <!-- Patterns for the feature values -->
  <xsl:variable name="output_format" select="'xml'"/>
  <xsl:variable name="e" select="$output_format"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>
  
  
  
  <xsl:template match="/" name="main">
    
    <xsl:choose>
      <xsl:when test="doc-available($inFile)">
	<xsl:variable name="out">
	  <r xml:lang="{$tlang}">
	    <xsl:for-each select="doc($inFile)//e">
	      <e>
		<lg>
		  <l>
		    <xsl:for-each select="./p/r/s">
		      <xsl:if test="position() = 1">
			<xsl:attribute name="pos">
			  <xsl:value-of select="lower-case(./@n)"/>
			</xsl:attribute>
		      </xsl:if>
		      <xsl:if test="position() = 2">
			<xsl:attribute name="type">
			  <xsl:value-of select="lower-case(./@n)"/>
			</xsl:attribute>
		      </xsl:if>
		      <xsl:if test="position() &gt; 2">
			<xsl:attribute name="{concat('att_', position())}">
			  <xsl:value-of select="lower-case(./@n)"/>
			</xsl:attribute>
		      </xsl:if>
		    </xsl:for-each>
		    <xsl:value-of select="./p/r"/>
		  </l>
		</lg>
		
		<mg>
		  <tg>
		    <t xml:lang="{$slang}">
		      <xsl:for-each select="./p/l/s">
			<xsl:if test="position() = 1">
			  <xsl:attribute name="pos">
			    <xsl:value-of select="lower-case(./@n)"/>
			  </xsl:attribute>
			</xsl:if>
			<xsl:if test="position() = 2">
			  <xsl:attribute name="type">
			    <xsl:value-of select="lower-case(./@n)"/>
			  </xsl:attribute>
			</xsl:if>
			<xsl:if test="position() &gt; 2">
			  <xsl:attribute name="{concat('att_', position())}">
			    <xsl:value-of select="lower-case(./@n)"/>
			  </xsl:attribute>
			</xsl:if>
		      </xsl:for-each>
		      <xsl:value-of select="./p/l"/>
		    </t>
		  </tg>
		</mg>
	      </e>
	      
	    </xsl:for-each>
	  </r>
	</xsl:variable>

	<xsl:variable name="pssp">
	  <pos_separated>
	    <xsl:for-each-group select="$out/r/e" group-by="./lg/l/@pos">
	      <pos_group>
		<xsl:copy-of select="current-group()"/>
	      </pos_group>
	    </xsl:for-each-group>
	  </pos_separated>
	</xsl:variable>
	
	<xsl:for-each select="$pssp/pos_separated/pos_group">
	  <xsl:variable name="current_pos" select="./e[1]/lg/l/@pos"/>
	  
	  <xsl:variable name="only_pos">
	    <xsl:if test="not(./e/lg/l/@type)">
	      <r xml:lang="{$tlang}">
		<xsl:copy-of select="./e[not(./lg/l/@type)]"/>
	      </r>
	    </xsl:if>
	  </xsl:variable>
	  
	  <xsl:result-document href="{$outDir}/{$current_pos}_{$tlang}{$slang}.{$e}" format="{$output_format}">
	    <xsl:copy-of select="$only_pos"/>
	  </xsl:result-document>
	  
	  <xsl:if test="./e/lg/l/@type">
	    <xsl:for-each-group select="./e[./lg/l/@type]" group-by="./lg/l/@type">
	      <xsl:result-document href="{$outDir}/{$current_pos}{upper-case(substring(current-grouping-key(),1,1))}{substring(current-grouping-key(),2)}_{$tlang}{$slang}.{$e}" format="{$output_format}">
		<r xml:lang="{$tlang}">
		  <xsl:copy-of select="current-group()"/>
		</r>
	      </xsl:result-document>
	    </xsl:for-each-group>
	  </xsl:if>
	</xsl:for-each>
	
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>Cannot locate: </xsl:text><xsl:value-of select="$inFile"/><xsl:text>&#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>

