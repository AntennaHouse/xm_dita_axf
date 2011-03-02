<?xml version="1.0" encoding="UTF-8" ?>
<!--
***************************************************************************
Copyright (c) 2006 Antenna House, Inc.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
***************************************************************************
NOTES: 1. Making index is highly language dependent job. 
          This module is only a temporary solution. For instance, this 
          module supports English, but it does not support CJK, Cyrillic, 
          Turkish (and so on).
       2. Making index ignores case diffrences of indexterm/text().
          This is because xsl:sort result seems not case sensitive.
       3. Indexterm nesting is limited to 2 levels. It is same as DocBook.
          If nesting level greater than 2, indexterm text will be formatted
          at level 2 line separated by space.
***************************************************************************
-->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    exclude-result-prefixes="exsl xalan msxsl" >


<!--
    ======================================================
    Global variables (Treat as constant)
    ======================================================
  -->
<xsl:variable name="cGetRangeSep" select="':'"/>
<xsl:variable name="cIndexId" select="'____INDEX'"/>
<xsl:variable name="cIndexTitle" select="'Index'"/>
<xsl:variable name="space256" select="'                                                                                                                                                                                                                                                                '"/>
                                                  
<!--
    ======================================================
    XSLT Processor distinction
    ======================================================
  -->
<xsl:variable name="Msxsl" select="'msxsl'"/>
<xsl:variable name="Xalan" select="'xalan'"/>
<xsl:variable name="Exslt" select="'exslt'"/>
<xsl:variable name="Saxon" select="'saxon'"/>

<xsl:variable name="nodesetImplementer">
  <xsl:choose>
    <xsl:when test="function-available('msxsl:node-set')">
      <xsl:value-of select="$Msxsl"/>
    </xsl:when>
    <xsl:when test="function-available('xalan:nodeset')">
      <xsl:value-of select="$Xalan"/>
    </xsl:when>
    <xsl:when test="function-available('exsl:node-set')">
      <xsl:value-of select="$Exslt"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<!--
    ======================================================
    Indexterm RTFs
    ======================================================
  -->

<!-- Make RTF from original indexterm -->
<xsl:variable name="indextermOrigin">
    <!-- Ignore indexterm in map/topicmeta 2008/07/23 t.makita -->
    <xsl:for-each select="//*[contains(@class,' topic/indexterm ')][not(ancestor::*[contains(@class,' topic/indexterm ')])][not(ancestor::*[contains(@class,' map/topicmeta ')])]">
        <xsl:element name="indexterm">
            <xsl:attribute name="seq">
                <xsl:value-of select="format-number(position(),'00000')"/>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:attribute name="primary">
                <xsl:apply-templates mode="make-primary"/>
            </xsl:attribute>
            <xsl:attribute name="secondary">
                <xsl:apply-templates select="*" mode="make-secondary"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:for-each>
</xsl:variable>

<!-- Extracting indexterm text templates -->
<xsl:template match="*" mode="make-primary">
    <xsl:apply-templates mode="make-primary"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/indexterm ')]" mode="make-primary"/>

<xsl:template match="*" mode="make-secondary">
    <xsl:apply-templates mode="make-secondary"/>
</xsl:template>

<xsl:template match="*[contains(@class,' topic/indexterm ')]" mode="make-secondary">
    <xsl:value-of select="' '"/>
    <xsl:apply-templates mode="make-secondary"/>
</xsl:template>



