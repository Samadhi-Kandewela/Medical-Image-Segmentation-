<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2005 GE Healthcare

    DOSE_HTM.XSL   : Rules for adding Dose SR table format report sections to PDF:
                     - Header (logo, name, address),
                     - Patient demographics (name, weight, etc.)
                     - Observation context
                     - Physician signatures

    Author          :   Laszlo PECSY
    Last modified on:   Maj 6, 2014
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:fox="http://xml.apache.org/fop/extensions">

<xsl:import href="SECT_FO.XSL"/>

<!-- ####################################################################################################
    Template:       addSoftwareVersion
    Description:    Add SoftwareVersion tag to rendered report.
-->
<xsl:template name="addSoftwareVersion">
    <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell>
                    <fo:block hyphenate="true" language="{$lang}">
                        <fo:inline font-weight="bold">
                            <xsl:value-of select="$messagecatalog/LBL_SOFTWARE_VERSION/msg[@lang = $lang]"/>
                        </fo:inline>
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block hyphenate="true" language="{$lang}">
                        <xsl:value-of select="$DICOM/SoftwareVersion"/>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>

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

    <xsl:variable name="accumulatedXRAYDoseDataItems" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113702' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:for-each select="$DICOM/ContentSequence/Item">
        <xsl:variable name="currPos" select="position()"/>
        <xsl:choose>
            <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = '113706' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM and $DICOM/@dosesrTableMode = 'true'">
                <!-- Irradiation X-Ray Dose Events shouldn't be processed -->
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
            <xsl:when test="not(current()/ValueType_TEXT) or current()/TextValue != ''">
                <xsl:call-template name="addContentItem">
                    <xsl:with-param name="pItem" select="current()"/>
                    <xsl:with-param name="pPosition" select="concat($pCurSectionPos, position())"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
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
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <!-- Calibration Uncertainty -->
        <xsl:when test="$valueCSD=$CSD_DICOM and $valueCV='113763'">
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
        </xsl:otherwise>
    </xsl:choose>
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
        
    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
                    <fo:block space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:value-of select="$accumulatedDoseData[1]/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%">
                        <xsl:if test="$acquisitionPlane">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$dapTotal">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$doseRPTotal">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$fluoroDAPTotal">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$fluoroDoseRPTotal">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$totalFluoroTime">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$acquisitionDAPTotal">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$acquisitioDoseRPTotal">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$totalAcquisitionTime">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$totalNumOfRadiographicFrames">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$referencePointDefinition">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                        </xsl:if>
                        <xsl:if test="$calibration">
                            <fo:table-column column-width="proportional-column-width(6)"/>
                        </xsl:if>
           <!--             <fo:table-header> -->
                                   <fo:table-body>

                            <fo:table-row background-color="#{$P2}">
                                <xsl:if test="$acquisitionPlane">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$acquisitionPlane/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$dapTotal">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$dapTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> (Gy.cm2)</xsl:text>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$doseRPTotal">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$doseRPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> (mGy)</xsl:text>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$fluoroDAPTotal">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$fluoroDAPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> (Gy.cm2)</xsl:text>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$fluoroDoseRPTotal">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$fluoroDoseRPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> (mGy)</xsl:text>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$totalFluoroTime">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$totalFluoroTime/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> </xsl:text>
                                        (<xsl:value-of select="$totalFluoroTime/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$acquisitionDAPTotal">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$acquisitionDAPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> (Gy.cm2)</xsl:text>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$acquisitioDoseRPTotal">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$acquisitioDoseRPTotal/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> (mGy)</xsl:text>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$totalAcquisitionTime">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$totalAcquisitionTime/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        <xsl:text> </xsl:text>
                                        (<xsl:value-of select="$totalAcquisitionTime/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$totalNumOfRadiographicFrames">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$totalNumOfRadiographicFrames/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$referencePointDefinition">
                                <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                        <xsl:value-of select="$referencePointDefinition/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <xsl:if test="$calibration">
                                    <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                            <xsl:value-of select="$calibration/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:if>
                            </fo:table-row>
<!--                        </fo:table-header>
                        <fo:table-body> -->
                        <xsl:for-each select="$accumulatedDoseData">
                            <fo:table-row>
                                <!-- acquisitionPlane -->
                                <xsl:if test="$acquisitionPlane">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <xsl:if test="current()/RelationshipType = 'CONTAINS'">
                                        <fo:block id="{concat(translate(current()/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), concat($pCurSectionPos, $pPosition + position() - 1))}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                                        </fo:block>
                                    </xsl:if>
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113764' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- dapTotal -->
                                <xsl:if test="$dapTotal">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113722' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- doseRPTotal  -->
                                <xsl:if test="$doseRPTotal">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113725' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- fluoroDAPTotal  -->
                                <xsl:if test="$fluoroDAPTotal">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113726' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- fluoroDoseRPTotal  -->
                                <xsl:if test="$fluoroDoseRPTotal">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113728' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- totalFluoroTime  -->
                                <xsl:if test="$totalFluoroTime">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113730' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- acquisitionDAPTotal  -->
                                <xsl:if test="$acquisitionDAPTotal">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113727' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- acquisitioDoseRPTotal  -->
                                <xsl:if test="$acquisitioDoseRPTotal">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113729' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- totalAcquisitionTime  -->
                                <xsl:if test="$totalAcquisitionTime">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113855' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- totalNumOfRadiographicFrames  -->
                                <xsl:if test="$totalNumOfRadiographicFrames">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113731' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- referencePointDefinition  -->
                                <xsl:if test="$referencePointDefinition">
                                <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113780' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:with-param name="pIsEditable" select="'false'"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                </xsl:if>
                                <!-- calibration  -->
                                <xsl:if test="$calibration">
                                    <xsl:variable name="currentCalibration" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122505' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:table table-layout="fixed" width="100%">
                                            <xsl:if test="$doseMeasurementDevice">
                                                <fo:table-column column-width="proportional-column-width(1)"/>
                                            </xsl:if>
                                            <xsl:if test="$calibrationDate">
                                                <fo:table-column column-width="proportional-column-width(1)"/>
                                            </xsl:if>
                                            <xsl:if test="$calibrationFactor">
                                                <fo:table-column column-width="proportional-column-width(1)"/>
                                            </xsl:if>
                                            <xsl:if test="$calibrationUncertainty">
                                                <fo:table-column column-width="proportional-column-width(1)"/>
                                            </xsl:if>
                                            <xsl:if test="$calibrationProtocol">
                                                <fo:table-column column-width="proportional-column-width(1)"/>
                                            </xsl:if>
                                            <xsl:if test="$calibrationResponsibleParty">
                                                <fo:table-column column-width="proportional-column-width(1)"/>
                                            </xsl:if>
                                            <fo:table-body>
                                                <fo:table-row>
                                                    <xsl:if test="$doseMeasurementDevice">
                                                    <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                                                            <xsl:value-of select="$doseMeasurementDevice/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <xsl:if test="$calibrationDate">
                                                    <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                                                            <xsl:value-of select="$calibrationDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <xsl:if test="$calibrationFactor">
                                                    <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                                                            <xsl:value-of select="$calibrationFactor/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <xsl:if test="$calibrationUncertainty">
                                                    <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                                                            <xsl:value-of select="$calibrationUncertainty/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <xsl:if test="$calibrationProtocol">
                                                    <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                                                            <xsl:value-of select="$calibrationProtocol/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <xsl:if test="$calibrationResponsibleParty">
                                                    <fo:table-cell background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block hyphenate="true" language="{$lang}" text-align="left" font-weight="bold">
                                                            <xsl:value-of select="$calibrationResponsibleParty/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                </fo:table-row>
                                                <xsl:for-each select="$currentCalibration">
                                                <fo:table-row>
                                                    <!-- doseMeasurementDevice  -->
                                                    <xsl:if test="$doseMeasurementDevice">
                                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                                            <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113794' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                                <xsl:with-param name="pIsEditable" select="'false'"/>
                                                                <xsl:with-param name="pUnit" select="'none'"/>
                                                            </xsl:call-template>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <!-- calibrationDate  -->
                                                    <xsl:if test="$calibrationDate">
                                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                                            <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113723' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                                <xsl:with-param name="pIsEditable" select="'false'"/>
                                                                <xsl:with-param name="pUnit" select="'none'"/>
                                                            </xsl:call-template>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <!-- calibrationFactor  -->
                                                    <xsl:if test="$calibrationFactor">
                                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                                            <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '122322' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                                <xsl:with-param name="pIsEditable" select="'false'"/>
                                                                <xsl:with-param name="pUnit" select="'none'"/>
                                                            </xsl:call-template>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <!-- calibrationUncertainty  -->
                                                    <xsl:if test="$calibrationUncertainty">
                                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                                            <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113763' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                                <xsl:with-param name="pIsEditable" select="'false'"/>
                                                                <xsl:with-param name="pUnit" select="'none'"/>
                                                            </xsl:call-template>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                    <!-- calibrationProtocol  -->
                                                    <xsl:if test="$calibrationProtocol">
                                                        <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                            <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                                                <xsl:call-template name="addValue">
                                                                <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113720' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                                    <xsl:with-param name="pIsEditable" select="'false'"/>
                                                                    <xsl:with-param name="pUnit" select="'none'"/>
                                                                </xsl:call-template>
                                                            </fo:block>
                                                        </fo:table-cell>
                                                    </xsl:if>
                                                    <!-- calibrationResponsibleParty  -->
                                                    <xsl:if test="$calibrationResponsibleParty">
                                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                                        <fo:block font-weight="normal" hyphenate="true" language="{$lang}" text-align="left">
                                                            <xsl:call-template name="addValue">
                                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '113724' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                                                <xsl:with-param name="pIsEditable" select="'false'"/>
                                                                <xsl:with-param name="pUnit" select="'none'"/>
                                                            </xsl:call-template>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    </xsl:if>
                                                </fo:table-row>
                                                </xsl:for-each>
                                            </fo:table-body>
                                        </fo:table>
                                    </fo:table-cell>
                                </xsl:if>  <!-- calibration -->
                            </fo:table-row>
                        </xsl:for-each>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
    <xsl:if test="$DICOM/@dosesrShortLength = 'true'">
        <fo:block font-weight="bold" hyphenate="true" language="{$lang}" text-align="left">
            <xsl:value-of select="$messagecatalog/LBL_SEE_IRRADIATION_IN_LONG/msg[@lang = $lang]"/>
        </fo:block>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
