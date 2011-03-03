<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:myFn="http://whatever">
  
  <xsl:output method="text"/>
  
  <xsl:function name="myFn:mapMORPH">
    <xsl:param name="pos"/>

    <!--     nob mapping -->
    
    <!--     <xsl:variable name="analysis" select="tokenize($pos, '&#xa;')" as="xs:string+"/> -->


    <xsl:variable name="descr">
      
      <xsl:for-each select="tokenize($pos, '_')">
		
	<xsl:if test="(normalize-space(.)='Der/PassL')">
	  <xsl:text>pass. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Der/PassS')">
	  <xsl:text>pass. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Sg')">
	  <xsl:text>sg. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Pl')">
	  <xsl:text>pl. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Actio')">
	  <xsl:text>aktio </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Ess')">
	  <xsl:text>ess. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Gen')">
	  <xsl:text>gen. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Nom')">
	  <xsl:text>nom. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Acc')">
	  <xsl:text>akk. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Ill')">
	  <xsl:text>ill. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Loc')">
	  <xsl:text>lok. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Com')">
	  <xsl:text>kom. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Ine')">
	  <xsl:text>ine. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='Ela')">
	  <xsl:text>ela. </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxSg1')">
	  <xsl:text>(poss. 1p. sg.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxSg2')">
	  <xsl:text>(poss. 2p. sg.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxSg3')">
	  <xsl:text>(poss. 3p. sg.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxDu1')">
	  <xsl:text>(poss. 1p. dl.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxDu2')">
	  <xsl:text>(poss. 2p. dl.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxDu3')">
	  <xsl:text>(poss. 3p. dl.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxPl1')">
	  <xsl:text>(poss. 1p. pl.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxPl2')">
	  <xsl:text>(poss. 2p. pl.) </xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space(.)='PxPl3')">
	  <xsl:text>(poss. 3p. pl.) </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Comp')">
	  <xsl:text>komp. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Superl')">
	  <xsl:text>superl. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Attr')">
	  <xsl:text>attr. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Pred')">
	  <xsl:text>pred. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Pass')">
	  <xsl:text>pass. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Ind')">
	  <xsl:text>indik. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Pot')">
	  <xsl:text>pot. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Cond')">
	  <xsl:text>kond. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Imprt')">
	  <xsl:text>imper. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Prs')">
	  <xsl:text>pres. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Prt')">
	  <xsl:text>pret. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Sg1')">
	  <xsl:text>1p. sg. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Sg2')">
	  <xsl:text>2p. sg. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Sg3')">
	  <xsl:text>3p. sg. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Du1')">
	  <xsl:text>1p. dl. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Du2')">
	  <xsl:text>2p. dl. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Du3')">
	  <xsl:text>3p. dl. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Pl1')">
	  <xsl:text>1p. pl. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Pl2')">
	  <xsl:text>2p. pl. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Pl3')">
	  <xsl:text>3p. pl. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='ConNeg')">
	  <xsl:text>neg. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Neg')">
	  <xsl:text>neg. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Sup')">
	  <xsl:text>sup. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Der/Pass')">
	  <xsl:text>deriv. pass. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='Inf')">
	  <xsl:text>inf. </xsl:text>
	</xsl:if>

<!-- http://giellatekno.uit.no/doc/lang/sme/docu-sme-grammartags.html -->
<!-- 	<xsl:if test="(normalize-space(.)='Act')"> -->
<!-- 	  <xsl:text>not yet documented </xsl:text> -->
<!-- 	</xsl:if> -->

	<xsl:if test="(normalize-space(.)='Ger')">
	  <xsl:text>ger. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='PrsPrc')">
	  <xsl:text>part. pres. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='PrfPrc')">
	  <xsl:text>part. perf. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='VGen')">
	  <xsl:text>gen. v. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='VAbess')">
	  <xsl:text>abbes. v. </xsl:text>
	</xsl:if>

	<xsl:if test="(normalize-space(.)='xxx')">
	  <xsl:text> </xsl:text>
	</xsl:if>


	
      </xsl:for-each>
      
    </xsl:variable>

    <xsl:copy-of select="normalize-space($descr)"/>
    
  </xsl:function>
  
</xsl:stylesheet>

