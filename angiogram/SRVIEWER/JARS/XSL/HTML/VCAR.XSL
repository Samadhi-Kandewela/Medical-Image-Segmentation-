<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    VCAR.XSL - PETVCAR specific XSLT rules for SR to XHTML transformation.
    @author raczatt
    @date Jul 11, 2007
-->


<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:date="http://exslt.org/dates-and-times"
                              extension-element-prefixes="date">

<!-- ####################################################################################################
    Template:       addPETVCARContentItem
    Description:    Add content item to report based on different cardiac protocols.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addPETVCARContentItem"> <xsl:param name="pItem"/>
                                            <xsl:param name="pPosition"/>

    <xsl:choose>
    <!-- (G-C32C, SRT, Procedure Context) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'G-C32C' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
            <xsl:call-template name="addPETVCARProcedureContext">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:when>
    <!-- (121070, DCM, Findings) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121070' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
            <xsl:variable name="responseEvaluation" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112020' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:if test="$responseEvaluation">
                <xsl:call-template name="addPETVCARGuidelines">
                    <xsl:with-param name="pResponseEvaluation" select="$responseEvaluation"/>
                </xsl:call-template>
                <br/>
            </xsl:if>
            <xsl:call-template name="addPETVCARFindings">
                <xsl:with-param name="pItem" select="$pItem"/>
                <xsl:with-param name="pPosition" select="$pPosition"/>
            </xsl:call-template>
        </xsl:when>
    <!-- (VV-024, 99GEMS, General Images) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-024' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
            <xsl:call-template name="addPETVCARGeneralImages">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:when>
    <!-- (121076, DCM, Conclusions) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121076' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
            <xsl:call-template name="addPETVCARConclusions">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:when>
    <!-- (PQ-0110, 99GEMS, Patient Questions) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
            <xsl:call-template name="addPatientQuestions">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="addItemWithGeneric">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCODEValue
    Description:    Overrides generic addCODEValue to remove ^ from Code Meaning.
    Parameters:
        pCurrent :  CODE content item
-->
<xsl:template name="addCODEValue"> <xsl:param name="pCurrent"/>
    <span title="{concat('(', $pCurrent/ConceptCodeSequence/Item/CodeValue, ', ', $pCurrent/ConceptCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/ConceptCodeSequence/Item/CodeMeaning, ')')}">
        <xsl:value-of select="translate($pCurrent/ConceptCodeSequence/Item/CodeMeaning, '^', '')"/>
    </span>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARProcedureContext
    Description:    Adds Procedure context.
    Parameters:
        pItem    :  (G-C32C, SRT, Procedure Context) content item
-->
<xsl:template name="addPETVCARProcedureContext"> <xsl:param name="pItem"/>

    <xsl:variable name="cellDefaultStyle">text-align: center; border-style: solid;</xsl:variable>
