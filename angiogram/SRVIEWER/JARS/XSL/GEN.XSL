<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2012 GE Healthcare

    GEN.XSL         :   Generic and commonly used XSLT temaplates.

    Author          :   Attila RACZ
    Last modified on:   Feb 06, 2012
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:java="http://xml.apache.org/xalan/java"
                              exclude-result-prefixes="java">

<!-- Global variables -->
<xsl:variable name="DICOM" select="/DICOM"/>
<!-- Language selection parameter -->
<xsl:variable name="lang" select="$DICOM/@lang"/>
<xsl:variable name="clinicalUse" select="$DICOM/@clinicalUse"/>
<xsl:variable name="rendering" select="$DICOM/@rendering"/>
    
<xsl:variable name="PatientDemographics" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121025 and ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM']"/>
<xsl:variable name="MedicalHistory" select="$PatientDemographics/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121060 and ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM']"/>
<xsl:variable name="Physician" select="$PatientDemographics/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'J-004E8' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'SNM3']"/>

<xsl:variable name="currentTemplate" select="concat($DICOM/@templateBase, $DICOM/@templateGroup, '/', $DICOM/@template, '/TP.XML')"/>
<!-- Template root. -->
<xsl:variable name="tp" select="document($currentTemplate)/Customizations"/>
<xsl:variable name="messagecatalog" select="document('MSGCAT.XML')/Messages"/>

<!-- Actual font size. Default size is 12pt. -->
<xsl:variable name="fontSize">
    <xsl:choose>
        <xsl:when test="$tp/Font/@size != ''"><xsl:value-of select="$tp/Font/@size"/></xsl:when>
        <xsl:otherwise>12</xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<!-- Title font size. -->
<xsl:variable name="titleFontSize" select="$fontSize + 8"/>
<!-- Heading 1 font size. -->
<xsl:variable name="heading1FontSize" select="$fontSize + 6"/>
<!-- Heading 2 font size. -->
<xsl:variable name="heading2FontSize" select="$fontSize + 4"/>
<!-- Heading 3 font size. -->
<xsl:variable name="heading3FontSize" select="$fontSize + 2"/>

<xsl:variable name="small1FontSize" select="$fontSize - 2"/>
<xsl:variable name="small2FontSize" select="$fontSize - 4"/>
<xsl:variable name="small3FontSize" select="$fontSize - 6"/>

<!-- Footer font size based on $fontSize. Deafult size is 8pt. -->
<xsl:variable name="footerFontSize">
    <xsl:choose>
        <xsl:when test="$fontSize &gt; 12">10</xsl:when>
        <xsl:otherwise>8</xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<!-- Number of columns patient demographic fields are displayed across. Default is 2. -->
<xsl:variable name="demographicsColumns">
    <xsl:choose>
        <xsl:when test="$tp/Demographics/@columns != ''"><xsl:value-of select="$tp/Demographics/@columns"/></xsl:when>
        <xsl:otherwise>2</xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<!-- Number of columns images are displayed across. Default is 2. -->
<xsl:variable name="imgColumns">
    <xsl:choose>
        <xsl:when test="$tp/Images/@columns != ''"><xsl:value-of select="$tp/Images/@columns"/></xsl:when>
        <xsl:otherwise>2</xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<!-- Notification of empty content content items with 1C values. -->
<xsl:variable name="NO_CONTENT">-</xsl:variable>

<!-- ####################################################################################################
    Coding Scheme Designator string constants
-->
<!-- DICOM Controlled Terminology; PS 3.16 Content Mapping Resource, Annex D -->
<xsl:variable name="CSD_DICOM">DCM</xsl:variable>
<!-- Logical Observation Identifier Names and Codes, Version 1.01 (Laboratory LOINC) -->
<xsl:variable name="CSD_LOINC">LN</xsl:variable>
<!-- SNOMED Version 3 -->
<xsl:variable name="CSD_SNOMED">SNM3</xsl:variable>
<!-- SNOMED-RT -->
<xsl:variable name="CSD_SNOMED_RT">SRT</xsl:variable>
<!-- Unified Code for Units of Measure -->
<xsl:variable name="CSD_UCUM">UCUM</xsl:variable>
<!-- GE Medical System internal -->
<xsl:variable name="CSD_GEMS">99GEMS</xsl:variable>

<!-- ####################################################################################################
    CUI color constants
-->
<xsl:variable name="P1">FFFFFF</xsl:variable>
<xsl:variable name="P2">F0F1F6</xsl:variable>
<xsl:variable name="P3">BBBDCA</xsl:variable>
<xsl:variable name="P4">979DB0</xsl:variable>
<xsl:variable name="P5">DBDDEA</xsl:variable>
<!--xsl:variable name="P6">DELETED</xsl:variable-->
<xsl:variable name="P7">BAC2D9</xsl:variable>
<xsl:variable name="P8">8D9CC5</xsl:variable>
<xsl:variable name="P9">6877A0</xsl:variable>
<xsl:variable name="P10">2F426A</xsl:variable>
<xsl:variable name="P11">000000</xsl:variable>
<xsl:variable name="P12">FFFFE1</xsl:variable>
<xsl:variable name="P13">FFF1AB</xsl:variable>

