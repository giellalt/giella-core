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
      <xsl:attribute name="id">
	<xsl:variable name="attr_values">
	  <xsl:for-each select="lg/l/@*">
	    <xsl:text>_</xsl:text>
	    <xsl:value-of select="normalize-space(.)" />
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="concat(lg/l, $attr_values)"/>
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
	    <pos_tag>
	      <i><xsl:value-of select="myFn:mapPOS(substring-before(normalize-space(lg/l/@pos),'_'))"/></i>
	    </pos_tag>

	    <!-- <xsl:text> &#187;</xsl:text> -->
	    <!-- <xsl:text> &x2192;</xsl:text> -->

	    <!-- this works with StarDict too -->
	    <!-- <xsl:text> &#8594;</xsl:text> -->


	    <!-- 	    <small> -->
	    <!-- 	      <xsl:text> &#9658;</xsl:text> -->
	    <!-- 	    </small> -->

	    <!-- this doesn't work with StarDict -->	    
	    <font size="-3">  &#9658;</font>
	    
	    <a href="x-dictionary:r:{lg/lemma_ref/@lemmaID}">
	      <short_ref>
		<xsl:value-of select="normalize-space(lg/lemma_ref)"/>
	      </short_ref>
	    </a>
	  </xsl:if>
	  <xsl:if test="not(lg/lemma_ref)">
	    <pos_tag>
	      <i><xsl:value-of select="myFn:mapPOS(normalize-space(lg/l/@pos))"/></i>
	    </pos_tag>
	  </xsl:if>
	</span>
      </span>

      <div>
	<xsl:if test="lg/l/@pos = 'v' or substring-before(normalize-space(lg/l/@pos),'_') = 'v'">
	  <!-- 	  <xsl:text>mist </xsl:text> -->
	  <xsl:if test="normalize-space(lg/l/@stem) = 'odd' or not(normalize-space(lg/l/@class) = '')">
	    <xsl:text>Klasse </xsl:text>
	    <xsl:if test="not(normalize-space(lg/l/@class) = '')">
	      <i><xsl:value-of select="normalize-space(lg/l/@class)"/></i>
	    </xsl:if>
	    <xsl:if test="normalize-space(lg/l/@stem) = 'odd'">
	      <i><xsl:text>ulikest.</xsl:text></i>
	    </xsl:if>
	  </xsl:if>
	</xsl:if>
      </div>
      
      <div>
	<!-- 	<br/> -->
	<xsl:if test="mg[not(./@lang)]">
	  <i>
	    <b>Norsk:</b>
	  </i>
	  <!-- 	  <br/> -->
	  <ol>
	    <xsl:apply-templates select="mg[not(./@lang)]"/>
	  </ol>
	</xsl:if>
	<xsl:if test="mg[./@lang='swe']">
	  <i>
	    <b>Svensk:</b>
	  </i>
<!-- 	  <br/> -->
	  <ol>
	    <xsl:apply-templates select="mg[./@lang='swe']"/>
	  </ol>
	</xsl:if>
	<xsl:if test="lg/analysis">
	  <prep_context>
	    <i>
	      <b><xsl:value-of select="concat(normalize-space(concat('Analyse', if (lg/analysis/last() &gt; 1) then 'r' else '')), ': ')"/></b>
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
	<xsl:if test="lg/mini_paradigm/analysis/wordform">
	  <xsl:apply-templates select="lg/mini_paradigm"/>
	</xsl:if>
      </div>
      
      <div align="left" d:priority="2">
	<xsl:if test="./mg/tg/xg/x and ./mg/tg/xg/xt  and not(./lg/lemma_ref)">
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
<!-- bulleted -->
<!-- 	      <td align="left"> -->
<!-- 		<ul> -->
		  <!-- 		      <xsl:call-template name="exx"/> -->
		  <xsl:apply-templates select="./mg/tg/xg"/>
<!-- 		</ul> -->
<!-- 	      </td> -->
	    </tr>
	  </table>
	</xsl:if>
      </div>

      <!--       <div align="left" d:priority="2"> -->
      <!--       </div> -->
      
      <div align="right" d:priority="2">
	<xsl:if test="normalize-space(./@source) = 'sk'">
	  <xsl:text>Kilde </xsl:text>
	  <i><xsl:text>Statens Kartverk</xsl:text></i>
	</xsl:if>
	<xsl:if test="normalize-space(./@source) = 'SvSt'">
	  <xsl:text>Kilde </xsl:text>
	  <i><xsl:text>Svenske Sametingets nettside</xsl:text></i>
	</xsl:if>
	<img class="alpha" src="Images/blank.jpg"/>
	<table border="0" align="right">
	  <tr>
	    <td align="right"></td>
	    <td align="right">
	      <img class="beta" src="Images/sme2nob_bg.jpg"/>
	    </td>
	  </tr>
	</table>
      </div>
      
    </d:entry>
    
  </xsl:template>
  
  <xsl:template match="mg[not(./@lang)]">
    <xsl:variable name="tgCount" select="count(./tg)"/>
    <xsl:for-each select="./tg">
      <xsl:variable name="tgPos" select="position()"/>
      <li>
	<xsl:variable name="tCount" select="count(./t)"/>
	<xsl:for-each select="./t">
	  <bf><xsl:value-of select="normalize-space(.)"/></bf>
	  <!-- 				  if ($tgPos = $tgCount) then '.' -->
	  <xsl:value-of select="if (position() = $tCount) then 
				if ($tgPos = $tgCount) then ''
				else ';'
				else ', '"/>
	</xsl:for-each>
      </li>
    </xsl:for-each>
    
  </xsl:template>
  
  <xsl:template match="mg[./@lang='swe']">
    <xsl:variable name="tgCount" select="count(./tg)"/>
    <xsl:for-each select="./tg">
      <xsl:variable name="tgPos" select="position()"/>
      <li>
	<xsl:variable name="tCount" select="count(./t)"/>
	<xsl:for-each select="./t">
	  <bf><xsl:value-of select="normalize-space(.)"/></bf>
	  <!-- 				  if ($tgPos = $tgCount) then '.' -->
	  <xsl:value-of select="if (position() = $tCount) then 
				if ($tgPos = $tgCount) then ''
				else ';'
				else ', '"/>
	</xsl:for-each>
      </li>
    </xsl:for-each>
  </xsl:template>

