<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2005 GE Healthcare

    GEN_FO.XSL      :   Generic and commonly used XSLT temaplates for FO output.

    Author          :   Attila RACZ
    Last modified on:   Jun 24, 2005
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg">

<xsl:include href="../GEN.XSL"/>

<!-- Global variables -->
<xsl:variable name="UNIT_MILLIMETER">mm</xsl:variable>
<xsl:variable name="UNIT_INCH">in</xsl:variable>
<!-- A4 media size in millimeters -->
<xsl:variable name="A4_HEIGHT">297</xsl:variable>
<xsl:variable name="A4_WIDTH">210</xsl:variable>
<xsl:variable name="A4_UNIT">mm</xsl:variable>
<!-- US letter media size in inches -->
<xsl:variable name="US_LETTER_HEIGHT">11</xsl:variable>
<xsl:variable name="US_LETTER_WIDTH">8.5</xsl:variable>
<xsl:variable name="US_UNIT">in</xsl:variable>
<!-- If no dimensions are given, FOP uses a default value of 72 dpi to compute the graphic's dimensions. -->
<xsl:variable name="FOP_DPI">72</xsl:variable>
<!-- Rate of $innerPageHeight for large image heigth calcualtion. -->
<xsl:variable name="LARGE_IMAGE_RATE">0.9</xsl:variable>

<!-- Actual A4 media width based on orientation(portrait, landscape) -->
<xsl:variable name="a4Width">
    <xsl:call-template name="countA4Width"/>
</xsl:variable>
<!-- Actual A4 media height based on orientation(portrait, landscape) -->
<xsl:variable name="a4Height">
    <xsl:call-template name="countA4Height"/>
</xsl:variable>
<!-- Actual US media width based on orientation(portrait, landscape) -->
<xsl:variable name="usWidth">
    <xsl:call-template name="countUSWidth"/>
</xsl:variable>
<!-- Actual US media height based on orientation(portrait, landscape) -->
<xsl:variable name="usHeight">
    <xsl:call-template name="countUSHeight"/>
</xsl:variable>

<!-- Actual page width based on media (A4, US letter) -->
<xsl:variable name="pageWidth">
    <xsl:call-template name="countPageWidth"/>
</xsl:variable>
<!-- Actual page height based on media (A4, US letter) -->
<xsl:variable name="pageHeight">
    <xsl:call-template name="countPageHeight"/>
</xsl:variable>

<!-- Units of page -->
<xsl:variable name="pageUnit">
    <xsl:call-template name="countPageUnit"/>
</xsl:variable>

<!-- Portrait page width based on media (A4, US letter). -->
<xsl:variable name="portraitWidth">
    <xsl:call-template name="getPortraitWidth"/>
</xsl:variable>
<!-- Portrait page height based on media (A4, US letter). -->
<xsl:variable name="portraitHeight">
    <xsl:call-template name="getPortraitHeight"/>
</xsl:variable>

<!-- Units of margins -->
<xsl:variable name="marginUnit" select="$tp/FixedOutput/Margin/@unit"/>

<!-- Inner page width -->
<xsl:variable name="innerPageWidth">
    <xsl:call-template name="countInnerPageWidth"/>
</xsl:variable>
<!-- Inner page height -->
<xsl:variable name="innerPageHeight">
    <xsl:call-template name="countInnerPageHeight"/>
</xsl:variable>

<!-- Top margin -->
<xsl:variable name="topMargin">
    <xsl:call-template name="setMargin">
        <xsl:with-param name="pMargin" select="'Top'"/>
    </xsl:call-template>
</xsl:variable>
<!-- Bottom margin -->
<xsl:variable name="bottomMargin">
    <xsl:call-template name="setMargin">
        <xsl:with-param name="pMargin" select="'Bottom'"/>
    </xsl:call-template>
</xsl:variable>
<!-- Left margin -->
<xsl:variable name="leftMargin">
    <xsl:call-template name="setMargin">
        <xsl:with-param name="pMargin" select="'Left'"/>
    </xsl:call-template>
</xsl:variable>
<!-- Right margin -->
<xsl:variable name="rightMargin">
    <xsl:call-template name="setMargin">
        <xsl:with-param name="pMargin" select="'Right'"/>
    </xsl:call-template>
</xsl:variable>

<!-- 1/3 column width based on innerPageWidth -->
<xsl:variable name="oneThirdColWidth">
    <xsl:value-of select="number($innerPageWidth div 3)"/>
</xsl:variable>

<!-- 2/3 column width based on innerPageWidth -->
<xsl:variable name="twoThirdColWidth">
    <xsl:value-of select="$innerPageWidth - $oneThirdColWidth"/>
</xsl:variable>


<!-- ####################################################################################################
    Template:       setMargin
    Description:    Set margin from template.
    Parameters:
-->
<xsl:template name="setMargin"> <xsl:param name="pMargin"/>
    <xsl:choose>
        <xsl:when test="$pMargin = 'Top'">
            <xsl:value-of select="$tp/FixedOutput/Margin/Top"/>
        </xsl:when>
        <xsl:when test="$pMargin = 'Bottom'">
            <xsl:value-of select="$tp/FixedOutput/Margin/Bottom"/>
        </xsl:when>
        <xsl:when test="$pMargin = 'Left'">
            <xsl:value-of select="$tp/FixedOutput/Margin/Left"/>
        </xsl:when>
        <xsl:when test="$pMargin = 'Right'">
            <xsl:value-of select="$tp/FixedOutput/Margin/Right"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- ####################################################################################################
    Template:       addLayoutMasterSet
    Description:    Define page settings (media, height and width, margins).
    Parameters:
-->
<xsl:template name="addLayoutMasterSet">
    <fo:layout-master-set>
        <fo:simple-page-master master-name="SimpleMaster"
                               page-width="{concat($pageWidth, $pageUnit)}"
                               page-height="{concat($pageHeight, $pageUnit)}">
            <fo:region-before extent="{concat($tp/FixedOutput/Margin/Top, $marginUnit)}"/>
            <fo:region-body margin-top="{concat($topMargin, $marginUnit)}"
                            margin-bottom="{concat($bottomMargin, $marginUnit)}"
                            margin-left="{concat($leftMargin, $marginUnit)}"
                            margin-right="{concat($rightMargin, $marginUnit)}"/>
            <fo:region-after extent="{concat($tp/FixedOutput/Margin/Bottom, $marginUnit)}"/>
        </fo:simple-page-master>
    </fo:layout-master-set>
</xsl:template>

<!-- ####################################################################################################
    Template:       countInnerPageWidth
    Description:    Count inner page width.
    Parameters:
-->
<xsl:template name="countInnerPageWidth">

    <xsl:choose>
<!-- Page unit is A4_UNIT -->
        <xsl:when test="$pageUnit = $A4_UNIT">
            <xsl:choose>
        <!-- Margin unit is A4_UNIT -->
                <xsl:when test="$marginUnit = $A4_UNIT">
                    <xsl:value-of select="number($pageWidth - $leftMargin - $rightMargin)"/>
                </xsl:when>
        <!-- Margin unit is US_UNIT -->
                <xsl:otherwise>
                    <xsl:value-of select="format-number(($pageWidth div ($RATE_cm_in * 10)) - $leftMargin - $rightMargin, '#.#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
<!-- Page unit is US_UNIT -->
        <xsl:otherwise>
            <xsl:choose>
        <!-- Margin unit is US_UNIT -->
                <xsl:when test="$marginUnit = $US_UNIT">
                    <xsl:value-of select="number($pageWidth - $leftMargin - $rightMargin)"/>
                </xsl:when>
        <!-- Margin unit is A4_UNIT -->
                <xsl:otherwise>
                    <xsl:value-of select="format-number(($pageWidth * $RATE_cm_in * 10) - $leftMargin - $rightMargin, '#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countInnerPageHeight
    Description:    Count inner page height.
    Parameters:
-->
<xsl:template name="countInnerPageHeight">

    <xsl:choose>
<!-- Page unit is A4_UNIT -->
        <xsl:when test="$pageUnit = $A4_UNIT">
            <xsl:choose>
        <!-- Margin unit is A4_UNIT -->
                <xsl:when test="$marginUnit = $A4_UNIT">
                    <xsl:value-of select="number($pageHeight - $topMargin - $bottomMargin)"/>
                </xsl:when>
        <!-- Margin unit is US_UNIT -->
                <xsl:otherwise>
                    <xsl:value-of select="format-number(($pageHeight div ($RATE_cm_in * 10)) - $topMargin - $bottomMargin, '#.#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
<!-- Page unit is US_UNIT -->
        <xsl:otherwise>
            <xsl:choose>
        <!-- Margin unit is US_UNIT -->
                <xsl:when test="$marginUnit = $US_UNIT">
                    <xsl:value-of select="number($pageHeight - $topMargin - $bottomMargin)"/>
                </xsl:when>
        <!-- Margin unit is A4_UNIT -->
                <xsl:otherwise>
                    <xsl:value-of select="format-number(($pageHeight * $RATE_cm_in * 10) - $topMargin - $bottomMargin, '#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countA4Width
    Description:    Count A4 media width based on orientation(portrait, landscape).
    Parameters:
-->
<xsl:template name="countA4Width">
    <xsl:choose>
        <xsl:when test="$tp/FixedOutput/Orientation = 'Portrait'">
            <xsl:value-of select="$A4_WIDTH"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$A4_HEIGHT"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countA4Height
    Description:    Count A4 media height based on orientation(portrait, landscape).
    Parameters:
-->
<xsl:template name="countA4Height">
    <xsl:choose>
        <xsl:when test="$tp/FixedOutput/Orientation = 'Portrait'">
            <xsl:value-of select="$A4_HEIGHT"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$A4_WIDTH"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countUSWidth
    Description:    Count US media width based on orientation(portrait, landscape).
    Parameters:
-->
<xsl:template name="countUSWidth">
    <xsl:choose>
        <xsl:when test="$tp/FixedOutput/Orientation = 'Portrait'">
            <xsl:value-of select="$US_LETTER_WIDTH"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$US_LETTER_HEIGHT"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countUSHeight
    Description:    Count US media height based on orientation(portrait, landscape).
    Parameters:
-->
<xsl:template name="countUSHeight">
    <xsl:choose>
        <xsl:when test="$tp/FixedOutput/Orientation = 'Portrait'">
            <xsl:value-of select="$US_LETTER_HEIGHT"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$US_LETTER_WIDTH"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countPageWidth
    Description:    Count page width based on media (A4, US letter) and orientation (portrait, landscape).
    Parameters:
-->
<xsl:template name="countPageWidth">
    <xsl:choose>
<!-- A4 media size -->
        <xsl:when test="$tp/FixedOutput/MediaSize = 'A4'">
            <xsl:value-of select="$a4Width"/>
        </xsl:when>
<!-- US Letter media size -->
        <xsl:otherwise>
            <xsl:value-of select="$usWidth"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countPageHeight
    Description:    Count page width based on media (A4, US letter) and orientation (portrait, landscape).
    Parameters:
-->
<xsl:template name="countPageHeight">
    <xsl:choose>
<!-- A4 media size -->
        <xsl:when test="$tp/FixedOutput/MediaSize = 'A4'">
            <xsl:value-of select="$a4Height"/>
        </xsl:when>
<!-- US Letter media size -->
        <xsl:otherwise>
            <xsl:value-of select="$usHeight"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       countPageUnit
    Description:    Count page unit based on media (A4, US letter).
    Parameters:
-->
<xsl:template name="countPageUnit">
    <xsl:choose>
<!-- A4 media size -->
        <xsl:when test="$tp/FixedOutput/MediaSize = 'A4'">
            <xsl:value-of select="$A4_UNIT"/>
        </xsl:when>
<!-- US Letter media size -->
        <xsl:otherwise>
            <xsl:value-of select="$US_UNIT"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       getPortraitWidth
    Description:    Retrieve portrait page width based on media (A4, US letter).
    Parameters:
-->
<xsl:template name="getPortraitWidth">
    <xsl:choose>
<!-- A4 media size -->
        <xsl:when test="$tp/FixedOutput/MediaSize = 'A4'">
            <xsl:value-of select="$A4_WIDTH"/>
        </xsl:when>
<!-- US Letter media size -->
        <xsl:otherwise>
            <xsl:value-of select="$US_LETTER_WIDTH"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       getPortraitHeight
    Description:    Retrieve portrait page height based on media (A4, US letter).
    Parameters:
-->
<xsl:template name="getPortraitHeight">
    <xsl:choose>
<!-- A4 media size -->
        <xsl:when test="$tp/FixedOutput/MediaSize = 'A4'">
            <xsl:value-of select="$A4_HEIGHT"/>
        </xsl:when>
<!-- US Letter media size -->
        <xsl:otherwise>
            <xsl:value-of select="$US_LETTER_HEIGHT"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       caluclateSizeInPageUnit
    Description:    Calculate size in page unit defined by $pageUnit using default $FOP_DPI resolution.
    Parameters:
        pSize    :  Size in pixels
-->
<xsl:template name="caluclateSizeInPageUnit"> <xsl:param name="pSize"/>
    <xsl:choose>
<!-- A4 media size -->
        <xsl:when test="$pageUnit = $A4_UNIT">
            <xsl:value-of select="($pSize div $FOP_DPI) * $RATE_cm_in * 10"/>
        </xsl:when>
<!-- US Letter media size -->
        <xsl:otherwise>
            <xsl:value-of select="$pSize div $FOP_DPI"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       break2NewLine
    Description:    Break down $pNewLineSeparator separated string into fo:blocks.
    Parameters:
        pAlign	:  Alignment
        pText 	:  Text to break down.
        pNewLineSeparator	: new line character
-->
<xsl:template name="break2NewLine"> <xsl:param name="pAlign"/>
                                    <xsl:param name="pText"/>
                                    <xsl:param name="pNewLineSeparator" select="$NewLineSeparator"/>

    <xsl:choose>
        <xsl:when test="contains($pText, $pNewLineSeparator)">
            <fo:block hyphenate="true" language="{$lang}" text-align="{$pAlign}" white-space-collapse="false">
                <xsl:value-of select="substring-before($pText, $pNewLineSeparator)"/>
                <xsl:text> </xsl:text>
            </fo:block>
            <xsl:call-template name="break2NewLine">
                <xsl:with-param name="pAlign" select="$pAlign"/>
                <xsl:with-param name="pText" select="substring-after($pText, $pNewLineSeparator)"/>
                <xsl:with-param name="pNewLineSeparator" select="$pNewLineSeparator"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <fo:block hyphenate="true" language="{$lang}" text-align="{$pAlign}">
                <xsl:value-of select="$pText"/>
            </fo:block>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addProportionalTableColumn
    Description:    Adds N proportional column to table.
    Parameters:
        pN        :  # of columns.
-->
<xsl:template name="addProportionalTableColumn"> <xsl:param name="pN"/>

    <xsl:if test="$pN &gt; 0">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <xsl:if test="$pN &gt; 1">
            <xsl:call-template name="addProportionalTableColumn">
                <xsl:with-param name="pN" select="$pN - 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addRadioButtons
    Description:    Recursively adds radio buttons organized into N columns.
    Parameters:
        pItems      : value
        pSelection  : Selected value(s).
        pN          : Number of columns.
        pMark       : Check mark of the selected radio buttons. cross = X, dot = \u2022
-->
<xsl:template name="addRadioButtons"> <xsl:param name="pItems"/>
                                      <xsl:param name="pSelection"/>
                                      <xsl:param name="pN"/>
                                      <xsl:param name="pMark" select="'dot'"/>

    <fo:table table-layout="fixed" width="100%">
        <xsl:call-template name="addProportionalTableColumn">
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
        <fo:table-body>
            <xsl:call-template name="addNRadioButton">
                <xsl:with-param name="pItems" select="$pItems"/>
                <xsl:with-param name="pSelection" select="$pSelection"/>
                <xsl:with-param name="pN" select="$pN"/>
                <xsl:with-param name="pMark" select="$pMark"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNRadioButton
    Description:    Recursively adds radio buttons organized into N columns.
    Parameters:
        pItems      : value
        pSelection  : The selected value
        pN          : Number of columns.
        pMark       : Check mark of the selected radio buttons. cross = X, dot = \u2022
-->
<xsl:template name="addNRadioButton"> <xsl:param name="pItems"/>
                                      <xsl:param name="pSelection"/>
                                      <xsl:param name="pN"/>
                                      <xsl:param name="pMark" select="'dot'"/>

    <xsl:variable name="firstNItem" select="$pItems[position() &lt;= $pN]"/>
    <fo:table-row keep-together="always">
        <xsl:for-each select="$firstNItem">
            <fo:table-cell text-align="left" display-align="before" padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                <fo:block hyphenate="true" language="{$lang}">
                    <fo:instream-foreign-object>
                        <svg:svg width="{$fontSize}" height="{$fontSize}">
                            <svg:circle cx="{$fontSize div 2}" cy="{$fontSize div 2}" r="{$fontSize div 2 - 1}" fill="none" stroke="#000000"/>
                            <xsl:if test="$pSelection = current()/msg[@lang = $lang]">
                                <xsl:choose>
                                    <xsl:when test="$pMark = 'cross'">
                                        <svg:line x1="3" y1="3" x2="{$fontSize - 3}" y2="{$fontSize - 3}" stroke="#0000FF" stroke-width="2"/>
                                        <svg:line x1="{$fontSize - 3}" y1="3" x2="3" y2="{$fontSize - 3}" stroke="#0000FF" stroke-width="2"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <svg:circle cx="{$fontSize div 2}" cy="{$fontSize div 2}" r="{$fontSize div 2 - 3}" fill="#0000FF"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </svg:svg>
                    </fo:instream-foreign-object>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="current()/msg[@lang = $lang]"/>
                </fo:block>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>

    <xsl:variable name="remainingItems" select="$pItems[position() &gt; $pN]"/>
