<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
     xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:TEI="http://www.tei-c.org/ns/1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="3.0"
     >
     <xsl:output indent="yes"/><!--
           use-character-maps="SV2HCAMSmap"
          suppress-indentation="" b, i, osv.
     use-character-maps
          brug >> til unicode mv.
     -->
     
     
     <xsl:template match="TEI:TEI">
          
          <!--<xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href=""</xsl:processing-instruction>-->
          <xsl:processing-instruction name="xml-model">type="application/relax-ng-compact-syntax" href="https://beta.auh.sdu.dk/pmm-skema/sv18.rnc"</xsl:processing-instruction>
          <xsl:variable name="originalDanishVersion" select="concat(current()//TEI:notesStmt/TEI:note[@type='originalDanish']/@target,'.xml')"/>
          <!--<xsl:variable name="originalDanishVersion" select="document('file:/C:/Users/nh/Documents/GitHub/SV2modern/mergeModernHeaderOriginal')"/>-->
          <!--<xsl:variable name="originalDanishVersion" select="document(concat(tokenize(base-uri(), '/')[last()-1], '/originalDanishVersion/', //TEI:notesStmt/TEI:note[@type='originalDanish']/@target=current()/preceding::TEI:note[@type='originalDanish']/@target, '.xml'))"/>-->
          
          <!--<xsl:variable name="originalDanishVersion" select="document(concat(tokenize(base-uri(), '/')last()-1],'/originalDanishVersion/',//TEI:notesStmt/TEI:note[@type='originalDanish']/@target,'.xml'))//TEI:author"/>-->
          <!--substring-before(tokenize(base-uri(), '/')[last()],'_modern.xml')-->
          
          <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xml:lang="da" xml:space="preserve">
<!--teiHeader begins-->
                         <teiHeader>
                                   <fileDesc>
                                        <titleStmt>
                                             <title><xsl:value-of select="//TEI:titleStmt/TEI:title"/></title>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:author"/>
                                             <xsl:for-each select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:titleStmt//TEI:editor[not(@type='orthography')]">
<xsl:copy-of select="."/>
</xsl:for-each>
<editor role="orthography">Andrea Steengaard</editor>
<editor role="orthography">Finn Gredal Jensen</editor>
                                        </titleStmt>
                                        <publicationStmt>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:publicationStmt//TEI:publisher"/>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:availability"/>
<xsl:copy-of select="//TEI:titleStmt//TEI:idno"/>
                                             <xsl:copy-of select="//TEI:publicationStmt//TEI:idno"/>
                                             <date>2024-10-02</date>
                                             <!--udgivelsesdato-->
                                        </publicationStmt>
                                        <sourceDesc>
                                             <listBibl>
<xsl:copy-of select="//TEI:sourceDesc//TEI:bibl"/>
<xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:biblStruct"/>
</listBibl>
<xsl:copy-of select="//TEI:sourceDesc//TEI:notesStmt"/>
                                             
                                        </sourceDesc>
                                        <xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:teiHeader//TEI:encodingDesc"/>
<xenoData>
<!--<xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:teiHeader//TEI:xenoData"/>-->
            <xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:teiHeader//TEI:xenoData/TEI:idno[1]"/>
<xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:teiHeader//TEI:xenoData/TEI:incipit[1]"/>
<xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:teiHeader//TEI:xenoData/TEI:readingTime[1]"/>                            
<xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:teiHeader//TEI:xenoData/TEI:popularity[1]"/>
</xenoData>

                                   </fileDesc>
                                   <profileDesc>
<xsl:copy-of select="//TEI:creation"/>
<xsl:copy-of select="//TEI:textClass"/>
<xsl:copy-of select="//TEI:table[@type='TOC']"/>
<!--<xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:teiHeader//TEI:profileDesc/child::*[not(TEI:table)]"/>-->

</profileDesc>
                                   <revisionDesc>
                                        <xsl:copy-of select="//TEI:teiHeader//TEI:change"/>
                                        <change who="NHB" when="{format-date(current-date(),'[Y0001]-[M01]-[D01]')}">revised teiHeader for publication in the sv-app</change>
                                   </revisionDesc>
                              </teiHeader>
                                                  
                         
                         <text type="print">
                              <xsl:copy-of select="//TEI:body"/>
</text>
<xsl:copy-of select="document(concat('originalDanishVersion/',$originalDanishVersion))//TEI:standOff"></xsl:copy-of>
                    <!--<xsl:copy-of select="$originalDanishVersion//TEI:teiHeader[descendant::TEI:note[@type='originalDanish']/@target=current()/preceding::TEI:note[@type='originalDanish']/@target]/following::TEI:standOff"/>-->
</TEI>
     </xsl:template>    
</xsl:stylesheet>