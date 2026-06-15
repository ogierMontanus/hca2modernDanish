<xsl:stylesheet 
     xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:TEI="http://www.tei-c.org/ns/1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="3.0"
     >
     <xsl:output indent="yes"/>
     <xsl:output method="xml" indent="yes"/>
     <xsl:param name="inputFileName" select="concat(current()//TEI:notesStmt/TEI:note[@type='originalDanish']/@target,'.xml')"/>
     
     <!-- Identity transform to copy all nodes -->
     <xsl:template match="@*|node()">
          <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
     </xsl:template>
     
     <!-- Append <standOff> from the corresponding file in the "copy" folder -->
     <xsl:template match="/*">
          <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
               <!--<xsl:variable name="copyFilePath" select="concat('/originalDanishVersion/', $inputFileName)"/>-->
               <xsl:apply-templates select="document(concat('originalDanishVersion/',$inputFileName))//TEI:standOff"/>
          </xsl:copy>
     </xsl:template>
</xsl:stylesheet>
