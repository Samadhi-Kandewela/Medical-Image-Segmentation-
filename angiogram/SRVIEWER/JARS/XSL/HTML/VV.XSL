<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    VV.XSL - Volume Viewer specific XSLT rules for SR to XHTML transformation.
    @author raczatt
    @date Jul 11, 2007
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="SECT_HTM.XSL"/>
<xsl:import href="GEN_HTM.XSL"/>
<xsl:include href="VV_HTM.XSL"/>
<xsl:include href="VCAR.XSL"/>

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
    Description:    Add content item to report based on different cardiac protocols.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addContentItem"> <xsl:param name="pItem"/>
                                     <xsl:param name="pPosition"/>

    <xsl:if test="$pItem/RelationshipType = 'CONTAINS'">
        <a name="{concat(translate($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition)}"/>
    <!-- (VV-008, 99GEMS, Name) Section titles are displayed separately from the sections content in HTML.
    In FO they are displayed together in fo:table to keep them together. -->
        <xsl:if test="$pItem/ConceptNameCodeSequence/Item/CodeMeaning">
            <h2>
                <xsl:call-template name="addContainerName">
                    <xsl:with-param name="pItem" select="$pItem"/>
                </xsl:call-template>
            </h2>
        </xsl:if>
        <xsl:choose>
    <!-- (PQ-0110, 99GEMS, Patient Questions) -->
            <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                <xsl:call-template name="addPatientQuestions">
                    <xsl:with-param name="pItem" select="$pItem"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($pItem/@app, 'VV')">
                <xsl:call-template name="addVVContentItem">
                    <xsl:with-param name="pItem" select="$pItem"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($pItem/@app, 'PETVCAR')">
                <xsl:call-template name="addPETVCARContentItem">
                    <xsl:with-param name="pItem" select="$pItem"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="addItemWithGeneric">
                    <xsl:with-param name="pItem" select="$pItem"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addVVContentItem
    Description:    Add CardIQ, CTC, ALA, CardIQ Function content items to report.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addVVContentItem"> <xsl:param name="pItem"/>
                                       <xsl:param name="pPosition"/>

    <xsl:choose>
