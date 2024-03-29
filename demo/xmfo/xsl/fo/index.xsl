<?xml version='1.0'?>

<!-- 
Copyright © 2004-2006 by Idiom Technologies, Inc. All rights reserved. 
IDIOM is a registered trademark of Idiom Technologies, Inc. and WORLDSERVER
and WORLDSTART are trademarks of Idiom Technologies, Inc. All other 
trademarks are the property of their respective owners. 

IDIOM TECHNOLOGIES, INC. IS DELIVERING THE SOFTWARE "AS IS," WITH 
ABSOLUTELY NO WARRANTIES WHATSOEVER, WHETHER EXPRESS OR IMPLIED,  AND IDIOM
TECHNOLOGIES, INC. DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
PURPOSE AND WARRANTY OF NON-INFRINGEMENT. IDIOM TECHNOLOGIES, INC. SHALL NOT
BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, COVER, PUNITIVE, EXEMPLARY,
RELIANCE, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO LOSS OF 
ANTICIPATED PROFIT), ARISING FROM ANY CAUSE UNDER OR RELATED TO  OR ARISING 
OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF IDIOM
TECHNOLOGIES, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 

Idiom Technologies, Inc. and its licensors shall not be liable for any
damages suffered by any person as a result of using and/or modifying the
Software or its derivatives. In no event shall Idiom Technologies, Inc.'s
liability for any damages hereunder exceed the amounts received by Idiom
Technologies, Inc. as a result of this transaction.

These terms and conditions supersede the terms and conditions in any
licensing agreement to the extent that such terms and conditions conflict
with those set forth herein.

This file is part of the DITA Open Toolkit project hosted on Sourceforge.net. 
See the accompanying license.txt file for applicable licenses.
-->