<!-- Add sort-key -->
<xsl:variable name="indextermWithKey">
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:for-each select="exsl:node-set($indextermOrigin)/indexterm">
                <xsl:variable name="primaryText">
                    <xsl:value-of select="normalize-space(@primary)"/>
                </xsl:variable>
                <xsl:variable name="loweredPrimaryText">
                    <xsl:call-template name="getLowerCaseString">
                        <xsl:with-param name="srcString" select="$primaryText"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="indextermLabel">
                    <xsl:call-template name="get-index-label">
                        <xsl:with-param name="prmIndexContent">
                            <xsl:value-of select="$primaryText"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="secondaryText">
                    <xsl:value-of select="normalize-space(@secondary)"/>
                </xsl:variable>
                <xsl:variable name="loweredSecondaryText">
                    <xsl:call-template name="getLowerCaseString">
                        <xsl:with-param name="srcString" select="$secondaryText"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="{name()}">
                    <xsl:attribute name="label">
                        <xsl:value-of select="$indextermLabel"/>
                    </xsl:attribute>
                    <xsl:attribute name="primary-origin">
                        <xsl:value-of select="$primaryText"/>
                    </xsl:attribute>
                    <xsl:attribute name="primary">
                        <xsl:value-of select="$loweredPrimaryText"/>
                    </xsl:attribute>
                    <xsl:attribute name="secondary-origin">
                        <xsl:value-of select="$secondaryText"/>
                    </xsl:attribute>
                    <xsl:attribute name="secondary">
                        <xsl:value-of select="$loweredSecondaryText"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@seq|@id"/>
                    <xsl:value-of select="$indextermLabel"/>
                    <xsl:value-of select="substring(concat($loweredPrimaryText,$space256),1,256)"/>
                    <xsl:value-of select="substring(concat($loweredSecondaryText,$space256),1,256)"/>
                    <xsl:value-of select="@seq"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:for-each select="xalan:nodeset($indextermOrigin)/indexterm">
                <xsl:variable name="primaryText">
                    <xsl:value-of select="normalize-space(@primary)"/>
                </xsl:variable>
                <xsl:variable name="loweredPrimaryText">
                    <xsl:call-template name="getLowerCaseString">
                        <xsl:with-param name="srcString" select="$primaryText"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="indextermLabel">
                    <xsl:call-template name="get-index-label">
                        <xsl:with-param name="prmIndexContent">
                            <xsl:value-of select="$primaryText"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="secondaryText">
                    <xsl:value-of select="normalize-space(@secondary)"/>
                </xsl:variable>
                <xsl:variable name="loweredSecondaryText">
                    <xsl:call-template name="getLowerCaseString">
                        <xsl:with-param name="srcString" select="$secondaryText"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="{name()}">
                    <xsl:attribute name="label">
                        <xsl:value-of select="$indextermLabel"/>
                    </xsl:attribute>
                    <xsl:attribute name="primary-origin">
                        <xsl:value-of select="$primaryText"/>
                    </xsl:attribute>
                    <xsl:attribute name="primary">
                        <xsl:value-of select="$loweredPrimaryText"/>
                    </xsl:attribute>
                    <xsl:attribute name="secondary-origin">
                        <xsl:value-of select="$secondaryText"/>
                    </xsl:attribute>
                    <xsl:attribute name="secondary">
                        <xsl:value-of select="$loweredSecondaryText"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@seq|@id"/>
                    <xsl:value-of select="$indextermLabel"/>
                    <xsl:value-of select="substring(concat($loweredPrimaryText,$space256),1,256)"/>
                    <xsl:value-of select="substring(concat($loweredSecondaryText,$space256),1,256)"/>
                    <xsl:value-of select="@seq"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:when>
    </xsl:choose>
</xsl:variable>

<!-- 
    Sorted result
  -->

<xsl:variable name="indextermSorted">
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:for-each select="exsl:node-set($indextermWithKey)/indexterm">
                <xsl:sort/>
                <xsl:element name="{name()}">
                    <xsl:copy-of select="@*"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:for-each select="xalan:nodeset($indextermWithKey)/indexterm">
                <xsl:sort/>
                <xsl:element name="{name()}">
                    <xsl:copy-of select="@*"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:when>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="indextermSortedCount">
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:value-of select="count(exsl:node-set($indextermSorted)/indexterm)"/>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:value-of select="count(xalan:nodeset($indextermSorted)/indexterm)"/>
        </xsl:when>
    </xsl:choose>
</xsl:variable>