<!-- (PVCAR-0100, 99GEMS, Exam) items. -->
    <xsl:variable name="exams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- Baseline (110180, DCM, Study Instance UID) content item UID value. -->
    <xsl:variable name="baselineStudyInstanceUID">
        <xsl:call-template name="selectBaselineUID">
            <xsl:with-param name="pExams" select="$exams"/>
        </xsl:call-template>
    </xsl:variable>
    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
	    <xsl:if test="$rendering = 'xls'">
	        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
	    </xsl:if>
    <!-- (G-D802, SRT, Date) -->
        <xsl:variable name="examDate" select="$exams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <!-- (8302-2, LN, Patient Height) -->
        <xsl:variable name="patientHeight" select="$exams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8302-2' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
    <!-- (29463-7, LN, Patient Weight) -->
        <xsl:variable name="patientWeight" select="$exams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '29463-7' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
        <tr style="background-color: #{$P2}">
            <th style="width: 10%; text-align: left; border-style: solid; border-width: thin">
                <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="border-style: solid; border-width: thin">
                <xsl:value-of select="$patientHeight/ConceptNameCodeSequence/Item/CodeMeaning"/>
                <xsl:text> / </xsl:text>
                <xsl:value-of select="$patientWeight/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="border-style: solid; border-width: thin">
                <xsl:value-of select="$vcarmsg/LBL_TRACER/msg[@lang = $lang]"/>
                <xsl:text> / </xsl:text>
                <xsl:value-of select="$vcarmsg/LBL_RADIONUCLIDE/msg[@lang = $lang]"/>
            </th>
            <th style="border-style: solid; border-width: thin">
                <xsl:value-of select="$vcarmsg/LBL_METABOLIZATION_TIME/msg[@lang = $lang]"/>
                <!--xsl:text> / </xsl:text>
                <xsl:value-of select="$vcarmsg/LBL_METABOLIZATION_TIME_DIFFERENCE_TO_BASELINE/msg[@lang = $lang]"/-->
            </th>
            <th style="border-style: solid; border-width: thin">
                <xsl:value-of select="$vcarmsg/LBL_INJECTED_VOLUME/msg[@lang = $lang]"/>
                <xsl:text> / </xsl:text>
                <xsl:value-of select="$vcarmsg/LBL_INJECTED_DOSE/msg[@lang = $lang]"/>
            </th>
            <th style="border-style: solid; border-width: thin">
                <xsl:value-of select="$vcarmsg/LBL_BLOOD_GLUCOSE_LEVEL/msg[@lang = $lang]"/>
            </th>
            <th style="border-style: solid; border-width: thin">
                <xsl:value-of select="$vcarmsg/LBL_REF_SUV_LEVEL/msg[@lang = $lang]"/>
            </th>
        </tr>
        <xsl:for-each select="$exams">
            <xsl:sort select="position()" data-type="number" order="descending"/>
    <!-- Current (PVCAR-0100, 99GEMS, Exam) item. -->
            <xsl:variable name="curExam" select="current()"/>
    <!-- Current (110180, DCM, Study Instance UID) item. -->
            <xsl:variable name="curStudyUID" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- Current (110180, DCM, Study Instance UID) item. -->
            <xsl:variable name="durationToBaseline" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-7290' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <!-- (PVCAR-0010, 99GEMS, PET Context) -->
            <xsl:variable name="petContexts" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (PVCAR-0010, 99GEMS, PET Context) -->
            <xsl:variable name="petContextsNo" select="count($petContexts)"/>
            <xsl:for-each select="$petContexts">
        <!-- (123001, DCM, Radiopharmaceutical) -->
                <xsl:variable name="curRadiopharmaceutical" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123001' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <tr>
                    <xsl:variable name="baselineTooltip">
                        <xsl:choose>
                            <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                                <xsl:value-of select="$vcarmsg/LBL_BASELINE/msg[@lang = $lang]"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="leftCellStyle">
                        <xsl:choose>
                            <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                                <xsl:text>text-align: left; border-style: solid; font-weight: bold; border-width: medium thin medium medium</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>text-align: left; border-style: solid; border-width: thin</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="middleCellStyle">
                        <xsl:choose>
                            <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                                <xsl:value-of select="concat($cellDefaultStyle, ' font-weight: bold; border-width: medium thin medium thin;')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($cellDefaultStyle, ' border-width: thin;')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="rightCellStyle">
                        <xsl:choose>
                            <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                                <xsl:value-of select="concat($cellDefaultStyle, ' font-weight: bold; border-width: medium medium medium thin;')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($cellDefaultStyle, ' border-width: thin;')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
            <!-- Current (G-D802, SRT, Date) and (G-D217, SRT, Interval) items. -->
                    <xsl:if test="position() = 1">
                    <td style="{$leftCellStyle}" title="{$baselineTooltip}" rowspan="{$petContextsNo}">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                        <br/>
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
                    </td>
            <!-- (8302-2, LN, Patient Height) / (29463-7, LN, Patient Weight) -->
                    <td style="{$middleCellStyle}" title="{$baselineTooltip}" rowspan="{$petContextsNo}">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8302-2' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '29463-7' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </td>
                    </xsl:if>
                    <td style="{$middleCellStyle}" title="{$baselineTooltip}">
            <!-- (123001, DCM, Radiopharmaceutical) -->
                        <xsl:choose>
                            <xsl:when test="$curRadiopharmaceutical/ConceptCodeSequence/Item/CodeValue = 'C-B1031' and $curRadiopharmaceutical/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                                <span title="{concat('(', $curRadiopharmaceutical/ConceptCodeSequence/Item/CodeValue, ', ', $curRadiopharmaceutical/ConceptCodeSequence/Item/CodingSchemeDesignator, ', ', $curRadiopharmaceutical/ConceptCodeSequence/Item/CodeMeaning, ')')}">
                                    <xsl:value-of select="$vcarmsg/LBL_FDG/msg[@lang = $lang]"/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$curRadiopharmaceutical"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> / </xsl:text>
            <!-- (C-B1000, SRT, Diagnostic Radioisotope) -->
                        <xsl:variable name="isotopeItem" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'C-B1000' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                        <xsl:choose>
                            <xsl:when test="$isotopeItem/ConceptCodeSequence/Item/CodeValue = 'C-111A1' and $isotopeItem/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                                <span title="{concat('(', $isotopeItem/ConceptCodeSequence/Item/CodeValue, ', ', $isotopeItem/ConceptCodeSequence/Item/CodingSchemeDesignator, ', ', $isotopeItem/ConceptCodeSequence/Item/CodeMeaning, ')')}">
                                    <xsl:value-of select="$vcarmsg/LBL_18F/msg[@lang = $lang]"/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$isotopeItem"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                    <td style="{$middleCellStyle}" title="{$baselineTooltip}">
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
                    </td>
                    <td style="{$middleCellStyle}" title="{$baselineTooltip}">
            <!-- (123005, DCM, Radiopharmaceutical Volume) -->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123005' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
            <!-- (123006, DCM, Radionuclide Total Dose) -->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123006' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </td>
                    <td style="{$middleCellStyle}" title="{$baselineTooltip}">
            <!-- (F-0194E, SRT, Blood Glucose Level) -->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'F-0194E' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </td>
                    <td style="{$rightCellStyle}" title="{$baselineTooltip}">
            <!-- (PVCAR-0090, 99GEMS, "Reference SUV Mean") -->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0090' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:for-each>
        </xsl:for-each>
    </table>