<!-- Recursive call for remaining items. -->
    <xsl:if test="count($remainingItems) != 0">
        <xsl:call-template name="addNRadioButton">
            <xsl:with-param name="pItems" select="$remainingItems"/>
            <xsl:with-param name="pSelection" select="$pSelection"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCheckBoxes
    Description:    Recursively adds check boxes organized into N columns.
    Parameters:
        pItems      : value
        pSelection  : Selected value(s).
        pN          : Number of columns.
        pMark       : Check mark of the selected check boxes. cross = X, pipe = \u221A
        pStyle      : Visual style of the check boxes: 2D (default), 3D
        pFontSize   : Font size with $fontSize default.
-->
<xsl:template name="addCheckBoxes"> <xsl:param name="pItems"/>
                                    <xsl:param name="pSelection"/>
                                    <xsl:param name="pN" select="'2'"/>
                                    <xsl:param name="pMark" select="'cross'"/>
                                    <xsl:param name="pStyle" select="'2D'"/>
                                    <xsl:param name="pFontSize" select="$fontSize"/>

    <fo:table table-layout="fixed" width="100%">
        <xsl:call-template name="addProportionalTableColumn">
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
        <fo:table-body>
            <xsl:call-template name="addNCheckBox">
                <xsl:with-param name="pItems" select="$pItems"/>
                <xsl:with-param name="pSelection" select="$pSelection"/>
                <xsl:with-param name="pN" select="$pN"/>
                <xsl:with-param name="pMark" select="$pMark"/>
                <xsl:with-param name="pStyle" select="$pStyle"/>
                <xsl:with-param name="pFontSize" select="$pFontSize"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNCheckBox
    Description:    Recursively adds check boxes organized into N columns.
    Parameters:
        pItems      : value
        pSelection  : The selected value
        pMark       : Check mark of the selected check boxes. cross = X, pipe = \u221A
        pStyle      : Visual style of the check boxes: 2D (default), 3D
        pFontSize   : Font size with $fontSize default.
-->
<xsl:template name="addNCheckBox"> <xsl:param name="pItems"/>
                                   <xsl:param name="pSelection"/>
                                   <xsl:param name="pN" select="'2'"/>
                                   <xsl:param name="pMark" select="'cross'"/>
                                   <xsl:param name="pStyle" select="'2D'"/>
                                   <xsl:param name="pFontSize" select="$fontSize"/>

    <xsl:variable name="firstNItem" select="$pItems[position() &lt;= $pN]"/>
    <fo:table-row keep-together="always">
        <xsl:for-each select="$firstNItem">
            <fo:table-cell text-align="left" display-align="before" padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                <fo:block hyphenate="true" language="{$lang}" font-size="{$pFontSize}pt">
                    <fo:instream-foreign-object>
                        <xsl:variable name="svgSize">
                            <xsl:choose>
                                <xsl:when test="$pStyle = '3D'">
                                    <xsl:value-of select="$pFontSize + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$pFontSize"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <svg:svg width="{$svgSize}" height="{$svgSize}">
                            <xsl:if test="$pStyle = '3D'">
                                <svg:rect x="1" y="1" width="{$svgSize}" height="{$svgSize}" fill="#000000" stroke="#000000"/>
                            </xsl:if>
                            <svg:rect x="0" y="0" width="{$pFontSize}" height="{$pFontSize}" fill="#FFFFFF" stroke="#000000"/>
                            <xsl:if test="contains($pSelection, current()/msg[@lang = $lang])">
                                <!--xsl:choose>
                                    <xsl:when test="$pMark = 'pipe'">
                                        <svg:line x1="2" y1="6" x2="6" y2="10" stroke="#0000FF"/>
                                        <svg:line x1="6" y1="10" x2="10" y2="2" stroke="#0000FF"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    </xsl:otherwise>
                                </xsl:choose-->
                                <svg:line x1="2" y1="2" x2="{$pFontSize - 2}" y2="{$pFontSize - 2}" stroke="#0000FF" stroke-width="2"/>
                                <svg:line x1="{$pFontSize - 2}" y1="2" x2="2" y2="{$pFontSize - 2}" stroke="#0000FF" stroke-width="2"/>
                            </xsl:if>
                        </svg:svg>
                    </fo:instream-foreign-object>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="current()/msg[@lang = $lang]"/>
                </fo:block>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>

    <xsl:variable name="remainingItems" select="$pItems[position() &gt; $pN]"/>
<!-- Recursive call for remaining items. -->
    <xsl:if test="count($remainingItems) != 0">
        <xsl:call-template name="addNCheckBox">
            <xsl:with-param name="pItems" select="$remainingItems"/>
            <xsl:with-param name="pSelection" select="$pSelection"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addValue
    Description:    Add the value of content item depending on the value type to FO.
    Parameters:
        pCurrent :  The current node of processing
        pUnit    :  Enumerated values: cv: Code Value, cm: Code Meaning of Measurement Units Code Sequence, none: don't add unit.
