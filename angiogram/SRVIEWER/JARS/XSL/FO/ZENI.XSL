<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2005 GE Healthcare

    FO_ZENI.XSL     :   ZENITH specific XSLT rules for SR to XSL-FO transformation.

    Author          :   Attila RACZ
    Last modified on:   Jun 27, 2005
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg">

<xsl:include href="GEN_FO.XSL"/>

<xsl:output method="xml" indent="yes"/>

<xsl:variable name="PEN_COLOR">0000FF</xsl:variable>
<xsl:variable name="ZENITH_BLUE">004F8D</xsl:variable>
<xsl:variable name="ZENITH_COLOR_D1">00477F</xsl:variable>
<xsl:variable name="ZENITH_COLOR_D2">4E79A9</xsl:variable>
<xsl:variable name="ZENITH_COLOR_D3">7F9AC1</xsl:variable>
<xsl:variable name="ZENITH_COLOR_L1">007561</xsl:variable>
<xsl:variable name="ZENITH_COLOR_L2">159284</xsl:variable>
<xsl:variable name="ZENITH_COLOR_L3">7CB7AF</xsl:variable>
<xsl:variable name="ZENITH_COLOR_D1_GRAFT_DIAM">F9633B</xsl:variable>
<xsl:variable name="ZENITH_COLOR_D2_GRAFT_DIAM">FD9067</xsl:variable>
<xsl:variable name="ZENITH_COLOR_D3_GRAFT_DIAM">FFAC89</xsl:variable>
<xsl:variable name="ZENITH_COLOR_CL_LENGTH">EABF23</xsl:variable>
<xsl:variable name="ZENITH_COLOR_IL_LENGTH">F4DC8E</xsl:variable>

<xsl:template match="/">

    <fo:root font-family="Helvetica" font-size="10pt">

<!-- Page settings (media, height and width) -->
        <xsl:call-template name="addLayoutMasterSet"/>

        <fo:page-sequence master-reference="SimpleMaster">
            <fo:flow flow-name="xsl-region-body">
                <xsl:for-each select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS']">
                    <xsl:choose>
                        <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = 'A-25500' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                            <xsl:call-template name="addAAA">
                                <xsl:with-param name="pItem" select="current()"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </fo:flow>
        </fo:page-sequence>

    </fo:root>

</xsl:template>

