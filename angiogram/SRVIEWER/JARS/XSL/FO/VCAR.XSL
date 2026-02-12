<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    VCAR.XSL - PETVCAR specific XSLT rules for SR to XSL-FO transformation.
    @author raczatt
    @date Jul 11, 2007
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                              xmlns:fox="http://xml.apache.org/fop/extensions">

<!-- ####################################################################################################
    Template:       addPETVCARContentItem
    Description:    Add content item to report.
    Parameters:
        pItem    :  First level content item in the report.
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPETVCARContentItem"> <xsl:param name="pItem"/>
                                            <xsl:param name="pPosition"/>

    <xsl:if test="$pItem/RelationshipType = 'CONTAINS'">
    <xsl:choose>
<!-- The content item is coming from an application specific report. -->
        <xsl:when test="$pItem/@app">
            <xsl:choose>
        <!-- (G-C32C, SRT, Procedure Context) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'G-C32C' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                    <xsl:call-template name="addPETVCARProcedureContext">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (121070, DCM, Findings) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121070' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                    <xsl:call-template name="addPETVCARFindings">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-024, 99GEMS, General Images) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-024' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addPETVCARGeneralImages">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (121076, DCM, Conclusions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121076' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                    <xsl:call-template name="addPETVCARConclusions">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (PQ-0110, 99GEMS, Patient Questions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                    <xsl:call-template name="addPatientQuestions">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:call-template name="addItemWithGenericAndName">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
        <!-- (PQ-0110, 99GEMS, Patient Questions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                    <xsl:call-template name="addPatientQuestions">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="addItemWithGenericAndName">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:if>

</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARProcedureContext
    Description:    Adds Procedure context.
    Parameters:
        pItem    :  (G-C32C, SRT, Procedure Context) content item
-->
<xsl:template name="addPETVCARProcedureContext"> <xsl:param name="pItem"/>
                                                 <xsl:param name="pPosition"/>

<!-- (PVCAR-0100, 99GEMS, Exam) items. -->
    <xsl:variable name="exams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$exams"/>
        </xsl:call-template>
    </xsl:variable>
<!-- (G-D802, SRT, Date) -->
    <xsl:variable name="examDate" select="$exams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
<!-- (8302-2, LN, Patient Height) -->
    <xsl:variable name="patientHeight" select="$exams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8302-2' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
<!-- (29463-7, LN, Patient Weight) -->
    <xsl:variable name="patientWeight" select="$exams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '29463-7' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-header>
                            <fo:table-row background-color="#{$P2}">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                                        <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$patientHeight/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> / </xsl:text>
                                        <xsl:value-of select="$patientWeight/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$vcarmsg/LBL_TRACER/msg[@lang = $lang]"/>
                                        <xsl:text> / </xsl:text>
                                        <xsl:value-of select="$vcarmsg/LBL_RADIONUCLIDE/msg[@lang = $lang]"/>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$vcarmsg/LBL_METABOLIZATION_TIME/msg[@lang = $lang]"/>
                                        <!--xsl:text> / </xsl:text>
                                        <xsl:value-of select="$vcarmsg/LBL_METABOLIZATION_TIME_DIFFERENCE_TO_BASELINE/msg[@lang = $lang]"/-->
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$vcarmsg/LBL_INJECTED_VOLUME/msg[@lang = $lang]"/>
                                        <xsl:text> / </xsl:text>
                                        <xsl:value-of select="$vcarmsg/LBL_INJECTED_DOSE/msg[@lang = $lang]"/>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$vcarmsg/LBL_BLOOD_GLUCOSE_LEVEL/msg[@lang = $lang]"/>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$vcarmsg/LBL_REF_SUV_LEVEL/msg[@lang = $lang]"/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <xsl:for-each select="$exams">
                                <xsl:sort select="position()" data-type="number" order="descending"/>
                    <!-- Current (PVCAR-0100, 99GEMS, Exam) item. -->
                                <xsl:variable name="curExam" select="current()"/>
                    <!-- Current (110180, DCM, Study Instance UID) item. -->
                                <xsl:variable name="curStudyUID" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                    <!-- (PVCAR-0010, 99GEMS, PET Context) -->
                                <xsl:variable name="petContexts" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <!-- (PVCAR-0010, 99GEMS, PET Context) -->
                                <xsl:variable name="petContextsNo" select="count($petContexts)"/>
                                <xsl:for-each select="$petContexts">
                            <!-- (123001, DCM, Radiopharmaceutical) -->
                                    <xsl:variable name="curRadiopharmaceutical" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123001' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <fo:table-row>
                                        <xsl:variable name="borderWidth">
                                            <xsl:call-template name="setBaselineBorderWidth">
                                                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                                                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:variable name="fontWeight">
                                            <xsl:call-template name="setBaselineFontWeight">
                                                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                                                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:if test="position() = 1">
                                <!-- (G-D802, SRT, Date) and (G-D217, SRT, Interval) items. -->
                                        <fo:table-cell number-rows-spanned="{$petContextsNo}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="{$borderWidth}" border-bottom-width="{$borderWidth}" border-end-width="thin">
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="left">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                                                </xsl:call-template>
                                            </fo:block>
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="left">
                                                <xsl:choose>
                                                    <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                                                        <xsl:value-of select="$vcarmsg/LBL_BASELINE/msg[@lang = $lang]"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                            <!-- Current (G-D217, SRT, Interval) item. -->
                                                        <xsl:variable name="curIntervalItem" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D217' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                                                        <xsl:if test="$curIntervalItem/MeasuredValueSequence/Item/NumericValue &gt; 0">
                                                            <xsl:text>+</xsl:text>
                                                        </xsl:if>
                                                        <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="$curIntervalItem"/>
                                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                                            <xsl:with-param name="pUnit" select="'cm'"/>
                                                            <xsl:with-param name="pPattern" select="'###0'"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </fo:block>
                                        </fo:table-cell>
                                <!-- (8302-2, LN, Patient Height) / (29463-7, LN, Patient Weight) -->
                                        <fo:table-cell number-rows-spanned="{$petContextsNo}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="{$borderWidth}" border-bottom-width="{$borderWidth}" border-end-width="thin">
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8302-2' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
                                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                                </xsl:call-template>
                                                <xsl:text> / </xsl:text>
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '29463-7' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
                                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </fo:table-cell>
                                        </xsl:if>
                                        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="thin" border-bottom-width="{$borderWidth}" border-end-width="thin">
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                                <!-- (123001, DCM, Radiopharmaceutical) -->
                                                <xsl:variable name="radiopharmaceuticalItem" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123001' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                <xsl:choose>
                                                    <xsl:when test="$radiopharmaceuticalItem/ConceptCodeSequence/Item/CodeValue = 'C-B1031' and $radiopharmaceuticalItem/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                                                        <xsl:value-of select="$vcarmsg/LBL_FDG/msg[@lang = $lang]"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="$radiopharmaceuticalItem"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text> / </xsl:text>
                                <!-- (C-B1000, SRT, Diagnostic Radioisotope) -->
                                                <xsl:variable name="isotopeItem" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'C-B1000' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                                                <xsl:choose>
                                                    <xsl:when test="$isotopeItem/ConceptCodeSequence/Item/CodeValue = 'C-111A1' and $isotopeItem/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                                                        <xsl:value-of select="$vcarmsg/LBL_18F/msg[@lang = $lang]"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="$isotopeItem"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="thin" border-bottom-width="{$borderWidth}" border-end-width="thin">
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                                <!-- (123003, DCM, Radiopharmaceutical Start Time) -->
                                                <xsl:variable name="injectionStartDateTime">
                                                    <xsl:call-template name="DTtoXSDdateTime">
                                                        <xsl:with-param name="pDateTime" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123003' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]/DateTime"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                <!-- (PVCAR-0006, 99GEMS, Acquisition DateTime) -->
                                                <xsl:variable name="acquisitionDateTime">
                                                    <xsl:call-template name="DTtoXSDdateTime">
                                                        <xsl:with-param name="pDateTime" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0006' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]/DateTime"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:if test="$injectionStartDateTime != '' and $acquisitionDateTime != ''">
                                                    <xsl:call-template name="addMetabolizationTime">
                                                        <xsl:with-param name="pStart" select="$injectionStartDateTime"/>
                                                        <xsl:with-param name="pEnd" select="$acquisitionDateTime"/>
                                                    </xsl:call-template>
                                                </xsl:if>
                                                <!--xsl:text> / </xsl:text-->
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="thin" border-bottom-width="{$borderWidth}" border-end-width="thin">
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                                <!-- (123005, DCM, Radiopharmaceutical Volume) -->
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123005' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                </xsl:call-template>
                                                <xsl:text> / </xsl:text>
                                <!-- (123006, DCM, Radionuclide Total Dose) -->
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123006' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="thin" border-bottom-width="{$borderWidth}" border-end-width="thin">
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                                <!-- (F-0194E, SRT, Blood Glucose Level) -->
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'F-0194E' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="thin" border-bottom-width="{$borderWidth}" border-end-width="{$borderWidth}">
                                            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                                <!-- (PVCAR-0090, 99GEMS, "Reference SUV Mean") -->
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0090' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </xsl:for-each>
                            </xsl:for-each>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<xsl:template name="addPETVCARFindingsCol"> <xsl:param name="pExams"/>
    <xsl:for-each select="$pExams">
        <fo:table-column column-width="proportional-column-width(2)"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="addPETVCARFindingsColHeader"> <xsl:param name="pHeader"/>
                                                  <xsl:param name="pColumnSpan"/>
                                                  <xsl:param name="pUnit"/>
    <fo:table-cell number-columns-spanned="{$pColumnSpan}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
        <fo:block hyphenate="true" language="{$lang}" text-align="center">
            <fo:inline font-weight="bold">
                <xsl:value-of select="$pHeader"/>
            </fo:inline>
        </fo:block>
        <xsl:if test="$pUnit and ($pUnit/ConceptCodeSequence/Item/CodeValue != '1' or $pUnit/ConceptCodeSequence/Item/CodingSchemeDesignator != $CSD_UCUM)">
            <fo:block font-weight="bold" hyphenate="true" language="{$lang}" text-align="center">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="$pUnit/ConceptCodeSequence/Item/CodeValue"/>
                <xsl:text>]</xsl:text>
            </fo:block>
        </xsl:if>
    </fo:table-cell>