<!-- The content item is coming from an application specific report. -->
        <xsl:when test="$pItem/@app">
            <xsl:choose>
        <!-- (121064, DCM, Current Procedure Descriptions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121064' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = 'DCM'">
                    <xsl:call-template name="addCurrentProcedureDescriptions">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (121071, DCM, Finding) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121071' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                    <xsl:call-template name="addFinding">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (M-01470, SNM3, Plaque) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'M-01470' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addPlaque">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (M-32200, SNM3, Aneurysm) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'M-32200' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addAneurysm">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (F-30164, SNM3, Cardiac Finding) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'F-30164' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addCardiacFinding">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (F-32000, SRT, Cardiac Function) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'F-32000' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                    <xsl:call-template name="addCardiacFunction">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (M-76800, SNM3, Polyp) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'M-76800' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addPolyp">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-006, 99GEMS, Extra Finding) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-006' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addExtraFinding">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (ALA-029, 99GEMS, Scan Parameters) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'ALA-029' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addScanParameters">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (M-03010, SRT, Nodule) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'M-03010' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                    <xsl:call-template name="addNodule">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (T-28000, SRT, Lung) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'T-28000' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                    <xsl:call-template name="addLung">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-024, 99GEMS, General Images) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-024' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addGeneralImages">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-020, 99GEMS, Pre Exam) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-020' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addPreExam">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-019, 99GEMS, Post Exam) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-019' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addPostExam">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (121076, DCM, Conclusions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121076' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                    <xsl:call-template name="addPostExam">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pWithSubTitles" select="'false'"/>
                    </xsl:call-template>
                </xsl:when>

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
        </xsl:when>
        <xsl:otherwise>
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
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPreExam
    Description:    Adds Pre Exam content item.
    Parameters:
        pItem    :  (VV-020, 99GEMS, Pre Exam) content item
-->
<xsl:template name="addPreExam"> <xsl:param name="pItem"/>

<!-- (VV-021, 99GEMS, Family Medical history) -->
    <xsl:variable name="famMedHist" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-021' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (VV-022, 99GEMS, Patient history) -->
    <xsl:variable name="patHist" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-022' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$famMedHist or $patHist">
        <xsl:call-template name="addTwoInARow">
            <xsl:with-param name="p1st" select="$famMedHist"/>
            <xsl:with-param name="p2nd" select="$patHist"/>
        </xsl:call-template>
    </xsl:if>
<!-- (VV-023, 99GEMS, Exam procedure) -->
    <xsl:variable name="examProc" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-023' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (VV-072, 99GEMS, Scan dose) -->
    <xsl:variable name="scanDose" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-072' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$examProc or $scanDose">
        <xsl:call-template name="addTwoInARow">
            <xsl:with-param name="p1st" select="$examProc"/>
            <xsl:with-param name="p2nd" select="$scanDose"/>
        </xsl:call-template>
    </xsl:if>
<!-- (CAR-029, 99GEMS, Indications for study) or (121109, DCM, "Indications for Procedure") -->
    <xsl:variable name="indications" select="$pItem/ContentSequence/Item[(ConceptNameCodeSequence/Item/CodeValue = 'CAR-029' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS) or (ConceptNameCodeSequence/Item/CodeValue = '121109' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM)]"/>
<!-- (G-C2CB, SNM3, Ventricular dominance) -->
    <xsl:variable name="dominance" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C2CB' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:if test="$indications or $dominance">
        <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <tr style="background-color: #{$P2}">
                <th style="width: 50%; text-align: left">
                    <xsl:value-of select="$indications/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
                <th style="width: 50%; text-align: left">
                    <xsl:value-of select="$dominance/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </tr>
            <tr>
                <td style="width: 50%; vertical-align: top;">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$indications"/>
                    </xsl:call-template>
                </td>
                <td style="width: 50%; vertical-align: top;">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$dominance"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:if>
<!-- (8867-4, LN, Heart rate) -->
    <xsl:variable name="hr" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8867-4' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
<!-- (CAR-036, 99GEMS, Beta Blockers) -->
    <xsl:variable name="betaB" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (CAR-037, 99GEMS, Nitro) -->
    <xsl:variable name="nitro" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-037' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$hr or $betaB or $nitro">
        <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <tr style="background-color: #{$P2}">
                <th style="width: 33%; text-align: left">
                    <xsl:value-of select="$hr/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
                <th style="width: 34%; text-align: left">
                    <xsl:value-of select="$nitro/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
                <th style="width: 33%; text-align: left">
                    <xsl:value-of select="$betaB/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </tr>
            <tr>
                <td style="width: 33%; vertical-align: top;">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$hr"/>
                <!-- Display Code Meaning of Measurement Units Code Sequence. -->
                        <xsl:with-param name="pUnit" select="'cm'"/>
                        <xsl:with-param name="pPattern" select="'#,##0'"/>
                    </xsl:call-template>
                </td>
                <td style="width: 34%; vertical-align: top;">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$nitro"/>
                    </xsl:call-template>
                </td>
                <td style="width: 33%; vertical-align: top;">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$betaB"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:if>
</xsl:template>

<xsl:template name="addTwoInARow">
    <xsl:param name="p1st"/>
    <xsl:param name="p2nd"/>

    <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <tr style="background-color: #{$P2}">
        <xsl:choose>
            <xsl:when test="not($p1st) or not($p2nd)">
                <th style="width: 100%; text-align: left">
                    <xsl:choose>
                        <xsl:when test="$p1st">
                            <xsl:value-of select="$p1st/ConceptNameCodeSequence/Item/CodeMeaning"/>
                        </xsl:when>
                        <xsl:when test="$p2nd">
                            <xsl:value-of select="$p2nd/ConceptNameCodeSequence/Item/CodeMeaning"/>
                        </xsl:when>
                    </xsl:choose>
                </th>
            </xsl:when>
            <xsl:otherwise>
                <th style="width: 50%; text-align: left">
                    <xsl:value-of select="$p1st/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
                <th style="width: 50%; text-align: left">
                    <xsl:value-of select="$p2nd/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
            </xsl:otherwise>
        </xsl:choose>
    </tr>
    <tr>
        <xsl:choose>
            <xsl:when test="not($p1st) or not($p2nd)">
                <td style="width: 100%; vertical-align: top;">
                    <xsl:choose>
                        <xsl:when test="$p1st">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$p1st"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$p2nd">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$p2nd"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </td>
            </xsl:when>
            <xsl:otherwise>
                <td style="width: 50%; vertical-align: top;">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$p1st"/>
                    </xsl:call-template>
                </td>
                <td style="width: 50%; vertical-align: top;">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$p2nd"/>
                    </xsl:call-template>
                </td>
            </xsl:otherwise>
        </xsl:choose>
    </tr>
    </table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPostExam
    Description:    Adds Post Exam content item.
    Parameters:
        pItem    :  (VV-019, 99GEMS, Post Exam) content item
-->
<xsl:template name="addPostExam"> <xsl:param name="pItem"/>
                                  <xsl:param name="pWithSubTitles" select="'true'"/>

    <xsl:for-each select="$pItem/ContentSequence/Item">
        <xsl:if test="$pWithSubTitles = 'true'">
            <h3>
                <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </h3>
        </xsl:if>
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="current()"/>
        </xsl:call-template>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addFinding
    Description:    Adds Finding content item.
    Parameters:
        pItem    :  (121071, DCM, Finding) content item
-->
<xsl:template name="addFinding">
    <xsl:param name="pItem"/>

<!-- (121106, DCM, Comment) -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:call-template name="addMeasurements">
        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    </xsl:call-template>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPlaque
    Description:    Adds Plaque content item.
    Parameters:
        pItem    :  (M-01470, SNM3, Plaque) content item
-->
<xsl:template name="addPlaque">
    <xsl:param name="pItem"/>

    <xsl:variable name="branch" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="location" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C1E8' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="type" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D70D' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="riskComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-025' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="characterization" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-031' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="description" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$branch or $location or $type or $characterization or $description">
    <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
	    <xsl:if test="$rendering = 'xls'">
	        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
	    </xsl:if>
        <tr style="background-color: #{$P2}">
            <th style="width: 20%">
                <xsl:value-of select="$branch/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 20%">
                <xsl:value-of select="$location/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 20%">
                <xsl:value-of select="$type/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 20%">
                <xsl:value-of select="$characterization/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 20%">
                <xsl:value-of select="$description/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
        </tr>
        <tr>
            <td style="width: 20%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$branch"/>
                </xsl:call-template>
            </td>
            <td style="width: 20%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$location"/>
                </xsl:call-template>
            </td>
            <td style="width: 20%; text-align: center">
                <div>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$type"/>
                    </xsl:call-template>
                </div>
                <xsl:if test="$riskComment">
                    <div>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$riskComment"/>
                        </xsl:call-template>
                    </div>
                </xsl:if>
            </td>
            <td style="width: 20%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$characterization"/>
                </xsl:call-template>
            </td>
            <td style="width: 20%; text-align: center">
                <xsl:for-each select="$description">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()"/>
                    </xsl:call-template>
                    <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </table>
    </xsl:if>
<!-- (121106, DCM, Comment) -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:call-template name="addMeasurements">
        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    </xsl:call-template>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addAneurysm
    Description:    Adds Aneurysm content item.
    Parameters:
        pItem    :  (M-32200, SNM3, Aneurysm) content item
-->
<xsl:template name="addAneurysm">
    <xsl:param name="pItem"/>

    <xsl:variable name="branch" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="description" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$branch or $description">
    <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
	    <xsl:if test="$rendering = 'xls'">
	        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
	    </xsl:if>
        <tr style="background-color: #{$P2}">
            <th style="width: 50%">
                <xsl:value-of select="$branch/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 50%">
                <xsl:value-of select="$description/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
        </tr>
        <tr>
            <td style="width: 50%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$branch"/>
                </xsl:call-template>
            </td>
            <td style="width: 50%; text-align: center">
                <xsl:for-each select="$description">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()"/>
                    </xsl:call-template>
                    <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </table>
    </xsl:if>
<!-- (121106, DCM, Comment) -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:call-template name="addMeasurements">
        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    </xsl:call-template>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCardiacFinding
    Description:    Adds Aneurysm content item.
    Parameters:
        pItem    :  (F-30164, SNM3, Cardiac Finding) content item
-->
<xsl:template name="addCardiacFinding">
    <xsl:param name="pItem"/>

    <xsl:variable name="branch" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$branch">
    <div>
        <span style="font-weight: bold;">
            <xsl:value-of select="$branch/ConceptNameCodeSequence/Item/CodeMeaning"/>
            <xsl:text>: </xsl:text>
        </span>
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$branch"/>
        </xsl:call-template>
    </div>
    </xsl:if>
<!-- (121106, DCM, Comment) -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:call-template name="addMeasurements">
        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    </xsl:call-template>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCardiacFunction
    Description:    Adds Cardiac Function content item.
    Parameters:
    pItem    :  (F-32000, SRT, Cardiac Function) content item
-->
<xsl:template name="addCardiacFunction"> <xsl:param name="pItem"/>

<!-- (121106, DCM, Comment) -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
<!-- (T-32600, SRT, Left Ventricle) -->
    <xsl:variable name="lv" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32600' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:if test="$lv">
        <xsl:call-template name="addCardiacCavityFunction">
            <xsl:with-param name="pItem" select="$lv"/>
        </xsl:call-template>
    </xsl:if>
<!-- (T-32500, SRT, Right Ventricle) -->
    <xsl:variable name="rv" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32500' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:if test="$rv">
        <xsl:call-template name="addCardiacCavityFunction">
            <xsl:with-param name="pItem" select="$rv"/>
        </xsl:call-template>
    </xsl:if>
<!-- (T-32300, SRT, Left Atrium) -->
    <xsl:variable name="la" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32300' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:if test="$la">
        <xsl:call-template name="addCardiacCavityFunction">
            <xsl:with-param name="pItem" select="$la"/>
        </xsl:call-template>
    </xsl:if>
<!-- (T-32200, SRT, Right Atrium) -->
    <xsl:variable name="ra" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32200' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:if test="$ra">
        <xsl:call-template name="addCardiacCavityFunction">
            <xsl:with-param name="pItem" select="$ra"/>
        </xsl:call-template>
    </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCardiacCavityFunction
    Description:    Adds Cardiac Cavity Function content item.
    Parameters:
    pItem    :  i.e. (T-32600, SRT, Left Ventricle)  item
-->
<xsl:template name="addCardiacCavityFunction"> <xsl:param name="pItem"/>
    
    <h3>
        <xsl:call-template name="addContainerName">
            <xsl:with-param name="pItem" select="$pItem"/>
        </xsl:call-template>
    </h3>

    <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:if test="$measurements">
        <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
		    <xsl:if test="$rendering = 'xls'">
		        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
		    </xsl:if>
            <tr style="background-color: #{$P2}">
<!-- If there is only one NUM item then it is a CVA measurement and not ROI data. -->
                <xsl:for-each select="$measurements">
                    <th style="text-align: center">
                        <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
                        <xsl:if test="count($num) = 1">
                            <xsl:choose>
<!-- display Myocardial Mass instead of Wall Mass -->
                                <xsl:when test="$num[ConceptNameCodeSequence/Item/CodeValue = '122447' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]">
                                    <xsl:value-of select="$messagecatalog/LBL_WALL_MASS/msg[@lang = $lang]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="addContainerName">
                                        <xsl:with-param name="pItem" select="$num"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </th>    
                </xsl:for-each>     
            </tr>
            <tr>
                <xsl:for-each select="$measurements">
                    <td style="text-align: center">
                        <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
                        <xsl:call-template name="addNumWithPrecision">
                            <xsl:with-param name="pNum" select="$num"/>
                        </xsl:call-template>
                        <xsl:variable name="comment" select="$num/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:if test="$comment/TextValue != ''">
                            <br/>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$comment"/>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                </xsl:for-each>  
           </tr> 
        </table>
    </xsl:if>
    
<!--  cavity tables like bullsEye or Phase Volumes    -->

    <xsl:variable name="cavityTable" select="$pItem/ContentSequence/Item[(ConceptNameCodeSequence/Item/CodeValue = '122445' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM) or
                                                                           (ConceptNameCodeSequence/Item/CodeValue = '122607' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM) or 
                                                                           (ConceptNameCodeSequence/Item/CodeValue = 'F-32050' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT) or
                                                                           (ConceptNameCodeSequence/Item/CodeValue = 'CAR-042' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS)]"/>
    <xsl:if test="$cavityTable">
        <xsl:for-each select="$cavityTable">
             <xsl:variable name="cavityMeasurements" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
             <h4>
                <xsl:choose>
