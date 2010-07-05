<?xml version="1.0" encoding="UTF-8"?>
<!--+

An XSLT2 script to convert gt-formatted dictionaries to the Apertium bidix
format.

Usage:
    xsl2 smanob/concatsrc/smanob.xml scripts/gtdict2apertium.xsl > OUT

Input:
   <e usage="more">
      <lg>
         <l pos="n">gudneáŋgirvuohta</l>
      </lg>
      <mg>
         <tg>
            <t pos="m">ambisjon</t>
            <t pos="f">ærgjerrighet</t>
         </tg>
      </mg>
   </e>

   <e usage="more">
      <lg>
         <l pos="n">heahtedilli</l>
      </lg>
      <mg>
         <tg>
            <t pos="f">krise</t>
         </tg>
         <tg>
            <t pos="m">nødssituasjon</t>
         </tg>
      </mg>
   </e>

Expected output:
    <e><p><l>ahki<s n="N"/></l><r>alder<s n="n"/><s n="m"/></r></p><par n="__n"/></e>
    <e><p><l>áhkká<s n="N"/></l><r>hustru<s n="n"/></r></p><par n="f_RL_m__n"/></e>
    <e slr="1"><p><l>áhkká<s n="N"/></l><r>kone<s n="n"/></r></p><par n="f_RL_m__n"/></e>
    <e><p><l>áhkku<s n="N"/></l><r>bestemor<s n="n"/></r></p><par n="f_RL_m__n"/></e>
    <e slr="1"><p><l>áhkku<s n="N"/></l><r>kjerring<s n="n"/></r></p><par n="f_RL_m__n"/></e>
    <e><p><l>áhpu<s n="N"/></l><r>nytte<s n="n"/></r></p><par n="m_RL_f__n"/></e>
    <e><p><l>áibmi<s n="N"/></l><r>synål<s n="n"/></r></p><par n="m_RL_f__n"/></e>
    <e><p><l>áibmu<s n="N"/></l><r>luft<s n="n"/></r></p><par n="m_RL_f__n"/></e>
    <e><p><l>áidi<s n="N"/></l><r>gjerde<s n="n"/><s n="nt"/></r></p><par n="__n"/></e>
    <e><p><l>áigi<s n="N"/></l><r>tid<s n="n"/></r></p><par n="m_RL_f__n"/></e>
    +-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      indent="yes"/> <!-- set this to 'no' when the script is working as it
	                          should to get output formatted as above. -->

<!-- Skip all licensing text: (or should we? It could be turned into a comment instead) -->
<xsl:template match="lics|lic|a|ref|sourcenote"/>

<xsl:template match="e"> <!-- [mg[1]/tg[1]/t[1]] -->
    <xsl:text>
</xsl:text>
    <xsl:for-each select="mg">
	    <xsl:for-each select="tg">
		    <xsl:for-each select="t">
    		    <e>
    		        <p>
    		            <l><xsl:value-of select="../../../lg/l"/><s n="{upper-case(../../../lg/l/@pos)}"/></l>
    		            <r><xsl:value-of select="."/><s n="{../../../lg/l/@pos}"/>
    		                <s n="{@pos}"/>
    		            </r>
    		        </p>
    		        <par n=""/>
    		    </e>
		    </xsl:for-each>
	    </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<!--xsl:template match="e[mg/tg/t[position() &gt; 1]]">
    <xsl:for-each select="mg">
	    <xsl:for-each select="tg">
		    <xsl:for-each select="t">
    		    <e slr="{.//t[position()] - 1}">
    		        <p>
    		            <l><xsl:value-of select="../../../lg/l"/><s n="{upper-case(../../../lg/l/@pos)}"/></l>
    		            <r><xsl:value-of select="."/><s n="{../../../lg/l/@pos}"/>
    		                <s n="{@pos}"/>
    		            </r>
    		        </p>
    		        <par n=""/>
    		    </e>
		    </xsl:for-each>
	    </xsl:for-each>
    </xsl:for-each>
</xsl:template-->

</xsl:stylesheet>
