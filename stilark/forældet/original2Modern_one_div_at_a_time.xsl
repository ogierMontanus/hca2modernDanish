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
          
          <xsl:choose></xsl:choose>
          <xsl:result-document href="{format-date(current-date(),'[Y0001]-[M01]-[D01]')}opdateringTilIndexHTML.html" method="html">
               <!--add wrapper-tag-->
                    <html>
                         <xsl:for-each select="(//TEI:div[@type='workPart']|//TEI:floatingText[@xml:id])">
                         <item>
                              <title xml:lang="da"><xsl:value-of select="./@rend"/></title>
                              <xsl:if test="//TEI:catRef/@target='tale'">
                                   <title xml:lang="da" id="modernDanish"><xsl:value-of select="@rend"/><xsl:text>_modern</xsl:text></title>
                                   <title xml:lang="eng" id="Irons"><xsl:text>add English title from index to translation by John Irons</xsl:text></title>
                              </xsl:if>
                              <xsl:call-template name="date"/>
                              <!--<date><xsl:choose>
                                   <xsl:when test="preceding-sibling::TEI:div[@type='source']"><xsl:value-of select="preceding-sibling::TEI:div[@type='source']/TEI:sourceDate"/></xsl:when>
                                   <xsl:when test="parent::TEI:div[@type='source']"><xsl:value-of select="parent::TEI:div[@type='source']/TEI:sourceDate"/></xsl:when>
                                   <xsl:when test=".//TEI:sourceDate|.//TEI:docDate[not(@when)]">
                                        <xsl:value-of select=".//TEI:sourceDate|.//TEI:docDate[not(@when)]"/></xsl:when>
                                   <xsl:when test=".//TEI:docDate[@when]"><xsl:value-of select=".//TEI:docDate/@when"/></xsl:when>
                                   <xsl:otherwise>DATO MANGLER I XML-FILEN med bindene</xsl:otherwise>
                              </xsl:choose>
                              </date>-->    
                              <catRef target="{//TEI:catRef/@target}"/>
                              <idno type="SV"><xsl:value-of select="ancestor::TEI:div[@type='work']/@xml:id"/><xsl:text>.html#</xsl:text><xsl:value-of select="./@xml:id"/></idno>
                         </item>
                         
                    </xsl:for-each></html>
               
          </xsl:result-document>
          <xsl:result-document href="{format-date(current-date(),'[Y0001]-[M01]-[D01]')}opdateringTilIndexXML.xml" method="xml">
               <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="(//TEI:div[@type='work' or @type='workPart']|//TEI:floatingText[@xml:id])">
                    <item>
                         <title xml:lang="da"><xsl:if test="(TEI:div[@type='work'])"><xsl:attribute name="rend">hashtag</xsl:attribute></xsl:if><xsl:value-of select="./@rend"/></title>
                         <!--2023-05-05: hashtag virker endnu ikke efter hensigten-->
                         <xsl:if test="//TEI:catRef/@target='tale'">
                              <title xml:lang="da" id="modernDanish"><xsl:value-of select="@rend"/><xsl:text>_modern</xsl:text></title>
                              <title xml:lang="eng" id="Irons"><xsl:text>add English title from index to translation by John Irons</xsl:text></title>
                         </xsl:if>
                         <xsl:call-template name="date"/>
                         <catRef target="{//TEI:catRef/@target}"/>
                         <idno type="SV"><xsl:value-of select="@xml:id"/></idno>
                         <ref type="prefix">https://hcams.andersen.sdu.dk/exist/apps/sv/api/document/works%252F</ref>
                         <ref type="suffix-xml">/xml</ref>
                         <ref type="suffix-html">/html</ref>
                         <ref type="suffix-pdf">/pdf</ref>
                         <ref type="suffix-epub">/pdf</ref>
                         <!--<date><xsl:choose>
                              <xsl:when test="preceding-sibling::TEI:div[@type='source']"><xsl:value-of select="preceding-sibling::TEI:div[@type='source']/TEI:sourceDate"/></xsl:when>
                              <xsl:when test="parent::TEI:div[@type='source']"><xsl:value-of select="parent::TEI:div[@type='source']/TEI:sourceDate"/></xsl:when>
                              <xsl:when test=".//TEI:sourceDate|.//TEI:docDate[not(@when)]">
                                   <xsl:value-of select=".//TEI:sourceDate|.//TEI:docDate[not(@when)]"/></xsl:when>
                              <xsl:when test=".//TEI:docDate[@when]"><xsl:value-of select=".//TEI:docDate/@when"/></xsl:when>
                              <xsl:otherwise>DATO MANGLER I XML-FILEN med bindene</xsl:otherwise>
                         </xsl:choose>
                         </date>-->
                              <!--<xsl:value-of select="//TEI:div[@type='work-comments' and contains(@xml:id, current()/@xml:id)]/TEI:p[position()=1]/TEI:date"/>-->
                    </item>
                    
               </xsl:for-each>
               </TEI>
          </xsl:result-document>
          
               <xsl:for-each select="//TEI:div[@type='work']">
               
               <xsl:result-document href="extract{format-date(current-date(),'[Y0001]-[M01]-[D01]')}/{@xml:id}.xml" method="xml">
                    <!--<xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href=""</xsl:processing-instruction>-->
                    <xsl:processing-instruction name="xml-model">type="application/relax-ng-compact-syntax" href="../css/sv18.rnc"</xsl:processing-instruction><!--type="application/relax-ng-compact-syntax" href="https://beta.auh.sdu.dk/pmm-skema/sv18.rnc"-->
                    
                    <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xml:lang="da" xml:space="preserve">
