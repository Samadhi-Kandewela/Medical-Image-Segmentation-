<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2005 GE Healthcare

    FO_EXCL.XSL     :   Gore EXCLUDER specific XSLT rules for SR to XSL-FO transformation.

    Author          :   Attila RACZ
    Last modified on:   Aug 24, 2005
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg">

<xsl:include href="GEN_FO.XSL"/>

<xsl:output method="xml" indent="yes"/>

<xsl:variable name="PEN_COLOR">0000FF</xsl:variable>
<xsl:variable name="EXCLUDER_BLACK">000000</xsl:variable>
<xsl:variable name="EXCLUDER_GRAY">DCDCDC</xsl:variable>
<xsl:variable name="EXCLUDER_COPYRIGHT">262626</xsl:variable>

<xsl:template match="/">

    <fo:root font-family="Helvetica" font-size="10pt">

<!-- Page settings (media, height and width) -->
        <fo:layout-master-set>
            <fo:simple-page-master master-name="SimpleLandscape"
                                   page-width="{concat($portraitHeight, $pageUnit)}"
                                   page-height="{concat($portraitWidth, $pageUnit)}">
                <fo:region-before extent="{concat($tp/FixedOutput/Margin/Top, $marginUnit)}"/>
                <fo:region-body margin-top="{concat($topMargin, $marginUnit)}"
                                margin-bottom="{concat($bottomMargin, $marginUnit)}"
                                margin-left="{concat($leftMargin, $marginUnit)}"
                                margin-right="{concat($rightMargin, $marginUnit)}"/>
                <fo:region-after extent="{concat($tp/FixedOutput/Margin/Bottom, $marginUnit)}"/>
            </fo:simple-page-master>
            <fo:simple-page-master master-name="SimplePortrait"
                                   page-width="{concat($portraitWidth, $pageUnit)}"
                                   page-height="{concat($portraitHeight, $pageUnit)}">
                <fo:region-before extent="{concat($tp/FixedOutput/Margin/Top, $marginUnit)}"/>
                <fo:region-body margin-top="{concat($topMargin, $marginUnit)}"
                                margin-bottom="{concat($bottomMargin, $marginUnit)}"
                                margin-left="{concat($leftMargin, $marginUnit)}"
                                margin-right="{concat($rightMargin, $marginUnit)}"/>
                <fo:region-after extent="{concat($tp/FixedOutput/Margin/Bottom, $marginUnit)}"/>
            </fo:simple-page-master>
        </fo:layout-master-set>

<!-- Measurement Form in landscape format. -->
        <fo:page-sequence master-reference="SimpleLandscape">
            <fo:flow flow-name="xsl-region-body">
                <xsl:for-each select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS']">
                    <xsl:choose>
                        <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = 'A-25500' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                            <xsl:call-template name="addMeasurementForm">
                                <xsl:with-param name="pItem" select="current()"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </fo:flow>
        </fo:page-sequence>

<!-- Device Selection Form in portrait format. -->
        <fo:page-sequence master-reference="SimplePortrait">
            <fo:flow flow-name="xsl-region-body">
                <xsl:for-each select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS']">
                    <xsl:choose>
                        <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = 'A-25500' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                            <!--xsl:call-template name="addDeviceSelectionForm">
                                <xsl:with-param name="pItem" select="current()"/>
                            </xsl:call-template-->
                            <fo:block/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </fo:flow>
        </fo:page-sequence>

    </fo:root>

</xsl:template>

<!-- ####################################################################################################
    Template:       addMeasurementForm
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addMeasurementForm">
    <xsl:param name="pItem"/>

    <xsl:call-template name="addMHeader">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>

    <xsl:call-template name="addMQuestionsComments">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>

</xsl:template>

<!-- ####################################################################################################
    Template:       addMHeader
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addMHeader">
    <xsl:param name="pItem"/>

    <fo:block text-align="center" font-size="8pt" font-weight="bold">
        Gore / Patient Confidential Information
    </fo:block>

</xsl:template>