<!-- display Wall Thickening instead of Thickening Analysis-->
                    <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = '122607' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                        <xsl:value-of select="$messagecatalog/LBL_THICKENING_ANALYSIS/msg[@lang = $lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="current()"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="concat(' (', $cavityMeasurements[1]/ContentSequence/Item/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ')')"/>
            </h4>
            <xsl:call-template name="addNFunctionCavityTable">
                <xsl:with-param name="pMeasurements" select="$cavityMeasurements"/>
                <xsl:with-param name="pN" select="10"/>
            </xsl:call-template>
        </xsl:for-each>     
    </xsl:if>
   
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:call-template name="addMeasurements">
        <xsl:with-param name="pMeasurements" select="$measurements[count(ContentSequence/Item/ValueType_NUM) != 1]"/>
    </xsl:call-template>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>



<!-- ####################################################################################################
    Template:       addNFunctionCavityTable
    Description:    Adds Tables belonginf to the cavities: bull's eye tables for LV, Phase Volume Tables for every cavity (LV, RV, RA, LA)
    Parameters:
    pItem    :  i.e. (T-32600, SRT, Left Ventricle)  item
-->
<xsl:template name="addNFunctionCavityTable"> 
                    <xsl:param name="pMeasurements"/>
                    <xsl:param name="pN" select="$imgColumns"/>


    <xsl:variable name="firstNMeasurements" select="$pMeasurements[position() &lt;= $pN]"/>
    <xsl:if test="$firstNMeasurements">
        <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <tr style="background-color: #{$P2}">
<!-- If there is only one NUM item then it is a CVA measurement and not ROI data. -->
                <xsl:for-each select="$firstNMeasurements">
                    <th style="text-align: center">
                        <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
                        <xsl:if test="count($num) = 1">
                            <xsl:call-template name="addContainerName">
                                <xsl:with-param name="pItem" select="$num"/>
                            </xsl:call-template> 
                        </xsl:if>
                    </th>    
                </xsl:for-each>     
            </tr>
            <tr>
                <xsl:for-each select="$firstNMeasurements">
                    <td style="text-align: center">
                        <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
                        <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$num"/>
                                <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                        
                    </td>
                </xsl:for-each>  
           </tr> 
        </table>
    </xsl:if>   
    <xsl:variable name="remainingMeasurements" select="$pMeasurements[position() &gt; $pN]"/>
<!-- Recursive call for remaining measurements. -->
    <xsl:if test="count($remainingMeasurements) != 0">
        <xsl:call-template name="addNFunctionCavityTable">
            <xsl:with-param name="pMeasurements" select="$remainingMeasurements"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>

    
</xsl:template>    
<!-- ####################################################################################################
    Template:       addPolyp
    Description:    Adds Polyp content item.
    Parameters:
        pItem    :  (M-76800, SNM3, Polyp) content item
-->
<xsl:template name="addPolyp"> <xsl:param name="pItem"/>

    <xsl:variable name="location" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C1E8' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="shape" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C2FE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="size" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CTC-004' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="distRectum" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CTC-003' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$location or $shape or $size or $distRectum">
    <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
	    <xsl:if test="$rendering = 'xls'">
	        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
	    </xsl:if>
        <tr style="background-color: #{$P2}">
            <th style="width: 25%">
                <xsl:value-of select="$location/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 25%">
                <xsl:value-of select="$shape/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 25%">
                <xsl:value-of select="$size/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 25%">
                <xsl:value-of select="$distRectum/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
        </tr>
        <tr>
<!-- (G-C1E8, SNM3, Location) -->
            <td style="width: 25%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$location"/>
                </xsl:call-template>
            </td>
<!-- (G-C2FE, SNM3, Shape) -->
            <td style="width: 25%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$shape"/>
                </xsl:call-template>
            </td>
<!-- (CTC-004, 99GEMS, Lesion size) -->
            <td style="width: 25%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$size"/>
                </xsl:call-template>
            </td>
<!-- (CTC-003, 99GEMS, Distance from Rectum) -->
            <td style="width: 25%; text-align: center">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$distRectum"/>
                </xsl:call-template>
            </td>
        </tr>
    </table>
    </xsl:if>
<!-- (121106, DCM, Comment) -->
    <xsl:variable name="comment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$comment"/>
    </xsl:call-template>
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:call-template name="addMeasurements">
        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    </xsl:call-template>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addExtraFinding
    Description:    Adds Extra Finding.
    Parameters:
        pItem    :  (VV-006, 99GEMS, Extra Finding) content item
