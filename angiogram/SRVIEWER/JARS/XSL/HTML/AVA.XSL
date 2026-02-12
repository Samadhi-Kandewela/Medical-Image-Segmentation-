<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002 General Electric Medical Systems, Hungary


    srxml2html_ava.xsl     :   AVA specific XSLT rules for SR to HTML transformation.

    Created on      :   Apr 08, 2002
    Author          :   Attila RACZ
    Last modified on:   Apr 02, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="GEN_HTM.XSL"/>
<xsl:include href="SECT_HTM.XSL"/>
<xsl:include href="VV_HTM.XSL"/>

<xsl:output method="html" indent="yes"/>

<!-- Declare a key for vessel image SOP Instance UIDs for DISTINCT processing. -->
<xsl:key name="codeKey" use="CodeValue" match="/DICOM/ContentSequence/Item/ContentSequence/Item/ConceptNameCodeSequence/Item"/>


<xsl:template match="/">

    <HTML>
    <HEAD>
        <TITLE>
            <xsl:value-of select="DICOM/ConceptNameCodeSequence/Item/CodeMeaning"/>,
            <xsl:call-template name="formatPersonName">
                <xsl:with-param name="PName" select="DICOM/PatientName"/>
            </xsl:call-template>
            (<xsl:call-template name="addSexText">
                <xsl:with-param name="PSex" select="DICOM/PatientSex"/>
            </xsl:call-template>,
            #<xsl:value-of select="DICOM/PatientID"/>)
        </TITLE>
        <STYLE type="text/css">
            H2 {color: #9999CC}
            TH {text-decoration: underline}
        </STYLE>
        <xsl:call-template name="addJavaScript"/>
    </HEAD>
    <BODY onLoad="onLoadBody()" style="font-family: {$customizations/Font/@type}; font-size: {$customizations/Font/@size}pt">
        <xsl:choose>
            <xsl:when test="$DICOM/@mode = 'ed'">
                <FORM NAME='form1'>
                    <xsl:call-template name="processSections"/>
                    <INPUT TYPE='button' NAME='Submit' VALUE='Save' onclick="submitOnClick()"></INPUT>
                </FORM>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processSections"/>
            </xsl:otherwise>
        </xsl:choose>
    </BODY>
  </HTML>

</xsl:template>


<!-- ####################################################################################################
    Template:       addContentItem
    Description:    Add content item to report.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addContentItem">
    <xsl:param name="pItem"/>

    <A name="{translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, ' ', '')}"/>
    <xsl:choose>
<!-- (121064, DCM, Current Procedure Descriptions) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121064' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM'">
            <xsl:call-template name="addCurrentProcedureDescriptions">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:when>

<!-- Image Library -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '111028' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM'">
            <H2><xsl:value-of select="$DICOM/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = '111028' and ../CodingSchemeDesignator = 'DCM']"/></H2>
            <TABLE width="100%" border="1" style="font-family: {$customizations/Font/@type}; font-size: {$customizations/Font/@size}pt">
                <TR>
                    <TH>
                    <xsl:for-each select="$DICOM/ContentSequence/Item/ContentSequence/Item/ConceptNameCodeSequence/Item[CodeValue='AVA-0002']">
                        <xsl:if test="generate-id(.) = generate-id(key('codeKey', CodeValue))">
                            <xsl:value-of select="CodeMeaning"/>
                        </xsl:if>
                    </xsl:for-each>
                    </TH>
                    <TH>
                        Images
                    </TH>
                </TR>
                <xsl:for-each select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS' and ConceptNameCodeSequence/Item/CodeValue = '111028' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM']">
                <TR>
                    <TD><B>
                    <xsl:value-of select="ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning"/>
                    </B></TD>
                    <TD align="center" width="75%">
                    <TABLE style="font-family: {$customizations/Font/@type}; font-size: {$customizations/Font/@size}pt">
                    <TR>
                    <xsl:for-each select="ContentSequence/Item">
                        <xsl:if test="ValueType_IMAGE">
                            <TD>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                            </TD>
                        </xsl:if>
                    </xsl:for-each>
                    </TR>
                    </TABLE>
                    </TD>
                </TR>
                </xsl:for-each>
            </TABLE>
        </xsl:when>

<!-- Findings -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121070' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM'">
            <H2><xsl:value-of select="$DICOM/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = '121070' and ../CodingSchemeDesignator = 'DCM']"/></H2>
            <TABLE width="100%" border="1" style="font-family: {$customizations/Font/@type}; font-size: {$customizations/Font/@size}pt">
            <TR>
                <TH><xsl:value-of select="$pItem/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue='AVA-0003']"/></TH>
                <TH>Measurements</TH>
            </TR>
            <xsl:for-each select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121070' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM']">
                <TR>
<!-- Scope of Findings -->
                    <TD>
                    <xsl:for-each select="ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue='AVA-0003']">
                        <B>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()"/>
                        </xsl:call-template>
                        </B>
<!-- Label of Finding -->
                        (<xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/following::Item[ConceptNameCodeSequence/Item/CodeValue='AVA-0004']"/>
                        </xsl:call-template>)
<!-- Finding modifiers -->
                        <TABLE width="100%" border="0">
                        <TR>
                            <TD align="right">
                            <TABLE width="100%" border="0" cols="2" style="font-family: {$customizations/Font/@type}; font-size: {$customizations/Font/@size}pt">
                            <xsl:for-each select="ContentSequence/Item">
                                <TR>
                                    <TH><xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/></TH>
                                </TR>
                                <TR>
                                    <TD align="center"><xsl:value-of select="ConceptCodeSequence/Item/CodeMeaning"/></TD>
                                </TR>
                            </xsl:for-each>
                            </TABLE>
                            </TD>
                        </TR>
                        </TABLE>
                    </xsl:for-each>
                    </TD>
<!-- Measurements -->
                    <TD width="75%" align="center">
                    <TABLE width="100%" border="0" style="font-family: {$customizations/Font/@type}; font-size: {$customizations/Font/@size}pt">
                    <TR>
                        <xsl:for-each select="ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue!='AVA-0003']">
                            <TH>
                                <xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/>
                            </TH>
                        </xsl:for-each>
                    </TR>
                    <TR>
                        <xsl:for-each select="ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue!='AVA-0003']">
                            <TD align="center">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                            <xsl:for-each select="ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue='R-00363' and ConceptNameCodeSequence/Item/CodingSchemeDesignator='SNM3']">
                                <xsl:text disable-output-escaping="yes"> &amp;plusmn; </xsl:text>
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="current()"/>
                                </xsl:call-template>
                            </xsl:for-each>
                            </TD>
                        </xsl:for-each>
                    </TR>
                    </TABLE>
<!-- Best Illustration of finding -->
                    <TABLE width="100%" border="0" style="font-family: {$customizations/Font/@type}; font-size: {$customizations/Font/@size}pt">
                    <TR>
                        <xsl:for-each select="current()/ContentSequence/Item/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue='121080' and ConceptNameCodeSequence/Item/CodingSchemeDesignator='DCM']">
<!-- Distinct images of all measurements under the current finding -->
                            <xsl:choose>
                                <xsl:when test="position() = 1">
                                    <TD align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()"/>
                                        </xsl:call-template>
                                    </TD>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="precedingImage" select="current()/preceding-sibling::Item[1]"/>
                                    <xsl:if test="current()/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID != $precedingImage/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID">
                                        <TD align="center">
                                            <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="current()"/>
                                            </xsl:call-template>
                                        </TD>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </TR>
                    </TABLE>
                    </TD>
                </TR>
            </xsl:for-each>
            </TABLE>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
