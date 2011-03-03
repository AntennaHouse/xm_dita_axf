<?xml version="1.0"?>
<xsl:stylesheet  version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index">



    <!--add column-gap="50pt attribute to the flow-section -->
    <xsl:template match="/" mode="index-postprocess">
        <fo:block xsl:use-attribute-sets="__index__label">
            <xsl:attribute name="id">ID_INDEX_00-0F-EA-40-0D-4D</xsl:attribute>
            <xsl:call-template name="insertVariable">
                <xsl:with-param name="theVariableID" select="'Index'"/>
            </xsl:call-template>
        </fo:block>
        
        <rx:flow-section column-count="2" column-gap="27pt">
            <xsl:apply-templates select="//opentopic-index:index.groups" mode="index-postprocess"/>
        </rx:flow-section>
        
    </xsl:template>
</xsl:stylesheet>
