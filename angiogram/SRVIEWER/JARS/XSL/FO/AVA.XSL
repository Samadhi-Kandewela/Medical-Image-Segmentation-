<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2005 GE Healthcare

    FO_VV.XSL       :   AVA specific XSLT rules for SR to XSL-FO transformation.

    Author          :   Attila RACZ
    Last modified on:   Jun 27, 2005
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg">

<xsl:include href="GEN_FO.XSL"/>

<xsl:output method="xml" indent="yes"/>

<xsl:variable name="PEN_COLOR">0000FF</xsl:variable>

<xsl:template match="/">

    <fo:root font-family="Helvetica" font-size="10pt">

<!-- Page settings (media, height and width) -->
        <xsl:call-template name="addLayoutMasterSet"/>

        <fo:page-sequence master-reference="SimpleMaster">
            <fo:flow flow-name="xsl-region-body">
                <xsl:for-each select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS']">
                    <xsl:choose>
                        <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = 'A-25500' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                            <xsl:call-template name="addAAA">
                                <xsl:with-param name="pItem" select="current()"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </fo:flow>
        </fo:page-sequence>

    </fo:root>

</xsl:template>

</xsl:stylesheet>