-->
<xsl:template name="addExtraFinding">
    <xsl:param name="pItem"/>

    <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:if test="$measurements">
        <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
		    <xsl:if test="$rendering = 'xls'">
		        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
		    </xsl:if>
            <tr style="background-color: #{$P2}">
                <th style="width: 33%">
                    <xsl:value-of select="$messagecatalog/LBL_MEASUREMENT/msg[@lang = $lang]"/>
                </th>
                <th style="width: 67%">
                    <xsl:value-of select="$messagecatalog/LBL_VALUE/msg[@lang = $lang]"/>
                </th>
            </tr>
            <xsl:for-each select="$measurements">
                <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
    <!-- If there is only one NUM item then it is a CVA measurement and not ROI data. -->
                <xsl:if test="count($num) = 1">
                <tr>
                    <td style="width: 33%; text-align: center">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$num"/>
                        </xsl:call-template>
                    </td>
                    <td style="width: 67%; text-align: center">
                        <xsl:call-template name="addNumWithPrecision">
                            <xsl:with-param name="pNum" select="$num"/>
                        </xsl:call-template>
                        <xsl:variable name="comment" select="$num/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                        <xsl:if test="$comment/TextValue != ''">
                            <br/>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$comment"/>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
    </xsl:if>
<!-- (121106, DCM, Comment) -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:call-template name="addMeasurements">
        <xsl:with-param name="pMeasurements" select="$measurements[count(ContentSequence/Item/ValueType_NUM) != 1]"/>
    </xsl:call-template>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addScanParameters
    Description:    Adds Scan Parameters.
    Parameters:
        pItem    :  (ALA-029, 99GEMS, Scan Parameters) content item
-->
<xsl:template name="addScanParameters">
    <xsl:param name="pItem"/>

