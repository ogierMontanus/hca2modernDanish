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
     
     <xsl:template match="TEI:body//TEI:div/(TEI:p|TEI:seg|TEI:head)/text()"><!--2023-08-17: removed |TEI:l-->
          <xsl:analyze-string select="substring(.,1,1)" regex="\w"><xsl:matching-substring><xsl:value-of select="upper-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string>
          <xsl:copy-of select="substring(.,2,10000000000000000)"/>
     </xsl:template>

     <xsl:template match="TEI:body//TEI:l/text()"><!--2023-08-17: added template-->
          <xsl:analyze-string select="substring(.,1,1)" regex="\w"><xsl:matching-substring><xsl:value-of select="upper-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string>
          <xsl:copy-of select="substring(.,2,10000000000000000)"/>
     </xsl:template>
     
     
          
     
</xsl:stylesheet>