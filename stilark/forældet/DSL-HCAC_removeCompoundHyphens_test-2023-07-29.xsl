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
     
     
     
     <xsl:template match="//TEI:body//TEI:div/(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
          
          <xsl:analyze-string select="." regex="([\wæøå]+\-[\wæøå]+)" ><xsl:matching-substring><xsl:copy-of select="."></xsl:copy-of></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string>
     </xsl:template>
     <!--not(codepoint-equal(regex-group(2),'et fyensk folke-eventyr') or (regex-group(2),'laaland-falsters stiftstidende') or (regex-group(2),'klumpe-dumpe, som faldt ned af trapperne og kom dog i høisædet og fik prindsessen') or (regex-group(2),'klumpe-dumpe') or (regex-group(2),'klumpe-dumpe der faldt ned af trapperne og kom dog i høisædet og fik prindsessen') or (regex-group(2),'p-maal') or (regex-group(2),'trold-gubben') or (regex-group(2),'gjedebukkebeens-overogundergeneralkrigskommandeersergeanten') or (regex-group(2),'gjedebukkebeens-overogundergeneralkrigscommandeersergeanten') or (regex-group(2),'krible-krable') or (regex-group(2),'halte-maren') or (regex-group(2),'jeppe-jæns') or (regex-group(2),'jeppe-jæns’s') or (regex-group(2),'landmaaler-mærke') or (regex-group(2),'an-lis') or (regex-group(2),'-sen') or (regex-group(2),'aands-hovmodets') or (regex-group(2),'huusby-klitter') or (regex-group(2),'nørre-vosborg') or (regex-group(2),'gammel-skagen') or (regex-group(2),'vester-') or (regex-group(2),'hun-skarnbasser') or (regex-group(2),'berner-oberland') or (regex-group(2),'venskabs-pagten') or (regex-group(2),'skandale-flasken') or (regex-group(2),'cancan-suppe') or (regex-group(2),'høiere dannelses-anstalt') or (regex-group(2),'fr. paludan-müller') or (regex-group(2),'friheds-støtten') or (regex-group(2),'militair-skolen') or (regex-group(2),'pariser-udstillingen!') or (regex-group(2),'skidt-mads') or (regex-group(2),'gartner-lærlingen') or (regex-group(2),'assistents-kirkegaarden') or (regex-group(2),'lotte-lene') or (regex-group(2),'lotte-lenes') or (regex-group(2),'have-kirsten') or (regex-group(2),'have-ole') or (regex-group(2),'krøbling-hans') or (regex-group(2),'frederik høegh-guldberg') or (regex-group(2),'laaland-falsters stiftstidende') or (regex-group(2),'hegermann-lindencrone') or (regex-group(2),'nøgle-aander') or (regex-group(2),'academi-opdragne') or (regex-group(2),'brekke-ke-kex') or (regex-group(2),'bruun-grøn') or (regex-group(2),'fut-foi') or (regex-group(2),'hu-hu') or (regex-group(2),'hu-ih-hu-ih') or (regex-group(2),'høi-fornemme') or (regex-group(2),'kjærrrrr-restefolk') or (regex-group(2),'oldermands-klog') or (regex-group(2),'over-keiserlig-nattergale-bringer') or (regex-group(2),'qvirre-virre-vit') or (regex-group(2),'ritsch-ratsch') or (regex-group(2),'snip-snap-snurre-basselurre') or (regex-group(2),'surrerurre-rup') or (regex-group(2),'tip-tip-oldemoders') or (regex-group(2),'tiptippe-tip-oldemoer-lygte') or (regex-group(2),'tromme-romme-rommer') or (regex-group(2),'trylle-fløiten') or (regex-group(2),'tsing-pe') or (regex-group(2),'uh-u-ud') or (regex-group(2),'ding-dang') or (regex-group(2),'ding-dang'))
               -->
     <!--contains(regex-group(1),'et fyensk folke-eventyr') or (regex-group(1),'ivede-avede') or (regex-group(1),'klumpe-dumpe, som faldt ned af trapperne og kom dog i høisædet og fik prindsessen') or (regex-group(1),'klumpe-dumpe') or (regex-group(1),'klumpe-dumpe der faldt ned af trapperne og kom dog i høisædet og fik prindsessen') or (regex-group(1),'p-maal') or (regex-group(1),'trold-gubben') or (regex-group(1),'gjedebukkebeens-overogundergeneralkrigskommandeersergeanten') or (regex-group(1),'gjedebukkebeens-overogundergeneralkrigscommandeersergeanten') or (regex-group(1),'krible-krable') or (regex-group(1),'halte-maren') or (regex-group(1),'klods-hans') or (regex-group(1),'jeppe-jæns') or (regex-group(1),'jeppe-jæns’s') or (regex-group(1),'landmaaler-mærke') or (regex-group(1),'an-lis') or (regex-group(1),'-sen') or (regex-group(1),'aands-hovmodets') or (regex-group(1),'huusby-klitter') or (regex-group(1),'nørre-vosborg') or (regex-group(1),'gammel-skagen') or (regex-group(1),'vester-') or (regex-group(1),'hun-skarnbasser') or (regex-group(1),'berner-oberland') or (regex-group(1),'skandale-flasken') or (regex-group(1),'cancan-suppe') or (regex-group(1),'høiere dannelses-anstalt') or (regex-group(1),'fr. paludan-müller') or (regex-group(1),'friheds-støtten') or (regex-group(1),'militair-skolen') or (regex-group(1),'pariser-udstillingen!') or (regex-group(1),'skidt-mads') or (regex-group(1),'gartner-lærlingen') or (regex-group(1),'assistents-kirkegaarden') or (regex-group(1),'lotte-lene') or (regex-group(1),'lotte-lenes') or (regex-group(1),'have-kirsten') or (regex-group(1),'have-ole') or (regex-group(1),'krøbling-hans') or (regex-group(1),'frederik høegh-guldberg') or (regex-group(1),'laaland-falsters stiftstidende') or (regex-group(1),'hegermann-lindencrone') or (regex-group(1),'nøgle-aander') or (regex-group(1),'academi-opdragne') or (regex-group(1),'brekke-ke-kex') or (regex-group(1),'bruun-grøn') or (regex-group(1),'fut-foi') or (regex-group(1),'hu-hu') or (regex-group(1),'hu-ih-hu-ih') or (regex-group(1),'høi-fornemme') or (regex-group(1),'kjærrrrr-restefolk') or (regex-group(1),'oldermands-klog') or (regex-group(1),'over-keiserlig-nattergale-bringer') or (regex-group(1),'qvirre-virre-vit') or (regex-group(1),'ritsch-ratsch') or (regex-group(1),'snip-snap-snurre-basselurre') or (regex-group(1),'surrerurre-rup') or (regex-group(1),'tip-tip-oldemoders') or (regex-group(1),'tiptippe-tip-oldemoer-lygte') or (regex-group(1),'tromme-romme-rommer') or (regex-group(1),'trylle-fløiten') or (regex-group(1),'tsing-pe') or (regex-group(1),'uh-u-ud') or (regex-group(1),'ding-dang') or (regex-group(1),'ding-dang')-->
     <!--<xsl:for-each select="substring-before(substring-after(.,' '),'-')"></xsl:for-each-->     
     <!--(Ivede-Avede|Klumpe-Dumpe|Klumpe-Dumpe der faldt ned af Trapperne og kom dog i Høisædet og fik Prindsessen|Gjedebukkebeens-Overogundergeneralkrigscommandeersergeanten|Krible-Krable)-->
     <!--1) alt lower-case
               2) første char upper-case
          -->
     <!--<xsl:template match="TEI:body//TEI:div/(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
               <xsl:analyze-string select="substring(.,1,2)" regex="»\w"><xsl:matching-substring><xsl:value-of select="upper-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string>
               <xsl:copy-of select="substring(.,2,10000000000000000)"/>
          </xsl:template>-->
     <!--the last regex avoids the letters, which are most frequent in verbs: j,r,s. This part is experimental-->
     <!--<xsl:copy-of select="."/>-->
     
     <xsl:template name="removeHypens">
          <xsl:analyze-string select="." regex="([A-Z][a-z]*)\-([A-Z][a-z])"><xsl:matching-substring>
          <xsl:value-of select="translate(.,'-', '')"/>
          <!--<xsl:choose>
                    <xsl:when test=""><!-\-<!-\-(Ivede-Avede|Klumpe-Dumpe|Klumpe-Dumpe der faldt ned af Trapperne og kom dog i Høisædet og fik Prindsessen|Gjedebukkebeens-Overogundergeneralkrigscommandeersergeanten|Krible-Krable)-\-><xsl:value-of select="."/></xsl:when></xsl:choose>--></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string></xsl:template>
     
     <!--<xsl:template match="TEI:body//TEI:div/TEI:p/text()">
          <xsl:analyze-string select="substring(.,1,2)" regex="»\w"><xsl:matching-substring><xsl:value-of select="upper-case(.)"/></xsl:matching-substring><xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring></xsl:analyze-string>
          <xsl:copy-of select="substring(.,3,10000000000000000)"/>
     </xsl:template>-->
     <!--<xsl:template match="TEI:p/text()"><xsl:copy-of select="upper-case(substring(.,1,1))"/><xsl:copy-of select="substring(.,2,10000000000000000)"/></xsl:template>-->
     
     
     <!--
          2023-07-02: add new template
          upper-case for first character in TEI:p, TEI:lg/l[1] TEI:head
          reuse xslt SVaddInitial-->
     
     <!--  -->
     <!--<xsl:template match="//TEI:body//TEI:div/(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
          <xsl:when test="contains(regex-group(1),'et fyensk folke-eventyr') or (regex-group(1),'ivede-avede') or (regex-group(1),'klumpe-dumpe, som faldt ned af trapperne og kom dog i høisædet og fik prindsessen') or (regex-group(1),'klumpe-dumpe') or (regex-group(1),'klumpe-dumpe der faldt ned af trapperne og kom dog i høisædet og fik prindsessen') or (regex-group(1),'p-maal') or (regex-group(1),'trold-gubben') or (regex-group(1),'gjedebukkebeens-overogundergeneralkrigskommandeersergeanten') or (regex-group(1),'gjedebukkebeens-overogundergeneralkrigscommandeersergeanten') or (regex-group(1),'krible-krable') or (regex-group(1),'halte-maren') or (regex-group(1),'klods-hans') or (regex-group(1),'jeppe-jæns') or (regex-group(1),'jeppe-jæns’s') or (regex-group(1),'landmaaler-mærke') or (regex-group(1),'an-lis') or (regex-group(1),'-sen') or (regex-group(1),'aands-hovmodets') or (regex-group(1),'huusby-klitter') or (regex-group(1),'nørre-vosborg') or (regex-group(1),'gammel-skagen') or (regex-group(1),'vester-') or (regex-group(1),'hun-skarnbasser') or (regex-group(1),'berner-oberland') or (regex-group(1),'skandale-flasken') or (regex-group(1),'cancan-suppe') or (regex-group(1),'høiere dannelses-anstalt') or (regex-group(1),'fr. paludan-müller') or (regex-group(1),'friheds-støtten') or (regex-group(1),'militair-skolen') or (regex-group(1),'pariser-udstillingen!') or (regex-group(1),'skidt-mads') or (regex-group(1),'gartner-lærlingen') or (regex-group(1),'assistents-kirkegaarden') or (regex-group(1),'lotte-lene') or (regex-group(1),'lotte-lenes') or (regex-group(1),'have-kirsten') or (regex-group(1),'have-ole') or (regex-group(1),'krøbling-hans') or (regex-group(1),'frederik høegh-guldberg') or (regex-group(1),'laaland-falsters stiftstidende') or (regex-group(1),'hegermann-lindencrone') or (regex-group(1),'nøgle-aander') or (regex-group(1),'academi-opdragne') or (regex-group(1),'brekke-ke-kex') or (regex-group(1),'bruun-grøn') or (regex-group(1),'fut-foi') or (regex-group(1),'hu-hu') or (regex-group(1),'hu-ih-hu-ih') or (regex-group(1),'høi-fornemme') or (regex-group(1),'kjærrrrr-restefolk') or (regex-group(1),'oldermands-klog') or (regex-group(1),'over-keiserlig-nattergale-bringer') or (regex-group(1),'qvirre-virre-vit') or (regex-group(1),'ritsch-ratsch') or (regex-group(1),'snip-snap-snurre-basselurre') or (regex-group(1),'surrerurre-rup') or (regex-group(1),'tip-tip-oldemoders') or (regex-group(1),'tiptippe-tip-oldemoer-lygte') or (regex-group(1),'tromme-romme-rommer') or (regex-group(1),'trylle-fløiten') or (regex-group(1),'tsing-pe') or (regex-group(1),'uh-u-ud') or (regex-group(1),'ding-dang') or (regex-group(1),'ding-dang'))">
               <xsl:value-of select="translate(.,'-', '')"/></xsl:when>
     </xsl:template>-->
     
</xsl:stylesheet>