</xsl:template>

<xsl:template name="addPETVCARFindingsColHeader"> <xsl:param name="pHeader"/>
                                                  <xsl:param name="pColumnSpan"/>
                                                  <xsl:param name="pUnit"/>
    <th style="text-align: center; border-style: solid; border-width: thin" colspan="{$pColumnSpan}">
        <xsl:value-of select="$pHeader"/>
        <xsl:if test="$pUnit and ($pUnit/ConceptCodeSequence/Item/CodeValue != '1' or $pUnit/ConceptCodeSequence/Item/CodingSchemeDesignator != $CSD_UCUM)">
            <br/>
            <span title="{concat('(', $pUnit/ConceptCodeSequence/Item/CodeValue, ', ', $pUnit/ConceptCodeSequence/Item/CodingSchemeDesignator, ', ', $pUnit/ConceptCodeSequence/Item/CodeMeaning, ')')}">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="$pUnit/ConceptCodeSequence/Item/CodeValue"/>
                <xsl:text>]</xsl:text>
            </span>
        </xsl:if>
    </th>
</xsl:template>

<xsl:template name="addPETVCARExamDateCells"> <xsl:param name="pExams"/>

    <xsl:variable name="cellDefaultStyle">text-align: center; border-style: solid;</xsl:variable>
    <xsl:for-each select="$pExams">
        <xsl:variable name="baseline" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121079' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <xsl:variable name="cellStyle">
            <xsl:choose>
                <xsl:when test="$baseline">
                    <xsl:value-of select="concat($cellDefaultStyle, ' font-weight: bold; border-width: medium medium thin medium;')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($cellDefaultStyle, ' border-width: thin;')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$baseline">
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
    <!-- Current (G-D802, SRT, Date) item. -->
        <xsl:variable name="curDateXSD">
            <xsl:call-template name="toXSDdate">
                <xsl:with-param name="pDate" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]/Date"/>
            </xsl:call-template>
        </xsl:variable>
        <td style="{$cellStyle}" title="{$title}">
            <xsl:call-template name="formatDate">
                <xsl:with-param name="pDate" select="$curDateXSD"/>
            </xsl:call-template>
        </td>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARFindings
    Description:    Adds Findings content item.
    Parameters:
        pItem    :  (121070, DCM, Findings) content item
-->
<xsl:template name="addPETVCARFindings"> <xsl:param name="pItem"/>
                                         <xsl:param name="pPosition"/>

