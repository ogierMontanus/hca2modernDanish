<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:exsl="http://exslt.org/common"
     xmlns:dps="dps:dps">
     <!--xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:TEI="http://www.tei-c.org/ns/1.0"      
     -->
     <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
     
     <!--
        The original version of this code was published by Ibrahim Naji (http://thinknook.com/xslt-replace-multiple-strings-2010-09-07/).
        It works but suffered the limitation of only being able to supply a single replacement text. An alternative implementation, which
        did allow find/replace pairs to be specified, was published by Dimitre Novatchev
        (https://stackoverflow.com/questions/5213644/xslt-multiple-string-replacement-with-recursion).
        However, that implementation suffers from stack overflow problems if the node contains more than a few hundred bytes of text (and
        in my case I needed to process nodes which could include several kb of data). Hence this version which combines the best features
        of both implementations.

        John Cullen, 14 July 2017.
     -->
     
     <!-- IdentityTransform, copy the input to the output -->
     <xsl:template match="@*|node()">
          <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
     </xsl:template>
     
     <xsl:template match="/">
          
          <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="../css/oxyAuthorEditMinimumHCA.css"</xsl:processing-instruction>
          <xsl:apply-templates select="@*|node()"/>
          <xsl:text><?oxy_options track_changes="on"?></xsl:text>
     </xsl:template>
          
     <!-- Process all text nodes. -->
     <xsl:template match="text()">
          <xsl:call-template name="string-replace-all">
               <xsl:with-param name="text" select="."/>
          </xsl:call-template>
     </xsl:template>
     
     <!-- Table of replacement patterns -->
     <xsl:variable name="vPatterns">
          <dps:patterns>
               <pattern>
                    <old>ct</old>
                    <new>kt</new><!-- pipe should be placed at one spot-->
               </pattern>
               <!--preamble ee > e-->
               <pattern>
                    <old>Meen</old>
                    <new>mén</new>
               </pattern>
               <pattern>
                    <old>Maneer</old>
                    <new>manér</new>
               </pattern>
               <!--<pattern>
                    <old>Theepotte</old>
                    <new>Tepotte</new>
               </pattern>
               <pattern>
                    <old>Hyldethee</old>
                    <new>hyldete</new>
               </pattern>
               <pattern>
                    <old>Theemaskinen</old>
                    <new>Temaskinen</new>
               </pattern>
               <pattern>
                    <old>Thee</old>
                    <new>te</new>
               </pattern>-->
               <pattern>
                    <old>Thee</old>
                    <new>te</new>
               </pattern>
               <pattern>
                    <old>Reelingen</old>
                    <new>rælingen</new>
               </pattern>
               <pattern>
                    <old>leet</old>
                    <new>leeet</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old>leende</old>
                    <new>leeende</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old>Ideen</old>
                    <new>ideeen</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old> Fee</old>
                    <new> Feee</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old> Feen</old>
                    <new> Feeen</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old>Seer</old>
                    <new>Seeer</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old>besneede</old>
                    <new>tilsneeede</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old>Sneen</old>
                    <new>sneeen</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old>Beeren</old>
                    <new>Beeeren</new><!--eee should be replaced to ee-->
               </pattern>
               <pattern>
                    <old>Hveen</old>
                    <new>Hven</new><!--formal spelling: Ven. Keep the H in the proper noun due to autoreplacement of noun Ven > ven -->
               </pattern>
               <pattern>
                    <old>Kaffeen</old>
                    <new>caféen</new>
               </pattern>
               <pattern>
                    <old>Cafeer</old>
                    <new>caféer</new>
               </pattern>
               <pattern>
                    <old>Alleer</old>
                    <new>alléer</new>
               </pattern>
               <pattern>
                    <old>Alleen</old>
                    <new>alléen</new>
               </pattern>
               <pattern>
                    <old>Allee </old>
                    <new>allé </new>
               </pattern>
               <pattern>
                    <old>desmeer</old>
                    <new>desmere</new>
               </pattern><pattern>
                    <old>Fricasee</old>
                    <new>frikassé</new>
               </pattern>
               <pattern>
                    <old> reele</old>
                    <new> reeele</new>
               </pattern>
               <pattern>
                    <old>Reele</old>
                    <new>Reeele</new>
               </pattern>
               <pattern>
                    <old> Udseende</old>
                    <new> udseeende</new>
               </pattern>
               <pattern>
                    <old> Forseelse</old>
                    <new> forseeelse</new>
               </pattern>
               <!--end of preamble ee> e-->
               <pattern>
                    <old>ee</old>
                    <new>e</new>
               </pattern>
               <!--beginning of postludium ee> e-->
               
               <!--<pattern>
                    <old> Then</old>
                    <new> teen</new>
               </pattern>-->
               <!--<pattern>
                    <old> Aftenthen</old>
                    <new> aftenteen</new>
               </pattern>-->
               <!--<pattern>
                    <old> besnede</old>
                    <new> besneede</new>
               </pattern>-->
               
               
               <!--end of postludium ee> e-->
               <pattern>
                    <old>kie</old>
                    <new>ke</new><!-- pipe should be placed at one spot-->
               </pattern>
               <pattern>
                    <old>oug</old>
                    <new>ov</new>
               </pattern>
               <pattern>
                    <old>Ph</old>
                    <new>F</new>
               </pattern>
               <pattern>
                    <old>raph</old>
                    <new>raf</new>
               </pattern>
               <pattern>
                    <old>soph</old>
                    <new>sof</new>
               </pattern>
               <pattern>
                    <old>aa</old>
                    <new>å</new>
               </pattern>
               <pattern>
                    <old>Aa</old>
                    <new>Å</new>
               </pattern>
               <pattern>
                    <old> eet</old>
                    <new> ét</new>
               </pattern>
               <pattern>
                    <old>ö</old>
                    <new>ø</new>
               </pattern>
               <pattern>
                    <old>muel</old>
                    <new>mul</new>
               </pattern>
               <!--<pattern>
                    <old>&lt;/b&gt;</old>
                    <new>&lt;/strong&gt;</new>
               </pattern>-->
               
               <pattern>
                    <old>foer</old>
                    <new>for</new>
               </pattern>
               <pattern>
                    <old>Roes</old>
                    <new>ros</new>
               </pattern>
               <pattern>
                    <old>vaer</old>
                    <new>var</new>
               </pattern>
               
               <!--e > æ, råskitse-->
               <pattern>
                    <old>bjel</old>
                    <new>bjæl</new>
               </pattern>
               <pattern>
                    <old>Bjel</old>
                    <new>Bjæl</new>
               </pattern>
               
               <!-- Endelse -e pluralis i ubestemt form-->
               <pattern>
                    <old>skoe </old>
                    <new>sko </new>
               </pattern>
               
               <!--dobbeltkonsonant, råskitse-->
               <pattern>
                    <old>bittre</old>
                    <new>bitre</new>
               </pattern>
               <!--præsens og præteritum pluralis, råskitse -->
               <pattern>
                    <old> vare </old>
                    <new> var </new>
               </pattern>
               <pattern>
                    <old> ere </old>
                    <new> er </new>
               </pattern>
          </dps:patterns>
     </xsl:variable>
     
     <!--
        Convert the internal table into a node-set. This could also be done via a call to document()
        for example select="document('')/*/myns:params/*" with a suitable namespace declaration, but
        in my case that was not possible because the code is being used in with a StreamSource.
     -->
     <xsl:variable name="vPats" select="exsl:node-set($vPatterns)/dps:patterns/*"/>
     
     <!-- This template matches all text() nodes, and calls itself recursively to performs the actual replacements. -->
     <xsl:template name="string-replace-all">
          <xsl:param name="text"/>
          <xsl:param name="pos" select="1"/>
          <xsl:variable name="replace" select="$vPats[$pos]/old"/>
          <xsl:variable name="by" select="$vPats[$pos]/new"/>
          <xsl:choose>
               
               <!-- Ignore empty strings -->
               <xsl:when test="string-length(translate(normalize-space($text), ' ', '')) = 0"> 
                    <xsl:value-of select="$text"/>
               </xsl:when>
               
               <!-- Return the unchanged text if the replacement is larger than the input (so no match possible) -->
               <xsl:when test="string-length($replace) > string-length($text)">
                    <xsl:value-of select="$text"/>
               </xsl:when>
               
               <!-- If the current text contains the next pattern -->
               <xsl:when test="contains($text, $replace)">
                    <!-- Perform a recursive call, each time replacing the next occurrence of the current pattern -->
                    <xsl:call-template name="string-replace-all">
                         <xsl:with-param name="text" select="concat(substring-before($text,$replace),'|',$by,'|',substring-after($text,$replace))"/>
                         <xsl:with-param name="pos" select="$pos"/>
                    </xsl:call-template>
               </xsl:when>
               
               <!-- No (more) matches found -->
               <xsl:otherwise>
                    <!-- Bump the counter to pick up the next pattern we want to search for -->
                    <xsl:variable name="next" select="$pos+1"/>
                    <xsl:choose>
                         <!-- If we haven't finished yet, perform a recursive call to process the next pattern in the list. -->
                         <xsl:when test="boolean($vPats[$next])">
                              <xsl:call-template name="string-replace-all">
                                   <xsl:with-param name="text" select="$text"/>
                                   <xsl:with-param name="pos" select="$next"/>
                              </xsl:call-template>
                         </xsl:when>
                         
                         <!-- No more patterns, we're done. Return the fully processed text. -->
                         <xsl:otherwise>
                              <xsl:value-of select="$text"/>
                         </xsl:otherwise>
                    </xsl:choose>
               </xsl:otherwise>
          </xsl:choose>
     </xsl:template>
</xsl:stylesheet>