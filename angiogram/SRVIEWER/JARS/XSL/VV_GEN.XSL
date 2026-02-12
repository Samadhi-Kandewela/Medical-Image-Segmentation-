<?xml version="1.0" encoding="utf-8"?>
<!-- ####################################################################################################
    Copyright (c) 2004 GE Healthcare

    VV_GEN.XSL     :    Common XSLT templates for Volume Viewer applications.

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:date="http://exslt.org/dates-and-times"
                              extension-element-prefixes="date">

<xsl:import href="DATE/DIFF.XSL"/>

<!-- ####################################################################################################
    Template:       addContainerName
    Description:    Adds the TextValue of child with CodeValue VV-008 in $CSD_GEMS and the abbreviation
                    if exists or the CodeMeaning of the content item otherwise.
    Parameters:
        pItem :
-->
<xsl:template name="addContainerName"> <xsl:param name="pItem"/>

    <xsl:variable name="name" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:choose>
        <xsl:when test="$name">
            <xsl:value-of select="$name/TextValue"/>
            <xsl:variable name="abbreviation" select="$name/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-009' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:if test="$abbreviation/TextValue and $abbreviation/TextValue != ''">
                (<xsl:value-of select="$abbreviation/TextValue"/>)
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNumWithPrecision
    Description:    Adds the NUM item with the corresponding precision child if exists.
    Parameters:
        pNum :
-->
<xsl:template name="addNumWithPrecision"> <xsl:param name="pNum"/>

    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pNum"/>
    </xsl:call-template>
<!-- (R-00363, SNM3, +/- range of measurement) -->
    <xsl:variable name="precision" select="$pNum/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-00363' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:if test="$precision">
        <xsl:text> ± </xsl:text>
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$precision"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addImageCaptures
    Description:    Adds image captures based on manual / automatic template setting.
    Parameters:
        pImages   :  Image Capture node-set.
        pN        :  # of columns images displayed across.
-->
<xsl:template name="addImageCaptures"> <xsl:param name="pImages"/>
                                       <xsl:param name="pN" select="$imgColumns"/>
                                       <xsl:param name="pWithName" select="'true'"/>
                                       <xsl:param name="pWithComment" select="'true'"/>

<!-- Automatic images -->
    <xsl:variable name="automatic" select="$pImages[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D231' and (ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED or ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT)]"/>
    <xsl:if test="$automatic and $tp/Images/@automatic = 'true'">
        <xsl:call-template name="addImages">
            <xsl:with-param name="pImages" select="$automatic"/>
            <xsl:with-param name="pN" select="$pN"/>
            <xsl:with-param name="pWithName" select="$pWithName"/>
            <xsl:with-param name="pWithComment" select="$pWithComment"/>
        </xsl:call-template>
    </xsl:if>
<!-- Manual images -->
    <xsl:variable name="manual" select="$pImages[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D221' and (ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED or ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT)]"/>
    <xsl:if test="$manual and $tp/Images/@manual = 'true'">
        <xsl:call-template name="addImages">
            <xsl:with-param name="pImages" select="$manual"/>
            <xsl:with-param name="pN" select="$pN"/>
            <xsl:with-param name="pWithName" select="$pWithName"/>
            <xsl:with-param name="pWithComment" select="$pWithComment"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       sumNoduleVolumes
    Description:    Calculates total nodule volumes in mm3.
    Parameters:
        pVolumes :  (G-D705, SNM3, Volume) NUM items.
-->
<xsl:template name="sumNoduleVolumes"> <xsl:param name="pVolumes"/>
                                       <xsl:param name="pSum" select="'0'"/>

    <xsl:choose>
        <xsl:when test="$pVolumes">
            <xsl:variable name="firstVolume" select="$pVolumes[1]"/>
            <xsl:choose>
                <xsl:when test="$firstVolume/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue = 'cm3' and $firstVolume/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator = $CSD_UCUM">
                    <xsl:call-template name="sumNoduleVolumes">
                        <xsl:with-param name="pVolumes" select="$pVolumes[position() != 1]"/>
                        <xsl:with-param name="pSum" select="$pSum + $firstVolume/MeasuredValueSequence/Item/NumericValue * 1000"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="sumNoduleVolumes">
                        <xsl:with-param name="pVolumes" select="$pVolumes[position() != 1]"/>
                        <xsl:with-param name="pSum" select="$pSum + $firstVolume/MeasuredValueSequence/Item/NumericValue"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$pSum"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="addNoduleVolume"> <xsl:param name="pVolume"/>

