<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
     xmlns:TEI="http://www.tei-c.org/ns/1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="3.0">
     
     
     <xsl:template match="/">
          <TEI><xsl:for-each select="//TEI:pattern">
               <xsl:text>&lt;xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    &lt;xsl:analyze-string select="." regex="</xsl:text><xsl:value-of select="./TEI:old"/><xsl:text>">
                         &lt;xsl:matching-substring>
                         &lt;xsl:text></xsl:text><xsl:value-of select="./TEI:new"/><xsl:text>&lt;/xsl:text>&lt;/xsl:matching-substring>
                         &lt;xsl:non-matching-substring>
                         &lt;xsl:value-of select="."/>&lt;/xsl:non-matching-substring>
                    &lt;/xsl:analyze-string>
                    &lt;/xsl:template></xsl:text>
               
          </xsl:for-each>
     </xsl:template>

     

     
</xsl:stylesheet>