</xsl:template>

<xsl:template name="addPETVCARExamDateCells"> <xsl:param name="pExams"/>

<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$pExams"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="$pExams">
    <!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <xsl:variable name="borderWidth">
            <xsl:call-template name="setBaselineBorderWidth">
                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="fontWeight">
            <xsl:call-template name="setBaselineFontWeight">
                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                    <xsl:value-of select="$vcarmsg/LBL_BASELINE/msg[@lang = $lang]"/>
                </xsl:when>
                <xsl:otherwise>
        <!-- Current (G-D217, SRT, Interval) item. -->
                    <xsl:variable name="curIntervalItem" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D217' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                    <xsl:if test="$curIntervalItem/MeasuredValueSequence/Item/NumericValue &gt; 0">
                        <xsl:text>+</xsl:text>
                    </xsl:if>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$curIntervalItem"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'cm'"/>
                        <xsl:with-param name="pPattern" select="'###0'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="curDateXSD">
            <xsl:call-template name="toXSDdate">
                <xsl:with-param name="pDate" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]/Date"/>
            </xsl:call-template>
        </xsl:variable>
        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="{$borderWidth}" border-start-width="{$borderWidth}" border-bottom-width="thin" border-end-width="{$borderWidth}">
            <fo:block font-weight="{$fontWeight}" font-size="{$small1FontSize}pt" hyphenate="true" language="{$lang}" text-align="center">
                <fo:basic-link external-destination="x:{$title}">
                    <xsl:call-template name="formatDate">
                        <xsl:with-param name="pDate" select="$curDateXSD"/>
                    </xsl:call-template>
                </fo:basic-link>
            </fo:block>
        </fo:table-cell>
    </xsl:for-each>