<!-- ####################################################################################################
    Template:       addPlaque
    Description:    Adds Plaque content item.
    Parameters:
        pItem    :  (, , ) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addAAA">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell text-align="center" padding-top="1pt" padding-left="24pt" padding-bottom="1pt" padding-right="24pt">
                    <fo:block>
                        <fo:external-graphic src="{concat('../IMAGE/', 'zenith.jpg')}"/>
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt">
                    <fo:block space-after="4pt">
                        <fo:inline font-weight="bold" text-decoration="underline">ALL</fo:inline>
                        <xsl:text> </xsl:text>
                        <fo:inline font-weight="bold">information must be complete:</fo:inline>
                    </fo:block>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-left="1pt" padding-right="1pt">
                                    <fo:block>
                                        Date:
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-left="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-width="thin">
                                    <fo:block color="#{$PEN_COLOR}">
                                        <xsl:value-of select="$DICOM/ContentDate"/>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="right" padding-left="1pt" padding-right="1pt">
                                    <fo:block>
                                        Patient ID:
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-left="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-width="thin">
                                    <fo:block color="#{$PEN_COLOR}">
                                        <xsl:value-of select="$DICOM/PatientID"/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-left="1pt" padding-right="1pt">
                                    <fo:block>
                                        Hospital:
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-left="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-width="thin">
                                    <fo:block color="#{$PEN_COLOR}">
                                        <xsl:value-of select="$DICOM/InstitutionName"/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-left="1pt" padding-right="1pt">
                                    <fo:block>
                                        Physician Name:
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-left="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-width="thin">
                                    <fo:block color="#{$PEN_COLOR}">
                                        <xsl:call-template name="formatPersonName">
                                            <xsl:with-param name="PName" select="$DICOM/ReferringPhysiciansName"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(3)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-left="1pt" padding-right="1pt">
                                    <fo:block>
                                        Physician Signature:
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-left="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-width="thin">
                                    <fo:block color="#{$PEN_COLOR}">
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-left="1pt" padding-right="1pt">
                                    <fo:block>
                                        Physician Phone #:
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-left="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-width="thin">
                                    <fo:block color="#{$PEN_COLOR}">
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:table table-layout="fixed" width="100%" space-after="2pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell padding-left="1pt" padding-right="1pt">
                                    <fo:block>
                                        Physician email:
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-left="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-width="thin">
                                    <fo:block color="#{$PEN_COLOR}">
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>

    <fo:table table-layout="fixed" width="100%" border-top-style="solid" border-top-color="#{$ZENITH_BLUE}" border-top-width="thick">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell text-align="left" border-right-style="solid" border-right-color="#{$ZENITH_BLUE}">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell text-align="left" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-color="#{$ZENITH_BLUE}">
                                    <xsl:call-template name="addZenithAAAStep1">
                                        <xsl:with-param name="pItem" select="$pItem"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell text-align="left" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-color="#{$ZENITH_BLUE}">
                                    <xsl:call-template name="addZenithAAAStep2">
                                        <xsl:with-param name="pItem" select="$pItem"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell text-align="left" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt">
                                    <xsl:call-template name="addZenithAAAStep3">
                                        <xsl:with-param name="pItem" select="$pItem"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell text-align="left" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt" border-bottom-style="solid" border-bottom-color="#{$ZENITH_BLUE}">
                                    <xsl:call-template name="addZenithAAAStep4">
                                        <xsl:with-param name="pItem" select="$pItem"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell text-align="left" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt">
                                    <xsl:call-template name="addZenithAAAStep5">
                                        <xsl:with-param name="pItem" select="$pItem"/>
                                    </xsl:call-template>
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
    Template:       addZenithAAAStep1
