<?xml version="1.0" encoding="utf-8"?>
<!-- ####################################################################################################
    Copyright (c) 2004 GE Healthcare

    VV_FO.XSL       :   Volume Viewer specific XSLT templates for SR to XSL-FO transformation.

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:import href="GEN_FO.XSL"/>
<xsl:include href="../VV_GEN.XSL"/>

<!-- ####################################################################################################
    Template:       addCurrentProcedureDescriptions
    Description:    Adds (121064, DCM, Current Procedure Descriptions) as a table to the report.
    Parameters:
        pItem    :
-->
<xsl:template name="addCurrentProcedureDescriptions">
    <xsl:param name="pItem"/>
    <xsl:param name="pPosition"/>

    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="8pt" space-after="8pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
        <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
    </fo:block>
<!-- Equal width columns based on the number of sub content items in Current Procedure Descriptions -->
    <fo:table table-layout="fixed" width="100%">
        <xsl:for-each select="$pItem/ContentSequence/Item">
            <fo:table-column column-width="proportional-column-width(1)"/>
        </xsl:for-each>
        <fo:table-header>
            <fo:table-row>
                <xsl:for-each select="$pItem/ContentSequence/Item">
                    <fo:table-cell padding-bottom="4pt">
                        <fo:block text-align="center">
                            <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/></fo:inline>
                        </fo:block>
                    </fo:table-cell>
                </xsl:for-each>
            </fo:table-row>
        </fo:table-header>
        <fo:table-body>
            <fo:table-row>
                <xsl:for-each select="$pItem/ContentSequence/Item">
                    <fo:table-cell>
                        <fo:block text-align="center">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                </xsl:for-each>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
    <fo:block text-align="center">
        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
    </fo:block>
</xsl:template>

</xsl:stylesheet>