</xsl:template>

<!-- ####################################################################################################
    Template:       countMinColWidth
    Description:    Count minimum column width for IDA table based on inner page width.
    Parameters:
-->
<xsl:template name="countMinColWidth">

    <xsl:choose>
<!-- Margin unit is A4_UNIT -->
        <xsl:when test="$marginUnit = $A4_UNIT">
            <xsl:value-of select="18"/>
        </xsl:when>
<!-- Margin unit is US_UNIT -->
        <xsl:otherwise>
            <xsl:value-of select="format-number((18 div ($RATE_cm_in * 10)), '#.#')"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- ####################################################################################################
    Template:       addPETVCARFindings
    Description:    Adds Findings content item.
    Parameters:
        pItem    :  (121070, DCM, Findings) content item
-->
<xsl:template name="addPETVCARFindings"> <xsl:param name="pItem"/>
                                         <xsl:param name="pPosition"/>

    <xsl:variable name="thisFindingsPos" select="count($pItem/preceding-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = '121070' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]) + 1"/>
    <xsl:variable name="allProcedureContexts" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C32C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="procedureContext" select="$allProcedureContexts[position() = $thisFindingsPos]"/>
<!-- (PVCAR-0100, 99GEMS, Exam) items in the corresponding (G-C32C, SRT, Procedure Context) item. -->
    <xsl:variable name="exams" select="$procedureContext/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="examNo" select="count($exams)"/>
<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$exams"/>
        </xsl:call-template>
    </xsl:variable>

<!-- Minimum column width needed to fit a statistics value. -->
    <xsl:variable name="minColWidth">
        <xsl:call-template name="countMinColWidth"/>
    </xsl:variable>
<!-- Maximum number of columns that can fit to the inner page width. -->
    <xsl:variable name="maxCol" select="format-number($innerPageWidth div $minColWidth, '###0')"/>
<!-- Maximum number of statistics that can fit to the inner page width. -->
    <xsl:variable name="maxStatisticsNum" select="floor(($maxCol - 1) div $examNo - 1)"/>

<!-- (R-40831, SRT, Measurement) items describing statistics and their corresponding units. -->
    <xsl:variable name="statisticsDescs" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="statisticsDescsR" select="$statisticsDescs[ConceptCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED_RT or (ConceptCodeSequence/Item/CodeValue != 'G-A105' and ConceptCodeSequence/Item/CodeValue != 'G-A116')]"/>
    <xsl:variable name="statisticsDescsRNo" select="count($statisticsDescsR)"/>

