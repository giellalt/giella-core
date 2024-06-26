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

  <xsl:variable name="internalRef" select="false()"/>
  <xsl:variable name="debug" select="true()"/>
  <xsl:variable name="nl" select="'&#xa;'"/>

  <xsl:template match="r">
    <d:dictionary
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">
      <xsl:apply-templates />
    </d:dictionary>
  </xsl:template>
  
  <xsl:template match="e">

    <xsl:if test="$debug">
      <xsl:message terminate="no">
	<xsl:value-of select="concat('%%%%%%%%', $nl)"/>
	<xsl:value-of select="concat('processing  ', ./lg/l, $nl)"/>
      </xsl:message>
    </xsl:if>

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

	    <!-- this doesn't work with StarDict -->	    
	    <!-- <font size="-3">  &#9658;</font> -->

	    <!-- this works with StarDict too -->
	    <!-- <xsl:text> &#8594;</xsl:text> -->
	    <!-- <small> -->
	    <!--   <xsl:text>  &#8594;</xsl:text> -->
	    <!-- </small> -->
	    
	    <font size="-3">  &#8594; </font>

	    <xsl:if test="$internalRef">
	      <a href="x-dictionary:r:{lg/lemma_ref/@lemmaID}">
		<short_ref>
		  <xsl:value-of select="normalize-space(lg/lemma_ref)"/>
		</short_ref>
	      </a>
	    </xsl:if>
	    
	    <xsl:if test="not($internalRef)">
	      <short_ref>
		<xsl:value-of select="normalize-space(lg/lemma_ref)"/>
	      </short_ref>
	    </xsl:if>
	    
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
	  <xsl:if test="(normalize-space(lg/l/@stem) = 'odd') or (not(normalize-space(lg/l/@class) = '')
			or (normalize-space(lg/l/@stem) = '3syll'))">
	    <xsl:text>Klasse </xsl:text>
	    <xsl:if test="not(normalize-space(lg/l/@class) = '')">
	      <i><xsl:value-of select="normalize-space(lg/l/@class)"/></i>
	    </xsl:if>
	    <xsl:if test="(normalize-space(lg/l/@stem) = 'odd') or (normalize-space(lg/l/@stem) = '3syll')">
	      <i><xsl:text>ulikest.</xsl:text></i>
	    </xsl:if>
	  </xsl:if>
	</xsl:if>
      </div>
      
      <div>
	<ol>
	  <xsl:apply-templates select="mg[not(./@xml:lang)]"/>
	</ol>
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
	<xsl:if test="./mg[not(./@xml:lang)]/tg[./@xml:lang='nob']/xg/x and ./mg[not(./@xml:lang)]/tg[./@xml:lang='nob']/xg/xt  and not(./lg/lemma_ref)">
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
		  <xsl:apply-templates select="./mg[not(./@xml:lang)]/tg[./@xml:lang='nob']/xg"/>