<!-- ####################################################################################################
    Template:       addMQuestionsComments
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addMQuestionsComments">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="2pt">
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-top="8pt" border-top-style="solid" border-top-width="8pt" border-top-color="#{$EXCLUDER_GRAY}" padding-left="8pt" border-left-style="solid" border-left-width="8pt" border-left-color="#{$EXCLUDER_GRAY}" padding-bottom="1pt" border-bottom-style="solid" border-bottom-width="8pt" border-bottom-color="#{$EXCLUDER_GRAY}" padding-right="8pt" border-right-style="solid" border-right-width="8pt" border-right-color="#{$EXCLUDER_GRAY}">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(26)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-top="3pt" padding-left="1pt" padding-bottom="3pt" padding-right="1pt">
                                    <fo:block font-size="8pt">
                                        1.
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="3pt" padding-left="1pt" padding-bottom="3pt" padding-right="1pt">
                                    <fo:block font-size="8pt">
                                        Are the proximal and distal implantation sites free of significant thrombus (&lt; 2 mm thickness
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        and/or &lt; 25% of circumference) and/or calcium?
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="3pt" padding-left="1pt" padding-bottom="3pt" padding-right="1pt">
                                    <xsl:call-template name="addCheckBoxes">
                                        <xsl:with-param name="pItems" select="$messagecatalog/*[name() = 'LBL_BOOL']/item"/>
                                        <!--xsl:with-param name="pSelection" select=""/-->
                                        <xsl:with-param name="pN" select="'2'"/>
                                        <xsl:with-param name="pStyle" select="'2D'"/>
                                        <xsl:with-param name="pFontSize" select="'8'"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="addMQuestionRow">
                                <xsl:with-param name="pNum" select="'2.'"/>
                                <xsl:with-param name="pQuestion" select="'Is the aortic neck free of any reverse taper (&gt; 2 mm growth within 15 mm of neck)?'"/>
                            </xsl:call-template>
                            <xsl:call-template name="addMQuestionRow">
                                <xsl:with-param name="pNum" select="'3.'"/>
                                <xsl:with-param name="pQuestion" select="'Is there adequate lumen diameter and retrograde access to contralateral limb?'"/>
                            </xsl:call-template>
                            <xsl:call-template name="addMQuestionRow">
                                <xsl:with-param name="pNum" select="'4.'"/>
                                <xsl:with-param name="pQuestion" select="'Will distal artery diameter/tortuosity/calcification allow for 18 Fr sheath access on the right side?'"/>
                            </xsl:call-template>
                            <xsl:call-template name="addMQuestionRow">
                                <xsl:with-param name="pNum" select="'5.'"/>
                                <xsl:with-param name="pQuestion" select="'Will distal artery diameter/tortuosity/calcification allow for 18 Fr sheath access on the left side?'"/>
                            </xsl:call-template>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell padding-top="8pt" border-top-style="solid" border-top-width="8pt" border-top-color="#{$EXCLUDER_GRAY}" padding-left="8pt" border-left-style="solid" border-left-width="8pt" border-left-color="#{$EXCLUDER_GRAY}" padding-bottom="5pt" border-bottom-style="solid" border-bottom-width="8pt" border-bottom-color="#{$EXCLUDER_GRAY}" padding-right="8pt" border-right-style="solid" border-right-width="8pt" border-right-color="#{$EXCLUDER_GRAY}">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" number-columns-spanned="2">
                                    <fo:block font-size="8pt" space-after="4pt">
                                        Case planning / procedural notes / comments:
                                    </fo:block>
                                    <fo:block space-after="3pt">
                                        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
                                    </fo:block>
                                    <fo:block space-after="3pt">
                                        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
                                    </fo:block>
                                    <fo:block space-after="3pt">
                                        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
                                    </fo:block>
                                    <fo:block space-after="3pt">
                                        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
                                    </fo:block>
                                    <fo:block space-after="3pt">
                                        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
                                    </fo:block>
                                    <fo:block space-after="3pt">
                                        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<xsl:template name="addMQuestionRow"> <xsl:param name="pNum"/> <xsl:param name="pQuestion"/>
    <fo:table-row>
        <fo:table-cell padding-top="3pt" padding-left="1pt" padding-bottom="3pt" padding-right="1pt">
            <fo:block font-size="8pt">
                <xsl:value-of select="$pNum"/>
            </fo:block>
        </fo:table-cell>
        <fo:table-cell padding-top="3pt" padding-left="1pt" padding-bottom="3pt" padding-right="1pt">
            <fo:block font-size="8pt">
                <xsl:value-of select="$pQuestion"/>
            </fo:block>
        </fo:table-cell>
        <fo:table-cell padding-top="3pt" padding-left="1pt" padding-bottom="3pt" padding-right="1pt">
            <xsl:call-template name="addCheckBoxes">
                <xsl:with-param name="pItems" select="$messagecatalog/*[name() = 'LBL_BOOL']/item"/>
                <!--xsl:with-param name="pSelection" select=""/-->
                <xsl:with-param name="pN" select="'2'"/>
                <xsl:with-param name="pStyle" select="'2D'"/>
                <xsl:with-param name="pFontSize" select="'8'"/>
            </xsl:call-template>
        </fo:table-cell>
    </fo:table-row>