<!-- (121071, DCM, Finding) items. -->
    <xsl:variable name="findingItems" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121071' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- (112020, DCM, Response Evaluation) items. -->
    <xsl:variable name="responseEvaluation" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112020' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
    <!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:if test="$responseEvaluation">
                <fo:table-row>
                    <fo:table-cell>
                        <xsl:call-template name="addPETVCARGuidelines">
                            <xsl:with-param name="pResponseEvaluation" select="$responseEvaluation"/>
                        </xsl:call-template>
                    </fo:table-cell>
                </fo:table-row>
            </xsl:if>
            <fo:table-row>
                <fo:table-cell>
                    <xsl:call-template name="addPETVCARNStatistics">
                        <xsl:with-param name="pStatistics" select="$statisticsDescsR"/>
                        <xsl:with-param name="pFindingsItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                        <xsl:with-param name="pN" select="$maxStatisticsNum"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>

    <xsl:if test="$DICOM/@templateGroup != 'PETVCAR' or $DICOM/@template != 'AWS'">
	    <xsl:for-each select="$findingItems">
	<!-- (112039, DCM, Tracking Identifier) item. -->
	        <xsl:variable name="trackingID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112039' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- If not the Summary row -->
	        <xsl:if test="string(number($trackingID/TextValue)) != 'NaN'">
	            <fo:table table-layout="fixed" width="100%" space-after="4pt">
	                <fo:table-column column-width="proportional-column-width(1)"/>
	                <fo:table-body>
	                    <fo:table-row keep-with-next="always">
	                        <fo:table-cell>
	                            <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition, 'Lesion', $trackingID/TextValue)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading2FontSize}pt">
	                                <fo:basic-link internal-destination="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition, 'TableLesion', $trackingID/TextValue)}" color="blue">
	                                    <fo:inline text-decoration="underline">
	                                        <xsl:value-of select="concat($vcarmsg/LBL_LESION/msg[@lang = $lang], ' ', $trackingID/TextValue)"/>
	                                    </fo:inline>
	                                </fo:basic-link>
	                            </fo:block>
	                        </fo:table-cell>
	                    </fo:table-row>
	                    <fo:table-row>
	                        <fo:table-cell>
	                            <xsl:call-template name="addPETVCARFinding">
	                                <xsl:with-param name="pFinding" select="current()"/>
	                                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
	                            </xsl:call-template>
	                        </fo:table-cell>
	                    </fo:table-row>
	                </fo:table-body>
	            </fo:table>
	        </xsl:if>
	    </xsl:for-each>
    </xsl:if>
</xsl:template>

<xsl:template name="addPETVCARNStatistics"> <xsl:param name="pStatistics"/>
                                            <xsl:param name="pFindingsItem"/>
                                            <xsl:param name="pPosition"/>
                                            <xsl:param name="pN"/>

    <xsl:variable name="thisFindingsPos" select="count($pFindingsItem/preceding-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = '121070' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]) + 1"/>
    <xsl:variable name="allProcedureContexts" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C32C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="procedureContext" select="$allProcedureContexts[position() = $thisFindingsPos]"/>
<!-- (PVCAR-0100, 99GEMS, Exam) items in the corresponding (G-C32C, SRT, Procedure Context) item. -->
    <xsl:variable name="exams" select="$procedureContext/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="examNo" select="count($exams)"/>
<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$exams"/>
        </xsl:call-template>
    </xsl:variable>

<!-- (121071, DCM, Finding) items. -->
    <xsl:variable name="findingItems" select="$pFindingsItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121071' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- (112020, DCM, Response Evaluation) items. -->
    <xsl:variable name="responseEvaluationItems" select="$pFindingsItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112020' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>

<!-- (PVCAR-0100, 99GEMS, Exam) items. -->
    <xsl:variable name="allFindingExams" select="$findingItems/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="types" select="$allFindingExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D7FD' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>

    <xsl:variable name="firstNStats" select="$pStatistics[position() &lt;= $pN]"/>

    <fo:table table-layout="fixed" width="100%" space-before="4pt" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <xsl:if test="$types">
            <xsl:call-template name="addPETVCARFindingsCol">
                <xsl:with-param name="pExams" select="$exams"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:for-each select="$firstNStats">
            <xsl:choose>
                <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A100' and ConceptCodeSequence/Item/CodingSchemeDesignator = 'SRT'">
                    <xsl:call-template name="addPETVCARFindingsCol">
                        <xsl:with-param name="pExams" select="$exams"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A105' and ConceptCodeSequence/Item/CodingSchemeDesignator = 'SRT'">
<!-- RAS is displayed only once. -->
                </xsl:when>
                <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A116' and ConceptCodeSequence/Item/CodingSchemeDesignator = 'SRT'">
<!-- RAS is displayed only once. -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="addPETVCARFindingsCol">
                        <xsl:with-param name="pExams" select="$exams"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