<xsl:template name="dumpIndexterm">
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:for-each select="exsl:node-set($indextermSorted)/indexterm">
                <xsl:message>[dumpIndexterm] seq=<xsl:value-of select="@seq"/></xsl:message>
                <xsl:message>[dumpIndexterm]   id=<xsl:value-of select="@id"/></xsl:message>
                <xsl:message>[dumpIndexterm]   label=<xsl:value-of select="@label"/></xsl:message>
                <xsl:message>[dumpIndexterm]   primary-origin=<xsl:value-of select="@primary-origin"/></xsl:message>
                <xsl:message>[dumpIndexterm]   secondary-origin=<xsl:value-of select="@secondary-origin"/></xsl:message>
                <xsl:message>[dumpIndexterm]   primary=<xsl:value-of select="@primary"/></xsl:message>
                <xsl:message>[dumpIndexterm]   secondary=<xsl:value-of select="@secondary"/></xsl:message>
            </xsl:for-each>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:for-each select="xalan:nodeset($indextermWithKey)/indexterm">
                <xsl:message>[dumpIndexterm] seq=<xsl:value-of select="@seq"/></xsl:message>
                <xsl:message>[dumpIndexterm]   id=<xsl:value-of select="@id"/></xsl:message>
                <xsl:message>[dumpIndexterm]   label=<xsl:value-of select="@label"/></xsl:message>
                <xsl:message>[dumpIndexterm]   primary-origin=<xsl:value-of select="@primary-origin"/></xsl:message>
                <xsl:message>[dumpIndexterm]   secondary-origin=<xsl:value-of select="@secondary-origin"/></xsl:message>
                <xsl:message>[dumpIndexterm]   primary=<xsl:value-of select="@primary"/></xsl:message>
                <xsl:message>[dumpIndexterm]   secondary=<xsl:value-of select="@secondary"/></xsl:message>
            </xsl:for-each>
        </xsl:when>
    </xsl:choose>
</xsl:template>




<xsl:variable name="labelAlphabets" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸĀĂĄĆĈĊČĎĐĒĔĖĘĚĜĞĠĢĤĦĨĪĬĮİĲĴĶĹĻĽĿŁŃŅŇŊŌŎŐŒŔŖŘŚŜŞŠŢŤŦŨŪŬŮŰŲŴŶŹŻŽ'"/>
<xsl:variable name="upperAlphabets" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸĀĂĄĆĈĊČĎĐĒĔĖĘĚĜĞĠĢĤĦĨĪĬĮİĲĴĶĹĻĽĿŁŃŅŇŊŌŎŐŒŔŖŘŚŜŞŠŢŤŦŨŪŬŮŰŲŴŶŹŻŽ'"/>
<xsl:variable name="lowerAlphabets" select="'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿāăąćĉċčďđēĕėęěĝğġģĥħĩīĭįiĳĵķĺļľŀłńņňŋōŏőœŕŗřśŝşšţťŧũūŭůűųŵŷźżž'"/>

<!-- 
 function: Generate a indexterm label
 param:    prmIndexContent: Indexterm text itself.
 return:   Indexterm label
 note:     Language support is limited.
-->
<xsl:template name="get-index-label">
    <xsl:param name="prmIndexContent"/>
    <xsl:variable name="firstChar" select="substring($prmIndexContent,1,1)"/>
    <xsl:choose>
        <xsl:when test="contains($upperAlphabets, $firstChar) or contains($lowerAlphabets, $firstChar)">
            <xsl:value-of select="translate($firstChar, $lowerAlphabets, $labelAlphabets)"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="' '"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- 
 function: Return lower-case string
 param:    srcString: Source string
 return:   Lower case string
 note:     Language support is limited.
-->
<xsl:template name="getLowerCaseString">
    <xsl:param name="srcString" select="''"/>
    <xsl:value-of select="translate($srcString, $upperAlphabets, $lowerAlphabets)"/>
</xsl:template>



<!--
    ======================================================
    Make index page
    ======================================================
  -->

<!-- 
 function: Making index page main. 
 param:    None
 return:   Index page fo:page-sequence
 note:     Change book title class reference 2008/07/16 t.makita
-->
<xsl:template name="make-index">

    <!--xsl:message>[make-index] index count=<xsl:value-of select="$indextermSortedCount"/></xsl:message>
    <xsl:call-template name="dumpIndexterm"/-->
    <fo:page-sequence master-reference="index-master">
        <fo:static-content flow-name="xsl-region-before">
            <fo:block font-size="8pt" line-height="8pt">
                <xsl:value-of select="$bookTitle"/>
            </fo:block>
        </fo:static-content>

        <fo:static-content flow-name="xsl-region-after">
            <fo:block text-align="center" font-size="10pt" font-weight="bold" font-family="Helvetica">
                <fo:page-number></fo:page-number>
            </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">
            <fo:block text-align="left" font-size="10pt" font-family="Helvetica" break-before="page">
                <!-- Index title -->
                <fo:block xsl:use-attribute-sets="topictitle1" padding-top="1.4pc" span="all" id="{$cIndexId}">
                    <xsl:value-of select="$cIndexTitle"/>
                </fo:block>
                <xsl:call-template name="make-index-content-control"/>
                <!-- insert dummay block to make column contents make it equal -->
                <fo:block span="all"/>
            </fo:block>
        </fo:flow>
    </fo:page-sequence>