<!-- (ALA-085, 99GEMS, Scan Exam) items. -->
    <xsl:variable name="scanExams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-085' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
	    <xsl:if test="$rendering = 'xls'">
	        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
	    </xsl:if>
    <!-- (ALA-011, 99GEMS, Exam Date) -->
        <xsl:variable name="examDate" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-034, 99GEMS, Pixel Size) -->
        <xsl:variable name="pixelSize" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-035, 99GEMS, Slice Thickness) -->
        <xsl:variable name="thickness" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-036, 99GEMS, Slice Spacing) -->
        <xsl:variable name="spacing" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-032, 99GEMS, Voltage) -->
        <xsl:variable name="voltage" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-033, 99GEMS, Current) -->
        <xsl:variable name="current" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-037, 99GEMS, Dose) -->
        <xsl:variable name="dose" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-037' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-030, 99GEMS, Reconstruction Kernel Name) -->
        <xsl:variable name="recon" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-031, 99GEMS, Manufacturer Name) -->
        <xsl:variable name="manufacturer" select="$scanExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-031' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        <tr style="background-color: #{$P2}">
            <th style="width: 10%; text-align: left; border-style: solid; border-width: thin">
                <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 10%; border-style: solid; border-width: thin">
                <xsl:value-of select="$pixelSize/ConceptNameCodeSequence/Item/CodeMeaning"/>
                <xsl:text> </xsl:text>
                (<xsl:value-of select="$pixelSize/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
            </th>
            <th style="width: 25%; border-style: solid; border-width: thin">
                <xsl:value-of select="$thickness/ConceptNameCodeSequence/Item/CodeMeaning"/>
                <xsl:text> / </xsl:text>
                <xsl:value-of select="$spacing/ConceptNameCodeSequence/Item/CodeMeaning"/>
                <xsl:text> </xsl:text>
                (<xsl:value-of select="$thickness/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
            </th>
            <th style="width: 5%; border-style: solid; border-width: thin">
                <xsl:value-of select="$voltage/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
            </th>
            <th style="width: 5%; border-style: solid; border-width: thin">
                <xsl:value-of select="$current/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
            </th>
            <th style="width: 5%; border-style: solid; border-width: thin">
                <xsl:value-of select="$dose/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
            </th>
            <th style="width: 20%; border-style: solid; border-width: thin">
                <xsl:value-of select="$recon/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <th style="width: 20%; border-style: solid; border-width: thin">
                <xsl:value-of select="$manufacturer/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
        </tr>
        <xsl:for-each select="$scanExams">
        <tr>
            <td style="width: 10%; text-align: left; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pIsEditable" select="'false'"/>
                </xsl:call-template>
            </td>
            <td style="width: 10%; text-align: center; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
            </td>
            <td style="width: 25%; text-align: center; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
                <xsl:text> / </xsl:text>
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
            </td>
            <td style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
            </td>
            <td style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
            </td>
            <td style="width: 5%; text-align: center; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-037' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
            </td>
            <td style="width: 20%; text-align: center; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pIsEditable" select="'false'"/>
                </xsl:call-template>
            </td>
            <td style="width: 20%; text-align: center; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-031' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pIsEditable" select="'false'"/>
                </xsl:call-template>
            </td>
        </tr>
        </xsl:for-each>
    </table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addLung
    Description:    Adds Lung.
    Parameters:
        pItem    :  (T-28000, SRT, Lung) content item
-->
<xsl:template name="addLung"> <xsl:param name="pItem"/>

<!-- (ALA-041, 99GEMS, Lung Exam) items. -->
    <xsl:variable name="lungExams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-041' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="colWidth">
        <xsl:value-of select="number(100 div (2 * count($lungExams) + 1))"/>
    </xsl:variable>
    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
	    <xsl:if test="$rendering = 'xls'">
	        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
	    </xsl:if>
    <!-- (ALA-011, 99GEMS, Exam Date) -->
        <tr style="background-color: #{$P2}">
            <xsl:variable name="examDate" select="$lungExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <th style="text-align: left; width: {$colWidth}%; border-style: solid; border-width: thin">
                <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <xsl:for-each select="$lungExams">
            <th style="width: {$colWidth * 2}%; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pIsEditable" select="'false'"/>
                </xsl:call-template>
            </th>
            </xsl:for-each>
        </tr>
        <tr>
            <xsl:variable name="lungVolumeItems" select="$lungExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <td style="text-align: left; display-align: center; font-weight: bold; border-style: solid; border-width: thin">
                <xsl:value-of select="$lungVolumeItems/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </td>
            <xsl:for-each select="$lungExams">
                <xsl:variable name="lungVolumeItem" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                <td style="text-align: center; display-align: center; border-style: solid; border-width: thin">
                    <xsl:call-template name="addNoduleVolume">
                        <xsl:with-param name="pVolume" select="$lungVolumeItem"/>
                    </xsl:call-template>
                </td>
            </xsl:for-each>
        </tr>
<!-- Add total nodule volumes if (M-03010, SRT, Nodule) content items are present. -->
        <xsl:variable name="nodules" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'M-03010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
        <xsl:if test="$nodules">
    <!-- (ALA-010, 99GEMS, Nodule Exam) items. -->
            <xsl:variable name="noduleExams" select="$nodules/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <tr>
                <td style="text-align: left; display-align: center; font-weight: bold; border-style: solid; border-width: thin">
                    <xsl:value-of select="$messagecatalog/LBL_TOTAL_NODULE_VOLUME/msg[@lang = $lang]"/>
                </td>
                <xsl:for-each select="$lungExams">
        <!-- (ALA-011, 99GEMS, Exam Date) -->
                    <xsl:variable name="lungExamDateItem" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        <!-- Select those (ALA-010, 99GEMS, Nodule Exam) items, which has the same date as the current (ALA-041, 99GEMS, Lung Exam) item's exam date. -->
                    <xsl:variable name="noduleExamsWithDate" select="$noduleExams[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS and ContentSequence/Item/Date = $lungExamDateItem/Date]"/>
                    <xsl:variable name="totalNoduleVolume">
                        <xsl:call-template name="sumNoduleVolumes">
                            <xsl:with-param name="pVolumes" select="$noduleExamsWithDate/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <td style="text-align: center; display-align: center; border-style: solid; border-width: thin">
                        <xsl:call-template name="addTotalNoduleVolume">
                            <xsl:with-param name="pTotal" select="$totalNoduleVolume"/>
                        </xsl:call-template>
                    </td>
                </xsl:for-each>
            </tr>
        </xsl:if>
    </table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNodule
    Description:    Adds Nodule.
    Parameters:
        pItem    :  (M-03010, SRT, Nodule) content item
-->
<xsl:template name="addNodule"> <xsl:param name="pItem"/>

    <xsl:variable name="lobe" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-28770' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
    <xsl:variable name="comment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:if test="$lobe">
<!-- (T-28770, SRT, Lobe of lung) -->
        <div>
            <span style="font-weight: bold;">
                <xsl:value-of select="$lobe/ConceptNameCodeSequence/Item/CodeMeaning"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$lobe"/>
            </xsl:call-template>
        </div>
    </xsl:if>
    <xsl:if test="$comment">
<!-- (121106, DCM, Comment) -->
        <div>
            <span style="font-weight: bold;">
                <xsl:value-of select="$comment/ConceptNameCodeSequence/Item/CodeMeaning"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$comment"/>
            </xsl:call-template>
        </div>
    </xsl:if>
<!-- (ALA-010, 99GEMS, Nodule Exam) items. -->
    <xsl:variable name="noduleExams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="colWidth">
        <xsl:value-of select="number(100 div (2 * count($noduleExams) + 1))"/>
    </xsl:variable>
    <xsl:variable name="examDate" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <!-- (ALA-011, 99GEMS, Exam Date) -->
        <tr style="background-color: #{$P2}">
            <th style="text-align: left; width: {$colWidth}%; border-style: solid; border-width: thin">
                <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </th>
            <xsl:for-each select="$noduleExams">
            <th style="width: {$colWidth * 2}%; border-style: solid; border-width: thin">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <xsl:with-param name="pIsEditable" select="'false'"/>
                </xsl:call-template>
            </th>
            </xsl:for-each>
        </tr>
    <!-- (ALA-084, 99GEMS, Slice Index) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'ALA-084'"/>
            <xsl:with-param name="pCSD" select="$CSD_GEMS"/>
        </xsl:call-template>
    <!-- (111009, DCM, Calcification Type) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'111009'"/>
            <xsl:with-param name="pCSD" select="$CSD_DICOM"/>
        </xsl:call-template>
    <!-- (112118, DCM, Density) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'112118'"/>
            <xsl:with-param name="pCSD" select="$CSD_DICOM"/>
        </xsl:call-template>
    <!-- (G-C2FE, SNM3, Shape) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'G-C2FE'"/>
            <xsl:with-param name="pCSD" select="$CSD_SNOMED"/>
        </xsl:call-template>
    <!-- (G-A168, SRT, Surface) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'G-A168'"/>
            <xsl:with-param name="pCSD" select="$CSD_SNOMED_RT"/>
        </xsl:call-template>
    <!-- (G-C197, SRT, Severity) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'G-C197'"/>
            <xsl:with-param name="pCSD" select="$CSD_SNOMED_RT"/>
        </xsl:call-template>
    <!-- (ALA-100, 99GEMS, L-R) -->
        <xsl:variable name="l_rs" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-101, 99GEMS, A-P) -->
        <xsl:variable name="a_ps" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-101' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (ALA-102, 99GEMS, I-S) -->
        <xsl:variable name="i_ss" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-102' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        <xsl:if test="$l_rs or $a_ps or $i_ss">
        <tr>
            <td style="text-align: left; display-align: center; border-style: solid; border-width: thin">
                <span style="font-weight: bold;">
                    <xsl:value-of select="concat($l_rs/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $a_ps/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $i_ss/ConceptNameCodeSequence/Item/CodeMeaning)"/>
                </span>
            </td>
            <xsl:for-each select="$noduleExams">
                <xsl:variable name="l_r" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="a_p" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-101' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="i_s" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-102' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <td style="text-align: center; display-align: center; border-style: solid; border-width: thin">
                    <xsl:if test="$l_r or $a_p or $i_s">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$l_r"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$a_p"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$i_s"/>
                        </xsl:call-template>
                    </xsl:if>
                </td>
            </xsl:for-each>
        </tr>
        </xsl:if>
    <!-- (G-D705, SNM3, Volume) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'G-D705'"/>
            <xsl:with-param name="pCSD" select="$CSD_SNOMED"/>
        </xsl:call-template>
    <!-- (ALA-082, 99GEMS, Days growth) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'ALA-082'"/>
            <xsl:with-param name="pCSD" select="$CSD_GEMS"/>
        </xsl:call-template>
    <!-- (ALA-081, 99GEMS, Percent Growth) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'ALA-081'"/>
            <xsl:with-param name="pCSD" select="$CSD_GEMS"/>
        </xsl:call-template>
    <!-- (ALA-080, 99GEMS, Doubling Time) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'ALA-080'"/>
            <xsl:with-param name="pCSD" select="$CSD_GEMS"/>
        </xsl:call-template>
    <!-- (M-02550, SNM3, Diameter) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'M-02550'"/>
            <xsl:with-param name="pCSD" select="$CSD_SNOMED"/>
        </xsl:call-template>
    <!-- (VV-032, 99GEMS, Min) -->
        <xsl:variable name="mins" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-033, 99GEMS, Max) -->
        <xsl:variable name="maxs" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-034, 99GEMS, Avg) -->
        <xsl:variable name="avgs" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-036, 99GEMS, Std) -->
        <xsl:variable name="stds" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        <xsl:if test="$mins or $maxs or $avgs or $stds">
        <tr>
            <td style="text-align: left; display-align: center; border-style: solid; border-width: thin">
                <span style="font-weight: bold;">
                <xsl:value-of select="$mins/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
                </span>
                <xsl:text> </xsl:text>
                <xsl:value-of select="concat('(', $mins/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $avgs/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $maxs/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $stds/ConceptNameCodeSequence/Item/CodeMeaning, ')')"/>
            </td>
            <xsl:for-each select="$noduleExams">
                <xsl:variable name="min" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="max" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="avg" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:variable name="std" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <td style="text-align: center; display-align: center; border-style: solid; border-width: thin">
                    <xsl:if test="$min or $max or $avg or $std">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$min"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$avg"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$max"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$std"/>
                            <xsl:with-param name="pUnit" select="'none'"/>
                        </xsl:call-template>
                    </xsl:if>
                </td>
            </xsl:for-each>
        </tr>
        </xsl:if>
    <!-- (CAPTURE, 99GEMS, Image Capture) -->
        <xsl:variable name="imageCaptures" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
        <xsl:if test="$imageCaptures">
        <tr>
            <td style="text-align: left; font-weight: bold; border-style: solid; border-width: thin">
                <xsl:value-of select="$imageCaptures/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </td>
            <xsl:for-each select="$noduleExams">
            <td style="text-align: center; vertical-align: top; border-style: solid; border-width: thin">
                <xsl:call-template name="addImageCaptures">
                    <xsl:with-param name="pImages" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                </xsl:call-template>
            </td>
            </xsl:for-each>
        </tr>
        </xsl:if>
    <!-- (121106, DCM, Comment) -->
        <xsl:call-template name="addNoduleExamRow">
            <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
            <xsl:with-param name="pCV" select="'121106'"/>
            <xsl:with-param name="pCSD" select="$CSD_DICOM"/>
        </xsl:call-template>
    </table>
