<?xml version="1.0"?>
<!--+
    | 
    | The parameter: language pair, and date
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main generate_infofile.xsl S_LANG=LANG T_LANG=LANG DATE=DATE
    | 
    +-->



<!-- java -Xmx2048m net.sf.saxon.Transform -it:main generate_infofile.xsl S_LANG=sme T_LANG=nob DATE=20090121 -->



<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
    xmlns:myFct="nightbar"
    exclude-result-prefixes="xs myFct">

  <xsl:import href="mapLang.xsl"/>

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      encoding="UTF-8"
	      omit-xml-declaration="no"
	      doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"
	      doctype-public="-//Apple//DTD PLIST 1.0//EN"
	      indent="yes"/>
  
  <xsl:param name="S_LANG" select="'xxx'"/>
  <xsl:param name="T_LANG" select="'xxx'"/>
  <xsl:param name="DATE" select="'20081213'"/>
  <xsl:variable name="DAY" select="substring($DATE,7)"/>
  <xsl:variable name="MONTH" select="substring($DATE,5,2)"/>
  <xsl:variable name="YEAR" select="substring($DATE,1,4)"/>
  <xsl:variable name="COPYRIGHT" select="'Sámi giellatekno and Sámediggi'"/>
  <xsl:variable name="MANUFACTURER" select="'Sámi giellatekno'"/>
  <xsl:variable name="dictID" select="concat('no.divvun.dictionary.', $S_LANG, $T_LANG, 'Dictionary')"/>
  <xsl:variable name="dictCSS" select="concat($S_LANG, $T_LANG, 'Dictionary.css')"/>
  <xsl:variable name="dictXSL" select="concat($S_LANG, $T_LANG, 'Dictionary.xsl')"/>
  <xsl:variable name="dictPREFS" select="concat($S_LANG, $T_LANG, 'Dictionary_prefs.html')"/>


  
  <xsl:template match="/" name="main">

    <plist version="1.0">
      <dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleIdentifier</key>
	<string>
	  <xsl:value-of select="$dictID"/>
	</string>
	<key>CFBundleDisplayName</key>
	<string>
	  <xsl:value-of select="concat(myFct:capitalize-first(myFct:mapLang($S_LANG)), '-', myFct:mapLang($T_LANG), ' ordbok', ' (Versjon ', $DAY, '.', $MONTH, '.', $YEAR, ')')"/>
	</string>
	<key>CFBundleName</key>
	<string>
	  <xsl:value-of select="concat(upper-case($S_LANG), '&gt;', upper-case($T_LANG))"/>
	</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>DCSDictionaryCopyright</key>
	<string>
	  <xsl:value-of select="concat('Copyright © ', $YEAR, ' ', $COPYRIGHT)"/>
	</string>
	<key>DCSDictionaryManufacturerName</key>
	<string>
	  <xsl:value-of select="$MANUFACTURER"/>
	</string>
	<key>DCSDictionaryPrefsHTML</key>
	<string>
	  <xsl:value-of select="$dictPREFS"/>
	</string>
	<key>DCSDictionaryXSL</key>
	<string>
	  <xsl:value-of select="$dictXSL"/>
	</string>
	<key>DCSDictionaryDefaultPrefs</key>
	<dict>
	  <key>pronunciation</key>
	  <string>0</string>
	  <key>display-column</key>
	  <string>1</string>
	  <key>display-picture</key>
	  <string>1</string>
	  <key>version</key>
	  <string>1</string>
	</dict>
      </dict>
    </plist>
    
  </xsl:template>
  
</xsl:stylesheet>
