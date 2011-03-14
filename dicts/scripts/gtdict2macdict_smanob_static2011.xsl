<?xml version="1.0"?>
<!--+
    | Transforms termcenter.xml files into tab-separated entries of sme-nob.
    | Usage: xsltproc termc2txt.xsl termcenter.xml
    | 
    +-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
    xmlns:myFn="http://whatever"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">

  <xsl:import href="mapPOS.xsl"/>
  <xsl:import href="mapMORPH.xsl"/>
  
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      indent="yes"/>


  <xsl:template match="r">
    <d:dictionary
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">
      <xsl:apply-templates />
    </d:dictionary>
  </xsl:template>
  
  <xsl:template match="e">
    <d:entry d:title="{lg/l}">
      
      <xsl:variable name="dictID">
	<xsl:variable name="attr_values">
	  <xsl:for-each select="lg/l/@*">
	    <xsl:text>_</xsl:text>
	    <xsl:value-of select="normalize-space(.)" />
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="concat(lg/l, $attr_values)"/>
      </xsl:variable>
      
      <xsl:attribute name="id">
	<xsl:value-of select="$dictID"/>
      </xsl:attribute>
      <!--       <d:index d:value="{lg/l}"/> -->
      <xsl:for-each select="lg/spellings/spv">
	<d:index d:value="{.}"/>	
      </xsl:for-each>
      
      <div d:priority="2"><h1><xsl:value-of select="lg/l"/></h1></div>
      <span class="syntax">
	<span d:pr="US">
	  <!-- it is a word form -->
	  <xsl:if test="lg/lemma_ref">
	    <xsl:for-each select="lg/lemma_ref">
	      <pos_tag>
		<i>
		  <xsl:if test="../l/@type">
		    <xsl:value-of select="myFn:mapPOS(normalize-space(../l/@type))"/>
		    <xsl:text> </xsl:text>
		  </xsl:if>
		  <xsl:if test="not(../l/@type = 'interr')">
		    <xsl:value-of select="myFn:mapPOS(normalize-space(../l/@pos))"/>
		  </xsl:if>
		</i>
	      </pos_tag>

	      <!-- 	      <font size="-3">  &#9658;</font> -->
	      <!-- 	      <small> -->
	      <!-- 		<xsl:text>  &#8594;</xsl:text> -->
	      <!-- 	      </small> -->
	      
	      <font size="-3">  &#8594; </font>
	      <a href="x-dictionary:r:{./@lemmaID}">
		<short_ref>
		  <xsl:value-of select="normalize-space(.)"/>
		</short_ref>
	      </a>
	      <i>
		<xsl:value-of select="if (position() = last()) then ''
				      else 
				      if (last() &gt;= 2) then
				      if (position() = last()-1) then ' el. '
				      else ', '
				      else ''"/>
	      </i>
	    </xsl:for-each>
	  </xsl:if>
	  <xsl:if test="not(lg/lemma_ref)">
	    <pos_tag>
	      <i>
		<xsl:if test="lg/l/@type">
		  <xsl:value-of select="myFn:mapPOS(normalize-space(lg/l/@type))"/>
		  <xsl:text> </xsl:text>
		</xsl:if>
		<xsl:if test="not(lg/l/@type = 'interr')">
		  <xsl:value-of select="myFn:mapPOS(normalize-space(lg/l/@pos))"/>
		</xsl:if>
	      </i>
	    </pos_tag>
	  </xsl:if>
	</span>
      </span>
      <div>
	<ol>
	  <xsl:apply-templates select="mg"/>
	</ol>
	<xsl:if test="lg/analysis">
	  <prep_context>
	    <i>
	      <b><xsl:value-of select="concat('Analyse', if (lg/analysis/last() &gt; 1) then 'r: ' else ': ')"/></b>
	    </i>
	  </prep_context>
	  <xsl:for-each select="lg/analysis">
	    <xsl:variable name="posOutput" select="myFn:mapMORPH(.)"/>
	    <xsl:if test="not($posOutput = '')">
	      <morpho_descr>
		<xsl:value-of select="$posOutput"/>
	      </morpho_descr>
	      <prep_context>
		<!-- 		    <xsl:value-of select="if (position() = last()) then ' av&#x9;' -->
		<i>
		  <xsl:value-of select="if (position() = last()) then ''
					else 
					if (last() &gt;= 2) then
					if (position() = last()-1) then ' el. '
					else ', '
					else ''"/>
		</i>
	      </prep_context>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:if>
      </div>
      <div align="left" d:priority="2">
	<xsl:if test="lg/mini_paradigm">
	  <xsl:apply-templates select="lg/mini_paradigm"/>
	</xsl:if>
	<xsl:if test="mg/tg/xg and not(mg/tg/xg = '')">
	  <img class="alpha" src="Images/blank.jpg"/>
	  <table border="0" align="left">
	    <tr>
	      <td align="left">
		<prep_context>
		  <i>
		    <b>Eksempler:</b>
		  </i>
		</prep_context>
	      </td>
	      <td align="left"/>
	    </tr>
	    <tr>
	      <xsl:apply-templates select="mg/tg/xg"/>
	    </tr>
	  </table>
	</xsl:if>
      </div>
      
      <div align="right" d:priority="2">
	<img class="alpha" src="Images/blank.jpg"/>
