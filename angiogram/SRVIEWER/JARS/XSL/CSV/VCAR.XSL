<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    VCAR.XSL - PETVCAR specific XSLT rules for SR to CSV transformation.
    @author raczatt
    @date Jul 11, 2007
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- ####################################################################################################
    Template:       addPETVCARContentItem
    Description:    Add content item to report.
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
            <xsl:call-template name="addPETVCARFindings">
                <xsl:with-param name="pItem" select="$pItem"/>
                <xsl:with-param name="pPosition" select="$pPosition"/>
            </xsl:call-template>
        </xsl:when>
    <!-- (121076, DCM, Conclusions) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121076' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
            <xsl:call-template name="addPETVCARConclusions">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARProcedureContext
    Description:    Adds Procedure context.
    Parameters:
        pItem    :  (G-C32C, SRT, Procedure Context) content item
-->
<xsl:template name="addPETVCARProcedureContext"> <xsl:param name="pItem"/>

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
    <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$patientHeight/ConceptNameCodeSequence/Item/CodeMeaning"/>
    <xsl:text> / </xsl:text>
    <xsl:value-of select="$patientWeight/ConceptNameCodeSequence/Item/CodeMeaning"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_TRACER/msg[@lang = $lang]"/>
    <xsl:text> / </xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_RADIONUCLIDE/msg[@lang = $lang]"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_METABOLIZATION_TIME/msg[@lang = $lang]"/>
    <!--xsl:text> / </xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_METABOLIZATION_TIME_DIFFERENCE_TO_BASELINE/msg[@lang = $lang]"/-->
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_INJECTED_VOLUME/msg[@lang = $lang]"/>
    <xsl:text> / </xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_INJECTED_DOSE/msg[@lang = $lang]"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_BLOOD_GLUCOSE_LEVEL/msg[@lang = $lang]"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$vcarmsg/LBL_REF_SUV_LEVEL/msg[@lang = $lang]"/>
    <xsl:value-of select="$LF"/>

    <xsl:for-each select="$exams">
        <xsl:sort select="position()" data-type="number" order="descending"/>
<!-- Current (PVCAR-0100, 99GEMS, Exam) item. -->
        <xsl:variable name="curExam" select="current()"/>
