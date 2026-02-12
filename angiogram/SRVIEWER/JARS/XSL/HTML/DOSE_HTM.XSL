<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2005 GE Healthcare

    DOSE_HTM.XSL   : Rules for adding Dose SR table format report sections to HTML:
                     - Header (logo, name, address),
                     - Patient demographics (name, weight, etc.)
                     - Observation context
                     - Physician signatures

    Author          :   Laszlo PECSY
    Last modified on:   Feb 13, 2014
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="SECT_HTM.XSL"/>

<!-- ####################################################################################################
    Template:       addSoftwareVersion
    Description:    Add SoftwareVersion tag to rendered report.
-->
<xsl:template name="addSoftwareVersion">
    <table border="0" width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <tr>
        <td style="width: 30%; text-align:left; vertical-align: top;">
            <b><xsl:value-of select="$messagecatalog/LBL_SOFTWARE_VERSION/msg[@lang = $lang]"/></b>
        </td>
        <td style="text-align:left; vertical-align: top;">
            <xsl:value-of select="$DICOM/SoftwareVersion"/>
        </td>
    </tr>
    </table>

</xsl:template>

<!-- ####################################################################################################
    Template:       processReportSections
    Description:    Process report sections.
    Parameters:
        pCurSectionPos :
-->
<xsl:template name="processReportSections"> <xsl:param name="pCurSectionPos"/>

    <!-- Software Version should be added before any report section!!! -->
    <xsl:if test="$DICOM/SoftwareVersion != ''">
        <xsl:call-template name="addSoftwareVersion"/>
    </xsl:if>

    <xsl:variable name="irradiationXRAYDoseEvents" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113706' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:variable name="accumulatedXRAYDoseDataItems" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113702' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:for-each select="$DICOM/ContentSequence/Item">
        <xsl:variable name="currPos" select="position()"/>
        <xsl:choose>
            <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = '113706' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and $DICOM/@dosesrTableMode = 'true'">
                <xsl:choose>
                    <xsl:when test="current() = $irradiationXRAYDoseEvents[1]">
                        <xsl:call-template name="addIrradiationXRAYDoseEvents">
                            <xsl:with-param name="xRAYDoseEvents" select="$irradiationXRAYDoseEvents"/>
                            <xsl:with-param name="pCurSectionPos" select="$pCurSectionPos"/>
                            <xsl:with-param name="pPosition" select="$currPos"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Irradiation X-Ray Dose Events should process only one time -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = '113702' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and $DICOM/@dosesrTableMode = 'true'">
                <xsl:choose>
                    <xsl:when test="current() = $accumulatedXRAYDoseDataItems[1]">
                        <xsl:call-template name="addAccumulatedXRAYDoseData">
                            <xsl:with-param name="accumulatedDoseData" select="$accumulatedXRAYDoseDataItems"/>
                            <xsl:with-param name="pCurSectionPos" select="$pCurSectionPos"/>
                            <xsl:with-param name="pPosition" select="$currPos"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Accumulated X-Ray Dose Data should process only one time -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = '121025' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                <!-- Patient Demographics are added by addPDSections template. -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="addContentItem">
                    <xsl:with-param name="pItem" select="current()"/>
                    <xsl:with-param name="pPosition" select="concat($pCurSectionPos, position())"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNUMValue
    Description:    Change unit of some values. Adds Code Meaning and "(CV, CSD, CM)" in tooltip.
    Parameters:
        pCurrent :  NUM content item
        pPattern :  Number format pattern
        pUnit    :  could be: none, cv, cm, special
