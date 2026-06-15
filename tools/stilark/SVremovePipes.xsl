<?xml version="1.0" encoding="UTF-8"?>
<!-- 2013.02.08 -->
<!--2014-10-31 NHB opdateret-->
<!--NHB: 2023-01-31 opdateret NHB-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0">


     <xsl:output use-character-maps="removePipes"/>
     
     
     <xsl:character-map name="removePipes">
        <!--a-->
        <xsl:output-character character="|" string=""/>
         
    </xsl:character-map>
    
     <xsl:template match="node() | @*">
          <!--includes elements that are not matched by the following xsl-templates-->
          <xsl:copy>
               <xsl:apply-templates select="node() | @*"/>
          </xsl:copy>
          
     </xsl:template>
</xsl:stylesheet>