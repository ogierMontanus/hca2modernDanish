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
     <xsl:template name="date">
          <date>
<xsl:choose>
     <xsl:when test="descendant::TEI:div[@type='source' and descendant::TEI:sourceDate]"><xsl:value-of select="descendant::TEI:div[@type='source']/TEI:sourceDate"/></xsl:when>
     <xsl:when test="parent::TEI:div[@type='source' and descendant::TEI:sourceDate]"><xsl:value-of select="parent::TEI:div[@type='source']/TEI:sourceDate"/></xsl:when>               
     <xsl:when test="preceding-sibling::TEI:div[@type='source' and descendant::TEI:sourceDate]"><xsl:value-of select="preceding-sibling::TEI:div[@type='source']/TEI:sourceDate"/></xsl:when>               
               <xsl:when test=".//TEI:sourceDate">
                    <xsl:value-of select=".//TEI:sourceDate[1]"/></xsl:when>
     <xsl:when test=".//TEI:docDate[not(@when)]">
<xsl:value-of select="descendant::TEI:docDate[not(@when)][1]"/></xsl:when>
<xsl:when test=".//TEI:docDate[@when]"><xsl:value-of select=".//TEI:docDate[1]/@when"/></xsl:when>
               <xsl:when test="./preceding::TEI:sourceDate[1]"><xsl:value-of select="./preceding::TEI:sourceDate[1]"/></xsl:when>
               <xsl:when test="./preceding::TEI:docDate[@when]"><xsl:value-of select="./preceding::TEI:docDate[1][@when]"/></xsl:when>
     <xsl:when test="descendant::TEI:front"><xsl:value-of select="descendant::TEI:front[1]//TEI:docTitle//(TEI:date|TEI:docDate)"/></xsl:when>
     <xsl:when test=".//TEI:front"><xsl:value-of select=".//TEI:front[1]//TEI:docImprint/(TEI:date|TEI:docDate)"/></xsl:when>
               <xsl:otherwise>4000</xsl:otherwise>
          </xsl:choose>
          </date>
     </xsl:template>
<xsl:template name="trimFirstline">
     <xsl:choose><xsl:when test="@rend"><xsl:choose><!--<xsl:value-of select="@rend"/>--><xsl:when test="substring(@rend,1,1) = '»'"><!--1) expand test »|–|\( + 2) finetune position, to make sure the test concerns the first character --><xsl:value-of select="substring(@rend,2)"/></xsl:when><xsl:otherwise><xsl:value-of select="@rend"/></xsl:otherwise>
     </xsl:choose></xsl:when><xsl:otherwise><xsl:text>mangler @rend </xsl:text></xsl:otherwise></xsl:choose></xsl:template>
     