<!-- 	<table border="0" align="right"> -->
<!-- 	  <tr> -->
<!-- 	    <td align="right"></td> -->
<!-- 	    <td align="right"> -->
<!-- 	      <img class="beta" src="Images/sme2nob_bg.jpg"/> -->
<!-- 	    </td> -->
<!-- 	  </tr> -->
<!-- 	</table> -->
      </div>
      
    </d:entry>
    
  </xsl:template>
  
  <xsl:template match="mg">
    <xsl:if test="count(../mg) = 1">
      <xsl:variable name="tgCount" select="count(./tg)"/>
      <xsl:for-each select="./tg">
	<xsl:variable name="tgPos" select="position()"/>
	<xsl:variable name="tCount" select="count(./*[(local-name() = 't') or (local-name() = 'tf')])"/>
	<xsl:if test="./re">
	  <bf><xsl:value-of select="concat('(', normalize-space(./re[1]), ') ')"/></bf>
	</xsl:if>
	<xsl:for-each select="./*[(local-name() = 't') or (local-name() = 'tf')]">
	  <bf><xsl:value-of select="normalize-space(.)"/></bf>
	  <!-- 				  if ($tgPos = $tgCount) then '.' -->
	  <xsl:value-of select="if (position() = $tCount) then 
				if ($tgPos = $tgCount) then ''
				else '; '
				else ', '"/>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:if>
    
    <xsl:if test="count(../mg) &gt; 1">
      <li>
	<xsl:variable name="tgCount" select="count(./tg)"/>
	<xsl:for-each select="./tg">
	  <xsl:variable name="tgPos" select="position()"/>
	  <xsl:variable name="tCount" select="count(./*[(local-name() = 't') or (local-name() = 'tf')])"/>
	<xsl:if test="./re">
	  <bf><xsl:value-of select="concat('(', normalize-space(./re[1]), ') ')"/></bf>
	</xsl:if>

	  <xsl:for-each select="./*[(local-name() = 't') or (local-name() = 'tf')]">
	    <bf><xsl:value-of select="normalize-space(.)"/></bf>
	    <!-- 				  if ($tgPos = $tgCount) then '.' -->
	    <xsl:value-of select="if (position() = $tCount) then 
				  if ($tgPos = $tgCount) then ''
				  else '; '
				  else ', '"/>
	  </xsl:for-each>
	</xsl:for-each>
      </li>
    </xsl:if>
  </xsl:template>



<!--   <xsl:template match="mg"> -->
<!--     <xsl:variable name="tgCount" select="count(./tg)"/> -->
<!--     <xsl:for-each select="./tg"> -->
<!--       <xsl:variable name="tgPos" select="position()"/> -->
<!--       <li> -->
<!-- 	<xsl:variable name="tCount" select="count(./t)"/> -->
<!-- 	<xsl:for-each select="./t"> -->
<!-- 	  <bf><xsl:value-of select="normalize-space(.)"/></bf> -->
	  <!-- 				  if ($tgPos = $tgCount) then '.' -->
<!-- 	  <xsl:value-of select="if (position() = $tCount) then  -->
<!-- 				if ($tgPos = $tgCount) then '' -->
<!-- 				else ';' -->
<!-- 				else ', '"/> -->
<!-- 	</xsl:for-each> -->
<!--       </li> -->
<!--     </xsl:for-each> -->
<!--   </xsl:template> -->
  
  <xsl:template match="xg">
    <tr>
      <xsl:apply-templates select="./x"/>
    </tr>
  </xsl:template>
  
  <xsl:template match="x">
    <td>
      <i><small>
	<xsl:value-of select="normalize-space(.)"/>
      </small></i>
      <xsl:apply-templates select="../xt"/>
    </td>
  </xsl:template>
  
  <xsl:template match="xt">
    
    <td align="center"> </td>
    <td align="center"> </td>
    <td align="left">
      <small>
	<xsl:value-of select="normalize-space(.)"/>
      </small>
    </td>
  </xsl:template>
  
  
  <xsl:template name="m_paradigm" match="mini_paradigm">
    <table border="0" align="left">
      <tr>
	<td align="left">
	  <prep_context>
	    <i>
	      <b>Nøkkelformer:</b>
	    </i>
	  </prep_context>
	</td>
	<td align="left"> </td>
      </tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match="analysis">
    <xsl:variable name="currentWordForm" select="./wordform"/>
    <xsl:variable name="currentPOS" select="myFn:mapPOS(normalize-space(../../l/@pos))"/>
    <xsl:variable name="currentMS" select="normalize-space(./@ms)"/>
    
    <tr>
      <td align="right">
	<morpho_descr>
	  <xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
	</morpho_descr>
      </td>
      <td align="center"> </td>
      <td align="center"> </td>
      <td align="left">
	<small>
	  <xsl:value-of select="$currentWordForm"/>
	</small>
      </td>
<!--       <td align="center"> </td> -->
<!--       <td align="center"> </td> -->
<!--       <td align="center"> </td> -->
<!--       <td align="center"> </td> -->
<!--       <td align="center"> </td> -->
<!--       <td align="center"> </td> -->
<!--       <td align="center"> </td> -->
    </tr>
  </xsl:template>
  
</xsl:stylesheet>