<!-- Unit conversion rates: RATE_<from>_<to> -->
<xsl:variable name="RATE_cm_in">2.54</xsl:variable>
<xsl:variable name="RATE_m_ft">3.28084</xsl:variable>
<xsl:variable name="RATE_kg_lb">2.20462</xsl:variable>

<xsl:variable name="INVALID_NAME_CHARS"> !"#$%&amp;'()*+,-./:;=?@[\]^`{|}~</xsl:variable>

<xsl:variable name="DECIMAL_SEPARATOR">.</xsl:variable>
<xsl:variable name="LF"><xsl:value-of select="'&#x0A;'"/></xsl:variable>
<xsl:variable name="NewLineSeparator">\n</xsl:variable>

<xsl:variable name="numberFormatInteger">
    <xsl:choose>
        <xsl:when test="$DICOM/@use_grouping_separator = 'true'">#,##0</xsl:when>
        <xsl:otherwise>###0</xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="numberFormatFraction">
    <xsl:if test="$DICOM/@decimal_places">
        <xsl:call-template name="setDecimalPlaces">
            <xsl:with-param name="pDecimalPlaces" select="$DICOM/@decimal_places"/>
        </xsl:call-template>
    </xsl:if>
</xsl:variable>
<xsl:variable name="numberFormat">
    <xsl:choose>
        <xsl:when test="$DICOM/@use_grouping_separator and $DICOM/@decimal_places">
            <xsl:choose>
                <xsl:when test="$DICOM/@decimal_places = '0'">
                    <xsl:value-of select="$numberFormatInteger"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($numberFormatInteger, $DECIMAL_SEPARATOR, $numberFormatFraction)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>#,##0.0</xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<!-- Generic style-sheet displays nested content items in tables. At each nesting level the column size will reduce with this factor. -->
<xsl:variable name="COL_REDUCE_FACTOR">0.02</xsl:variable>

<!-- ####################################################################################################
    Template:       setDecimalPlaces
    Description:    Sets number formatting pattern for decimal places.
    Parameters:
-->
<xsl:template name="setDecimalPlaces"> <xsl:param name="pDecimalPlaces"/>
    <xsl:choose>
        <xsl:when test="$pDecimalPlaces &gt; 0">
            <xsl:text>0</xsl:text>
            <xsl:call-template name="setDecimalPlaces">
                <xsl:with-param name="pDecimalPlaces" select="$pDecimalPlaces - 1"/>
            </xsl:call-template>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addDateAndTime
    Description:    Add the specified date and time with "," separator.
    Parameters:
        pDate   : Date value
        pTime   : Time value
-->
<xsl:template name="addDateAndTime"> <xsl:param name="pDate"/> <xsl:param name="pTime"/>
    <xsl:if test="$pDate != ''">
        <xsl:call-template name="formatDate">
            <xsl:with-param name="pDate" select="$pDate"/>
        </xsl:call-template>
    </xsl:if>
    <xsl:if test="$pTime != ''">
        <xsl:text>, </xsl:text>
        <xsl:call-template name="formatTime">
            <xsl:with-param name="pTime" select="$pTime"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addSexText
    Description:    Select the sex based on PSex code.
    Parameters:
        PSex    : Sex code
-->
<xsl:template name="addSexText"> <xsl:param name="PSex"/>
    <xsl:value-of select="$messagecatalog/LBL_SEX/item[@value = $PSex]/msg[@lang = $lang]"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       addAgeText
    Description:    Format age text based on AS value representation.
    Parameters:
        pAge    : Age value and code
-->
<xsl:template name="addAgeText"> <xsl:param name="pAge"/>
    <xsl:if test="$pAge and $pAge != ''">
        <xsl:value-of select="number(substring($pAge, 1, 3))"/>
    </xsl:if>
    <xsl:if test="$DICOM/PatientBirthDate and $DICOM/PatientBirthDate != ''">
        <!--xsl:text> </xsl:text-->
        (<xsl:value-of select="number(substring($DICOM/@dateTime, 1, 4)) - number(substring($DICOM/PatientBirthDate, 1, 4))"/>)
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addHeight
    Description:    Format the height to # cm (# ft)
    Parameters:
        pHeight : Value of height
-->
<xsl:template name="addHeight"> <xsl:param name="pHeight"/>
    <xsl:if test="$pHeight !=''">
        <xsl:variable name="cmPatientSize"><xsl:value-of select="$pHeight * 100"/></xsl:variable>
        <xsl:choose>
            <xsl:when test="$tp/UnitsOfMeasurement/@name = 'EN'">
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pHeight * $RATE_m_ft"/>
                    <xsl:with-param name="pPattern" select="'#,##0.00'"/>
                </xsl:call-template><xsl:text> ft (</xsl:text>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pHeight"/>
                    <xsl:with-param name="pPattern" select="'#,##0.00'"/>
                </xsl:call-template><xsl:text> m)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pHeight"/>
                    <xsl:with-param name="pPattern" select="'#,##0.00'"/>
                </xsl:call-template><xsl:text> m (</xsl:text>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pHeight * $RATE_m_ft"/>
                    <xsl:with-param name="pPattern" select="'#,##0.00'"/>
                </xsl:call-template><xsl:text> ft)</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
