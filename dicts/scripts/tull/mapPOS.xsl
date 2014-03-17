<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:myFn="http://whatever">
  
  <xsl:output method="text"/>
  
  <xsl:function name="myFn:mapPOS">
    <xsl:param name="pos"/>
    
    <xsl:choose>
      <xsl:when test="contains($pos, '_dublu')">
	
	<xsl:variable name="ppooss" select="substring-before($pos, '_dublu')"/>

	<xsl:if test="lower-case(normalize-space($ppooss))='n'">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>

	<xsl:if test="lower-case(normalize-space($pos))='actor'">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='g3'">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
		
	<xsl:if test="lower-case(normalize-space($ppooss))='prop'">
	  <xsl:text>egennavn</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($ppooss))='a'">
	  <xsl:text>adj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($ppooss))='num'">
	  <xsl:text>num.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($ppooss))='v'">
	  <xsl:text>verb</xsl:text>
	</xsl:if>
	
      </xsl:when>
      
      <xsl:otherwise>
	
	<!--     nob mapping -->
	
	<xsl:if test="lower-case(normalize-space($pos))='x'">
	  <xsl:text>xxx</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='v'">
	  <xsl:text>verb</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='im'">
	  <xsl:text>infinitivsmerke</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='cs'">
	  <!--       <xsl:text>subjunksjon</xsl:text> -->
	  <xsl:text>subj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='cc'">
	  <!--       <xsl:text>konjunksjon</xsl:text> -->
	  <xsl:text>konj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='qu'">
	  <!--       <xsl:text>konjunksjon</xsl:text> -->
	  <xsl:text>qu.</xsl:text>
	</xsl:if>

	<xsl:if test="lower-case(normalize-space($pos))='clt'">
	  <!--       <xsl:text>konjunksjon</xsl:text> -->
	  <xsl:text>clt.</xsl:text>
	</xsl:if>

	<xsl:if test="lower-case(normalize-space($pos))='abbr'">
	  <!--       <xsl:text>konjunksjon</xsl:text> -->
	  <xsl:text>forkort.</xsl:text>
	</xsl:if>

	<xsl:if test="lower-case(normalize-space($pos))='interj'">
	  <!--       <xsl:text>interjeksjon</xsl:text> -->
	  <xsl:text>interj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron'">
	  <!--       <xsl:text>pronomen</xsl:text> -->
	  <xsl:text>pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pr'">
	  <!--       <xsl:text>preposisjon</xsl:text> -->
	  <xsl:text>prep.</xsl:text>
	</xsl:if>

	<xsl:if test="lower-case(normalize-space($pos))='po'">
	  <!--       <xsl:text>postposisjon</xsl:text> -->
	  <xsl:text>postp.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case((normalize-space($pos))='pcle'">
	  <!--       <xsl:text>partikkel</xsl:text> -->
	  <xsl:text>part.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='num'">
	  <!--       <xsl:text>tallord</xsl:text> -->
	  <xsl:text>num.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='adv'">
	  <!--       <xsl:text>adverb</xsl:text> -->
	  <xsl:text>adv.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='n'">
	  <!--       <xsl:text>substantiv (fellesnavn; intetkjønn)</xsl:text> -->
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='a'">
	  <xsl:text>adj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron_pers'">
	  <xsl:text>pers. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron_refl'">
	  <xsl:text>refl. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron_rel'">
	  <xsl:text>rel. pron.</xsl:text>
	</xsl:if>

	<xsl:if test="lower-case(normalize-space($pos))='pers'">
	  <xsl:text>pers.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='refl'">
	  <xsl:text>refl.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='rel'">
	  <xsl:text>rel.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='recipr'">
	  <xsl:text>resipr.</xsl:text>
	</xsl:if>

	<xsl:if test="lower-case(normalize-space($pos))='interr'">
	  <xsl:text>spørrepron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='dem'">
	  <xsl:text>påpek.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='actor'">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='g3'">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>

	<!--     sme mapping -->
	
	<xsl:if test="lower-case(normalize-space($pos))='x_sme'">
	  <xsl:text>xxx</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='v_sme'">
	  <xsl:text>verb</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='im_sme'">
	  <xsl:text>infinitivsmerke</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='cs_sme'">
	  <xsl:text>subj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='cc_sme'">
	  <xsl:text>konj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='i_sme'">
	  <xsl:text>interj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron_sme'">
	  <xsl:text>pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pcle_sme'">
	  <xsl:text>part.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='num_sme'">
	  <xsl:text>num.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='adv_sme'">
	  <xsl:text>adv.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='prop_sme'">
	  <xsl:text>egennavn</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='a_sme'">
	  <xsl:text>adj.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='n_sme'">
	  <xsl:text>subst.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pr_sme'">
	  <xsl:text>prep.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='po_sme'">
	  <xsl:text>postp.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron_pers_sme'">
	  <xsl:text>pers. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron_refl_sme'">
	  <xsl:text>refl. pron.</xsl:text>
	</xsl:if>
	
	<xsl:if test="lower-case(normalize-space($pos))='pron_rel_sme'">
	  <xsl:text>rel. pron.</xsl:text>
	</xsl:if>
	
      </xsl:otherwise>

    </xsl:choose>
    
  </xsl:function>
  
</xsl:stylesheet>