-->
<xsl:template name="addNUMValue">
    <xsl:param name="pCurrent"/>
    <xsl:param name="pPattern"/>
    <xsl:param name="pUnit"/>

    <xsl:variable name="measureUnitCV" select="$pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
    <xsl:variable name="valueCV" select="$pCurrent/ConceptNameCodeSequence/Item/CodeValue"/>
    <xsl:variable name="valueCSD" select="$pCurrent/ConceptNameCodeSequence/Item/CodingSchemeDesignator"/>

    <span title="{concat('(', $pCurrent/ConceptNameCodeSequence/Item/CodeValue, ', ', $pCurrent/ConceptNameCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/ConceptNameCodeSequence/Item/CodeMeaning, '): ', $pCurrent/MeasuredValueSequence/Item/NumericValue, ' ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue)}">
        <xsl:choose>
            <!-- Total Fluoro Time, Total Acquisition Time -->
            <xsl:when test="$valueCSD=$CSD_DICOM and ($valueCV='113730' or $valueCV='113855')">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (s) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 's'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Calibration Uncertainty -->
            <xsl:when test="$valueCSD=$CSD_DICOM and ($valueCV='113763')">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (%) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != '%'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Positioner Primary Angle, Positioner Secondary Angle, Positioner Primary End Angle, Positioner Secondary End Angle,
                 Table Horizontal Rotation Angle, Table Head Tilt Angle -->
            <xsl:when test="$valueCSD=$CSD_DICOM and ($valueCV='112011' or $valueCV='112012' or $valueCV='113739' or $valueCV='113740' or $valueCV='113755' or $valueCV='113754')">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (deg) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 'deg'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Collimated Field Area -->
            <xsl:when test="$valueCSD=$CSD_DICOM and $valueCV='113790'">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (m2) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 'm2'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- X-Ray Filter Thickness Maximum, Table Longitudinal Position, Table Lateral Position, Table Height,
                 Table Longitudinal End Position, Table Lateral End Position, Table Height End Position, SID, SOD,  -->
            <xsl:when test="$valueCSD=$CSD_DICOM and ($valueCV='113773' or $valueCV='113751' or $valueCV='113752' or $valueCV='113753' or $valueCV='Cod010' or $valueCV='Cod011' or $valueCV='Cod012' or $valueCV='113750' or $valueCV='113748')">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (mm) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 'mm'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Patient Equivalent Thickness -->
            <xsl:when test="$valueCSD=$CSD_GEMS and $valueCV='INNOVA-106'">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (cm) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 'cm'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Pulse Rate -->
            <xsl:when test="$valueCSD=$CSD_DICOM and $valueCV='113773'">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard ({pulse}/s) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != '{pulse}/s'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- KVP -->
            <xsl:when test="$valueCSD=$CSD_DICOM and $valueCV='113733'">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (kV) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 'kV'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- X-Ray Tube Current -->
            <xsl:when test="$valueCSD=$CSD_DICOM and $valueCV='113734'">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (mA) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 'mA'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Pulse Width, Exposure Time -->
            <xsl:when test="$valueCSD=$CSD_DICOM and $valueCV='113734'">
                <xsl:choose>
                    <!-- If dosesrTableMode and the unit doesn't correspond to DICOM standard (ms) -->
                    <xsl:when test="$DICOM/@dosesrTableMode = 'true' and $measureUnitCV != 'ms'">
                        <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- DAP Total, Fluoro DAP Total, Acquisition DAP Total, DAP -->
            <xsl:when test="$valueCSD=$CSD_DICOM and ($valueCV='122130' or $valueCV='113722' or $valueCV='113726' or $valueCV='113727')">
                <xsl:choose>
                    <!-- Convert value to Gy.cm2 unit and put the new value with new unit (if necessary) -->
                    <xsl:when test="$measureUnitCV='Gy.m2' or $measureUnitCV='Gym2'">
                        <xsl:variable name="multipliedNum">
                            <xsl:call-template name="multiplyNumericValue">
                                <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                                <xsl:with-param name="pExponent" select="4"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$multipliedNum"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <xsl:if test="$pUnit = 'cv' or $pUnit = 'cm'">
                            <xsl:choose>
                                <xsl:when test="contains($measureUnitCV,'.')">
                                    <xsl:text> Gy.cm2</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text> Gycm2</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:when>
                    <!-- If the unit conversion isn't possible -->
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-- In case of dosesrTableMode put 'N/A' -->
                            <xsl:when test="$DICOM/@dosesrTableMode = 'true'">
                                <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                            </xsl:when>
                            <!-- Otherwise put the original value with original unit (if necessary) -->
                            <xsl:otherwise>
                                <xsl:call-template name="formatNumericValue">
                                    <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                                    <xsl:with-param name="pPattern" select="$pPattern"/>
                                </xsl:call-template>
                                <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Dose (RP) Total, Fluoro Dose (RP) Total, Acquisition Dose (RP) Total, Dose (RP) -->
            <xsl:when test="$valueCSD=$CSD_DICOM and ($valueCV='113738' or $valueCV='113725' or $valueCV='113728' or $valueCV='113729')">
                <xsl:choose>
                    <!-- Convert value to mGy unit and put the new value with new unit (if necessary) -->
                    <xsl:when test="$measureUnitCV='Gy'">
                        <xsl:variable name="multipliedNum">
                            <xsl:call-template name="multiplyNumericValue">
                                <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                                <xsl:with-param name="pExponent" select="3"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="formatNumericValue">
                            <xsl:with-param name="pNum" select="$multipliedNum"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                        <xsl:if test="$pUnit = 'cv' or $pUnit = 'cm'">
                            <xsl:text> mGy</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <!-- If the unit conversion isn't possible -->
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-- In case of dosesrTableMode put 'N/A' -->
                            <xsl:when test="$DICOM/@dosesrTableMode = 'true'">
                                <xsl:value-of select="$messagecatalog/LBL_NA/msg[@lang = $lang]"/>
                            </xsl:when>
                            <!-- Otherwise put the original value with original unit (if necessary) -->
                            <xsl:otherwise>
                                <xsl:call-template name="formatNumericValue">
                                    <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                                    <xsl:with-param name="pPattern" select="$pPattern"/>
                                </xsl:call-template>
                                <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Otherwise put the original value with original unit (if necessary) -->
            <xsl:otherwise>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
                    <xsl:with-param name="pPattern" select="$pPattern"/>
                </xsl:call-template>
                <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
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
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </span>
</xsl:template>

