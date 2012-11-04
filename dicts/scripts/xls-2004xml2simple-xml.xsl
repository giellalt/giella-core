<?xml version="1.0"?>
<!--+
    | 
    | change the 2004-xml-spreadsheet XML files into a simpler xml format
    | Usage: java net.sf.saxon.Transform -it:main STYLESHEET_NAME.xsl (inFile=INPUT_FILE_NAME.xml | inDir=INPUT_DIR)
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:local="nightbar"
		xmlns:fmp="http://www.filemaker.com/fmpxmlresult"
		xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
		exclude-result-prefixes="xs local fmp ss">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>
  
  <!-- Input -->
  <xsl:param name="inFile" select="'xxxfilexxx'"/>
  <xsl:param name="inDir" select="'xxxdirxxx'"/>
  
  <!-- Output -->
  <xsl:param name="outputDir" select="'000_outDir'"/>
  
  <!-- Patterns for the feature values -->
  <xsl:variable name="output_format" select="'xml'"/>
  <xsl:variable name="e" select="$output_format"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>
  <xsl:variable name="nl" select="'&#xA;'"/>
  <xsl:variable name="debug" select="true()"/>
  
  
  
  <xsl:template match="/" name="main">
    
    <xsl:if test="doc-available($inFile)">

      <xsl:message terminate="no">
	<xsl:value-of select="concat('Processing file: ', $inFile)"/>
      </xsl:message>
      
      <xsl:call-template name="processFile">
	<xsl:with-param name="theFile" select="document($inFile)"/>
	<xsl:with-param name="theName" select="$file_name"/>
      </xsl:call-template>
    </xsl:if>

    <!-- xsl:if test="doc-available($inDir)" -->
    <xsl:if test="not($inDir = 'xxxdirxxx')">
      <xsl:for-each select="for $f in collection(concat($inDir, '?select=*.xml')) return $f">
	
	<xsl:variable name="current_file" select="substring-before((tokenize(document-uri(.), '/'))[last()], '.xml')"/>
	<xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	<xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	
	<xsl:message terminate="no">
	  <xsl:value-of select="concat('Processing file: ', $current_file)"/>
	</xsl:message>

	<xsl:call-template name="processFile">
	  <xsl:with-param name="theFile" select="."/>
	  <xsl:with-param name="theName" select="$current_file"/>
	</xsl:call-template>
      </xsl:for-each>
    </xsl:if>
    
	
    
    <xsl:if test="not(doc-available($inFile) or not($inDir = 'xxxdirxxx'))">
      <xsl:value-of select="concat('Neither ', $inFile, ' nor ', $inDir, ' found.', $nl)"/>
    </xsl:if>
    
  </xsl:template>

  <xsl:template name="processFile">
    <xsl:param name="theFile"/>
    <xsl:param name="theName"/>

    <xsl:variable name="output">
      <xsl:for-each select="$theFile/*:Workbook/*:Worksheet/*:Table/*:Row">
	<xsl:call-template name="processRow">
	  <xsl:with-param name="theRow" select="."/>
	  <xsl:with-param name="thePosition" select="position()"/>
	</xsl:call-template>
      </xsl:for-each>
    </xsl:variable>

    <!-- output document -->
    <xsl:result-document href="{$outputDir}/result_{$theName}.{$e}" format="{$output_format}">
      <output>
	<xsl:copy-of select="$output"/>
      </output>
    </xsl:result-document>

  </xsl:template>
  
  <xsl:template name="processRow">
    <xsl:param name="theRow"/>
    <xsl:param name="thePosition"/>
    
    <xsl:message terminate="no">
      <xsl:value-of select="concat('Row position ', $thePosition)"/>
    </xsl:message>
    
    <xsl:variable name="elName" select="if (position() = 1) then 'label' else 'row'"/>
    <xsl:variable name="isNonemptyRow" select="some $cell in $theRow satisfies not(normalize-space($cell) = '')"/>
    
    <xsl:if test="$isNonemptyRow">
      
      <xsl:element name="{$elName}">
	<xsl:attribute name="cell_count">
	  <xsl:value-of select="count($theRow//*:Cell[not(normalize-space(.) = '')])"/>
	</xsl:attribute>

	<!-- as default, don't filter empty cells (semantics = column position) -->	
	<!-- xsl:for-each select="$theRow//*:Cell[not(normalize-space(.) = '')]" -->
	<xsl:for-each select="$theRow//*:Cell">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('Processing column: ', .)"/>
	  </xsl:message>
	  
	  <xsl:element name="col">
	    <xsl:attribute name="id">
	      <xsl:value-of select="position()"/>
	    </xsl:attribute>
	    <!-- as default, don't filter empty cells (semantics = column position) -->	
	    <!-- xsl:value-of select="./*:Data//text()"/ -->
	    <xsl:value-of select="./*:Data"/>
	  </xsl:element>
	</xsl:for-each>
	
	<!-- xsl:variable name="current_data">
	     <xsl:for-each select="./*:Data//text()">
	     <xsl:value-of select="normalize-space(concat(., ''))"/>
	     </xsl:for-each>
	     </xsl:variable>
	     
	     <xsl:if test="not($current_data = '')">
	     <xsl:element name="col">
	     <xsl:attribute name="id">
	     <xsl:value-of select="position()"/>
	     </xsl:attribute>
	     <xsl:value-of select="./*:Data//text()"/>
	     </xsl:element>
	     </xsl:if>
	     </xsl:for-each -->
	
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>

