<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2006 GE Healthcare

    XML_GEN.XSL     :   Generic XSLT rules for SR to simple XML transformation.
    @author raczatt
    @date Feb 07, 2006
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../GEN.XSL"/>

<xsl:output method="xml"
            indent="yes"
            encoding="UTF-8"/>


<xsl:template match="/">

    <Report>
        <xsl:if test="$clinicalUse = 'false'">
            <Warning>NOT for clinical use !</Warning>
        </xsl:if>
        <Title><xsl:value-of select="$DICOM/ConceptNameCodeSequence/Item/CodeMeaning"/></Title>
        <State><xsl:value-of select="$DICOM/CompletionFlag"/></State>
        <Patient>
            <Name><xsl:value-of select="$DICOM/PatientName"/></Name>
            <ID><xsl:value-of select="$DICOM/PatientID"/></ID>
            <BirthDate><xsl:value-of select="$DICOM/PatientBirthDate"/></BirthDate>
            <Sex><xsl:value-of select="$DICOM/PatientSex"/></Sex>
            <Size><xsl:value-of select="$DICOM/PatientSize"/> m</Size>
            <Weight><xsl:value-of select="$DICOM/PatientWeight"/> kg</Weight>
        </Patient>
        <Exam>
            <ID><xsl:value-of select="$DICOM/StudyID"/></ID>
            <Date>
                <xsl:value-of select="$DICOM/StudyDate"/>
                <xsl:if test="$DICOM/StudyTime != ''">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$DICOM/StudyTime"/>
                </xsl:if>
            </Date>
            <Description><xsl:value-of select="$DICOM/StudyDescription"/></Description>
        </Exam>
        <Content>
            <Date>
                <xsl:value-of select="$DICOM/ContentDate"/>
                <xsl:if test="$DICOM/ContentTime != ''">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$DICOM/ContentTime"/>
                </xsl:if>
            </Date>
            <xsl:call-template name="processContentItems">
                <xsl:with-param name="pCurrent" select="$DICOM"/>
            </xsl:call-template>
        </Content>
    </Report>

</xsl:template>

<!-- ####################################################################################################
    Template:       processContentItems
    Description:    .
-->
<xsl:template name="processContentItems"> <xsl:param name="pCurrent"/>
    <xsl:for-each select="$pCurrent/ContentSequence/Item">
        <xsl:variable name="cv" select="current()/ConceptNameCodeSequence/Item/CodeValue"/>
        <xsl:variable name="csd" select="current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator"/>
        <xsl:variable name="cm" select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/>
<!-- Remove invalid characters from CodeMeaning of the current content item. -->
        <xsl:variable name="cmTranslated" select="translate($cm, $INVALID_NAME_CHARS, '')"/>
        <xsl:variable name="elementName">
            <xsl:choose>
                <xsl:when test="string-length($cmTranslated) = 0">n.a.</xsl:when>
                <xsl:otherwise><xsl:value-of select="$cmTranslated"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$elementName}">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="current()"/>
            </xsl:call-template>
            <xsl:if test="$pCurrent/ContentSequence/Item">
                <xsl:call-template name="processContentItems">
                    <xsl:with-param name="pCurrent" select="current()"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:element>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       processContentItems
    Description:    .
-->
<xsl:template name="addValue"> <xsl:param name="pCurrent"/>

    <xsl:choose>
        <xsl:when test="$pCurrent/ValueType_TEXT or $pCurrent/ValueType = 'TEXT'">
            <xsl:value-of select="$pCurrent/TextValue"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_CODE or $pCurrent/ValueType = 'CODE'">
            <xsl:value-of select="$pCurrent/ConceptCodeSequence/Item/CodeMeaning"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_NUM or $pCurrent/ValueType = 'NUM'">
            <xsl:value-of select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
            <xsl:if test="$pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue != '1'">
                <xsl:text> </xsl:text>
                <xsl:value-of select="$pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
            </xsl:if>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_PNAME or $pCurrent/ValueType = 'PNAME'">
            <xsl:value-of select="$pCurrent/PersonName"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_DATE or $pCurrent/ValueType = 'DATE'">
            <xsl:value-of select="$pCurrent/Date"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_TIME or $pCurrent/ValueType = 'TIME'">
            <xsl:value-of select="$pCurrent/Time"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_DATETIME or $pCurrent/ValueType = 'DATETIME'">
            <xsl:value-of select="$pCurrent/DateTime"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_UIDREF or $pCurrent/ValueType = 'UIDREF'">
            <xsl:value-of select="$pCurrent/UID"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_COMPOSITE or $pCurrent/ValueType = 'COMPOSITE'">
            <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = $pCurrent/ReferencedSOPSequence/Item/ReferencedSOPClassUID]/@abbrev"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_IMAGE or $pCurrent/ValueType = 'IMAGE'">
            <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = $pCurrent/ReferencedSOPSequence/Item/ReferencedSOPClassUID]/@abbrev"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_WAVEFORM or $pCurrent/ValueType = 'WAVEFORM'">
            <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = $pCurrent/ReferencedSOPSequence/Item/ReferencedSOPClassUID]/@abbrev"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_SCOORD or $pCurrent/ValueType = 'SCOORD'">
            <xsl:value-of select="$pCurrent/GraphicType"/>: <xsl:value-of select="$pCurrent/GraphicData"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_TCOORD or $pCurrent/ValueType = 'TCOORD'">
            <xsl:value-of select="$pCurrent/TemporalRangeType"/>: <xsl:value-of select="$pCurrent/ReferencedTimeOffsets"/>
        </xsl:when>
    </xsl:choose>

</xsl:template>

</xsl:stylesheet>