<!-- (R-40831, SRT, Measurement) items describing statistics and their corresponding units. -->
    <xsl:variable name="statisticsDescs" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
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
<!-- (121071, DCM, Finding) items. -->
    <xsl:variable name="findingItems" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121071' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- (112020, DCM, Response Evaluation) items. -->
    <xsl:variable name="responseEvaluationItems" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112020' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- (PVCAR-0100, 99GEMS, Exam) items. -->
    <xsl:variable name="allFindingExams" select="$findingItems/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="types" select="$allFindingExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D7FD' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
	    <xsl:if test="$rendering = 'xls'">
	        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
	    </xsl:if>
        <xsl:variable name="cellDefaultStyle">text-align: center; border-style: solid;</xsl:variable>
        <tr style="background-color: #{$P2}">
            <th style="text-align: center; border-style: solid; border-width: thin">
                <xsl:value-of select="$vcarmsg/LBL_LESION/msg[@lang = $lang]"/>
            </th>
            <xsl:if test="$types">
                <xsl:call-template name="addPETVCARFindingsColHeader">
                    <xsl:with-param name="pHeader" select="$vcarmsg/LBL_STATUS_TYPE/msg[@lang = $lang]"/>
                    <xsl:with-param name="pColumnSpan" select="$examNo"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:for-each select="$statisticsDescs">
                <xsl:choose>
                    <xsl:when test="current()/ConceptCodeSequence/Item/CodeValue = 'G-A100'">
                        <xsl:call-template name="addPETVCARFindingsColHeader">
                            <xsl:with-param name="pHeader" select="$vcarmsg/LBL_RAS/msg[@lang = $lang]"/>
                            <xsl:with-param name="pColumnSpan" select="$examNo"/>
                            <xsl:with-param name="pUnit" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-4286C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="current()/ConceptCodeSequence/Item/CodeValue = 'G-A105'">
    <!-- RAS is displayed only once. -->
                    </xsl:when>
                    <xsl:when test="current()/ConceptCodeSequence/Item/CodeValue = 'G-A116'">
    <!-- RAS is displayed only once. -->
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
        </tr>
<!-- Exam dates -->
        <tr style="background-color: #{$P12}; font-size: {$small1FontSize}pt">
            <td style="text-align: center; border-style: solid; border-width: thin">
            </td>
            <xsl:if test="$types">
                <xsl:call-template name="addPETVCARExamDateCells">
                    <xsl:with-param name="pExams" select="$exams"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:for-each select="$statisticsDescs">
                <xsl:choose>
                    <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A100'">
                        <xsl:call-template name="addPETVCARExamDateCells">
                            <xsl:with-param name="pExams" select="$exams"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A105'">
    <!-- RAS is displayed only once. -->
                    </xsl:when>
                    <xsl:when test="ConceptCodeSequence/Item/CodeValue = 'G-A116'">
    <!-- RAS is displayed only once. -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="addPETVCARExamDateCells">
                            <xsl:with-param name="pExams" select="$exams"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </tr>
        <xsl:for-each select="$findingItems">
    <!-- (112039, DCM, Tracking Identifier) item. -->
            <xsl:variable name="trackingID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112039' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (PVCAR-0100, 99GEMS, Exam) items. -->
            <xsl:variable name="findingExams" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <tr>
                <td style="text-align: center; border-style: solid; border-width: thin">
                    <xsl:choose>
                    <!-- If Summary row -->
                        <xsl:when test="string(number($trackingID/TextValue)) = 'NaN'">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$trackingID"/>
                                <xsl:with-param name="pIsEditable" select="'false'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <a name="{concat(translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition, 'TableLesion', $trackingID/TextValue)}" href="{concat('#', translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition, 'Lesion', $trackingID/TextValue)}">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$trackingID"/>
                                <xsl:with-param name="pIsEditable" select="'false'"/>
                            </xsl:call-template>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
        <!-- (G-C284, SRT, Status) / (G-D7FD, SRT, Type) -->
                <xsl:if test="$types">
                    <xsl:for-each select="$exams">
                <!-- Current (110180, DCM, Study Instance UID) item. -->
                        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <!-- Select those (PVCAR-0100, 99GEMS, Exam) items, which has the same Study Instance UID. -->
                        <xsl:variable name="findingExamWithUID" select="$findingExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '110180' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/UID = $curStudyUID/UID]"/>
                <!-- (G-C284, SRT, Status) item. -->
                        <xsl:variable name="status" select="$findingExamWithUID/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C284' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                <!-- (G-D7FD, SRT, Type) item. -->
                        <xsl:variable name="type" select="$findingExamWithUID/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D7FD' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                        <xsl:variable name="cellStyle">
                            <xsl:choose>
                                <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                                    <xsl:value-of select="concat($cellDefaultStyle, ' font-weight: bold; border-width: thin medium thin medium;')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($cellDefaultStyle, ' border-width: thin;')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <td style="{$cellStyle}">
                            <xsl:choose>
                        <!-- If Summary row -->
                                <xsl:when test="string(number($trackingID/TextValue)) = 'NaN'">-</xsl:when>
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
                                <xsl:otherwise>-</xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </xsl:for-each>
                </xsl:if>
                <xsl:for-each select="$statisticsDescs">
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
            </tr>
        </xsl:for-each>
    </table>
    <br/>
    <xsl:if test="$DICOM/@templateGroup != 'PETVCAR' or $DICOM/@template != 'AWS'">
	    <xsl:for-each select="$findingItems">
	<!--(112039, DCM, Tracking Identifier) item.-->
	        <xsl:variable name="trackingID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112039' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <!-- If not the Summary row -->
	        <xsl:if test="string(number($trackingID/TextValue)) != 'NaN'">
	            <div>
	                <a name="{concat(translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition, 'Lesion', $trackingID/TextValue)}" href="{concat('#', translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition, 'TableLesion', $trackingID/TextValue)}" style="font-size: {$heading3FontSize}pt">
	                    <xsl:value-of select="concat($vcarmsg/LBL_LESION/msg[@lang = $lang], ' ', $trackingID/TextValue)"/>
	                </a>
	            </div>
	            <xsl:call-template name="addPETVCARFinding">
	                <xsl:with-param name="pFinding" select="current()"/>
	                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
	            </xsl:call-template>
	            <br/>
	        </xsl:if>
	    </xsl:for-each>
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
    <xsl:variable name="cellDefaultStyle">text-align: center; border-style: solid;</xsl:variable>
    <xsl:for-each select="$pExams">
