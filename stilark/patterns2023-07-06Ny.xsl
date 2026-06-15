<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
     xmlns:TEI="http://www.tei-c.org/ns/1.0" 
     xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="3.0">
     <!-- 2017-05-05: Holger Berg
     2018-03-01: opdateret xsl:number, tilføjet attribut count-->
     
     <xsl:template match="@*|node()">
          <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
     </xsl:template>
     
     <!--<xsl:template match="/">
          
          <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="../css/oxyAuthorEditMinimumHCA.css"</xsl:processing-instruction>
          <xsl:apply-templates select="@*|node()"/>
          <xsl:text><?oxy_options track_changes="on"?></xsl:text>
     </xsl:template>-->
     
     
     <!--<xsl:template match="//TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
          <xsl:analyze-string select="." regex="ee">
               <xsl:matching-substring><xsl:text>|e</xsl:text></xsl:matching-substring>
               <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
          </xsl:analyze-string>
          
          <xsl:analyze-string select="." regex="o">
               <xsl:matching-substring><xsl:text>|i</xsl:text></xsl:matching-substring>
               <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
          </xsl:analyze-string>
     </xsl:template>-->
     
     
     <xsl:template match="//TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()" >
          <xsl:analyze-string select="." regex="ee">
               <xsl:matching-substring><xsl:text>|e</xsl:text></xsl:matching-substring>
               <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
          </xsl:analyze-string>
     </xsl:template>
     
     <xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()" >
                    <xsl:analyze-string select="." regex="Meen" >
                         <xsl:matching-substring><xsl:text>|mén</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                         
                    </xsl:analyze-string>
     </xsl:template>
     
     <xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">                    <xsl:analyze-string select="." regex="Maneer">
                         <xsl:matching-substring><xsl:text>|manér</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="leet">
                         <xsl:matching-substring><xsl:text>|leeet</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="leende">
                         <xsl:matching-substring><xsl:text>|leeende</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Ideen">
                         <xsl:matching-substring><xsl:text>|ideeen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Fee">
                         <xsl:matching-substring><xsl:text>| Feee</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Feen">
                         <xsl:matching-substring><xsl:text>| Feeen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Seer">
                         <xsl:matching-substring><xsl:text>|Seeer</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="besneede">
                         <xsl:matching-substring><xsl:text>|tilsneeede</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Sneen">
                         <xsl:matching-substring><xsl:text>|sneeen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Beeren">
                         <xsl:matching-substring><xsl:text>|Beeeren</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Hveen">
                         <xsl:matching-substring><xsl:text>|Hven</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Kaffeen">
                         <xsl:matching-substring><xsl:text>|caféen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Cafeer">
                         <xsl:matching-substring><xsl:text>|caféer</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Alleer">
                         <xsl:matching-substring><xsl:text>|alléer</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Alleen">
                         <xsl:matching-substring><xsl:text>|alléen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Allee ">
                         <xsl:matching-substring><xsl:text>|allé </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="desmeer">
                         <xsl:matching-substring><xsl:text>|desmere</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Fricasee">
                         <xsl:matching-substring><xsl:text>|frikassé</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" reele">
                         <xsl:matching-substring><xsl:text>| reeele</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Reele">
                         <xsl:matching-substring><xsl:text>|Reeele</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Udseende">
                         <xsl:matching-substring><xsl:text>| udseeende</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Forseelse">
                         <xsl:matching-substring><xsl:text>| forseeelse</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="ee">
                         <xsl:matching-substring><xsl:text>|e</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" eet">
                         <xsl:matching-substring><xsl:text>| ét</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Thea">
                         <xsl:matching-substring><xsl:text>| tea</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Theo">
                         <xsl:matching-substring><xsl:text>| teo</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Thee">
                         <xsl:matching-substring><xsl:text>|te</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="othek">
                         <xsl:matching-substring><xsl:text>|otek</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kie">
                         <xsl:matching-substring><xsl:text>|ke</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="aae ">
                         <xsl:matching-substring><xsl:text>|å </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="aae. ">
                         <xsl:matching-substring><xsl:text>|å. </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="aaer">
                         <xsl:matching-substring><xsl:text>|år</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template>
     <xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="aa">
                         <xsl:matching-substring><xsl:text>|å</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Aa">
                         <xsl:matching-substring><xsl:text>|Å</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" eet">
                         <xsl:matching-substring><xsl:text>| ét</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kje">
                         <xsl:matching-substring><xsl:text>|ke</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Kje">
                         <xsl:matching-substring><xsl:text>|ke</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=". ke">
                         <xsl:matching-substring><xsl:text>|. Ke</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kjæ">
                         <xsl:matching-substring><xsl:text>|kæ</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Kjæ">
                         <xsl:matching-substring><xsl:text>|kæ</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=". kæ">
                         <xsl:matching-substring><xsl:text>|. Kæ</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kjø">
                         <xsl:matching-substring><xsl:text>|kø</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Kjøbenhavn">
                         <xsl:matching-substring><xsl:text>|K*ø*benhavn</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Kjø">
                         <xsl:matching-substring><xsl:text>|kø</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="K*ø*benhavn">
                         <xsl:matching-substring><xsl:text>|København</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=". kø">
                         <xsl:matching-substring><xsl:text>|. Kø</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="gje">
                         <xsl:matching-substring><xsl:text>|ge</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Gje">
                         <xsl:matching-substring><xsl:text>|ge</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=". ge">
                         <xsl:matching-substring><xsl:text>|. Ge</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="gjæ">
                         <xsl:matching-substring><xsl:text>|gæ</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Gjæ">
                         <xsl:matching-substring><xsl:text>|gæ</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=". gæ">
                         <xsl:matching-substring><xsl:text>|. Gæ</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="gjø">
                         <xsl:matching-substring><xsl:text>|gø</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Gjø">
                         <xsl:matching-substring><xsl:text>|gø</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=". gø">
                         <xsl:matching-substring><xsl:text>|. Gø</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="deig">
                         <xsl:matching-substring><xsl:text>|dej</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="seig">
                         <xsl:matching-substring><xsl:text>|sej</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="øi">
                         <xsl:matching-substring><xsl:text>|øj</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Øi">
                         <xsl:matching-substring><xsl:text>|øj</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="ein">
                         <xsl:matching-substring><xsl:text>|e*in</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Freia">
                         <xsl:matching-substring><xsl:text>|Fre*ia</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Marseillaisen">
                         <xsl:matching-substring><xsl:text>|Marse*illaisen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Meiringen">
                         <xsl:matching-substring><xsl:text>|Me*iringen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Heiberg">
                         <xsl:matching-substring><xsl:text>|He*iberg</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="heim">
                         <xsl:matching-substring><xsl:text>|he*im</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="lein">
                         <xsl:matching-substring><xsl:text>|le*in</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="peiter">
                         <xsl:matching-substring><xsl:text>|pe*iter</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Peiter">
                         <xsl:matching-substring><xsl:text>|Pe*iter</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Seid">
                         <xsl:matching-substring><xsl:text>|Se*id</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="wei">
                         <xsl:matching-substring><xsl:text>|we*i</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Wei">
                         <xsl:matching-substring><xsl:text>|We*i</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="weide">
                         <xsl:matching-substring><xsl:text>|we*ide</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="weig">
                         <xsl:matching-substring><xsl:text>|we*ig</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="ei">
                         <xsl:matching-substring><xsl:text>|ej</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="e*i">
                         <xsl:matching-substring><xsl:text>|ei</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="qv">
                         <xsl:matching-substring><xsl:text>|kv</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Qv">
                         <xsl:matching-substring><xsl:text>|Kv</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="voxte">
                         <xsl:matching-substring><xsl:text>|voksede</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="x">
                         <xsl:matching-substring><xsl:text>|ks</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="angest">
                         <xsl:matching-substring><xsl:text>|angst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Angest">
                         <xsl:matching-substring><xsl:text>|angst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="døer">
                         <xsl:matching-substring><xsl:text>|dør</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="foer">
                         <xsl:matching-substring><xsl:text>|for</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="muel">
                         <xsl:matching-substring><xsl:text>|mul</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Muel">
                         <xsl:matching-substring><xsl:text>|Mul</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="boer ">
                         <xsl:matching-substring><xsl:text>|bor </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="moer">
                         <xsl:matching-substring><xsl:text>|mor</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="groer">
                         <xsl:matching-substring><xsl:text>|gror</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="troer">
                         <xsl:matching-substring><xsl:text>|tror</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Troer">
                         <xsl:matching-substring><xsl:text>|Tror</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Roes">
                         <xsl:matching-substring><xsl:text>|ros</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="vaer">
                         <xsl:matching-substring><xsl:text>|var</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="øe ">
                         <xsl:matching-substring><xsl:text>|ø </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="øe,">
                         <xsl:matching-substring><xsl:text>|ø,</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="øe;">
                         <xsl:matching-substring><xsl:text>|ø;</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="øe.">
                         <xsl:matching-substring><xsl:text>|ø.</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="øe!">
                         <xsl:matching-substring><xsl:text>|ø!</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="oe ">
                         <xsl:matching-substring><xsl:text>|oe </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="oe.">
                         <xsl:matching-substring><xsl:text>|oe.</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="bjel">
                         <xsl:matching-substring><xsl:text>|bjæl</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Bjel">
                         <xsl:matching-substring><xsl:text>|bjæl</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Fjæder">
                         <xsl:matching-substring><xsl:text>|fjeder</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Flesk">
                         <xsl:matching-substring><xsl:text>|flæsk</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Gest">
                         <xsl:matching-substring><xsl:text>| gæst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" gest">
                         <xsl:matching-substring><xsl:text>| gæst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="geld">
                         <xsl:matching-substring><xsl:text>|gæld</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Geld">
                         <xsl:matching-substring><xsl:text>|Gæld</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="gette">
                         <xsl:matching-substring><xsl:text>|gætte</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="helde">
                         <xsl:matching-substring><xsl:text>|hælde</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="hengst">
                         <xsl:matching-substring><xsl:text>|hingst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="hjelp">
                         <xsl:matching-substring><xsl:text>|hjælp</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kjep">
                         <xsl:matching-substring><xsl:text>|kep</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="klokkeslet">
                         <xsl:matching-substring><xsl:text>|klokkeslæt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="knegt">
                         <xsl:matching-substring><xsl:text>|knægt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="melk">
                         <xsl:matching-substring><xsl:text>|mælk</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="nelde">
                         <xsl:matching-substring><xsl:text>|nælde</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="neppe">
                         <xsl:matching-substring><xsl:text>|næppe</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Reelingen">
                         <xsl:matching-substring><xsl:text>|rælingen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="sjeld">
                         <xsl:matching-substring><xsl:text>|sjæld</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="skeppe">
                         <xsl:matching-substring><xsl:text>|skæppe</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="skev">
                         <xsl:matching-substring><xsl:text>|skæv</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="snev">
                         <xsl:matching-substring><xsl:text>|snæv</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="stræng">
                         <xsl:matching-substring><xsl:text>|streng</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Vert">
                         <xsl:matching-substring><xsl:text>| Vært</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" vert">
                         <xsl:matching-substring><xsl:text>| vært</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="ii">
                         <xsl:matching-substring><xsl:text>|i</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Ii">
                         <xsl:matching-substring><xsl:text>|I</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="uud">
                         <xsl:matching-substring><xsl:text>|u*ud</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="uu">
                         <xsl:matching-substring><xsl:text>|u</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="u*ud">
                         <xsl:matching-substring><xsl:text>|uud</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kkr">
                         <xsl:matching-substring><xsl:text>|kr</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="ppr">
                         <xsl:matching-substring><xsl:text>|pr</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="bittre">
                         <xsl:matching-substring><xsl:text>|bitre</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="døttre">
                         <xsl:matching-substring><xsl:text>|døtre</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="gittre">
                         <xsl:matching-substring><xsl:text>|gitre</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="knittre">
                         <xsl:matching-substring><xsl:text>|knitre</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="sittre">
                         <xsl:matching-substring><xsl:text>|sitre</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="zittre">
                         <xsl:matching-substring><xsl:text>|sitre</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="dands">
                         <xsl:matching-substring><xsl:text>|dans</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="glands">
                         <xsl:matching-substring><xsl:text>|glans</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="glindse">
                         <xsl:matching-substring><xsl:text>|glinse</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="grændse">
                         <xsl:matching-substring><xsl:text>|grænse</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kladsk">
                         <xsl:matching-substring><xsl:text>|klask</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="krands">
                         <xsl:matching-substring><xsl:text>|krans</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kudsk">
                         <xsl:matching-substring><xsl:text>|kusk</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="lædsk">
                         <xsl:matching-substring><xsl:text>|læsk</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="pladsk">
                         <xsl:matching-substring><xsl:text>|plask</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="pidsk">
                         <xsl:matching-substring><xsl:text>|pisk</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="prinds">
                         <xsl:matching-substring><xsl:text>|prins</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="provinds">
                         <xsl:matching-substring><xsl:text>|provins</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="sandse">
                         <xsl:matching-substring><xsl:text>|sanse</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="skøndt">
                         <xsl:matching-substring><xsl:text>|skønt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="svedske">
                         <xsl:matching-substring><xsl:text>|sveske</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="tidt">
                         <xsl:matching-substring><xsl:text>|tit</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="todt">
                         <xsl:matching-substring><xsl:text>|tot</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="ct">
                         <xsl:matching-substring><xsl:text>|kt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="chor">
                         <xsl:matching-substring><xsl:text>|kor</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="con">
                         <xsl:matching-substring><xsl:text>|kon</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="copi">
                         <xsl:matching-substring><xsl:text>|kopi</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="chines">
                         <xsl:matching-substring><xsl:text>|kines</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="christn">
                         <xsl:matching-substring><xsl:text>|kristn</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="cava">
                         <xsl:matching-substring><xsl:text>|kava</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="comedie">
                         <xsl:matching-substring><xsl:text>|komedie</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="command">
                         <xsl:matching-substring><xsl:text>|kommand</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="capel">
                         <xsl:matching-substring><xsl:text>|kapel</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="elect">
                         <xsl:matching-substring><xsl:text>|elekt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="loco">
                         <xsl:matching-substring><xsl:text>|loko</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Ph">
                         <xsl:matching-substring><xsl:text>|F</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="raph">
                         <xsl:matching-substring><xsl:text>|raf</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="soph">
                         <xsl:matching-substring><xsl:text>|sof</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="meur">
                         <xsl:matching-substring><xsl:text>|mør</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="raison">
                         <xsl:matching-substring><xsl:text>|ræson</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" vare ">
                         <xsl:matching-substring><xsl:text>| var </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" vare.">
                         <xsl:matching-substring><xsl:text>| var.</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" vare!">
                         <xsl:matching-substring><xsl:text>| var!</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" vare,">
                         <xsl:matching-substring><xsl:text>| var,</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" vare;">
                         <xsl:matching-substring><xsl:text>| var;</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" ere ">
                         <xsl:matching-substring><xsl:text>| er </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" bleve ">
                         <xsl:matching-substring><xsl:text>| blev </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="såe ">
                         <xsl:matching-substring><xsl:text>|så </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" såe.">
                         <xsl:matching-substring><xsl:text>| så.</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" såe,">
                         <xsl:matching-substring><xsl:text>| så,</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="stode ">
                         <xsl:matching-substring><xsl:text>|stod </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="stode.">
                         <xsl:matching-substring><xsl:text>|stod.</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="stode,">
                         <xsl:matching-substring><xsl:text>|stod,</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" lagte ">
                         <xsl:matching-substring><xsl:text>| lagt </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" sade ">
                         <xsl:matching-substring><xsl:text>| sad </xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" skrede">
                         <xsl:matching-substring><xsl:text>| skred</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" lode">
                         <xsl:matching-substring><xsl:text>| lod</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="vi have">
                         <xsl:matching-substring><xsl:text>|vi har</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="fornam">
                         <xsl:matching-substring><xsl:text>|fornemmede</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="havt">
                         <xsl:matching-substring><xsl:text>|haft</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="goel">
                         <xsl:matching-substring><xsl:text>|galede</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="flokkerne">
                         <xsl:matching-substring><xsl:text>|flokkene</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="altfor">
                         <xsl:matching-substring><xsl:text>|alt for</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="altsammen">
                         <xsl:matching-substring><xsl:text>|alt sammmen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="efterat">
                         <xsl:matching-substring><xsl:text>|efter at</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="desmere">
                         <xsl:matching-substring><xsl:text>|des mere</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="desmindre">
                         <xsl:matching-substring><xsl:text>|des mindre</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" iaft">
                         <xsl:matching-substring><xsl:text>| iaft</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" Iaft">
                         <xsl:matching-substring><xsl:text>| I aft</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="idag">
                         <xsl:matching-substring><xsl:text>|i dag</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Idag">
                         <xsl:matching-substring><xsl:text>|I dag</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="igår">
                         <xsl:matching-substring><xsl:text>|i går</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Igår">
                         <xsl:matching-substring><xsl:text>|I går</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="imorgen">
                         <xsl:matching-substring><xsl:text>|i morgen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Imorgen">
                         <xsl:matching-substring><xsl:text>|I morgen</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="istedetfor">
                         <xsl:matching-substring><xsl:text>|i stedet for</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="isøvn">
                         <xsl:matching-substring><xsl:text>|i søvn</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" iøvrigt">
                         <xsl:matching-substring><xsl:text>| i øvrigt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex=" ivej">
                         <xsl:matching-substring><xsl:text>| i vej</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="såmeget">
                         <xsl:matching-substring><xsl:text>|så meget</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="sålangt">
                         <xsl:matching-substring><xsl:text>|så langt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="sålænge">
                         <xsl:matching-substring><xsl:text>|så længe</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="såmeget">
                         <xsl:matching-substring><xsl:text>|så meget</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="såsandt">
                         <xsl:matching-substring><xsl:text>|så sandt</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="såsnart">
                         <xsl:matching-substring><xsl:text>|så snart</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="tilside">
                         <xsl:matching-substring><xsl:text>|til side</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="tilsidst">
                         <xsl:matching-substring><xsl:text>|til sidst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Tilsidst">
                         <xsl:matching-substring><xsl:text>|Til sidst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="akasie">
                         <xsl:matching-substring><xsl:text>|akacie</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="boutik">
                         <xsl:matching-substring><xsl:text>|butik</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kalosk">
                         <xsl:matching-substring><xsl:text>|galoch</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kastanie">
                         <xsl:matching-substring><xsl:text>|kastanje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="lillie">
                         <xsl:matching-substring><xsl:text>|lilje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="lilie">
                         <xsl:matching-substring><xsl:text>|lilje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="linie">
                         <xsl:matching-substring><xsl:text>|linje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="løgte">
                         <xsl:matching-substring><xsl:text>|lygte</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="matras">
                         <xsl:matching-substring><xsl:text>|madras</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="medaille">
                         <xsl:matching-substring><xsl:text>|medalje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="militair">
                         <xsl:matching-substring><xsl:text>|militær</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="minuter">
                         <xsl:matching-substring><xsl:text>|minutter</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="musiken">
                         <xsl:matching-substring><xsl:text>|musikken</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="forbause">
                         <xsl:matching-substring><xsl:text>|forbavse</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="Fønix">
                         <xsl:matching-substring><xsl:text>|Føniks</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="gletscher">
                         <xsl:matching-substring><xsl:text>|gletsjer</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="kige">
                         <xsl:matching-substring><xsl:text>|kigge</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="konst">
                         <xsl:matching-substring><xsl:text>|kunst</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="lieutenant">
                         <xsl:matching-substring><xsl:text>|løjtnant</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="literatur">
                         <xsl:matching-substring><xsl:text>|litteratur</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="marsch">
                         <xsl:matching-substring><xsl:text>|march</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="punsch">
                         <xsl:matching-substring><xsl:text>|punch</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="sadde">
                         <xsl:matching-substring><xsl:text>|satte</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="sadte">
                         <xsl:matching-substring><xsl:text>|satte</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="skruptudse">
                         <xsl:matching-substring><xsl:text>|skrubtudse</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="såmæn">
                         <xsl:matching-substring><xsl:text>|såmænd</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="tour">
                         <xsl:matching-substring><xsl:text>|tur</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="tredie">
                         <xsl:matching-substring><xsl:text>|tredje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="oug">
                         <xsl:matching-substring><xsl:text>|ov</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="uhr">
                         <xsl:matching-substring><xsl:text>|ur</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="villie">
                         <xsl:matching-substring><xsl:text>|vilje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()">
                    <xsl:analyze-string select="." regex="vilie">
                         <xsl:matching-substring><xsl:text>|vilje</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template><xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()" priority="8">
                    <xsl:analyze-string select="." regex=" ædder">
                         <xsl:matching-substring><xsl:text>| edder</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template>
     <xsl:template match="TEI:body//(TEI:p|TEI:seg|TEI:l|TEI:head)/text()" priority="7">
                    <xsl:analyze-string select="." regex="ægyp">
                         <xsl:matching-substring><xsl:text>|egyp</xsl:text></xsl:matching-substring>
                         <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                    </xsl:analyze-string>
                    </xsl:template>
</xsl:stylesheet>