<!-- (R-40831, DCM, Measurement) items -->
    <xsl:variable name="measurements" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:if test="$measurements">
        <h3><xsl:value-of select="$measurements/ConceptNameCodeSequence/Item/CodeMeaning"/></h3>
        <table style="width: 100%; border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <tr style="background-color: #{$P2}">
                <th style="text-align: left; width: 10%; border-style: solid; border-width: thin">
                    <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </th>
                <th style="width: 10%; border-style: solid; border-width: thin">
                </th>
            </tr>
            <xsl:for-each select="$noduleExams">
            <tr>
                <td style="text-align: left; width: 10%; border-style: solid; border-width: thin">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:with-param name="pIsEditable" select="'false'"/>
                    </xsl:call-template>
                </td>
                <td style="text-align: center; vertical-align: top; border-style: solid; border-width: thin">
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                    </xsl:call-template>
                </td>
            </tr>
            </xsl:for-each>
        </table>
    </xsl:if>

</xsl:template>

<xsl:template name="addNoduleExamRow">
    <xsl:param name="pNoduleExams"/>
    <xsl:param name="pCV"/>
    <xsl:param name="pCSD"/>

    <xsl:variable name="items" select="$pNoduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = $pCV and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $pCSD]"/>
    <xsl:if test="$items">
    <tr>
        <td style="text-align: left; display-align: center; font-weight: bold; border-style: solid; border-width: thin">
            <xsl:value-of select="$items/ConceptNameCodeSequence/Item/CodeMeaning"/>
        </td>
        <xsl:for-each select="$pNoduleExams">
            <xsl:variable name="item" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = $pCV and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $pCSD]"/>
            <td style="text-align: center; display-align: center; border-style: solid; border-width: thin">
                <xsl:choose>
    <!-- (ALA-084, 99GEMS, Slice Index) -->
                    <xsl:when test="$pCV = 'ALA-084' and $pCSD = $CSD_GEMS">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$item"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </xsl:when>
    <!-- (G-D705, SNM3, Volume) -->
                    <xsl:when test="$pCV = 'G-D705' and $pCSD = $CSD_SNOMED">
                        <xsl:variable name="non-solid" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-038' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:variable name="solid" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-039' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:call-template name="addNoduleVolumes">
                            <xsl:with-param name="pVolume" select="$item"/>
                            <xsl:with-param name="pNonSolid" select="$non-solid"/>
                            <xsl:with-param name="pSolid" select="$solid"/>
                        </xsl:call-template>
                    </xsl:when>
    <!-- (ALA-080, 99GEMS, Doubling Time) -->
                    <xsl:when test="$pCV = 'ALA-080' and $pCSD = $CSD_GEMS">
                        <xsl:call-template name="addDoublingTime">
                            <xsl:with-param name="pDoubling" select="$item"/>
                        </xsl:call-template>
                    </xsl:when>
    <!-- (ALA-082, 99GEMS, Days Growth) -->
                    <xsl:when test="$pCV = 'ALA-082' and $pCSD = $CSD_GEMS">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$item"/>
                            <xsl:with-param name="pUnit" select="'cm'"/>
                        </xsl:call-template>
                    </xsl:when>                        
                    <xsl:otherwise>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$item"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </xsl:for-each>
    </tr>
    </xsl:if>
</xsl:template>

<xsl:template name="addNoduleVolumes"> <xsl:param name="pVolume"/> <xsl:param name="pNonSolid"/> <xsl:param name="pSolid"/>

<!-- Only mm3 and cm3 is used for nodule volumes. Precision is always to the nearest mm3. If the volume is reported in cm3 the precision is 3 decimal digits. -->
    <xsl:choose>
        <xsl:when test="$pNonSolid or $pSolid">
        <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <tr>
                <th style="width: 33%; font-size: {$fontSize - 2}pt;">
                    <xsl:value-of select="$messagecatalog/LBL_NONSOLID/msg[@lang = $lang]"/>
                </th>
                <th style="width: 34%; font-size: {$fontSize - 2}pt;">
                    <xsl:value-of select="$messagecatalog/LBL_SOLID/msg[@lang = $lang]"/>
                </th>
                <th style="width: 33%; font-size: {$fontSize - 2}pt;">
                    <xsl:value-of select="$messagecatalog/LBL_TOTAL/msg[@lang = $lang]"/>
                </th>
            </tr>
            <tr>
                <td style="text-align: center;">
                    <xsl:call-template name="addNoduleVolume">
                        <xsl:with-param name="pVolume" select="$pNonSolid"/>
                    </xsl:call-template>
                </td>
                <td style="text-align: center;">
                    <xsl:call-template name="addNoduleVolume">
                        <xsl:with-param name="pVolume" select="$pSolid"/>
                    </xsl:call-template>
                </td>
                <td style="text-align: center;">
                    <xsl:call-template name="addNoduleVolume">
                        <xsl:with-param name="pVolume" select="$pVolume"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="addNoduleVolume">
                <xsl:with-param name="pVolume" select="$pVolume"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addMeasurements
    Description:    Adds measurements.
    Parameters:
        pMeasurements :
-->
<xsl:template name="addMeasurements"> <xsl:param name="pMeasurements"/>
                                      <xsl:param name="pN" select="$imgColumns"/>

    <xsl:if test="$pMeasurements">
        <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
		    <xsl:if test="$rendering = 'xls'">
		        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
		    </xsl:if>
            <xsl:call-template name="addNMeasurements">
                <xsl:with-param name="pMeasurements" select="$pMeasurements"/>
                <xsl:with-param name="pN" select="$pN"/>
            </xsl:call-template>
        </table>
    </xsl:if>
    <xsl:for-each select="$pMeasurements">
    <!-- Color coded plaque statistics -->
        <xsl:if test="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-CCP' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]">
            <xsl:call-template name="addColorPlaqueStatistics">
                <xsl:with-param name="pMeasurement" select="current()"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:for-each>
</xsl:template>


<!-- ####################################################################################################
    Template:       addNMeasurements
    Description:    Recursively adds measurements organized into N columns.
    Parameters:
        pMeasurements :
-->
<xsl:template name="addNMeasurements"> <xsl:param name="pMeasurements"/>
                                       <xsl:param name="pN" select="$imgColumns"/>

    <xsl:variable name="firstNMeasurements" select="$pMeasurements[position() &lt;= $pN]"/>