<!-- Header labels -->
        <fo:table-header>
            <fo:table-row background-color="#{$P2}">
                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                        <xsl:value-of select="$vcarmsg/LBL_LESION/msg[@lang = $lang]"/>
                    </fo:block>
                </fo:table-cell>
                <xsl:if test="$types">
                    <xsl:call-template name="addPETVCARFindingsColHeader">
                        <xsl:with-param name="pHeader" select="$vcarmsg/LBL_STATUS_TYPE/msg[@lang = $lang]"/>
                        <xsl:with-param name="pColumnSpan" select="$examNo"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:for-each select="$firstNStats">
                    <xsl:choose>
                        <xsl:when test="current()/ConceptCodeSequence/Item/CodeValue = 'G-A100'">
                            <xsl:call-template name="addPETVCARFindingsColHeader">
                                <xsl:with-param name="pHeader" select="$vcarmsg/LBL_RAS/msg[@lang = $lang]"/>
                                <xsl:with-param name="pColumnSpan" select="$examNo"/>
                                <xsl:with-param name="pUnit" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-4286C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="current()/ConceptCodeSequence/Item/CodeValue = 'G-A105'">
                        </xsl:when>
                        <xsl:when test="current()/ConceptCodeSequence/Item/CodeValue = 'G-A116'">
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="headerLabel">
                                <xsl:call-template name="addPETVCARCODEValue">
                                    <xsl:with-param name="pCodeItem" select="current()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="addPETVCARFindingsColHeader">
                                <xsl:with-param name="pHeader" select="$headerLabel"/>
                                <xsl:with-param name="pColumnSpan" select="$examNo"/>
                                <xsl:with-param name="pUnit" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-4286C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </fo:table-row>
        </fo:table-header>

        <fo:table-body>
    <!-- Exam dates -->
            <fo:table-row keep-with-next="always" background-color="#{$P12}">
                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                </fo:table-cell>
                <xsl:if test="$types">
                    <xsl:call-template name="addPETVCARExamDateCells">
                        <xsl:with-param name="pExams" select="$exams"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:for-each select="$firstNStats">
                    <xsl:choose>
                        <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A100'">
                            <xsl:call-template name="addPETVCARExamDateCells">
                                <xsl:with-param name="pExams" select="$exams"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A105'">
                        </xsl:when>
                        <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A116'">
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="addPETVCARExamDateCells">
                                <xsl:with-param name="pExams" select="$exams"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </fo:table-row>
            <xsl:for-each select="$findingItems">
    <!-- (112039, DCM, Tracking Identifier) item. -->
                <xsl:variable name="trackingID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112039' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (PVCAR-0100, 99GEMS, Exam) items. -->
                <xsl:variable name="findingExams" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <fo:table-row keep-together="always">
                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                        <fo:block hyphenate="true" language="{$lang}" text-align="center">
                            <xsl:choose>
                            <!-- If Summary row -->
                                <xsl:when test="string(number($trackingID/TextValue)) = 'NaN'">
                                    <xsl:call-template name="addValue">
                                        <xsl:with-param name="pCurrent" select="$trackingID"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:basic-link internal-destination="{concat($pFindingsItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition, 'Lesion', $trackingID/TextValue)}" color="blue">
                                        <fo:inline text-decoration="underline">
                                            <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="$trackingID"/>
                                            </xsl:call-template>
                                        </fo:inline>
                                    </fo:basic-link>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                    </fo:table-cell>
    <!-- (G-C284, SRT, Status) / (G-D7FD, SRT, Type) -->
                    <xsl:if test="$types">
                        <xsl:for-each select="$exams">
    <!-- Current (110180, DCM, Study Instance UID) item. -->
                            <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                            <xsl:variable name="borderWidth">
                                <xsl:call-template name="setBaselineBorderWidth">
                                    <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                                    <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="fontWeight">
                                <xsl:call-template name="setBaselineFontWeight">
                                    <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                                    <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
                                </xsl:call-template>
                            </xsl:variable>
        <!-- Select those (PVCAR-0100, 99GEMS, Exam) items, which has the same Study Instance UID. -->
                            <xsl:variable name="findingExamWithUID" select="$findingExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '110180' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/UID = $curStudyUID/UID]"/>
        <!-- (G-C284, SRT, Status) item. -->
                            <xsl:variable name="status" select="$findingExamWithUID/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C284' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        <!-- (G-D7FD, SRT, Type) item. -->
                            <xsl:variable name="type" select="$findingExamWithUID/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D7FD' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="{$borderWidth}" border-bottom-width="thin" border-end-width="{$borderWidth}">
                                <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                                <xsl:choose>
                <!-- If Summary row -->
                                    <xsl:when test="string(number($trackingID/TextValue)) = 'NaN'">
                                        <xsl:text>-</xsl:text>
                                    </xsl:when>
                <!-- (G-D2FC, SRT, Accepted) or (PVCAR-0005, 99GEMS, Rejected) -->
                                    <xsl:when test="($status/ConceptCodeSequence/Item/CodeValue = 'G-D2FC' and $status/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT) or ($status/ConceptCodeSequence/Item/CodeValue = 'PVCAR-0005' and $status/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS)">
                                        <xsl:call-template name="addPETVCARFindingType">
                                            <xsl:with-param name="pType" select="$type"/>
                                        </xsl:call-template>
                                    </xsl:when>
                <!-- (PVCAR-0007, 99GEMS, Not Reviewed) -->
                                    <xsl:when test="$status/ConceptCodeSequence/Item/CodeValue = 'PVCAR-0007' and $status/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$status"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>-</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                </fo:block>
                            </fo:table-cell>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each select="$firstNStats">
                        <xsl:choose>
                            <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A100'">
                                <xsl:call-template name="addPETVCARRAS">
                                    <xsl:with-param name="pExams" select="$exams"/>
                                    <xsl:with-param name="pFindingExams" select="$findingExams"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A105'">
            <!-- RAS is displayed only once. -->
                            </xsl:when>
                            <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A116'">
            <!-- RAS is displayed only once. -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="addPETVCARStatisticsValue">
                                    <xsl:with-param name="pExams" select="$exams"/>
                                    <xsl:with-param name="pFindingExams" select="$findingExams"/>
                                    <xsl:with-param name="pStatDesc" select="current()"/>
                                    <xsl:with-param name="pResponseEvaluation" select="$responseEvaluationItems"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </fo:table-row>
            </xsl:for-each>
        </fo:table-body>
    </fo:table>

    <xsl:variable name="remainingStats" select="$pStatistics[position() &gt; $pN]"/>