-->
<xsl:template name="addZenithAAAStep1">
    <xsl:param name="pItem"/>

    <fo:block space-before="2pt" space-after="2pt" font-weight="bold" font-size="14pt">
        STEP 1
    </fo:block>
    <fo:block space-after="2pt" font-weight="bold" font-size="12pt">
        Select Side of Main Body Introduction and Fixation Sites
    </fo:block>
    <xsl:call-template name="addCheckBoxes">
        <xsl:with-param name="pItems" select="$messagecatalog/*[name() = 'LBL_ILIAC']/item"/>
        <!--xsl:with-param name="pSelection" select=""/-->
        <xsl:with-param name="pN" select="'2'"/>
        <xsl:with-param name="pStyle" select="'3D'"/>
    </xsl:call-template>
    <fo:block space-before="4pt" space-after="2pt">
        External Iliac (El) measurement _______mm
    </fo:block>
    <fo:block font-size="6pt" space-after="2pt">
        (Minimum diameter, inner wall to inner wall, from introduction site to aorta.)
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addZenithAAAStep2
-->
<xsl:template name="addZenithAAAStep2">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" padding-bottom="1pt" padding-right="4pt">
                    <fo:block space-before="2pt" space-after="2pt" font-weight="bold" font-size="14pt">
                        STEP 2
                    </fo:block>
                    <fo:block space-after="4pt" font-weight="bold" font-size="12pt">
                        Anatomical Measurements
                    </fo:block>
                    <fo:block font-size="6pt">
                        (These measurments should be given
                    </fo:block>
                    <fo:block font-size="6pt">
                        in mm rounded to the nearest mm.
                    </fo:block>
                    <fo:block font-size="6pt">
                        The following CT diameters are outer
                    </fo:block>
                    <fo:block space-after="2pt" font-size="6pt">
                        wall to outer wall.)
                    </fo:block>
                    <fo:block space-after="2pt" font-weight="bold">
                        CT table position at:
                    </fo:block>
                    <fo:block space-after="2pt">
                        _____ lowest renal artery
                    </fo:block>
                    <fo:block font-size="8pt">
                        15 mm below lowest renal artery,
                    </fo:block>
                    <fo:block space-after="2pt" font-size="8pt">
                        check for 10% increase
                    </fo:block>
                    <fo:block space-after="2pt">
                        _____ aortic bifurcation
                    </fo:block>
                    <fo:block space-after="2pt">
                        _____ origin cl internal iliac
                    </fo:block>
                    <fo:block space-after="4pt">
                        _____ origin il internal iliac
                    </fo:block>
                    <fo:block color="#6F6F6F" space-after="2pt" padding-top="2pt" padding-left="2pt" padding-bottom="48pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-color="#E5E5E5" border-left-color="#E5E5E5" border-bottom-color="#E5E5E5" border-right-color="#E5E5E5">
                        Space for Calculations
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell text-align="center" display-align="center" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="1pt">
                    <fo:block>
                        <fo:external-graphic src="{concat('../IMAGE/', 'aneurysm.jpg')}"/>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
    <fo:list-block space-after="2pt">
        <fo:list-item>
            <fo:list-item-label>
                <fo:block>&#8226;</fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="8pt">
                <fo:block font-size="8pt">
                    When using CT for length, approximate lateral deviation/tortuostity and
                </fo:block>
                <fo:block font-size="8pt">
                    add to difference in table position.
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </fo:list-block>
    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell display-align="center">
                    <fo:block font-weight="bold">
                        Diameters:
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-right="4pt">
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell display-align="center">
                                    <fo:block>
                                        D1
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D1}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                    <xsl:variable name="D1" select="$DICOM/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'D1' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <fo:block font-size="12pt" font-weight="bold" color="#{$PEN_COLOR}">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$D1"/>
                                            <xsl:with-param name="pAddUnit" select="'false'"/>
                                            <xsl:with-param name="pPattern" select="'#'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" background-color="#{$ZENITH_COLOR_D1}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D1}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:circle cx="4" cy="7" r="2" fill="#FFFFFF"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell padding-right="4pt">
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell display-align="center">
                                    <fo:block>
                                        D2
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D2}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D2}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                    <xsl:variable name="D2" select="$DICOM/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'D2' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <fo:block font-size="12pt" font-weight="bold" color="#{$PEN_COLOR}">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$D2"/>
                                            <xsl:with-param name="pAddUnit" select="'false'"/>
                                            <xsl:with-param name="pPattern" select="'#'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" background-color="#{$ZENITH_COLOR_D2}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D2}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D2}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:circle cx="4" cy="3" r="2" fill="#FFFFFF"/>
                                            <svg:circle cx="4" cy="10" r="2" fill="#FFFFFF"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell padding-right="4pt">
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell display-align="center">
                                    <fo:block>
                                        D3
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D3}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D3}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                    <xsl:variable name="D3" select="$DICOM/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'D3' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <fo:block font-size="12pt" font-weight="bold" color="#{$PEN_COLOR}">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$D3"/>
                                            <xsl:with-param name="pAddUnit" select="'false'"/>
                                            <xsl:with-param name="pPattern" select="'#'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" background-color="#{$ZENITH_COLOR_D3}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D3}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D3}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:circle cx="4" cy="2" r="2" fill="#FFFFFF"/>
                                            <svg:circle cx="4" cy="7" r="2" fill="#FFFFFF"/>
                                            <svg:circle cx="4" cy="12" r="2" fill="#FFFFFF"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell display-align="center">
                    <fo:block font-weight="bold">
                        Lengths:
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell padding-right="4pt">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell display-align="center">
                                    <fo:block>
                                        L1
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_L1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_L1}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                    <fo:block>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" background-color="#{$ZENITH_COLOR_L1}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_L1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_L1}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:rect x="3" y="5" width="3" height="3" fill="#FFFFFF"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell padding-right="4pt">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell display-align="center">
                                    <fo:block>
                                        L2
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_L2}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L2}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_L2}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L2}">
                                    <fo:block>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" background-color="#{$ZENITH_COLOR_L2}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_L2}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L2}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_L2}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L2}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:rect x="3" y="2" width="3" height="3" fill="#FFFFFF"/>
                                            <svg:rect x="3" y="9" width="3" height="3" fill="#FFFFFF"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell padding-right="4pt">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(5)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell display-align="center">
                                    <fo:block>
                                        L3
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_L3}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L3}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_L3}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L3}">
                                    <fo:block>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" background-color="#{$ZENITH_COLOR_L3}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_L3}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L3}" border-bottom-style="solid"  border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_L3}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L3}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:rect x="3" y="1" width="3" height="3" fill="#FFFFFF"/>
                                            <svg:rect x="3" y="6" width="3" height="3" fill="#FFFFFF"/>
                                            <svg:rect x="3" y="11" width="3" height="3" fill="#FFFFFF"/>
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

    <fo:block font-size="6pt" space-after="1pt">
        D1: Largest aortic neck diameter throughout 15 mm neck length
    </fo:block>
    <fo:block font-size="6pt" space-after="1pt">
        D2: Largest iliac diameter throughout contralateral distal fixation site
    </fo:block>
    <fo:block font-size="6pt" space-after="2pt">
        D3: Largest iliac diameter throughout ipsilateral distal fixation site
    </fo:block>
    <fo:block font-size="6pt" space-after="1pt">
        L1: Lowest renal artery to aortic bifurcation + lateral deviation/tortuosity
    </fo:block>
    <fo:block font-size="6pt" space-after="1pt">
        L2: Lowest renal artery to contralateral distal fixation site + lateral deviation/tortuosity
    </fo:block>
    <fo:block font-size="6pt" space-after="2pt">
        L3: Lowest renal artery to ipsilateral distal fixation site + lateral deviation/tortuosity
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addZenithAAAStep3
-->
<xsl:template name="addZenithAAAStep3">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(3)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" padding-bottom="1pt" padding-right="4pt">
                    <fo:block space-before="2pt" space-after="2pt" font-weight="bold" font-size="14pt">
                        STEP 3
                    </fo:block>
                    <fo:block space-after="4pt" font-weight="bold" font-size="12pt">
                        Main Body
                    </fo:block>
                    <fo:list-block space-after="2pt">
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    From D1, select graft diameter.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    From L1, select the graft lengths.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    If the choice of graft diameter or graft length
                                </fo:block>
                                <fo:block font-size="8pt">
                                    is affected by other considerations, adjust
                                </fo:block>
                                <fo:block font-size="8pt">
                                    accordingly.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    Using graft diameter and cl length, complete
                                </fo:block>
                                <fo:block font-size="8pt">
                                    the Main Body Order Number.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    </fo:list-block>
                </fo:table-cell>
                <fo:table-cell text-align="center" display-align="center" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="2pt">
                    <fo:block font-weight="bold" font-size="8pt" space-before="2pt">
                        Main Body (TFB)
                    </fo:block>
                    <fo:block font-weight="bold" font-size="8pt" space-after="2pt">
                        Graft Diameters
                    </fo:block>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:block font-size="8pt">
                                        D1
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        (mm)
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:block font-size="8pt">
                                        Graft
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        Diameter
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        (mm)
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="before" padding-right="1pt">
                                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                                    <fo:block font-size="8pt">
                                                        18-19
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                                    <fo:block font-size="8pt">
                                                        20-21
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                                    <fo:block font-size="8pt">
                                                        22
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                                    <fo:block font-size="8pt">
                                                        23-24
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                                    <fo:block font-size="8pt">
                                                        25-26
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                                    <fo:block font-size="8pt">
                                                        27-28
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_D1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_D1}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1}">
                                                    <fo:instream-foreign-object text-align="center">
                                                        <svg:svg width="30" height="8">
                                                            <svg:circle cx="15" cy="4" r="2" fill="#FFFFFF"/>
                                                        </svg:svg>
                                                    </fo:instream-foreign-object>
                                                </fo:table-cell>
                                            </fo:table-row>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="before" padding-left="1pt">
                                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        22
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        24
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        26
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        28
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        30
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        32
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                                    <fo:instream-foreign-object text-align="center">
                                                        <svg:svg width="29" height="8">
                                                            <svg:polygon points="15,2 13,6 17,6" fill="#FFFFFF"/>
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
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(11)"/>
        <fo:table-column column-width="proportional-column-width(9)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" padding-bottom="1pt" padding-right="12pt">
                    <fo:block font-weight="bold" space-after="8pt">
                        Main Body Order Number =
                    </fo:block>
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell display-align="center">
                                    <fo:block font-weight="bold">
                                        TFB -
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                    <xsl:variable name="D1" select="$DICOM/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'D1' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <fo:block font-size="12pt" font-weight="bold" color="#{$PEN_COLOR}">
                                        <xsl:call-template name="getZenith_D1_GraftDiam">
                                            <xsl:with-param name="pD1">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$D1"/>
                                                    <xsl:with-param name="pAddUnit" select="'false'"/>
                                                    <xsl:with-param name="pPattern" select="'#'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" background-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D1_GRAFT_DIAM}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:polygon points="2,5 2,9 6,7" fill="#FFFFFF"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="center">
                                    <fo:block font-weight="bold">
                                        -
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_CL_LENGTH}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_CL_LENGTH}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                    <fo:block>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" background-color="#{$ZENITH_COLOR_CL_LENGTH}" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_CL_LENGTH}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-width="thick" border-bottom-color="#{$ZENITH_COLOR_CL_LENGTH}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                    <fo:instream-foreign-object text-align="center">
                                        <svg:svg width="8" height="14">
                                            <svg:polygon points="3,5 1,7 3,9 5,7" fill="#FFFFFF"/>
                                        </svg:svg>
                                    </fo:instream-foreign-object>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" number-columns-spanned="2" padding-top="2pt">
                                    <fo:table table-layout="fixed" width="100%">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-column column-width="proportional-column-width(3)"/>
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="right">
                                                    <fo:block font-size="12pt">
                                                        (
                                                    </fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="center">
                                                    <fo:block font-size="6pt">
                                                        Graft
                                                    </fo:block>
                                                    <fo:block font-size="6pt">
                                                        Diameter
                                                    </fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="left">
                                                    <fo:block font-size="12pt">
                                                        )
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" number-columns-spanned="2" padding-top="2pt">
                                    <fo:table table-layout="fixed" width="100%">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-column column-width="proportional-column-width(6)"/>
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="right">
                                                    <fo:block font-size="12pt">
                                                        (
                                                    </fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="center">
                                                    <fo:block font-size="6pt">
                                                        cl Length /
                                                    </fo:block>
                                                    <fo:block font-size="6pt">
                                                        Graft Length
                                                    </fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="left">
                                                    <fo:block font-size="12pt">
                                                        )
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
                <fo:table-cell padding-top="1pt" padding-bottom="1pt" padding-left="4pt" padding-right="2pt">
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:block font-size="8pt" font-weight="bold" space-after="2pt">
                                        Main Body (TFB) Graft Lengths
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:table table-layout="fixed" width="100%">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" display-align="after">
                                                    <fo:block font-size="8pt">
                                                        L1
                                                    </fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="center" display-align="after">
                                                    <fo:block font-size="8pt">
                                                        cl
                                                    </fo:block>
                                                    <fo:block font-size="8pt">
                                                        Length*
                                                    </fo:block>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="center" display-align="after">
                                                    <fo:block font-size="8pt">
                                                        il
                                                    </fo:block>
                                                    <fo:block font-size="8pt">
                                                        Length**
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-right="1pt">
        <!-- L1 table -->
                                                    <fo:table table-layout="fixed" width="100%">
                                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                                        <fo:table-body>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_L1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                                                    <fo:block font-size="8pt">
                                                                        80-95
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                                                    <fo:block font-size="8pt">
                                                                        96-110
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                                                    <fo:block font-size="8pt">
                                                                        111-125
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                                                    <fo:block font-size="8pt">
                                                                        126-140
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                                                    <fo:block font-size="8pt">
                                                                        141-155
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_L1}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_L1}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_L1}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_L1}">
                                                                    <fo:instream-foreign-object text-align="center">
                                                                        <svg:svg width="36" height="8">
                                                                            <svg:rect x="18" y="2" width="3" height="3" fill="#FFFFFF"/>
                                                                        </svg:svg>
                                                                    </fo:instream-foreign-object>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                        </fo:table-body>
                                                    </fo:table>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="center" padding-left="1pt" padding-right="1pt">
        <!-- cl Length table -->
                                                    <fo:table table-layout="fixed" width="100%">
                                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                                        <fo:table-body>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_CL_LENGTH}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        74
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        88
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        103
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        117
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        132
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_CL_LENGTH}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_CL_LENGTH}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_CL_LENGTH}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_CL_LENGTH}">
                                                                    <fo:instream-foreign-object text-align="center">
                                                                        <svg:svg width="36" height="8">
                                                                            <svg:polygon points="19,2 17,4 19,6 21,4" fill="#FFFFFF"/>
                                                                        </svg:svg>
                                                                    </fo:instream-foreign-object>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                        </fo:table-body>
                                                    </fo:table>
                                                </fo:table-cell>
                                                <fo:table-cell text-align="center" padding-left="1pt">
        <!-- il Length table -->
                                                    <fo:table table-layout="fixed" width="100%">
                                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                                        <fo:table-body>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_IL_LENGTH}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_IL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_IL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        104
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_IL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_IL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        118
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_IL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_IL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        133
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_IL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_IL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        147
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_IL_LENGTH}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_IL_LENGTH}">
                                                                    <fo:block font-size="8pt">
                                                                        162
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_IL_LENGTH}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_IL_LENGTH}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_IL_LENGTH}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_IL_LENGTH}">
                                                                    <fo:instream-foreign-object text-align="center">
                                                                        <svg:svg width="36" height="8">
                                                                            <svg:polygon points="15,2 13,4 15,6 17,4" fill="#FFFFFF"/>
                                                                            <svg:polygon points="23,2 21,4 23,6 25,4" fill="#FFFFFF"/>
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
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block font-size="6pt" font-style="italic" space-before="2pt" space-after="2pt">
                                        *main body length on contralateral side.
                                    </fo:block>
                                    <fo:block font-size="6pt" font-style="italic">
                                        **main body length on ipsilateral side.
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