<!--teiHeader begins-->
                         
                              <teiHeader>
                                   <fileDesc>
                                        <titleStmt>
                                             <title><xsl:value-of select="@rend"/></title>
                                             <author ref="http://viaf.org/viaf/4925902">H.C. Andersen</author>
                                             <xsl:for-each select="//TEI:div[@type='credits']//TEI:persName"><editor role="content"><xsl:value-of select="."/></editor></xsl:for-each>
                                             <editor role="data">Dan H. Andreasen</editor>
                                             <editor role="data">Holger Berg</editor>
                                        </titleStmt>
                                        <publicationStmt>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:publisher"/>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:availability"/>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:idno"/>
                                             <date>2024-04-01</date>
                                             <!--udgivelsesdato-->
                                        </publicationStmt>
                                        <sourceDesc>
                                             <listBibl>
                                                  <bibl>
                                                             
      <xsl:copy-of select="//TEI:div[@type='work-comments' and contains(@xml:id, current()/@xml:id)]/TEI:p[position()=1]"/>    
      </bibl>
                                                  <biblStruct>
                                                  <monogr>
                                                       <title level="m">ANDERSEN: H.C. Andersens Samlede Værker</title>
                                                       <editor ref="http://viaf.org/viaf/4925902">
                                                            <publisher>Det Danske Sprog- og Litteraturselskab</publisher>
                                                            <persName>
                                                                 <forename>Klaus</forename>
                                                                 <forename full="init">P.</forename>
                                                                 <surname>Mortensen</surname>
                                                            </persName>
                                                            </editor>
                                                            <imprint>
                                                                 <pubPlace>København</pubPlace>
                                                                 <publisher>Gyldendal</publisher>
                                                                 <date>2003-2008</date>
                                                                 <idno type="ISBN">87-02-01991-4</idno>
                                                            </imprint>
                                                       <biblScope unit="volume"><xsl:value-of select="TEI:div[@type='credits']//TEI:volume"/><xsl:text>:</xsl:text><hi rend="italic"><xsl:for-each select="TEI:div[@type='credits']//TEI:volumeTitle"><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:for-each></hi></biblScope>
                                                       <date when="{TEI:div[@type='credits']//TEI:date}"/>
                                                  </monogr>
                                             </biblStruct></listBibl>
                                             <notesStmt>
                                                  <xsl:if test="not(TEI:TEI/@xml:lang='eng')">
                                                       <note xml:id="thisFile"
                        target="{@xml:id}.xml"
                        type="originalDanish">dansk førsteudgave</note>
                                                       <xsl:if test="//TEI:catRef/@target='tale'">
                                                            <note target="{@xml:id}_modern" type="modernDanish">moderniseret version</note>
                                                       <note type="britishEnglish"><xsl:attribute name="target"><xsl:copy-of select="document('file:/C:/Users/nh/Documents/GitHubC-drev/KlausPMortensen/git-sv/sv-data/data/index.xml')//TEI:item[child::TEI:idno=current()/@xml:id]/TEI:idno[@type='ironsEdition']"/></xsl:attribute><xsl:text>engelsk oversættelse</xsl:text></note></xsl:if>
                                                  </xsl:if>
                                                  <xsl:if test="//TEI:catRef/@target='tale' and TEI:TEI/@xml:lang='eng'"><!--code for English translations, not yet tested-->
                                                       <note><xsl:attribute name="target"><xsl:copy-of select="document('file:/C:/Users/nh/Documents/GitHubC-drev/KlausPMortensen/git-sv/sv-data/data/index.xml')//TEI:item[child::TEI:idno=current()/@xml:id]/TEI:idno[@type='SV']"/></xsl:attribute><xsl:text>dansk førsteudgave</xsl:text></note><!--test-->
                                                       <note><xsl:attribute name="target"><xsl:copy-of select="document('file:/C:/Users/nh/Documents/GitHubC-drev/KlausPMortensen/git-sv/sv-data/data/index.xml')//TEI:item[child::TEI:idno=current()/@xml:id]/TEI:idno[@type='SV']"/><xsl:text>_modern.xml</xsl:text></xsl:attribute><xsl:text>moderniseret version</xsl:text></note>
                                                       <note target="{@xml:id}" xml:id="thisFile">engelsk oversættelse</note>
                                                  </xsl:if>                                                  
                                             </notesStmt>
                                        </sourceDesc>
                                        <encodingDesc>
                                             <taxonomy xml:id="tax.Mortensen">
                                                  <bibl>
                                                       <title>ANDERSEN. H.C. Andersens Samlede Værker</title>
                                                       <editor>Klaus P. Mortensen</editor>
                                                       <edition>2003-2008</edition>
                                                  </bibl>
                                                  <category xml:id="tale">
                                                       <catDesc xml:lang="da">eventyr og historier</catDesc>
                                                       <catDesc xml:lang="en">fairy tales and stories</catDesc>
                                                  </category>
                                                  <category xml:id="novel">
                                                       <catDesc xml:lang="da">romaner</catDesc>
                                                       <catDesc xml:lang="en">novels</catDesc>
                                                  </category>
                                                  <category xml:id="poem">
                                                       <catDesc xml:lang="da">digte</catDesc>
                                                       <catDesc xml:lang="en">poems</catDesc>
                                                  </category>
                                                  <category xml:id="mix">
                                                       <catDesc xml:lang="da">blandinger</catDesc>
                                                       <catDesc xml:lang="en">genre mixes</catDesc>
                                                  </category>
                                                  <category xml:id="play">
                                                       <catDesc xml:lang="da">skuespil</catDesc>
                                                       <catDesc xml:lang="en">plays</catDesc>
                                                  </category>
                                                  <category xml:id="travelAccount">
                                                       <catDesc xml:lang="da">rejseberetninger</catDesc>
                                                       <catDesc xml:lang="en">travel accounts</catDesc>
                                                  </category>
                                                  <category xml:id="autobiography">
                                                       <catDesc xml:lang="da">selvbiografier</catDesc>
                                                       <catDesc xml:lang="en">autobiographies</catDesc>
                                                  </category>
                                             </taxonomy>︎    
                                        </encodingDesc>
                                        <xenoData/>
                                   </fileDesc>
                                   <profileDesc>
                                        <creation>
                                             <xsl:call-template name="date"/>
                                        </creation>
                                        <textClass>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:catRef"/>
                                             
                                             <keywords scheme="addLinkToControlledVocabulary">
                                                  <xsl:choose>
                    <xsl:when test="//TEI:catRef[@target='#tale']">
                         <term>had</term>
                         <term>kærlighed</term>
                    </xsl:when>
                    <xsl:when test="//TEI:catRef[@target='#novel']">
                         <term>krig</term>
                         <term>fred</term>
                    </xsl:when>
                    <xsl:when test="//TEI:catRef[@target='#poem']">
                         <term>længsel</term>
                         <term>smerte</term>
                    </xsl:when>
                    <xsl:when test="//TEI:catRef[@target='#mix']">
                         <term>havet</term>
                         <term>godhed</term>
                    </xsl:when>
                    <xsl:when test="//TEI:catRef[@target='#play']">
                         <term>historie</term>
                         <term>intrige</term>
                    </xsl:when>
                    <xsl:when test="//TEI:catRef[@target='#travelAccount']">
                         <term>rejser</term>
                         <term>seværdigheder</term>
                    </xsl:when>
                    <xsl:when test="//TEI:catRef[@target='#autobiography']">
                         <term>dannelse</term>
                         <term>barndom</term>
                    </xsl:when>
               
               </xsl:choose>
                                             </keywords>
                                        </textClass>
                                        <xsl:if test="descendant::TEI:div">
                                             <table type="TOC">
                                                  <row>
                                                       <xsl:for-each select=".//TEI:div|TEI:floatingText[@xml:id]">
                                                            <cell ref="#{@xml:id}"><xsl:if test="ancestor::TEI:div/TEI:head[@type='part' or @type='act'] or ancestor::TEI:div[@type='workPart']/TEI:head[@type='main' or @type='scene']"><xsl:attribute name="level">2</xsl:attribute></xsl:if><xsl:choose><xsl:when test="@rend"><xsl:value-of select="@rend"/></xsl:when><xsl:when test="@type and not(@rend)"><xsl:value-of select="@type"/></xsl:when><xsl:otherwise><xsl:text>hverken @rend eller @type ved div-elementet. Indføj alternativ overskrift i kildefilen</xsl:text></xsl:otherwise></xsl:choose></cell>
                                                       </xsl:for-each>
                                                  </row>
                                             </table>
                                             <floatingTextsRankedAsWorks><!--should be moved to xenoData-->
                                                  <xsl:for-each select=".//TEI:floatingText[@xml:id]|TEI:div[@type='workPart']">
                                                            <separateWork>
                                                                 <title><xsl:choose><xsl:when test="@rend"><xsl:value-of select="@rend"/></xsl:when><xsl:when test="@type and not(@rend)"><xsl:value-of select="@type"/></xsl:when><xsl:otherwise><xsl:text>hverken @rend eller @type ved div-elementet. Indføj alternativ overskrift i kildefilen</xsl:text></xsl:otherwise></xsl:choose></title>
                                                            <xsl:copy-of select="//TEI:teiHeader//TEI:catRef"/>
                                                                 <section><xsl:value-of select="@xml:id"/></section>
                                                                 <xsl:if test="@alt"><alternativeTitles><xsl:value-of select="@alt"/><!--<xsl:text>FIGURE OUT HOW TO GRAB</xsl:text>--></alternativeTitles></xsl:if>
                                                                 <xsl:call-template name="date"/>
                                                       </separateWork></xsl:for-each>
                                                  
                                             </floatingTextsRankedAsWorks>
                                        </xsl:if>
                                   </profileDesc>
                                   <revisionDesc>
                                        <xsl:copy-of select="//TEI:teiHeader//TEI:change"/>
                                        <change who="NHB" when="{format-date(current-date(),'[Y0001]-[M01]-[D01]')}">extracted from larger file with entire volume</change>
                                   </revisionDesc>
                              </teiHeader>
                              
                                                  
                         
                         <text type="print">
                              <body>
                                   <xsl:copy-of select="."/>
                              </body>
                         </text>
                         <standOff>
                              <listAnnotation>
                                   <!--should later be separated into subsections for deviations, corrections and textcomments
                                   https://tei-c.org/release/doc/tei-p5-doc/en/html/SA.html#SASOann-->
                                   <xsl:for-each select="//TEI:div[@type='work-comments' and contains(@xml:id, current()/@xml:id)]"><xsl:copy-of select="."/></xsl:for-each>
                              </listAnnotation>
                         </standOff>
                    </TEI>
               </xsl:result-document>
          </xsl:for-each>
     </xsl:template>    
</xsl:stylesheet>