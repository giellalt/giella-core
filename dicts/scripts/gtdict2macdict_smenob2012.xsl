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

      <!-- to refine here -->
      <d:index d:value="{lg/l}"/>

      <xsl:for-each select="lg/lsub">
	<xsl:if test="not(normalize-space(.) = '')">
	  <d:index d:value="{.}"/>
	</xsl:if>
      </xsl:for-each>
      <!-- this is a remaining from the smanob dict, apparently not applicable for sme -->
      <xsl:for-each select="lg/spellings/spv">
	<xsl:if test="not(normalize-space(.) = '')">
	  <d:index d:value="{.}"/>	
	</xsl:if>
      </xsl:for-each>

      <!-- refining indexing for mwe -->
      <xsl:for-each select="(tokenize(normalize-space(lg/l), ' '))[position() &gt; 1]">
	<d:index d:value="{.}"/>	
      </xsl:for-each>

      <xsl:if test="some $node in lg/analysis satisfies (starts-with($node, 'v_') and
                    (contains($node, 'Ind') or contains($node, 'Cond') or contains($node, 'Pot')))">
        <d:index d:value="{concat(normalize-space(lg/l), 'go')}"/>
      </xsl:if>

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
		<!--short_ref-->
		<b>
		  <xsl:value-of select="normalize-space(lg/lemma_ref)"/>
		</b>
		<!--/short_ref-->
	      </a>
	    </xsl:if>

	    <xsl:if test="not($internalRef)">
	      <b>
		<xsl:value-of select="normalize-space(lg/lemma_ref)"/>
	      </b>
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
	<ol>
	  <xsl:apply-templates select="mg"/>
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
      
      <xsl:if test="lg/l_ref">
	<div align="left" d:priority="2">
	  <!-- todo -->
	  <xsl:if test="$internalRef">
	    <i><xsl:value-of select="'Se også '"/></i>
	    <a href="x-dictionary:r:{lg/lemma_ref/@lemmaID}">
	      <!--cf_ref-->
	      <b>
		<xsl:value-of select="normalize-space(lg/lemma_ref)"/>
	      </b>
	      <!--/cf_ref-->
	    </a>
	  </xsl:if>
	  
	  <xsl:if test="not($internalRef)">
	    <i><xsl:value-of select="'Se også '"/></i>
	    <b>
	      <xsl:value-of select="substring-before(normalize-space(lg/l_ref), '_')"/>
	    </b>
	  </xsl:if>
	  <img class="alpha" src="Images/blank.jpg"/>
	</div>
      </xsl:if>
      
      <xsl:if test="lg/mini_paradigm/analysis/wordform">
	<div align="left" d:priority="2">
	  <xsl:apply-templates select="lg/mini_paradigm"/>
	</div>
      </xsl:if>
      
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
      </div>
    </d:entry>
  </xsl:template>
  
  <xsl:template match="mg">
    <xsl:variable name="cp">
      <xsl:variable name="wf" select="myFn:mapPOS(substring-before(normalize-space(../lg/l/@pos),'_'))"/>
      <xsl:variable name="lm" select="myFn:mapPOS(normalize-space(../lg/l/@pos))"/>
	<xsl:value-of select="if (normalize-space($wf) = '') then $lm else $wf"/>
    </xsl:variable>

      <xsl:if test="false()">
        <xsl:message terminate="no">
          <xsl:value-of select="concat('......$$$......', $nl)"/>
          <xsl:value-of select="concat('pos  ', $cp, $nl)"/>
          <xsl:value-of select="'......$$$......'"/>
        </xsl:message>
      </xsl:if>

    <xsl:if test="count(../mg) = 1">
      <xsl:variable name="tgCount" select="count(./tg)"/>
      <xsl:for-each select="./tg">
	<xsl:variable name="tgPos" select="position()"/>
	<xsl:variable name="tCount" select="count(./*[(local-name() = 't') or (local-name() = 'tf')])"/>
	<xsl:if test="./re">
	  <bf><xsl:value-of select="concat('(', normalize-space(./re[1]), ') ')"/></bf>
	</xsl:if>
	<xsl:for-each select="./*[(local-name() = 't') or (local-name() = 'tf')]">
	  <xsl:if test="($cp = 'verb') and not(local-name() = 'te')">
	    <bf><xsl:value-of select="'å '"/></bf>
	  </xsl:if>
	  <bf><xsl:value-of select="normalize-space(.)"/></bf>
	  <xsl:if test="@country">
	    <bf><xsl:value-of select="concat(' (', normalize-space(./@country), ') ')"/></bf>
	  </xsl:if>
	  <xsl:if test="@reg">
	    <bf><xsl:value-of select="concat(' (', normalize-space(./@reg), ') ')"/></bf>
	  </xsl:if>
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
	    <xsl:if test="($cp = 'verb') and not(local-name() = 'te')">
	      <bf><xsl:value-of select="'å '"/></bf>
	    </xsl:if>

	    <bf><xsl:value-of select="normalize-space(.)"/></bf>
	    <xsl:if test="@country">
	      <bf><xsl:value-of select="concat(' (', normalize-space(./@country), ') ')"/></bf>
	    </xsl:if>
	    <xsl:if test="@reg">
	      <bf><xsl:value-of select="concat(' (', normalize-space(./@reg), ') ')"/></bf>
	    </xsl:if>
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
    <xsl:variable name="currentContext" select="normalize-space(../../l/@context)"/>
    <xsl:variable name="currentIllpl" select="normalize-space(../../l/@illpl)"/>

    <!-- xsl:variable name="currentMS" select="normalize-space(./@ms)"/ -->

    <xsl:variable name="currentMS">
      <xsl:variable name="vtags" select="'___v1___v2___v3___v4___v5___'"/>
      <xsl:variable name="current_vtag" select="(tokenize(normalize-space(./@ms), '_'))[1]"/>

      <xsl:if test="contains($vtags, $current_vtag)">
	<xsl:value-of select="substring-after(./@ms, concat($current_vtag, '_'))"/>

	<xsl:if test="$debug">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('___vtag detected___ ', substring-after(./@ms, concat($current_vtag, '_')),' vtags ', $vtags, $nl)"/>
	    <xsl:value-of select="'............'"/>
	  </xsl:message>
	</xsl:if>
	
      </xsl:if>
      <xsl:if test="not(contains($vtags, $current_vtag))">
	<xsl:value-of select="./@ms"/>
	<xsl:if test="$debug">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('NO vtag detected ', ./@ms, ' current_vtag ', $current_vtag, $nl)"/>
	    <xsl:value-of select="'............'"/>
	  </xsl:message>
	</xsl:if>
      </xsl:if>
    </xsl:variable>
    
    <xsl:variable name="currentTrans">
      <xsl:variable name="currentTransT" select="tokenize(normalize-space(../../../mg[1]/tg[1]/t[1]), ' ')[1]"/>
      <xsl:variable name="currentTransPh" select="normalize-space(../../../mg[1]/tg[1]/tf[1])"/>
      <xsl:value-of select="if (normalize-space($currentTransT) = '') then $currentTransPh else $currentTransT"/>
    </xsl:variable>
    
    <xsl:if test="false()">
      <xsl:message terminate="no">
	<xsl:value-of select="concat('............', $nl)"/>
	<xsl:value-of select="concat('checking miniparadigm ', $currentWordForm[1], ' currentTranslation ', $currentTrans, $nl)"/>
	<xsl:value-of select="'............'"/>
      </xsl:message>
    </xsl:if>
    
    <tr>
      <xsl:if test="not($currentPOS = 'verb')">
	<!-- pos=subst & illPl=no-->
	<xsl:if test="(($currentPOS = 'subst.'))">
	  <xsl:if test="$currentIllpl = 'no'">
	    <xsl:choose>
	      <xsl:when test="(ends-with(./@ms, 'Sg_Gen') or
			      ends-with(./@ms, 'Sg_Ill'))">
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
	  <xsl:if test="not($currentIllpl = 'no')">
	    <td align="right">
	      <morpho_descr>
		<xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
	      </morpho_descr>
	    </td>
	  </xsl:if>
	</xsl:if>
	
	<xsl:if test="not($currentPOS = 'subst.')">
	  <td align="right">
	    <morpho_descr>
	      <xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
	    </morpho_descr>
	  </td>
	</xsl:if>
	
      </xsl:if>
      
      <xsl:if test="$currentPOS = 'verb'">
	<xsl:if test="$currentContext = 'mun'">
	  <xsl:choose>
	    <xsl:when test="(ends-with(./@ms, 'Ind_Prs_Sg1') or
			    ends-with(./@ms, 'Ind_Prt_Sg1') or
			    ends-with(./@ms, 'Ind_Prs_ConNeg'))">
	      <td align="right">
		<morpho_descr>
		  <xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
		</morpho_descr>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
	<xsl:if test="$currentContext = 'dat'">
	  <xsl:choose>
	    <xsl:when test="(ends-with(./@ms, 'Ind_Prs_Pl3') or
			    ends-with(./@ms, 'Ind_Prt_Sg3') or
			    ends-with(./@ms, 'Ind_Prs_ConNeg'))">
	      <td align="right">
		<morpho_descr>
		  <xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
		</morpho_descr>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
	<xsl:if test="$currentContext = 'upers'">
	  <xsl:choose>
	    <xsl:when test="(ends-with(./@ms, 'Ind_Prs_Sg3') or
			    ends-with(./@ms, 'Ind_Prt_Sg3') or
			    ends-with(./@ms, 'Ind_Prs_ConNeg'))">
	      <td align="right">
		<morpho_descr>
		  <xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
		</morpho_descr>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
	<xsl:if test="$currentContext = 'sii'">
	  <xsl:choose>
	    <xsl:when test="(ends-with(./@ms, 'Ind_Prs_Pl3') or
			    ends-with(./@ms, 'Ind_Prt_Pl3') or
			    ends-with(./@ms, 'Ind_Prs_ConNeg'))">
	      <td align="right">
		<morpho_descr>
		  <xsl:value-of select="normalize-space(myFn:mapMORPH(./@ms))"/>
		</morpho_descr>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