<!-- ####################################################################################################
    Template:       addIrradiationXRAYDoseEvents
    Description:    
    Parameters:
-->
<xsl:template name="addIrradiationXRAYDoseEvents">
    <xsl:param name="xRAYDoseEvents"/>
    <xsl:param name="pCurSectionPos"/>
    <xsl:param name="pPosition"/>

<!-- (113706, DCM, Irradiation Event X-Ray Data) items. -->
    <xsl:if test="$xRAYDoseEvents[1]/RelationshipType = 'CONTAINS'">
        <xsl:if test="$xRAYDoseEvents[1]/ConceptNameCodeSequence/Item/CodeMeaning">
            <h2><xsl:value-of select="$xRAYDoseEvents[1]/ConceptNameCodeSequence/Item/CodeMeaning"/></h2>
        </xsl:if>
    </xsl:if>

    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
        <xsl:if test="$rendering = 'xls'">
            <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
        </xsl:if>
    <!-- (111526, DCM, DateTime Started) -->
        <xsl:variable name="dateTimeStarted" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '111526' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (125203, DCM, Acquisition Protocol) -->
        <xsl:variable name="acquisitionProtocol" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '125203' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (122130, DCM, Dose Area Product) -->
        <xsl:variable name="dap" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122130' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113738, DCM, Dose (RP)) -->
        <xsl:variable name="doseRP" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113738' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113751, DCM, Table Longitudinal Position) -->
        <xsl:variable name="tableLongitPosition" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113751' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113752, DCM, Table Lateral Position) -->
        <xsl:variable name="tableLateralPosition" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113752' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113753, DCM, Table Height) -->
        <xsl:variable name="tableHeight" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113753' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113755, DCM, Table Horizontal Rotation Angle) -->
        <xsl:variable name="tableHorizRotAngle" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113755' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113754, DCM, Table Head Tilt Angle) -->
        <xsl:variable name="tableHeadTiltAngle" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113754' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (Cod010, DCM, Table Longitudinal End Position) -->
        <xsl:variable name="tableLongitEndPosition" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'Cod010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (Cod011, DCM, Table Lateral End Position) -->
        <xsl:variable name="tableLateralEndPosition" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'Cod011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (Cod012, DCM, Table Height End Position) -->
        <xsl:variable name="tableHeightEndPosition" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'Cod012' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (112011, DCM, Positioner Primary Angle) -->
        <xsl:variable name="positionerPriAngle" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (112012, DCM, Positioner Secondary Angle) -->
        <xsl:variable name="positionerSecAngle" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112012' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113739, DCM, Positioner Primary End Angle) -->
        <xsl:variable name="positionerPriEndAngle" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113739' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113740, DCM, Positioner Secondary End Angle) -->
        <xsl:variable name="positionerSecEndAngle" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113740' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113745, DCM, Patient Table Relationship) -->
        <xsl:variable name="patientTableRel" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113745' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (INNOVA-106, 99GEMS, Patient Equivalent Thickness) -->
        <xsl:variable name="patientEquivThick" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'INNOVA-106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (113750, DCM, Distance Source To Detector (SID)) -->
        <xsl:variable name="sid" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113750' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113748, DCM, Distance Source To Isocenter (SOD)) -->
        <xsl:variable name="sod" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113748' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113790, DCM, Collimated Field Area) -->
        <xsl:variable name="collimatedFieldArea" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113790' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113768, DCM, Number of Pulses) -->
        <xsl:variable name="numberOfPulses" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113768' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113791, DCM, Pulse Rate) -->
        <xsl:variable name="pulseRate" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113791' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113793, DCM, Pulse Width) -->
        <xsl:variable name="pulseWidth" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113793' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113733, DCM, KVP) -->
        <xsl:variable name="kvp" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113733' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113734, DCM, X-Ray Tube Current) -->
        <xsl:variable name="xRAYTubeCurrent" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113734' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113824, DCM, Exposure Time) -->
        <xsl:variable name="exposureTime" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113824' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (123014, DCM, Target Region) -->
        <xsl:variable name="targetRegion" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123014' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113773, DCM, Filter Thickness) -->
        <xsl:variable name="filterThickness" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113771' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113773' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113764, DCM, Acquisition Plane) -->
        <xsl:variable name="acquisitionPlane" select="$xRAYDoseEvents/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113764' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <tr bgcolor="#{$P2}">
            <xsl:if test="$dateTimeStarted">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$dateTimeStarted/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$acquisitionProtocol">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$acquisitionProtocol/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$dap">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$dap/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (Gy.cm2)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$doseRP">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$doseRP/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (mGy)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$tableLongitPosition">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableLongitPosition/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableLongitPosition/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$tableLateralPosition">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableLateralPosition/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableLateralPosition/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$tableHeight">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableHeight/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableHeight/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$tableHorizRotAngle">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableHorizRotAngle/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableHorizRotAngle/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$tableHeadTiltAngle">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableHeadTiltAngle/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableHeadTiltAngle/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$tableLongitEndPosition">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableLongitEndPosition/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableLongitEndPosition/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$tableLateralEndPosition">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableLateralEndPosition/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableLateralEndPosition/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$tableHeightEndPosition">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$tableHeightEndPosition/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$tableHeightEndPosition/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$positionerPriAngle">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$positionerPriAngle/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$positionerPriAngle/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$positionerSecAngle">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$positionerSecAngle/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$positionerSecAngle/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$positionerPriEndAngle">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$positionerPriEndAngle/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$positionerPriEndAngle/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$positionerSecEndAngle">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$positionerSecEndAngle/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$positionerSecEndAngle/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$patientTableRel">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$patientTableRel/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$patientEquivThick">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$patientEquivThick/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$patientEquivThick/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$sid">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$sid/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$sid/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$sod">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$sod/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$sod/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$collimatedFieldArea">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$collimatedFieldArea/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$collimatedFieldArea/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$numberOfPulses">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$numberOfPulses/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$pulseRate">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$pulseRate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$pulseRate/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$pulseWidth">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$pulseWidth/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$pulseWidth/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$kvp">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$kvp/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$kvp/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$xRAYTubeCurrent">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$xRAYTubeCurrent/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$xRAYTubeCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$exposureTime">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$exposureTime/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$exposureTime/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$targetRegion">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$targetRegion/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$filterThickness">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$filterThickness/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$filterThickness/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$acquisitionPlane">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$acquisitionPlane/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
        </tr>
        <xsl:for-each select="$xRAYDoseEvents">
        <tr>
            <!-- dateTimeStarted -->
            <xsl:if test="$dateTimeStarted">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <!-- This section create anchor in the table to used by section selector -->
                    <xsl:if test="current()/RelationshipType = 'CONTAINS'">
                        <a name="{concat(translate(current()/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), concat($pCurSectionPos, $pPosition + position() - 1))}"/>
                    </xsl:if>
                    
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '111526' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- acquisitionProtocol -->
            <xsl:if test="$acquisitionProtocol">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '125203' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- dap -->
            <xsl:if test="$dap">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122130' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- doseRP -->
            <xsl:if test="$doseRP">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113738' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableLongitPosition -->
            <xsl:if test="$tableLongitPosition">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113751' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableLateralPosition -->
            <xsl:if test="$tableLateralPosition">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113752' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableHeight -->
            <xsl:if test="$tableHeight">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113753' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableHorizRotAngle -->
            <xsl:if test="$tableHorizRotAngle">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113755' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableHeadTiltAngle -->
            <xsl:if test="$tableHeadTiltAngle">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113754' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableLongitEndPosition -->
            <xsl:if test="$tableLongitEndPosition">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'Cod010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableLateralEndPosition -->
            <xsl:if test="$tableLateralEndPosition">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'Cod011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- tableHeightEndPosition -->
            <xsl:if test="$tableHeightEndPosition">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'Cod012' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- positionerPriAngle -->
            <xsl:if test="$positionerPriAngle">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- positionerSecAngle -->
            <xsl:if test="$positionerSecAngle">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '112012' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- positionerPriEndAngle -->
            <xsl:if test="$positionerPriEndAngle">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113739' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- positionerSecEndAngle -->
            <xsl:if test="$positionerSecEndAngle">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113740' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- patientTableRel -->
            <xsl:if test="$patientTableRel">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113745' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- patientEquivThick -->
            <xsl:if test="$patientEquivThick">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'INNOVA-106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- sid -->
            <xsl:if test="$sid">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113750' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- sod -->
            <xsl:if test="$sod">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113748' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- collimatedFieldArea -->
            <xsl:if test="$collimatedFieldArea">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113790' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- numberOfPulses -->
            <xsl:if test="$numberOfPulses">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113768' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- pulseRate -->
            <xsl:if test="$pulseRate">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113791' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- pulseWidth -->
            <xsl:if test="$pulseWidth">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113793' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- kvp -->
            <xsl:if test="$kvp">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113733' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- xRAYTubeCurrent -->
            <xsl:if test="$xRAYTubeCurrent">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113734' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- exposureTime -->
            <xsl:if test="$exposureTime">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113824' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- targetRegion -->
            <xsl:if test="$targetRegion">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '123014' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- filterThickness -->
            <xsl:if test="$filterThickness">
                <xsl:variable name="currentFilterThickness" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113771' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113773' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <xsl:choose>
                    <xsl:when test="$currentFilterThickness">
                        <td style="text-align: left; border-style: solid; border-width: thin">
                            <table style="width: 100%; border-style: none; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
                                <xsl:for-each select="$currentFilterThickness">
                                    <tr>
                                        <td style="text-align: center; border-style: none">
                                            <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="current()"/>
                                                <xsl:with-param name="pIsEditable" select="'false'"/>
                                                <xsl:with-param name="pUnit" select="'none'"/>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </table>
                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td style="text-align: left; border-style: solid; border-width: thin">
                        </td>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <!-- acquisitionPlane -->
            <xsl:if test="$acquisitionPlane">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113764' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
        </tr>
        </xsl:for-each>
    </table>
