<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2004 GE Healthcare

    FUNC_HTM.XSL    :   Commonly used XSLT temaplates for HTML output for Functool.

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

<!-- ####################################################################################################
    Template:       addImageValue
    Description:    Add the value of image to HTML.
    Parameters:
        pCurrent :  The current node of processing
-->

<xsl:template name="addImageValue">
    <xsl:param name="pCurrent"/>
            <xsl:call-template name="addZoomImage">
                <xsl:with-param name="pSOPClassUID" select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPClassUID"/>
                <xsl:with-param name="pSOPInstUID" select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID"/>
                <xsl:with-param name="pIconImageSeq" select="$pCurrent/ReferencedSOPSequence/Item/IconImageSequence"/>
            </xsl:call-template>

</xsl:template>

<xsl:template name="addZoomImage"> <xsl:param name="pSOPClassUID"/> <xsl:param name="pSOPInstUID"/> <xsl:param name="pIconImageSeq"/>
    <A>
    <xsl:attribute name="href">javascript:showImageByUID('<xsl:value-of select="$pSOPInstUID"/>')</xsl:attribute>
    <xsl:attribute name="title">
        <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = $pSOPClassUID]/@abbrev"/>
    </xsl:attribute>
    <IMG>
    <xsl:choose>
        <xsl:when test="$pIconImageSeq">
            <xsl:attribute name="src">
                <xsl:value-of select="concat('../IMAGE/', $pSOPInstUID, '_ico.png')"/>
            </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="src">
                <xsl:value-of select="concat('../IMAGE/', $pSOPInstUID, '.jpg')"/>
            </xsl:attribute>
            <xsl:attribute name="style">width: 480px; height: 480px;</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
    </IMG>
    </A>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNumValue
    Description:    Add the value of Nummeric value for Functool.
    Parameters:
        pCurrent :  The current node of processing
-->

<xsl:template name="addNumValue">
    <xsl:param name="pCurrent"/>

    <xsl:choose>
        <xsl:when test="$pCurrent/ValueType_NUM">
            <xsl:choose>
                <xsl:when test="$DICOM/@mode = 'ed' and $pCurrent/MeasuredValueSequence/Item/NumericValue = ''">
                    <INPUT type="text" id="{$pCurrent/@id}" name="NumericValue" size="{string-length($pCurrent/MeasuredValueSequence/Item/NumericValue) + 1}" value="{$pCurrent/MeasuredValueSequence/Item/NumericValue}" onFocus="store(value)" onKeyUp="validateNum(this)"/>
                </xsl:when>
            </xsl:choose>
            <xsl:value-of select="concat(' ', $pCurrent/MeasuredValueSequence/Item/NumericValue)"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>


</xsl:stylesheet>
