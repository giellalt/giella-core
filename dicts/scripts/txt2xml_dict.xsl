<?xml version="1.0"?>
<!--+
    | Transforms the NOB-data from text format into xml format
    | Only simple POSs are handled!
    | NB: An XSLT-2.0-processor is needed!
    | The input: NOB data in the given format
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it:main nobDB_txt2xml.xsl file="INPUT-FILE"
    | 
    +-->

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:fn="fn"
		xmlns:local="nightbar"
		exclude-result-prefixes="xs fn local">
    
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml"
	      omit-xml-declaration="no"
	      indent="yes"/>
  

<xsl:function name="local:distinct-deep" as="node()*">
  <xsl:param name="nodes" as="node()*"/> 
 
  <xsl:sequence select=" 
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(local:is-node-in-sequence-deep-equal(
                          .,$nodes[position() &lt; $seq]))]
 "/>
   
</xsl:function>

<xsl:function name="local:is-node-in-sequence-deep-equal" as="xs:boolean">
  <xsl:param name="node" as="node()?"/> 
  <xsl:param name="seq" as="node()*"/> 
 
  <xsl:sequence select=" 
   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 "/>
   
</xsl:function>


  <!--   Input file in text format: as parameter -->
  <xsl:param name="file" select="'/Usefullform_bm_u8.txt'"/>
  <xsl:param name="path" select="'.'"/>
  <xsl:param name="outputDir" select="'XML_out'"/>

  <!-- Patterns for the feature values -->
  <xsl:variable name="e" select="'xml'"/>
  <xsl:variable name="file_name" select="substring-before((tokenize($file, '/'))[last()], '.xml')"/>
  
  
  <xsl:template match="/" name="main">
    
    <xsl:variable name="result">
      <r>
<!-- 	<xsl:for-each select="doc($file)/r/e"> -->
<!-- 	  <xsl:copy-of select="."/> -->
<!-- 	</xsl:for-each> -->

	<xsl:for-each-group select="doc($file)/r/e" group-by=".">
	  <xsl:sort select="./lg/l" data-type="text" order="ascending"/>
	  <xsl:copy-of select="."/>
	</xsl:for-each-group>

      </r>
    </xsl:variable>
    

    <xsl:result-document href="{$outputDir}/{$file_name}.{$e}">
      <xsl:copy-of select="$result"/>
    </xsl:result-document>
    
  </xsl:template>
  
</xsl:stylesheet>

