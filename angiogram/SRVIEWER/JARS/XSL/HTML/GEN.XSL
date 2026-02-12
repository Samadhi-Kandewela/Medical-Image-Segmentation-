<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2005 GE Healthcare

    HTM_GEN.XSL     :   Generic XSLT rules for SR to HTML transformation.
                        Recursive tree traversal to get out every content item.

    Author          :   Attila RACZ
    Last modified on:   Jan 12, 2005
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="GEN_HTM.XSL"/>
<xsl:include href="SECT_HTM.XSL"/>

<xsl:output method="xml"
            indent="yes"
            encoding="UTF-8"
            doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<xsl:template match="/">

    <html>
        <xsl:call-template name="addHTMLHead"/>
        <xsl:call-template name="addHTMLBody"/>
    </html>

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
        <a name="{concat(translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition)}"/>
        <xsl:if test="$pItem/ConceptNameCodeSequence/Item/CodeMeaning">
            <h2><xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/></h2>
        </xsl:if>
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