<xsl:template match="TEI:TEI">
          
          
          <xsl:result-document href="{format-date(current-date(),'[Y0001]-[M01]-[D01]')}opdateringTilIndexHTML.html" method="html">
               <!--add wrapper-tag-->
                    <html>
                         <xsl:for-each select="(//TEI:div[@type='workPart']|//TEI:floatingText[@xml:id])">
                         <item>
                              <title xml:lang="da"><xsl:value-of select="./@rend"/></title>
                              <xsl:if test="//TEI:catRef/@target='tale'">
                                   <!--<title xml:lang="da" id="modernDanish"><xsl:value-of select="@rend"/><xsl:text>_modern</xsl:text></title>-->
                                   <!--<title xml:lang="eng" id="Irons"><xsl:text>add English title from index to translation by John Irons</xsl:text></title>-->
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
                              <catRef target="#{//TEI:catRef/@target}"/>
                              <idno type="SV"><xsl:value-of select="ancestor::TEI:div[@type='work']/@xml:id"/><xsl:text>.html#</xsl:text><xsl:value-of select="./@xml:id"/></idno>
                         </item>
                         
                    </xsl:for-each></html>
               
          </xsl:result-document>
          <xsl:result-document href="{format-date(current-date(),'[Y0001]-[M01]-[D01]')}opdateringTilIndexXML_{substring-before(tokenize(base-uri(), '/')[last()],'.xml')}.xml" method="xml"><!--output filename to result-document, see https://stackoverflow.com/questions/30648703/get-file-name-of-xml-file-with-xsl?rq=3-->
               <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="//TEI:div[@type='work']"><!--select="(//TEI:div[@type='work' or @type='workPart']|//TEI:floatingText[@xml:id])-->
                    <item>
                         <title xml:lang="da"><!--<xsl:if test="(TEI:div[@type='work'])"><xsl:attribute name="rend">hashtag</xsl:attribute></xsl:if>--><xsl:value-of select="./@rend"/><xsl:if test="descendant::TEI:head[1][@rendition]"><xsl:text> [</xsl:text><xsl:value-of select="descendant::TEI:head[1][@rendition]/@rendition"/><xsl:text>]</xsl:text></xsl:if></title>
                         <!--2023-05-05: hashtag virker endnu ikke efter hensigten. 2023-11-15: hashtag slettet-->
                         <!--<xsl:if test="//TEI:catRef/@target='tale'">
                              <title xml:lang="da" id="modernDanish"><xsl:value-of select="@rend"/><xsl:text>_modern</xsl:text></title>
                              <title xml:lang="eng" id="Irons"><xsl:text>add English title from index to translation by John Irons</xsl:text></title>
                         </xsl:if>-->
                         <xsl:call-template name="date"/>
                         <catRef target="#{//TEI:catRef/@target}"/>
                         <idno type="SV"><xsl:value-of select="@xml:id"/></idno>
                         <!--<ref type="prefix">https://hcams.andersen.sdu.dk/exist/apps/sv/api/document/works%252F</ref>
                         <ref type="suffix-xml">/xml</ref>
                         <ref type="suffix-html">/html</ref>
                         <ref type="suffix-pdf">/pdf</ref>
                         <ref type="suffix-epub">/pdf</ref>-->
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
                    <xsl:processing-instruction name="xml-model">type="application/relax-ng-compact-syntax" href="https://beta.auh.sdu.dk/pmm-skema/sv18.rnc"</xsl:processing-instruction>
                    
                    <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:TEI="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xml:lang="da" xml:space="preserve">
<!--teiHeader begins-->
                         
                              <teiHeader>
                                   <fileDesc>
                                        <titleStmt>
                                             <title><xsl:value-of select="@rend"/></title>
                                             <author ref="http://viaf.org/viaf/4925902">H.C. Andersen</author>
                                             <xsl:for-each select="//TEI:div[@type='credits']//TEI:persName"><editor role="content"><xsl:value-of select="."/></editor><xsl:text>
</xsl:text></xsl:for-each>
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
<xsl:choose>
  <xsl:when test="//TEI:div[@type='work-comments' and contains(@synch, current()/@xml:id)]">
    <xsl:copy-of select="//TEI:div[@type='work-comments' and contains(@synch, current()/@xml:id)]/TEI:argument[@type='sourceData'][1]/child::*"/>
    <!--2024-09-28: added qualifier [1]: //TEI:argument[@type='sourceData'][1]/child::*-->
    <!--removed: /descendant::*-->
  </xsl:when>
  <!--added 2024-09-22-->
  <xsl:when test="//TEI:div[@type='work-comments' and contains(@synch, current()/@xml:id)]">
    <xsl:copy-of select="//TEI:div[@type='work-comments' and contains(@synch, current()/@xml:id)]"/>
  </xsl:when>
  <!--added 2024-09-22-->
  <xsl:otherwise>
    <xsl:copy-of select="//TEI:div[@type='work-comments' and contains(ancestor::TEI:div/@synch, current()/@xml:id)]/TEI:p[position()=1]"/>
  </xsl:otherwise>
  <!--<xsl:otherwise>
    <xsl:copy-of select="//TEI:div[@type='work-comments' and contains(@synch, current()/@xml:id) or contains(ancestor::TEI:div/@synch, current()/@xml:id)]/TEI:p[position()=1]"/>
  </xsl:otherwise>-->
</xsl:choose>


