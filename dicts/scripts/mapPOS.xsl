<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:myFn="http://whatever">
  
  <xsl:output method="text"/>
  
  <xsl:function name="myFn:mapPOS">
    <xsl:param name="pos"/>

    
    
    <xsl:choose>
      <xsl:when test="contains($pos, '_dublu')">
	
	<xsl:variable name="ppooss" select="substring-before($pos, '_dublu')"/>

	<xsl:if test="(normalize-space($ppooss)='n')">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($ppooss)='prop')">
	  <xsl:text>egennavn</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($ppooss)='a')">
	  <xsl:text>adj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($ppooss)='num')">
	  <xsl:text>num.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($ppooss)='v')">
	  <xsl:text>verb</xsl:text>
	</xsl:if>
	
      </xsl:when>
      
      <xsl:otherwise>
	
	<!--     nob mapping -->
	
	<xsl:if test="(normalize-space($pos)='x')">
	  <xsl:text>xxx</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='v')">
	  <xsl:text>verb</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='im')">
	  <xsl:text>infinitivsmerke</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='cs')">
	  <!--       <xsl:text>subjunksjon</xsl:text> -->
	  <xsl:text>subj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='cc')">
	  <!--       <xsl:text>konjunksjon</xsl:text> -->
	  <xsl:text>konj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='i')">
	  <!--       <xsl:text>interjeksjon</xsl:text> -->
	  <xsl:text>interj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron')">
	  <!--       <xsl:text>pronomen</xsl:text> -->
	  <xsl:text>pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='p')">
	  <!--       <xsl:text>preposisjon</xsl:text> -->
	  <xsl:text>prep.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pcle')">
	  <!--       <xsl:text>partikkel</xsl:text> -->
	  <xsl:text>part.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='num')">
	  <!--       <xsl:text>tallord</xsl:text> -->
	  <xsl:text>num.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='adv')">
	  <!--       <xsl:text>adverb</xsl:text> -->
	  <xsl:text>adv.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='S')">
	  <!--       <xsl:text>substantiv (fellesnavn; kjønn: xxx)</xsl:text> -->
	  <xsl:text>subst. xxx</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='n')">
	  <!--       <xsl:text>substantiv (fellesnavn; intetkjønn)</xsl:text> -->
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='f')">
	  <!--       <xsl:text>subst. (fellesn.; hunkjønn)</xsl:text> -->
	  <xsl:text>subst. f</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='m')">
	  <!--       <xsl:text>substantiv (fellesnavn; hankjønn)</xsl:text> -->
	  <xsl:text>subst. m</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='prop')">
	  <xsl:text>egennavn</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='npl')">
	  <xsl:text>egennavn</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='a')">
	  <xsl:text>adj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pr')">
	  <xsl:text>prep.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='po')">
	  <xsl:text>postp.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron_pers')">
	  <xsl:text>pers. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron_refl')">
	  <xsl:text>refl. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron_rel')">
	  <xsl:text>rel. pron.</xsl:text>
	</xsl:if>
	
	<!--     sme mapping -->
	
	<xsl:if test="(normalize-space($pos)='x_sme')">
	  <xsl:text>xxx</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='v_sme')">
	  <xsl:text>verb</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='im_sme')">
	  <xsl:text>infinitivsmerke</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='cs_sme')">
	  <xsl:text>subj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='cc_sme')">
	  <xsl:text>konj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='i_sme')">
	  <xsl:text>interj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron_sme')">
	  <xsl:text>pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pcle_sme')">
	  <xsl:text>part.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='num_sme')">
	  <xsl:text>num.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='adv_sme')">
	  <xsl:text>adv.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='prop_sme')">
	  <xsl:text>egennavn</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='a_sme')">
	  <xsl:text>adj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='n_sme')">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pr_sme')">
	  <xsl:text>prep.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='po_sme')">
	  <xsl:text>postp.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron_pers_sme')">
	  <xsl:text>pers. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron_refl_sme')">
	  <xsl:text>refl. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="(normalize-space($pos)='pron_rel_sme')">
	  <xsl:text>rel. pron.</xsl:text>
	</xsl:if>
	
      </xsl:otherwise>

    </xsl:choose>
    
  </xsl:function>
  
</xsl:stylesheet>