</xsl:template>

<!-- ####################################################################################################
    Template:       addDeviceSelectionForm
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addDeviceSelectionForm">
    <xsl:param name="pItem"/>

    <xsl:call-template name="addDSHeader">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addILProsthesisSizingGuide">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addCLProsthesisSizingGuide">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addIpsilateralLegComponent">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addContralateralLegComponent">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addExtenderQuestion">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addExtender">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addIntroducerSheath">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <xsl:call-template name="addComments">
        <xsl:with-param name="pItem" select="$pItem"/>
    </xsl:call-template>
    <fo:block text-align="center" color="#{$EXCLUDER_COPYRIGHT}" font-size="6pt" white-space-collapse="false">
        GORE, EXCLUDER<fo:inline vertical-align="super" font-size="75%">®</fo:inline>, and designs are trademarks of W. L. Gore &amp; Associates.     © 2003, 2004 W. L. Gore &amp; Associates, Inc.     AF4756-EN7
    </fo:block>

</xsl:template>

<!-- ####################################################################################################
    Template:       addDSHeader
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addDSHeader">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="2pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell display-align="before" padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                    <fo:block text-align="center">
                        <fo:external-graphic src="{concat('../IMAGE/', 'EXCLUDERAAA.gif')}"/>
                    </fo:block>
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(3)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                                </fo:table-cell>
                                <fo:table-cell padding-top="12pt" padding-left="1pt" padding-bottom="12pt" padding-right="1pt">
                                    <fo:block font-weight="bold">
                                        DEVICE SELECTION FORM
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                                    <fo:instream-foreign-object>
                                        <svg:svg width="36" height="10">
                                            <svg:polygon points="0,0 0,10 36,5" fill="#000000"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="4pt" padding-right="1pt">
                                    <fo:block font-size="8pt">
                                        Intended Trunk-Ipsilateral Leg
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        Prosthesis Introduction Site:
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                                    <xsl:call-template name="addCheckBoxes">
                                        <xsl:with-param name="pItems" select="$messagecatalog/*[name() = 'LBL_LEFT_RIGHT']/item"/>
                                        <!--xsl:with-param name="pSelection" select=""/-->
                                        <xsl:with-param name="pN" select="'2'"/>
                                        <xsl:with-param name="pStyle" select="'2D'"/>
                                        <xsl:with-param name="pFontSize" select="'8'"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" number-columns-spanned="2">
                                    <fo:block font-size="8pt" font-weight="bold">
                                        Gore / Patient Confidential Information
                                    </fo:block>
                                    <fo:block font-size="7pt">
                                        The following information is required to ensure that the appropriate devices and backups are available for the procedure.
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="4pt">
                                    <fo:table table-layout="fixed" width="100%">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <xsl:call-template name="addHeaderRow">
                                                <xsl:with-param name="pValue" select="$DICOM/PatientID"/>
                                                <xsl:with-param name="pField" select="'Patient ID'"/>
                                            </xsl:call-template>
                                            <xsl:variable name="referringPhysician">
                                                <xsl:call-template name="formatPersonName">
                                                    <xsl:with-param name="PName" select="$DICOM/ReferringPhysiciansName"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:call-template name="addHeaderRow">
                                                <xsl:with-param name="pValue" select="$referringPhysician"/>
                                                <xsl:with-param name="pField" select="'Physician'"/>
                                            </xsl:call-template>
                                            <xsl:call-template name="addHeaderRow">
                                                <xsl:with-param name="pValue" select="$DICOM/InstitutionName"/>
                                                <xsl:with-param name="pField" select="'Institution'"/>
                                            </xsl:call-template>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt">
                                    <fo:table table-layout="fixed" width="100%">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <xsl:call-template name="addHeaderRow">
                                                <xsl:with-param name="pField" select="'MMS ID'"/>
                                            </xsl:call-template>
                                            <xsl:call-template name="addHeaderRow">
                                                <xsl:with-param name="pField" select="'Customer Order Number'"/>
                                            </xsl:call-template>
                                            <xsl:call-template name="addHeaderRow">
                                                <xsl:with-param name="pField" select="'P.O. Number'"/>
                                            </xsl:call-template>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(3)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="4pt">
                                    <fo:table table-layout="fixed" width="100%">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <xsl:call-template name="addHeaderRow">
                                                <xsl:with-param name="pField" select="'Anticipated Procedural Date'"/>
                                            </xsl:call-template>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt">
                                    <fo:instream-foreign-object>
                                        <svg:svg width="236" height="24">
                                            <svg:ellipse cx="118" cy="12" rx="118" ry="12" fill="#{$EXCLUDER_GRAY}"/>
                                            <svg:text x="108" y="5" font-size="6" font-weight="bold">NOTE:</svg:text>
                                            <svg:g font-size="5" font-weight="bold">
                                                <svg:text x="19" y="10">Recommended prosthesis oversizing relative to the aorta is approximately 10 - 21 %</svg:text>
                                                <svg:text x="16" y="16">Recommended prosthesis oversizing relative to the iliac artery is approximately 7 - 25%</svg:text>
                                                <svg:text x="94" y="22">All sizes are nominal</svg:text>
                                            </svg:g>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addHeaderRow
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addHeaderRow"> <xsl:param name="pValue" select="''"/> <xsl:param name="pField"/>
    <fo:table-row>
        <fo:table-cell padding-top="1pt" border-top-style="solid" border-top-width="thin" padding-left="1pt" border-left-style="solid" border-left-width="thin" padding-bottom="1pt" border-bottom-style="solid" border-bottom-width="thin" padding-right="4pt" border-right-style="solid" border-right-width="thin">
            <fo:block color="#{$PEN_COLOR}" white-space-collapse="false">
                <xsl:choose>
                    <xsl:when test="$pValue = ''">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$pValue"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:block>
        </fo:table-cell>
    </fo:table-row>
    <fo:table-row>
        <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="4pt">
            <fo:block font-size="8pt">
                <xsl:value-of select="$pField"/>
            </fo:block>
        </fo:table-cell>
    </fo:table-row>
