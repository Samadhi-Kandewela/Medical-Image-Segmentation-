<?xml version="1.0" encoding="utf-8"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2004 GE Healthcare

    FO_FUNC.XSL     :   XSLT rules for SR to FO transformation for Functool reports.

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="xml" indent="yes"/>


<xsl:include href="GEN_FO.XSL"/>
<xsl:include href="SECT_FO.XSL"/>
<xsl:include href="FUNC_FO.XSL"/>

<xsl:key name="content-item" match="Item" use="ConceptNameCodeSequence/Item/CodeValue"/>

<xsl:template match="/">

    <fo:root font-family="{$tp/Font/@type}" font-size="{$fontSize}pt" xmlns:fox="http://xml.apache.org/fop/extensions">

<!-- Page settings (media, height and width) -->
        <xsl:call-template name="addLayoutMasterSet"/>

<!-- Bookmarks to report sections -->
        <xsl:call-template name="addBookmarks"/>

        <fo:page-sequence master-reference="SimpleMaster">
<!-- Report footer -->
            <xsl:call-template name="addFooter"/>
<!-- Report content -->
            <xsl:call-template name="processSections"/>
        </fo:page-sequence>

    </fo:root>

</xsl:template>

<!-- ####################################################################################################
    Template:       addContentItem
    Description:    Add content item to report.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addContentItem"> <xsl:param name="pItem"/>
                                     <xsl:param name="pPosition"/>

    <xsl:variable name="nodeMeaning" select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
    <xsl:choose>
    <xsl:when test="$nodeMeaning!='Best Illustrations' or position()=6">

    <xsl:choose>
    <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeMeaning='Best Illustrations'">
    <fo:block break-before="page" id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="12pt" space-after="12pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC" keep-with-next.within-page="always">
        <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
    </fo:block>
    </xsl:when>
    <xsl:otherwise>
    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="12pt" space-after="12pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC" keep-with-next.within-page="always">
        <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
    </fo:block>
    </xsl:otherwise>
    </xsl:choose>

    </xsl:when>
    <xsl:otherwise>
        <fo:block break-before="page" id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="12pt" space-after="12pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC" keep-with-next.within-page="always">
                <xsl:text>  </xsl:text>
            </fo:block>

    </xsl:otherwise>
    </xsl:choose>

    <!-- Add value of different Value Types except CONTAINER -->
    <xsl:if test="not($pItem/ValueType_CONTAINER)">
        <fo:block space-after="12pt" break-before="page">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$pItem"/>
            </xsl:call-template>
        </fo:block>
    </xsl:if>

    <!-- Process ContentSequence if exists -->
    <xsl:if test="$pItem/ContentSequence">
        <xsl:variable name="main_heading" select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>

        <!-- process 'Best Illustrations' Separartely to get a customized look -->
        <xsl:choose>
        <xsl:when test="$main_heading='Best Illustrations'">
        <xsl:call-template name="addBestIllustrations">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
        <xsl:call-template name="addContent">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
        </xsl:otherwise>
        </xsl:choose>

    </xsl:if>

</xsl:template>

<!-- ####################################################################################################
    Template:       addContent
    Description:    Add content with recursion.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->