<!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- (PVCAR-0010, 99GEMS, PET Context) -->
        <xsl:variable name="petContexts" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        <xsl:for-each select="$petContexts">
    <!-- (123001, DCM, Radiopharmaceutical) -->
            <xsl:variable name="curRadiopharmaceutical" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123001' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- Current (G-D802, SRT, Date) and (G-D217, SRT, Interval) items. -->
            <xsl:text>"</xsl:text>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                <xsl:with-param name="pIsEditable" select="'false'"/>
            </xsl:call-template>
            <xsl:text> / </xsl:text>
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
            <xsl:text>",</xsl:text>
    <!-- (8302-2, LN, Patient Height) / (29463-7, LN, Patient Weight) -->
            <xsl:text>"</xsl:text>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8302-2' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
                <xsl:with-param name="pIsEditable" select="'false'"/>
            </xsl:call-template>
            <xsl:text> / </xsl:text>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$curExam/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '29463-7' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
                <xsl:with-param name="pIsEditable" select="'false'"/>
            </xsl:call-template>
            <xsl:text>",</xsl:text>
    <!-- (123001, DCM, Radiopharmaceutical) -->
            <xsl:text>"</xsl:text>
            <xsl:choose>
                <xsl:when test="$curRadiopharmaceutical/ConceptCodeSequence/Item/CodeValue = 'C-B1031' and $curRadiopharmaceutical/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                    <xsl:value-of select="$vcarmsg/LBL_FDG/msg[@lang = $lang]"/>
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
                    <xsl:value-of select="$vcarmsg/LBL_18F/msg[@lang = $lang]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$isotopeItem"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>",</xsl:text>
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
            <xsl:text>"</xsl:text>
            <xsl:if test="$injectionStartDateTime != '' and $acquisitionDateTime != ''">
                <xsl:call-template name="addMetabolizationTime">
                    <xsl:with-param name="pStart" select="$injectionStartDateTime"/>
                    <xsl:with-param name="pEnd" select="$acquisitionDateTime"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:text>",</xsl:text>
    <!-- (123005, DCM, Radiopharmaceutical Volume) -->
            <xsl:text>"</xsl:text>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123005' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
            <xsl:text> / </xsl:text>
    <!-- (123006, DCM, Radionuclide Total Dose) -->
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$curRadiopharmaceutical/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123006' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
            <xsl:text>",</xsl:text>
    <!-- (F-0194E, SRT, Blood Glucose Level) -->
            <xsl:text>"</xsl:text>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'F-0194E' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
            </xsl:call-template>
            <xsl:text>",</xsl:text>
    <!-- (PVCAR-0090, 99GEMS, "Reference SUV Mean") -->
            <xsl:text>"</xsl:text>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0090' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            </xsl:call-template>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$LF"/>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<xsl:template name="addPETVCARFindingsColHeader"> <xsl:param name="pHeader"/>
                                                  <xsl:param name="pUnit"/>
    <xsl:value-of select="$pHeader"/>
    <xsl:if test="$pUnit and ($pUnit/ConceptCodeSequence/Item/CodeValue != '1' or $pUnit/ConceptCodeSequence/Item/CodingSchemeDesignator != $CSD_UCUM)">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="$pUnit/ConceptCodeSequence/Item/CodeValue"/>
        <xsl:text>]</xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template name="addPETVCARExamDateCells"> <xsl:param name="pExams"/>

    <xsl:for-each select="$pExams">
        <xsl:variable name="curDate" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$curDate"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARFindings
    Description:    Adds Finding content item.
    Parameters:
        pItem    :  (121070, DCM, Findings) content item
-->
<xsl:template name="addPETVCARFindings"> <xsl:param name="pItem"/>

<!-- (R-40831, SRT, Measurement) items describing statistics and their corresponding units. -->
    <xsl:variable name="statisticsDescs" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="thisFindingsPos" select="count($pItem/preceding-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = '121070' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]) + 1"/>
    <xsl:variable name="allProcedureContexts" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C32C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="procedureContext" select="$allProcedureContexts[position() = $thisFindingsPos]"/>
<!-- (PVCAR-0100, 99GEMS, Exam) items in the corresponding (G-C32C, SRT, Procedure Context) item. -->
    <xsl:variable name="exams" select="$procedureContext/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (121071, DCM, Finding) items. -->
    <xsl:variable name="findingItems" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121071' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- (PVCAR-0100, 99GEMS, Exam) items. -->
    <xsl:variable name="allFindingExams" select="$findingItems/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (G-C284, SRT, Status) / (G-D7FD, SRT, Type) -->
    <xsl:variable name="types" select="$allFindingExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D7FD' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>

    <xsl:value-of select="$vcarmsg/LBL_LESION/msg[@lang = $lang]"/>
    <xsl:text>,</xsl:text>
    <xsl:if test="$types">
        <xsl:call-template name="addPETVCARFindingsColHeader">
            <xsl:with-param name="pHeader" select="$vcarmsg/LBL_STATUS_TYPE/msg[@lang = $lang]"/>
        </xsl:call-template>
        <xsl:for-each select="$exams">
            <xsl:text>,</xsl:text>
        </xsl:for-each>
    </xsl:if>
    <xsl:for-each select="$statisticsDescs">
        <xsl:choose>
            <xsl:when test="current()/ConceptCodeSequence/Item/CodeValue = 'G-A100'">
                <xsl:call-template name="addPETVCARFindingsColHeader">
                    <xsl:with-param name="pHeader" select="$vcarmsg/LBL_RAS/msg[@lang = $lang]"/>
                    <xsl:with-param name="pUnit" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-4286C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                </xsl:call-template>
                <xsl:for-each select="$exams">
                    <xsl:text>,</xsl:text>
                </xsl:for-each>
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
                    <xsl:with-param name="pUnit" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-4286C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                </xsl:call-template>
                <xsl:for-each select="$exams">
                    <xsl:text>,</xsl:text>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
    <xsl:value-of select="$LF"/>