</xsl:template>

<!-- ####################################################################################################
    Template:       addILProsthesisSizingGuide
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addILProsthesisSizingGuide">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="6pt">
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_BLACK}">
                <fo:table-cell padding-top="4pt" padding-left="4pt" padding-bottom="2pt" padding-right="4pt" number-columns-spanned="3">
                    <fo:block text-align="center" font-weight="bold" color="#FFFFFF">
                        Trunk-Ipsilateral Leg Prosthesis Sizing Guide:
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell padding-right="8pt">
                    <xsl:call-template name="addAorticDiameters">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
                <fo:table-cell padding-left="8pt" padding-right="8pt">
                    <xsl:call-template name="addIliacDiameters">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
                <fo:table-cell padding-left="8pt">
                    <xsl:call-template name="addILLengths">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addAorticDiameters
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addAorticDiameters">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Intended Aortic Vessel
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Diameter (mm)
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Prosthesis Diameter
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Aortic End (mm)
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'19 - 21'"/>
                <xsl:with-param name="pVal2" select="'23'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'22 - 23'"/>
                <xsl:with-param name="pVal2" select="'26'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'24 - 26'"/>
                <xsl:with-param name="pVal2" select="'28.5'"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addIliacDiameters
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addIliacDiameters">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Intended Iliac Vessel
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Diameter (mm)
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Prosthesis Diameter
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Iliac End (mm)
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'10 - 11'"/>
                <xsl:with-param name="pVal2" select="'12'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'12 - 13.5'"/>
                <xsl:with-param name="pVal2" select="'14.5'"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addILLengths
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addILLengths">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Prosthesis
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Lengths (cm)
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="8pt">
                        14 / 16 / 18
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="8pt">
                        14 / 16 / 18
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCLProsthesisSizingGuide
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addCLProsthesisSizingGuide">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="6pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_BLACK}">
                <fo:table-cell padding-top="4pt" padding-left="4pt" padding-bottom="2pt" padding-right="4pt" number-columns-spanned="2">
                    <fo:block text-align="center" font-weight="bold" color="#FFFFFF">
                        Contralateral Leg Prosthesis Sizing Guide:
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell padding-right="8pt">
                    <xsl:call-template name="addCLDiameters">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
                <fo:table-cell padding-left="8pt">
                    <xsl:call-template name="addCLLengths">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCLDiameters
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addCLDiameters">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Intended Iliac Vessel
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Diameter (mm)
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Prosthesis Diameter
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Iliac End (mm)
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'10 - 11'"/>
                <xsl:with-param name="pVal2" select="'12'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'12 - 13.5'"/>
                <xsl:with-param name="pVal2" select="'14.5'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'13.5 - 14.5'"/>
                <xsl:with-param name="pVal2" select="'16'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'14.5 - 16.5'"/>
                <xsl:with-param name="pVal2" select="'18'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'16.5 - 18.5'"/>
                <xsl:with-param name="pVal2" select="'20'"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCLLengths
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addCLLengths">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="6pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Contralateral Leg
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Lengths (cm)*
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Total Length When
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Inserted in Trunk (cm)*
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'10'"/>
                <xsl:with-param name="pVal2" select="'14'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'12'"/>
                <xsl:with-param name="pVal2" select="'16'"/>
            </xsl:call-template>
            <xsl:call-template name="addSizingGuideRow">
                <xsl:with-param name="pVal1" select="'14'"/>
                <xsl:with-param name="pVal2" select="'18'"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
    <fo:block text-align="center" font-size="6pt">
        *For 16, 18 and 20 mm contralateral legs,
    </fo:block>
    <fo:block text-align="center" font-size="6pt">
        actual length is 5 mm less than listed.
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addSizingGuideRow
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addSizingGuideRow"> <xsl:param name="pVal1"/> <xsl:param name="pVal2"/>
    <fo:table-row>
        <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
            <fo:block text-align="center" font-size="8pt">
                <xsl:value-of select="$pVal1"/>
            </fo:block>
        </fo:table-cell>
        <fo:table-cell padding-top="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid">
            <fo:block text-align="center" font-size="8pt">
                <xsl:value-of select="$pVal2"/>
            </fo:block>
        </fo:table-cell>
    </fo:table-row>