<!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
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
        <xsl:variable name="cellStyle">
            <xsl:choose>
                <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                    <xsl:value-of select="concat($cellDefaultStyle, ' font-weight: bold; border-width: thin medium thin medium; background-color: #', $cellColor)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($cellDefaultStyle, ' border-width: thin; background-color: #', $cellColor)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <td style="{$cellStyle}">
            <xsl:if test="$response">
                <xsl:attribute name="title">
                    <xsl:value-of select="concat($response, ': ', $responseDesc)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$currentStatItem">
                    <xsl:choose>
                        <xsl:when test="$currentStatItem/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue = $statUnit/ConceptCodeSequence/Item/CodeValue and $currentStatItem/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator = $statUnit/ConceptCodeSequence/Item/CodingSchemeDesignator">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$currentStatItem"/>
                                <xsl:with-param name="pIsEditable" select="'false'"/>
                                <xsl:with-param name="pUnit" select="'none'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$currentStatItem/ValueType_TEXT or $currentStatItem/ValueType = 'TEXT'">
                            <xsl:choose>
                                <xsl:when test="$currentStatItem/TextValue = 'infinity' or $currentStatItem/TextValue = 'INFINITY'">
                                    <span style="font-weight: normal;" title="{$currentStatItem/ConceptNameCodeSequence/Item/CodeMeaning}">
                                        <xsl:value-of select="$VALUE_INFINITY"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="addValue">
                                        <xsl:with-param name="pCurrent" select="$currentStatItem"/>
                                        <xsl:with-param name="pIsEditable" select="'false'"/>
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
        </td>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARRAS
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
    <xsl:variable name="cellDefaultStyle">text-align: center; border-style: solid;</xsl:variable>
    <xsl:for-each select="$pExams">
<!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- Select those (PVCAR-0100, 99GEMS, Exam) items, which has the same Study Instance UID. -->
        <xsl:variable name="findingExamWithUID" select="$pFindingExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '110180' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/UID = $curStudyUID/UID]"/>
<!-- (G-A100, SRT, Right) item. -->
        <xsl:variable name="r" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'G-A100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
<!-- (G-A105, SRT, Anterior) item. -->
        <xsl:variable name="a" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'G-A105' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
<!-- (G-A116, SRT, Superior) item. -->
        <xsl:variable name="s" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'G-A116' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        <xsl:variable name="cellStyle">
            <xsl:choose>
                <xsl:when test="$baselineStudyInstanceUID = $curStudyUID/UID">
                    <xsl:value-of select="concat($cellDefaultStyle, ' font-weight: bold; border-width: thin medium thin medium;')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($cellDefaultStyle, ' border-width: thin;')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <td style="{$cellStyle}">
            <xsl:choose>
                <xsl:when test="$r and $a and $s">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$r"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                    <br/>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$a"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                    <br/>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$s"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>-</xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARGuidelines
    Description:    Display guidelines for tumor response evaluation.
    Parameters:
        pResponseEvaluation  :