<!-- Only mm3 and cm3 is used for nodule volumes. Precision is always to the nearest mm3. If the volume is reported in cm3 the precision is 3 decimal digits. -->
    <xsl:variable name="pattern">
        <xsl:choose>
            <xsl:when test="$pVolume/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue = 'mm3'">#,##0</xsl:when>
            <xsl:otherwise>#,##0.000</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pVolume"/>
        <xsl:with-param name="pPattern" select="$pattern"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addTotalNoduleVolume
    Description:    Adds total nodule volume.
    Parameters:
        $pTotal  :  Sum of nodule volumes.
-->
<xsl:template name="addTotalNoduleVolume"> <xsl:param name="pTotal"/>

    <xsl:choose>
        <xsl:when test="$pTotal &lt; 1000">
            <xsl:call-template name="formatNumericValue">
                <xsl:with-param name="pNum" select="$pTotal"/>
                <xsl:with-param name="pPattern" select="'#,##0'"/>
            </xsl:call-template>
            <xsl:text> mm3</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="formatNumericValue">
                <xsl:with-param name="pNum" select="$pTotal div 1000"/>
                <xsl:with-param name="pPattern" select="'#,##0.000'"/>
            </xsl:call-template>
            <xsl:text> cm3</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template name="addNoduleLungVolumeRate"> <xsl:param name="pTotalNoduleVol"/>
                                              <xsl:param name="pLungVol"/>

<!-- Change total nodule volume and lung volume to common unit: cm3. -->
    <xsl:variable name="totalNoduleVolume">
        <xsl:choose>
            <xsl:when test="$pTotalNoduleVol &lt; 1000">
                <xsl:value-of select="$pTotalNoduleVol div 1000"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pTotalNoduleVol"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="lungVolume">
        <xsl:choose>
            <xsl:when test="$pLungVol &lt; 1000">
                <xsl:value-of select="$pLungVol div 1000"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pLungVol"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="formatNumericValue">
        <xsl:with-param name="pNum" select="$totalNoduleVolume div $lungVolume"/>
        <xsl:with-param name="pPattern" select="'0.000%'"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addDoublingTime
    Description:    Formats doubling time to # year # day if it's > 2 years otherwise displays in days.
    Parameters:
        pVolumes :  (ALA-080, 99GEMS, Doubling Time) NUM items.
-->
<xsl:template name="addDoublingTime"> <xsl:param name="pDoubling"/>

    <xsl:variable name="unitCV" select="$pDoubling/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
    <xsl:variable name="unitCSD" select="$pDoubling/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator"/>
    <xsl:variable name="numVal" select="$pDoubling/MeasuredValueSequence/Item/NumericValue"/>
    <xsl:choose>
        <xsl:when test="$unitCV = 'd' and $unitCSD = $CSD_UCUM">
            <xsl:choose>
                <xsl:when test="$numVal &gt; 2 * 365">
                    <xsl:variable name="years" select="floor($numVal div 365)"/>
                    <xsl:variable name="days" select="$numVal - $years * 365"/>
                    <xsl:call-template name="formatNumericValue">
                        <xsl:with-param name="pNum" select="$years"/>
                        <xsl:with-param name="pPattern" select="'#,##0'"/>
                    </xsl:call-template>
                    <xsl:value-of select="concat(' ', $messagecatalog/LBL_YEAR/msg[@lang = $lang], ' ')"/>
                    <xsl:call-template name="formatNumericValue">
                        <xsl:with-param name="pNum" select="$days"/>
                        <xsl:with-param name="pPattern" select="'#,##0'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="formatNumericValue">
                        <xsl:with-param name="pNum" select="$numVal"/>
                        <xsl:with-param name="pPattern" select="'#,##0'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="concat(' ', $messagecatalog/LBL_DAY/msg[@lang = $lang])"/>
        </xsl:when>
        <xsl:otherwise>
            <!-- Doubling Time is not in days. -->
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addBSA
    Description:    Adds Body Surface Area from VV report or calculates.
    Parameters:
        pWeight : Value of weight
        pHeight : Value of height