</xsl:template>


<!-- ####################################################################################################
    Template:       addAccumulatedXRAYDoseData
    Description:    
    Parameters:
-->
<xsl:template name="addAccumulatedXRAYDoseData">
    <xsl:param name="accumulatedDoseData"/>
    <xsl:param name="pCurSectionPos"/>
    <xsl:param name="pPosition"/>

<!-- (113702, DCM, Accumulated X-Ray Dose Data) items. -->
    <xsl:if test="$accumulatedDoseData[1]/RelationshipType = 'CONTAINS'">
        <xsl:if test="$accumulatedDoseData[1]/ConceptNameCodeSequence/Item/CodeMeaning">
            <h2><xsl:value-of select="$accumulatedDoseData[1]/ConceptNameCodeSequence/Item/CodeMeaning"/></h2>
        </xsl:if>
    </xsl:if>

    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
        <xsl:if test="$rendering = 'xls'">
            <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
        </xsl:if>
    <!-- (113764, DCM, Acquisition Plane) -->
        <xsl:variable name="acquisitionPlane" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113764' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113722, DCM, Dose Area Product Total) -->
        <xsl:variable name="dapTotal" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113722' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113725, DCM, Dose (RP) Total) -->
        <xsl:variable name="doseRPTotal" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113725' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113726, DCM, Fluoro Dose Area Product Total) -->
        <xsl:variable name="fluoroDAPTotal" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113726' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113728, DCM, Fluoro Dose (RP) Total) -->
        <xsl:variable name="fluoroDoseRPTotal" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113728' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113730, DCM, Total Fluoro Time) -->
        <xsl:variable name="totalFluoroTime" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113730' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113727, DCM, Acquisition Dose Area Product Total) -->
        <xsl:variable name="acquisitionDAPTotal" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113727' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113729, DCM, Acquisition Dose (RP) Total) -->
        <xsl:variable name="acquisitioDoseRPTotal" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113729' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113855, DCM, Total Acquisition Time) -->
        <xsl:variable name="totalAcquisitionTime" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113855' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113731, DCM, Total Number of Radiographic Frames) -->
        <xsl:variable name="totalNumOfRadiographicFrames" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113731' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113780, DCM, Reference Point Definition) -->
        <xsl:variable name="referencePointDefinition" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113780' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (122505, DCM, Calibration) -->
        <xsl:variable name="calibration" select="$accumulatedDoseData/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122505' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113794, DCM, Dose Measurement Device) -->
        <xsl:variable name="doseMeasurementDevice" select="$calibration/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113794' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113723, DCM, Calibration Date) -->
        <xsl:variable name="calibrationDate" select="$calibration/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113723' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (122322, DCM, Calibration Factor) -->
        <xsl:variable name="calibrationFactor" select="$calibration/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122322' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113763, DCM, Calibration Uncertainty) -->
        <xsl:variable name="calibrationUncertainty" select="$calibration/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113763' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113720, DCM, Calibration Protocol) -->
        <xsl:variable name="calibrationProtocol" select="$calibration/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113720' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <!-- (113724, DCM, Calibration Responsible Party) -->
        <xsl:variable name="calibrationResponsibleParty" select="$calibration/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113724' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        
        <tr bgcolor="#{$P2}">
            <xsl:if test="$acquisitionPlane">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$acquisitionPlane/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$dapTotal">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$dapTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (Gy.cm2)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$doseRPTotal">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$doseRPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (mGy)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$fluoroDAPTotal">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$fluoroDAPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (Gy.cm2)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$fluoroDoseRPTotal">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$fluoroDoseRPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (mGy)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$totalFluoroTime">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$totalFluoroTime/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$totalFluoroTime/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$acquisitionDAPTotal">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$acquisitionDAPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (Gy.cm2)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$acquisitioDoseRPTotal">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$acquisitioDoseRPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> (mGy)</xsl:text>
                </th>
            </xsl:if>
            <xsl:if test="$totalAcquisitionTime">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$totalAcquisitionTime/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:text> </xsl:text>
                    (<xsl:value-of select="$totalAcquisitionTime/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                </th>
            </xsl:if>
            <xsl:if test="$totalNumOfRadiographicFrames">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$totalNumOfRadiographicFrames/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$referencePointDefinition">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$referencePointDefinition/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
            <xsl:if test="$calibration">
                <th rowspan="1" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                    <xsl:value-of select="$calibration/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:if>
        </tr>
        <xsl:for-each select="$accumulatedDoseData">
        <tr>
            <!-- acquisitionPlane -->
            <xsl:if test="$acquisitionPlane">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:if test="current()/RelationshipType = 'CONTAINS'">
                        <a name="{concat(translate(current()/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), concat($pCurSectionPos, $pPosition + position() - 1))}"/>
                    </xsl:if>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113764' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- dapTotal -->
            <xsl:if test="$dapTotal">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113722' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- doseRPTotal  -->
            <xsl:if test="$doseRPTotal">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113725' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- fluoroDAPTotal  -->
            <xsl:if test="$fluoroDAPTotal">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113726' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- fluoroDoseRPTotal  -->
            <xsl:if test="$fluoroDoseRPTotal">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113728' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- totalFluoroTime  -->
            <xsl:if test="$totalFluoroTime">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113730' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- acquisitionDAPTotal  -->
            <xsl:if test="$acquisitionDAPTotal">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113727' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- acquisitioDoseRPTotal  -->
            <xsl:if test="$acquisitioDoseRPTotal">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113729' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- totalAcquisitionTime  -->
            <xsl:if test="$totalAcquisitionTime">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113855' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- totalNumOfRadiographicFrames  -->
            <xsl:if test="$totalNumOfRadiographicFrames">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113731' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <!-- referencePointDefinition  -->
            <xsl:if test="$referencePointDefinition">
                <td style="text-align: left; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113780' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
            <xsl:if test="$calibration">
                <xsl:variable name="currentCalibration" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122505' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                <td style="align: center; text-align: center; border-style: solid; border-width: thin">
                <table style="width: 90%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
                    <tr bgcolor="#{$P2}">
                        <xsl:if test="$doseMeasurementDevice">
                            <th headers="calibration" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                                <xsl:value-of select="$doseMeasurementDevice/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </th>
                        </xsl:if>
                        <xsl:if test="$calibrationDate">
                            <th headers="calibration" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                                <xsl:value-of select="$calibrationDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </th>
                        </xsl:if>
                        <xsl:if test="$calibrationFactor">
                            <th headers="calibration" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                                <xsl:value-of select="$calibrationFactor/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </th>
                        </xsl:if>
                        <xsl:if test="$calibrationUncertainty">
                            <th headers="calibration" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                                <xsl:value-of select="$calibrationUncertainty/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </th>
                        </xsl:if>
                        <xsl:if test="$calibrationProtocol">
                            <th headers="calibration" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                                <xsl:value-of select="$calibrationProtocol/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </th>
                        </xsl:if>
                        <xsl:if test="$calibrationResponsibleParty">
                            <th headers="calibration" style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                                <xsl:value-of select="$calibrationResponsibleParty/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </th>
                        </xsl:if>
                    </tr>
                    <xsl:for-each select="$currentCalibration">
                    <tr>
                        <!-- doseMeasurementDevice  -->
                        <xsl:if test="$doseMeasurementDevice">
                            <td style="text-align: left; border-style: solid; border-width: thin">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113794' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                    <xsl:with-param name="pUnit" select="'none'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                        <!-- calibrationDate  -->
                        <xsl:if test="$calibrationDate">
                            <td style="text-align: left; border-style: solid; border-width: thin">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113723' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                    <xsl:with-param name="pUnit" select="'none'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                        <!-- calibrationFactor  -->
                        <xsl:if test="$calibrationFactor">
                            <td style="text-align: left; border-style: solid; border-width: thin">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122322' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                    <xsl:with-param name="pUnit" select="'none'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                        <!-- calibrationUncertainty  -->
                        <xsl:if test="$calibrationUncertainty">
                            <td style="text-align: left; border-style: solid; border-width: thin">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113763' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                    <xsl:with-param name="pUnit" select="'none'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                        <!-- calibrationProtocol  -->
                        <xsl:if test="$calibrationProtocol">
                            <td style="text-align: left; border-style: solid; border-width: thin">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113720' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                    <xsl:with-param name="pUnit" select="'none'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                        <!-- calibrationResponsibleParty  -->
                        <xsl:if test="$calibrationResponsibleParty">
                            <td style="text-align: left; border-style: solid; border-width: thin">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113724' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                    <xsl:with-param name="pUnit" select="'none'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                    </tr>
                    </xsl:for-each>
                </table>
                </td>
            </xsl:if>  <!-- $calibration -->
        </tr>
        </xsl:for-each>
    </table>
    <xsl:if test="$DICOM/@dosesrShortLength = 'true'">
        <b><xsl:value-of select="$messagecatalog/LBL_SEE_IRRADIATION_IN_LONG/msg[@lang = $lang]"/></b>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