-->
<xsl:template name="addValue"> <xsl:param name="pCurrent"/>
                               <xsl:param name="pUnit" select="'cv'"/>
                               <xsl:param name="pPattern" select="$numberFormat"/>

    <xsl:choose>
        <xsl:when test="$pCurrent/ValueType_TEXT or $pCurrent/ValueType = 'TEXT'">
            <xsl:choose>
                <xsl:when test="contains($pCurrent/TextValue, $LF)">
                    <xsl:call-template name="break2NewLine">
                        <xsl:with-param name="pAlign">left</xsl:with-param>
                        <xsl:with-param name="pText" select="$pCurrent/TextValue"/>
                        <xsl:with-param name="pNewLineSeparator" select="$LF"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pCurrent/TextValue"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_CODE or $pCurrent/ValueType = 'CODE'">
            <xsl:value-of select="$pCurrent/ConceptCodeSequence/Item/CodeMeaning"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_NUM or $pCurrent/ValueType = 'NUM'">
            <xsl:call-template name="addNUMValue">
                <xsl:with-param name="pCurrent" select="$pCurrent"/>
                <xsl:with-param name="pPattern" select="$pPattern"/>
                <xsl:with-param name="pUnit" select="$pUnit"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_PNAME or $pCurrent/ValueType = 'PNAME'">
            <xsl:call-template name="formatPersonName">
                <xsl:with-param name="PName" select="$pCurrent/PersonName"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_DATE or $pCurrent/ValueType = 'DATE'">
            <xsl:variable name="date">
                <xsl:call-template name="toXSDdate">
                    <xsl:with-param name="pDate" select="$pCurrent/Date"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="formatDate">
                <xsl:with-param name="pDate" select="$date"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_TIME or $pCurrent/ValueType = 'TIME'">
            <xsl:call-template name="formatTime">
                <xsl:with-param name="pTime" select="$pCurrent/Time"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_DATETIME or $pCurrent/ValueType = 'DATETIME'">
            <xsl:call-template name="formatDateTime">
                <xsl:with-param name="pDTime" select="$pCurrent/DateTime"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_UIDREF or $pCurrent/ValueType = 'UIDREF'">
            <xsl:value-of select="$pCurrent/UID"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_COMPOSITE or $pCurrent/ValueType = 'COMPOSITE'">
            <xsl:value-of select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_IMAGE or $pCurrent/ValueType = 'IMAGE'">
            <xsl:call-template name="addImage">
                <xsl:with-param name="pSOPInstUID" select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID"/>
                <xsl:with-param name="pIconImageSeq" select="$pCurrent/ReferencedSOPSequence/Item/IconImageSequence"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_WAVEFORM or $pCurrent/ValueType = 'WAVEFORM'">
            <xsl:value-of select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID"/>
        </xsl:when>
    </xsl:choose>

</xsl:template>

<!-- ####################################################################################################
    Template:       addNUMValue
    Description:    Adds Code Meaning and "(CV, CSD, CM)" in tooltip.
    Parameters:
        pCurrent :  NUM content item
-->
<xsl:template name="addNUMValue">
    <xsl:param name="pCurrent"/>
    <xsl:param name="pPattern"/>
    <xsl:param name="pUnit"/>

    <xsl:call-template name="formatNumericValue">
        <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
        <xsl:with-param name="pPattern" select="$pPattern"/>
    </xsl:call-template>
    <xsl:choose>
        <xsl:when test="$pUnit = 'cv'">
            <xsl:if test="$pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue != '1'">
                <xsl:value-of select="concat(' ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue)"/>
            </xsl:if>
        </xsl:when>
        <xsl:when test="$pUnit = 'cm'">
            <xsl:value-of select="concat(' ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning)"/>
        </xsl:when>
    </xsl:choose>

</xsl:template>


<xsl:template name="addImage"> <xsl:param name="pSOPInstUID"/> <xsl:param name="pIconImageSeq"/>
    <fo:external-graphic>
        <xsl:choose>
            <xsl:when test="$pIconImageSeq">
                <xsl:attribute name="src">
                    <xsl:value-of select="concat('../IMAGE/', $pSOPInstUID, '_ico.jpg')"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="src">
                     <xsl:value-of select="concat('../IMAGE/', $pSOPInstUID, '.jpg')"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </fo:external-graphic>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPatientQuestions
    Description:    Adds Patient Questions.
    Parameters:
        pItem    :  (PQ-0110, 99GEMS, Patient Questions) content item