</xsl:template>

<!-- 
 function: Making index content main control template. 
 param:    None
 return:   
 note:     
-->
<xsl:template name="make-index-content-control">
    <xsl:variable name="startId">
        <xsl:choose>
            <xsl:when test="$nodesetImplementer=$Exslt">
                <xsl:value-of select="exsl:node-set($indextermSorted)/indexterm[1]/@id"/>
            </xsl:when>
            <xsl:when test="$nodesetImplementer=$Xalan">
                <xsl:value-of select="xalan:nodeset($indextermSorted)/indexterm[1]/@id"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="startGroupLabel">
        <xsl:call-template name="get-group-label">
            <xsl:with-param name="prmId" select="$startId"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="groupRange">
        <xsl:call-template name="get-group-range">
            <xsl:with-param name="prmCurrentId" select="$startId"/>
            <xsl:with-param name="prmGroupLabel" select="$startGroupLabel"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="make-index-group-control">
        <xsl:with-param name="prmGroupLabel" select="$startGroupLabel"/>
        <xsl:with-param name="prmStartId" select="$startId"/>
        <xsl:with-param name="prmEndId" select="substring-before($groupRange,$cGetRangeSep)"/>
        <xsl:with-param name="prmNextId" select="substring-after($groupRange,$cGetRangeSep)"/>
    </xsl:call-template>
</xsl:template>

<!--    function: Get group label
        param: prmId
        return: indexterm/@label
        note:none
-->
<xsl:template name="get-group-label">
    <xsl:param name="prmId"/>
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:value-of select="string(exsl:node-set($indextermSorted)/indexterm[@id=$prmId]/@label)"/>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:value-of select="string(xalan:nodeset($indextermSorted)/indexterm[@id=$prmId]/@label)"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- function: Get range of the indexterm group
     param: start id
     return: [id(to)]:[id(next)]
     note:Process starts from current indexterm element.
-->
<xsl:template name="get-group-range">
    <xsl:param name="prmCurrentId"/>
    <xsl:param name="prmGroupLabel"/>
    
    <!-- xsl:message>[get-group-range] $prmCurrentId:<xsl:value-of select="$prmCurrentId"/></xsl:message>
    <xsl:message>[get-group-range] $prmGroupLabel:<xsl:value-of select="$prmGroupLabel"/></xsl:message -->
    <xsl:variable name="nextId">
        <xsl:choose>
            <xsl:when test="$nodesetImplementer=$Exslt">
                <xsl:value-of select="exsl:node-set($indextermSorted)/indexterm[@id=$prmCurrentId]/following-sibling::indexterm[1]/@id"/>
            </xsl:when>
            <xsl:when test="$nodesetImplementer=$Xalan">
                <xsl:value-of select="xalan:nodeset($indextermSorted)/indexterm[@id=$prmCurrentId]/following-sibling::indexterm[1]/@id"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>    
    
    <xsl:variable name="nextGroupLabel">
        <xsl:choose>
            <xsl:when test="$nodesetImplementer=$Exslt">
                <xsl:value-of select="string(exsl:node-set($indextermSorted)/indexterm[@id=$prmCurrentId]/following-sibling::indexterm[1]/@label)"/>
            </xsl:when>
            <xsl:when test="$nodesetImplementer=$Xalan">
                <xsl:value-of select="string(xalan:nodeset($indextermSorted)/indexterm[@id=$prmCurrentId]/following-sibling::indexterm[1]/@label)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>    
    <!-- xsl:message>[get-group-range] $nextId:<xsl:value-of select="$nextId"/></xsl:message>
    <xsl:message>[get-group-range] $nextGroupLabel:<xsl:value-of select="$nextGroupLabel"/></xsl:message -->
    
    <xsl:choose>
        <xsl:when test="$prmGroupLabel != $nextGroupLabel">
            <!-- group key break -->
            <xsl:value-of select="concat($prmCurrentId, $cGetRangeSep, $nextId)"/>
            <!-- xsl:message>[get-group-range] result=<xsl:value-of select="concat($prmCurrentId, $cGetRangeSep, $nextId)"/></xsl:message -->
        </xsl:when>
        <xsl:otherwise>
            <!-- group key continues! Call recursively myself.-->
            <xsl:call-template name="get-group-range">
                <xsl:with-param name="prmCurrentId" select="$nextId"/>
                <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- function: Index group control
     param:
     return:
     note:
