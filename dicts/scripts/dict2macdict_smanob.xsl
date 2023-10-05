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
  
  <!-- EXAMPLE ENTRIES:
  <d:entry id="ldap" d:title="LDAP">
	<d:index d:value="LDAP"/>
	<h1>LDAP</h1>
	<p>Lightweight Directory Access Protocol</p>
  </d:entry>

  <d:entry id="make_1" d:title="make">
	<d:index d:value="make"/>
	<d:index d:value="makes"/>
	<d:index d:value="made" d:title="made (make)"/>
	<d:index d:value="making"/>
	<d:index d:value="make it" d:parental-control="1" d:anchor="xpointer(//*[@id='make_it'])"/>
	<div d:priority="2"><h1>make</h1></div><span class="syntax"><span d:pr="US">| māk |</span></span>
	<div>
		<ol>
			<li>
				Form by putting parts together or combining substances; construct; create; produce 
				<span d:priority="2"> : <i>Mother made her a beautiful dress</i>
				</span>
				.
			</li>
			<li>
				Cause to be or become
				<span d:priority="2"> : <i>The news made me happy</i>
				</span>
				.
			</li>
		</ol>
	</div>
	<div d:parental-control="1" d:priority="2">
		<h3>PHRASES</h3>
		<div id="make_it"><b>make it</b> : succeed in something; survive.</div>
		<h4><a href="x-dictionary:r:make_up_ones_mind"><b>make up one's mind</b></a></h4>
	</div>
  </d:entry>
  END OF EXAMPLE! -->

  <xsl:template match="e">
    <d:entry d:title="{lg/l}">
      <xsl:attribute name="id">
	<xsl:variable name="attr_values">
	  <xsl:for-each select="lg/l/@*">
	    <xsl:text>_</xsl:text>
	    <xsl:value-of select="." />
	  </xsl:for-each>
	</xsl:variable>
	
	<xsl:value-of select="concat(lg/l, $attr_values)"/>
	
<!-- 	<xsl:value-of select="concat(lg/l, -->
<!-- 			      '_', -->
<!-- 			      lg/l/@pos, -->
<!-- 			      lg/l/@class -->
<!-- 			      )"/> -->

      </xsl:attribute>
      <xsl:if test="not(lg/paradigm/wordform) or lg/paradigm/wordform = '???'">
	<d:index d:value="{lg/l}"/>
      </xsl:if>
      <xsl:apply-templates select="lg/paradigm"/>
      <h1><xsl:value-of select="lg/l"/></h1>
      <!--       <h3><xsl:text>Ordklasse: </xsl:text><i><xsl:value-of select="myFn:mapPOS(lg/l/@pos)"/></i></h3> -->
      <h3>
      <table>
	<tr>
	  <td><i><xsl:value-of select="myFn:mapPOS(lg/l/@pos)"/></i></td>
	  <!-- 	  <td><xsl:text> </xsl:text></td> -->
	  <td>
	    <xsl:if test="(lg/l/@pos = 'v') and (lg/l/@class)">
	      <xsl:text> (</xsl:text>
	      <xsl:value-of select="lg/l/@class"/>
	      <xsl:text>) </xsl:text>
	    </xsl:if>
	  </td>
	</tr>
      </table>
      </h3>
      <div>
	<ol>
	  <xsl:apply-templates select="mg"/>
	</ol>
      </div>

      <div align="right">
	<img class="beta" src="Images/sme2nob_bg.jpg"/>
      </div>

    </d:entry>
  </xsl:template>
  
  <xsl:template match="paradigm">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="wordform">
    <d:index d:value="{.}"/>
  </xsl:template>
  
  <xsl:template match="mg"><li><xsl:apply-templates/></li></xsl:template>
  
  <xsl:template match="tg[not(last())]">; <xsl:apply-templates/></xsl:template>
  <xsl:template match="tg[last()]"><xsl:apply-templates/></xsl:template>
  
  <xsl:template match="t[1]"><bf><xsl:value-of select="normalize-space(.)"/></bf>
  </xsl:template>
  <xsl:template match="t[position() > 1]">, <br/><bf><xsl:value-of select="normalize-space(.)"/></bf>
  </xsl:template>
  
  <xsl:template match="xg">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="x">
    <br/>
    <i><b><small>
      <xsl:apply-templates/>
    </small></b></i>
  </xsl:template>
  
  <xsl:template match="xt">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>