<!--
        <xsl:value-of select="floor($cmPatientSize div $RATE_cm_ft)"/>&#x20;ft&#x20;<xsl:value-of select="round(($cmPatientSize mod $RATE_cm_ft) div $RATE_cm_in)"/>&#x20;in
-->
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addWeight
    Description:    Format the weight to # kg (# lb)
    Parameters:
        pWeight : Value of weight
-->
<xsl:template name="addWeight"> <xsl:param name="pWeight"/>
    <xsl:if test="$pWeight != ''">
        <xsl:choose>
            <xsl:when test="$tp/UnitsOfMeasurement/@name = 'EN'">
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pWeight * $RATE_kg_lb"/>
                </xsl:call-template><xsl:text> lb (</xsl:text>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pWeight"/>
                </xsl:call-template><xsl:text> kg)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pWeight"/>
                </xsl:call-template><xsl:text> kg (</xsl:text>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pWeight * $RATE_kg_lb"/>
                </xsl:call-template><xsl:text> lb)</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       calculateBSA
    Description:    Calculates Body Surface Area based on
                    BSA = 0.20247 x Height(m)^0.725 x Weight(kg)^0.425 DuBois formula.
    Parameters:
        pWeight : Value of weight
        pHeight : Value of height
-->
<xsl:template name="calculateBSA"> <xsl:param name="pWeight" select="$DICOM/PatientWeight"/>
                                   <xsl:param name="pHeight" select="$DICOM/PatientSize"/>
    <xsl:if test="$pWeight != '' and $pHeight != ''">
        <xsl:variable name="item1" select="java:java.lang.Math.pow($pHeight, 0.725)"/>
        <xsl:variable name="item2" select="java:java.lang.Math.pow($pWeight, 0.425)"/>
        <xsl:call-template name="formatNumericValue">
            <xsl:with-param name="pNum" select="0.20247 * $item1 * $item2"/>
        </xsl:call-template><xsl:text> m2</xsl:text>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addBSA
    Description:    Adds Body Surface Area.
    Parameters:
        pWeight : Value of weight
        pHeight : Value of height
-->
<xsl:template name="addBSA"> <xsl:param name="pWeight" select="$DICOM/PatientWeight"/>
                             <xsl:param name="pHeight" select="$DICOM/PatientSize"/>
    <xsl:if test="$pWeight != '' and $pHeight != ''">
        <xsl:call-template name="calculateBSA">
            <xsl:with-param name="pWeight" select="$pWeight"/>
            <xsl:with-param name="pHeight" select="$pHeight"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       calculateBMI
    Description:    Calculates Body Mass Index based on BMI = Weight(kg) / Height(m)^2 formula.
    Parameters:
        pWeight : Value of weight
        pHeight : Value of height
-->
<xsl:template name="calculateBMI"> <xsl:param name="pWeight" select="$DICOM/PatientWeight"/>
                                   <xsl:param name="pHeight" select="$DICOM/PatientSize"/>
    <xsl:if test="$pWeight != '' and $pHeight != ''">
        <xsl:choose>
            <xsl:when test="$pWeight = 0 or $pHeight = 0">
                <xsl:text>-</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="formatNumericValue">
                    <xsl:with-param name="pNum" select="$pWeight div ($pHeight * $pHeight)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose><xsl:text> kg/m2</xsl:text>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addBMI
    Description:    Adds Body Mass Index.
    Parameters:
        pWeight : Value of weight
        pHeight : Value of height
-->
<xsl:template name="addBMI"> <xsl:param name="pWeight" select="$DICOM/PatientWeight"/>
                             <xsl:param name="pHeight" select="$DICOM/PatientSize"/>
    <xsl:if test="$pWeight != '' and $pHeight != ''">
        <xsl:call-template name="calculateBMI">
            <xsl:with-param name="pWeight" select="$pWeight"/>
            <xsl:with-param name="pHeight" select="$pHeight"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatSchemaSex
    Description:    Format person's sex to code sequence item.
    Parameters:
        PSex   : Sex abbreviation
