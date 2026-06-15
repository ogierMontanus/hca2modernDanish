<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
     xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:TEI="http://www.tei-c.org/ns/1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="3.0"
     >
     <!-- 2017-05-05: Holger Berg
     2018-03-01: opdateret xsl:number, tilføjet attribut count-->
     
     <xsl:template match="node()|@*">
          <xsl:copy>
               <xsl:apply-templates select="node()|@*"/>
          </xsl:copy>
     </xsl:template>     
     
     <xsl:template match="TEI:body//TEI:div/(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
          <xsl:analyze-string select="." regex="(([\.\?!:]\s(–\s)?(»{{1,2}}|–\s)?.)|(–!«\s[a-z|ø|æ|å])|(\.«\s(–\s)?)[a-z|ø|æ|å]|([\?!:]«\s(–\s)?[a-i|k-p|u-z|ø|æ|å]))"><xsl:matching-substring><xsl:value-of select="upper-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string><!--the last regex avoids the letters, which are most frequent in verbs: j,r,s. This part is experimental-->
          <!--<xsl:copy-of select="."/>-->
     </xsl:template>

     <!--<xsl:template match="TEI:body//TEI:div/(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
          <xsl:analyze-string select="." regex="(» (Klang|Udbrød|Hvisk))"><xsl:matching-substring><xsl:value-of select="lower-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="upper-case(.)"/></xsl:non-matching-substring></xsl:analyze-string><!-\-the last regex avoids the letters, which are most frequent in verbs: j,r,s. This part is experimental-\->
          <!-\-<xsl:copy-of select="."/>-\->
     </xsl:template>-->

     
     
     <!--<xsl:template match="TEI:body//TEI:div/TEI:p/text()">
          <xsl:analyze-string select="substring(.,1,2)" regex="»\w"><xsl:matching-substring><xsl:value-of select="upper-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string>
          <xsl:copy-of select="substring(.,3,10000000000000000)"/>
     </xsl:template>-->
     <!--<xsl:template match="TEI:p/text()"><xsl:copy-of select="upper-case(substring(.,1,1))"/><xsl:copy-of select="substring(.,2,10000000000000000)"/></xsl:template>-->
     
     
     <!--
          2023-07-02: add new template
          upper-case for first character in TEI:p, TEI:lg/l[1] TEI:head
          reuse xslt SVaddInitial-->
     
     <!--  -->
     
          
     
</xsl:stylesheet>