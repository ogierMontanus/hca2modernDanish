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
               <!-- palatalization (kj > k; gj > g) -->
               <pattern>
                    <old>kje</old>
                    <new>ke</new>
               </pattern>
               <pattern>
                    <old>Kje</old>
                    <new>ke</new>
               </pattern>
               <pattern>
                    <old>. ke</old>
                    <new>. Ke</new>
               </pattern>
               <pattern>
                    <old>kjæ</old>
                    <new>kæ</new>
               </pattern>
               <pattern>
                    <old>Kjæ</old>
                    <new>kæ</new>
               </pattern>
               <pattern>
                    <old>. kæ</old>
                    <new>. Kæ</new>
               </pattern>
               <pattern>
                    <old>kjø</old>
                    <new>kø</new>
               </pattern>
               <pattern>
                    <old>Kjøbenhavn</old>
                    <new>K*ø*benhavn</new>
               </pattern>
               <pattern>
                    <old>Kjø</old>
                    <new>kø</new>
               </pattern>
               <pattern>
                    <old>K*ø*benhavn</old>
                    <new>København</new>
               </pattern>
               <pattern>
                    <old>. kø</old>
                    <new>. Kø</new>
               </pattern>
               <pattern>
                    <old>gje</old>
                    <new>ge</new>
               </pattern>
               <pattern>
                    <old>Gje</old>
                    <new>ge</new>
               </pattern>
               <pattern>
                    <old>. ge</old>
                    <new>. Ge</new>
               </pattern>
               <pattern>
                    <old>gjæ</old>
                    <new>gæ</new>
               </pattern>
               <pattern>
                    <old>Gjæ</old>
                    <new>gæ</new>
               </pattern>
               <pattern>
                    <old>. gæ</old>
                    <new>. Gæ</new>
               </pattern>
               <pattern>
                    <old>gjø</old>
                    <new>gø</new>
               </pattern>
               <pattern>
                    <old>Gjø</old>
                    <new>gø</new>
               </pattern>
               <pattern>
                    <old>. gø</old>
                    <new>. Gø</new>
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