-->
<xsl:attribute-set name="indexGroupTitle">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">11pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="border-bottom">1.5pt solid black</xsl:attribute>
    <xsl:attribute name="space-before">5pt</xsl:attribute>
    <xsl:attribute name="space-after">4pt</xsl:attribute>
    <xsl:attribute name="keep-with-next">always</xsl:attribute>
</xsl:attribute-set>

<xsl:template name="make-index-group-control">
    <xsl:param name="prmGroupLabel"/>
    <xsl:param name="prmStartId"/>
    <xsl:param name="prmEndId"/>
    <xsl:param name="prmNextId" select="''"/>

    <!-- set group label -->
    <fo:block xsl:use-attribute-sets="indexGroupTitle">
        <xsl:value-of select="$prmGroupLabel"/>
    </fo:block>

    <xsl:variable name="currentPrimaryTerm">
        <xsl:call-template name="getPrimaryTerm">
            <xsl:with-param name="prmId" select="$prmStartId"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="currentSecondaryTerm">
        <xsl:call-template name="getSecondaryTerm">
            <xsl:with-param name="prmId" select="$prmStartId"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="indextermRange">
        <xsl:call-template name="get-indexterm-range">
            <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
            <xsl:with-param name="prmCurrentId" select="$prmStartId"/>
            <xsl:with-param name="prmCurrentPrimaryTerm" select="$currentPrimaryTerm"/>
            <xsl:with-param name="prmCurrentSecondaryTerm" select="$currentSecondaryTerm"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:call-template name="make-index-detail-line">
        <xsl:with-param name="prmCurrentId" select="$prmStartId"/>
        <xsl:with-param name="prmCurrentPrimaryTerm" select="$currentPrimaryTerm"/>
        <xsl:with-param name="prmCurrentSecondaryTerm" select="$currentSecondaryTerm"/>
        <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
        <xsl:with-param name="prmIndextermRange" select="$indextermRange"/>
        <xsl:with-param name="prmGroupEndId" select="$prmEndId"/>
    </xsl:call-template>
    
    <!-- next group processing -->
    <xsl:if test="string($prmNextId)">
        <xsl:variable name="startGroupLabel">
            <xsl:call-template name="get-group-label">
                <xsl:with-param name="prmId" select="$prmNextId"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="groupRange">
            <xsl:call-template name="get-group-range">
                <xsl:with-param name="prmCurrentId" select="$prmNextId"/>
                <xsl:with-param name="prmGroupLabel" select="$startGroupLabel"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="make-index-group-control">
            <xsl:with-param name="prmGroupLabel" select="$startGroupLabel"/>
            <xsl:with-param name="prmStartId" select="$prmNextId"/>
            <xsl:with-param name="prmEndId" select="substring-before($groupRange,$cGetRangeSep)"/>
            <xsl:with-param name="prmNextId" select="substring-after($groupRange,$cGetRangeSep)"/>
        </xsl:call-template>
    </xsl:if>
    
</xsl:template>

<!--    function: Get primary term
        param: prmId: id
        return: indexterm/@primary
        note:none
-->
<xsl:template name="getPrimaryTerm">
    <xsl:param name="prmId"/>
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:value-of select="string(exsl:node-set($indextermSorted)/indexterm[@id=$prmId]/@primary)"/>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:value-of select="string(xalan:nodeset($indextermSorted)/indexterm[@id=$prmId]/@primary)"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!--    function: Get secondary term
        param: prmId: id
        return: indexterm/@secondary
        note:none
-->
<xsl:template name="getSecondaryTerm">
    <xsl:param name="prmId"/>
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:value-of select="string(exsl:node-set($indextermSorted)/indexterm[@id=$prmId]/@secondary)"/>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:value-of select="string(xalan:nodeset($indextermSorted)/indexterm[@id=$prmId]/@secondary)"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>



