<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    VV.XSL - Volume Viewer specific XSLT rules for SR to XLS transformation.
    @author raczatt
    @date Feb 19, 2008
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:x="urn:schemas-microsoft-com:office:excel">

<xsl:import href="../HTML/VV.XSL"/>

<xsl:output method="html" indent="yes"
            doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
            doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

<xsl:template match="/">

    <html>
        <xsl:call-template name="addHTMLHead"/>
        <xsl:call-template name="addHTMLBody"/>
    </html>

</xsl:template>

</xsl:stylesheet>