-->
<xsl:template name="addPatientQuestions"> <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <xsl:for-each select="$pItem/ContentSequence/Item">
                <xsl:variable name="answer" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PQ-0130' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="answerHasContent">
                    <xsl:call-template name="hasContent">
                        <xsl:with-param name="pItems" select="$answer"/>
                    </xsl:call-template>
                </xsl:variable>
                <fo:table-row>
                    <fo:table-cell border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                        <fo:block hyphenate="true" language="{$lang}">
                            <fo:inline font-weight="bold">
                                <xsl:choose>
                                    <xsl:when test="current()/ValueType_CODE or current()/ValueType = 'CODE'">
                    <!-- Display the (121051, DCM, Equivalent meaning of value) child. -->
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121051' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                    <!-- Keep for older questionnaires that were saved as TEXT items with code in the concept name e.g.: (PQ-1000, 99GEMS, LBL_REASON_FOR_EXAM) -->
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                        <xsl:variable name="cv">
                            <xsl:choose>
                                <xsl:when test="current()/ValueType_CODE or current()/ValueType = 'CODE'">
                                    <xsl:value-of select="current()/ConceptCodeSequence/Item/CodeValue"/>
                                </xsl:when>
                                <xsl:otherwise>
                <!-- Keep for older questionnaires that were saved as TEXT items with code in the concept name e.g.: (PQ-1000, 99GEMS, LBL_REASON_FOR_EXAM) -->
                                    <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeValue"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="csd">
                            <xsl:choose>
                                <xsl:when test="current()/ValueType_CODE or current()/ValueType = 'CODE'">
                                    <xsl:value-of select="current()/ConceptCodeSequence/Item/CodingSchemeDesignator"/>
                                </xsl:when>
                                <xsl:otherwise>
                <!-- Keep for older questionnaires that were saved as TEXT items with code in the concept name e.g.: (PQ-1000, 99GEMS, LBL_REASON_FOR_EXAM) -->
                                    <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                <!-- (PQ-1020, 99GEMS, Currently smoking cigarettes) -->
                <!-- (PQ-1100, 99GEMS, Has patient ever used smokeless tobacco products?) -->
                <!-- (PQ-1140, 99GEMS, Do/did patient's parents smoke?) -->
                <!-- (PQ-1150, 99GEMS, Does patient's spouse smoke?) -->
                <!-- (PQ-1230, 99GEMS, Has the patient ever been told that he/she had an abnormal chest x-ray?) -->
                <!-- (PQ-1250, 99GEMS, Has patient ever had a positive skin test for tuberculosis?) -->
                <!-- (PQ-1270, 99GEMS, Does the patient have a history of chronic or frequent bronchitis?) -->
                <!-- (PQ-1280, 99GEMS, Does the patient have a chronic smoker's cough?) -->
                <!-- (PQ-1290, 99GEMS, Has the patient had a fungal infection of the lungs?) -->
                <!-- (PQ-1300, 99GEMS, Has the patient ever been diagnosed with emphysema?) -->
                            <xsl:when test="$csd = $CSD_GEMS and ($cv = 'PQ-1020' or $cv = 'PQ-1100' or $cv = 'PQ-1140' or $cv = 'PQ-1150' or $cv = 'PQ-1230' or $cv = 'PQ-1250' or $cv = 'PQ-1270' or $cv = 'PQ-1280' or $cv = 'PQ-1290' or $cv = 'PQ-1300')">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_BOOL</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1050, 99GEMS, How many times has patient tried to quit smoking?) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1050'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_SMOKING_QUIT_TRIAL_NR</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'6'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1060, 99GEMS, How many pack(s) a day has the patient smoked?) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1060'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_PACKS_PER_DAY</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1090, 99GEMS, Select other tobacco products used) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1090'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_OTHER_TOBACCO_USED</xsl:with-param>
                                    <xsl:with-param name="pType" select="'checkbox'"/>
                                    <xsl:with-param name="pN" select="'4'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1110, 99GEMS, Has patient been exposed to significant second-hand smoke in his/her home?) -->
                <!-- (PQ-1120, 99GEMS, Has patient been exposed to significant second-hand smoke in his/her workplace?) -->
                <!-- (PQ-1130, 99GEMS, Has patient been exposed to significant second-hand smoke in social settings?) -->
                <!-- (PQ-1160, 99GEMS, Has patient ever worked with asbestos?) -->
                <!-- (PQ-1170, 99GEMS, Has patient ever worked in a shipyard or with pipe insulation?) -->
                <!-- (PQ-1180, 99GEMS, Has patient ever worked with heavy metals such as lead, arsenic, or mercury?) -->
                <!-- (PQ-1190, 99GEMS, Has patient ever worked in a mine?) -->
                <!-- (PQ-1200, 99GEMS, Has patient had significant exposure to radon gas?) -->
                            <xsl:when test="$csd = $CSD_GEMS and ($cv = 'PQ-1110' or $cv = 'PQ-1120' or $cv = 'PQ-1130' or $cv = 'PQ-1160' or $cv = 'PQ-1170' or $cv = 'PQ-1180' or $cv = 'PQ-1190' or $cv = 'PQ-1200')">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_SECOND_HAND_SMOKE</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'4'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1240, 99GEMS, If so, what was the diagnosis?) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1240'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_ABNORMAL_CHEST_X-RAY_DIAG</xsl:with-param>
                                    <xsl:with-param name="pType" select="'checkbox'"/>
                                    <xsl:with-param name="pN" select="'4'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1260, 99GEMS, Does patient have a history of asthma?) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1260'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_ASTHMA_HISTORY</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'4'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1320, 99GEMS, Conditions for which the patient has seen a health care provider or taken medication in the past five years) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1320'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_CONDITIONS</xsl:with-param>
                                    <xsl:with-param name="pType" select="'checkbox'"/>
                                    <xsl:with-param name="pN" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-1330, 99GEMS, Current living location) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1330'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_CURRENT_LIVING_LOCATION</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-2000, 99GEMS, Cancer diagnosis) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-2000'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_CANCER_DIAGNOSIS</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'3'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (G-F150, SRT, T category) -->
                            <xsl:when test="$csd = $CSD_SNOMED_RT and $cv = 'G-F150'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_T_CATEGORY</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'5'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (R-40030, SRT, N category) -->
                            <xsl:when test="$csd = $CSD_SNOMED_RT and $cv = 'R-40030'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_N_CATEGORY</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'5'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (R-40031, SRT, M category) -->
                            <xsl:when test="$csd = $CSD_SNOMED_RT and $cv = 'R-40031'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_M_CATEGORY</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'5'"/>
                                </xsl:call-template>
                            </xsl:when>
                <!-- (PQ-2020, 99GEMS, Stage grouping) -->
                            <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-2020'">
                                <xsl:call-template name="addAnswers">
                                    <xsl:with-param name="pAnswer" select="$answer"/>
                                    <xsl:with-param name="pGroup">LBL_STAGE_GROUPING</xsl:with-param>
                                    <xsl:with-param name="pType" select="'radio'"/>
                                    <xsl:with-param name="pN" select="'5'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:block hyphenate="true" language="{$lang}">
                                    <xsl:if test="$answer/TextValue = ''">
                                        <xsl:attribute name="space-before">12pt</xsl:attribute>
                                        <xsl:attribute name="space-after">12pt</xsl:attribute>
                                    </xsl:if>
                                    <xsl:if test="$answerHasContent = 'true'">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$answer"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </fo:block>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:table-cell>
                </fo:table-row>
            </xsl:for-each>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addAnswers
    Description:    Adds possible answers from group $pGroup defined in $messagecatalog.
    Parameters:
        pAnswer    :  (PQ-0130, 99GEMS, Answer) content item