<!--    function: Get range of the indexterm
        param: See below
        return: [id(to)]:[id(next)]
        note:Process starts from current indexterm element.
-->
<xsl:template name="get-indexterm-range">
    <xsl:param name="prmGroupLabel"/>
    <xsl:param name="prmCurrentId"/>
    <xsl:param name="prmCurrentPrimaryTerm"/>
    <xsl:param name="prmCurrentSecondaryTerm"/>
    
    <xsl:variable name="nextId">
        <xsl:choose>
            <xsl:when test="$nodesetImplementer=$Exslt">
                <xsl:value-of select="exsl:node-set($indextermSorted)/indexterm[@id=$prmCurrentId]/following-sibling::indexterm[1]/@id"/>
            </xsl:when>
            <xsl:when test="$nodesetImplementer=$Xalan">
                <xsl:value-of select="xalan:nodeset($indextermSorted)/indexterm[@id=$prmCurrentId]/following-sibling::indexterm[1]/@id"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>    
    
    <xsl:variable name="nextGroupLabel">
        <xsl:call-template name="get-group-label">
            <xsl:with-param name="prmId" select="$nextId"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="nextPrimaryTerm">
        <xsl:call-template name="getPrimaryTerm">
            <xsl:with-param name="prmId" select="$nextId"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="nextSecondaryTerm">
        <xsl:call-template name="getSecondaryTerm">
            <xsl:with-param name="prmId" select="$nextId"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
        <xsl:when test="($prmGroupLabel != $nextGroupLabel) or ($prmCurrentPrimaryTerm != $nextPrimaryTerm) or ($prmCurrentSecondaryTerm != $nextSecondaryTerm)">
            <!-- group key or primary/seconary term breaks! -->
            <xsl:value-of select="concat($prmCurrentId, $cGetRangeSep, $nextId)"/>
            <!-- xsl:message>[get-indexterm-range] result=<xsl:value-of select="concat($prmCurrentId, $cGetRangeSep, $nextId)"/></xsl:message -->
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <!-- group label/indexterm continues! -->
                <xsl:when test="string($nextId)">
                    <xsl:call-template name="get-indexterm-range">
                        <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
                        <xsl:with-param name="prmCurrentId" select="$nextId"/>
                        <xsl:with-param name="prmCurrentPrimaryTerm" select="$prmCurrentPrimaryTerm"/>
                        <xsl:with-param name="prmCurrentSecondaryTerm" select="$prmCurrentSecondaryTerm"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- end of element -->
                    <xsl:value-of select="concat($prmCurrentId, $cGetRangeSep)"/>
                    <!-- xsl:message>[get-indexterm-range] result=<xsl:value-of select="concat($prmCurrentId, $cGetRangeSep)"/></xsl:message -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!--    function: make detail line
        param: See below.
        return:
        note: Modified index block attribute. 2008/07/17 t.makita
-->

<xsl:attribute-set name="indexPrimary">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">9pt</xsl:attribute>
    <xsl:attribute name="line-height">12pt</xsl:attribute>
    <xsl:attribute name="space-after">3pt</xsl:attribute>
    <xsl:attribute name="axf:text-align-first">justify</xsl:attribute>
    <xsl:attribute name="text-align">justify</xsl:attribute>
    <xsl:attribute name="text-align-last">right</xsl:attribute>
    <xsl:attribute name="axf:leader-expansion">force</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="indexPrimaryOnly" use-attribute-sets="indexPrimary">
    <xsl:attribute name="axf:text-align-first">left</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="text-align-last">left</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="indexSecondary" use-attribute-sets="indexPrimary">
    <xsl:attribute name="font-size">8.5pt</xsl:attribute>
    <xsl:attribute name="start-indent">5mm</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="indexPageNumber">
    <xsl:attribute name="axf:suppress-duplicate-page-number">true</xsl:attribute>
    <!--xsl:attribute name="color">blue</xsl:attribute-->
</xsl:attribute-set>