<!--       </xsl:if> -->


<!--       <xsl:if test="($currentPOS = 'verb')"> -->
	<xsl:if test="$currentContext = 'mun'">
	  <xsl:choose>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_Sg1')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'odne ', $currentContext, ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prt_Sg1')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'ikte ', $currentContext, ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_ConNeg')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'in', ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
	<xsl:if test="$currentContext = 'dat'">
	  <xsl:choose>
	    <!-- with or without 'odne' here? -->
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_Pl3')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'odne ', $currentContext, ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prt_Sg3')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'ikte ', $currentContext, ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_ConNeg')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'ii', ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
	<xsl:if test="$currentContext = 'upers'">
	  <xsl:choose>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_Sg3')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'odne', ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prt_Sg3')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'ikte', ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_ConNeg')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'ii', ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
	<xsl:if test="$currentContext = 'sii'">
	  <xsl:choose>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_Pl3')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'odne ', $currentContext, ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prt_Pl3')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'ikte ', $currentContext, ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	    <xsl:when test="ends-with(./@ms, 'Ind_Prs_ConNeg')">
	      <td align="center"> </td>
	      <td align="center"> </td>
	      <td align="left">
		<small>
		  <xsl:value-of select="concat('(', 'eai', ')', ' ')"/>
		  <xsl:value-of select="$currentWordForm"/>
		</small>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
      </xsl:if>

      <xsl:if test="$currentPOS = 'egennavn'">
	<xsl:choose>
	  <xsl:when test="ends-with(./@ms, '_Gen')">
	    <td align="center"> </td>
	    <td align="center"> </td>
	    <td align="left">
	      <small>
		<xsl:value-of select="$currentWordForm"/>
		<xsl:value-of select="concat(' ', 'bokte')"/>
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
	  <xsl:when test="ends-with(./@ms, '_Loc')">
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
		  <xsl:value-of select="'i/fra '"/>
		  <xsl:value-of select="$currentTrans"/>
		</i>
	      </small>
	    </td>

	  </xsl:when>
	</xsl:choose>
      </xsl:if>

      <!-- pos=subst & illPl=no-->
      <!-- xsl:if test="(($currentPOS = 'subst.'))">
	<xsl:if test="$currentIllpl = 'no'">
	  <xsl:choose>
	    <xsl:when test="(ends-with(./@ms, 'Sg_Gen') or
			    ends-with(./@ms, 'Sg_Ill'))">
	      <td align="right">
		<morpho_descr>
		  <xsl:value-of select="concat('in_if_test', normalize-space(myFn:mapMORPH(./@ms)))"/>
		</morpho_descr>
	      </td>
	    </xsl:when>
	  </xsl:choose>
	</xsl:if>
      </xsl:if -->
	
      <xsl:if test="(($currentPOS = 'num.') or ($currentPOS = 'adj.') or ($currentPOS = 'subst.') or ($currentPOS = 'pron.'))">

	<xsl:if test="$debug">
	  <xsl:message terminate="no">
	    <xsl:value-of select="concat('.............', $nl)"/>
	    <xsl:value-of select="concat('processing  ', $currentWordForm[1], ' currentMS ', $currentMS, $nl)"/>
	    <xsl:value-of select="'............'"/>
	  </xsl:message>
	</xsl:if>
	
	<td align="center"> </td>
	<td align="center"> </td>
	<td align="left">
	  <small>

	    <!-- xsl:value-of select="$currentWordForm"/ -->

	    <!--xsl:if test="not((ends-with($currentMS, 'Pl_Ill')) and ($currentIllpl = 'no'))"-->
	    <xsl:if test="not(ends-with($currentMS, 'Pl_Ill')) or (ends-with($currentMS, 'Pl_Ill') and not($currentIllpl = 'no'))">
	      <xsl:value-of select="$currentWordForm"/>
	    </xsl:if>
	    <!-- to debug -->
	    <!--xsl:if test="(($currentPOS = 'num.') and ((substring-after($currentMS, 'num_') = 'Pl_Nom') or (substring-after($currentMS, 'NUM_') = 'Pl_Nom')))  or
			  (($currentPOS = 'adj.') and ((substring-after($currentMS, 'a_') = 'Attr') or (substring-after($currentMS, 'A_') = 'Attr')))"-->


	    <xsl:if test="((($currentPOS = 'num.') and ((substring-after($currentMS, 'num_') = 'Pl_Nom') or (substring-after($currentMS, 'NUM_') = 'Pl_Nom')))  or
			  (($currentPOS = 'adj.') and ((substring-after($currentMS, 'a_') = 'Attr') or (substring-after($currentMS, 'A_') = 'Attr')))) and not($currentContext = '')">

	      <xsl:if test="$debug">
		<xsl:message terminate="no">
		  <xsl:value-of select="concat('--- check context with num and adj ---', $nl)"/>
		  <xsl:value-of select="concat('CONTEXT   ', $currentWordForm[1], ' currentMS ', $currentMS, ' currentContex ', $currentContext, $nl)"/>
		  <xsl:value-of select="'----------------'"/>
		</xsl:message>
	      </xsl:if>


	      <xsl:value-of select="concat(' ', '(', $currentContext, ')')"/>
	    </xsl:if>
	    
	    <xsl:if test="(($currentPOS = 'num.') and ((substring-after($currentMS, 'num_') = 'Pl_Gen') or (substring-after($currentMS, 'NUM_') = 'Pl_Gen')))">
	      <xsl:value-of select="' (gápmagiid)'"/>
	    </xsl:if>
	    
	  </small>
	</td>
      </xsl:if>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>