</xsl:template>

<!-- ####################################################################################################
    Template:       addIpsilateralLegComponent
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addIpsilateralLegComponent">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="6pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_BLACK}">
                <fo:table-cell padding-top="4pt" padding-left="4pt" padding-bottom="2pt" padding-right="4pt" number-columns-spanned="9">
                    <fo:block font-weight="bold" color="#FFFFFF">
                        Intended Trunk-Ipsilateral Leg Component:
                        <fo:inline font-size="6pt">[aortic end diameter (mm) x iliac end diameter (mm) x length (cm)]</fo:inline>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addLegComponentHeader"/>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'23 x 12 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXT231214'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'26 x 12 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXT261214'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'28.5 x 12 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXT281214'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'23 x 12 x 16'"/>
                    <xsl:with-param name="pCatNum" select="'PXT231216'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'26 x 12 x 16'"/>
                    <xsl:with-param name="pCatNum" select="'PXT261216'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'28.5 x 12 x 16'"/>
                    <xsl:with-param name="pCatNum" select="'PXT281216'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'23 x 12 x 18'"/>
                    <xsl:with-param name="pCatNum" select="'PXT231218'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'26 x 12 x 18'"/>
                    <xsl:with-param name="pCatNum" select="'PXT261218'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'28.5 x 12 x 18'"/>
                    <xsl:with-param name="pCatNum" select="'PXT281218'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'23 x 14.5 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXT231414'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'26 x 14.5 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXT261414'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'28.5 x 14.5 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXT281414'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'23 x 14.5 x 16'"/>
                    <xsl:with-param name="pCatNum" select="'PXT231416'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'26 x 14.5 x 16'"/>
                    <xsl:with-param name="pCatNum" select="'PXT261416'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'28.5 x 14.5 x 16'"/>
                    <xsl:with-param name="pCatNum" select="'PXT281416'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'23 x 14.5 x 18'"/>
                    <xsl:with-param name="pCatNum" select="'PXT231418'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'26 x 14.5 x 18'"/>
                    <xsl:with-param name="pCatNum" select="'PXT261418'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'28.5 x 14.5 x 18'"/>
                    <xsl:with-param name="pCatNum" select="'PXT281418'"/>
                </xsl:call-template>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addContralateralLegComponent
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addContralateralLegComponent">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="6pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_BLACK}">
                <fo:table-cell padding-top="4pt" padding-left="4pt" padding-bottom="2pt" padding-right="4pt" number-columns-spanned="9">
                    <fo:block font-weight="bold" color="#FFFFFF">
                        Intended Contralateral Leg Component:
                        <fo:inline font-size="6pt">[iliac end diameter (mm) x length (cm)]</fo:inline>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addLegComponentHeader"/>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'12 x 10'"/>
                    <xsl:with-param name="pCatNum" select="'PXC121000'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'14.5 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXC141400'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'18 x 11.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC181200'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'12 x 12'"/>
                    <xsl:with-param name="pCatNum" select="'PXC121200'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'16 x 9.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC161000'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'18 x 13.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC181400'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'12 x 14'"/>
                    <xsl:with-param name="pCatNum" select="'PXC121400'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'16 x 11.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC161200'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'20 x 9.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC201000'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'14.5 x 10'"/>
                    <xsl:with-param name="pCatNum" select="'PXC141000'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'16 x 13.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC161400'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'20 x 11.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC201200'"/>
                </xsl:call-template>
            </fo:table-row>
            <fo:table-row>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'14.5 x 12'"/>
                    <xsl:with-param name="pCatNum" select="'PXC141200'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'18 x 9.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC181000'"/>
                </xsl:call-template>
                <xsl:call-template name="addLegComponent">
                    <xsl:with-param name="pQty" select="''"/>
                    <xsl:with-param name="pDevSize" select="'20 x 13.5'"/>
                    <xsl:with-param name="pCatNum" select="'PXC201400'"/>
                </xsl:call-template>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addLegComponentHeader
    Description:
-->
<xsl:template name="addLegComponentHeader">
    <fo:table-row background-color="#{$EXCLUDER_GRAY}">
        <xsl:call-template name="addLegComponentBlockHeader"/>
        <xsl:call-template name="addLegComponentBlockHeader"/>
        <xsl:call-template name="addLegComponentBlockHeader"/>
    </fo:table-row>
</xsl:template>

<!-- ####################################################################################################
    Template:       addLegComponentBlockHeader
    Description:
-->
<xsl:template name="addLegComponentBlockHeader">
    <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
        <fo:block text-align="center" font-size="7pt" font-weight="bold">
            Qty.
        </fo:block>
    </fo:table-cell>
    <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
        <fo:block font-size="7pt" font-weight="bold">
            Device Size
        </fo:block>
    </fo:table-cell>
    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-right="1pt">
        <fo:block font-size="7pt" font-weight="bold">
            Catalogue Number
        </fo:block>
    </fo:table-cell>
</xsl:template>

<!-- ####################################################################################################
    Template:       addLegComponent
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addLegComponent"> <xsl:param name="pQty"/> <xsl:param name="pDevSize"/> <xsl:param name="pCatNum"/>
    <fo:table-cell text-align="center" padding-top="2pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
        <xsl:call-template name="addQuantity">
            <xsl:with-param name="pQty" select="$pQty"/>
        </xsl:call-template>
    </fo:table-cell>
    <fo:table-cell display-align="center" padding-top="1pt" padding-left="8pt" padding-right="1pt">
        <fo:block font-size="8pt">
            <xsl:value-of select="$pDevSize"/>
        </fo:block>
    </fo:table-cell>
    <fo:table-cell display-align="center" padding-top="1pt" padding-left="8pt" padding-right="1pt">
        <fo:block font-size="8pt">
            <xsl:value-of select="$pCatNum"/>
        </fo:block>
    </fo:table-cell>
</xsl:template>

<!-- ####################################################################################################
    Template:       addExtenderQuestion
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addExtenderQuestion">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="6pt">
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(5)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(10)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell>
                    <fo:instream-foreign-object text-align="center">
                        <svg:svg width="36" height="10">
                            <svg:polygon points="0,0 0,10 36,5" fill="#000000"/>
                        </svg:svg>
                    </fo:instream-foreign-object>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block font-size="8pt">
                        Do you intend to use an extender?
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <xsl:call-template name="addCheckBoxes">
                        <xsl:with-param name="pItems" select="$messagecatalog/*[name() = 'LBL_BOOL']/item"/>
                        <!--xsl:with-param name="pSelection" select=""/-->
                        <xsl:with-param name="pN" select="'2'"/>
                        <xsl:with-param name="pStyle" select="'2D'"/>
                        <xsl:with-param name="pFontSize" select="'8'"/>
                    </xsl:call-template>
                </fo:table-cell>
                <fo:table-cell>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>