<xsl:template name="addContent"> <xsl:param name="pLevel"/>
                                 <xsl:param name="pCurrent"/>

    <xsl:variable name="defaultFontSize">
        <xsl:choose>
            <!-- 10pt if no font size is specififed in the template. -->
            <xsl:when test="$tp/Font/@size = ''">10</xsl:when>
            <xsl:otherwise><xsl:value-of select="$tp/Font/@size"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fontSize">
        <xsl:choose>
            <!-- Calculating font size based on template font size and recursion level. -->
            <xsl:when test="($defaultFontSize - $pLevel) &gt; 6">
                <xsl:value-of select="$defaultFontSize - $pLevel"/>
            </xsl:when>
            <!-- Smallest font is 6pt. -->
            <xsl:otherwise>6</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- 1/3 column width based on innerPageWidth -->
    <xsl:variable name="one3rdColWidth">
        <xsl:value-of select="number($innerPageWidth div 3)"/>
    </xsl:variable>
    <!-- 2/3 column width based on innerPageWidth -->
    <xsl:variable name="two3rdColWidth">
        <xsl:value-of select="$innerPageWidth - $one3rdColWidth"/>
    </xsl:variable>


    <xsl:for-each select="$pCurrent/ContentSequence/Item">
    <xsl:variable name="sub_heading" select="ConceptNameCodeSequence/Item/CodeMeaning"/>

    <xsl:choose>
    <xsl:when test="$sub_heading='Description'">
    <fo:table width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-body>
                <!-- value of the particular item  -->
                <fo:table-row>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="2mm" space-after="2mm">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>

                <!-- process additional elements within the description node -->
                <xsl:if test="current()/ContentSequence/Item">
                    <fo:table-row>
                        <fo:table-cell>
                            <xsl:call-template name="addContent">
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>

        </fo:table-body>
    </fo:table>
    </xsl:when>

    <xsl:otherwise>
    <fo:table width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="{concat($one3rdColWidth, $marginUnit)}"/>
    <fo:table-column>
        <xsl:attribute name="column-width"><xsl:value-of select="concat($two3rdColWidth - 3 * $pLevel, $marginUnit)"/></xsl:attribute>
    </fo:table-column>
    <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>

                <fo:table-row>
                    <fo:table-cell/>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="2mm" space-after="2mm">
                                <fo:inline font-weight="bold">
                                <xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="2mm" space-after="2mm">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell/>
                </fo:table-row>

                <xsl:if test="current()/ContentSequence/Item">
                    <fo:table-row>
                        <fo:table-cell/>
                        <fo:table-cell>
                            <xsl:call-template name="addContent">
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:table-cell>
                        <fo:table-cell/>
                        <fo:table-cell/>
                    </fo:table-row>
                </xsl:if>

        </fo:table-body>
    </fo:table>
    </xsl:otherwise>
    </xsl:choose>

    </xsl:for-each>

</xsl:template>

<!-- ####################################################################################################
    Template:       addBestIllustrations
    Description:    Add content of "Best Illustrations"(Rois)in a TABLE.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->

