<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
    xmlns:myFct="nightbar"
    exclude-result-prefixes="xs myFct">
  
  <xsl:output method="text"/>
  
  <xsl:function name="myFct:mapLang">
    <xsl:param name="lang"/>

	<!--     language code mapping -->
	
	<xsl:if test="(normalize-space($lang)='sme')">
	  <xsl:text>nordsamisk</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($lang)='sma')">
	  <xsl:text>sørsamisk</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($lang)='nob')">
	  <xsl:text>norsk</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($lang)='swe')">
	  <xsl:text>svensk</xsl:text>
	</xsl:if>
	
  </xsl:function>

<xsl:function name="myFct:capitalize-first" as="xs:string?">
  <xsl:param name="arg" as="xs:string?"/> 
 
  <xsl:sequence select=" 
   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 "/>
   
</xsl:function>
  
</xsl:stylesheet>