<!-- ####################################################################################################
    Template:       addZenithAAAStep4
-->
<xsl:template name="addZenithAAAStep4">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" padding-bottom="1pt" padding-right="4pt">
                    <fo:block space-before="2pt" space-after="2pt" font-weight="bold" font-size="14pt">
                        STEP 4
                    </fo:block>
                    <fo:block space-after="4pt" font-weight="bold" font-size="12pt">
                        Contralateral Iliac Leg
                    </fo:block>
                    <fo:list-block space-after="2pt">
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    From D2, select graft diameter.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    Using L2 and cl length, complete
                                </fo:block>
                                <fo:block font-size="8pt">
                                    the following equation.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    Using contralateral working length,
                                </fo:block>
                                <fo:block font-size="8pt">
                                    select graft length.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    </fo:list-block>
                </fo:table-cell>
                <fo:table-cell text-align="center" display-align="center" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="2pt">
                    <fo:block font-weight="bold" font-size="8pt" space-before="2pt">
                        Contralateral Leg
                    </fo:block>
                    <fo:block font-weight="bold" font-size="8pt" space-after="2pt">
                        (TFLE) Graft Diameters
                    </fo:block>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:block font-size="8pt">
                                        D2
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        (mm)
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:block font-size="8pt">
                                        Graft
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        Diameter
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        (mm)
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="before" padding-right="1pt">
                                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D2}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        &lt;8
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        8-9
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        10-11
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        12-13
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        14-15
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        16-17
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        18
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        19
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:block font-size="8pt">
                                                        20
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_D2}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_D2}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2}">
                                                    <fo:instream-foreign-object text-align="center">
                                                        <svg:svg width="42" height="8">
                                                            <svg:circle cx="18" cy="4" r="2" fill="#FFFFFF"/>
                                                            <svg:circle cx="24" cy="4" r="2" fill="#FFFFFF"/>
                                                        </svg:svg>
                                                    </fo:instream-foreign-object>
                                                </fo:table-cell>
                                            </fo:table-row>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="before" padding-left="1pt">
                                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        8
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        10
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        12
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        14
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        16
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        18
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        20
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        22
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        24
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D2_GRAFT_DIAM}">
                                                    <fo:instream-foreign-object text-align="center">
                                                        <svg:svg width="36" height="8">
                                                            <svg:polygon points="17,2 15,6 19,6" fill="#FFFFFF"/>
                                                            <svg:polygon points="24,2 22,6 26,6" fill="#FFFFFF"/>
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
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addZenithAAAStep5
-->
<xsl:template name="addZenithAAAStep5">
    <xsl:param name="pItem"/>

    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell padding-top="1pt" padding-bottom="1pt" padding-right="4pt">
                    <fo:block space-before="2pt" space-after="2pt" font-weight="bold" font-size="14pt">
                        STEP 5
                    </fo:block>
                    <fo:block space-after="4pt" font-weight="bold" font-size="12pt">
                        Ipsilateral Iliac Leg
                    </fo:block>
                    <fo:list-block space-after="2pt">
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    From D3, select graft diameter.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    Using L3 and il length, complete
                                </fo:block>
                                <fo:block font-size="8pt">
                                    the following equation.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                        <fo:list-item space-after="2pt">
                            <fo:list-item-label>
                                <fo:block>&#8226;</fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="8pt">
                                <fo:block font-size="8pt">
                                    Using ipsilateral working length,
                                </fo:block>
                                <fo:block font-size="8pt">
                                    select graft length.
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    </fo:list-block>
                </fo:table-cell>
                <fo:table-cell text-align="center" display-align="center" padding-top="1pt" padding-left="4pt" padding-bottom="1pt" padding-right="2pt">
                    <fo:block font-weight="bold" font-size="8pt" space-before="2pt">
                        Ipsilateral Leg (TFLE)
                    </fo:block>
                    <fo:block font-weight="bold" font-size="8pt" space-after="2pt">
                        Graft Diameters
                    </fo:block>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:block font-size="8pt">
                                        D3
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        (mm)
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="after">
                                    <fo:block font-size="8pt">
                                        Graft
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        Diameter
                                    </fo:block>
                                    <fo:block font-size="8pt">
                                        (mm)
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell text-align="center" display-align="before" padding-right="1pt">
                                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D3}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        &lt;8
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        8-9
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        10-11
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        12-13
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        14-15
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        16-17
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        18
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        19
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:block font-size="8pt">
                                                        20
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_D3}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_D3}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3}">
                                                    <fo:instream-foreign-object text-align="center">
                                                        <svg:svg width="42" height="8">
                                                            <svg:circle cx="15" cy="4" r="2" fill="#FFFFFF"/>
                                                            <svg:circle cx="21" cy="4" r="2" fill="#FFFFFF"/>
                                                            <svg:circle cx="27" cy="4" r="2" fill="#FFFFFF"/>
                                                        </svg:svg>
                                                    </fo:instream-foreign-object>
                                                </fo:table-cell>
                                            </fo:table-row>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:table-cell>
                                <fo:table-cell text-align="center" display-align="before" padding-left="1pt">
                                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                                        <fo:table-column column-width="proportional-column-width(1)"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-top-style="solid" border-top-width="thick" border-top-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        8
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        10
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        12
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        14
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        16
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        18
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        20
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        22
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-width="thin" border-bottom-color="#939598" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:block font-size="8pt">
                                                        24
                                                    </fo:block>
                                                </fo:table-cell>
                                            </fo:table-row>
                                            <fo:table-row>
                                                <fo:table-cell text-align="center" padding-top="1pt" background-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-left-style="solid" border-left-width="thick" border-left-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-bottom-style="solid" border-bottom-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}" border-right-style="solid" border-right-width="thick" border-right-color="#{$ZENITH_COLOR_D3_GRAFT_DIAM}">
                                                    <fo:instream-foreign-object text-align="center">
                                                        <svg:svg width="42" height="8">
                                                            <svg:polygon points="15,2 13,6 17,6" fill="#FFFFFF"/>
                                                            <svg:polygon points="21,2 19,6 23,6" fill="#FFFFFF"/>
                                                            <svg:polygon points="27,2 25,6 29,6" fill="#FFFFFF"/>
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
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       getZenith_D1_GraftDiam
    Description:    Returns the corresponding Zenith Graft Diameter for D1.
    Parameters:
        pD1	 :  D1 in mm.