-->
<xsl:template name="addBSA"> <xsl:param name="pWeight" select="$DICOM/PatientWeight"/>
                             <xsl:param name="pHeight" select="$DICOM/PatientSize"/>

    <xsl:variable name="preExamItem" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-020' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="bsaItem" select="$preExamItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8277-6' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
    <xsl:choose>
        <xsl:when test="$bsaItem">
            <xsl:variable name="bsaFormulaItem" select="$bsaItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8278-4' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$bsaItem"/>
                <xsl:with-param name="pIsEditable" select="'false'"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="$pWeight != '' and $pHeight != ''">
                <xsl:call-template name="calculateBSA">
                    <xsl:with-param name="pWeight" select="$pWeight"/>
                    <xsl:with-param name="pHeight" select="$pHeight"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- ====================================================================================================
    PETVCAR specific variables and templates
===================================================================================================== -->


<xsl:variable name="vcarmsg" select="document('VCARMSG.XML')/Messages"/>


<!-- Infinity symbol -->
<xsl:variable name="VALUE_INFINITY">&#8734;</xsl:variable>
<!-- N/A symbol -->
<xsl:variable name="VALUE_NOT_AVAILABLE"><xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/></xsl:variable>

<!-- ####################################################################################################
    Template:       selectBaselineUID
    Description:    Selects baseline Study Instance UID.
-->
<xsl:template name="selectBaselineUID"> <xsl:param name="pExams"/>
    <xsl:variable name="baselineExams" select="$pExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '121079' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- Baseline (PVCAR-0100, 99GEMS, Exam) item. -->
    <xsl:variable name="baselineExamItem" select="$baselineExams[1]"/>
<!-- Baseline (110180, DCM, Study Instance UID) item. -->
    <xsl:variable name="baselineStudyInstanceUIDItem" select="$baselineExamItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '110180' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:value-of select="$baselineStudyInstanceUIDItem/UID"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       selectBaselineDate
    Description:    Selects baseline date.
-->
<xsl:template name="selectBaselineDate"> <xsl:param name="pExams"/>
    <xsl:variable name="baselineExams" select="$pExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '121079' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
<!-- Baseline (PVCAR-0100, 99GEMS, Exam) item. -->
    <xsl:variable name="baselineExamItem" select="$baselineExams[1]"/>
<!-- Baseline (G-D802, SRT, Date) item. -->
    <xsl:variable name="baselineDateItem" select="$baselineExamItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D802' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:value-of select="$baselineDateItem/Date"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       selectResponseColor
    Description:    Selects color for the specified response.
    Parameters:
        pBaseline :
-->
<xsl:template name="selectResponseColor"> <xsl:param name="pResponseEvaluation"/>
                                          <xsl:param name="pResponse"/>

    <xsl:variable name="responseItems" select="$pResponseEvaluation/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-21358' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="responseItem" select="$responseItems[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '125010' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/TextValue = $pResponse]"/>
    <xsl:variable name="responseColorItem" select="$responseItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:choose>
        <xsl:when test="$responseColorItem">
            <xsl:value-of select="$responseColorItem/TextValue"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="'FFFFFF'"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       selectResponseDescription
    Description:    Selects color for the specified response.
    Parameters:
        pBaseline :
-->
<xsl:template name="selectResponseDescription"> <xsl:param name="pResponseEvaluation"/>
                                                <xsl:param name="pResponse"/>

    <xsl:variable name="responseItems" select="$pResponseEvaluation/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-21358' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="responseItem" select="$responseItems[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = '125010' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and ContentSequence/Item/TextValue = $pResponse]"/>
    <xsl:value-of select="$responseItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]/TextValue"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       addMetabolizationTime
    Description:    Calculate metabolization time i.e. the difference between
                    acquisition and injection start time.
    Parameters:
        pStart    :
        pEnd      :
-->
<xsl:template name="addMetabolizationTime"> <xsl:param name="pStart"/>
                                            <xsl:param name="pEnd"/>

    <xsl:variable name="metabolizationTime">
        <xsl:call-template name="date:difference">
            <xsl:with-param name="start" select="$pStart"/>
            <xsl:with-param name="end" select="$pEnd"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="starts-with($metabolizationTime, '-')">
        <xsl:text>-</xsl:text>
    </xsl:if>
