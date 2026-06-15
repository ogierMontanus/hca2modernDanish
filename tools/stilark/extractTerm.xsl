<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
     xmlns:TEI="http://www.tei-c.org/ns/1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="3.0">
     <!-- 2017-05-05: Holger Berg
     2018-03-01: opdateret xsl:number, tilføjet attribut count-->

     
     <xsl:template match="TEI:TEI">
          <TEI><xsl:for-each select="//TEI:term[not(./text()=preceding::TEI:term/text())]">
               <term type="{@type}"><xsl:apply-templates select="./text()"/></term>
          <xsl:text>
</xsl:text></xsl:for-each>
     </TEI></xsl:template>

     

     
</xsl:stylesheet>