-->
<xsl:template name="formatSchemaSex"> <xsl:param name="PSex"/>
    <xsl:choose>
        <xsl:when test="$PSex = 'M'">
            <CodeValue>M</CodeValue>
            <CodingSchemeDesignator>ISO5218_1</CodingSchemeDesignator>
            <CodeMeaning>Male</CodeMeaning>
        </xsl:when>
        <xsl:when test="$PSex = 'F'">
            <CodeValue>F</CodeValue>
            <CodingSchemeDesignator>ISO5218_1</CodingSchemeDesignator>
            <CodeMeaning>Female</CodeMeaning>
        </xsl:when>
        <xsl:when test="$PSex = 'O'">
            <CodeValue>O</CodeValue>
            <CodingSchemeDesignator>ISO5218_1</CodingSchemeDesignator>
            <CodeMeaning>Other</CodeMeaning>
        </xsl:when>
        <xsl:otherwise>
            <CodeValue>O</CodeValue>
            <CodingSchemeDesignator>ISO5218_1</CodingSchemeDesignator>
            <CodeMeaning>Other</CodeMeaning>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatPersonName
    Description:    Format PN
                    "family_name_complex^given_name_complex^middle_name^name_prefix^name_suffix"
                    DICOM VR to English name format
                    "name_prefix given_name_complex middle_name family_name_complex name_suffix".
    Parameters:
        PName   : Person name
-->
<xsl:template name="formatPersonName"> <xsl:param name="PName"/>

<!-- Check if PName contains '^' at all. -->
    <xsl:choose>
        <xsl:when test="contains($PName, '^')">
            <xsl:variable name="family" select="substring-before($PName, '^')"/>
            <xsl:variable name="giv_mid_pre_suf" select="substring-after($PName, '^')"/>

<!-- Check if giv_mid_pre_suf contains '^' at all. -->
            <xsl:choose>
                <xsl:when test="contains($giv_mid_pre_suf, '^')">
                    <xsl:variable name="given" select="substring-before($giv_mid_pre_suf, '^')"/>
                    <xsl:variable name="mid_pre_suf" select="substring-after($giv_mid_pre_suf, '^')"/>

<!-- Check if mid_pre_suf contains '^' at all. -->
                    <xsl:choose>
                        <xsl:when test="contains($mid_pre_suf, '^')">
                            <xsl:variable name="middle" select="substring-before($mid_pre_suf, '^')"/>
                            <xsl:variable name="pre_suf" select="substring-after($mid_pre_suf, '^')"/>

<!-- Check if pre_suf contains '^' at all. -->
                            <xsl:choose>
                                <xsl:when test="contains($pre_suf, '^')">
                                    <xsl:variable name="prefix" select="substring-before($pre_suf, '^')"/>
                                    <xsl:variable name="suffix" select="substring-after($pre_suf, '^')"/>
                                    <xsl:value-of select="concat(concat(concat(concat(concat(concat(concat(concat($prefix, ' '), $given), ' '), $middle), ' '), $family), ', '), $suffix)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(concat(concat(concat(concat(concat($pre_suf, ' '), $given), ' '), $middle), ' '), $family)"/>
                                </xsl:otherwise>
                            </xsl:choose>

                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(concat(concat(concat($given, ' '), $mid_pre_suf), ' '), $family)"/>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(concat($giv_mid_pre_suf, ' '), $family)"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$PName"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       DAtoUSShortDate
    Description:    Format DA "yyyymmdd" DICOM VR to U.S. short date format "mm/dd/yyyy".
    Parameters:
        pDate  : Date string
-->
<xsl:template name="DAtoUSShortDate"> <xsl:param name="pDate"/>
    <xsl:value-of select="substring($pDate, 5, 2)"/>/<xsl:value-of
                  select="substring($pDate, 7, 2)"/>/<xsl:value-of
                  select="substring($pDate, 1, 4)"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       DTtoUSShortDate
    Description:    Format DT "yyyymmddhhmmss.ffffff[+|-]zzzz" DICOM VR to U.S. short datetime
                    format "mm/dd/yyyy, hh:mm:ss".
    Parameters:
        pDateTime : DateTime string
-->
<xsl:template name="DTtoUSShortDate"> <xsl:param name="pDateTime"/>
    <xsl:value-of select="substring($pDateTime, 5, 2)"/>/<xsl:value-of
                  select="substring($pDateTime, 7, 2)"/>/<xsl:value-of
                  select="substring($pDateTime, 1, 4)"/>,
    <xsl:value-of select="substring($pDateTime, 9, 2)"/>:<xsl:value-of
                  select="substring($pDateTime, 11, 2)"/>:<xsl:value-of
                  select="substring($pDateTime, 13, 2)"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       DAtoUSLongDate
    Description:    Format DA "yyyymmdd" DICOM VR to U.S. long date format "mmmm dd, yyyy".
    Parameters:
        pDate  : Date string
-->
<xsl:template name="DAtoUSLongDate"> <xsl:param name="pDate"/>
    <xsl:value-of select="$messagecatalog/Months/item[@value = number(substring($pDate, 5, 2))]/msg[@lang = $lang]"/>
    <xsl:value-of select="substring($pDate, 7, 2)"/>,
    <xsl:value-of select="substring($pDate, 1, 4)"/>
    <xsl:text> </xsl:text>
</xsl:template>

<!-- ####################################################################################################
    Template:       DTtoUSLongDate
    Description:    Format DT "yyyymmddhhmmss.ffffff[+|-]zzzz" DICOM VR to U.S. long datetime
                    format "mmmm dd, yyyy hh:mm:ss".
    Parameters:
        pDateTime : DateTime string