</xsl:template>

<!-- ####################################################################################################
    Template:       addExtender
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addExtender">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="6pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-right="8pt">
                    <xsl:call-template name="addAorticExtender">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
                <fo:table-cell padding-left="8pt">
                    <xsl:call-template name="addIliacExtender">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addAorticExtender
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addAorticExtender">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_BLACK}">
                <fo:table-cell padding-top="4pt" padding-left="4pt" padding-bottom="2pt" padding-right="4pt" number-columns-spanned="4">
                    <fo:block font-weight="bold" color="#FFFFFF">
                        Intended or Back-up Aortic Extender
                    </fo:block>
                    <fo:block font-size="6pt" font-weight="bold" color="#FFFFFF">
                        (extension length range: 0 - 1.6 cm, total extender length: 3.3 cm)
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Qty.
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Intended Aortic
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Vessel Diameter (mm)
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Prosthesis
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Diameter (mm)
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Catalogue Number
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addExtenderComponent">
                <xsl:with-param name="pQty" select="''"/>
                <xsl:with-param name="pVesselDiam" select="'19 - 21'"/>
                <xsl:with-param name="pProstDiam" select="'23'"/>
                <xsl:with-param name="pCatNum" select="'PXA230300'"/>
            </xsl:call-template>
            <xsl:call-template name="addExtenderComponent">
                <xsl:with-param name="pQty" select="''"/>
                <xsl:with-param name="pVesselDiam" select="'22 - 23'"/>
                <xsl:with-param name="pProstDiam" select="'26'"/>
                <xsl:with-param name="pCatNum" select="'PXA260300'"/>
            </xsl:call-template>
            <xsl:call-template name="addExtenderComponent">
                <xsl:with-param name="pQty" select="''"/>
                <xsl:with-param name="pVesselDiam" select="'24 - 26'"/>
                <xsl:with-param name="pProstDiam" select="'28.5'"/>
                <xsl:with-param name="pCatNum" select="'PXA280300'"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addIliacExtender
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addIliacExtender">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="2pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(4)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_BLACK}">
                <fo:table-cell padding-top="4pt" padding-left="4pt" padding-bottom="2pt" padding-right="4pt" number-columns-spanned="4">
                    <fo:block font-weight="bold" color="#FFFFFF">
                        Intended or Back-up Iliac Extender*
                    </fo:block>
                    <fo:block font-size="6pt" font-weight="bold" color="#FFFFFF">
                        (extension length range: 0 - 4 cm, total extender length: 7 cm)
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Qty.
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Intended Iliac
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Vessel Diameter (mm)
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Prosthesis
                    </fo:block>
                    <fo:block text-align="center" font-size="7pt" font-weight="bold">
                        Diameter (mm)
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Catalogue Number
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:call-template name="addExtenderComponent">
                <xsl:with-param name="pQty" select="''"/>
                <xsl:with-param name="pVesselDiam" select="'8 - 9'"/>
                <xsl:with-param name="pProstDiam" select="'10'"/>
                <xsl:with-param name="pCatNum" select="'PXL161007'"/>
            </xsl:call-template>
            <xsl:call-template name="addExtenderComponent">
                <xsl:with-param name="pQty" select="''"/>
                <xsl:with-param name="pVesselDiam" select="'10 - 11'"/>
                <xsl:with-param name="pProstDiam" select="'12'"/>
                <xsl:with-param name="pCatNum" select="'PXL161207'"/>
            </xsl:call-template>
            <xsl:call-template name="addExtenderComponent">
                <xsl:with-param name="pQty" select="''"/>
                <xsl:with-param name="pVesselDiam" select="'12 - 13.5'"/>
                <xsl:with-param name="pProstDiam" select="'14.5'"/>
                <xsl:with-param name="pCatNum" select="'PXL161407'"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
    <fo:block font-size="6pt" font-weight="bold">
        *PLEASE NOTE: All large diameter contralateral leg endoprostheses
    </fo:block>
    <fo:block font-size="6pt" font-weight="bold">
        (16, 18 and 20 mm) can be used as iliac extenders.
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addExtenderComponent
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addExtenderComponent"> <xsl:param name="pQty"/> <xsl:param name="pVesselDiam"/>
                                           <xsl:param name="pProstDiam"/> <xsl:param name="pCatNum"/>
    <fo:table-row>
        <fo:table-cell text-align="center" padding-top="2pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
            <xsl:call-template name="addQuantity">
                <xsl:with-param name="pQty" select="$pQty"/>
            </xsl:call-template>
        </fo:table-cell>
        <fo:table-cell display-align="center" padding-top="1pt" padding-left="24pt" padding-right="1pt">
            <fo:block font-size="8pt">
                <xsl:value-of select="$pVesselDiam"/>
            </fo:block>
        </fo:table-cell>
        <fo:table-cell display-align="center" padding-top="1pt" padding-left="24pt" padding-right="1pt">
            <fo:block font-size="8pt">
                <xsl:value-of select="$pProstDiam"/>
            </fo:block>
        </fo:table-cell>
        <fo:table-cell display-align="center" padding-top="1pt" padding-left="8pt" padding-right="1pt">
            <fo:block font-size="8pt">
                <xsl:value-of select="$pCatNum"/>
            </fo:block>
        </fo:table-cell>
    </fo:table-row>