-->
<xsl:template name="addAnswers"> <xsl:param name="pAnswer"/>
                                 <xsl:param name="pGroup"/>
                                 <xsl:param name="pType"/>
                                 <xsl:param name="pN" select="'2'"/>

    <xsl:variable name="items" select="$messagecatalog/*[name() = $pGroup]/item"/>
    <xsl:if test="$items">
        <xsl:choose>
            <xsl:when test="$pType = 'radio'">
                <xsl:call-template name="addRadioButtons">
                    <xsl:with-param name="pItems" select="$items"/>
                    <xsl:with-param name="pSelection" select="$pAnswer/TextValue"/>
                    <xsl:with-param name="pN" select="$pN"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pType = 'checkbox'">
                <xsl:call-template name="addCheckBoxes">
                    <xsl:with-param name="pItems" select="$items"/>
                    <xsl:with-param name="pSelection" select="$pAnswer/TextValue"/>
                    <xsl:with-param name="pN" select="$pN"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <fo:table table-layout="fixed" width="100%">
                    <xsl:call-template name="addProportionalTableColumn">
                        <xsl:with-param name="pN" select="$pN"/>
                    </xsl:call-template>
                    <fo:table-body>
                        <xsl:call-template name="addNAnswers">
                            <xsl:with-param name="pItems" select="$items"/>
                            <xsl:with-param name="pN" select="$pN"/>
                        </xsl:call-template>
                    </fo:table-body>
                </fo:table>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNAnswers
    Description:    Recursively adds answers organized into N columns.
    Parameters:
        pItems      : Possible answers.
        pN          : # of columns
-->
<xsl:template name="addNAnswers"> <xsl:param name="pItems"/> <xsl:param name="pN"/>

    <xsl:variable name="firstNItem" select="$pItems[position() &lt;= $pN]"/>
    <fo:table-row keep-together="always">
    <xsl:for-each select="$firstNItem">
        <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
            <fo:block hyphenate="true" language="{$lang}">
                <xsl:value-of select="current()/msg[@lang = $lang]"/>
            </fo:block>
        </fo:table-cell>
    </xsl:for-each>
    </fo:table-row>

    <xsl:variable name="remainingItems" select="$pItems[position() &gt; $pN]"/>
<!-- Recursive call for remaining items. -->
    <xsl:if test="count($remainingItems) != 0">
        <xsl:call-template name="addNAnswers">
            <xsl:with-param name="pItems" select="$remainingItems"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addItemWithGeneric
    Description:    Add content item to report with generic tree traversal.
    Parameters:
        pItem    :  Content item to add.
-->
<xsl:template name="addItemWithGeneric"> <xsl:param name="pItem"/>

<!-- Add value of different Value Types except CONTAINER. -->
    <xsl:if test="not($pItem/ValueType_CONTAINER) or ($pItem/ValueType and $pItem/ValueType != 'CONTAINER')">
        <xsl:call-template name="addItemContent">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
    </xsl:if>

<!-- Process nested ContentSequences. -->
    <xsl:if test="$pItem/ContentSequence">
        <xsl:call-template name="addRecursiveContent">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addRecursiveContent
    Description:    Add content with recursion.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->
<xsl:template name="addRecursiveContent"> <xsl:param name="pLevel"/>
                                          <xsl:param name="pCurrent"/>

    <xsl:variable name="reduceFactor">
        <xsl:value-of select="1 - $COL_REDUCE_FACTOR * $pLevel"/>
    </xsl:variable>
    <!-- reducedColWidth variable contains the column width based on COL_REDUCE_FACTOR and the level of recursion. -->
    <xsl:variable name="reducedOneThirdColWidth">
        <xsl:value-of select="$oneThirdColWidth * $reduceFactor"/>
    </xsl:variable>
    <xsl:variable name="reducedTwoThirdColWidth">
        <xsl:value-of select="$twoThirdColWidth * $reduceFactor"/>
    </xsl:variable>
    <fo:table table-layout="fixed" width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-column column-width="{concat($reducedOneThirdColWidth, $marginUnit)}"/>
    <fo:table-column>
        <xsl:attribute name="column-width"><xsl:value-of select="concat($reducedTwoThirdColWidth, $marginUnit)"/></xsl:attribute>
    </fo:table-column>
    <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>

            <xsl:for-each select="$pCurrent/ContentSequence/Item">
                <fo:table-row>
                    <fo:table-cell/>
                    <fo:table-cell display-align="before">
                        <fo:block hyphenate="true" language="{$lang}">
                            <!--xsl:if test="RelationshipType != 'CONTAINS'">
                                <fo:inline font-style="italic">
                                    <xsl:value-of select="RelationshipType"/>:
                                    <xsl:text> </xsl:text>
                                </fo:inline>
                            </xsl:if-->
                            <fo:inline font-weight="bold">
                                <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell display-align="before">
                        <fo:block>
                            <xsl:if test="current()/ValueType_TEXT or current()/ValueType = 'TEXT'">
                                <xsl:attribute name="hyphenate">true</xsl:attribute>
                                <xsl:attribute name="language"><xsl:value-of select="$lang"/></xsl:attribute>
                            </xsl:if>
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
                            <xsl:call-template name="addRecursiveContent">
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:table-cell>
                        <fo:table-cell/>
                        <fo:table-cell/>
                    </fo:table-row>
                </xsl:if>
            </xsl:for-each>

        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addItemContent
    Description:    Add content in table row.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->