<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    xmlns:exsl="http://exslt.org/common"
    xmlns:exslf="http://exslt.org/functions"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    xmlns:comparer="com.idiominc.ws.opentopic.xsl.extension.CompareStrings"
    extension-element-prefixes="exsl"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    exclude-result-prefixes="opentopic-index exsl comparer rx opentopic-func exslf">

    <xsl:include href="../../cfg/fo/attrs/index-attr.xsl"/>

    <!-- *************************************************************** -->
    <!-- Create index templates                                          -->
    <!-- *************************************************************** -->

    <xsl:variable name="continuedValue">
        <xsl:call-template name="insertVariable">
            <xsl:with-param name="theVariableID" select="'Index Continued String'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="locale.lang">
        <xsl:value-of select="substring-before($locale, '_')"/>
    </xsl:variable>
    <xsl:variable name="locale.country">
        <xsl:value-of select="substring-after($locale, '_')"/>
    </xsl:variable>

    <xsl:variable name="warn-enabled" select="true()"/>

	<xsl:key name="index-key" match="opentopic-index:index.entry" use="@value"/>

	<xsl:variable name="index-entries">
        <xsl:if test="$pdfFormatter = 'xep'">
            <xsl:apply-templates select="/" mode="index-entries"/>
        </xsl:if>
    </xsl:variable>

    <xsl:template match="*[contains(@class,' topic/topic ')]" mode="index-entries">
        <xsl:variable name="id" select="ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"/>
        <xsl:variable name="gid" select="generate-id(ancestor-or-self::*[contains(@class, ' topic/topic ')][1])"/>
        <xsl:variable name="topicNumber" select="count(exsl:node-set($topicNumbers)/topic[@id = $id][following-sibling::topic[@guid = $gid]]) + 1"/>
        <xsl:variable name="mapTopics">
            <xsl:copy-of select="$map//*[@id = $id]"/>
        </xsl:variable>

        <xsl:variable name="currentMapTopic" select="$mapTopics/*[position() = $topicNumber]"/>

        <xsl:if test="not(contains($currentMapTopic/@otherprops,'noindex'))">
            <xsl:apply-templates mode="index-entries"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/topic ')]" mode="index-postprocess">
        <xsl:variable name="id" select="ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"/>
        <xsl:variable name="gid" select="generate-id(ancestor-or-self::*[contains(@class, ' topic/topic ')][1])"/>
        <xsl:variable name="topicNumber" select="count(exsl:node-set($topicNumbers)/topic[@id = $id][following-sibling::topic[@guid = $gid]]) + 1"/>
        <xsl:variable name="mapTopics">
            <xsl:copy-of select="$map//*[@id = $id]"/>
        </xsl:variable>

        <xsl:variable name="currentMapTopic" select="$mapTopics/*[position() = $topicNumber]"/>

        <xsl:if test="not(contains($currentMapTopic/@otherprops,'noindex'))">
            <xsl:apply-templates mode="index-entries"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="opentopic-index:index.entry" mode="index-entries">
        <xsl:choose>
            <xsl:when test="opentopic-index:index.entry">
                <xsl:apply-templates mode="index-entries"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="opentopic-index:index.groups" mode="index-entries"/>

    <xsl:template match="*" priority="-1" mode="index-entries">
        <xsl:apply-templates mode="index-entries"/>
    </xsl:template>

    <xsl:template name="createIndex">
        <xsl:if test="(//opentopic-index:index.groups//opentopic-index:index.entry) and (count($index-entries//opentopic-index:index.entry) &gt; 0) and ($pdfFormatter = 'xep')">
            <fo:page-sequence master-reference="index-sequence" xsl:use-attribute-sets="__force__page__count">

                <xsl:call-template name="insertIndexStaticContents"/>

                <fo:flow flow-name="xsl-region-body">
                    <xsl:apply-templates select="/" mode="index-postprocess"/>
                </fo:flow>

            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/indexterm ')]">
		<xsl:apply-templates/>
	</xsl:template>

	<!--Following four templates handles index entry elements created by the index preprocessor task-->

    <xsl:template match="opentopic-index:index.groups"/>

	<xsl:template match="opentopic-index:index.entry[ancestor-or-self::opentopic-index:index.entry[@no-page='true'] and not(@single-page='true')]">
		<!--Skip index entries which shouldn't have a page numbering-->
    </xsl:template>

    <xsl:template match="opentopic-index:index.entry">
        <xsl:if test="(opentopic-index:refID/@value) and ($pdfFormatter = 'xep')">
            <xsl:choose>
                <xsl:when test="self::opentopic-index:index.entry[@start-range='true']">
					<!--Insert ranged index entry start marker-->
					<xsl:variable name="selfIDs" select="descendant-or-self::opentopic-index:index.entry[last()]/opentopic-index:refID/@value"/>

					<xsl:for-each select="$selfIDs">

						<xsl:variable name="selfID" select="."/>
						<xsl:variable name="followingMarkers" select="following::opentopic-index:index.entry[descendant-or-self::opentopic-index:index.entry[last()]/opentopic-index:refID/@value = $selfID]"/>
						<xsl:variable name="followingMarker" select="$followingMarkers[@end-range='true'][1]"/>
						<xsl:variable name="followingStartMarker" select="$followingMarkers[@start-range='true'][1]"/>
						<xsl:choose>
							<xsl:when test="not($followingMarker)">
								<xsl:if test="$warn-enabled">
									<xsl:message>
										<xsl:text>[WARNING] There is no index entry found which closing range for ID="</xsl:text>
										<xsl:value-of select="$selfID"/>
										<xsl:text>"</xsl:text>
									</xsl:message>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$followingStartMarker and $followingStartMarker[following::*[generate-id() = generate-id($followingMarker)]]">
										<xsl:if test="$warn-enabled">
											<xsl:message>
												<xsl:text>[WARNING] There are multiple index entry found which is opening range for ID="</xsl:text>
												<xsl:value-of select="$selfID"/>
												<xsl:text>"</xsl:text> but there is only one which close it or ranges are overlapping.
											</xsl:message>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<fo:index-range-begin id="{$selfID}_{generate-id()}" index-key="{$selfID}"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:for-each>
                </xsl:when>
                <xsl:when test="self::opentopic-index:index.entry[@end-range='true']">
                    <!--Insert ranged index entry end marker-->
					<xsl:variable name="selfIDs" select="descendant-or-self::opentopic-index:index.entry[last()]/opentopic-index:refID/@value"/>
					<xsl:for-each select="$selfIDs">

						<xsl:variable name="selfID" select="."/>
						<xsl:variable name="precMarkers" select="preceding::opentopic-index:index.entry[(@start-range or @end-range) and descendant-or-self::opentopic-index:index.entry[last()]/opentopic-index:refID/@value = $selfID]"/>
						<xsl:variable name="precMarker" select="$precMarkers[@start-range='true'][last()]"/>
						<xsl:variable name="precEndMarker" select="$precMarkers[@end-range='true'][last()]"/>
						<xsl:choose>
							<xsl:when test="not($precMarker)">
								<xsl:if test="$warn-enabled">
									<xsl:message>
										<xsl:text>[WARNING] There is no index entry found which opening range for ID="</xsl:text>
										<xsl:value-of select="$selfID"/>
										<xsl:text>"</xsl:text>
									</xsl:message>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$precEndMarker and $precEndMarker[preceding::*[generate-id() = generate-id($precMarker)]]">
										<xsl:if test="$warn-enabled">
											<xsl:message>
												<xsl:text>[WARNING] There are multiple index entry found which closing range for ID="</xsl:text>
												<xsl:value-of select="$selfID"/>
												<xsl:text>"</xsl:text>
											</xsl:message>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="$precMarker//opentopic-index:refID[@value = $selfID]/@value">
                                            <fo:index-range-end ref-id="{$selfID}_{generate-id()}"/>
                                        </xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:for-each>
                </xsl:when>
            </xsl:choose>
			<!--Insert simple index entry marker-->
			<xsl:choose>
				<xsl:when test="opentopic-index:index.entry"/>
				<xsl:otherwise>
					<xsl:for-each select="child::opentopic-index:refID[last()]">
						<fo:inline index-key="{@value}"/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="opentopic-index:*"/>
    <xsl:template match="opentopic-index:*" mode="preface" />
    <xsl:template match="opentopic-index:*" mode="index-postprocess"/>

    <xsl:template match="/" mode="index-postprocess">
        <fo:block xsl:use-attribute-sets="__index__label">
            <xsl:attribute name="id">ID_INDEX_00-0F-EA-40-0D-4D</xsl:attribute>
            <xsl:call-template name="insertVariable">
                <xsl:with-param name="theVariableID" select="'Index'"/>
            </xsl:call-template>
        </fo:block>

        <rx:flow-section column-count="2">
            <xsl:apply-templates select="//opentopic-index:index.groups" mode="index-postprocess"/>
        </rx:flow-section>

    </xsl:template>

    <xsl:template match="*" mode="index-postprocess" priority="-1">
		<xsl:apply-templates mode="index-postprocess"/>
	</xsl:template>

	<xsl:template match="opentopic-index:index.groups" mode="index-postprocess">
		<xsl:apply-templates mode="index-postprocess"/>
	</xsl:template>

	<xsl:template match="opentopic-index:index.group[opentopic-index:index.entry]" mode="index-postprocess">
		<fo:block xsl:use-attribute-sets="index.entry" >
			<xsl:apply-templates mode="index-postprocess"/>
		</fo:block>
	</xsl:template>

	<xsl:template match="opentopic-index:label" mode="index-postprocess">
		<fo:block xsl:use-attribute-sets="__index__letter-group">
			<xsl:value-of select="."/>
		</fo:block>
	</xsl:template>

    <xsl:template match="opentopic-index:index.entry[not(opentopic-index:index.entry)]" mode="index-postprocess" priority="1">
        <xsl:variable name="page-setting" select=" (ancestor-or-self::opentopic-index:index.entry/@no-page | ancestor-or-self::opentopic-index:index.entry/@start-page)[last()]"/>
		<xsl:variable name="isNoPage" select=" $page-setting = 'true' and name($page-setting) = 'no-page' "/>
        <xsl:variable name="value" select="@value"/>
        <xsl:variable name="refID" select="opentopic-index:refID/@value"/>

        <xsl:if test="opentopic-func:getIndexEntry($value,$refID)">
            <xsl:call-template name="make-index-ref">
				<xsl:with-param name="idxs" select="opentopic-index:refID"/>
				<xsl:with-param name="inner-text" select="opentopic-index:formatted-value"/>
				<xsl:with-param name="no-page" select="$isNoPage"/>
			</xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="opentopic-index:see-childs" mode="index-postprocess">
        <xsl:choose>
            <xsl:when test="parent::*[@no-page = 'true']">
                <fo:inline>
                    <xsl:call-template name="insertVariable">
                        <xsl:with-param name="theVariableID" select="'Index See String'"/>
                    </xsl:call-template>
                    <fo:basic-link>
                        <xsl:attribute name="internal-destination">
                            <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-destination"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-value"/>
                    </fo:basic-link>
                </fo:inline>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="index.entry__content">
                    <fo:inline >
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Index See Also String'"/>
                        </xsl:call-template>
                        <fo:basic-link>
                            <xsl:attribute name="internal-destination">
                                <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-destination"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-value"/>
                        </fo:basic-link>
                    </fo:inline>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="opentopic-index:index.entry" mode="get-see-destination">
        <xsl:value-of select="concat(@value,':')"/>
        <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-destination"/>
    </xsl:template>

    <xsl:template match="opentopic-index:index.entry" mode="get-see-value">
        <fo:inline>
            <xsl:call-template name="__formatText">
                <xsl:with-param name="text" select="opentopic-index:formatted-value"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-value"/>
        </fo:inline>
    </xsl:template>

    <xsl:template match="opentopic-index:see-also-childs" mode="index-postprocess">
        <fo:block xsl:use-attribute-sets="index.entry__content">
            <fo:inline>
                <xsl:call-template name="insertVariable">
                    <xsl:with-param name="theVariableID" select="'Index See Also String'"/>
                </xsl:call-template>
                <fo:basic-link>
                    <xsl:attribute name="internal-destination">
                        <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-destination"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-value"/>
                </fo:basic-link>
            </fo:inline>
        </fo:block>
    </xsl:template>

    <xsl:template match="opentopic-index:index.entry" mode="index-postprocess">
        <xsl:variable name="value" select="@value"/>

        <xsl:choose>
			<xsl:when test="opentopic-index:index.entry">
                <fo:table rx:table-omit-initial-header="true" width="100%">
                    <fo:table-header>
                        <fo:table-row keep-with-next.within-column="always">
                            <fo:table-cell>
                                <fo:block xsl:use-attribute-sets="index-indents" keep-with-next="always">
                                    <xsl:if test="count(ancestor::opentopic-index:index.entry) > 0">
                                        <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
                                    </xsl:if>
                                    <xsl:variable name="following-idx" select="following-sibling::opentopic-index:index.entry[@value = $value and opentopic-index:refID]"/>
                                    <xsl:if test="count(preceding-sibling::opentopic-index:index.entry[@value = $value]) = 0">
					<xsl:variable name="page-setting" select="(ancestor-or-self::opentopic-index:index.entry/@no-page | ancestor-or-self::opentopic-index:index.entry/@start-page)[last()]"/>
					<xsl:variable name="isNoPage" select="$page-setting = 'true' and name($page-setting) = 'no-page'"/>
					<xsl:variable name="refID" select="opentopic-index:refID/@value"/>
					<xsl:call-template name="make-index-ref-no-block">
						<xsl:with-param name="idxs" select="opentopic-index:refID"/>
						<xsl:with-param name="inner-text" select="opentopic-index:formatted-value"/>
						<xsl:with-param name="no-page" select="$isNoPage"/>
                                        </xsl:call-template>
					<fo:retrieve-table-marker retrieve-position="first-starting-within-page" retrieve-class-name="continued"/>
                                    </xsl:if>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-header>
                    <fo:table-body>
						<fo:table-row keep-with-next.within-column="always">
							<fo:table-cell>
								<fo:marker marker-class-name="continued"/>
							</fo:table-cell>
						</fo:table-row>
                        <fo:table-row keep-with-next.within-column="always">
                            <fo:table-cell>
								<fo:marker marker-class-name="continued">
									<xsl:value-of select="$continuedValue"/>
								</fo:marker>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block xsl:use-attribute-sets="index.entry__content">
                                    <xsl:apply-templates mode="index-postprocess"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="index-indents">
                    <xsl:if test="count(ancestor::opentopic-index:index.entry) > 0">
                        <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="following-idx" select="following-sibling::opentopic-index:index.entry[@value = $value and opentopic-index:refID]"/>
                    <xsl:if test="count(preceding-sibling::opentopic-index:index.entry[@value = $value]) = 0">
                        <xsl:variable name="page-setting" select=" (ancestor-or-self::opentopic-index:index.entry/@no-page | ancestor-or-self::opentopic-index:index.entry/@start-page)[last()]"/>
		                <xsl:variable name="isNoPage" select=" $page-setting = 'true' and name($page-setting) = 'no-page' "/>
                        <xsl:call-template name="make-index-ref">
                            <xsl:with-param name="idxs" select="opentopic-index:refID"/>
                            <xsl:with-param name="inner-text" select="opentopic-index:formatted-value"/>
                            <xsl:with-param name="no-page" select="$isNoPage"/>
                        </xsl:call-template>

                    </xsl:if>

                </fo:block>
                <fo:block xsl:use-attribute-sets="index.entry__content">
                    <xsl:apply-templates mode="index-postprocess"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



	<xsl:template name="__formatText">
		<xsl:param name="text"/>
		<xsl:param name="formatting" select="'Default Para Font'"/>
		<xsl:choose>
			<xsl:when test="starts-with($text, '&lt;')">
				<xsl:variable name="formatting-name" select="substring-before(substring-after($text, '&lt;'), '&gt;')"/>
				<xsl:call-template name="__formatText">
					<xsl:with-param name="text" select="substring-after($text, '&gt;')"/>
					<xsl:with-param name="formatting" select="$formatting-name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, '&lt;')">
				<xsl:call-template name="__formatText">
					<xsl:with-param name="text" select="substring-before($text, '&lt;')"/>
					<xsl:with-param name="formatting" select="$formatting"/>
				</xsl:call-template>
				<xsl:call-template name="__formatText">
					<xsl:with-param name="text" select="concat('&lt;', substring-after($text, '&lt;'))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$formatting = 'italic'">
						<fo:inline font-style="italic">
							<xsl:value-of select="$text"/>
						</fo:inline>
					</xsl:when>
					<xsl:when test="$formatting = 'bold'">
						<fo:inline font-weight="bold">
							<xsl:value-of select="$text"/>
						</fo:inline>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$text"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="make-index-ref">
		<xsl:param name="idxs"/>
		<xsl:param name="inner-text"/>
		<xsl:param name="no-page"/>
        <fo:block>
            <xsl:if test="position() = 1">
                <xsl:attribute name="keep-with-previous">always</xsl:attribute>
            </xsl:if>
            <fo:inline>
                <xsl:call-template name="__formatText">
                    <xsl:with-param name="text" select="$inner-text"/>
                </xsl:call-template>
            </fo:inline>
            <xsl:if test="$idxs">
                <xsl:for-each select="$idxs">
                    <fo:inline id="{generate-id(.)}"/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="not($no-page)">
                <xsl:if test="$idxs and count($idxs) &gt; 0">
                    <xsl:text> </xsl:text>
                    <fo:index-page-citation-list>
                        <xsl:for-each select="$idxs">
                            <fo:index-key-reference ref-index-key="{@value}" xsl:use-attribute-sets="__index__page__link"/>
                        </xsl:for-each>
                    </fo:index-page-citation-list>
                </xsl:if>
            </xsl:if>
            <xsl:for-each select="opentopic-index:see-childs | opentopic-index:see-also-childs">
                <xsl:apply-templates select="." mode="index-postprocess"/>
            </xsl:for-each>
        </fo:block>
	</xsl:template>