<xsl:template name="make-index-detail-line">
    <xsl:param name="prmCurrentId"/>
    <xsl:param name="prmCurrentPrimaryTerm"/>
    <xsl:param name="prmCurrentSecondaryTerm"/>
    <xsl:param name="prmGroupLabel"/>
    <xsl:param name="prmIndextermRange"/>
    <xsl:param name="prmGroupEndId"/>


    <xsl:variable name="toId" select="substring-before($prmIndextermRange,$cGetRangeSep)"/>
    <xsl:variable name="nextId" select="substring-after($prmIndextermRange,$cGetRangeSep)"/>
    <xsl:variable name="nextGroupLabel">
        <xsl:choose>
            <xsl:when test="not(string($nextId))">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="get-group-label">
                    <xsl:with-param name="prmId" select="$nextId"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
        <xsl:when test="not (string($prmCurrentSecondaryTerm))">
            <!-- primary only -->
            <xsl:variable name="currentPrimaryTermOrigin">
                <xsl:call-template name="getPrimaryTermOrigin">
                    <xsl:with-param name="prmId" select="$prmCurrentId"/>
                </xsl:call-template>
            </xsl:variable>
            
            <fo:block xsl:use-attribute-sets="indexPrimary">
                <xsl:value-of select="$currentPrimaryTermOrigin"/>
                <fo:leader leader-pattern="dots" leader-length.optimum="0pt" />
                <fo:inline keep-with-next.within-line="always">
                    <fo:leader leader-pattern="dots"/>
                </fo:inline>
                <fo:wrapper xsl:use-attribute-sets="indexPageNumber">
                    <xsl:call-template name="set-index-page-reference">
                        <xsl:with-param name="prmIsFirst" select="true()"/>
                        <xsl:with-param name="prmFromId" select="$prmCurrentId"/>
                        <xsl:with-param name="prmToId" select="$toId"/>
                    </xsl:call-template>
                </fo:wrapper>
            </fo:block>
        </xsl:when>
        <xsl:otherwise>
            <!-- primary and secondary -->
            <xsl:variable name="currentPrimaryTermOrigin">
                <xsl:call-template name="getPrimaryTermOrigin">
                    <xsl:with-param name="prmId" select="$prmCurrentId"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="currentSecondaryTermOrigin">
                <xsl:call-template name="getSecondaryTermOrigin">
                    <xsl:with-param name="prmId" select="$prmCurrentId"/>
                </xsl:call-template>
            </xsl:variable>

            <!-- get previous primary -->
            <xsl:variable name="prevPrimaryTerm">
                <xsl:choose>
                    <xsl:when test="$nodesetImplementer=$Exslt">
                        <xsl:value-of select="string(exsl:node-set($indextermSorted)/indexterm[@id=$prmCurrentId]/preceding-sibling::indexterm[1]/@primary)"/>
                    </xsl:when>
                    <xsl:when test="$nodesetImplementer=$Xalan">
                        <xsl:value-of select="string(xalan:nodeset($indextermSorted)/indexterm[@id=$prmCurrentId]/preceding-sibling::indexterm[1]/@primary)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            
            <!-- primary break -->
            <xsl:if test="$prmCurrentPrimaryTerm != $prevPrimaryTerm">
                <fo:block xsl:use-attribute-sets="indexPrimaryOnly">
                    <xsl:value-of select="$currentPrimaryTermOrigin"/>
                </fo:block>
            </xsl:if>
            
            <fo:block xsl:use-attribute-sets="indexSecondary">
                <xsl:value-of select="$currentSecondaryTermOrigin"/>
                <fo:leader leader-length.optimum="0pt" leader-pattern="dots"/>
                <fo:inline keep-with-next="always">
                    <fo:leader leader-pattern="dots"/>
                </fo:inline>
                <fo:wrapper xsl:use-attribute-sets="indexPageNumber">
                    <!-- Set page number reference -->
                    <xsl:call-template name="set-index-page-reference">
                        <xsl:with-param name="prmIsFirst" select="true()"/>
                        <xsl:with-param name="prmFromId" select="$prmCurrentId"/>
                        <xsl:with-param name="prmToId" select="$toId"/>
                    </xsl:call-template>
                </fo:wrapper>
            </fo:block>
        </xsl:otherwise>
    </xsl:choose>
   
    <xsl:if test="string($nextId) and ($nextGroupLabel = $prmGroupLabel)">
        <!-- Move to next -->
        <xsl:variable name="currentId" select="$nextId"/>
        
        <xsl:variable name="currentPrimaryTerm">
            <xsl:call-template name="getPrimaryTerm">
                <xsl:with-param name="prmId" select="$currentId"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="currentSecondaryTerm">
            <xsl:call-template name="getSecondaryTerm">
                <xsl:with-param name="prmId" select="$currentId"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="indextermRange">
            <xsl:call-template name="get-indexterm-range">
                <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
                <xsl:with-param name="prmCurrentId" select="$currentId"/>
                <xsl:with-param name="prmCurrentPrimaryTerm" select="$currentPrimaryTerm"/>
                <xsl:with-param name="prmCurrentSecondaryTerm" select="$currentSecondaryTerm"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- call recursively myself -->
        <xsl:call-template name="make-index-detail-line">
            <xsl:with-param name="prmCurrentId" select="$currentId"/>
            <xsl:with-param name="prmCurrentPrimaryTerm" select="$currentPrimaryTerm"/>
            <xsl:with-param name="prmCurrentSecondaryTerm" select="$currentSecondaryTerm"/>
            <xsl:with-param name="prmGroupLabel" select="$prmGroupLabel"/>
            <xsl:with-param name="prmIndextermRange" select="$indextermRange"/>
            <xsl:with-param name="prmGroupEndId" select="$prmGroupEndId"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!--    function: Get primary term original
        param: prmId
        return: indexterm/@primary-origin
        note:none
