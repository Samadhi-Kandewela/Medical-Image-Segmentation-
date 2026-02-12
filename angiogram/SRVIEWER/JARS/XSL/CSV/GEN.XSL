<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2006 GE Healthcare

    GEN.XSL      :   Generic XSLT rules for SR to CSV transformation.
    @author raczatt
    @date Nov 29, 2006
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../GEN.XSL"/>

<xsl:output method="text"
            indent="yes"
            encoding="UTF-8"/>

<xsl:template match="/">
    <xsl:value-of select="$messagecatalog/MSG_CSV_NOT_SUPPORTED/msg[@lang = $lang]"/>
</xsl:template>


</xsl:stylesheet>
