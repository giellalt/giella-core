<?xml version="1.0"?>
<!--+
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main THIS_FILE PARAMETER_LIST
    | e.g.
    | java -Xmx2048m net.sf.saxon.Transform -it:main _six scripts/extract_l-t-lexc.xsl SLANG=sme TLANG=smj TNUM=first
    |
    | - parameter to adjust:
    |   - input dir: inDir; default is ../SLANGTLANG/src (e.g., ../smenob/src)
    |   - output dir: outDir; default is SLANGTLANG/bin (e.g., ../smenob/bin)
    |
    |  CAVEAT: inDir and outDir should be given as relative to where
    |                 this script is called from; the defaults are relative to 
    |                   (a) the script being main/words/dicts/scripts
    |                        and
    |                   (b) the calling place being main/words/dicts
    |
    |   - inFile: which files to select; default is *.xml (all xml files from src)
    |   - source lang: SLANG
    |   - target lang: TLANG
    |   - number of traslation to pair: first (take only the first t)
    |      all (take all t-element values)
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="xs xhtml">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="dis"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:output method="xml" name="lexc"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="no"/>

  <xsl:output method="xml" name="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="yes"
	      indent="yes"/>

  <xsl:output method="text" name="txt"
              encoding="UTF-8"/>

  <xsl:param name="inDir" select="concat('../../../','dict-',$SLANG,'-',$TLANG,'/src')"/>

  <xsl:param name="inFile" select="concat('*_',$SLANG,$TLANG,'.xml')"/>
  <xsl:param name="outDir" select="concat('../../','dict-',$SLANG,'-',$TLANG,'/bin')"/>
  <xsl:param name="outFile" select="concat($SLANG,$TLANG,'-',$TNUM)"/>
  <xsl:param name="SLANG" select="'ggg'"/>
  <xsl:param name="TLANG" select="'ooo'"/>
  <xsl:param name="TNUM" select="'xxx'"/>
  <xsl:variable name="debug" select="false()"/>
  <xsl:variable name="nl" select="'&#xa;'"/>
  <xsl:variable name="tb" select="'&#9;'"/>
  <xsl:variable name="sr" select="'\*'"/>
  
  <xsl:template match="/" name="main">
    
    <xsl:variable name="fcounter" select="count(for $f in collection(concat($inDir,'?recurse=yes;select=',$inFile,';on-error=warning')) return $f)"/>

    <xsl:if test="true()">
      <xsl:message terminate="no">
	<xsl:value-of select="concat('Number of files to process ', $fcounter, $nl)"/>
      </xsl:message>
    </xsl:if>

    <xsl:result-document href="{$outDir}/{$outFile}.lexc" format="lexc">
      <xsl:value-of select="concat('LEXICON Root ',$nl)"/>

      <xsl:for-each select="for $f in collection(concat($inDir,'?recurse=yes;select=',$inFile,';on-error=warning')) return $f">
	
	<xsl:variable name="current_file" select="(tokenize(document-uri(.), '/'))[last()]"/>
	<xsl:variable name="current_dir" select="substring-before(document-uri(.), $current_file)"/>
	<xsl:variable name="current_location" select="concat($inDir, substring-after($current_dir, $inDir))"/>
	<xsl:variable name="relative_path" select="substring-after($current_dir, $inDir)"/>
	<xsl:variable name="file_name" select="substring-before($current_file, '.xml')"/>      
	
	<xsl:if test="true()">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
	    <xsl:value-of select="concat('location ', $current_location, $nl)"/>
	    <xsl:value-of select="concat('processing file ', $current_file, $nl)"/>
	    <xsl:value-of select="'-----------------------------------------'"/>
	  </xsl:message>
	</xsl:if>

	<xsl:variable name="tcounter" select="count(.//tg[./@xml:lang=$TLANG]/t)"/>

	<xsl:if test="$tcounter=0">
	  <xsl:message terminate="yes">
	    <xsl:value-of select="concat('No t-element found. Please check the xml:lang attribute on tg-elements!', $nl)"/>
	  </xsl:message>
	</xsl:if>

	
	<xsl:for-each select=".//e">
	  <!--xsl:variable name="cl" select="normalize-space(./lg/l)"/-->
	  <!-- if needed due to mwe in the l-value whitespaces can be
	       replaced by underscore such in t-value -->
	  <xsl:variable name="cl" select="translate(normalize-space(./lg/l), ' ','_')"/>

	  <xsl:if test="$TNUM='first'">
	    <xsl:value-of
		select="concat($cl,':',translate(normalize-space(./mg[1]/tg[1][./@xml:lang=$TLANG]/t[1]),
			' ','_') , ' # ;',$nl)"/>
	  </xsl:if>
	  <xsl:if test="$TNUM='all'">
	    <xsl:for-each select=".//tg[./@xml:lang=$TLANG]/t">
	      <xsl:value-of
		  select="concat($cl,':',translate(normalize-space(.),
			  ' ', '_') , ' # ;',$nl)"/>
	    </xsl:for-each>
	  </xsl:if>
	</xsl:for-each>
	
      </xsl:for-each>
    </xsl:result-document>
    
    <xsl:if test="true()">
      <xsl:message terminate="no">
	<xsl:value-of select="'Done!'"/>
      </xsl:message>
    </xsl:if>

  </xsl:template>
  
</xsl:stylesheet>