-->
<xsl:template name="getPrimaryTermOrigin">
    <xsl:param name="prmId"/>
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:value-of select="string(exsl:node-set($indextermSorted)/indexterm[@id=$prmId]/@primary-origin)"/>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:value-of select="string(xalan:nodeset($indextermSorted)/indexterm[@id=$prmId]/@primary-origin)"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!--    function: Get secondary term original
        param: prmId
        return: indexterm/@secondary-origin
        note:none
-->
<xsl:template name="getSecondaryTermOrigin">
    <xsl:param name="prmId"/>
    <xsl:choose>
        <xsl:when test="$nodesetImplementer=$Exslt">
            <xsl:value-of select="string(exsl:node-set($indextermSorted)/indexterm[@id=$prmId]/@secondary-origin)"/>
        </xsl:when>
        <xsl:when test="$nodesetImplementer=$Xalan">
            <xsl:value-of select="string(xalan:nodeset($indextermSorted)/indexterm[@id=$prmId]/@secondary-origin)"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>


<!--    function: Make INDEX page reference
        param: See below.
        return:
        note: 
-->
<xsl:template name="set-index-page-reference">
    <xsl:param name="prmIsFirst"/>
    <xsl:param name="prmFromId"/>
    <xsl:param name="prmToId"/>
    
    <!-- xsl:message>[set-index-page-reference] $prmIsFirst:<xsl:value-of select="$prmIsFirst"/></xsl:message>
    <xsl:message>[set-index-page-reference] $prmFromId:<xsl:value-of select="$prmFromId"/></xsl:message>
    <xsl:message>[set-index-page-reference] $prmToId:<xsl:value-of select="$prmToId"/></xsl:message -->
    
    <fo:inline>
        <xsl:if test="not ($prmIsFirst)">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <fo:basic-link internal-destination="{$prmFromId}">
            <fo:page-number-citation ref-id="{$prmFromId}" />
        </fo:basic-link>
    </fo:inline>
    <xsl:if test="$prmFromId != $prmToId">
        <xsl:variable name="nextId">
            <xsl:choose>
                <xsl:when test="$nodesetImplementer=$Exslt">
                    <xsl:value-of select="exsl:node-set($indextermSorted)/indexterm[@id=$prmFromId]/following-sibling::indexterm[1]/@id"/>
                </xsl:when>
                <xsl:when test="$nodesetImplementer=$Xalan">
                    <xsl:value-of select="xalan:nodeset($indextermSorted)/indexterm[@id=$prmFromId]/following-sibling::indexterm[1]/@id"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
                
        <xsl:if test="string($nextId)">
            <!-- call recursively myself until reach "toId" -->
            <xsl:call-template name="set-index-page-reference">
                <xsl:with-param name="isFirst" select="false()"/>
                <xsl:with-param name="prmFromId" select="$nextId"/>
                <xsl:with-param name="prmToId" select="$prmToId"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>