<xsl:template name="addItemContent"> <xsl:param name="pLevel"/> <xsl:param name="pCurrent"/>

    <fo:table table-layout="fixed" width="{100 - ($pLevel * 3)}%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell>
                    <fo:block hyphenate="true" language="{$lang}">
                        <!--xsl:if test="RelationshipType != 'CONTAINS'">
                            <fo:inline font-style="italic">
                                <xsl:value-of select="RelationshipType"/>:
                                <xsl:text> </xsl:text>
                            </fo:inline>
                        </xsl:if-->
                        <fo:inline font-weight="bold">
                            <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/>
                        </fo:inline>
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block hyphenate="true" language="{$lang}">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addImages
    Description:    Adds image captures to a table with pN columns.
    Parameters:
        pImages   :  Image Capture node-set.
        pN        :  # of columns images displayed across.
-->
<xsl:template name="addImages"> <xsl:param name="pImages"/>
                                <xsl:param name="pN" select="$imgColumns"/>
                                <xsl:param name="pWithName" select="'true'"/>
                                <xsl:param name="pWithComment" select="'true'"/>

    <xsl:if test="$pImages">
        <fo:table table-layout="fixed" width="100%">
            <xsl:call-template name="addProportionalTableColumn">
                <xsl:with-param name="pN" select="$pN"/>
            </xsl:call-template>
            <fo:table-body>
                <xsl:call-template name="addNImages">
                    <xsl:with-param name="pImages" select="$pImages"/>
                    <xsl:with-param name="pN" select="$pN"/>
                    <xsl:with-param name="pWithName" select="$pWithName"/>
                    <xsl:with-param name="pWithComment" select="$pWithComment"/>
                </xsl:call-template>
            </fo:table-body>
        </fo:table>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNImages
    Description:    Recursively adds Image captures organized into N columns.
    Parameters:
        pImages   :  Image Capture node-set.
        pN        :  # of columns images displayed across.
-->
<xsl:template name="addNImages"> <xsl:param name="pImages"/>
                                 <xsl:param name="pN" select="$imgColumns"/>
                                 <xsl:param name="pWithName" select="'true'"/>
                                 <xsl:param name="pWithComment" select="'true'"/>

    <xsl:variable name="firstNImages" select="$pImages[position() &lt;= $pN]"/>
    <fo:table-row>
        <xsl:if test="$tp/FixedOutput/Orientation = 'Portrait'">
            <xsl:attribute name="keep-together">always</xsl:attribute>
        </xsl:if>
        <xsl:for-each select="$firstNImages">
            <fo:table-cell padding-bottom="1pt" padding-left="1pt">
                <xsl:call-template name="addImageCapture">
                    <xsl:with-param name="pImage" select="current()"/>
                    <xsl:with-param name="pWithName" select="$pWithName"/>
                    <xsl:with-param name="pWithComment" select="$pWithComment"/>
                </xsl:call-template>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>
    <xsl:variable name="remainingImages" select="$pImages[position() &gt; $pN]"/>
    <xsl:if test="count($remainingImages) != 0">
        <xsl:call-template name="addNImages">
            <xsl:with-param name="pImages" select="$remainingImages"/>
            <xsl:with-param name="pN" select="$pN"/>
            <xsl:with-param name="pWithName" select="$pWithName"/>
            <xsl:with-param name="pWithComment" select="$pWithComment"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addImageCapture
    Description:    Add one image optionally with name and comment.
    Parameters:
        pImage   :  Image item.
-->
<xsl:template name="addImageCapture">
    <xsl:param name="pImage"/>
    <xsl:param name="pWithName" select="'true'"/>
    <xsl:param name="pWithComment" select="'true'"/>

<!-- Image -->
    <fo:block text-align="center">
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$pImage"/>
        </xsl:call-template>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       dumpFOVariables
    Description:    Write FO page, margin unit etc. variables.
-->
<xsl:template name="dumpFOVariables">

<!-- Image -->
    <fo:block color="#FF0000" space-before="2pt" space-after="2pt" padding-top="2pt" padding-left="2pt" padding-bottom="2pt" padding-right="2pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
        <fo:block color="#FF0000">
            MarginUnit: <xsl:value-of select="$marginUnit"/>,
            PageUnit: <xsl:value-of select="$pageUnit"/>,
            MediaSize: <xsl:value-of select="$tp/FixedOutput/MediaSize"/>,
            Orientation: <xsl:value-of select="$tp/FixedOutput/Orientation"/>
        </fo:block>
        <fo:block color="#FF0000">
            A4 W x H: <xsl:value-of select="$a4Width"/> x <xsl:value-of select="$a4Height"/>,
            US W x H: <xsl:value-of select="$usWidth"/> x <xsl:value-of select="$usHeight"/>
        </fo:block>
        <fo:block color="#FF0000">
            Page W x H: <xsl:value-of select="$pageWidth"/> x <xsl:value-of select="$pageHeight"/>,
            Portrait W x H: <xsl:value-of select="$portraitWidth"/> x <xsl:value-of select="$portraitHeight"/>,
            Inner Page W x H: <xsl:value-of select="$innerPageWidth"/> x <xsl:value-of select="$innerPageHeight"/>,
            1/3 col W: <xsl:value-of select="$oneThirdColWidth"/>, 2/3 col W: <xsl:value-of select="$twoThirdColWidth"/>,
        </fo:block>
        <fo:block color="#FF0000">
            Margins Top: <xsl:value-of select="$topMargin"/>, Bottom: <xsl:value-of select="$bottomMargin"/>,
            Left: <xsl:value-of select="$leftMargin"/>, Right: <xsl:value-of select="$rightMargin"/>
        </fo:block>
    </fo:block>
</xsl:template>

</xsl:stylesheet>