<!-- Recursive call for remaining items. -->
    <xsl:if test="count($remainingStats) != 0">
        <xsl:call-template name="addPETVCARNStatistics">
            <xsl:with-param name="pStatistics" select="$remainingStats"/>
            <xsl:with-param name="pFindingsItem" select="$pFindingsItem"/>
            <xsl:with-param name="pPosition" select="$pPosition"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>


<!-- ####################################################################################################
    Template:       addPETVCARStatisticsValue
    Description:    Adds statistics value selecting cell response and color.
    Parameters:
-->
<xsl:template name="addPETVCARStatisticsValue"> <xsl:param name="pExams"/>
                                                <xsl:param name="pFindingExams"/>
                                                <xsl:param name="pStatDesc"/>
                                                <xsl:param name="pResponseEvaluation"/>

    <xsl:variable name="statUnit" select="$pStatDesc/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-4286C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$pExams"/>
        </xsl:call-template>
    </xsl:variable>
<!-- Select those (PVCAR-0100, 99GEMS, Exam) items, which has the same baseline Study Instance UID. -->
    <xsl:variable name="findingExamWithBaselineUID" select="$pFindingExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '110180' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/UID = $baselineStudyInstanceUID]"/>

    <xsl:for-each select="$pExams">
        <xsl:variable name="curPosition" select="position()"/>
<!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <xsl:variable name="borderWidth">
            <xsl:call-template name="setBaselineBorderWidth">
                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="fontWeight">
            <xsl:call-template name="setBaselineFontWeight">
                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
            </xsl:call-template>
        </xsl:variable>
<!-- Select those (PVCAR-0100, 99GEMS, Exam) items, which has the same Study Instance UID. -->
        <xsl:variable name="findingExamWithUID" select="$pFindingExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '110180' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/UID = $curStudyUID/UID]"/>
        <xsl:variable name="currentStatItem" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = $pStatDesc/ConceptCodeSequence/Item/CodeValue and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $pStatDesc/ConceptCodeSequence/Item/CodingSchemeDesignator]"/>
        <xsl:variable name="response" select="$currentStatItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-21358' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]/TextValue"/>
        <xsl:variable name="responseDesc">
            <xsl:call-template name="selectResponseDescription">
                <xsl:with-param name="pResponseEvaluation" select="$pResponseEvaluation"/>
                <xsl:with-param name="pResponse" select="$response"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="cellColor">
            <xsl:call-template name="selectResponseColor">
                <xsl:with-param name="pResponseEvaluation" select="$pResponseEvaluation"/>
                <xsl:with-param name="pResponse" select="$response"/>
            </xsl:call-template>
        </xsl:variable>
        <fo:table-cell display-align="center" background-color="#{$cellColor}" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="{$borderWidth}" border-bottom-width="thin" border-end-width="{$borderWidth}">
            <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                <xsl:choose>
                    <xsl:when test="$currentStatItem">
                        <xsl:choose>
                            <xsl:when test="$currentStatItem/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue = $statUnit/ConceptCodeSequence/Item/CodeValue and $currentStatItem/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator = $statUnit/ConceptCodeSequence/Item/CodingSchemeDesignator">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$currentStatItem"/>
                                    <xsl:with-param name="pUnit" select="'none'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$currentStatItem/ValueType_TEXT or $currentStatItem/ValueType = 'TEXT'">
                                <xsl:choose>
                                    <xsl:when test="$currentStatItem/TextValue = 'infinity' or $currentStatItem/TextValue = 'INFINITY'">
                                        <fo:inline font-family="Symbol" font-weight="normal"><xsl:value-of select="$VALUE_INFINITY"/></fo:inline>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$currentStatItem"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
    <!-- Unit of this statistics doesn't match the unit defined in the header description for this statistics. -->
                            <xsl:otherwise>
                                <xsl:value-of select="$VALUE_NOT_AVAILABLE"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>-</xsl:otherwise>
                </xsl:choose>
            </fo:block>
        </fo:table-cell>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addRAS
    Description:    Adds RAS coordinates.
    Parameters:
        pBaseline :
