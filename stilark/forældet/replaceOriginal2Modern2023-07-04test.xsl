<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:my="my:my">
     <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
     
     <xsl:strip-space elements="*"/>
     <xsl:template match="/">
          
          <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="..css/oxyAuthorEditMinimumHCA.css"</xsl:processing-instruction>
          <xsl:apply-templates select="@* | node()"/>
          <xsl:text><?oxy_options track_changes="on"?></xsl:text>
     </xsl:template>


     <xsl:template name="string-replace-all"  match="text()">
          <xsl:param name="text" />
          <xsl:param name="replace" />
          <xsl:param name="by" />
          <xsl:choose>
               <xsl:when test="contains($text, $replace)">
                    <xsl:value-of select="substring-before($text,$replace)" />
                    <xsl:value-of select="$by" />
                    <xsl:call-template name="string-replace-all">
                         <xsl:with-param name="text" select="substring-after($text,$replace)" />
                         <xsl:with-param name="replace" select="$replace" />
                         <xsl:with-param name="by" select="$by" />
                    </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                    <xsl:value-of select="$text" />
               </xsl:otherwise>
          </xsl:choose>
     </xsl:template>
     
     <xsl:variable name="myVariable ">
          <xsl:call-template name="string-replace-all">
               <xsl:with-param name="text" select="'This is a {old} text'" />
               <xsl:with-param name="replace" select="'ei'" />
               <xsl:with-param name="by" select="'ej'" />
          </xsl:call-template>
     </xsl:variable>
     
     
     <!--<xsl:template name="search-and-replace">
          <xsl:param name="input"/>
          <xsl:param name="search-string"/>
          <xsl:param name="replace-string"/>
          <xsl:choose>
               <!-\- See if the input contains the search string -\->
               <xsl:when test="$search-string and 
                    contains($input,$search-string)">
                    <!-\- If so, then concatenate the substring before the search
          string to the replacement string and to the result of
          recursively applying this template to the remaining substring.
          -\->
                    <xsl:value-of 
                         select="substring-before($input,$search-string)"/>
                    <xsl:value-of select="$replace-string"/>
                    <xsl:call-template name="search-and-replace">
                         <xsl:with-param name="input"
                              select="substring-after($input,$search-string)"/>
                         <xsl:with-param name="search-string" 
                              select="$search-string"/>
                         <xsl:with-param name="replace-string" 
                              select="$replace-string"/>
                    </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                    <!-\- There are no more occurences of the search string so 
               just return the current input string -\->
                    <xsl:value-of select="$input"/>
               </xsl:otherwise>
          </xsl:choose>
     </xsl:template>-->
</xsl:stylesheet>