<xsl:template name="addBestIllustrations">
    <xsl:param name="pLevel"/>
    <xsl:param name="pCurrent"/>

    <xsl:variable name="defaultFontSize">
        <xsl:choose>
            <!-- 10pt if no font size is specififed in the template. -->
            <xsl:when test="$tp/Font/@size = ''">10</xsl:when>
            <xsl:otherwise><xsl:value-of select="$tp/Font/@size"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fontSize">
        <xsl:choose>
            <!-- Calculating font size based on template font size and recursion level. -->
            <xsl:when test="($defaultFontSize - $pLevel) &gt; 6">
                <xsl:value-of select="$defaultFontSize - $pLevel"/>
            </xsl:when>
            <!-- Smallest font is 6pt. -->
            <xsl:otherwise>6</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- 1/3 column width based on innerPageWidth -->
    <xsl:variable name="one3rdColWidth">
        <xsl:value-of select="number($innerPageWidth div 3)"/>
    </xsl:variable>
    <!-- 2/3 column width based on innerPageWidth -->
    <xsl:variable name="two3rdColWidth">
        <xsl:value-of select="$innerPageWidth - $one3rdColWidth"/>
    </xsl:variable>


    <xsl:for-each select="$pCurrent/ContentSequence/Item">
    <xsl:variable name="sub_heading" select="ConceptNameCodeSequence/Item/CodeMeaning"/>

    <xsl:choose>
    <xsl:when test="$sub_heading='Location'">
    <fo:table width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-body>
                <fo:table-row>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="2mm" space-after="2mm">
                            <fo:inline font-weight="bold">
                                <xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </fo:inline>
                            <fo:inline font-weight="bold">
                                :
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="2mm" space-after="2mm">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell/>
                    <fo:table-cell/>
                    <fo:table-cell/>
                    <fo:table-cell/>
                    <fo:table-cell/>
                    <fo:table-cell/>
                </fo:table-row>

                <xsl:if test="current()/ContentSequence/Item">
                    <fo:table-row>
                        <fo:table-cell/>
                        <fo:table-cell>
                            <xsl:call-template name="addBestIllustrations">
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:table-cell>
                        <fo:table-cell/>
                        <fo:table-cell/>
                    </fo:table-row>
                </xsl:if>

        </fo:table-body>
    </fo:table>
    </xsl:when>
    </xsl:choose>
    </xsl:for-each>

    <!-- Customize 'Image Capture' tag -->
    <xsl:call-template name="ImageCapture">
        <xsl:with-param name="pLevel" select="$pLevel"/>
        <xsl:with-param name="pCurrent" select="$pCurrent"/>
    </xsl:call-template>

    <xsl:for-each select="$pCurrent/ContentSequence/Item">
    <xsl:variable name="sub_heading" select="ConceptNameCodeSequence/Item/CodeMeaning"/>

    <xsl:choose>
    <!-- Customize 'Description' tag -->
    <xsl:when test="$sub_heading='Description'">
    <fo:table width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-body>
                <!-- value of the particular item  -->
                <fo:table-row>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="5mm" space-after="2mm">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>

                <!-- process additional elements within the description node -->
                <xsl:if test="current()/ContentSequence/Item">
                    <fo:table-row>
                        <fo:table-cell>
                            <xsl:call-template name="addBestIllustrations">
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>

        </fo:table-body>
    </fo:table>
    </xsl:when>

    <!-- process all other sub-headings -->
    <xsl:when test="$sub_heading!='Image Capture' and $sub_heading!='Location'">
    <fo:table width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="{concat($one3rdColWidth, $marginUnit)}"/>
    <fo:table-column>
        <xsl:attribute name="column-width"><xsl:value-of select="concat($two3rdColWidth - 3 * $pLevel, $marginUnit)"/></xsl:attribute>
    </fo:table-column>
    <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>

                <fo:table-row>
                    <fo:table-cell/>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="2mm" space-after="2mm">
                             <fo:inline font-weight="bold">
                                <xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell display-align="before">
                        <fo:block space-before="2mm" space-after="2mm">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell/>
                </fo:table-row>

                <xsl:if test="current()/ContentSequence/Item">
                    <fo:table-row>
                        <fo:table-cell/>
                        <fo:table-cell>
                            <xsl:call-template name="addBestIllustrations">
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:table-cell>
                        <fo:table-cell/>
                        <fo:table-cell/>
                    </fo:table-row>
                </xsl:if>

        </fo:table-body>
    </fo:table>
    </xsl:when>

    </xsl:choose>
    </xsl:for-each>

</xsl:template>

<!-- ####################################################################################################
    Template:       ImageCapture
    Description:    Add 'Image Capture related information
     Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing

-->
<xsl:template name="ImageCapture">
    <xsl:param name="pLevel"/>
    <xsl:param name="pCurrent"/>

        <xsl:variable name="image_set" select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <xsl:variable name="numOfImages" select="2"/>

                     <fo:table width="100%">
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                    <fo:table-body>

                        <xsl:call-template name="addNImagesFunc">
                                <xsl:with-param name="pImages" select="$image_set"/>
                                <xsl:with-param name="pN" select="$numOfImages"/>
                                <xsl:with-param name="numOfRows" select="0"/>
                        </xsl:call-template>

                </fo:table-body>
                </fo:table>

                <!-- add "Roi Group" statistics"-->
                <xsl:for-each select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeMeaning = 'Image Capture']">
                        <xsl:variable name="image_capture" select="current()/ContentSequence/Item"/>

                        <xsl:if test="$image_capture/ValueType_IMAGE and $image_capture/ConceptNameCodeSequence/Item/CodeMeaning = 'Roi Group'">

                        <fo:table>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                        <fo:table-row keep-together="always">
                        <fo:table-cell>

                        <fo:table>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>

                        <xsl:if test="$image_capture/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning='Name'">

                        <fo:table-row>
                        <fo:table-cell padding="5mm 0mm 0mm 0mm">
                                <fo:block text-align="center" background-color="#F0F1F6">
                                <fo:inline>
                                        <xsl:choose>
                                        <xsl:when test="$image_capture/ContentSequence/Item/ValueType_NUM">
                                        <xsl:call-template name="addNumValue">
                                                <xsl:with-param name="pCurrent" select="$image_capture/ContentSequence/Item"/>
                                        </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                        <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="$image_capture/ContentSequence/Item"/>
                                        </xsl:call-template>
                                        </xsl:otherwise>
                                        </xsl:choose>
                                </fo:inline>
                                </fo:block>
                        </fo:table-cell>
                        </fo:table-row>
                        </xsl:if>

                        <!-- add 'Roi Group' -->
                        <xsl:for-each select="$image_capture">

                        <xsl:if test="ConceptNameCodeSequence/Item/CodeMeaning = 'Roi Group'">
                        <fo:table-row>
                        <fo:table-cell>
                                <xsl:call-template name="addRoiGroup">
                                        <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                        <xsl:with-param name="pCurrent" select="current()"/>
                                </xsl:call-template>
                        </fo:table-cell>
                        </fo:table-row>
                        </xsl:if>

                        </xsl:for-each>

                        </fo:table-body>
                        </fo:table>

                        </fo:table-cell>
                        </fo:table-row>
                        </fo:table-body>
                        </fo:table>

                        </xsl:if>

                </xsl:for-each>

</xsl:template>


<!-- ####################################################################################################
    Template:       addRoiGroup
    Description:    Add roi Group within 'Iamge Capture' in a TABLE.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->

    <xsl:template name="addRoiGroup">
    <xsl:param name="pLevel"/>
    <xsl:param name="pCurrent"/>

         <xsl:variable name="defaultFontSize">
        <xsl:choose>
            <!-- 10pt if no font size is specififed in the template. -->
            <xsl:when test="$tp/Font/@size = ''">10</xsl:when>
            <xsl:otherwise><xsl:value-of select="$tp/Font/@size"/></xsl:otherwise>
        </xsl:choose>
            </xsl:variable>
            <xsl:variable name="fontSize">
        <xsl:choose>
            <!-- Calculating font size based on template font size and recursion level. -->
            <xsl:when test="($defaultFontSize - $pLevel) &gt; 6">
                <xsl:value-of select="$defaultFontSize - $pLevel"/>
            </xsl:when>
            <!-- Smallest font is 6pt. -->
            <xsl:otherwise>6</xsl:otherwise>
        </xsl:choose>
            </xsl:variable>

            <!-- 1/3 column width based on innerPageWidth -->
            <xsl:variable name="one3rdColWidth">
                <xsl:value-of select="number($innerPageWidth div 3)"/>
            </xsl:variable>
            <!-- 2/3 column width based on innerPageWidth -->
            <xsl:variable name="two3rdColWidth">
                       <xsl:value-of select="$innerPageWidth - $one3rdColWidth"/>
            </xsl:variable>

        <!-- if there are childs within Roi Group for Rois draw a seperate table -->
        <xsl:if test="current()/ContentSequence/Item">

        <!-- add columns and data -->
        <!-- draw the table columns only once -->
        <fo:table border-color="#C1C1C1" border-style="ridge" border-width="0.1mm" width="100%">
                <xsl:for-each select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeMeaning='Roi']">
                <xsl:variable name="roi_pos" select="position()"/>
                <xsl:if test="$roi_pos=1">
                        <xsl:for-each select="current()/ContentSequence/Item">
                                <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:for-each>
                </xsl:if>
                </xsl:for-each>
        <fo:table-body>
                <xsl:for-each select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeMeaning='Roi']">
                <xsl:variable name="roi_pos" select="position()"/>
                <xsl:if test="$roi_pos=1">
                <fo:table-row text-align="center">
                        <xsl:for-each select="current()/ContentSequence/Item">

                                <fo:table-cell font-size="8pt" border-color="#C1C1C1" border-style="ridge" border-width="0.1mm" display-align="center">
                                <fo:block space-before="2mm" space-after="2mm">
                                <fo:inline font-weight="bold">
                                        <xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/>
                                </fo:inline>
                                </fo:block>
                                </fo:table-cell>

                        </xsl:for-each>
                </fo:table-row>
                </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeMeaning='Roi']">
                <fo:table-row text-align="center">
                        <xsl:for-each select="current()/ContentSequence/Item">
                                <fo:table-cell font-size="8pt" border-color="#C1C1C1" border-style="ridge" border-width="0.1mm" display-align="center">
                                <fo:block space-before="1.5mm" space-after="1.5mm">
                                <xsl:choose>
                                <xsl:when test="current()/ValueType_NUM">
                                        <xsl:call-template name="addNumValue">
                                                <xsl:with-param name="pCurrent" select="current()"/>
                                        </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                       <xsl:call-template name="addValue">
                                               <xsl:with-param name="pCurrent" select="current()"/>
                                       </xsl:call-template>
                                </xsl:otherwise>
                                </xsl:choose>
                                </fo:block>
                                </fo:table-cell>

                        </xsl:for-each>
                </fo:table-row>
                </xsl:for-each>

        </fo:table-body>
        </fo:table>

            </xsl:if><!-- if there are childs within Roi Group -->