-->
<xsl:template name="DTtoUSLongDate"> <xsl:param name="pDateTime"/>
    <xsl:value-of select="$messagecatalog/Months/item[@value = number(substring($pDateTime, 5, 2))]/msg[@lang = $lang]"/>
    <xsl:value-of select="substring($pDateTime, 7, 2)"/>,
    <xsl:value-of select="substring($pDateTime, 1, 4)"/>
    <xsl:value-of select="substring($pDateTime, 9, 2)"/>:<xsl:value-of
                  select="substring($pDateTime, 11, 2)"/>:<xsl:value-of
                  select="substring($pDateTime, 13, 2)"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       DAtoXSDdate
    Description:    Format DA "yyyymmdd" DICOM VR to XML Schema built in xsd:date type "yyyy-mm-dd".
    Parameters:
        $pDate  : Date string
-->
<xsl:template name="DAtoXSDdate"> <xsl:param name="pDate"/>
    <xsl:value-of select="substring($pDate, 1, 4)"/>-<xsl:value-of
                  select="substring($pDate, 5, 2)"/>-<xsl:value-of
                  select="substring($pDate, 7, 2)"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       toXSDdate
    Description:    Format to XML Schema built in xsd:date type "yyyy-mm-dd".
    Parameters:
        $pDate  : Date string
-->
<xsl:template name="toXSDdate"> <xsl:param name="pDate"/>
    <xsl:choose>
        <xsl:when test="contains($pDate, '-')">
            <xsl:value-of select="$pDate"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring($pDate, 1, 4)"/>-<xsl:value-of
                          select="substring($pDate, 5, 2)"/>-<xsl:value-of
                          select="substring($pDate, 7, 2)"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       toXSDtime
    Description:    Format to XML Schema built in xsd:time type "hh:mm:ss".
    Parameters:
        pTime  : Time string
-->
<xsl:template name="toXSDtime"> <xsl:param name="pTime"/>

    <xsl:variable name="hour">
        <xsl:choose>
            <xsl:when test="contains($pTime, ':')">
                <xsl:value-of select="substring-before($pTime, ':')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($pTime, 1, 2)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="minsec">
        <xsl:choose>
            <xsl:when test="contains($pTime, ':')">
                <xsl:value-of select="substring-after($pTime, ':')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($pTime, 3)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="min">
        <xsl:choose>
            <xsl:when test="string-length($minsec) &gt; 0">
                <xsl:choose>
                    <xsl:when test="contains($minsec, ':')">
                        <xsl:value-of select="substring-before($minsec, ':')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring($minsec, 1, 2)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>00</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sec">
        <xsl:choose>
            <xsl:when test="string-length($minsec) &gt; 2">
                <xsl:choose>
                    <xsl:when test="contains($minsec, ':')">
                        <xsl:value-of select="substring-after($minsec, ':')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring($minsec, 3)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>00</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat($hour, ':', $min, ':', $sec)"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       TMtoXSDtime
    Description:    Format TM "hhmmss.frac" DICOM VR to XML Schema built in xsd:time type "hh:mm:ss".
    Parameters:
        pTime  : Time string
-->
<xsl:template name="TMtoXSDtime"> <xsl:param name="pTime"/>
    <xsl:value-of select="substring($pTime, 1, 2)"/>:<xsl:value-of
                  select="substring($pTime, 3, 2)"/>:<xsl:value-of
                  select="substring($pTime, 5, 2)"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       DTtoXSDdateTime
    Description:    Format DT "yyyymmddhhmmss.ffffff[+|-]zzzz" DICOM VR to XML Schema built in
                    xsd:dateTime type "ccyy-mm-ddThh:mm:ss".
    Parameters:
        pDateTime : DateTime string
-->
<xsl:template name="DTtoXSDdateTime"> <xsl:param name="pDateTime"/>
    <xsl:if test="$pDateTime">
    <xsl:choose>
        <xsl:when test="substring($pDateTime, 5, 1) = '-' and
                        substring($pDateTime, 8, 1) = '-' and
                        substring($pDateTime, 11, 1) = 'T' and
                        substring($pDateTime, 14, 1) = ':' and
                        substring($pDateTime, 17, 1) = ':'">
            <xsl:value-of select="$pDateTime"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring($pDateTime, 1, 4)"/>-<xsl:value-of
                          select="substring($pDateTime, 5, 2)"/>-<xsl:value-of
                          select="substring($pDateTime, 7, 2)"/>T<xsl:value-of
                          select="substring($pDateTime, 9, 2)"/>:<xsl:value-of
                          select="substring($pDateTime, 11, 2)"/>:<xsl:value-of
                          select="substring($pDateTime, 13, 2)"/>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatDate
    Description:    Formats XML Schema built in xsd:date type "ccyy-mm-dd" to international "yyyy-mm-dd"
                    or localized date format.
    Parameters:
        pDate  :    Date string