<!-- (VV-008, 99GEMS, Name) - (G-D70D, SNM3, Type) -->
    <tr style="background-color: #{$P2}">
        <xsl:for-each select="$firstNMeasurements">
            <xsl:variable name="imgCapture" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:variable name="name" select="$imgCapture/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="type" select="$imgCapture/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D70D' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <td style="width: {100 div $pN}%; text-align: center">
                <xsl:if test="$name and $name/TextValue != ''">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$name"/>
                    </xsl:call-template>
                    <xsl:if test="$type and $name/TextValue != $type/TextValue">
                        <xsl:text> - </xsl:text>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$type"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:if>
            </td>
        </xsl:for-each>
        <xsl:call-template name="addEmptyCells">
            <xsl:with-param name="pTotalCols" select="$pN"/>
            <xsl:with-param name="pN" select="$pN - count($firstNMeasurements)"/>
        </xsl:call-template>
    </tr>
<!-- (CAPTURE, DCM, Image Capture) linked to measurements or ROIs -->
    <tr>
        <xsl:for-each select="$firstNMeasurements">
            <xsl:variable name="imgCapture" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <td style="width: {100 div $pN}%; text-align: center">
                <xsl:variable name="manual" select="$imgCapture/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 'G-D221' and ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                <xsl:variable name="automatic" select="$imgCapture/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 'G-D231' and ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                <xsl:choose>
                    <xsl:when test="$manual and $tp/Images/@manual = 'true'">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$imgCapture/ContentSequence/Item[ValueType_IMAGE]"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$automatic and $tp/Images/@automatic = 'true'">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$imgCapture/ContentSequence/Item[ValueType_IMAGE]"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </xsl:for-each>
        <xsl:call-template name="addEmptyCells">
            <xsl:with-param name="pTotalCols" select="$pN"/>
            <xsl:with-param name="pN" select="$pN - count($firstNMeasurements)"/>
        </xsl:call-template>
    </tr>
<!-- (121106, DCM, Comment) -->
    <tr>
        <xsl:for-each select="$firstNMeasurements">
            <xsl:variable name="imgCapture" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:variable name="comment" select="$imgCapture/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <td style="width: {100 div $pN}%; text-align: center">
                <xsl:if test="$comment and $comment/TextValue != ''">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$comment"/>
                    </xsl:call-template>
                </xsl:if>
            </td>
        </xsl:for-each>
        <xsl:call-template name="addEmptyCells">
            <xsl:with-param name="pTotalCols" select="$pN"/>
            <xsl:with-param name="pN" select="$pN - count($firstNMeasurements)"/>
        </xsl:call-template>
    </tr>
    <tr>
        <xsl:for-each select="$firstNMeasurements">
            <xsl:variable name="nums" select="current()/ContentSequence/Item[ValueType_NUM]"/>
    <!-- (VV-032, 99GEMS, Min) -->
            <xsl:variable name="min" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-033, 99GEMS, Max) -->
            <xsl:variable name="max" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-034, 99GEMS, Avg) -->
            <xsl:variable name="avg" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-036, 99GEMS, Std) -->
            <xsl:variable name="std" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- Measurement name, value and comment -->
            <td style="width: {100 div $pN}%; vertical-align: top;">
                <xsl:choose>
    <!-- ROI -->
                    <xsl:when test="$min or $max or $avg or $std">
                        <xsl:call-template name="addROI">
                            <xsl:with-param name="pMeasurement" select="current()"/>
                        </xsl:call-template>
                    </xsl:when>
    <!-- Color Plaque -->
                    <xsl:when test="count($nums) = 0">
                        <span style="font-weight: bold">
                            <xsl:call-template name="addContainerName">
                                <xsl:with-param name="pItem" select="current()"/>
                            </xsl:call-template>
                        </span>
                    </xsl:when>
    <!-- Simple measurement -->
                    <xsl:when test="count($nums) = 1">
                        <div style="font-weight: bold">
                            <xsl:value-of select="$nums/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            <xsl:text>:</xsl:text>
                        </div>
                        <div style="text-align: center;">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$nums"/>
                            </xsl:call-template>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </xsl:for-each>
        <xsl:call-template name="addEmptyCells">
            <xsl:with-param name="pTotalCols" select="$pN"/>
            <xsl:with-param name="pN" select="$pN - count($firstNMeasurements)"/>
        </xsl:call-template>
    </tr>
    <xsl:variable name="remainingMeasurements" select="$pMeasurements[position() &gt; $pN]"/>
<!-- Recursive call for remaining measurements. -->
    <xsl:if test="count($remainingMeasurements) != 0">
        <xsl:call-template name="addNMeasurements">
            <xsl:with-param name="pMeasurements" select="$remainingMeasurements"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addROI
    Description:    Adds ROI.
    Parameters:
        pROI :
-->
<xsl:template name="addROI"> <xsl:param name="pMeasurement"/>

    <div style="text-align: left; font-weight: bold">
        <xsl:call-template name="addContainerName">
            <xsl:with-param name="pItem" select="$pMeasurement"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:value-of select="concat(' ', $messagecatalog/LBL_HOUNSFIELD_STATISTICS/msg[@lang = $lang], ' (HU):')"/>
    </div>
<!-- (VV-032, 99GEMS, Min) -->
    <xsl:variable name="min" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (VV-033, 99GEMS, Max) -->
    <xsl:variable name="max" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (VV-034, 99GEMS, Avg) -->
    <xsl:variable name="avg" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (VV-036, 99GEMS, Std) -->
    <xsl:variable name="std" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>

    <xsl:if test="$min or $max or $avg or $std">
        <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
		    <xsl:if test="$rendering = 'xls'">
		        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
		    </xsl:if>
            <tr>
                <th style="width: 25%; text-align: center">
                    <xsl:choose>
                        <xsl:when test="$avg">
                            <xsl:value-of select="$avg/ConceptNameCodeSequence/Item/CodeMeaning"/>
                        </xsl:when>
                        <xsl:otherwise>Avg</xsl:otherwise>
                    </xsl:choose>
                </th>
                <th style="width: 25%; text-align: center">
                    <xsl:choose>
                        <xsl:when test="$std">
                            <xsl:value-of select="$std/ConceptNameCodeSequence/Item/CodeMeaning"/>
                        </xsl:when>
                        <xsl:otherwise>Std</xsl:otherwise>
                    </xsl:choose>
                </th>
                <th style="width: 25%; text-align: center">
                    <xsl:choose>
                        <xsl:when test="$min">
                            <xsl:value-of select="$min/ConceptNameCodeSequence/Item/CodeMeaning"/>
                        </xsl:when>
                        <xsl:otherwise>Min</xsl:otherwise>
                    </xsl:choose>
                </th>
                <th style="width: 25%; text-align: center">
                    <xsl:choose>
                        <xsl:when test="$max">
                            <xsl:value-of select="$max/ConceptNameCodeSequence/Item/CodeMeaning"/>
                        </xsl:when>
                        <xsl:otherwise>Max</xsl:otherwise>
                    </xsl:choose>
                </th>
            </tr>
            <tr>
    <!-- (VV-034, 99GEMS, Avg) -->
                <xsl:call-template name="addROIValue">
                    <xsl:with-param name="pROI" select="$avg"/>
                </xsl:call-template>
    <!-- (VV-036, 99GEMS, Std) -->
                <xsl:call-template name="addROIValue">
                    <xsl:with-param name="pROI" select="$std"/>
                </xsl:call-template>
    <!-- (VV-032, 99GEMS, Min) -->
                <xsl:call-template name="addROIValue">
                    <xsl:with-param name="pROI" select="$min"/>
                </xsl:call-template>
    <!-- (VV-033, 99GEMS, Max) -->
                <xsl:call-template name="addROIValue">
                    <xsl:with-param name="pROI" select="$max"/>
                </xsl:call-template>
            </tr>
        </table>
    </xsl:if>
