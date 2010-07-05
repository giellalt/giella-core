<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      indent="yes"/>

<xsl:template match="lics|lic|a|ref|sourcenote"/>

<xsl:template match="e"> <!-- [mg[1]/tg[1]/t[1]] -->
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
