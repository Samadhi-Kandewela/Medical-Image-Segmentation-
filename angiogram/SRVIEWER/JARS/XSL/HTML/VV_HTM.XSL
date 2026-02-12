<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ====================================================================================================
    Copyright (c) 2004 GE Healthcare

    VV_HTM.XSL      :   Volume Viewer specific XSLT templates for SR to HTML transformation.

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:include href="../VV_GEN.XSL"/>

<!-- ####################################################################################################
    Template:       addCurrentProcedureDescriptions
    Description:    Adds (121064, DCM, Current Procedure Descriptions) as a table to the report.
    Parameters:
        pItem    :  Current Procedure Descriptions CONTAINER item.
-->
<xsl:template name="addCurrentProcedureDescriptions">
    <xsl:param name="pItem"/>

    <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <tr>
    <xsl:for-each select="$pItem/ContentSequence/Item">
        <th>
        <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/>
        </th>
    </xsl:for-each>
    </tr>
    <tr>
    <xsl:for-each select="$pItem/ContentSequence/Item">
        <td align="center">
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="current()"/>
        </xsl:call-template>
        </td>
    </xsl:for-each>
    </tr>
    </table>
    <hr/>
</xsl:template>

</xsl:stylesheet>