<!--<xsl:choose>
<xsl:when test="//TEI:div[@type='work-comments' and contains(@synch, current()/@xml:id)]//TEI:argument[@type='sourceData']">
<xsl:copy-of select="//TEI:div[@type='work-comments' and (contains(@synch, current()/@xml:id))]//TEI:argument[@type='sourceData'][1]/child::*"/>
<!-\-2024-09-28: added qualifier [1]: //TEI:argument[@type='sourceData'][1]/child::*-\->
<!-\-removed: /descendant::*-\->
</xsl:when>
<!-\-added 2024-09-22-\-><xsl:when test="//TEI:div[@type='work-comments' and (contains(@synch, current()/@xml:id))]"><xsl:copy-of select="//TEI:div[@type='work-comments' and (contains(@synch, current()/@xml:id))]"></xsl:copy-of></xsl:when>
<!-\-added 2024-09-22-\-><xsl:otherwise><xsl:copy-of select="//TEI:div[@type='work-comments' and (contains(ancestor::TEI:div/@synch, current()/@xml:id))]/TEI:p[position()=1]"/></xsl:otherwise>
<!-\-<xsl:otherwise><xsl:copy-of select="//TEI:div[@type='work-comments' and (contains(@synch, current()/@xml:id) or contains(ancestor::TEI:div/@synch, current()/@xml:id))]/TEI:p[position()=1]"/></xsl:otherwise>-\-></xsl:choose>--></bibl>
                                                  <biblStruct>
                                                  <monogr>
                                                       <title level="m">ANDERSEN. H.C. Andersens samlede værker</title>
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
                                                                 <date>2003-2007</date>
                                                                 <idno type="ISBN">87-02-01991-4</idno>
                                                            </imprint>
                                                       <biblScope unit="volume"><xsl:value-of select="//TEI:div[@type='credits']//TEI:volume"/><xsl:text>:</xsl:text><hi rend="italic"><xsl:for-each select="//TEI:div[@type='credits']//TEI:volumeTitle"><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:for-each></hi></biblScope>
                                                       <date when="{//TEI:div[@type='credits']//(TEI:date|TEI:docDate)}"/>
                                                  </monogr>
                                             </biblStruct></listBibl>
                                             <notesStmt>
                                                  <xsl:if test="not(TEI:TEI/@xml:lang='eng')">
                                                       <note xml:id="thisFile"
                        target="{@xml:id}"
                        type="originalDanish">dansk førsteudgave</note><!--2023-10-04: removed .xml from @target. target="{substring-before(@xml:id,'.xml')}"-->
                                                       <xsl:if test="//TEI:catRef/@target='tale'">
                                                            <xsl:if test="not(substring-before(@subtype,'zed')='notTranslatedNotModerni')"><note target="{@xml:id}_modern" type="modernDanish">moderniseret version</note></xsl:if>
                                                       <xsl:if test="not(substring-before(@subtype,'ed')='notTranslat')"><note type="britishEnglish"><xsl:attribute name="target"><xsl:copy-of select="document('file:/C:/Users/nh/Documents/GitHub/KlausPMortensen/git-sv/sv-data/data/index.xml')//TEI:item[child::TEI:idno=current()/@xml:id]/TEI:idno[@type='ironsEdition']"/><!--<xsl:text>.xml</xsl:text>--></xsl:attribute><xsl:text>engelsk oversættelse</xsl:text></note></xsl:if></xsl:if>
                                                  </xsl:if>
                                                  <xsl:if test="//TEI:catRef/@target='tale' and TEI:TEI/@xml:lang='eng'"><!--code for English translations, not yet tested-->
                                                       <note><xsl:attribute name="target"><xsl:copy-of select="document('file:/C:/Users/nh/Documents/GitHub/KlausPMortensen/git-sv/sv-data/data/index.xml')//TEI:item[child::TEI:idno=current()/@xml:id]/TEI:idno[@type='SV']"/></xsl:attribute><xsl:text>dansk førsteudgave</xsl:text></note><!--test-->
                                                       <note><xsl:attribute name="target"><xsl:copy-of select="document('file:/C:/Users/nh/Documents/GitHub/KlausPMortensen/git-sv/sv-data/data/index.xml')//TEI:item[child::TEI:idno=current()/@xml:id]/TEI:idno[@type='SV']"/><xsl:text>_modern<!--.xml--></xsl:text></xsl:attribute><xsl:text>moderniseret version</xsl:text></note>
                                                       <note target="{@xml:id}.xml" xml:id="thisFile">engelsk oversættelse</note>
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
                                        <xenoData>
<xsl:if test=".//(TEI:floatingText[@xml:id]|TEI:div[@type='workPart']|TEI:l[@subtype='firstline'])">
<floatingTextsRankedAsWorks><!--should be moved to xenoData-->
                                                  <xsl:for-each select="(.//TEI:floatingText[@xml:id]|TEI:div[@type='workPart'])[(descendant::TEI:head)|descendant::TEI:titlePart]"><!--removed condition TEI:head[not(@subtype='numbersOnly' or @subtype='firstlineOnly')]]
