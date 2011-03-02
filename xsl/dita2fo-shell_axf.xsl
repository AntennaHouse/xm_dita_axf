<?xml version="1.0" encoding="UTF-8" ?>
<!--
===============================================================
Copyright (c) 2006-2007 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
===============================================================
-->
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- import and include stylesheets -->
    <xsl:import href="dita2fo-shell.xsl"/>
    <xsl:include href="xslfo/dita2fo-index_axf.xsl"/>
    
    <!-- Inhibit indentation, it influences badly for fo:inline objects -->
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <!-- Indexterm count. Used in dita-setup, make-bookmark-tree, gen-toc. -->
    <xsl:variable name="indextermCount" select="count(//*[contains(@class, ' topic/indexterm ')])"/>
    <xsl:variable name="makeIndex" select="boolean($indextermCount &gt; 0)"/>

    <!-- 
        main control: called from dita2fo-shell.xsl
        (Originally coded in dita2fo-shell.xsl)
      -->
    <xsl:template name="dita-setup">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
            
            <!-- Delete FOP original book-mark generation -->
            <!--xsl:apply-templates mode="outline"></xsl:apply-templates-->

            <xsl:call-template name="define-page-masters-dita"></xsl:call-template>

            <!-- 
               Generate fo:bookmark-tree, fo:fo:bookmark, fo:bookmark-title
               instead of fox:outline, fox:label (Based on XSL1.1)
            -->
            <xsl:call-template name="make-bookmark-tree"/>

            <xsl:call-template name="front-covers"></xsl:call-template>

            <xsl:call-template name="generated-frontmatter"></xsl:call-template>

            <xsl:call-template name="main-doc3"></xsl:call-template>
            
            <!-- Generate index -->
            <xsl:if test="$makeIndex">
                <xsl:call-template name="make-index"/>
            </xsl:if>

        </fo:root>
    </xsl:template>

    <!-- 
        define-page-masters-dita: add index page master
        (Originally coded in dita2fo-shell.xsl)
      -->
    <xsl:template name="define-page-masters-dita">
        <fo:layout-master-set>
            <fo:page-sequence-master master-name="chapter-master">
                <fo:repeatable-page-master-alternatives>
                    <fo:conditional-page-master-reference page-position="first" odd-or-even="odd" master-reference="common-page"></fo:conditional-page-master-reference>

                    <fo:conditional-page-master-reference page-position="first" odd-or-even="even" master-reference="common-page"></fo:conditional-page-master-reference>

                    <fo:conditional-page-master-reference page-position="rest" odd-or-even="odd" master-reference="common-page"></fo:conditional-page-master-reference>

                    <fo:conditional-page-master-reference page-position="rest" odd-or-even="even" master-reference="common-page"></fo:conditional-page-master-reference>
                  
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
            <!-- for index page -->
            <fo:page-sequence-master master-name="index-master">
                <fo:repeatable-page-master-alternatives>
                    <fo:conditional-page-master-reference page-position="first" odd-or-even="odd" master-reference="index-page-first"></fo:conditional-page-master-reference>

                    <fo:conditional-page-master-reference page-position="first" odd-or-even="even" master-reference="index-page-first"></fo:conditional-page-master-reference>

                    <fo:conditional-page-master-reference page-position="rest" odd-or-even="odd" master-reference="index-page-rest"></fo:conditional-page-master-reference>

                    <fo:conditional-page-master-reference page-position="rest" odd-or-even="even" master-reference="index-page-rest"></fo:conditional-page-master-reference>
                  
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
            <fo:simple-page-master master-name="cover" xsl:use-attribute-sets="common-grid">
                <fo:region-body margin-top="72pt"></fo:region-body>
            </fo:simple-page-master>
            <fo:simple-page-master master-name="common-page" xsl:use-attribute-sets="common-grid">
                <fo:region-body margin-bottom="36pt" margin-top="12pt"></fo:region-body>
                <fo:region-before extent="12pt"></fo:region-before>
                <fo:region-after extent="24pt"></fo:region-after>
            </fo:simple-page-master>
            <!-- for index page -->
            <fo:simple-page-master master-name="index-page-first" xsl:use-attribute-sets="common-grid">
                <fo:region-body margin-bottom="36pt" margin-top="12pt" column-count="2" column-gap="24pt"></fo:region-body>
                <fo:region-before extent="12pt"></fo:region-before>
                <fo:region-after extent="24pt"></fo:region-after>
            </fo:simple-page-master>
            <fo:simple-page-master master-name="index-page-rest" xsl:use-attribute-sets="common-grid">
                <fo:region-body margin-bottom="36pt" margin-top="36pt" column-count="2" column-gap="24pt"></fo:region-body>
                <fo:region-before extent="12pt"></fo:region-before>
                <fo:region-after extent="24pt"></fo:region-after>
            </fo:simple-page-master>
        </fo:layout-master-set>
    </xsl:template>
    
    <!-- 
        Make XSL 1.1 fo:bookmark-tree
        (Modify existing templates match="*[contains(@class,' topic/topic ')]" mode="outline".)
      -->
    <xsl:template name="make-bookmark-tree">
        <fo:bookmark-tree>
            <xsl:apply-templates mode="outline"/>
            <xsl:if test="$makeIndex">
                <fo:bookmark internal-destination="{$cIndexId}">
                    <fo:bookmark-title>
                        <xsl:value-of select="$cIndexTitle"/>
                    </fo:bookmark-title>
                </fo:bookmark>
            </xsl:if>
        </fo:bookmark-tree>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/topic ')]" mode="outline">
      <xsl:variable name="id-value">
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="@id"></xsl:value-of>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="generate-id()"></xsl:value-of>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <fo:bookmark>
        <xsl:attribute name="internal-destination">
          <xsl:value-of select="$id-value"></xsl:value-of>
        </xsl:attribute>
        <fo:bookmark-title>
          <xsl:choose>
            <xsl:when test="*[contains(@class,' topic/titlealts ')]/*[contains(@class, ' topic/navtitle ')]">
              <xsl:apply-templates select="*[contains(@class,' topic/titlealts ')]/*[contains(@class, ' topic/navtitle ')]" mode="text-only"></xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="title" mode="text-only"></xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </fo:bookmark-title>
        <xsl:apply-templates select="child::*[contains(@class,' topic/topic ')]" mode="outline"></xsl:apply-templates>
      </fo:bookmark>
    </xsl:template>

    <!-- Ignore text other than topic/topic 2007/07/16 t.makita -->
    <xsl:template match="text()" mode="outline" />
    
    <!-- Get book title. It is used in some points.
         2008/07/16 t.makita
      -->
    <xsl:variable name="bookTitle">
        <xsl:choose>
            <xsl:when test="//*[contains(@class,' bookmap/mainbooktitle ')]">
                <xsl:value-of select="//*[contains(@class,' bookmap/mainbooktitle ')][1]/text()"/>
            </xsl:when>
            <xsl:when test="/*[contains(@class,' bookmap/bookmap ')]/*[contains(@class, ' topic/title ')]">
                <xsl:value-of select="/*[contains(@class,' bookmap/bookmap ')]/*[contains(@class, ' topic/title ')]"/>
            </xsl:when>
            <xsl:when test="/*[contains(@class,' map/map ')]/*[contains(@class, ' topic/title ')]">
                <xsl:value-of select="/*[contains(@class,' map/map ')]/*[contains(@class, ' topic/title ')]"/>
            </xsl:when>
            <xsl:when test="/*[contains(@class,' map/map ')]/@title">
                <xsl:value-of select="/*[contains(@class,' map/map ')]/@title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="//*/title[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <!-- 
        Make front covers: book title class is illegal. 
        (Originally coded in dita2fo-shell.xsl)
      -->
    <xsl:template name="front-covers">
      
      <fo:page-sequence master-reference="cover">
        <fo:flow flow-name="xsl-region-body">
          <fo:block text-align="right" font-family="Helvetica">
            
            <fo:block font-size="30pt" font-weight="bold" line-height="140%">
              <!-- 2007/07/16 t.makita-->
              <!--xsl:choose>
                <xsl:when test="//*[contains(@class,' bkinfo/bkinfo ')]">
                  <xsl:value-of select="//*[contains(@class,' bkinfo/bkinfo ')]/*[contains(@class,' topic/title ')]"></xsl:value-of>
                  <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkinfo ')]/@id"></xsl:apply-templates>
                </xsl:when>
                <xsl:when test="@title"><xsl:value-of select="@title"></xsl:value-of></xsl:when>
                <xsl:otherwise><xsl:value-of select="//*/title"></xsl:value-of></xsl:otherwise>
              </xsl:choose-->
              <xsl:value-of select="$bookTitle"/>
            </fo:block>
            <!-- COMMENT: FOP 0.20.5 does not accept margin-bottom="1in" -->
            <fo:block font-size="24pt" font-weight="bold" line-height="140%" margin-bottom="1in">
              <!-- 2007/07/22 t.makita -->
              <!--xsl:value-of select="//*[contains(@class,' bkinfo/bkinfo ')]/*[contains(@class,' bkinfo/bktitlealts ')]/*[contains(@class,' bkinfo/bksubtitle ')]"></xsl:value-of-->
              <xsl:choose>
                <xsl:when test="//*[contains(@class,' bkinfo/bkinfo ')]/*[contains(@class,' bkinfo/bktitlealts ')]/*[contains(@class,' bkinfo/bksubtitle ')]">
                  <xsl:value-of select="//*[contains(@class,' bkinfo/bkinfo ')]/*[contains(@class,' bkinfo/bktitlealts ')]/*[contains(@class,' bkinfo/bksubtitle ')]"/>
                </xsl:when>
                <xsl:when test="//*[contains(@class,' bookmap/booktitlealt ')]">
                  <xsl:value-of select="//*[contains(@class,' bookmap/booktitlealt ')][1]/text()"/>
                </xsl:when>
              </xsl:choose>
            </fo:block>
            
            <fo:block font-size="11pt" font-weight="bold" line-height="1.5">
              <xsl:text>[vertical list of authors]</xsl:text>
            </fo:block>
            <xsl:for-each select="//author">
              <xsl:variable name="authorid1" select="generate-id(.)"></xsl:variable>   
  			<xsl:variable name="authorid2" select="generate-id(//author[.=current()])"></xsl:variable>
  			<xsl:if test="$authorid1=$authorid2">
  			  <fo:block font-size="11pt" font-weight="bold" line-height="1.5">
  				[<xsl:value-of select="."></xsl:value-of>]
  			  </fo:block>
  			</xsl:if>            
  		  </xsl:for-each>
            
            <fo:block margin-top="3pc" font-size="11pt" font-weight="bold" line-height="normal"> ©    Copyright
              <!-- 2008/07/16 t.makita -->
              <!--xsl:value-of select="//*[contains(@class,' bkinfo/orgname ')]"></xsl:value-of-->
              <xsl:choose>
                <xsl:when test="//*[contains(@class,' bkinfo/orgname ')]">
                    <xsl:value-of select="//*[contains(@class,' bkinfo/orgname ')]"/>
                </xsl:when>
                <xsl:when test="//*[contains(@class,' bookmap/bookowner ')]/*[contains(@class,' bookmap/organization ')]">
                    <xsl:value-of select="//*[contains(@class,' bookmap/bookowner ')]/*[contains(@class,' bookmap/organization ')]/text()"/>
                </xsl:when>
                <xsl:when test="/*[contains(@class, ' map/map ')]/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/copyright ')]/*[contains(@class, ' topic/copyrholder ')]">
                    <xsl:value-of select="/*[contains(@class, ' map/map ')]/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/copyright ')]/*[contains(@class, ' topic/copyrholder ')]/text()"/>
                </xsl:when>
              </xsl:choose>
              <xsl:text></xsl:text>
              <!-- 2008/07/22 t.makita -->
              <!--xsl:value-of select="//*[contains(@class,' bkinfo/bkcopyrfirst ')]"></xsl:value-of>,<xsl:value-of select="//*[contains(@class,' bkinfo/bkcopyrlast ')]"></xsl:value-of>. </fo:block-->
              <xsl:choose>
                <xsl:when test="//*[contains(@class,' bookmap/copyrfirst ')]/*[contains(@class,' bookmap/year ')]">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="//*[contains(@class,' bookmap/copyrfirst ')]/*[contains(@class,' bookmap/year ')]"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//*[contains(@class,' bookmap/copyrlast ')]/*[contains(@class,' bookmap/year ')]"/>
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:when test="//*[contains(@class,' bkinfo/bkcopyrfirst ')]">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="//*[contains(@class,' bkinfo/bkcopyrfirst ')]"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="//*[contains(@class,' bkinfo/bkcopyrlast ')]"/>
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:when test="/*[contains(@class, ' map/map ')]/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/copyright ')]/*[contains(@class, ' topic/copyryear ')]">
                    <xsl:text> </xsl:text>
                    <xsl:variable name="copyryear" select="/*[contains(@class, ' map/map ')]/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/copyright ')]/*[contains(@class, ' topic/copyryear ')]"/>
                    <xsl:value-of select="$copyryear[1]/@year"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$copyryear[position()=last()]/@year"/>
                    <xsl:text>.</xsl:text>
                </xsl:when>
              </xsl:choose>  
            </fo:block>
          </fo:block>
          
          <xsl:call-template name="place-cover-art"></xsl:call-template>
          
        </fo:flow>
      </fo:page-sequence>
      
      <fo:page-sequence master-reference="cover">
        <fo:flow flow-name="xsl-region-body">
          <fo:block xsl:use-attribute-sets="p" color="purple" text-align="center"></fo:block>
        </fo:flow>
      </fo:page-sequence>
    </xsl:template>

    <xsl:template name="place-cover-art">
        <!-- COMMENT: FOP 0.20.5 seems to interpret border-style="dashed" as border-style="solid" -->
        <fo:block margin-top="2pc" font-family="Helvetica" border-style="dashed" border-color="black" border-width="thin" padding="6pt">
          <!-- COMMENT: FOP 0.20.5 does not accept margin-top="12pc" margin-bottom="12pc" -->
          <fo:block font-size="12pt" line-height="100%" margin-top="12pc" margin-bottom="12pc" text-align="center">
            <fo:inline color="purple" font-weight="bold">[cover art/text goes here]</fo:inline>
            
          </fo:block>
        </fo:block>
    </xsl:template>

    <!-- 
        BUGFIX: Ignore all cover items. If this template is not exist, redundant text appears in main context.
        2008/07/16 t.makita
      -->
    <xsl:template match="*[contains(@class,' bookmap/bookmap ')]/*[contains(@class,' topic/title ')]" />
    <xsl:template match="*[contains(@class,' bookmap/booktitle ')]" />
    <xsl:template match="*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]" />
    <xsl:template match="*[contains(@class,' map/map ')]/*[contains(@class,' bkinfo/bkinfo ')]" />
    <xsl:template match="*[contains(@class,' bookmap/bookmeta ')]" />
    <xsl:template match="*[contains(@class,' map/topicmeta ')]" />

    <!-- 
        BUGFIX: Illegal class reference to get book title.
        2008/07/16 t.makita
      -->
  <xsl:template name="generated-frontmatter">
    <fo:page-sequence master-reference="common-page" format="i" initial-page-number="1">
      
      
      <fo:static-content flow-name="xsl-region-before">
        
        <!--xsl:variable name="booktitle">
          <xsl:choose>
            <xsl:when test="//*[contains(@class,' bkinfo/bkinfo ')]">
              <xsl:value-of select="//*[contains(@class,' bkinfo/bkinfo ')]/*[contains(@class,' topic/title ')]"></xsl:value-of>
              <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkinfo ')]/@id"></xsl:apply-templates>
            </xsl:when>
            <xsl:when test="@title">
              <xsl:value-of select="@title"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="//*/title"></xsl:value-of></xsl:otherwise>
          </xsl:choose>
        </xsl:variable-->
        <fo:block font-size="8pt" line-height="8pt">
          <!--xsl:value-of select="$booktitle"></xsl:value-of-->
          <xsl:value-of select="$bookTitle"/>
        </fo:block>
      </fo:static-content>
      
      <fo:static-content flow-name="xsl-region-after">
        <fo:block text-align="center" font-size="10pt" font-weight="bold" font-family="Helvetica">
          <fo:page-number></fo:page-number>
        </fo:block>
      </fo:static-content>
      
      <fo:flow flow-name="xsl-region-body">
        
        <fo:block line-height="12pt" font-size="10pt" font-family="Helvetica" id="page1-1">
          <fo:block text-align="left" font-family="Helvetica">
            <fo:block>
              <fo:leader color="black" leader-pattern="rule" rule-thickness="3pt" leader-length="2in"></fo:leader>
            </fo:block>
            <fo:block font-size="20pt" font-weight="bold" line-height="140%">
              Contents </fo:block>
            <xsl:call-template name="gen-toc"></xsl:call-template>
          </fo:block>
        </fo:block>
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>

    <!-- 
        BUGFIX: Illegal class reference to get book title.
        2008/07/16 t.makita
      -->
    <xsl:template name="main-doc3">
        <fo:page-sequence master-reference="chapter-master">
          
          <fo:static-content flow-name="xsl-region-before">
            
            <!--xsl:variable name="booktitle">
              <xsl:choose>
                <xsl:when test="//*[contains(@class,' bkinfo/bkinfo ')]">
                  <xsl:value-of select="//*[contains(@class,' bkinfo/bkinfo ')]/*[contains(@class,' topic/title ')]"></xsl:value-of>
                  <xsl:apply-templates select="//*[contains(@class,' bkinfo/bkinfo ')]/@id"></xsl:apply-templates>
                </xsl:when>
                <xsl:when test="@title">
                  <xsl:value-of select="@title"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="//*/title"></xsl:value-of></xsl:otherwise>
              </xsl:choose>
            </xsl:variable-->
            <fo:block font-size="8pt" line-height="8pt">
              <!--xsl:value-of select="$booktitle"></xsl:value-of-->
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
              <xsl:apply-templates></xsl:apply-templates>
            </fo:block>
          </fo:flow>
        </fo:page-sequence>
    </xsl:template>


    <!-- 
        Make toc: Added index entry and fo:basic-link and comment
        (Originally coded in dita2fo-shell.xsl)
      -->
    <xsl:template name="gen-toc">
        <!-- Reject bkinfo 2008/07/22 t.makita -->
        <!-- Add bookmap/frontmatter 2008/07/24 t.makita -->
        <!--xsl:for-each select="//bookmap/*[contains(@class,' topic/topic ')]|//map/*[contains(@class,' topic/topic ')]"-->
        <!--xsl:for-each select="//bookmap/*[contains(@class,' topic/topic ')][not(contains(@class, ' bkinfo/bkinfo '))]|//map/*[contains(@class,' topic/topic ')][not(contains(@class, ' bkinfo/bkinfo '))]"-->
        <xsl:for-each select="//bookmap//*[contains(@class,' topic/topic ')][not(contains(@class, ' bkinfo/bkinfo '))][not(ancestor::*[contains(@class, ' topic/topic ')])]|//map/*[contains(@class,' topic/topic ')][not(contains(@class, ' bkinfo/bkinfo '))]">
            <xsl:variable name="id-value">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"></xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- COMMENT: FOP 0.20.5 does not accept margin-top="6pt" -->
            <fo:block text-align-last="justify" margin-top="6pt" margin-left="4.9pc">
                <!-- Add fo:basic-link -->
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:inline font-weight="bold">
                      <xsl:value-of select="*[contains(@class,' topic/title ')]"></xsl:value-of>
                    </fo:inline>
                </fo:basic-link>
                <fo:leader leader-pattern="dots"></fo:leader>
                <!-- Add fo:basic-link -->
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:page-number-citation ref-id="{$id-value}"></fo:page-number-citation>
                </fo:basic-link>
            </fo:block>
            <xsl:call-template name="get-tce2-section"></xsl:call-template>
        </xsl:for-each>
        <!-- Add index -->
        <xsl:if test="$makeIndex">
            <fo:block text-align-last="justify" margin-top="6pt" margin-left="4.9pc">
                <fo:basic-link internal-destination="{$cIndexId}">
                    <fo:inline font-weight="bold">
                      <xsl:value-of select="$cIndexTitle"/>
                    </fo:inline>
                </fo:basic-link>
                <fo:leader leader-pattern="dots"/>
                <fo:basic-link internal-destination="{$cIndexId}">
                    <fo:page-number-citation ref-id="{$cIndexId}"/>
                </fo:basic-link>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template name="get-tce2-section">
        <xsl:for-each select="*[contains(@class,' topic/topic ')]">
            <xsl:variable name="id-value">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"></xsl:value-of>
                    </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <fo:block text-align-last="justify" margin-left="7.5pc">
                <!-- Add fo:basic-link -->
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:inline font-weight="bold">
                        <xsl:value-of select="*[contains(@class,' topic/title ')]"></xsl:value-of>
                    </fo:inline>
                </fo:basic-link>
                <fo:leader leader-pattern="dots"></fo:leader>
                <!-- Add fo:basic-link -->
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:page-number-citation ref-id="{$id-value}"></fo:page-number-citation>
                </fo:basic-link>
            </fo:block>
            <xsl:call-template name="get-tce3-section"></xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="get-tce3-section">
        <xsl:for-each select="*[contains(@class,' topic/topic ')]">
            <xsl:variable name="id-value">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"></xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <fo:block text-align-last="justify" margin-left="9pc">
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:inline>
                        <xsl:value-of select="*[contains(@class,' topic/title ')]"></xsl:value-of>
                    </fo:inline>
                </fo:basic-link>
                <fo:leader leader-pattern="dots"></fo:leader>
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:page-number-citation ref-id="{$id-value}"></fo:page-number-citation>
                </fo:basic-link>
            </fo:block>
            <xsl:call-template name="get-tce4-section"></xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="get-tce4-section">
        <xsl:for-each select="bksubsect1">
            <xsl:variable name="id-value">
                <xsl:choose>
                    <xsl:when test="@id">
                       <xsl:value-of select="@id"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:value-of select="generate-id()"></xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <fo:block text-align-last="justify" margin-left="+5.9pc">
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:inline>
                        <xsl:value-of select="*/title"></xsl:value-of>
                    </fo:inline>
                </fo:basic-link>
                <fo:leader leader-pattern="dots"></fo:leader>
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:page-number-citation ref-id="{$id-value}"></fo:page-number-citation>
                </fo:basic-link>
            </fo:block>
            <xsl:call-template name="get-tce5-section"></xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="get-tce5-section">
        <xsl:for-each select="bksubsect2">
            <xsl:variable name="id-value">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"></xsl:value-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <fo:block text-align-last="justify" margin-left="+5.9pc">
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:inline>
                        <xsl:value-of select="*/title"></xsl:value-of>
                    </fo:inline>
                </fo:basic-link>
                <fo:leader leader-pattern="dots"></fo:leader>
                <fo:basic-link internal-destination="{$id-value}">
                    <fo:page-number-citation ref-id="{$id-value}"></fo:page-number-citation>
                </fo:basic-link>
            </fo:block>
          
        </xsl:for-each>
    </xsl:template>

    <!-- 
        "entryatts" template: BUG-FIX
        (Originally coded in xslfo/dita2fo-calstable.xsl)
      -->
    <!-- table "macros" -->
    <xsl:template name="entryatts">
        <xsl:call-template name="att-valign"/>
        <xsl:call-template name="att-align"/>
        <xsl:if test="string(@colsep)">
            <!--
                BUGFIX: "cellpadding" property does not defined in XSL recommendation.
                NOTES: In DITA specification, colsep's default value is "0". This will
                       mean there are no left/right rules in table cell. But all authoring
                       results and stylesheet implementation seems that table cell has 
                       the rule as default.
              -->
            <!--xsl:if test="@colsep='1'">
                <xsl:attribute name="cellpadding">10</xsl:attribute>
            </xsl:if-->
            <xsl:if test="@colsep='0'">
                <xsl:attribute name="border-left-style">none</xsl:attribute>
                <xsl:attribute name="border-right-style">none</xsl:attribute>
            </xsl:if>
        </xsl:if>
        <!-- IPL start -->
        <xsl:if test="string(@namest)">
            <xsl:variable name="colst" select="substring-after(@namest,'col')"/>
            <xsl:variable name="colend" select="substring-after(@nameend,'col')"/>
            <xsl:attribute name="number-columns-spanned">
            <xsl:value-of select="$colend - $colst + 1"/>
            </xsl:attribute>
        </xsl:if>
        <!-- IPL end -->
        <xsl:if test="@morerows">
            <xsl:attribute name="number-rows-spanned">
                <xsl:value-of select="@morerows+1"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- 
        "fo:list-item" generation template: Set "relative-align" property.
        (Originally coded in xslfo/dita2fo-lists.xsl)
     -->

    <xsl:template match="*[contains(@class,' topic/ul ')]/*[contains(@class,' topic/li ')]">
      <xsl:variable name="list-level" 
        select="count(ancestor-or-self::*[contains(@class,' topic/ul ')] | 
                      ancestor-or-self::*[contains(@class,' topic/dl ')] |
                      ancestor-or-self::*[contains(@class,' topic/sl ')] |
                      ancestor-or-self::*[contains(@class,' topic/ol ')] )" />
      <xsl:variable name="extra-list-indent"><xsl:value-of select="number($list-level)*16"/>pt</xsl:variable>
      <!--fo:list-item-->
      <fo:list-item relative-align="baseline">
        <fo:list-item-label end-indent="label-end()" text-align="end"> 
          <fo:block>
            <fo:inline>&#x2022;</fo:inline>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()"> 
          <!--xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/> + <xsl:value-of select="$extra-list-indent"/></xsl:attribute-->
          <fo:block> 
            <xsl:apply-templates /> 
          </fo:block> 
        </fo:list-item-body> 
      </fo:list-item>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ol ')]/*[contains(@class,' topic/li ')]">
      <xsl:variable name="list-level" 
        select="count(ancestor-or-self::*[contains(@class,' topic/ul ')] | 
                      ancestor-or-self::*[contains(@class,' topic/dl ')] |
                      ancestor-or-self::*[contains(@class,' topic/sl ')] |
                      ancestor-or-self::*[contains(@class,' topic/ol ')] )" />
      <xsl:variable name="extra-list-indent"><xsl:value-of select="number($list-level)*16"/>pt</xsl:variable>
      <!--fo:list-item-->
      <fo:list-item relative-align="baseline">
        <fo:list-item-label end-indent="label-end()" text-align="end">
          <fo:block><!-- linefeed-treatment="ignore"-->
            <xsl:choose> 
              <xsl:when test="($list-level mod 2) = 1"> 
                <!--          arabic         --> 
                <!--xsl:number format="1." /--> 
                <xsl:value-of select="position()"/>. 
              </xsl:when> 
              <xsl:otherwise> 
                <!--              alphabetic             --> 
                <xsl:number format="a." /> 
              </xsl:otherwise> 
            </xsl:choose> 
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()"> 
          <!--xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/> + <xsl:value-of select="$extra-list-indent"/></xsl:attribute-->
          <fo:block> 
             <xsl:apply-templates /> 
          </fo:block> 
        </fo:list-item-body> 
      </fo:list-item>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/sl ')]/*[contains(@class,' topic/sli ')]">
      <xsl:variable name="list-level" 
        select="count(ancestor-or-self::*[contains(@class,' topic/ul ')] | 
                      ancestor-or-self::*[contains(@class,' topic/dl ')] |
                      ancestor-or-self::*[contains(@class,' topic/sl ')] |
                      ancestor-or-self::*[contains(@class,' topic/ol ')] )" />
      <xsl:variable name="extra-list-indent"><xsl:value-of select="number($list-level)*16"/>pt</xsl:variable>
      <!--fo:list-item-->
      <fo:list-item relative-align="baseline">
        <fo:list-item-label end-indent="label-end()" text-align="end">
          <fo:block linefeed-treatment="ignore">
            <fo:inline><xsl:text> </xsl:text></fo:inline>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()"> 
          <!--xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/> + <xsl:value-of select="$extra-list-indent"/></xsl:attribute-->
          <fo:block> 
             <xsl:apply-templates /> 
          </fo:block> 
        </fo:list-item-body> 
      </fo:list-item>
    </xsl:template>

    <!-- 
        indexterm template: 
        Generate fo:inline with id attribute. Process first level indexterm only.
        (Originally coded in xslfo/dita2fo-elems.xsl)
      -->
    <xsl:template match="*[contains(@class,' topic/indexterm ')]">
        <fo:inline id="{generate-id()}"/>
    </xsl:template>

    <!-- 
        prolog template: 
        Changed to process descendant indexterm.  Process first level indexterm only.
        (Originally coded in topic2foImpl.xsl)
      -->
    <xsl:template match="*[contains(@class,' topic/prolog ')]">
        <xsl:apply-templates select="*//*[contains(@class,' topic/indexterm ')][not(ancestor::*[contains(@class,' topic/indexterm ')])]" />
    </xsl:template>

    <!-- Set table border-collapse to "collapse-with-precedence"
         for no cell rule of fo:table and set table background. 
         Newly added. 2007/10/16 
         LIMITATION: Current XSL Formatter does not draw rule of
         fo:table when there is no cell if border-collapse="collapse".
      -->
    <xsl:attribute-set name="table.simpletable">
      <xsl:attribute name="border-collapse">collapse-with-precedence</xsl:attribute>
      <xsl:attribute name="background-color">#fafafa</xsl:attribute>
    </xsl:attribute-set>

    <!-- 
         Simple table: Refined to generate fo:table-header
         Originally coded in xslfo/dita2fo-simpletable.xsl
         2007/10/16
     -->
    <xsl:template match="*[contains(@class,' topic/simpletable ')]">
        <fo:block space-before="12pt">
            <!-- Added table.simpletable for lacking cell 2007/10/16 -->
          <fo:table xsl:use-attribute-sets="table.data frameall table.simpletable">
                <xsl:call-template name="semtbl-colwidth"/>
                <!-- Refined -->
                <xsl:choose>
                    <xsl:when test="*/*[contains(@class,' topic/stentry ')]/@specentry">
                        <fo:table-header>
                            <xsl:call-template name="gen-dflt-data-hdr"/>
                        </fo:table-header>
                    </xsl:when>
                    <xsl:when test="*[contains(@class,' topic/sthead ')]">
                        <fo:table-header>
                            <xsl:apply-templates select="*[contains(@class,' topic/sthead ')]"/>
                        </fo:table-header>
                    </xsl:when>
                </xsl:choose>
                <fo:table-body>
                    <xsl:apply-templates select="*[contains(@class,' topic/strow ')]"/>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    
    <!-- Newly added.
         Border-width conditionality retain attribute. 2007/10/16
     -->
    <xsl:attribute-set name="border-width.retain">
      <xsl:attribute name="border-before-width.conditionality">retain</xsl:attribute>
      <xsl:attribute name="border-after-width.conditionality">retain</xsl:attribute>
    </xsl:attribute-set>

    <!-- 
         Simple table refinement.
         (Originally coded in xslfo/dita2fo-simpletable.xsl)
      -->
    <xsl:template match="*[contains(@class,' topic/sthead ')]/*[contains(@class,' topic/stentry ')]" priority="2">
      <!-- Add "border-width.retain" 2007/10/16 -->
      <fo:table-cell start-indent="2pt" background-color="silver" padding="2pt" text-align=
    "center" font-weight="bold" xsl:use-attribute-sets="frameall border-width.retain">
        <xsl:attribute name="column-number"><xsl:number count="*"/></xsl:attribute>
        <fo:block>
          <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:call-template name="get-title"/>
        </fo:block>
      </fo:table-cell>
    </xsl:template>


    <xsl:template match="*[contains(@class,' topic/stentry ')]">
      <xsl:variable name="localkeycol">
        <xsl:choose>
          <xsl:when test="ancestor::*[contains(@class,' topic/simpletable ')]/@keycol">
            <xsl:value-of select="ancestor::*[contains(@class,' topic/simpletable ')]/@keycol"/>
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="thisnum"><xsl:number/></xsl:variable>
      <xsl:variable name="thisrow"><xsl:number level="single" count="strow"/></xsl:variable>
      <!--xsl:message>Keycol: <xsl:value-of select="$localkeycol"/>  Number: <xsl:value-of select="$thisnum"/>  Row: <xsl:value-of select="$thisrow"/></xsl:message-->
      <xsl:choose>
        <xsl:when test="$thisnum=$localkeycol">
          <!-- Add "border-width.retain" 2007/10/16 -->
          <fo:table-cell start-indent="2pt" background-color="#fafafa" padding="2pt" xsl:use-attribute-sets="frameall  border-width.retain">
            <xsl:attribute name="column-number"><xsl:number count="*"/></xsl:attribute>
            <fo:block font-weight="bold">
              <xsl:attribute name="font-size">9pt</xsl:attribute>
              <xsl:apply-templates/> <!-- don't use "apply-for-phrases" for editor -->
            </fo:block>
          </fo:table-cell>
        </xsl:when>
        <xsl:otherwise>
          <!-- Add "border-width.retain" 2007/10/16 -->
          <fo:table-cell start-indent="2pt" background-color="#fafafa" padding="2pt" xsl:use-attribute-sets="frameall border-width.retain" border-after-width.conditionality="retain">
            <xsl:attribute name="column-number"><xsl:number count="*"/></xsl:attribute>
            <fo:block>
              <xsl:attribute name="font-size">9pt</xsl:attribute>
              <xsl:apply-templates/>
            </fo:block>
          </fo:table-cell>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <!-- CALS table refinement:
         Originally coded in dita2fo-calstable.xsl
    -->
      <xsl:template match="*[contains(@class,' topic/thead ')]/*[contains(@class,' topic/row ')]/*[contains(@class,' topic/entry ')]">
        <xsl:variable name="colnumval">
          <xsl:choose>
            <xsl:when test="@colname">
              <xsl:value-of select="ancestor::tgroup/colspec[@colname=current()/@colname]/@colnum"/>
            </xsl:when>
            <xsl:when test="@colnum">
              <xsl:value-of select="@colnum"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:number count="entry"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Add border-width.retain 2007/10/16 -->
        <fo:table-cell column-number="{$colnumval}" start-indent="2pt"
          background-color="silver" padding="2pt" text-align="center"
          font-weight="bold" xsl:use-attribute-sets="frameall border-width.retain">
          <!-- xsl:use-attribute-sets="table.data.th"-->
          <xsl:call-template name="entryatts"/>
          <fo:block>
            <xsl:call-template name="fillit"/>
          </fo:block>
        </fo:table-cell>
      </xsl:template>
    
    
      <xsl:template match="*[contains(@class,' topic/tfoot ')]/*[contains(@class,' topic/row ')]/*[contains(@class,' topic/entry ')]">
        <xsl:variable name="colnumval">
          <xsl:choose>
            <xsl:when test="@colname">
              <xsl:value-of select="ancestor::tgroup/colspec[@colname=current()/@colname]/@colnum"/>
            </xsl:when>
            <xsl:when test="@colnum">
              <xsl:value-of select="@colnum"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:number count="entry"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Add border-width.retain 2007/10/16 -->
        <fo:table-cell start-indent="2pt" column-number="{$colnumval}" xsl:use-attribute-sets="table.data.tf frameall border-width.retain">
          <xsl:call-template name="entryatts"/>
          <fo:block>
            <xsl:call-template name="fillit"/>
          </fo:block>
        </fo:table-cell>
      </xsl:template>

      <xsl:template match="*[contains(@class,' topic/tbody ')]/*[contains(@class,' topic/row ')]/*[contains(@class,' topic/entry ')]">
        <xsl:variable name="colnumval">
          <xsl:choose>
            <xsl:when test="@colname">
              <xsl:value-of select="ancestor::tgroup/colspec[@colname=current()/@colname]/@colnum"/>
            </xsl:when>
            <xsl:when test="@colnum">
              <xsl:value-of select="@colnum"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:number count="entry"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Add border-width.retain 2007/10/16 -->
        <fo:table-cell column-number="{$colnumval}" start-indent="2pt"
          background-color="#faf4fa" padding="2pt" xsl:use-attribute-sets="frameall border-width.retain">
          <xsl:call-template name="entryatts"/>
          <fo:block>
            <xsl:call-template name="fillit"/>
          </fo:block>
        </fo:table-cell>
      </xsl:template>

      <!-- Add id. Originally coded in dita2fo-list.xsl
           2008/07/22 t.makita
        -->
      <xsl:template match="*[contains(@class,' topic/ul ')]/*[contains(@class,' topic/li ')]">
        <xsl:variable name="list-level" 
          select="count(ancestor-or-self::*[contains(@class,' topic/ul ')] | 
                        ancestor-or-self::*[contains(@class,' topic/dl ')] |
                        ancestor-or-self::*[contains(@class,' topic/sl ')] |
                        ancestor-or-self::*[contains(@class,' topic/ol ')] )" />
        <xsl:variable name="extra-list-indent"><xsl:value-of select="number($list-level)*16"/>pt</xsl:variable>
        <fo:list-item>
          <!-- Add id. 2008/07/22 t.makita -->
          <xsl:if test="@id">
            <xsl:attribute name="id">
              <xsl:value-of select="@id"/>
            </xsl:attribute>
          </xsl:if>
          <fo:list-item-label end-indent="label-end()" text-align="end"> 
            <fo:block>
              <fo:inline>&#x2022;</fo:inline>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()"> 
            <!--xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/> + <xsl:value-of select="$extra-list-indent"/></xsl:attribute-->
            <fo:block> 
              <xsl:apply-templates /> 
            </fo:block> 
          </fo:list-item-body> 
        </fo:list-item>
      </xsl:template>


      <xsl:template match="*[contains(@class,' topic/ol ')]/*[contains(@class,' topic/li ')]">
        <xsl:variable name="list-level" 
          select="count(ancestor-or-self::*[contains(@class,' topic/ul ')] | 
                        ancestor-or-self::*[contains(@class,' topic/dl ')] |
                        ancestor-or-self::*[contains(@class,' topic/sl ')] |
                        ancestor-or-self::*[contains(@class,' topic/ol ')] )" />
        <xsl:variable name="extra-list-indent"><xsl:value-of select="number($list-level)*16"/>pt</xsl:variable>
        <fo:list-item>
          <!-- Add id. 2008/07/22 t.makita -->
          <xsl:if test="@id">
            <xsl:attribute name="id">
              <xsl:value-of select="@id"/>
            </xsl:attribute>
          </xsl:if>
          <fo:list-item-label end-indent="label-end()" text-align="end">
            <fo:block><!-- linefeed-treatment="ignore"-->
              <xsl:choose> 
                <xsl:when test="($list-level mod 2) = 1"> 
                  <!--          arabic         --> 
                  <!--xsl:number format="1." /--> 
                  <xsl:value-of select="position()"/>. 
                </xsl:when> 
                <xsl:otherwise> 
                  <!--              alphabetic             --> 
                  <xsl:number format="a." /> 
                </xsl:otherwise> 
              </xsl:choose> 
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()"> 
            <!--xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/> + <xsl:value-of select="$extra-list-indent"/></xsl:attribute-->
            <fo:block> 
               <xsl:apply-templates /> 
            </fo:block> 
          </fo:list-item-body> 
        </fo:list-item>
      </xsl:template>


</xsl:stylesheet>

