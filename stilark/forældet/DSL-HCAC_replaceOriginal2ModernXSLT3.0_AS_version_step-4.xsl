<?xml version="1.0"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:exsl="http://exslt.org/common" xmlns:dps="dps:dps">
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
     <xsl:template match="@* | node()">
          <xsl:copy>
               <xsl:apply-templates select="@* | node()"/>
          </xsl:copy>
     </xsl:template>

     <xsl:template match="/">

          
          <xsl:apply-templates select="@* | node()"/>
          
     </xsl:template>

     <!-- Process all text nodes. -->
     <xsl:template match="text()">
          <xsl:call-template name="string-replace-all">
               <xsl:with-param name="text" select="."/>
          </xsl:call-template>
     </xsl:template>

     <!-- Table of replacement patterns -->
     <!-- 
          AS NB (30-06-23): Replacement patterns should only replace words placed in <p>-tags, i.e. text should not be replaced
          if placed within the following tags:
          <l> 
          <hi rend> 
          ... This in order not to mess with "<?oxy_delete" for instance. 
          
          Questions:
          1) Should capital letters be retained in the search and replace patterns? We have to make sure that we don't replace capital
          letters placed after punctuation.
          
          2) Er line toggle + linjeafstand muligt?
     -->

     <xsl:variable name="vPatterns">
          <dps:patterns>
               


               <!-- e > æ and vice versa. NB! Make sure gj/kj > g/k has already been applied-->
               <pattern>
                    <old>bjel</old>
                    <new>bjæl</new>
               </pattern>
               <pattern>
                    <old>Bjel</old>
                    <new>bjæl</new>
               </pattern>
               <pattern>
                    <old>Fjæder</old>
                    <new>fjeder</new>
               </pattern>
               <pattern>
                    <old>Flesk</old>
                    <new>flæsk</new>
               </pattern>
               <pattern>
                    <old> Gest</old>
                    <new> gæst</new>
               </pattern>
               <pattern>
                    <old> gest</old>
                    <new> gæst</new>
               </pattern>
               <pattern>
                    <old>geld</old>
                    <new>gæld</new>
               </pattern>
               <pattern>
                    <old>Geld</old>
                    <new>Gæld</new>
               </pattern>
               <pattern>
                    <old>gette</old>
                    <new>gætte</new>
               </pattern>
               <pattern>
                    <old>helde</old>
                    <new>hælde</new>
               </pattern>
               <pattern>
                    <old>hengst</old>
                    <new>hingst</new>
               </pattern>
               <pattern>
                    <old>hjelp</old>
                    <new>hjælp</new>
               </pattern>
               <pattern>
                    <old>kjep</old>
                    <new>kep</new>
               </pattern>
               <pattern>
                    <old>klokkeslet</old>
                    <new>klokkeslæt</new>
               </pattern>
               <pattern>
                    <old>knegt</old>
                    <new>knægt</new>
               </pattern>
               <pattern>
                    <old>melk</old>
                    <new>mælk</new>
               </pattern>
               <pattern>
                    <old>nelde</old>
                    <new>nælde</new>
               </pattern>
               <pattern>
                    <old>neppe</old>
                    <new>næppe</new>
               </pattern>
               <pattern>
                    <old>Reelingen</old>
                    <new>rælingen</new>
               </pattern>
               <pattern>
                    <old>sjeld</old>
                    <new>sjæld</new>
               </pattern>
               <pattern>
                    <old>skeppe</old>
                    <new>skæppe</new>
               </pattern>
               <pattern>
                    <old>skev</old>
                    <new>skæv</new>
               </pattern>
               <pattern>
                    <old>snev</old>
                    <new>snæv</new>
               </pattern>
               <pattern>
                    <old>stræng</old>
                    <new>streng</new>
               </pattern>
               <pattern>
                    <old> Vert</old>
                    <new> Vært</new>
               </pattern>
               <pattern>
                    <old> vert</old>
                    <new> vært</new>
               </pattern>

               <!-- Wowel duplication-->
               <!-- ii > i -->
               <pattern>
                    <old>ii</old>
                    <new>i</new>
               </pattern>

               <pattern>
                    <old>Ii</old>
                    <new>I</new>
               </pattern>

               <pattern>
                    <old>uud</old>
                    <new>u*ud</new>
                    <!-- To keep words where uu is correct -->
               </pattern>
               <pattern>
                    <old>uu</old>
                    <new>u</new>
               </pattern>
               <pattern>
                    <old>u*ud</old>
                    <new>uud</new>
                    <!-- To keep words where uu is correct -->
               </pattern>


               <!-- Consonant duplication -->
               <pattern>
                    <old>kkr</old>
                    <new>kr</new>
               </pattern>
               <pattern>
                    <old>ppr</old>
                    <new>pr</new>
               </pattern>
               <!--<pattern>
                    <old>bittre</old>
                    <new>bitre</new>
               </pattern>
               <pattern>
                    <old>døttre</old>
                    <new>døtre</new>
               </pattern>
               <pattern>
                    <old>gittre</old>
                    <new>gitre</new>
               </pattern>
               <pattern>
                    <old>knittre</old>
                    <new>knitre</new>
               </pattern>
               <pattern>
                    <old>sittre</old>
                    <new>sitre</new>
               </pattern>
               <pattern>
                    <old>zittre</old>
                    <new>sitre</new>
               </pattern>

               <!-\- Ord med stumt d. NB! Make sure kj > k has been applied-\->
               <pattern>
                    <old>dands</old>
                    <new>dans</new>
               </pattern>
               <pattern>
                    <old>glands</old>
                    <new>glans</new>
               </pattern>
               <pattern>
                    <old>glindse</old>
                    <new>glinse</new>
               </pattern>
               <pattern>
                    <old>grændse</old>
                    <new>grænse</new>
               </pattern>
               <pattern>
                    <old>kladsk</old>
                    <new>klask</new>
               </pattern>
               <pattern>
                    <old>krands</old>
                    <new>krans</new>
               </pattern>
               <pattern>
                    <old>kudsk</old>
                    <new>kusk</new>
               </pattern>
               <pattern>
                    <old>lædsk</old>
                    <new>læsk</new>
               </pattern>
               <pattern>
                    <old>pladsk</old>
                    <new>plask</new>
               </pattern>
               <pattern>
                    <old>pidsk</old>
                    <new>pisk</new>
               </pattern>
               <pattern>
                    <old>prinds</old>
                    <new>prins</new>
               </pattern>
               <pattern>
                    <old>provinds</old>
                    <new>provins</new>
               </pattern>
               <pattern>
                    <old>sandse</old>
                    <new>sanse</new>
               </pattern>
               <pattern>
                    <old>skøndt</old>
                    <new>skønt</new>
               </pattern>
               <pattern>
                    <old>svedske</old>
                    <new>sveske</new>
               </pattern>
               <pattern>
                    <old>tidt</old>
                    <new>tit</new>
               </pattern>
               <pattern>
                    <old>todt</old>
                    <new>tot</new>
               </pattern>

               <!-\- c > k -\->
               <pattern>
                    <old>ct</old>
                    <new>kt</new>
                    <!-\- pipe should be placed at one spot-\->
               </pattern>
               <pattern>
                    <old>chor</old>
                    <new>kor</new>
               </pattern>
               <pattern>
                    <old>con</old>
                    <!-\- search pattern will replace a few words that shouldn't be replaced, i.e. convolvoli/convolvolus/connetable-\->
                    <new>kon</new>
               </pattern>
               <pattern>
                    <old>copi</old>
                    <new>kopi</new>
               </pattern>
               <pattern>
                    <old>chines</old>
                    <new>kines</new>
               </pattern>
               <pattern>
                    <old>christn</old>
                    <new>kristn</new>
               </pattern>
               <pattern>
                    <old>cava</old>
                    <new>kava</new>
               </pattern>
               <pattern>
                    <old>comedie</old>
                    <new>komedie</new>
               </pattern>
               <pattern>
                    <old>command</old>
                    <new>kommand</new>
               </pattern>
               <pattern>
                    <old>capel</old>
                    <new>kapel</new>
               </pattern>
               <pattern>
                    <old>elect</old>
                    <new>elekt</new>
               </pattern>
               <pattern>
                    <old>loco</old>
                    <new>loko</new>
               </pattern>

               <!-\- ph > f -\->
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


               <!-\- eur > ør; ai > æ -\->
               <pattern>
                    <old>meur</old>
                    <new>mør</new>
               </pattern>
               <pattern>
                    <old>raison</old>
                    <new>ræson</new>
               </pattern>

               <!-\-præsens og præteritum pluralis, råskitse. NB! Make sure aa > å has been applied -\->
               <pattern>
                    <old> vare </old>
                    <new> var </new>
               </pattern>
               <pattern>
                    <old> vare.</old>
                    <new> var.</new>
               </pattern>
               <pattern>
                    <old> vare!</old>
                    <new> var!</new>
               </pattern>
               <pattern>
                    <old> vare,</old>
                    <new> var,</new>
               </pattern>
               <pattern>
                    <old> vare;</old>
                    <new> var;</new>
               </pattern>
               <pattern>
                    <old> ere </old>
                    <new> er </new>
               </pattern>
               <pattern>
                    <old> bleve </old>
                    <new> blev </new>
               </pattern>
               <pattern>
                    <old>såe </old>
                    <new>så </new>
               </pattern>
               <pattern>
                    <old> såe.</old>
                    <new> så.</new>
               </pattern>
               <pattern>
                    <old> såe,</old>
                    <new> så,</new>
               </pattern>
               <pattern>
                    <old>stode </old>
                    <new>stod </new>
               </pattern>
               <pattern>
                    <old>stode.</old>
                    <new>stod.</new>
               </pattern>
               <pattern>
                    <old>stode,</old>
                    <new>stod,</new>
               </pattern>
               <pattern>
                    <old> lagte </old>
                    <new> lagt </new>
               </pattern>
               <pattern>
                    <old> sade </old>
                    <new> sad </new>
               </pattern>
               <pattern>
                    <old> skrede</old>
                    <new> skred</new>
               </pattern>
               <pattern>
                    <old> lode</old>
                    <new> lod</new>
               </pattern>
               <pattern>
                    <old>vi have</old>
                    <new>vi har</new>
               </pattern>

               <!-\- obsolete conjugation, råskitse -\->
               <pattern>
                    <old>fornam</old>
                    <new>fornemmede</new>
               </pattern>
               <pattern>
                    <old>havt</old>
                    <new>haft</new>
               </pattern>
               <pattern>
                    <old>goel</old>
                    <new>galede</new>
               </pattern>

               <!-\- general conjugation, råskitse -\->
               <pattern>
                    <old>flokkerne</old>
                    <new>flokkene</new>
               </pattern>

               <!-\-one word or two words, råskitse. NB! Make sure aa > å has been applied -\->
               <pattern>
                    <old>altfor</old>
                    <new>alt for</new>
               </pattern>
               <pattern>
                    <old>altsammen</old>
                    <new>alt sammmen</new>
               </pattern>
               <pattern>
                    <old>efterat</old>
                    <new>efter at</new>
               </pattern>
               <pattern>
                    <old>desmere</old>
                    <new>des mere</new>
               </pattern>
               <pattern>
                    <old>desmindre</old>
                    <new>des mindre</new>
               </pattern>
               <pattern>
                    <old> iaft</old>
                    <new> iaft</new>
               </pattern>
               <pattern>
                    <old> Iaft</old>
                    <new> I aft</new>
               </pattern>
               <pattern>
                    <old>idag</old>
                    <new>i dag</new>
               </pattern>
               <pattern>
                    <old>Idag</old>
                    <new>I dag</new>
               </pattern>
               <pattern>
                    <old>igår</old>
                    <new>i går</new>
               </pattern>
               <pattern>
                    <old>Igår</old>
                    <new>I går</new>
               </pattern>
               <pattern>
                    <old>imorgen</old>
                    <new>i morgen</new>
               </pattern>
               <pattern>
                    <old>Imorgen</old>
                    <new>I morgen</new>
               </pattern>
               <pattern>
                    <old>istedetfor</old>
                    <new>i stedet for</new>
               </pattern>
               <pattern>
                    <old>isøvn</old>
                    <new>i søvn</new>
               </pattern>
               <pattern>
                    <old> iøvrigt</old>
                    <new> i øvrigt</new>
               </pattern>
               <pattern>
                    <old> ivej</old>
                    <new> i vej</new>
               </pattern>
               <pattern>
                    <old>såmeget</old>
                    <new>så meget</new>
               </pattern>
               <pattern>
                    <old>sålangt</old>
                    <new>så langt</new>
               </pattern>
               <pattern>
                    <old>sålænge</old>
                    <new>så længe</new>
               </pattern>
               <pattern>
                    <old>såmeget</old>
                    <new>så meget</new>
               </pattern>
               <pattern>
                    <old>såsandt</old>
                    <new>så sandt</new>
               </pattern>
               <pattern>
                    <old>såsnart</old>
                    <new>så snart</new>
               </pattern>
               <pattern>
                    <old>tilside</old>
                    <new>til side</new>
               </pattern>
               <pattern>
                    <old>tilsidst</old>
                    <new>til sidst</new>
               </pattern>
               <pattern>
                    <old>Tilsidst</old>
                    <new>Til sidst</new>
               </pattern>


               <!-\- general spelling, råskitse -\->
               <pattern>
                    <old>akasie</old>
                    <new>akacie</new>
               </pattern>
               <pattern>
                    <old>boutik</old>
                    <new>butik</new>
               </pattern>
               <pattern>
                    <old>kalosk</old>
                    <new>galoch</new>
               </pattern>
               <pattern>
                    <old>kastanie</old>
                    <new>kastanje</new>
               </pattern>
               <pattern>
                    <old>lillie</old>
                    <new>lilje</new>
               </pattern>
               <pattern>
                    <old>lilie</old>
                    <new>lilje</new>
               </pattern>
               <pattern>
                    <old>linie</old>
                    <new>linje</new>
               </pattern>
               <pattern>
                    <old>løgte</old>
                    <new>lygte</new>
               </pattern>
               <pattern>
                    <old>matras</old>
                    <new>madras</new>
               </pattern>
               <pattern>
                    <old>medaille</old>
                    <new>medalje</new>
               </pattern>
               <pattern>
                    <old>militair</old>
                    <new>militær</new>
               </pattern>
               <pattern>
                    <old>minuter</old>
                    <new>minutter</new>
               </pattern>
               <pattern>
                    <old>musiken</old>
                    <new>musikken</new>
               </pattern>
               <pattern>
                    <old>forbause</old>
                    <new>forbavse</new>
               </pattern>
               <pattern>
                    <old>Fønix</old>
                    <new>Føniks</new>
               </pattern>
               <pattern>
                    <old>gletscher</old>
                    <new>gletsjer</new>
               </pattern>
               <pattern>
                    <old>kige</old>
                    <new>kigge</new>
               </pattern>
               <pattern>
                    <old>konst</old>
                    <new>kunst</new>
               </pattern>
               <pattern>
                    <old>lieutenant</old>
                    <new>løjtnant</new>
               </pattern>
               <pattern>
                    <old>literatur</old>
                    <new>litteratur</new>
               </pattern>
               <pattern>
                    <old>marsch</old>
                    <new>march</new>
               </pattern>
               <pattern>
                    <old>punsch</old>
                    <new>punch</new>
               </pattern>
               <pattern>
                    <old>sadde</old>
                    <new>satte</new>
               </pattern>
               <pattern>
                    <old>sadte</old>
                    <new>satte</new>
               </pattern>
               <pattern>
                    <old>skruptudse</old>
                    <new>skrubtudse</new>
               </pattern>
               <pattern>
                    <old>såmæn</old>
                    <!-\- NB! One hit with 'saamænd' in the text -\->
                    <new>såmænd</new>
               </pattern>
               <pattern>
                    <old>tour</old>
                    <new>tur</new>
               </pattern>
               <pattern>
                    <old>tredie</old>
                    <new>tredje</new>
               </pattern>
               <pattern>
                    <old>oug</old>
                    <new>ov</new>
               </pattern>
               <pattern>
                    <old>uhr</old>
                    <new>ur</new>
               </pattern>
               <pattern>
                    <old>villie</old>
                    <new>vilje</new>
               </pattern>
               <pattern>
                    <old>vilie</old>
                    <new>vilje</new>
               </pattern>
               <pattern>
                    <old> ædder</old>
                    <new> edder</new>
               </pattern>
               <pattern>
                    <old>ægyp</old>
                    <new>egyp</new>
               </pattern>-->

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
                         <xsl:with-param name="text"
                              select="concat(substring-before($text, $replace), '|', $by, '|', substring-after($text, $replace))"/>
                         <xsl:with-param name="pos" select="$pos"/>
                    </xsl:call-template>
               </xsl:when>

               <!-- No (more) matches found -->
               <xsl:otherwise>
                    <!-- Bump the counter to pick up the next pattern we want to search for -->
                    <xsl:variable name="next" select="$pos + 1"/>
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