-->
<xsl:template name="addPETVCARRAS"> <xsl:param name="pExams"/>
                                    <xsl:param name="pFindingExams"/>

<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$pExams"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="$pExams">
<!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <xsl:variable name="borderWidth">
            <xsl:call-template name="setBaselineBorderWidth">
                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="fontWeight">
            <xsl:call-template name="setBaselineFontWeight">
                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
            </xsl:call-template>
        </xsl:variable>
<!-- Select those (PVCAR-0100, 99GEMS, Exam) items, which has the same Study Instance UID. -->
        <xsl:variable name="findingExamWithUID" select="$pFindingExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '110180' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/UID = $curStudyUID/UID]"/>
<!-- (G-A100, SRT, Right) item. -->
        <xsl:variable name="r" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'G-A100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
<!-- (G-A105, SRT, Anterior) item. -->
        <xsl:variable name="a" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'G-A105' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
<!-- (G-A116, SRT, Superior) item. -->
        <xsl:variable name="s" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'G-A116' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="{$borderWidth}" border-bottom-width="thin" border-end-width="{$borderWidth}">
            <xsl:choose>
                <xsl:when test="$r and $a and $s">
                    <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$r"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                    </fo:block>
                    <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$a"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                    </fo:block>
                    <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$s"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                    </fo:block>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">-</fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:table-cell>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addGuidelines
    Description:    Display guidelines for tumor response evaluation.
    Parameters:
        pResponseEvaluation  :
-->
<xsl:template name="addPETVCARGuidelines"> <xsl:param name="pResponseEvaluation"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <xsl:for-each select="$pResponseEvaluation/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-21358' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]">
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-column column-width="proportional-column-width(4)"/>
        </xsl:for-each>
        <fo:table-body>
            <fo:table-row>
                <xsl:for-each select="$pResponseEvaluation/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-21358' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]">
                    <xsl:variable name="id" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '125010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                    <xsl:variable name="description" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:variable name="color" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <fo:table-cell background-color="#{$color/TextValue}"/>
                    <fo:table-cell padding-left="2pt">
                        <fo:block>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$id"/>
                            </xsl:call-template>
                            <xsl:text>: </xsl:text>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$description"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                </xsl:for-each>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<xsl:template name="setBaselineBorderWidth"> <xsl:param name="pBaselineStudyInstanceUID"/>
                                             <xsl:param name="pStudyUID"/>
    <xsl:choose>
        <xsl:when test="$pBaselineStudyInstanceUID = $pStudyUID/UID">medium</xsl:when>
        <xsl:otherwise>thin</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="setBaselineFontWeight"> <xsl:param name="pBaselineStudyInstanceUID"/>
                                            <xsl:param name="pStudyUID"/>
    <xsl:choose>
        <xsl:when test="$pBaselineStudyInstanceUID = $pStudyUID/UID">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARFinding
    Description:    Add detailed Finding content item.
    Parameters:
        pFinding :  (121071, DCM, Finding) content item
-->
<xsl:template name="addPETVCARFinding"> <xsl:param name="pFinding"/>
                                        <xsl:param name="pBaselineStudyInstanceUID"/>