<!-- Exam dates -->
    <xsl:text>,</xsl:text>
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
    <xsl:value-of select="$LF"/>

    <xsl:for-each select="$findingItems">
<!-- (112039, DCM, Tracking Identifier) item. -->
        <xsl:variable name="trackingID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112039' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- (PVCAR-0100, 99GEMS, Exam) items. -->
        <xsl:variable name="findingExams" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PVCAR-0100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$trackingID"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
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
                <xsl:text>,</xsl:text>
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
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:value-of select="$LF"/>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARStatisticsValue
    Description:    Adds statistics value selecting cell response and color.
    Parameters:
-->
<xsl:template name="addPETVCARStatisticsValue"> <xsl:param name="pExams"/>
                                                <xsl:param name="pFindingExams"/>
                                                <xsl:param name="pStatDesc"/>

    <xsl:variable name="statUnit" select="$pStatDesc/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-4286C' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:for-each select="$pExams">
<!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- Select those (PVCAR-0100, 99GEMS, Exam) items, which has the same Study Instance UID. -->
        <xsl:variable name="findingExamWithUID" select="$pFindingExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '110180' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/UID = $curStudyUID/UID]"/>
        <xsl:variable name="currentStatItem" select="$findingExamWithUID/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = $pStatDesc/ConceptCodeSequence/Item/CodeValue and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $pStatDesc/ConceptCodeSequence/Item/CodingSchemeDesignator]"/>
        <xsl:choose>
            <xsl:when test="$currentStatItem">
                <xsl:choose>
                    <xsl:when test="$currentStatItem/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue = $statUnit/ConceptCodeSequence/Item/CodeValue and $currentStatItem/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator = $statUnit/ConceptCodeSequence/Item/CodingSchemeDesignator">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$currentStatItem"/>
                    <!-- Don't use the default pattern as it may contain ',' as thousands separator, that would mess up the CSV format. -->
                            <xsl:with-param name="pPattern" select="'0.0'"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$currentStatItem/ValueType_TEXT or $currentStatItem/ValueType = 'TEXT'">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$currentStatItem"/>
                        </xsl:call-template>
                    </xsl:when>
    <!-- Unit of this statistics doesn't match the unit defined in the header description for this statistics. -->
                    <xsl:otherwise>
                        <xsl:value-of select="$VALUE_NOT_AVAILABLE"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
        </xsl:choose>
        <xsl:text>,</xsl:text>
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
<!-- Calculate % value change for (PVCAR-0110, 99GEMS, SUV Max). -->
        <xsl:choose>
            <xsl:when test="$r and $a and $s">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$r"/>
                    <xsl:with-param name="pPattern" select="'0.0'"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
                <xsl:text> | </xsl:text>
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$a"/>
                    <xsl:with-param name="pPattern" select="'0.0'"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
                <xsl:text> | </xsl:text>
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$s"/>
                    <xsl:with-param name="pPattern" select="'0.0'"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
        </xsl:choose>
        <xsl:text>,</xsl:text>
    </xsl:for-each>
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
    <xsl:for-each select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121077' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]">
        <xsl:sort select="position()" data-type="number" order="descending"/>
    <!-- Current (110180, DCM, Study Instance UID) item. -->
        <xsl:variable name="curStudyUID" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- Current (G-D802, SRT, Date) item. -->
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        </xsl:call-template>
        <xsl:value-of select="$LF"/>
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="current()"/>
        </xsl:call-template>
        <xsl:value-of select="$LF"/>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
