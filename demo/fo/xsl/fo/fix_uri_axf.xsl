<?xml version='1.0' encoding="UTF-8" ?>
<!--
  ============================================================
  Copyright (c) 2007 Antenna House, Inc. All rights reserved.
  Antenna House is a trademark of Antenna House, Inc.
  URL    : http://www.antennahouse.com/
  E-mail : info@antennahouse.com
  ============================================================
-->
<!-- NOTE: This module is temporary solution for $artworkPrefix parameter uri confliction
           in the Windows environment.
           If we make complete URI reference in the src attribute of fo:external-graphic,
           it must be absolute URI or we must use axf:base-uri attribute to the fo:root 
           for the relative URI. 
           This needs more xsl:param that express XSL-FO location. (2007/10/18)
 -->
<xsl:stylesheet version="1.1"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
>

<xsl:variable name="apos">
    <xsl:text>'</xsl:text>
</xsl:variable>

<xsl:variable name="artworkPrefix_axf">
    <!--xsl:message>$artworkPrefix=<xsl:value-of select="$artworkPrefix"/></xsl:message-->
	<xsl:call-template name="fixArtworkPrefixURI">
		<xsl:with-param name="uri" select="$artworkPrefix"/>
	</xsl:call-template>
</xsl:variable>

<xsl:template name="fixArtworkPrefixURI">
	<xsl:param name="uri"/>
	
	<xsl:variable name="fixURL1">
		<xsl:choose>
			<xsl:when test="contains($uri, ':')">
				<!-- Assumeed contains Windows drive root -->
				<xsl:value-of select="concat('file:///', $uri)"/>
			</xsl:when>
			<xsl:otherwise>
                <!-- If relative uri, we need axf:base-uri, so remains as is -->
				<xsl:value-of select="$uri"/>
		  </xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- Change space to %20 escape and "\" to "/". -->
    <!--xsl:message>$fixURL1=<xsl:value-of select="$fixURL1"/></xsl:message-->
	<xsl:variable name="fixURL2">
		<xsl:call-template name="fixURIEscape">
			<xsl:with-param name="uri" select="$fixURL1"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$fixURL2"/>
</xsl:template>

<!-- Template: Change space to %20 escape and "\" to "/". -->
<xsl:template name="fixURIEscape">
	<xsl:param name="uri"/>
	<xsl:variable name="uriFirstChar">
        <xsl:choose>
            <xsl:when test="string-length($uri) &gt; 0">
                <xsl:value-of select="substring($uri, 1, 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	<xsl:variable name="uriRestChar">
        <xsl:choose>
            <xsl:when test="string-length($uri) &gt; 1">
                <xsl:value-of select="substring($uri, 2, (string-length($uri) -1))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	<xsl:variable name="escapedUriFirstChar">
		<xsl:choose>
			<xsl:when test="$uriFirstChar=' '">
				<xsl:value-of select="'%20'"/>
			</xsl:when>
			<xsl:when test="$uriFirstChar='\'">
				<xsl:value-of select="'/'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$uriFirstChar"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="escapedUriRestChar">
		<xsl:choose>
			<xsl:when test="string($uriRestChar)">
				<xsl:call-template name="fixURIEscape">
					<xsl:with-param name="uri" select="$uriRestChar"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
    <!--xsl:message>$escapedUriFirstChar=<xsl:value-of select="$escapedUriFirstChar"/></xsl:message-->
	<xsl:value-of select="concat($escapedUriFirstChar, $escapedUriRestChar)"/>
</xsl:template>

<!-- Modify original template -->
<!-- Originally coded in fo/commons.xsl -->
<xsl:template match="@background-image" mode="layout-masters-processing">
    <xsl:attribute name="background-image">
		<!-- Fix URI 2007/10/17 -->
        <!--xsl:value-of select="concat('url(', $artworkPrefix_axf,'/',substring-after(.,'artwork:'),')')"/-->
        <xsl:value-of select="concat('url(',$apos, $artworkPrefix_axf,'/',substring-after(.,'artwork:'),$apos,')')"/>
    </xsl:attribute>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/note ')]">
    <xsl:variable name="noteType">
        <xsl:choose>
            <xsl:when test="@type">
                <xsl:value-of select="@type"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'note'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="noteImagePath">
        <xsl:call-template name="insertVariable">
            <xsl:with-param name="theVariableID" select="concat($noteType, ' Note Image Path')"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="not($noteImagePath = '')">
            <fo:table xsl:use-attribute-sets="note__table">
                <fo:table-column column-number="1"/>
                <fo:table-column column-number="2"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="note__image__entry">
                            <fo:block>
                                <!-- Fix URI 2007/10/17 -->
                                <!--fo:external-graphic src="url({concat($artworkPrefix, '/', $noteImagePath)})" xsl:use-attribute-sets="image"/-->
                                <fo:external-graphic src="url({concat($apos, $artworkPrefix_axf, '/', $noteImagePath, $apos)})" xsl:use-attribute-sets="image"/>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="note__text__entry">
                            <xsl:call-template name="placeNoteContent"/>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="placeNoteContent"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>