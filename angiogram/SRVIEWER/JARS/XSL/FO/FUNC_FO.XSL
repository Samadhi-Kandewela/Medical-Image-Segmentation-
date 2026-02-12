<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2004 GE Healthcare

    FUNC_FO.XSL     :   Commonly used XSLT temaplates for FO output for Functool.

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

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
            <xsl:value-of select="concat(' ', $pCurrent/MeasuredValueSequence/Item/NumericValue)"/>
        </xsl:when>
    </xsl:choose>
</xsl:template>
</xsl:stylesheet>