-->
<xsl:template name="formatDate"> <xsl:param name="pDate"/>

    <xsl:if test="$pDate != ''">
    <xsl:choose>
        <xsl:when test="$DICOM/@international_date_time = 'true'">
            <xsl:value-of select="$pDate"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="intlDatePattern">
                <xsl:choose>
                    <xsl:when test="string-length($pDate) = 4">yyyy</xsl:when>
                    <xsl:when test="string-length($pDate) &lt; 8">yyyy-MM</xsl:when>
                    <xsl:otherwise>yyyy-MM-dd</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="intlDateFormatter" select="java:java.text.SimpleDateFormat.new($intlDatePattern)"/>
            <xsl:variable name="date" select="java:parse($intlDateFormatter, $pDate)"/>
            <xsl:variable name="newDatePattern">
                <xsl:choose>
                    <xsl:when test="string-length($pDate) = 4">yyyy</xsl:when>
                    <xsl:when test="string-length($pDate) &lt; 8"><xsl:value-of select="$DICOM/@ymDateFormat"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$DICOM/@dateFormat"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- newDatePattern: [<xsl:value-of select="$newDatePattern"/>]-->
            <xsl:variable name="dateFormatter" select="java:java.text.SimpleDateFormat.new($newDatePattern)"/>
            <xsl:value-of select="java:format($dateFormatter, $date)"/>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatTime
    Description:    Formats XML Schema built in xsd:time type "hh:mm:ss.sss" to international "HH:mm:ss"
                    or localized time format.
    Parameters:
        pTime  :    Time string
-->
<xsl:template name="formatTime"> <xsl:param name="pTime"/>

    <xsl:if test="$pTime != ''">
    <!-- Remove UTC offset. -->
    <xsl:variable name="utcOffset">
        <xsl:choose>
            <xsl:when test="contains($pTime, '+')">
                <xsl:value-of select="concat('+', substring-after($pTime, '+'))"/>
            </xsl:when>
            <xsl:when test="contains($pTime, '-')">
                <xsl:value-of select="concat('-', substring-after($pTime, '-'))"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="hours_mins_secs_secsfraction">
        <xsl:choose>
            <xsl:when test="string-length($utcOffset) &gt; 0 and contains($pTime, $utcOffset)">
                <xsl:value-of select="substring-before($pTime, $utcOffset)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pTime"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="secsfraction">
        <xsl:if test="contains($hours_mins_secs_secsfraction, '.')">
            <xsl:value-of select="concat('.', substring-after($hours_mins_secs_secsfraction, '.'))"/>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="hours_mins_secs">
        <xsl:choose>
            <xsl:when test="string-length($secsfraction) &gt; 0 and contains($hours_mins_secs_secsfraction, $secsfraction)">
                <xsl:value-of select="substring-before($hours_mins_secs_secsfraction, $secsfraction)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$hours_mins_secs_secsfraction"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="xsdTime">
        <xsl:call-template name="toXSDtime">
            <xsl:with-param name="pTime" select="$hours_mins_secs"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$DICOM/@international_date_time = 'true'">
            <xsl:value-of select="concat($xsdTime, $secsfraction, $utcOffset)"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="intlTimeFormatter" select="java:java.text.SimpleDateFormat.new('HH:mm:ss')"/>
            <xsl:variable name="time" select="java:parse($intlTimeFormatter, $xsdTime)"/>
            <xsl:variable name="timeFormatter" select="java:java.text.SimpleDateFormat.new($DICOM/@timeFormat)"/>
            <xsl:value-of select="concat(java:format($timeFormatter, $time), $secsfraction, $utcOffset)"/>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatDateTime
    Description:    Format XML Schema built in xsd:dateTime type "ccyy-mm-ddThh:mm:ss" to
                    datetime "yyyy-mm-dd, hh:mm:ss".
    Parameters:
        pDTime    : DateTime string
-->
<xsl:template name="formatDateTime"> <xsl:param name="pDTime"/>
    <xsl:variable name="date">
        <xsl:choose>
            <xsl:when test="contains($pDTime, 'T')">
                <xsl:value-of select="substring-before($pDTime, 'T')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pDTime"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="time">
        <xsl:choose>
            <xsl:when test="contains($pDTime, 'T')">
                <xsl:value-of select="substring-after($pDTime, 'T')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="addDateAndTime">
        <xsl:with-param name="pDate" select="$date"/>
        <xsl:with-param name="pTime" select="$time"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Added for Cortex ID backward compatibility.
-->
<xsl:template name="formatSchemaDateTime"> <xsl:param name="PDTime"/>
    <xsl:call-template name="formatDateTime">
        <xsl:with-param name="pDTime" select="$PDTime"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatScientificNotationNumber
    Description:    Format numeric values that are represented with scientifc notation.
    Parameters:
        pNum        : Numeric value string
        pPattern    : Format pattern string