-->
<xsl:template name="addPETVCARGuidelines"> <xsl:param name="pResponseEvaluation"/>

    <xsl:variable name="cellDefaultStyle">width: 5%;</xsl:variable>
    <table style="width: 100%;">
        <tr>
            <xsl:for-each select="$pResponseEvaluation/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-21358' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]">
                <xsl:variable name="id" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '125010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <xsl:variable name="description" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="color" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="style" select="concat($cellDefaultStyle, ' background-color: #', $color/TextValue)"/>
                <td style="{$style}"></td>
                <td style="width: 20%">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$id"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                    </xsl:call-template>
                    <xsl:text>: </xsl:text>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$description"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                    </xsl:call-template>
                </td>
            </xsl:for-each>
        </tr>
    </table>
</xsl:template>

<xsl:template name="setBaselineFontWeight"> <xsl:param name="pBaselineStudyInstanceUID"/>
                                            <xsl:param name="pStudyUID"/>
    <xsl:choose>
        <xsl:when test="$pBaselineStudyInstanceUID = $pStudyUID/UID">font-weight: bold</xsl:when>
        <xsl:otherwise>font-weight: normal</xsl:otherwise>
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
    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <!-- (G-D802, SRT, Date) -->
        <xsl:variable name="examDate" select="$findingExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        <xsl:variable name="allImages" select="$findingExams/ContentSequence/Item[ValueType = 'IMAGE' or ValueType_IMAGE = 'IMAGE']"/>
        <tr style="background-color: #{$P2}">
            <th style="width: 10%; text-align: left; border-style: solid; border-width: thin">
                <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 90%; border-style: solid; border-width: thin">
                <xsl:value-of select="$allImages/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
        </tr>

        <xsl:for-each select="$findingExams">
            <xsl:sort select="position()" data-type="number" order="descending"/>
    <!-- Current (110180, DCM, Study Instance UID) item. -->
            <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:variable name="fontWeight">
                <xsl:call-template name="setBaselineFontWeight">
                    <xsl:with-param name="pBaselineStudyInstanceUID" select="$pBaselineStudyInstanceUID"/>
                    <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
                </xsl:call-template>
            </xsl:variable>
            <tr>
    <!-- Current (G-D802, SRT, Date) item. -->
                <td style="width: 10%; text-align: left; border-style: solid; border-width: thin; {$fontWeight}">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                    </xsl:call-template>
                </td>
                <td style="width: 90%; text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addImageCaptures">
                        <xsl:with-param name="pImages" select="current()/ContentSequence/Item[ValueType = 'IMAGE' or ValueType_IMAGE = 'IMAGE']"/>
                    </xsl:call-template>
                    <xsl:variable name="comment" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                    <xsl:if test="$comment">
                    <div style="font-weight: bold;">
                        <xsl:value-of select="concat($comment/ConceptNameCodeSequence/Item/CodeMeaning, ':')"/>
                    </div>
                    <div>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$comment"/>
                        </xsl:call-template>
                    </div>
                    </xsl:if>
                </td>
            </tr>
        </xsl:for-each>
    </table>
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
        <div style="text-align: center; background-color: #{$P2}">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$view"/>
            </xsl:call-template>
        </div>
    </xsl:if>
<!-- Image -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pImage"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARGeneralImages
    Description:    Adds General Images.
    Parameters:
        pItem    :  (VV-024, 99GEMS, General Images) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPETVCARGeneralImages"> <xsl:param name="pItem"/>
    <xsl:variable name="images" select="$pItem/ContentSequence/Item[ValueType = 'IMAGE' or ValueType_IMAGE = 'IMAGE']"/>
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$images"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARConclusions
    Description:    Adds Conclusions for each exam.
    Parameters:
        pItem    :  (121076, DCM, Conclusions) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPETVCARConclusions"> <xsl:param name="pItem"/>

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
    <xsl:for-each select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121077' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]">
        <xsl:sort select="position()" data-type="number" order="descending"/>
    <!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <xsl:variable name="fontWeight">
            <xsl:call-template name="setBaselineFontWeight">
                <xsl:with-param name="pBaselineStudyInstanceUID" select="$baselineStudyInstanceUID"/>
                <xsl:with-param name="pStudyUID" select="$curStudyUID"/>
            </xsl:call-template>
        </xsl:variable>
    <!-- Current (G-D802, SRT, Date) item. -->
        <div style="font-size: {$heading2FontSize}pt; {$fontWeight}">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                <xsl:with-param name="pIsEditable" select="'false'"/>
            </xsl:call-template>
        </div>
        <div>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="current()"/>
            </xsl:call-template>
        </div>
        <xsl:if test="position() != last()"><br/></xsl:if>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