-->
<xsl:template name="getZenith_D1_GraftDiam"> <xsl:param name="pD1"/>
    <xsl:choose>
        <xsl:when test="18 &lt;= $pD1 and $pD1 &lt;= 19">22</xsl:when>
        <xsl:when test="20 &lt;= $pD1 and $pD1 &lt;= 21">24</xsl:when>
        <xsl:when test="$pD1 = 22">26</xsl:when>
        <xsl:when test="23 &lt;= $pD1 and $pD1 &lt;= 24">28</xsl:when>
        <xsl:when test="25 &lt;= $pD1 and $pD1 &lt;= 26">30</xsl:when>
        <xsl:when test="27 &lt;= $pD1 and $pD1 &lt;= 28">32</xsl:when>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       getZenith_D2_GraftDiam
    Description:    Returns the corresponding Zenith Graft Diameter for D2.
    Parameters:
        pD2	 :  D2 in mm.
-->
<xsl:template name="getZenith_D2_GraftDiam"> <xsl:param name="pD2"/>
    <xsl:choose>
        <xsl:when test="$pD2 &lt; 8">8</xsl:when>
        <xsl:when test="8 &lt;= $pD2 and $pD2 &lt;= 9">10</xsl:when>
        <xsl:when test="10 &lt;= $pD2 and $pD2 &lt;= 11">12</xsl:when>
        <xsl:when test="12 &lt;= $pD2 and $pD2 &lt;= 13">14</xsl:when>
        <xsl:when test="14 &lt;= $pD2 and $pD2 &lt;= 15">16</xsl:when>
        <xsl:when test="16 &lt;= $pD2 and $pD2 &lt;= 17">18</xsl:when>
        <xsl:when test="$pD2 = 18">20</xsl:when>
        <xsl:when test="$pD2 = 19">22</xsl:when>
        <xsl:when test="$pD2 = 20">24</xsl:when>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       getZenith_D3_GraftDiam
    Description:    Returns the corresponding Zenith Graft Diameter for D3.
    Parameters:
        pD3	 :  D3 in mm.
-->
<xsl:template name="getZenith_D3_GraftDiam"> <xsl:param name="pD3"/>
    <xsl:choose>
        <xsl:when test="$pD3 &lt; 8">8</xsl:when>
        <xsl:when test="8 &lt;= $pD3 and $pD3 &lt;= 9">10</xsl:when>
        <xsl:when test="10 &lt;= $pD3 and $pD3 &lt;= 11">12</xsl:when>
        <xsl:when test="12 &lt;= $pD3 and $pD3 &lt;= 13">14</xsl:when>
        <xsl:when test="14 &lt;= $pD3 and $pD3 &lt;= 15">16</xsl:when>
        <xsl:when test="16 &lt;= $pD3 and $pD3 &lt;= 17">18</xsl:when>
        <xsl:when test="$pD3 = 18">20</xsl:when>
        <xsl:when test="$pD3 = 19">22</xsl:when>
        <xsl:when test="$pD3 = 20">24</xsl:when>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