-->
<xsl:template name="formatScientificNotationNumber"> <xsl:param name="pNum"/>
                                                     <xsl:param name="pPattern" select="$numberFormat"/>

    <xsl:variable name="numWithE" select="translate($pNum, 'e', 'E')"/>
    <xsl:variable name="mantissa" select="substring-before($numWithE, 'E')"/>
    <xsl:variable name="exponent" select="substring-after($numWithE, 'E')"/>
    <xsl:choose>
    <!-- Check if the mantissa is number. -->
        <xsl:when test="number($mantissa) = $mantissa">
            <xsl:choose>
                <xsl:when test="string(number($exponent)) != 'NaN' and $exponent != 0">
                    <xsl:value-of select="concat(format-number($mantissa, $pPattern), 'E', $exponent)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number($mantissa, $pPattern)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$pNum"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatIfNumber
    Description:    If pNum is number than call format-number() XSLT function otherwise display the original value.
    Parameters:
        pNum        : Numeric value string
        pPattern    : Format pattern string
-->
<xsl:template name="formatIfNumber"> <xsl:param name="pNum"/>
                                     <xsl:param name="pPattern" select="$numberFormat"/>

    <xsl:choose>
        <xsl:when test="number($pNum) = $pNum">
            <xsl:value-of select="format-number($pNum, $pPattern)"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$pNum"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       formatNumericValue
    Description:    Format numeric values.
    Parameters:
        pNum        : Numeric value string
        pPattern    : Format pattern string
-->
<xsl:template name="formatNumericValue"> <xsl:param name="pNum"/>
                                         <xsl:param name="pPattern" select="$numberFormat"/>
    <xsl:if test="$pNum != ''">
        <xsl:choose>
            <xsl:when test="contains($pNum, 'E') or contains($pNum, 'e')">
                <xsl:call-template name="formatScientificNotationNumber">
                    <xsl:with-param name="pNum" select="$pNum"/>
                    <xsl:with-param name="pPattern" select="$pPattern"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($pNum, '.') or contains($pNum, ',')">
                <xsl:call-template name="formatIfNumber">
                    <xsl:with-param name="pNum" select="$pNum"/>
                    <xsl:with-param name="pPattern" select="$pPattern"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$pNum &gt; 1000">
                        <xsl:call-template name="formatIfNumber">
                            <xsl:with-param name="pNum" select="$pNum"/>
                            <xsl:with-param name="pPattern" select="$pPattern"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$pNum"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       multiplyNumericValue
    Description:    Multiply the pNum with 10^pExponent.
    Parameters:
        pNum      :  Numeric value string
        pExponent :  Integer value string
-->
<xsl:template name="multiplyNumericValue">
    <xsl:param name="pNum"/>
    <xsl:param name="pExponent" select="0"/>
    
    <xsl:choose>
        <xsl:when test="contains($pNum,'E') or contains($pNum,'e')">
            <xsl:variable name="numWithE" select="translate($pNum, 'e', 'E')"/>
            <xsl:variable name="mantissa" select="substring-before($numWithE, 'E')"/>
            <xsl:variable name="exponent" select="substring-after($numWithE, 'E')"/>
            <xsl:value-of select="concat(number($mantissa),'E',number($exponent) + number($pExponent))"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="numCoefficient" select="java:java.lang.Math.pow(10, $pExponent)"/>
            <xsl:value-of select="number($numCoefficient) * number($pNum)"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       hasContent
    Description:    Check if there is a not empty TEXT item or any other item among the specified content items.
    Parameters:
        pItems   :
-->
<xsl:template name="hasContent"> <xsl:param name="pItems"/>

    <xsl:variable name="firstItem" select="$pItems[position() = 1]"/>
    <xsl:choose>
        <xsl:when test="$firstItem and (not($firstItem/ValueType_TEXT) or ($firstItem/ValueType_TEXT and $firstItem/TextValue != '' and $firstItem/TextValue != $NO_CONTENT))">
            <xsl:value-of select="true()"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="remainingItems" select="$pItems[position() != 1]"/>
            <xsl:choose>
                <xsl:when test="count($remainingItems) = 0">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="hasContent">
                        <xsl:with-param name="pItems" select="$remainingItems"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDValue
    Description:    Add patient demographics value specific to the field.
        pPDItem   :  Patient demographics item in the template.
-->
<xsl:template name="addPDValue"> <xsl:param name="pPDItem"/>

    <xsl:choose>
<!-- Identification -->
<!-- Patient ID -->
        <xsl:when test="$pPDItem/@name = 'LBL_PATIENTID'">
            <xsl:value-of select="$DICOM/PatientID"/>
        </xsl:when>
<!-- Patient Name -->
        <xsl:when test="$pPDItem/@name = 'LBL_NAME'">
            <xsl:call-template name="formatPersonName">
                <xsl:with-param name="PName" select="$DICOM/PatientName"/>
            </xsl:call-template>
        </xsl:when>
<!-- Birthdate -->
        <xsl:when test="$pPDItem/@name = 'LBL_BIRTHDATE'">
            <xsl:call-template name="formatDate">
                <xsl:with-param name="pDate" select="$DICOM/PatientBirthDate"/>
            </xsl:call-template>
        </xsl:when>