<!-- (PVCAR-0100, 99GEMS, Exam) items. -->
    <xsl:variable name="findingExams" select="$pFinding/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(8)"/>
    <!-- (G-D802, SRT, Date) -->
        <xsl:variable name="examDate" select="$findingExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        <xsl:variable name="allImages" select="$findingExams/ContentSequence/Item[ValueType = 'IMAGE' or ValueType_IMAGE = 'IMAGE']"/>
        <fo:table-header>
            <fo:table-row background-color="#{$P2}">
                <fo:table-cell border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                    <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                        <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                        <xsl:value-of select="$allImages/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-header>
        <fo:table-body>
            <xsl:for-each select="$findingExams">
                <xsl:sort select="position()" data-type="number" order="descending"/>
    <!-- Current (110180, DCM, Study Instance UID) item. -->
                <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <xsl:variable name="images" select="current()/ContentSequence/Item[ValueType = 'IMAGE' or ValueType_IMAGE = 'IMAGE']"/>
                <xsl:variable name="comment" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <xsl:variable name="commentHasContent">
                    <xsl:call-template name="hasContent">
                        <xsl:with-param name="pItems" select="$comment"/>
                    </xsl:call-template>
                </xsl:variable>
                <fo:table-row>
                    <xsl:variable name="fontWeight">
                        <xsl:call-template name="setBaselineFontWeight">
                            <xsl:with-param name="pBaselineStudyInstanceUID" select="$pBaselineStudyInstanceUID"/>
                            <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
                        </xsl:call-template>
                    </xsl:variable>
    <!-- Current (G-D802, SRT, Date) item. -->
                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                        <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="left">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                        <fo:block font-weight="{$fontWeight}" hyphenate="true" language="{$lang}" text-align="center">
                            <xsl:call-template name="addImageCaptures">
                                <xsl:with-param name="pImages" select="$images"/>
                            </xsl:call-template>
                        </fo:block>
    <!-- (121106, DCM, Comment) -->
                        <xsl:if test="$commentHasContent = 'true'">
                        <fo:block font-weight="bold" hyphenate="true" language="{$lang}" text-align="left">
                            <xsl:value-of select="concat($comment/ConceptNameCodeSequence/Item/CodeMeaning, ':')"/>
                        </fo:block>
                        <fo:block hyphenate="true" language="{$lang}" text-align="left">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$comment"/>
                            </xsl:call-template>
                        </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
            </xsl:for-each>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARImageCapture
    Description:    Add one image optionally with name and comment.
    Parameters:
        pImage   :  Image item.
-->
<xsl:template name="addPETVCARImageCapture"> <xsl:param name="pImage"/>
                                             <xsl:param name="pWithName" select="'true'"/>
                                             <xsl:param name="pWithComment" select="'true'"/>

<!-- (G-C27A, SRT, View) -->
    <xsl:variable name="view" select="$pImage/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C27A' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:if test="$pWithName = 'true'">
        <fo:block text-align="center" background-color="#{$P2}" hyphenate="true" language="{$lang}">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$view"/>
            </xsl:call-template>
        </fo:block>
    </xsl:if>
<!-- Image -->
    <fo:block text-align="center">
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$pImage"/>
        </xsl:call-template>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARGeneralImages
    Description:    Adds General Images.
    Parameters:
        pItem    :  (VV-024, 99GEMS, General Images) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPETVCARGeneralImages"> <xsl:param name="pItem"/>
                                              <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:variable name="images" select="$pItem/ContentSequence/Item[ValueType = 'IMAGE' or ValueType_IMAGE = 'IMAGE']"/>
            <xsl:variable name="manual" select="$images[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D221' and (ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED or ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT)]"/>
            <xsl:variable name="automatic" select="$images[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D231' and (ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED or ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT)]"/>
            <xsl:if test="($manual and $tp/Images/@manual = 'true') or ($automatic and $tp/Images/@automatic = 'true')">
            <fo:table-row>
                <fo:table-cell>
                <xsl:call-template name="addImageCaptures">
                    <xsl:with-param name="pImages" select="$images"/>
                </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARConclusions
    Description:    Adds Conclusions for each exam.
    Parameters:
        pItem    :  (121076, DCM, Conclusions) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPETVCARConclusions"> <xsl:param name="pItem"/>
                                            <xsl:param name="pPosition"/>

    <xsl:variable name="thisConclusionsPos" select="count($pItem/preceding-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = '121076' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]) + 1"/>
    <xsl:variable name="allProcedureContexts" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C32C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="procedureContext" select="$allProcedureContexts[position() = $thisConclusionsPos]"/>
<!-- (PVCAR-0100, 99GEMS, Exam) items in the corresponding (G-C32C, SRT, Procedure Context) item. -->
    <xsl:variable name="exams" select="$procedureContext/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$exams"/>
        </xsl:call-template>
    </xsl:variable>
    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:for-each select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121077' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]">
                <xsl:sort select="position()" data-type="number" order="descending"/>
    <!-- Current (110180, DCM, Study Instance UID) item. -->
                <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <fo:table-row>
                    <xsl:variable name="fontWeight">
                        <xsl:call-template name="setBaselineFontWeight">
                            <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                            <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <fo:table-cell display-align="center">
                        <fo:block font-weight="{$fontWeight}" font-size="{$heading2FontSize}pt" hyphenate="true" language="{$lang}" text-align="left">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            </xsl:call-template>
                        </fo:block>
                        <fo:block hyphenate="true" language="{$lang}" text-align="left" space-after="4pt">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </xsl:for-each>
        </fo:table-body>
    </fo:table>
</xsl:template>

</xsl:stylesheet>
