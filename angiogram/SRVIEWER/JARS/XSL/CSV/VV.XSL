<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    VCAR.XSL - PETVCAR specific XSLT rules for SR to CSV transformation.
    @author raczatt
    @date Jul 11, 2007
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="SECT_CSV.XSL"/>
<xsl:import href="../HTML/GEN_HTM.XSL"/>
<xsl:include href="../VV_GEN.XSL"/>
<xsl:include href="VCAR.XSL"/>

<xsl:output method="text"
            indent="yes"
            encoding="UTF-8"/>

<xsl:template match="/">
    <xsl:choose>
<!-- Display CSV report only for PETVCAR. -->
        <xsl:when test="contains($DICOM/ApplicationSpecificData, 'PETVCAR')">
            <xsl:call-template name="processSections"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$messagecatalog/MSG_CSV_NOT_SUPPORTED/msg[@lang = $lang]"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addContentItem
    Description:    Add content item to report based on different cardiac protocols.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addContentItem"> <xsl:param name="pItem"/>
                                     <xsl:param name="pPosition"/>

    <xsl:if test="$pItem/ConceptNameCodeSequence/Item/CodeMeaning">
        <xsl:call-template name="addContainerName">
            <xsl:with-param name="pItem" select="$pItem"/>
        </xsl:call-template>
        <xsl:value-of select="$LF"/>
    </xsl:if>

    <xsl:choose>
        <xsl:when test="contains($pItem/@app, 'VV')">
        </xsl:when>
        <xsl:when test="contains($pItem/@app, 'PETVCAR')">
            <xsl:call-template name="addPETVCARContentItem">
                <xsl:with-param name="pItem" select="$pItem"/>
                <xsl:with-param name="pPosition" select="$pPosition"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$LF"/>
</xsl:template>

</xsl:stylesheet>