</xsl:template>

<xsl:template name="addROIValue"> <xsl:param name="pROI"/>
    <td style="width: 25%; text-align: center">
        <xsl:choose>
            <xsl:when test="$pROI">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$pROI"/>
                    <xsl:with-param name="pUnit" select="'none'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
        </xsl:choose>
    </td>
</xsl:template>

<!-- ####################################################################################################
    Template:       addColorPlaqueStatistics
    Description:    Adds statistics for Color Coded Plaques.
    Parameters:
        pMeasurement :
-->
<xsl:template name="addColorPlaqueStatistics"> <xsl:param name="pMeasurement"/>

    <xsl:variable name="statistics" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-CCP' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:if test="$statistics">
        <br/>
        <div style="text-align: left; font-weight: bold">
            <xsl:call-template name="addContainerName">
                <xsl:with-param name="pItem" select="$pMeasurement"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:value-of select="concat($statistics/ConceptNameCodeSequence/Item/CodeMeaning, ':')"/>
        </div>
        <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
		    <xsl:if test="$rendering = 'xls'">
		        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
		    </xsl:if>
            <tr>
                <th style="width: 5%; text-align: center"/>
                <th style="width: 10%; text-align: center">
                    <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'VV-035' and ../CodingSchemeDesignator = $CSD_GEMS]"/>
                </th>
                <th style="width: 30%; text-align: center">
                    <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'VV-030' and ../CodingSchemeDesignator = $CSD_GEMS]"/>
                </th>
                <th style="width: 15%; text-align: center">
                    <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'VV-008' and ../CodingSchemeDesignator = $CSD_GEMS]"/>
                </th>
                <th style="width: 25%; text-align: center" colspan="2">
                    <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'G-D705' and ../CodingSchemeDesignator = $CSD_SNOMED]"/>
                </th>
                <!--th style="width: 15%; text-align: center"/-->
            </tr>
            <xsl:for-each select="$statistics">
    <!-- (, , Segment) -->
                <tr>
                    <td style="width: 5%; text-align: center">
                        <xsl:value-of select="position() - 1"/>
                    </td>
    <!-- (VV-035, 99GEMS, RGB Color) -->
                    <xsl:variable name="rgb" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                    <td style="width: 10%; background-color: {$rgb/TextValue}"/>
    <!-- (VV-030, 99GEMS, Hounsfield range) This is a not editable TEXT item. -->
                    <td style="width: 30%; text-align: center">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </td>
    <!-- (VV-008, 99GEMS, Name) -->
                    <td style="width: 15%; text-align: center">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        </xsl:call-template>
                    </td>
    <!-- (G-D705, SNM3, Volume) -->
                    <td style="width: 25%; text-align: right">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                        </xsl:call-template>
                    </td>
    <!-- (VV-031, 99GEMS, Percent of total volume) -->
                    <td style="width: 15%; text-align: right">
                        (<xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-031' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        </xsl:call-template>)
                    </td>
                </tr>
            </xsl:for-each>
    <!-- Sum up segment volumes. -->
            <xsl:variable name="volumes" select="$statistics/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <tr>
                <td style="width: 5%; text-align: center"/>
                <td style="width: 10%;"/>
                <td style="width: 30%; text-align: center"/>
                <td style="width: 15%; text-align: center; font-weight: bold">
                    <xsl:value-of select="$messagecatalog/LBL_TOTAL/msg[@lang = $lang]"/>
                </td>
                <td style="width: 25%; text-align: right; font-weight: bold">
                    <xsl:call-template name="formatNumericValue">
                        <xsl:with-param name="pNum" select="sum($volumes/MeasuredValueSequence/Item/NumericValue)"/>
                    </xsl:call-template>
                    <xsl:value-of select="concat(' ', $volumes/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue)"/>
                </td>
                <td style="width: 15%; text-align: right"/>
            </tr>
        </table>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addGeneralImages
    Description:    Adds General Images.
    Parameters:
        pItem    :  (VV-024, 99GEMS, General Images) content items
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addGeneralImages">
    <xsl:param name="pItem"/>
    <xsl:param name="pPosition"/>

    <xsl:variable name="imageCaptures" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:variable name="manual" select="$imageCaptures[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D221' and ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="automatic" select="$imageCaptures[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D231' and ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:if test="($manual and $tp/Images/@manual = 'true') or ($automatic and $tp/Images/@automatic = 'true')">
        <xsl:call-template name="addImageCaptures">
            <xsl:with-param name="pImages" select="$imageCaptures"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addImageCapture
    Description:    Add one image optionally with name and comment.
    Parameters:
        pImage   :  Image.
-->
<xsl:template name="addImageCapture"> <xsl:param name="pImage"/>
                                      <xsl:param name="pWithName" select="'true'"/>
                                      <xsl:param name="pWithComment" select="'true'"/>
    <xsl:choose>
        <xsl:when test="$pImage/ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and $pImage/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
            <xsl:call-template name="addVVImageCapture">
                <xsl:with-param name="pImage" select="$pImage"/>
                <xsl:with-param name="pWithName" select="$pWithName"/>
                <xsl:with-param name="pWithComment" select="$pWithComment"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="addPETVCARImageCapture">
                <xsl:with-param name="pImage" select="$pImage"/>
                <xsl:with-param name="pWithName" select="$pWithName"/>
                <xsl:with-param name="pWithComment" select="$pWithComment"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addVVImageCapture
    Description:    Add one image optionally with name and comment.
    Parameters:
        pImage   :  Image item.
-->
<xsl:template name="addVVImageCapture"> <xsl:param name="pImage"/>
                                        <xsl:param name="pWithName" select="'true'"/>
                                        <xsl:param name="pWithComment" select="'true'"/>

<!-- (VV-008, 99GEMS, Name) - (G-D70D, SNM3, Type) -->
    <xsl:variable name="name" select="$pImage/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="type" select="$pImage/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D70D' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:if test="$pWithName = 'true'">
        <div style="text-align: center; background-color: #{$P2}">
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$pImage/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        </xsl:call-template>
        <xsl:if test="$type and $name/TextValue != $type/TextValue">
            <xsl:text> - </xsl:text>
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$type"/>
                <xsl:with-param name="pIsEditable" select="'false'"/>
            </xsl:call-template>
        </xsl:if>
        </div>
    </xsl:if>
<!-- Image -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pImage/ContentSequence/Item[ValueType_IMAGE]"/>
    </xsl:call-template>
<!-- (121106, DCM, Comment) -->
    <xsl:variable name="comment" select="$pImage/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:if test="$pWithComment = 'true'">
        <div style="text-align: left">
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$comment"/>
        </xsl:call-template>
        </div>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