</xsl:template>

<!-- ####################################################################################################
    Template:       addIntroducerSheath
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addIntroducerSheath">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%" space-after="12pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(5)"/>
        <fo:table-column column-width="proportional-column-width(6)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(5)"/>
        <fo:table-column column-width="proportional-column-width(6)"/>
        <fo:table-body>
            <fo:table-row background-color="#{$EXCLUDER_BLACK}">
                <fo:table-cell padding-top="4pt" padding-left="4pt" padding-bottom="2pt" padding-right="4pt" number-columns-spanned="6">
                    <fo:block font-weight="bold" color="#FFFFFF">
                        GORE Introducer Sheath
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row background-color="#{$EXCLUDER_GRAY}">
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Qty.
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Description
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Catalogue Number
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Qty.
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Description
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="7pt" font-weight="bold">
                        Catalogue Number
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell text-align="center" padding-top="2pt" padding-left="1pt" padding-right="1pt">
                    <xsl:call-template name="addQuantity">
                        <xsl:with-param name="pQty" select="''"/>
                    </xsl:call-template>
                </fo:table-cell>
                <fo:table-cell text-align="center" display-align="center" padding-top="2pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="8pt">
                        12 Fr x 30 cm
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell display-align="center" padding-top="2pt" padding-left="8pt" padding-right="1pt">
                    <fo:block font-size="8pt">
                        PG123000
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" padding-top="2pt" padding-left="1pt" padding-right="1pt">
                    <xsl:call-template name="addQuantity">
                        <xsl:with-param name="pQty" select="''"/>
                    </xsl:call-template>
                </fo:table-cell>
                <fo:table-cell text-align="center" display-align="center" padding-top="2pt" padding-left="1pt" padding-right="1pt">
                    <fo:block font-size="8pt">
                        18 Fr x 30 cm
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell display-align="center" padding-top="2pt" padding-left="8pt" padding-right="1pt">
                    <fo:block font-size="8pt">
                        PG183000
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addComments
    Description:
    Parameters:
        pItem    :  (, , ) content item
-->
<xsl:template name="addComments">
    <xsl:param name="pItem"/>

    <fo:block font-size="7pt" space-after="4pt">
        Case planning / procedural notes / comments:
    </fo:block>
    <fo:block space-after="3pt">
        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
    </fo:block>
    <fo:block space-after="3pt">
        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
    </fo:block>
    <fo:block space-after="3pt">
        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addQuantity
    Description:
    Parameters:
        pQuantity:  Quantity to display
-->
<xsl:template name="addQuantity"> <xsl:param name="pQty"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" border-top-style="solid" padding-left="1pt" border-left-style="solid" border-bottom-style="solid" padding-right="1pt" border-right-style="solid">
                    <fo:block font-size="8pt" font-weight="bold" color="#{$PEN_COLOR}" white-space-collapse="false">
                        <xsl:choose>
                            <xsl:when test="$pQty = ''">
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$pQty"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

</xsl:stylesheet>