2024-06-25: removed |descendant::TEI:l[@subtype='firstline'
firstline is used below-->
                                                            <separateWork>
                                                                 <title><xsl:choose><xsl:when test="@rend"><!--<xsl:value-of select="@rend"/>--><xsl:choose><xsl:when test="substring(@rend,1,1) = '»'"><!--1) expand test »|–|\( + 2) finetune position, to make sure the test concerns the first character --><xsl:value-of select="substring(@rend,2)"/></xsl:when><xsl:otherwise><xsl:value-of select="@rend"/></xsl:otherwise></xsl:choose></xsl:when><xsl:when test="@type and not(@rend)"><xsl:value-of select="@type"/></xsl:when><xsl:otherwise><xsl:text>hverken @rend eller @type ved div-elementet. Indføj alternativ overskrift i kildefilen</xsl:text></xsl:otherwise></xsl:choose></title>
                                                            <xsl:copy-of select="//TEI:teiHeader//TEI:catRef"/>
                                                                 <section><xsl:for-each select="parent::TEI:div[@xml:id]"><!--2024-06-25: ancestor > parent select="ancestor::TEI:div[@xml:id]"-->

<xsl:value-of select="@xml:id"/><xsl:text>/#</xsl:text></xsl:for-each><xsl:value-of select="@xml:id"/></section>
                                                                 <!--<xsl:if test="@alt"><alternativeTitles><xsl:value-of select="@alt"/><!-\-<xsl:text>FIGURE OUT HOW TO GRAB</xsl:text>-\-></alternativeTitles></xsl:if>--><xsl:call-template name="date"/>
                                                       </separateWork>
</xsl:for-each>

<xsl:for-each select="descendant::TEI:l[@subtype='firstline']">
                                                            <separateWork><!--test 2024-06-25-->
                                                                 <title><xsl:value-of select="@corresp"/><!--<xsl:choose><xsl:when test="ancestor::TEI:parent/preceding-sibling::TEI:head[@subtype='numbersOnly' or @subtype='firstlineOnly']"><xsl:value-of select="@corresp"/></xsl:when><xsl:otherwise><xsl:call-template name="trimFirstline"/></xsl:otherwise></xsl:choose>--><!--<xsl:choose><xsl:when test="@rend"><xsl:choose><!-\-<xsl:value-of select="@rend"/>-\-><xsl:when test="substring(@rend,1,1) = '»'"><!-\-1) expand test »|–|\( + 2) finetune position, to make sure the test concerns the first character -\-><xsl:value-of select="substring(@rend,2)"/></xsl:when><xsl:otherwise><xsl:value-of select="@rend"/></xsl:otherwise>
</xsl:choose></xsl:when><xsl:otherwise><xsl:text>mangler @rend </xsl:text></xsl:otherwise></xsl:choose>--></title>
                                                            <xsl:copy-of select="//TEI:teiHeader//TEI:catRef"/><!--refine: (sub)type drama > catRef drama-->
                                                                 <section><xsl:value-of select="ancestor::TEI:div[@type='work']/@xml:id"/><xsl:text>/#</xsl:text><xsl:value-of select="@rendition"/></section>
                                                                 <xsl:call-template name="date"/>
                                                       </separateWork></xsl:for-each>
                                                  
                                             </floatingTextsRankedAsWorks></xsl:if>
</xenoData>
                                   </fileDesc>
                                   <profileDesc>
                                        <creation>
                                             <xsl:call-template name="date"/>
                                        </creation>
                                        <textClass>
                                             <xsl:copy-of select="//TEI:teiHeader//TEI:catRef"/>
                                             
                                             <keywords scheme="addLinkToControlledVocabulary">
                                                  <!--<xsl:choose>
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
               
               </xsl:choose>-->
                                             </keywords>
                                        </textClass>
                                        <xsl:choose>