<!-- 		</ul> -->
<!-- 	      </td> -->
	    </tr>
	  </table>
	</xsl:if>
      </div>

      <div align="right" d:priority="2">
	<xsl:if test="normalize-space(./@src) = 'sk'">
	  <xsl:text>Kilde </xsl:text>
	  <i><xsl:text>Statens Kartverk</xsl:text></i>
	</xsl:if>
	<xsl:if test="normalize-space(./@src) = 'SvSt'">
	  <xsl:text>Kilde </xsl:text>
	  <i><xsl:text>Svenske Sametingets nettside</xsl:text></i>
	</xsl:if>
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
  
  <xsl:template match="mg[not(./@xml:lang)]">

    <xsl:variable name="cp">
      <xsl:variable name="wf" select="myFn:mapPOS(substring-before(normalize-space(../lg/l/@pos),'_'))"/>
      <xsl:variable name="lm" select="myFn:mapPOS(normalize-space(../lg/l/@pos))"/>
	<xsl:value-of select="if (normalize-space($wf) = '') then $lm else $wf"/>
    </xsl:variable>

      <xsl:if test="$debug">
        <xsl:message terminate="no">
          <xsl:value-of select="concat('......$$$......', $nl)"/>
          <xsl:value-of select="concat('pos  ', $cp, $nl)"/>
          <xsl:value-of select="'......$$$......'"/>
        </xsl:message>
      </xsl:if>



    <xsl:if test="count(../mg[not(./@xml:lang)]) = 1">
      <xsl:variable name="tgCount" select="count(./tg[./@xml:lang='nob'])"/>
      <xsl:for-each select="./tg[./@xml:lang='nob']">
	<xsl:variable name="tgPos" select="position()"/>
	<xsl:variable name="tCount" select="count(./*[(local-name() = 't') or (local-name() = 'tf')])"/>
	<xsl:if test="./re">
	  <bf><xsl:value-of select="concat(' (', normalize-space(./re[1]), ') ')"/></bf>
	</xsl:if>
	<xsl:for-each select="./*[(local-name() = 't') or (local-name() = 'tf')]">
	  <xsl:if test="($cp = 'verb') and not(local-name() = 'te')">
	    <bf><xsl:value-of select="'å '"/></bf>
	  </xsl:if>
	  <bf><xsl:value-of select="normalize-space(.)"/></bf>
	  <!-- 				  if ($tgPos = $tgCount) then '.' -->
	  <xsl:value-of select="if (position() = $tCount) then 
				if ($tgPos = $tgCount) then ''
				else '; '
				else ', '"/>
	</xsl:for-each>
	<xsl:if test="./te">
	  <!-- this should be first tested against the containt of all te elements -->
	  <!-- 	  <xsl:if test="($cp = 'verb') and not(local-name() = 'te')"> -->
	  <!-- 	    <bf><i><xsl:value-of select="'å '"/></i></bf> -->
	  <!-- 	  </xsl:if> -->
	  <bf><i><xsl:value-of select="concat(' ', normalize-space(./te[1]), ' ')"/></i></bf>
	</xsl:if>
      </xsl:for-each>
    </xsl:if>
    
    <xsl:if test="count(../mg[not(./@xml:lang)]) &gt; 1">
      <li>
	<xsl:variable name="tgCount" select="count(./tg[./@xml:lang='nob'])"/>
	<xsl:for-each select="./tg[./@xml:lang='nob']">
	  <xsl:variable name="tgPos" select="position()"/>
	  <xsl:variable name="tCount" select="count(./*[(local-name() = 't') or (local-name() = 'tf')])"/>
	  <xsl:if test="./re">
	    <bf><xsl:value-of select="concat(' (', normalize-space(./re[1]), ') ')"/></bf>
	  </xsl:if>
	  <xsl:for-each select="./*[(local-name() = 't') or (local-name() = 'tf')]">
	    <xsl:if test="($cp = 'verb') and not(local-name() = 'te')">
	      <bf><xsl:value-of select="'å '"/></bf>
	    </xsl:if>
	    <bf><xsl:value-of select="normalize-space(.)"/></bf>
	    <!-- 				  if ($tgPos = $tgCount) then '.' -->
	    <xsl:value-of select="if (position() = $tCount) then 
				  if ($tgPos = $tgCount) then ''
				  else '; '
				  else ', '"/>
	  </xsl:for-each>
	  <xsl:if test="./te">
	    <!-- this should be first tested against the containt of all te elements -->
	    <!-- 	  <xsl:if test="($cp = 'verb') and not(local-name() = 'te')"> -->
	    <!-- 	    <bf><i><xsl:value-of select="'å '"/></i></bf> -->
	    <!-- 	  </xsl:if> -->
	    <bf><i><xsl:value-of select="concat(' ', normalize-space(./te[1]), ' ')"/></i></bf>
	  </xsl:if>
	</xsl:for-each>
      </li>
    </xsl:if>
  </xsl:template>
  
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
    <xsl:variable name="currentTrans" select="tokenize(normalize-space(../../../mg[not(./@xml:lang)][1]/tg[./@xml:lang='nob'][1]/t[1]), ' ')[1]"/>
    <xsl:variable name="currentIllpl" select="normalize-space(../../l/@illpl)"/>

    <xsl:if test="$debug">
      <xsl:message terminate="no">
	<xsl:value-of select="concat('............', $nl)"/>
	<xsl:value-of select="concat('processing  ', $currentWordForm[1], ' currentTranslation ', $currentTrans, $nl)"/>
	<xsl:value-of select="'............'"/>
      </xsl:message>
    </xsl:if>
    
    <tr>
      <xsl:if test="not($currentPOS = 'verb') and not($currentIllpl = 'no' and ends-with(./@ms, 'Pl_Ill'))">
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
			  (ends-with(./@ms, 'Sg3') and $currentMPfeature = 'onlyPl') or 
			  (./@ms = 'PrfPrc'))">
	    <td align="right">
	      <morpho_descr>
		<xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
	      </morpho_descr>
	    </td>
	  </xsl:when>
	  <!-- Extra Wurst for smanob -->
	  <xsl:when test="./@ms = 'PrfPrc'">
	    <td align="right">
	      <morpho_descr>
		<xsl:value-of select="'perf.'"/>
	      </morpho_descr>
	    </td>
	  </xsl:when>
	  <xsl:otherwise>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
      
      <xsl:if test="$currentPOS = 'verb'">
	<xsl:choose>
	  <xsl:when test="ends-with(./@ms, 'Inf')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Ind_Prs_Sg1') and not(($currentMPfeature = 'notSg1') or ($currentMPfeature = 'onlyPl'))">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'daan biejjien manne', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Ind_Prs_Sg3')and not($currentMPfeature = 'onlyPl')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'daan biejjien dïhte', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'ConNeg')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
	      <xsl:if test="not($currentMPfeature = 'onlyPl')">
		<xsl:value-of select="concat('(', 'ij', ')', ' ')"/>
	      </xsl:if>
	      <xsl:if test="$currentMPfeature = 'onlyPl'">
	      		<xsl:value-of select="concat('(', 'eah', ')', ' ')"/>
	      </xsl:if>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'Ind_Prs_Pl3')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'daan biejjien dah', ')', ' ')"/>
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
	  <xsl:when test="ends-with(./@ms, 'Ger') or ends-with(./@ms ,'PrfPrc')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="concat('(', 'lea', ')', ' ')"/>
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	  <xsl:when test="ends-with(./@ms, 'VGen')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<!-- xsl:value-of select="concat('(', 'dïhte båata', ')', ' ')"/ -->
		<xsl:value-of select="$currentWordForm"/>
	      </small>
	    </td>
	  </xsl:when>
	</xsl:choose>
      </xsl:if>

      <xsl:if test="$currentPOS = 'egennavn'">
	<xsl:choose>
	  <xsl:when test="ends-with(./@ms, '_Gen')">
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
	  <xsl:when test="ends-with(./@ms, '_Ill')">
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
	  <xsl:when test="ends-with(./@ms, '_Ine')">
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
	  <xsl:when test="ends-with(./@ms, '_Ela')">
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
	<xsl:if test="not($currentIllpl = 'no' and ends-with(./@ms, 'Pl_Ill'))">
	  <td align="center"> </td>
	  <td align="center"> </td>
	  <td align="left">
	    <small>
	      <xsl:value-of select="$currentWordForm"/>
	    </small>
	  </td>
	</xsl:if>
      </xsl:if>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>