</xsl:template>

<!-- ####################################################################################################
    Template:       addNImagesFunc
    Description:    Recursively adds Image captures organized into N columns.
    Parameters:
        pImages   :  Image Capture node-set.
        pN        :  # of columns images displayed across.
        numOfRows :  # of rows of images in a single page.
-->
<xsl:template name="addNImagesFunc">
    <xsl:param name="pImages"/>
    <xsl:param name="pN"/>
    <xsl:param name="numOfRows"/>


    <xsl:variable name="firstNImages" select="$pImages[position() &lt;= $pN]"/>
    <fo:table-row keep-together="always">
        <xsl:for-each select="$firstNImages">

                <fo:table-cell>
                <fo:table width="100%">
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-body>

                <xsl:for-each select="current()/ContentSequence/Item">
                <xsl:variable name="child_tag_name" select="ConceptNameCodeSequence/Item/CodeMeaning"/>

                        <xsl:choose>
                        <!-- first child is the image -->
                        <xsl:when test="current()/ValueType_IMAGE">

                                <fo:table-row>
                                <!-- print the value of image name -->
                                <fo:table-cell display-align="before" padding="0mm 0mm 0mm 0mm">
                                                <fo:block text-align="center" background-color="#F0F1F6" space-before="2mm" space-after="0mm">
                                                <fo:inline font-weight="bold">
                                                        <xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                </fo:inline>
                                                </fo:block>
                                </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                <fo:table-cell display-align="before" padding="0mm 0mm 0mm 0mm">
                                <fo:block space-before="0mm" space-after="2mm">
                                        <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="current()"/>
                                        </xsl:call-template>
                                </fo:block>
                                </fo:table-cell>
                                </fo:table-row>
                        </xsl:when>
                        <xsl:when test="$child_tag_name='Description'">
                                <fo:table-row>
                                <fo:table-cell display-align="before" padding="0mm 4mm 0mm 0mm">
                                <fo:block space-before="2mm" space-after="2mm">
                                <xsl:call-template name="addValue">
                                        <xsl:with-param name="pCurrent" select="current()"/>
                                     </xsl:call-template>
                                 </fo:block>
                                </fo:table-cell>
                                </fo:table-row>

                        </xsl:when>

                        </xsl:choose>

                </xsl:for-each>
                </fo:table-body>
                </fo:table>
            </fo:table-cell>

        </xsl:for-each>
    </fo:table-row>
    <xsl:variable name="remainingImages" select="$pImages[position() &gt; $pN]"/>
    <xsl:if test="count($remainingImages) != 0">
        <xsl:call-template name="addNImagesFunc">
            <xsl:with-param name="pImages" select="$remainingImages"/>
            <xsl:with-param name="pN" select="$pN"/>
            <xsl:with-param name="numOfRows" select="$numOfRows + 1"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