<xsl:when test="count((.//TEI:div[not(@type='source')])|(.//TEI:floatingText[@xml:id]))>1"><!--
after 2024-03-13: count((.//TEI:div[not(@type='source')])|(.//TEI:floatingText[@xml:id]))>1"
before 2024-03-13: test="
(descendant::TEI:div[not(@type='source')]|descendant::TEI:floatingText[@xml:id])
-->
                                             <table type="TOC">
                                                  <row>
                                                       <xsl:for-each select="(.//TEI:div[not(@type='source')])|(.//TEI:floatingText[@xml:id])">
                                                            <cell ref="#{@xml:id}"><xsl:if test="(ancestor::TEI:div[@type='part' or @type='act']/TEI:head[not(@type='melody')]) or (ancestor::TEI:div[@type='workPart']/(TEI:head[@type='main' or @type='scene']|TEI:front))"><xsl:attribute name="level">2</xsl:attribute></xsl:if><xsl:choose><xsl:when test="@rend"><xsl:value-of select="@rend"/></xsl:when><xsl:when test="descendant::TEI:l[@subtype]"><xsl:value-of select="descendant::TEI:l[@subtype]/@corresp"/></xsl:when><xsl:when test="@type and not(@rend)"><xsl:value-of select="@type"/></xsl:when><xsl:otherwise><xsl:text>hverken @rend eller @type ved div-elementet. Indføj alternativ overskrift i kildefilen</xsl:text></xsl:otherwise></xsl:choose></cell>
                                                       </xsl:for-each>
                                                  </row>
                                             </table>
                                             
                                        </xsl:when>
<xsl:otherwise><milestone type="noTOC"/></xsl:otherwise>
</xsl:choose>
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
<xsl:if test="not(//TEI:div[@type='work-comments' and contains(@synch, current()/@xml:id)])"><xsl:text>NO NOTES ADDED. CHECK THE MARKUP IN DIV TYPE COMMENTS</xsl:text></xsl:if><!--[2024-06-25: removed test. descendant::TEI:row[contains(@xml:id,current()/descendant::TEI:seg[1]/@target)]-->                                   
<xsl:for-each select="//TEI:div[@type='work-comments' and not(@synch='') and (contains(@synch, current()/@xml:id))]">
<!--removed option 2024-06-25:
or descendant::TEI:row[contains(@xml:id,current()/descendant::TEI:seg[1]/@target)]-->
<xsl:copy-of select="."/></xsl:for-each><!--
2024-06-25: modified test. From additional constraint to an alternative [descendant::TEI:row[contains(@xml:id,current()/descendant::TEI:seg[1]/@target)]]
2023-11-10 should be narrowed in via
[descendant::TEI:table[@type='textcomments']/TEI:row[@xml:id=current()/descendant::TEI:seg/@target]]
[contains(descendant::TEI:table[@type='textcomments']/TEI:row[@xml:id],current()/descendant::TEI:seg/@target)]-->
                                   <!--deactivated 2023-11-14. Test listAnnotation in div work with workPart, e.g. volume 17 and 18 
<xsl:if test="current()//TEI:floatingText/@xml:id">
                                        <xsl:for-each select="//TEI:div[@type='work-comments' and contains(@xml:id, current()//TEI:floatingText[position()=1]/@xml:id)]"><xsl:copy-of select="."/></xsl:for-each>
                                   <xsl:for-each select="//TEI:div[@type='work-comments' and contains(@xml:id, current()//TEI:floatingText[position()=2]/@xml:id)]"><xsl:copy-of select="."/></xsl:for-each>
                                        <xsl:for-each select="//TEI:div[@type='work-comments' and contains(@xml:id, current()//TEI:floatingText[position()=3]/@xml:id)]"><xsl:copy-of select="."/></xsl:for-each>
                                   <xsl:for-each select="//TEI:div[@type='work-comments' and contains(@xml:id, current()//TEI:floatingText[position()=4]/@xml:id)]"><xsl:copy-of select="."/></xsl:for-each>
                                   <xsl:for-each select="//TEI:div[@type='work-comments' and contains(@xml:id, current()//TEI:floatingText[position()=5]/@xml:id)]"><xsl:copy-of select="."/></xsl:for-each>
                                   <!-\-<xsl:for-each select="//TEI:div[@type='work-comments' and contains(@xml:id, current()//TEI:floatingText[position()=6]/@xml:id)]"><xsl:copy-of select="."/></xsl:for-each>-\->
                                   </xsl:if>-->
                              </listAnnotation>
                         </standOff>
                    </TEI>
               </xsl:result-document>
          </xsl:for-each>
     </xsl:template>    
</xsl:stylesheet>