<!-- Difference is returned in format PnDTnHnMnS. -->
    <xsl:variable name="ymdhms" select="substring-after($metabolizationTime, 'P')"/>
<!-- Date part: nD -->
    <xsl:variable name="ymd">
        <xsl:choose>
            <xsl:when test="contains($ymdhms, 'T')"><xsl:value-of select="substring-before($ymdhms, 'T')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$ymdhms"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="d">
        <xsl:choose>
            <xsl:when test="contains($ymd, 'M')">
                <xsl:value-of select="substring-before(substring-after($ymd, 'M'), 'D')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-before($ymd, 'D')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="day-hours">
        <xsl:choose>
            <xsl:when test="number($d)"><xsl:value-of select="$d * 24"/></xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

<!-- Time part: nHnMnS -->
    <xsl:variable name="hms" select="substring-after($ymdhms, 'T')"/>
    <xsl:variable name="h">
        <xsl:choose>
            <xsl:when test="contains($hms, 'H')"><xsl:value-of select="substring-before($hms, 'H')"/></xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ms">
        <xsl:choose>
            <xsl:when test="contains($hms, 'H')"><xsl:value-of select="substring-after($hms, 'H')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$hms"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="m">
        <xsl:choose>
            <xsl:when test="contains($ms, 'M')"><xsl:value-of select="substring-before($ms, 'M')"/></xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="s">
        <xsl:variable name="sec">
            <xsl:choose>
                <xsl:when test="contains($ms, 'M')"><xsl:value-of select="substring-after($ms, 'M')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$ms"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($sec, 'S')"><xsl:value-of select="substring-before($sec, 'S')"/></xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

<!-- Round second to minute. -->
    <xsl:variable name="min">
        <xsl:choose>
            <xsl:when test="number($s) and $s &gt;= 30"><xsl:value-of select="($m + 1) mod 60"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$m"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="hour">
        <xsl:choose>
            <xsl:when test="number($min) and $min != $m and $min = 0"><xsl:value-of select="$day-hours + $h + 1"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$day-hours + $h"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:choose>
        <xsl:when test="$hour &gt; 0">
            <xsl:value-of select="$hour"/><xsl:text> h </xsl:text>
        </xsl:when>
    </xsl:choose>
    <xsl:value-of select="$min"/><xsl:text> min</xsl:text>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARFindingType
    Description:    Displays accepted (T, N, M) or rejected finding type.
    Parameters:
        pType     :
-->
<xsl:template name="addPETVCARCODEValue"> <xsl:param name="pCodeItem"/>
    <xsl:variable name="mappingMsg" select="$vcarmsg/*[@cv = $pCodeItem/ConceptCodeSequence/Item/CodeValue and @csd = $pCodeItem/ConceptCodeSequence/Item/CodingSchemeDesignator]"/>
    <xsl:choose>
        <xsl:when test="$mappingMsg">
            <xsl:value-of select="$mappingMsg/msg[@lang = $lang]"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$pCodeItem/ConceptCodeSequence/Item/CodeMeaning"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPETVCARFindingType
    Description:    Displays accepted (T, N, M) or rejected finding type.
    Parameters:
        pType     :
-->
<xsl:template name="addPETVCARFindingType"> <xsl:param name="pType"/>
    <xsl:choose>
    <!-- (G-F150, SRT, T category) -->
        <xsl:when test="$pType/ConceptCodeSequence/Item/CodeValue = 'G-F150' and $pType/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
            <xsl:text>T</xsl:text>
        </xsl:when>
    <!-- (R-40030, SRT, N category) -->
        <xsl:when test="$pType/ConceptCodeSequence/Item/CodeValue = 'R-40030' and $pType/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
            <xsl:text>N</xsl:text>
        </xsl:when>
    <!-- (R-40031, SRT, M category) -->
        <xsl:when test="$pType/ConceptCodeSequence/Item/CodeValue = 'R-40031' and $pType/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
            <xsl:text>M</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="addPETVCARCODEValue">
                <xsl:with-param name="pCodeItem" select="$pType"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