<!-- bulleted   -->
<!--   <xsl:template name="exx" match="xg"> -->
<!--     <li> -->
<!--       <xsl:apply-templates select="./x"/> -->
<!--     </li> -->
<!--   </xsl:template> -->
  
<!--   <xsl:template match="x"> -->
<!--     <i> -->
<!--       <small> -->
<!-- 	<xsl:value-of select="normalize-space(.)"/> -->
<!--       </small> -->
<!--     </i> -->
<!--     <br/> -->
<!--     <xsl:apply-templates select="../xt"/> -->
<!--   </xsl:template> -->
  
<!--   <xsl:template match="xt"> -->
<!--     <small> -->
<!--       <xsl:value-of select="normalize-space(.)"/> -->
<!--     </small> -->
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
    <xsl:variable name="currentWordForm" select="./wordform/@value"/>
    <xsl:variable name="currentPOS" select="myFn:mapPOS(normalize-space(../../l/@pos))"/>
    <xsl:variable name="currentMPfeature" select="../../l/@minip"/>
    <xsl:variable name="currentMS" select="normalize-space(./@ms)"/>
    <xsl:variable name="currentTrans" select="tokenize(normalize-space(../../../mg[1]/tg[1]/t[1]), ' ')[1]"/>

    <tr>
      
      <xsl:if test="not($currentPOS = 'verb')">
	<td align="right">
	  <morpho_descr>
	    <xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
	  </morpho_descr>
	</td>
      </xsl:if>
      
      <xsl:if test="$currentPOS = 'verb'">
	<xsl:choose>
	  <xsl:when test="not((ends-with(./@ms, 'Sg1') and
			  (($currentMPfeature = 'notSg1') or ($currentMPfeature = 'onlyPl'))) or
			  (ends-with(./@ms, 'Sg3') and $currentMPfeature = 'onlyPl'))">
	    <td align="right">
	      <morpho_descr>
		<xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
	      </morpho_descr>
	    </td>
	  </xsl:when>
	  <xsl:otherwise>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
      
      <xsl:if test="$currentPOS = 'verb'">
	<xsl:choose>
	  <xsl:when test="ends-with(./@ms, 'Ind_Prs_Sg1') and not(($currentMPfeature = 'notSg1') or ($currentMPfeature = 'onlyPl'))">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'daenbiejjien manne', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Ind_Prs_Sg3')and not($currentMPfeature = 'onlyPl')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'daenbiejjien dïhte', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Ind_Prs_Pl3')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'daenbiejjien dah', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Ind_Prt_Sg1') and not(($currentMPfeature = 'notSg1') or ($currentMPfeature = 'onlyPl'))">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'jååktan manne', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Ger')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'dïhte lea', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'VGen')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'dïhte båata', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	</xsl:choose>
      </xsl:if>

      <xsl:if test="$currentPOS = 'egennavn'">
	<xsl:choose>
	  <xsl:when test="ends-with(./@ms, 'Sg_Gen')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="$currentWordForm"/>
		<xsl:value-of select="concat(' ', 'baaktoe')"/>
	      </small>
	    </td>

	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<i>
		  <xsl:value-of select="'via '"/>
		  <xsl:value-of select="$currentTrans"/>
		</i>
	      </small>
	    </td>

	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Sg_Ill')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>

	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<i>
		  <xsl:value-of select="'til '"/>
		  <xsl:value-of select="$currentTrans"/>
		</i>
	      </small>
	    </td>

	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Sg_Ine')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>

	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<i>
		  <xsl:value-of select="'i/på '"/>
		  <xsl:value-of select="$currentTrans"/>
		</i>
	      </small>
	    </td>


	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Sg_Ela')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>

	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<i>
		  <xsl:value-of select="'fra '"/>
		  <xsl:value-of select="$currentTrans"/>
		</i>
	      </small>
	    </td>

	  </xsl:when>
	</xsl:choose>
      </xsl:if>
      
      <xsl:if test="not($currentPOS = 'verb') and not($currentPOS = 'egennavn')">
	<td align="center"> </td>
	<td align="center"> </td>
	<td align="left">
	  <small>
	    <xsl:value-of select="$currentWordForm"/>
	  </small>
	</td>
      </xsl:if>

    </tr>
  </xsl:template>
  
</xsl:stylesheet>
