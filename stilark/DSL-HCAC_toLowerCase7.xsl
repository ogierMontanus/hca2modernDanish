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
          <xsl:analyze-string select="substring(.,1,4)" regex="»–\s\w"><xsl:matching-substring><xsl:value-of select="upper-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string>
          <xsl:copy-of select="substring(.,5,10000000000000000)"/>
     </xsl:template>
     
     
     
     
     
     <!--<xsl:variable name="upperCaseElements" select="(TEI:p|TEI:seg|TEI:l|TEI:head)"/>-->
     
     
     <!--
          2023-07-02: add new template
          upper-case for first character in TEI:p, TEI:lg/l[1] TEI:head
          reuse xslt SVaddInitial-->
     
     <!--  -->
     
          
     
</xsl:stylesheet>