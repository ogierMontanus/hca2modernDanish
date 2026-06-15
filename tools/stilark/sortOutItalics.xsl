<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
     xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:TEI="http://www.tei-c.org/ns/1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="3.0"
     >
     <!-- 2017-05-05: Holger Berg
     2018-03-01: opdateret xsl:number, tilføjet attribut count-->
     
     
     
     <xsl:template match="/">
          <xsl:comment>
               words</xsl:comment>
          <xsl:text>[</xsl:text>
          
               <xsl:for-each select="//TEI:term[@type='word']"><!-- test for highlighted words -->
                    <xsl:text>codepoint-equal(.,'</xsl:text><xsl:value-of select="."/><xsl:text>') or </xsl:text>
               </xsl:for-each>
                    <xsl:text>]
                    </xsl:text>
          <xsl:comment>
               latin terms</xsl:comment>
          <xsl:text>[</xsl:text>
          
          <xsl:for-each select="//TEI:term[@type='latin']"><!-- test for highlighted words -->
               <xsl:text>codepoint-equal(.,'</xsl:text><xsl:value-of select="."/><xsl:text>') or </xsl:text>
          </xsl:for-each>
          <xsl:text>]
          </xsl:text>          
          
          <xsl:comment>
               abstract terms and named entities</xsl:comment>
          <xsl:text>[</xsl:text>
          
               <xsl:for-each select="//TEI:term[@type='abstract' or @type='namedEntity']"><!-- test for highlighted words -->
                    <xsl:text>codepoint-equal(.,'</xsl:text><xsl:value-of select="."/><xsl:text>') or </xsl:text>
               </xsl:for-each>
          <xsl:text>]
          </xsl:text>
          <xsl:comment>
               ONLY named entities - for xslt toLowerCase</xsl:comment>
          <xsl:text>(</xsl:text>
          
          <xsl:for-each select="//TEI:term[@type='namedEntity']"><!-- test for highlighted words -->
               <xsl:value-of select="."/><xsl:text>|</xsl:text>
          </xsl:for-each>
          <xsl:text>)</xsl:text>
     

          <xsl:text>not(codepoint-equal(</xsl:text><xsl:for-each select="//TEI:description"><!-- test for highlighted words --><xsl:text>(regex-group(2),'</xsl:text><xsl:value-of select="lower-case(.)"/><xsl:text>') or </xsl:text><xsl:text></xsl:text></xsl:for-each><xsl:text>)</xsl:text>


          <xsl:comment>
               noItalics, i.e. speaking entities that do not qualify as proper nouns. The list currently excludedes titles: Kammerraaden, Generalen, Greven, etc.</xsl:comment>
          <xsl:text>[</xsl:text>
          
          <xsl:for-each select="//TEI:term[@type='noItalics']"><!-- test for highlighted words -->
               <xsl:text>codepoint-equal(.,'</xsl:text><xsl:value-of select="."/><xsl:text>') or </xsl:text>
          </xsl:for-each>
          <xsl:text>]
          </xsl:text>
          <xsl:comment>
               ONLY named entities - for xslt toLowerCase</xsl:comment>
          <xsl:text>(</xsl:text>
     </xsl:template>


     
     
     
</xsl:stylesheet>