<?xml version="1.0"?>
<!--+
    | 
    | java net.sf.saxon.Transform -it:main THIS_SHEET.xsl inFile=FILE.xml outDir=OUT_DIR
    | You can change the parameter values in  this file so that you don't need any inFile/outDir specification in the command line but just
    | java net.sf.saxon.Transform -it:main THIS_SHEET.xsl
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:local="nightbar"
		xmlns:myFn="http://whatever"
		exclude-result-prefixes="xs local myFn">

 <xsl:import href="mapPOS.xsl"/>

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" name="xml"
              encoding="UTF-8"
	      omit-xml-declaration="no"
	      indent="yes"/>

  
  <!-- Input file: customize as you need it -->
  <!-- path to the correct input type: gtdict format, and
   NOT tull/out_simple-apertium/tull.xml --> 
  <xsl:param name="inFile" select="'tull/tull.xml'"/>

  <!-- Output dir: customize as you need it -->
  <xsl:param name="outDir" select="'smsRev'"/>
  
  <!-- Patterns for the feature values -->
  <xsl:variable name="output_format" select="'xml'"/>
  <xsl:variable name="e" select="$output_format"/>
  <!-- This means that input file name is the same as output file name: change as you need it -->
  <xsl:variable name="file_name" select="substring-before((tokenize($inFile, '/'))[last()], '.xml')"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="nl" select="'&#xa;'"/>
  
  <xsl:template match="/" name="main">
    
    <xsl:choose>
      <xsl:when test="doc-available($inFile)">
	<xsl:variable name="out">
	  <dictionary>
	    <alphabet/>
	    <sdefs>
	      <sdef n="a."/>
	      <sdef n="abr."/>
	      <sdef n="adv."/>
	      <sdef n="conj."/>
	      <sdef n="interj."/>
	      <sdef n="n."/>
	      <sdef n="npl."/>
<!--	      <sdef n="n. pl."/> -->
	      <sdef n="num."/>
	      <sdef n="pcle."/>
	      <sdef n="postpos."/>
	      <sdef n="prepos."/>
	      <sdef n="pron."/>
	      <sdef n="proper n."/>
	      <sdef n="subjunc."/>
	      <sdef n="v."/>
	    </sdefs>
	    
	    <section id="main" type="standard">
	      <!-- constraint for smanob: this should be handled in the previous step! -->
	      <xsl:for-each select="doc($inFile)/r/e[not(./lg/l/@pos = 'prop')][not(./lg/l/@pos = 'propPl')]">
		
		<xsl:if test="$debug">
		  <xsl:message terminate="no">
		    <xsl:value-of select="concat('-----------------------------------------', $nl)"/>
		    <xsl:value-of select="concat('entry: ', ./lg/l, ' ___ pos: ', ./lg/l/@pos, $nl)"/>
		    <xsl:value-of select="'-----------------------------------------'"/>
		  </xsl:message>
		</xsl:if>
		

		<e>
		  <p>
		    <l>
		      <xsl:value-of select="./lg/l"/>
		      <s n="{myFn:mapPOS(./lg/l/@pos)}"/>
		    </l>
		    <r>
		      <xsl:variable name="mg_c" select="count(mg)"/>
		      <xsl:for-each select="./mg">
			<xsl:if test="$mg_c &gt; 1">
			  <xsl:value-of select="concat(position(), '. ')"/>
			</xsl:if>
			<xsl:for-each select="./tg">
			  <xsl:if test="./re">
			    <xsl:value-of select="concat('(', ./re, ') ')"/>
			  </xsl:if>
			  <xsl:variable name="t_c" select="count(t) + count(tf)"/>
			  <xsl:for-each select="(./t | ./tf | ./te)">
<!-- 			    <xsl:if test="($t_c = 0) or (($t_c &gt; 0) and (not(local-name() = 'te')))"> -->
			      <xsl:value-of select="."/>
			      <xsl:if test="position() != last()">
				<xsl:value-of select="', '"/>
			      </xsl:if>
<!-- 			    </xsl:if> -->
			  </xsl:for-each>
			  <xsl:if test="position() != last()">
			    <xsl:value-of select="';'"/>
			  </xsl:if>
			  <xsl:value-of select="' '"/>
			</xsl:for-each>
		      </xsl:for-each>
		    </r>
		  </p>
		</e>

	      </xsl:for-each>
	    </section>
	  </dictionary>
	</xsl:variable>
	
	<!-- Output -->
	<xsl:result-document href="{$outDir}/{$file_name}.{$e}" format="{$output_format}">
	  <xsl:copy-of select="$out"/>
	</xsl:result-document>
	
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>Cannot locate: </xsl:text><xsl:value-of select="$inFile"/><xsl:text>&#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>