<!-- Age -->
        <xsl:when test="$pPDItem/@name = 'LBL_AGE'">
            <xsl:call-template name="addAgeText">
                <xsl:with-param name="pAge" select="$DICOM/PatientAge"/>
            </xsl:call-template>
        </xsl:when>
<!-- Sex -->
        <xsl:when test="$pPDItem/@name = 'LBL_SEX'">
            <xsl:call-template name="addSexText">
                <xsl:with-param name="PSex" select="$DICOM/PatientSex"/>
            </xsl:call-template>
        </xsl:when>
<!-- Ethnic Group -->
        <xsl:when test="$pPDItem/@name = 'LBL_ETHNIC_GROUP'">
            <xsl:call-template name="addEthnicGroup"/>
        </xsl:when>
<!-- Study date and time -->
        <xsl:when test="$pPDItem/@name = 'LBL_STUDYDATE'">
            <xsl:call-template name="addDateAndTime">
                <xsl:with-param name="pDate" select="$DICOM/StudyDate"/>
                <xsl:with-param name="pTime" select="$DICOM/StudyTime"/>
            </xsl:call-template>
        </xsl:when>
<!-- Study ID -->
        <xsl:when test="$pPDItem/@name = 'LBL_STUDYID'">
            <xsl:value-of select="$DICOM/StudyID"/>
        </xsl:when>
<!-- Accession Number -->
        <xsl:when test="$pPDItem/@name = 'LBL_ACCESSION_NUMBER'">
            <xsl:value-of select="$DICOM/AccessionNumber"/>
        </xsl:when>
<!-- Content date and time -->
        <xsl:when test="$pPDItem/@name = 'LBL_CONTENT_DATE'">
            <xsl:call-template name="addDateAndTime">
                <xsl:with-param name="pDate" select="$DICOM/ContentDate"/>
                <xsl:with-param name="pTime" select="$DICOM/ContentTime"/>
            </xsl:call-template>
        </xsl:when>

<!-- ======================================== Medical History ======================================== -->
<!-- Weight -->
        <xsl:when test="$pPDItem/@name = 'LBL_WEIGHT'">
            <xsl:call-template name="addWeight">
                <xsl:with-param name="pWeight" select="$DICOM/PatientWeight"/>
            </xsl:call-template>
        </xsl:when>
<!-- Height -->
        <xsl:when test="$pPDItem/@name = 'LBL_HEIGHT'">
            <xsl:call-template name="addHeight">
                <xsl:with-param name="pHeight" select="$DICOM/PatientSize"/>
            </xsl:call-template>
        </xsl:when>
<!-- Body Surface Area -->
        <xsl:when test="$pPDItem/@name = 'LBL_BODY_SURFACE_AREA'">
            <xsl:call-template name="addBSA">
                <xsl:with-param name="pWeight" select="$DICOM/PatientWeight"/>
                <xsl:with-param name="pHeight" select="$DICOM/PatientSize"/>
            </xsl:call-template>
        </xsl:when>
<!-- Body Mass Index -->
        <xsl:when test="$pPDItem/@name = 'LBL_BODY_MASS_INDEX'">
            <xsl:call-template name="addBMI">
                <xsl:with-param name="pWeight" select="$DICOM/PatientWeight"/>
                <xsl:with-param name="pHeight" select="$DICOM/PatientSize"/>
            </xsl:call-template>
        </xsl:when>

<!-- ======================================== Physician Info ======================================== -->
<!-- (J-0016E, SNM3, Doctor) -->
        <!--xsl:when test="$pPDItem/@name = 'LBL_ORDERING_PHYSICIAN'">
            <xsl:variable name="orderingPhysician" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'J-0016E' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$orderingPhysician"/>
            </xsl:call-template>
        </xsl:when-->
<!-- (J-06170, SNM3, Radiologist) -->
        <xsl:when test="$pPDItem/@name = 'LBL_REFERRING_PHYSICIAN'">
            <xsl:variable name="referringPhysician" select="$DICOM/ReferringPhysiciansName"/>
            <xsl:call-template name="formatPersonName">
                <xsl:with-param name="PName" select="$referringPhysician"/>
            </xsl:call-template>
        </xsl:when>

<!-- Completion Flag -->
        <xsl:when test="$pPDItem/@name = 'LBL_COMPLETION_FLAG'">
            <xsl:value-of select="$DICOM/CompletionFlag"/>
        </xsl:when>
<!-- Verification Flag -->
        <xsl:when test="$pPDItem/@name = 'LBL_VERIFICATION_FLAG'">
            <xsl:value-of select="$DICOM/VerificationFlag"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$DICOM/*[@tag = $pPDItem/@tag]"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addEthnicGroup
    Description:    Adds Body Surface Area.
    Parameters:
-->
<xsl:template name="addEthnicGroup">
    <xsl:value-of select="$DICOM/EthnicGroup"/>
</xsl:template>

</xsl:stylesheet>
