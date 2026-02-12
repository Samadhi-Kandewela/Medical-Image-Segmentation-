<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2004 GE Healthcare

    FO_GEN.XSL      :   Generic XSLT rules for SR to XSL-FO transformation.
                        Recursive tree traversal to get out every content item.

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:include href="GEN_FO.XSL"/>
<xsl:include href="SECT_FO.XSL"/>

<xsl:output method="xml" indent="yes"/>

<xsl:key name="content-item" match="Item" use="ConceptNameCodeSequence/Item/CodeValue"/>


<xsl:template match="/">

    <fo:root font-family="{$tp/Font/@type}" font-size="{$fontSize}pt" xmlns:fox="http://xml.apache.org/fop/extensions">

<!-- Page settings (media, height and width) -->
        <xsl:call-template name="addLayoutMasterSet"/>

<!-- Bookmarks to report sections -->
        <xsl:call-template name="addBookmarks"/>

        <fo:page-sequence master-reference="SimpleMaster">
<!-- Report footer -->
            <xsl:call-template name="addFooter"/>
<!-- Report content -->
            <xsl:call-template name="processSections"/>
        </fo:page-sequence>

    </fo:root>

</xsl:template>

<!-- ####################################################################################################
    Template:       addContentItem
    Description:    Add content item to report.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addContentItem"> <xsl:param name="pItem"/>
                                     <xsl:param name="pPosition"/>

    <xsl:if test="$pItem/RelationshipType = 'CONTAINS'">
        <fo:block id="{concat(translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
            <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
        </fo:block>
    </xsl:if>
    <xsl:choose>
    <!-- (PQ-0110, 99GEMS, Patient Questions) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
            <xsl:call-template name="addPatientQuestions">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="addItemWithGeneric">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