<!-- ALEX added to handle initial index entry with continued marker -->
	<xsl:template name="make-index-ref-no-block">
		<xsl:param name="idxs"/>
		<xsl:param name="inner-text"/>
		<xsl:param name="no-page"/>
            <fo:inline>
                <xsl:call-template name="__formatText">
                    <xsl:with-param name="text" select="$inner-text"/>
                </xsl:call-template>
            </fo:inline>
            <xsl:if test="$idxs">
                <xsl:for-each select="$idxs"><!-- ALEX 2011 03MAR 03 replacing @value which produces invalid ID results with the function generate-id() -->
                  <!--   <fo:inline id="{@value}"/> -->
				<fo:inline id="{generate-id()}"/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="not($no-page)">
                <xsl:if test="$idxs and count($idxs) &gt; 0">
                    <xsl:text> </xsl:text>
                    <fo:index-page-citation-list>
                        <xsl:for-each select="$idxs">
                            <fo:index-key-reference ref-index-key="{@value}" xsl:use-attribute-sets="__index__page__link"/>
                        </xsl:for-each>
                    </fo:index-page-citation-list>
                </xsl:if>
            </xsl:if>
            <xsl:for-each select="opentopic-index:see-childs | opentopic-index:see-also-childs">
                <xsl:apply-templates select="." mode="index-postprocess"/>
            </xsl:for-each>
	</xsl:template>



	<exslf:function name="opentopic-func:getIndexEntry">
		<xsl:param name="value"/>
		<xsl:param name="refID"/>

		<xsl:for-each select="$index-entries">
			<xsl:variable name="entries" select="key('index-key',$value)"/>
			<exslf:result select="$entries[opentopic-index:refID/@value = $refID]"/>
		</xsl:for-each>
	</exslf:function>


</xsl:stylesheet>
