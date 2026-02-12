<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    VV.XSL - Volume Viewer specific XSLT rules for SR to XSL-FO transformation.
    @author raczatt
    @date Jul 11, 2007
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                              xmlns:fox="http://xml.apache.org/fop/extensions">

<xsl:import href="SECT_FO.XSL"/>
<xsl:include href="VV_FO.XSL"/>
<xsl:include href="VCAR.XSL"/>

<xsl:output method="xml"
            indent="yes"/>

<xsl:template match="/">

    <fo:root font-family="{$tp/Font/@type}" font-size="{$fontSize}pt">

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
    Template:       addBookmarks
    Description:    Overwrite addBookmarks in FO/SECT_FO.XSL.
-->
<xsl:template name="addBookmarks">

    <xsl:for-each select="$tp/Sections/Section">
        <xsl:variable name="curSection" select="current()"/>
        <xsl:variable name="curSectionPos" select="position()"/>
        <xsl:choose>
<!-- SR content in the original order -->
            <xsl:when test="@name = 'LBL_SRSECTIONS'">
                <xsl:for-each select="$DICOM/ContentSequence/Item">
                    <xsl:if test="current()/RelationshipType = 'CONTAINS'">
                    <xsl:variable name="cv" select="current()/ConceptNameCodeSequence/Item/CodeValue"/>
                    <xsl:variable name="csd" select="current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator"/>
                    <xsl:choose>
<!-- (VV-020, 99GEMS, Pre Exam) -->
                        <xsl:when test="$cv = 'VV-020' and $csd = $CSD_GEMS">
                            <xsl:call-template name="addBookmarkWithContent">
                                <xsl:with-param name="pItem" select="current()"/>
                                <xsl:with-param name="pPos" select="concat($curSectionPos, position())"/>
                            </xsl:call-template>
                        </xsl:when>
<!-- (VV-019, 99GEMS, Post Exam) -->
                        <xsl:when test="$cv = 'VV-019' and $csd = $CSD_GEMS">
                            <xsl:call-template name="addBookmarkWithContent">
                                <xsl:with-param name="pItem" select="current()"/>
                                <xsl:with-param name="pPos" select="concat($curSectionPos, position())"/>
                            </xsl:call-template>
                        </xsl:when>
<!-- (121076, DCM, Conclusions) -->
                        <xsl:when test="$cv = '121076' and $csd = $CSD_DICOM">
                            <xsl:call-template name="addBookmarkWithContent">
                                <xsl:with-param name="pItem" select="current()"/>
                                <xsl:with-param name="pPos" select="concat($curSectionPos, position())"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <fox:outline internal-destination="{concat(current()/ConceptNameCodeSequence/Item/CodeMeaning, $curSectionPos, position())}">
                                <fox:label>
                                    <xsl:call-template name="addContainerName">
                                        <xsl:with-param name="pItem" select="current()"/>
                                    </xsl:call-template>
                                </fox:label>
                            </fox:outline>
                        </xsl:otherwise>
                    </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
<!-- One specified SR ContentItem -->
            <xsl:when test="@code">
    <!-- Select content items with this code and scheme. -->
                <xsl:variable name="itemsWithCode" select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS' and ConceptNameCodeSequence/Item/CodeValue = current()/@code and ConceptNameCodeSequence/Item/CodingSchemeDesignator = current()/@scheme]"/>
    <!-- Count content items with this code and scheme. -->
                <xsl:variable name="itemsWithCodeNo" select="count($itemsWithCode)"/>
                <xsl:choose>
<!-- (VV-020, 99GEMS, Pre Exam) -->
                    <xsl:when test="current()/@code = 'VV-020' and current()/@scheme = $CSD_GEMS">
                        <xsl:call-template name="addBookmarkWithContent">
                            <xsl:with-param name="pItem" select="$itemsWithCode"/>
                            <xsl:with-param name="pPos" select="$curSectionPos"/>
                        </xsl:call-template>
                    </xsl:when>
<!-- (VV-019, 99GEMS, Post Exam) -->
                    <xsl:when test="(current()/@code = 'VV-020' or current()/@code = 'VV-019') and current()/@scheme = $CSD_GEMS">
                        <xsl:call-template name="addBookmarkWithContent">
                            <xsl:with-param name="pItem" select="$itemsWithCode"/>
                            <xsl:with-param name="pPos" select="$curSectionPos"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
    <!-- Select content items with (VV-008, 99GEMS, Name) children (comming from VV). -->
                        <xsl:variable name="itemsWithName" select="$itemsWithCode[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- Select content items with (VV-008, 99GEMS, Name) children (comming from VV) where the name is the name of the current Section. -->
                        <xsl:variable name="itemsWithThisName" select="$itemsWithCode[ContentSequence/Item/ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ContentSequence/Item/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS and ContentSequence/Item/TextValue = $curSection/@name]"/>
    <!-- Count content items with (VV-008, 99GEMS, Name) children (comming from VV) where the name is the name of the current Section. -->
                        <xsl:variable name="itemsWithThisNameNo" select="count($itemsWithThisName)"/>
                        <xsl:choose>
    <!-- All content items with this code and scheme where (VV-008, 99GEMS, Name) child exists are processed here but only those are added where the name is the name of the current Section. -->
                            <xsl:when test="$itemsWithName">
        <!-- Select position in $itemsWithName of current Section node among the sections with the same code, scheme and name.
             If there are more sections with the code, scheme and name in the template than in the SR they are displayed repeatedly (using mod for position calculation). -->
                                <xsl:variable name="curSameSectionPos" select="count(preceding-sibling::Section[@code = current()/@code and @scheme = current()/@scheme and @name = current()/@name]) mod $itemsWithThisNameNo + 1"/>
                                <xsl:variable name="itemWithPos" select="$itemsWithThisName[position() = $curSameSectionPos]"/>
                                <xsl:variable name="itemWithPosHasContent">
                                    <xsl:call-template name="hasContent">
                                        <xsl:with-param name="pItems" select="$itemWithPos"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:if test="$itemWithPosHasContent = 'true'">
                                    <fox:outline internal-destination="{concat($itemWithPos/ConceptNameCodeSequence/Item/CodeMeaning, $curSectionPos)}">
                                        <fox:label>
                                            <xsl:call-template name="addContainerName">
                                                <xsl:with-param name="pItem" select="$itemWithPos"/>
                                            </xsl:call-template>
                                        </fox:label>
                                    </fox:outline>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
        <!-- Select position in $itemsWithCode of current Section node among the sections with the same code and scheme.
             If there are more sections with the same code and scheme in the template than in the SR they are displayed repeatedly (using mod for position calculation). -->
                                <xsl:variable name="curSameSectionPos" select="count(preceding-sibling::Section[@code = current()/@code and @scheme = current()/@scheme]) mod $itemsWithCodeNo + 1"/>
                                <xsl:variable name="itemWithPos" select="$itemsWithCode[position() = $curSameSectionPos]"/>
                                <xsl:variable name="itemWithPosHasContent">
                                    <xsl:call-template name="hasContent">
                                        <xsl:with-param name="pItems" select="$itemWithPos"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:if test="$itemWithPosHasContent = 'true'">
                                    <fox:outline internal-destination="{concat($itemWithPos/ConceptNameCodeSequence/Item/CodeMeaning, $curSectionPos)}">
                                        <fox:label>
                                            <xsl:call-template name="addContainerName">
                                                <xsl:with-param name="pItem" select="$itemWithPos"/>
                                            </xsl:call-template>
                                        </fox:label>
                                    </fox:outline>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
<!-- Header, Patient demographics, Observation context, etc. -->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@type = 'GENERIC_MESSAGE'">
    <!-- Select Generic Message with the same id as Section id. -->
                        <xsl:variable name="genMsg" select="$tp/GenericMessages/GenericMessage[@id = current()/@id]"/>
                        <xsl:if test="$genMsg/Add">
                            <xsl:call-template name="addBookmark">
                                <xsl:with-param name="pSection" select="current()"/>
                                <xsl:with-param name="pSectionPos" select="$curSectionPos"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@type = 'DIAGRAM'">
    <!-- Select Diagram with the same id as Section id. -->
                        <xsl:variable name="diag" select="$tp/Diagrams/Diagram[@id = current()/@id]"/>
                        <xsl:if test="$diag/Add">
                            <xsl:call-template name="addBookmark">
                                <xsl:with-param name="pSection" select="current()"/>
                                <xsl:with-param name="pSectionPos" select="$curSectionPos"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@type = 'PAGE_BREAK'">
    <!-- Page break sections are not displayed as PDF bookmarks. -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="addBookmark">
                            <xsl:with-param name="pSection" select="current()"/>
                            <xsl:with-param name="pSectionPos" select="$curSectionPos"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addBookmarkWithContent
    Description:    Overwrite addBookmarks in sections_fo.xsl.
-->
<xsl:template name="addBookmarkWithContent"> <xsl:param name="pItem"/> <xsl:param name="pPos"/>

    <xsl:variable name="hasContent">
        <xsl:choose>
    <!-- (VV-020, 99GEMS, Pre Exam) -->
            <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-020' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
        <!-- (J-06170, SNM3, Radiologist) -->
                <xsl:variable name="noRadiologist" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue != 'J-06170' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
        <!-- (J-0016E, SNM3, Doctor) -->
                <xsl:variable name="noDoctor" select="$noRadiologist[ConceptNameCodeSequence/Item/CodeValue != 'J-0016E' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
        <!-- (J-0612B, SNM3, Cardiologist) -->
                <xsl:variable name="noCardiologist" select="$noDoctor[ConceptNameCodeSequence/Item/CodeValue != 'J-0612B' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED_RT]"/>
        <!-- (S-32000, SNM3, Smoker) -->
                <xsl:variable name="noSmoker" select="$noCardiologist[ConceptNameCodeSequence/Item/CodeValue != 'S-32000' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
        <!-- (F-02A18, SNM3, Overweight) -->
                <xsl:variable name="noOverweight" select="$noSmoker[ConceptNameCodeSequence/Item/CodeValue != 'F-02A18' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
        <!-- (VV-050, 99GEMS, Diabetes) -->
                <xsl:variable name="noDiabetes" select="$noOverweight[ConceptNameCodeSequence/Item/CodeValue != 'VV-050' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_GEMS]"/>
        <!-- (F-63980, SNM3, Cholesterol) -->
                <xsl:variable name="noCholesterol" select="$noDiabetes[ConceptNameCodeSequence/Item/CodeValue != 'F-63980' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
                <xsl:variable name="itemsDisplayedUnderPreExam" select="$noCholesterol"/>
                <xsl:call-template name="hasContent">
                    <xsl:with-param name="pItems" select="$itemsDisplayedUnderPreExam"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="hasContent">
                    <xsl:with-param name="pItems" select="$pItem/ContentSequence/Item"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="$hasContent = 'true'">
        <fox:outline internal-destination="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPos)}">
            <fox:label>
                <xsl:call-template name="addContainerName">
                    <xsl:with-param name="pItem" select="$pItem"/>
                </xsl:call-template>
            </fox:label>
        </fox:outline>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addContentItem
    Description:    Add content item to report based on different cardiac protocols.
    Parameters:
        pItem    :  First level ContentItem in the report.
-->
<xsl:template name="addContentItem"> <xsl:param name="pItem"/>
                                     <xsl:param name="pPosition"/>

    <xsl:choose>
<!-- (PQ-0110, 99GEMS, Patient Questions) -->
        <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
            <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </fo:block>
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
            <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
            </fo:block>
            <xsl:call-template name="addItemWithGeneric">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addVVContentItem
    Description:    Add CardIQ, CTC, ALA, CardIQ Function content items to report.
    Parameters:
        pItem    :  First level content item in the report.
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addVVContentItem"> <xsl:param name="pItem"/>
                                       <xsl:param name="pPosition"/>

    <xsl:if test="$pItem/RelationshipType = 'CONTAINS'">
    <xsl:choose>
<!-- The content item is coming from an application specific report. -->
        <xsl:when test="$pItem/@app">
            <xsl:choose>
        <!-- (121064, DCM, Current Procedure Descriptions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121064' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                    <xsl:call-template name="addCurrentProcedureDescriptions">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (121071, DCM, Finding) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121071' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                    <xsl:call-template name="addFinding">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (M-01470, SNM3, Plaque) used for Plaque, Stent, Bypass, Anomalous type finding. -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'M-01470' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addPlaque">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (M-32200, SNM3, Aneurysm) used for Aneurysm type finding. -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'M-32200' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addAneurysm">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (F-30164, SNM3, Cardiac Finding) used for Normal, Ancillary, Other type finding.  -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'F-30164' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addCardiacFinding">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (F-32000, SRT, Cardiac Function) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'F-32000' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                    <xsl:call-template name="addCardiacFunction">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (M-76800, SNM3, Polyp) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'M-76800' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED">
                    <xsl:call-template name="addPolyp">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-006, 99GEMS, Extra Finding) used for Ejection Fraction type finding. -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-006' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addExtraFinding">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
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
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (T-28000, SRT, Lung) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'T-28000' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT">
                    <xsl:call-template name="addLung">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-024, 99GEMS, General Images) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-024' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addVVGeneralImages">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-020, 99GEMS, Pre Exam) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-020' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addPreExam">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (VV-019, 99GEMS, Post Exam) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'VV-019' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <xsl:call-template name="addPostExam">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (121076, DCM, Conclusions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = '121076' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                    <xsl:call-template name="addPostExam">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                        <xsl:with-param name="pWithSubTitles" select="'false'"/>
                    </xsl:call-template>
                </xsl:when>

        <!-- (PQ-0110, 99GEMS, Patient Questions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                    <xsl:call-template name="addPatientQuestions">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:call-template name="addItemWithGenericAndName">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
        <!-- (PQ-0110, 99GEMS, Patient Questions) -->
                <xsl:when test="$pItem/ConceptNameCodeSequence/Item/CodeValue = 'PQ-0110' and $pItem/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS">
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:value-of select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                    <xsl:call-template name="addPatientQuestions">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="addItemWithGenericAndName">
                        <xsl:with-param name="pItem" select="$pItem"/>
                        <xsl:with-param name="pPosition" select="$pPosition"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:if>

</xsl:template>

<!-- ####################################################################################################
    Template:       addItemWithGenericAndName
    Description:    Add content item to report.
    Parameters:
        pItem    :  Content item to add.
-->
<xsl:template name="addItemWithGenericAndName"> <xsl:param name="pItem"/>
                                                <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell>
                    <xsl:call-template name="addItemWithGeneric">
                        <xsl:with-param name="pItem" select="$pItem"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPreExam
    Description:    Adds Pre Exam content item.
    Parameters:
        pItem    :  (VV-020, 99GEMS, Pre Exam) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPreExam"> <xsl:param name="pItem"/>
                                 <xsl:param name="pPosition"/>

<!-- (J-06170, SNM3, Radiologist) -->
    <xsl:variable name="noRadiologist" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue != 'J-06170' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
<!-- (J-0016E, SNM3, Doctor) -->
    <xsl:variable name="noDoctor" select="$noRadiologist[ConceptNameCodeSequence/Item/CodeValue != 'J-0016E' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
<!-- (J-0612B, SNM3, Cardiologist) -->
    <xsl:variable name="noCardiologist" select="$noDoctor[ConceptNameCodeSequence/Item/CodeValue != 'J-0612B' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED_RT]"/>
<!-- (S-32000, SNM3, Smoker) -->
    <xsl:variable name="noSmoker" select="$noCardiologist[ConceptNameCodeSequence/Item/CodeValue != 'S-32000' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
<!-- (F-02A18, SNM3, Overweight) -->
    <xsl:variable name="noOverweight" select="$noSmoker[ConceptNameCodeSequence/Item/CodeValue != 'F-02A18' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
<!-- (VV-050, 99GEMS, Diabetes) -->
    <xsl:variable name="noDiabetes" select="$noOverweight[ConceptNameCodeSequence/Item/CodeValue != 'VV-050' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_GEMS]"/>
<!-- (F-63980, SNM3, Cholesterol) -->
    <xsl:variable name="noCholesterol" select="$noDiabetes[ConceptNameCodeSequence/Item/CodeValue != 'F-63980' or ConceptNameCodeSequence/Item/CodingSchemeDesignator != $CSD_SNOMED]"/>
    <xsl:variable name="itemsDisplayedUnderPreExam" select="$noCholesterol"/>
    <xsl:variable name="hasContent">
        <xsl:call-template name="hasContent">
            <xsl:with-param name="pItems" select="$itemsDisplayedUnderPreExam"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$hasContent = 'true'">
        <fo:table table-layout="fixed" width="100%" space-after="4pt">
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-body>
                <fo:table-row keep-with-next="always">
                    <fo:table-cell>
                        <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                            <xsl:call-template name="addContainerName">
                                <xsl:with-param name="pItem" select="$pItem"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                    <fo:table-cell>
<!-- (VV-021, 99GEMS, Family Medical history) -->
                        <xsl:variable name="famMedHist" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-021' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:variable name="famMedHistHasContent">
                            <xsl:call-template name="hasContent">
                                <xsl:with-param name="pItems" select="$famMedHist"/>
                            </xsl:call-template>
                        </xsl:variable>
<!-- (VV-022, 99GEMS, Patient history) -->
                        <xsl:variable name="patHist" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-022' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:variable name="patHistHasContent">
                            <xsl:call-template name="hasContent">
                                <xsl:with-param name="pItems" select="$patHist"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="($famMedHistHasContent = 'true' or $patHistHasContent = 'true')">
                            <xsl:call-template name="addTwoInARow">
                                <xsl:with-param name="p1st" select="$famMedHist"/>
                                <xsl:with-param name="p2nd" select="$patHist"/>
                            </xsl:call-template>
                        </xsl:if>
<!-- (VV-023, 99GEMS, Exam procedure) -->
                        <xsl:variable name="examProc" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-023' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:variable name="examProcHasContent">
                            <xsl:call-template name="hasContent">
                                <xsl:with-param name="pItems" select="$examProc"/>
                            </xsl:call-template>
                        </xsl:variable>
<!-- (VV-072, 99GEMS, Scan dose) -->
                        <xsl:variable name="scanDose" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-072' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:variable name="scanDoseHasContent">
                            <xsl:call-template name="hasContent">
                                <xsl:with-param name="pItems" select="$scanDose"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="($examProcHasContent = 'true' or $scanDoseHasContent = 'true')">
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
                            <fo:table table-layout="fixed" width="100%">
                                <fo:table-column column-width="proportional-column-width(1)"/>
                                <fo:table-column column-width="proportional-column-width(1)"/>
                                <fo:table-header>
                                    <fo:table-row background-color="#{$P2}">
                                        <fo:table-cell padding-right="2pt">
                                            <fo:block>
                                                <xsl:if test="$indications">
                                                <fo:inline font-weight="bold" text-decoration="underline">
                                                    <xsl:value-of select="$indications/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                </fo:inline>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$dominance">
                                                <fo:inline font-weight="bold" text-decoration="underline">
                                                    <xsl:value-of select="$dominance/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                </fo:inline>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </fo:table-header>
                                <fo:table-body>
                                    <fo:table-row>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$indications">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$indications"/>
                                                </xsl:call-template>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$dominance">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$dominance"/>
                                                </xsl:call-template>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </fo:table-body>
                            </fo:table>
                        </xsl:if>
<!-- (8867-4, LN, Heart rate) -->
                        <xsl:variable name="hr" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '8867-4' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_LOINC]"/>
<!-- (CAR-036, 99GEMS, Beta Blockers) -->
                        <xsl:variable name="betaB" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (CAR-037, 99GEMS, Nitro) -->
                        <xsl:variable name="nitro" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-037' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                        <xsl:if test="$hr or $betaB or $nitro">
                            <fo:table table-layout="fixed" width="100%">
                                <fo:table-column column-width="proportional-column-width(1)"/>
                                <fo:table-column column-width="proportional-column-width(1)"/>
                                <fo:table-column column-width="proportional-column-width(1)"/>
                                <fo:table-header>
                                    <fo:table-row background-color="#{$P2}">
                                        <fo:table-cell padding-right="2pt">
                                            <fo:block>
                                                <xsl:if test="$hr">
                                                <fo:inline font-weight="bold" text-decoration="underline">
                                                    <xsl:value-of select="$hr/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                </fo:inline>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$nitro">
                                                <fo:inline font-weight="bold" text-decoration="underline">
                                                    <xsl:value-of select="$nitro/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                </fo:inline>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$betaB">
                                                <fo:inline font-weight="bold" text-decoration="underline">
                                                    <xsl:value-of select="$betaB/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                                </fo:inline>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </fo:table-header>
                                <fo:table-body>
                                    <fo:table-row>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$hr">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$hr"/>
                                            <!-- Display Code Meaning of Measurement Units Code Sequence. -->
                                                    <xsl:with-param name="pUnit" select="'cm'"/>
                                                    <xsl:with-param name="pPattern" select="'#,##0'"/>
                                                </xsl:call-template>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$nitro">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$nitro"/>
                                                </xsl:call-template>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:if test="$betaB">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$betaB"/>
                                                </xsl:call-template>
                                                </xsl:if>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </fo:table-body>
                            </fo:table>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:if>
</xsl:template>

<xsl:template name="addTwoInARow"> <xsl:param name="p1st"/>
                                   <xsl:param name="p2nd"/>

    <fo:table table-layout="fixed" width="100%" space-after="2pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>

        <xsl:variable name="p1stHasContent">
            <xsl:call-template name="hasContent">
                <xsl:with-param name="pItems" select="$p1st"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="p2ndHasContent">
            <xsl:call-template name="hasContent">
                <xsl:with-param name="pItems" select="$p2nd"/>
            </xsl:call-template>
        </xsl:variable>
        <fo:table-header>
            <fo:table-row background-color="#{$P2}">
                <xsl:choose>
                    <xsl:when test="$p1stHasContent = 'false' or $p2ndHasContent = 'false'">
                        <fo:table-cell number-columns-spanned="2">
                            <fo:block hyphenate="true" language="{$lang}">
                                <xsl:choose>
                                    <xsl:when test="$p1stHasContent = 'true'">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$p1st/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </xsl:when>
                                    <xsl:when test="$p2ndHasContent = 'true'">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$p2nd/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </xsl:when>
                                </xsl:choose>
                            </fo:block>
                        </fo:table-cell>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:table-cell padding-right="2pt">
                            <fo:block hyphenate="true" language="{$lang}">
                                <xsl:if test="$p1stHasContent = 'true'">
                                <fo:inline font-weight="bold" text-decoration="underline">
                                    <xsl:value-of select="$p1st/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                </fo:inline>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}">
                                <xsl:if test="$p2ndHasContent = 'true'">
                                <fo:inline font-weight="bold" text-decoration="underline">
                                    <xsl:value-of select="$p2nd/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                </fo:inline>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:table-row>
        </fo:table-header>
        <fo:table-body>
            <fo:table-row>
                <xsl:choose>
                    <xsl:when test="$p1stHasContent = 'false' or $p2ndHasContent = 'false'">
                        <fo:table-cell number-columns-spanned="2">
                            <fo:block hyphenate="true" language="{$lang}">
                                <xsl:choose>
                                    <xsl:when test="$p1stHasContent = 'true'">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$p1st"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$p2ndHasContent = 'true'">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$p2nd"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                </xsl:choose>
                            </fo:block>
                        </fo:table-cell>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:table-cell padding-right="2pt">
                            <fo:block hyphenate="true" language="{$lang}">
                                <xsl:if test="$p1stHasContent = 'true'">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$p1st"/>
                                </xsl:call-template>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}">
                                <xsl:if test="$p2ndHasContent = 'true'">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$p2nd"/>
                                </xsl:call-template>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:table-row>
        </fo:table-body>
    </fo:table>

</xsl:template>

<!-- ####################################################################################################
    Template:       addPostExam
    Description:    Adds Pre Exam content item.
    Parameters:
        pItem    :  (VV-019, 99GEMS, Post Exam) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPostExam"> <xsl:param name="pItem"/> <xsl:param name="pPosition"/>
                                  <xsl:param name="pWithSubTitles" select="'true'"/>

    <xsl:variable name="hasContent">
        <xsl:call-template name="hasContent">
            <xsl:with-param name="pItems" select="$pItem/ContentSequence/Item"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$hasContent = 'true'">
        <fo:table table-layout="fixed" width="100%" space-after="4pt">
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-body>
                <fo:table-row keep-with-next="always">
                    <fo:table-cell>
                        <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                            <xsl:call-template name="addContainerName">
                                <xsl:with-param name="pItem" select="$pItem"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                    <fo:table-cell>
                        <xsl:for-each select="$pItem/ContentSequence/Item">
                            <xsl:variable name="currentHasContent">
                                <xsl:call-template name="hasContent">
                                    <xsl:with-param name="pItems" select="current()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="$currentHasContent = 'true'">
                                <xsl:if test="$pWithSubTitles = 'true'">
                                    <fo:block id="{concat(current()/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="2pt" space-after="2pt" font-weight="bold" font-size="{$heading2FontSize}pt">
                                        <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </fo:block>
                                </xsl:if>
                                <fo:block hyphenate="true" language="{$lang}">
                                    <xsl:call-template name="addValue">
                                        <xsl:with-param name="pCurrent" select="current()"/>
                                    </xsl:call-template>
                                </fo:block>
                            </xsl:if>
                        </xsl:for-each>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:if>
</xsl:template>

<xsl:template name="addComment"> <xsl:param name="pComment"/>

    <xsl:variable name="commentHasContent">
        <xsl:call-template name="hasContent">
            <xsl:with-param name="pItems" select="$pComment"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$commentHasContent = 'true'">
    <fo:table-row>
        <fo:table-cell>
            <fo:block hyphenate="true" language="{$lang}">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$pComment"/>
                </xsl:call-template>
            </fo:block>
        </fo:table-cell>
    </fo:table-row>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addFinding
    Description:    Adds Finding content item.
    Parameters:
        pItem    :  (121071, DCM, Finding) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addFinding"> <xsl:param name="pItem"/>
                                 <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
<!-- (121106, DCM, Comment) -->
            <xsl:call-template name="addComment">
                <xsl:with-param name="pComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
            <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
<!-- (R-40831, DCM, Measurement) items -->
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPlaque
    Description:    Adds Plaque content item used for Plaque, Stent, Bypass, Anomalous type finding.
    Parameters:
        pItem    :  (M-01470, SNM3, Plaque) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPlaque"> <xsl:param name="pItem"/>
                                <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:variable name="branch" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="branchHasContent">
                <xsl:call-template name="hasContent">
                    <xsl:with-param name="pItems" select="$branch"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="location" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C1E8' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:variable name="type" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D70D' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:variable name="riskComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-025' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="characterization" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-031' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="description" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:if test="$branchHasContent = 'true' or $location or $type or $characterization or $description">
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(3)"/>
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-header>
                            <fo:table-row background-color="#{$P2}">
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$branch/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$location/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$type/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$characterization/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$description/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <fo:table-row>
<!-- (CAR-030, 99GEMS, Branch Name) -->
                                <fo:table-cell>
                                    <xsl:if test="$branchHasContent = 'true'">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$branch"/>
                                        </xsl:call-template>
                                    </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
<!-- (G-C1E8, SNM3, Location) -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$location"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
<!-- (G-D70D, SNM3, Type), (VV-025, 99GEMS, Risk comment) -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$type"/>
                                        </xsl:call-template>
                                    </fo:block>
                                    <xsl:if test="$riskComment">
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                            <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="$riskComment"/>
                                            </xsl:call-template>
                                        </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
<!-- (CAR-030, 99GEMS, Characterization) -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$characterization"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
<!-- (CAR-032, 99GEMS, Description) items -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:for-each select="$description">
                                            <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="current()"/>
                                            </xsl:call-template>
                                            <xsl:if test="position() != last()">, </xsl:if>
                                        </xsl:for-each>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (121106, DCM, Comment) -->
            <xsl:call-template name="addComment">
                <xsl:with-param name="pComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
            <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
<!-- (R-40831, DCM, Measurement) items -->
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addAneurysm
    Description:    Adds Aneurysm content item used for Aneurysm type finding.
    Parameters:
        pItem    :  (M-32200, SNM3, Aneurysm) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addAneurysm"> <xsl:param name="pItem"/>
                                  <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:variable name="branch" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="branchHasContent">
                <xsl:call-template name="hasContent">
                    <xsl:with-param name="pItems" select="$branch"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="description" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:if test="$branchHasContent = 'true' or $description">
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-header>
                            <fo:table-row background-color="#{$P2}">
                                <fo:table-cell>
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$branch/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$description/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <fo:table-row>
<!-- (G-C57F, SNM3, Vessel) -->
                                <fo:table-cell>
                                    <xsl:if test="$branchHasContent = 'true'">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$branch"/>
                                        </xsl:call-template>
                                    </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
<!-- (CAR-028, 99GEMS, Aneurysm description) items -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:for-each select="$description">
                                            <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="current()"/>
                                            </xsl:call-template>
                                            <xsl:if test="position() != last()">, </xsl:if>
                                        </xsl:for-each>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (121106, DCM, Comment) -->
            <xsl:call-template name="addComment">
                <xsl:with-param name="pComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
            <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
<!-- (R-40831, DCM, Measurement) items -->
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCardiacFinding
    Description:    Adds Cardiac Finding content item used for Normal, Ancillary, Other type finding.
    Parameters:
        pItem    :  (F-30164, SNM3, Cardiac Finding) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addCardiacFinding"> <xsl:param name="pItem"/>
                                        <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:variable name="branch" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAR-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="branchHasContent">
                <xsl:call-template name="hasContent">
                    <xsl:with-param name="pItems" select="$branch"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="comment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:variable name="commentHasContent">
                <xsl:call-template name="hasContent">
                    <xsl:with-param name="pItems" select="$comment"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$branchHasContent = 'true' or $commentHasContent = 'true'">
            <fo:table-row>
                <fo:table-cell>
                    <xsl:if test="$branchHasContent = 'true'">
                    <fo:block hyphenate="true" language="{$lang}">
                        <fo:inline font-weight="bold">
                            <xsl:value-of select="$branch/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            <xsl:text>: </xsl:text>
                        </fo:inline>
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$branch"/>
                        </xsl:call-template>
                    </fo:block>
                    </xsl:if>
<!-- (121106, DCM, Comment) -->
                    <xsl:if test="$commentHasContent = 'true'">
                        <fo:block hyphenate="true" language="{$lang}">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$comment"/>
                            </xsl:call-template>
                        </fo:block>
                    </xsl:if>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
            <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
<!-- (R-40831, DCM, Measurement) items -->
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCardiacFunction
    Description:    Adds Cardiac Function content item.
    Parameters:
    pItem    :  (F-32000, SRT, Cardiac Function) content item
-->
<xsl:template name="addCardiacFunction"> <xsl:param name="pItem"/>
                                         <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="2pt" space-after="2pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
    <!-- (121106, DCM, Comment) -->
            <xsl:call-template name="addComment">
                <xsl:with-param name="pComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
    <!-- (T-32600, SRT, Left Ventricle) -->
            <xsl:variable name="lv" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32600' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
            <xsl:if test="$lv">
                <xsl:call-template name="addCardiacCavityCell">
                    <xsl:with-param name="pItem" select="$lv"/>
                </xsl:call-template>
            </xsl:if>
    <!-- (T-32500, SRT, Right Ventricle) -->
            <xsl:variable name="rv" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32500' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
            <xsl:if test="$rv">
                <xsl:call-template name="addCardiacCavityCell">
                    <xsl:with-param name="pItem" select="$rv"/>
                </xsl:call-template>
            </xsl:if>
    <!-- (T-32300, SRT, Left Atrium) -->
            <xsl:variable name="la" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32300' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
            <xsl:if test="$la">
                <xsl:call-template name="addCardiacCavityCell">
                    <xsl:with-param name="pItem" select="$la"/>
                </xsl:call-template>
            </xsl:if>
    <!-- (T-32200, SRT, Right Atrium) -->
            <xsl:variable name="ra" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-32200' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
            <xsl:if test="$ra">
                <xsl:call-template name="addCardiacCavityCell">
                    <xsl:with-param name="pItem" select="$ra"/>
                </xsl:call-template>
            </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCardiacCavityCell
    Description:    Adds Cardiac Cavity table cell.
    Parameters:
    pItem    :  i.e. (T-32600, SRT, Left Ventricle)  item
-->

<xsl:template name="addCardiacCavityCell"> <xsl:param name="pItem"/>

    <fo:table-row>
        <fo:table-cell>
            <xsl:call-template name="addCardiacCavityFunction">
                <xsl:with-param name="pItem" select="$pItem"/>
            </xsl:call-template>
        </fo:table-cell>
    </fo:table-row>
<!-- (CAPTURE, DCM, Image Capture) items -->
    <xsl:call-template name="addImageCaptures2">
        <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCardiacCavityFunction
    Description:    Adds Cardiac Cavity Function content item.
    Parameters:
    pItem    :  i.e. (T-32600, SRT, Left Ventricle)  item
    pPosition:  Position of content item in the content sequence.
-->

<xsl:template name="addCardiacCavityFunction"> <xsl:param name="pItem"/>
                                               <xsl:param name="pPosition"/>

    <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    
    <fo:table table-layout="fixed" width="100%" space-before="8pt" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block space-before="2pt" space-after="2pt" font-weight="bold" font-size="{$heading1FontSize}pt">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%">
                        <xsl:for-each select="$measurements">
                            <fo:table-column column-width="proportional-column-width(2)"/>
                        </xsl:for-each>
                        <fo:table-header>
                           <fo:table-row background-color="#{$P2}">
                               <xsl:for-each select="$measurements">
                                    <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
                                    <xsl:if test="count($num) = 1">
                                        <fo:table-cell display-align="center" padding-top="2pt" padding-left="2pt" padding-bottom="2pt" padding-right="2pt" border-top-style="solid" border-left-style="solid" border-right-style="solid" border-bottom-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                            <fo:block hyphenate="true" language="{$lang}" text-align="center">
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
                                            </fo:block>
                                        </fo:table-cell>
                                    </xsl:if>
                                </xsl:for-each>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <fo:table-row>                            
                            <xsl:for-each select="$measurements">
                                    <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
    <!-- If there is only one NUM item then it is a CVA measurement and not ROI data. -->
                                    <xsl:if test="count($num) = 1">
                                   
        <!-- Measurement Value -->
                                        <fo:table-cell display-align="center" border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                            <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                                <xsl:call-template name="addNumWithPrecision">
                                                    <xsl:with-param name="pNum" select="$num"/>
                                                </xsl:call-template>
                                            </fo:block>
        <!-- (121106, DCM, Comment) -->
                                            <xsl:variable name="comment" select="$num/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                            <xsl:variable name="commentHasContent">
                                                <xsl:call-template name="hasContent">
                                                    <xsl:with-param name="pItems" select="$comment"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:if test="$commentHasContent = 'true'">
                                                <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                                    <xsl:call-template name="addValue">
                                                        <xsl:with-param name="pCurrent" select="$comment"/>
                                                    </xsl:call-template>
                                                </fo:block>
                                            </xsl:if>
                                        </fo:table-cell>
                                    </xsl:if>
                                </xsl:for-each>
                            </fo:table-row>                        
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
            <fo:table-row>
                <fo:table-cell>
<!-- (R-40831, DCM, Measurement) items -->
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="$measurements[count(ContentSequence/Item/ValueType_NUM) != 1]"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
    
    
<!-- cavity tables like bullsEye or Phase Volumes    -->

    <xsl:variable name="cavityTable" select="$pItem/ContentSequence/Item[(ConceptNameCodeSequence/Item/CodeValue = '122445' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM) or
                                                                           (ConceptNameCodeSequence/Item/CodeValue = '122607' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM) or 
                                                                           (ConceptNameCodeSequence/Item/CodeValue = 'F-32050' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT) or
                                                                           (ConceptNameCodeSequence/Item/CodeValue = 'CAR-042' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS)]"/>
     <xsl:if test="$cavityTable">
        <xsl:for-each select="$cavityTable">
             <xsl:variable name="cavityMeasurements" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
     
            <fo:table table-layout="fixed" width="100%" space-before="8pt" space-after="4pt">
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-body>
                <fo:table-row keep-with-next="always">
                    <fo:table-cell>
    <!-- Bullseye Table name -->
                        <fo:block space-before="2pt" space-after="2pt" font-weight="bold" font-size="{$heading3FontSize}pt">
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
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
<!-- innen jon majd a rekurziv hivas -->
                <xsl:call-template name="addNFunctionCavityTable">
                    <xsl:with-param name="pMeasurements" select="$cavityMeasurements"/>
                    <xsl:with-param name="pN" select="10"/>
                </xsl:call-template>

            </fo:table-body>
            </fo:table>
        </xsl:for-each>
    </xsl:if>
                
</xsl:template>


<!-- ####################################################################################################
    Template:       addNFunctionCavityTable
    Description:    Adds Tables belonging to the cavities: bull's eye tables for LV, Phase Volume Tables for every cavity (LV, RV, RA, LA)
                    recursively (pN cell in a line)
    Parameters:
    pItem    :  i.e. (T-32600, SRT, Left Ventricle)  item
-->
<xsl:template name="addNFunctionCavityTable"> 
                    <xsl:param name="pMeasurements"/>
                    <xsl:param name="pN" select="$imgColumns"/>

    <xsl:variable name="firstNMeasurements" select="$pMeasurements[position() &lt;= $pN]"/>
    <xsl:if test="$firstNMeasurements">
        <fo:table-row>
            <fo:table-cell>
                <fo:table table-layout="fixed" width="100%">
                    <xsl:for-each select="$firstNMeasurements">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                    </xsl:for-each>
                    <fo:table-header>
                       <fo:table-row background-color="#{$P2}">                            
                           <xsl:for-each select="$firstNMeasurements">
                                <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
                                <xsl:if test="count($num) = 1">
                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-right-style="solid" border-bottom-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block text-align="center">
                                            <xsl:call-template name="addContainerName">
                                                <xsl:with-param name="pItem" select="$num"/>
                                            </xsl:call-template> 
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:if>
                            </xsl:for-each>
                        </fo:table-row>
                    </fo:table-header>
                    <fo:table-body>
                        <fo:table-row>                            
                        <xsl:for-each select="$firstNMeasurements">
                                <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
<!-- If there is only one NUM item then it is a CVA measurement and not ROI data. -->
                                <xsl:if test="count($num) = 1">
                                    <fo:table-cell display-align="center" border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                            <xsl:call-template name="addValue">
                                                <xsl:with-param name="pCurrent" select="$num"/>
                                                <xsl:with-param name="pUnit" select="'none'"/>
                                            </xsl:call-template>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:if>
                            </xsl:for-each>
                        </fo:table-row>                        
                    </fo:table-body>
                </fo:table>
            </fo:table-cell>
        </fo:table-row>
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
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addPolyp"> <xsl:param name="pItem"/>
                               <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="2pt" space-after="2pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:variable name="location" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C1E8' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:variable name="shape" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-C2FE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:variable name="size" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CTC-004' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="distRectum" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CTC-003' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:if test="$location or $shape or $size or $distRectum">
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-header>
                            <fo:table-row background-color="#{$P2}">
                                <fo:table-cell>
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$location/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$shape/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$size/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$distRectum/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <fo:table-row>
<!-- (G-C1E8, SNM3, Location) -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$location"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
<!-- (G-C2FE, SNM3, Shape) -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$shape"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
<!-- (CTC-004, 99GEMS, Lesion size) -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$size"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
<!-- (CTC-003, 99GEMS, Distance from Rectum) -->
                                <fo:table-cell>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="$distRectum"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (121106, DCM, Comment) -->
            <xsl:call-template name="addComment">
                <xsl:with-param name="pComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
            <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
<!-- (R-40831, DCM, Measurement) items -->
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addExtraFinding
    Description:    Adds Extra Finding content item used for Ejection Fraction type finding.
    Parameters:
        pItem    :  (VV-006, 99GEMS, Extra Finding) content item.
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addExtraFinding"> <xsl:param name="pItem"/>
                                      <xsl:param name="pPosition"/>

    <xsl:variable name="measurements" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="2pt" space-after="2pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-header>
                            <fo:table-row background-color="#{$P2}">
                                <fo:table-cell border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$messagecatalog/LBL_MEASUREMENT/msg[@lang = $lang]"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$messagecatalog/LBL_VALUE/msg[@lang = $lang]"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <xsl:for-each select="$measurements">
                                <xsl:variable name="num" select="current()/ContentSequence/Item[ValueType_NUM]"/>
<!-- If there is only one NUM item then it is a CVA measurement and not ROI data. -->
                                <xsl:if test="count($num) = 1">
                                <fo:table-row>
    <!-- (VV-008, 99GEMS, Name) -->
                                    <fo:table-cell display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block text-align="center">
                                            <xsl:call-template name="addContainerName">
                                                <xsl:with-param name="pItem" select="$num"/>
                                            </xsl:call-template>
                                        </fo:block>
                                    </fo:table-cell>
    <!-- Measurement Value -->
                                    <fo:table-cell display-align="center" border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block text-align="center">
                                            <xsl:call-template name="addNumWithPrecision">
                                                <xsl:with-param name="pNum" select="$num"/>
                                            </xsl:call-template>
                                        </fo:block>
    <!-- (121106, DCM, Comment) -->
                                        <xsl:variable name="comment" select="$num/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                        <xsl:variable name="commentHasContent">
                                            <xsl:call-template name="hasContent">
                                                <xsl:with-param name="pItems" select="$comment"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:if test="$commentHasContent = 'true'">
                                            <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$comment"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </xsl:if>
                                    </fo:table-cell>
                                </fo:table-row>
                                </xsl:if>
                            </xsl:for-each>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (121106, DCM, Comment) -->
            <xsl:call-template name="addComment">
                <xsl:with-param name="pComment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
<!-- (R-40831, DCM, Measurement) items -->
                    <xsl:call-template name="addMeasurements">
                        <xsl:with-param name="pMeasurements" select="$measurements[count(ContentSequence/Item/ValueType_NUM) != 1]"/>
                    </xsl:call-template>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addScanParameters
    Description:    Adds Scan Parameters.
    Parameters:
        pItem    :  (ALA-029, 99GEMS, Scan Parameters) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addScanParameters"> <xsl:param name="pItem"/>
                                        <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
    <!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
    <!-- (ALA-085, 99GEMS, Scan Exam) items. -->
            <xsl:variable name="scanExams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-085' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(4)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <fo:table-column column-width="proportional-column-width(3)"/>
                        <fo:table-column column-width="proportional-column-width(3)"/>
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
                        <fo:table-header>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$pixelSize/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        (<xsl:value-of select="$pixelSize/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$thickness/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                            <xsl:text> / </xsl:text>
                                            <xsl:value-of select="$spacing/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        (<xsl:value-of select="$thickness/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>)
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$voltage/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$current/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$dose/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$recon/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$manufacturer/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <xsl:for-each select="$scanExams">
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                        <xsl:text> / </xsl:text>
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-037' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                            <xsl:with-param name="pUnit" select="'none'"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-031' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            </xsl:for-each>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addLung
    Description:    Adds Lung.
    Parameters:
        pItem    :  (T-28000, SRT, Lung) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addLung"> <xsl:param name="pItem"/> <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
    <!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
    <!-- (ALA-041, 99GEMS, Lung Exam) items. -->
            <xsl:variable name="lungExams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-041' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <fo:table-row>
                <fo:table-cell>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <xsl:for-each select="$lungExams">
                            <fo:table-column column-width="proportional-column-width(2)"/>
                        </xsl:for-each>
                        <fo:table-header>
                            <fo:table-row>
        <!-- (ALA-011, 99GEMS, Exam Date) -->
                                <xsl:variable name="examDate" select="$lungExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block text-align="left">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <xsl:for-each select="$lungExams">
                                    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block text-align="center">
                                            <fo:inline font-weight="bold" text-decoration="underline">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                                </xsl:call-template>
                                            </fo:inline>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:for-each>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                            <fo:table-row>
                                <xsl:variable name="lungVolumeItems" select="$lungExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="left">
                                        <fo:inline font-weight="bold">
                                            <xsl:value-of select="$lungVolumeItems/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <xsl:for-each select="$lungExams">
                                    <xsl:variable name="lungVolumeItem" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                                    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block text-align="center">
                                            <xsl:call-template name="addNoduleVolume">
                                                <xsl:with-param name="pVolume" select="$lungVolumeItem"/>
                                            </xsl:call-template>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:for-each>
                            </fo:table-row>
    <!-- Add total nodule volumes if (M-03010, SRT, Nodule) content items are present. -->
                            <xsl:variable name="nodules" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'M-03010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                            <xsl:if test="$nodules">
                                <fo:table-row>
                                    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block hyphenate="true" language="{$lang}" text-align="left">
                                            <fo:inline font-weight="bold">
                                                <xsl:value-of select="$messagecatalog/LBL_TOTAL_NODULE_VOLUME/msg[@lang = $lang]"/>
                                            </fo:inline>
                                        </fo:block>
                                    </fo:table-cell>
        <!-- (ALA-010, 99GEMS, Nodule Exam) items. -->
                                    <xsl:variable name="noduleExams" select="$nodules/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
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
                                        <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                            <fo:block text-align="center">
                                                <xsl:call-template name="addTotalNoduleVolume">
                                                    <xsl:with-param name="pTotal" select="$totalNoduleVolume"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </fo:table-cell>
                                    </xsl:for-each>
                                </fo:table-row>
                            </xsl:if>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNodule
    Description:    Adds Nodule.
    Parameters:
        pItem    :  (M-03010, SRT, Nodule) content item
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addNodule"> <xsl:param name="pItem"/> <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
    <!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
<!-- (ALA-010, 99GEMS, Nodule Exam) items. -->
            <xsl:variable name="noduleExams" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-010' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
<!-- (ALA-011, 99GEMS, Exam Date) -->
            <xsl:variable name="examDate" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <fo:table-row>
                <fo:table-cell>
                    <xsl:variable name="lobe" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'T-28770' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT]"/>
                    <xsl:variable name="comment" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                    <xsl:if test="$lobe">
    <!-- (T-28770, SRT, Lobe of lung) -->
                        <fo:block hyphenate="true" language="{$lang}">
                            <fo:inline font-weight="bold">
                                <xsl:value-of select="$lobe/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                <xsl:text>: </xsl:text>
                            </fo:inline>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$lobe"/>
                            </xsl:call-template>
                        </fo:block>
                    </xsl:if>
                    <xsl:variable name="commentHasContent">
                        <xsl:call-template name="hasContent">
                            <xsl:with-param name="pItems" select="$comment"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:if test="$commentHasContent = 'true'">
    <!-- (121106, DCM, Comment) -->
                        <fo:block hyphenate="true" language="{$lang}">
                            <fo:inline font-weight="bold">
                                <xsl:value-of select="$comment/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                <xsl:text>: </xsl:text>
                            </fo:inline>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$comment"/>
                            </xsl:call-template>
                        </fo:block>
                    </xsl:if>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt" table-omit-header-at-break="true">
                        <fo:table-column column-width="proportional-column-width(1)"/>
                        <xsl:for-each select="$noduleExams">
                            <fo:table-column column-width="proportional-column-width(2)"/>
                        </xsl:for-each>
        <!-- (ALA-011, 99GEMS, Exam Date) -->
                        <fo:table-header>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block text-align="left">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <xsl:for-each select="$noduleExams">
                                    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                            <fo:inline font-weight="bold" text-decoration="underline">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                                </xsl:call-template>
                                            </fo:inline>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:for-each>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
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
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="left">
                                        <fo:inline font-weight="bold">
                                            <xsl:value-of select="concat($l_rs/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $a_ps/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $i_ss/ConceptNameCodeSequence/Item/CodeMeaning)"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <xsl:for-each select="$noduleExams">
                                    <xsl:variable name="l_r" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-100' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <xsl:variable name="a_p" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-101' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <xsl:variable name="i_s" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-102' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block text-align="center">
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
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:for-each>
                            </fo:table-row>
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
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="left">
                                        <fo:inline font-weight="bold">
                                            <xsl:value-of select="$mins/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue"/>
                                        </fo:inline>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="concat('(', $mins/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $avgs/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $maxs/ConceptNameCodeSequence/Item/CodeMeaning, ' / ', $stds/ConceptNameCodeSequence/Item/CodeMeaning, ')')"/>
                                    </fo:block>
                                </fo:table-cell>
                                <xsl:for-each select="$noduleExams">
                                    <xsl:variable name="min" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <xsl:variable name="max" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <xsl:variable name="avg" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <xsl:variable name="std" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center">
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
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:for-each>
                            </fo:table-row>
                            </xsl:if>
        <!-- (CAPTURE, 99GEMS, Image Capture) -->
                            <xsl:variable name="imageCaptures" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                            <xsl:if test="$imageCaptures">
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="left">
                                        <fo:inline font-weight="bold">
                                            <xsl:value-of select="$imageCaptures/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <xsl:for-each select="$noduleExams">
                                    <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                        <xsl:call-template name="addImageCaptures">
                                            <xsl:with-param name="pImages" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                                        </xsl:call-template>
                                    </fo:table-cell>
                                </xsl:for-each>
                            </fo:table-row>
                            </xsl:if>
        <!-- (ALA-010, 99GEMS, Nodule Exam) -->
                            <xsl:call-template name="addNoduleExamRow">
                                <xsl:with-param name="pNoduleExams" select="$noduleExams"/>
                                <xsl:with-param name="pCV" select="'121106'"/>
                                <xsl:with-param name="pCSD" select="$CSD_DICOM"/>
                            </xsl:call-template>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            <xsl:variable name="measurements" select="$noduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <xsl:if test="$measurements">
            <fo:table-row>
                <fo:table-cell>
<!-- Display (R-40831, DCM, Measurement) items separately to give more (enough) space for CCP, etc. -->
                    <fo:block hyphenate="true" language="{$lang}" text-align="left" space-before="2pt" space-after="2pt" font-weight="bold" font-size="{$heading2FontSize}pt">
                        <xsl:value-of select="$measurements/ConceptNameCodeSequence/Item/CodeMeaning"/>
                    </fo:block>
                    <fo:table table-layout="fixed" width="100%" space-after="4pt">
                        <fo:table-column column-width="proportional-column-width(2)"/>
                        <fo:table-column column-width="proportional-column-width(15)"/>
                        <fo:table-header>
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <fo:inline font-weight="bold" text-decoration="underline">
                                            <xsl:value-of select="$examDate/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" background-color="#{$P2}" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                        <fo:table-body>
                        <xsl:for-each select="$noduleExams">
                            <fo:table-row>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                        <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'ALA-011' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                        </xsl:call-template>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                                    <xsl:call-template name="addMeasurements">
                                        <xsl:with-param name="pMeasurements" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'R-40831' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </fo:table-row>
                        </xsl:for-each>
                        </fo:table-body>
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
            </xsl:if>
        </fo:table-body>
    </fo:table>
</xsl:template>

<xsl:template name="addNoduleExamRow"> <xsl:param name="pNoduleExams"/> <xsl:param name="pCV"/> <xsl:param name="pCSD"/>

    <xsl:variable name="items" select="$pNoduleExams/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = $pCV and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $pCSD]"/>
    <xsl:if test="$items">
    <fo:table-row>
        <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
            <fo:block hyphenate="true" language="{$lang}" text-align="left">
                <fo:inline font-weight="bold">
                    <xsl:value-of select="$items/ConceptNameCodeSequence/Item/CodeMeaning"/>
                </fo:inline>
            </fo:block>
        </fo:table-cell>
        <xsl:for-each select="$pNoduleExams">
            <xsl:variable name="item" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = $pCV and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $pCSD]"/>
            <fo:table-cell padding-top="1pt" padding-left="1pt" padding-bottom="1pt" padding-right="1pt" display-align="center" border-top-style="solid" border-left-style="solid" border-bottom-style="solid" border-right-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                <fo:block text-align="center">
                    <xsl:choose>
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
                </fo:block>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>
    </xsl:if>
</xsl:template>

<xsl:template name="addNoduleVolumes"> <xsl:param name="pVolume"/> <xsl:param name="pNonSolid"/> <xsl:param name="pSolid"/>

    <xsl:choose>
        <xsl:when test="$pNonSolid or $pSolid">
            <fo:table table-layout="fixed" width="100%">
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-header>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" text-align="center" font-size="{$fontSize - 2}pt">
                                <fo:inline font-weight="bold" text-decoration="underline">
                                    <xsl:value-of select="$messagecatalog/LBL_NONSOLID/msg[@lang = $lang]"/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" text-align="center" font-size="{$fontSize - 2}pt">
                                <fo:inline font-weight="bold" text-decoration="underline">
                                    <xsl:value-of select="$messagecatalog/LBL_SOLID/msg[@lang = $lang]"/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" text-align="center" font-size="{$fontSize - 2}pt">
                                <fo:inline font-weight="bold" text-decoration="underline">
                                    <xsl:value-of select="$messagecatalog/LBL_TOTAL/msg[@lang = $lang]"/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-header>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block text-align="center">
                                <xsl:call-template name="addNoduleVolume">
                                    <xsl:with-param name="pVolume" select="$pNonSolid"/>
                                </xsl:call-template>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block text-align="center">
                                <xsl:call-template name="addNoduleVolume">
                                    <xsl:with-param name="pVolume" select="$pSolid"/>
                                </xsl:call-template>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block text-align="center">
                                <xsl:call-template name="addNoduleVolume">
                                    <xsl:with-param name="pVolume" select="$pVolume"/>
                                </xsl:call-template>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
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

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <xsl:call-template name="addProportionalTableColumn">
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
        <fo:table-body>
            <xsl:call-template name="addNMeasurements">
                <xsl:with-param name="pMeasurements" select="$pMeasurements"/>
                <xsl:with-param name="pN" select="$pN"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
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
    <fo:table-row keep-with-next="always">
        <xsl:for-each select="$firstNMeasurements">
            <xsl:variable name="imgCapture" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:variable name="name" select="$imgCapture/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
            <xsl:variable name="type" select="$imgCapture/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D70D' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
            <fo:table-cell display-align="center" background-color="#{$P2}">
                <xsl:if test="$name and $name/TextValue != ''">
                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$name"/>
                        </xsl:call-template>
                        <xsl:if test="$type and $name/TextValue != $type/TextValue">
                            <xsl:text> - </xsl:text>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$type"/>
                            </xsl:call-template>
                        </xsl:if>
                    </fo:block>
                </xsl:if>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>
<!-- (CAPTURE, DCM, Image Capture) linked to measurements or ROIs -->
    <fo:table-row keep-together="always">
        <xsl:for-each select="$firstNMeasurements">
            <xsl:variable name="imgCapture" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <fo:table-cell display-align="center">
                <xsl:variable name="manual" select="$imgCapture/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 'G-D221' and ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                <xsl:variable name="automatic" select="$imgCapture/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 'G-D231' and ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                <fo:block text-align="center">
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
                </fo:block>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>
<!-- (121106, DCM, Comment) -->
    <fo:table-row keep-together="always">
        <xsl:for-each select="$firstNMeasurements">
            <xsl:variable name="imgCapture" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:variable name="comment" select="$imgCapture/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            <xsl:variable name="commentHasContent">
                <xsl:call-template name="hasContent">
                    <xsl:with-param name="pItems" select="$comment"/>
                </xsl:call-template>
            </xsl:variable>
            <fo:table-cell display-align="center" padding-bottom="4pt">
                <xsl:if test="$commentHasContent = 'true'">
                    <fo:block hyphenate="true" language="{$lang}" text-align="center">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$comment"/>
                        </xsl:call-template>
                    </fo:block>
                </xsl:if>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>
    <fo:table-row keep-together="always">
        <xsl:for-each select="$firstNMeasurements">
<!-- Measurement name, value and comment -->
            <fo:table-cell border-top-style="solid" border-start-style="solid" border-bottom-style="solid" border-end-style="solid" border-top-width="thin" border-start-width="thin" border-bottom-width="thin" border-end-width="thin">
                <xsl:variable name="nums" select="current()/ContentSequence/Item[ValueType_NUM]"/>
    <!-- (VV-032, 99GEMS, Min) -->
                <xsl:variable name="min" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-033, 99GEMS, Max) -->
                <xsl:variable name="max" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-034, 99GEMS, Avg) -->
                <xsl:variable name="avg" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-036, 99GEMS, Std) -->
                <xsl:variable name="std" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                <xsl:choose>
    <!-- ROI -->
                    <xsl:when test="$min or $max or $avg or $std">
                        <xsl:call-template name="addROI">
                            <xsl:with-param name="pMeasurement" select="current()"/>
                        </xsl:call-template>
                    </xsl:when>
    <!-- Color Plaque -->
                    <xsl:when test="count($nums) = 0">
                        <fo:block text-align="center">
                            <fo:inline font-weight="bold">
                                <xsl:call-template name="addContainerName">
                                    <xsl:with-param name="pItem" select="current()"/>
                                </xsl:call-template>
                            </fo:inline>
                        </fo:block>
                    </xsl:when>
    <!-- Simple measurement -->
                    <xsl:when test="count($nums) = 1">
                        <fo:block font-weight="bold">
                            <xsl:value-of select="$nums/ConceptNameCodeSequence/Item/CodeMeaning"/>
                            <xsl:text>:</xsl:text>
                        </fo:block>
                        <fo:block text-align="center">
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="$nums"/>
                            </xsl:call-template>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>
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

    <fo:block font-weight="bold">
        <xsl:call-template name="addContainerName">
            <xsl:with-param name="pItem" select="$pMeasurement"/>
        </xsl:call-template>
        <xsl:value-of select="concat(' ', $messagecatalog/LBL_HOUNSFIELD_STATISTICS/msg[@lang = $lang], ' (HU):')"/>
    </fo:block>
    <fo:block text-align="center">
    <!-- (VV-032, 99GEMS, Min) -->
        <xsl:variable name="min" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-032' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-033, 99GEMS, Max) -->
        <xsl:variable name="max" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-033' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-034, 99GEMS, Avg) -->
        <xsl:variable name="avg" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-034' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <!-- (VV-036, 99GEMS, Std) -->
        <xsl:variable name="std" select="$pMeasurement/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-036' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>

        <xsl:if test="$min or $max or $avg or $std">
            <fo:table table-layout="fixed" width="100%">
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-header>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block text-align="center" font-weight="bold">
                                <xsl:choose>
                                    <xsl:when test="$avg">
                                        <xsl:value-of select="$avg/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </xsl:when>
                                    <xsl:otherwise>Avg</xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block text-align="center" font-weight="bold">
                                <xsl:choose>
                                    <xsl:when test="$std">
                                        <xsl:value-of select="$std/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </xsl:when>
                                    <xsl:otherwise>Std</xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block text-align="center" font-weight="bold">
                                <xsl:choose>
                                    <xsl:when test="$min">
                                        <xsl:value-of select="$min/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </xsl:when>
                                    <xsl:otherwise>Min</xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block text-align="center" font-weight="bold">
                                <xsl:choose>
                                    <xsl:when test="$max">
                                        <xsl:value-of select="$max/ConceptNameCodeSequence/Item/CodeMeaning"/>
                                    </xsl:when>
                                    <xsl:otherwise>Max</xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-header>
                <fo:table-body>
                    <fo:table-row>
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
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </xsl:if>
    </fo:block>
</xsl:template>

<xsl:template name="addROIValue"> <xsl:param name="pROI"/>
    <fo:table-cell>
        <fo:block text-align="center">
            <xsl:choose>
                <xsl:when test="$pROI">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$pROI"/>
                        <xsl:with-param name="pUnit" select="'none'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>-</xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </fo:table-cell>
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
        <fo:table table-layout="fixed" width="100%" space-after="4pt">
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-body>
                <fo:table-row keep-with-next="always">
                    <fo:table-cell>
                        <fo:block space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading3FontSize}pt">
                            <xsl:call-template name="addContainerName">
                                <xsl:with-param name="pItem" select="$pMeasurement"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="concat($statistics/ConceptNameCodeSequence/Item/CodeMeaning, ':')"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                    <fo:table-cell>
                        <fo:table table-layout="fixed" width="100%">
                            <fo:table-column column-width="proportional-column-width(1)"/>
                            <fo:table-column column-width="proportional-column-width(3)"/>
                            <fo:table-column column-width="proportional-column-width(6)"/>
                            <fo:table-column column-width="proportional-column-width(3)"/>
                            <fo:table-column column-width="proportional-column-width(5)"/>
                            <fo:table-column column-width="proportional-column-width(3)"/>
                            <fo:table-header>
                                <fo:table-row>
                                    <fo:table-cell/>
                                    <fo:table-cell>
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                            <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'VV-035' and ../CodingSchemeDesignator = $CSD_GEMS]"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell>
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                            <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'VV-030' and ../CodingSchemeDesignator = $CSD_GEMS]"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell>
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                            <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'VV-008' and ../CodingSchemeDesignator = $CSD_GEMS]"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell number-columns-spanned="2">
                                        <fo:block hyphenate="true" language="{$lang}" text-align="center" font-weight="bold">
                                            <xsl:value-of select="$statistics/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning[../CodeValue = 'G-D705' and ../CodingSchemeDesignator = $CSD_SNOMED]"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                            </fo:table-header>
                            <fo:table-body>
                                <xsl:for-each select="$statistics">
                                    <fo:table-row>
                    <!-- (, , Segment) -->
                                        <fo:table-cell>
                                            <fo:block text-align="center">
                                                <xsl:value-of select="position() - 1"/>
                                            </fo:block>
                                        </fo:table-cell>
                    <!-- (VV-035, 99GEMS, RGB Color) -->
                                        <xsl:variable name="rgb" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-035' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                        <fo:table-cell background-color="{$rgb/TextValue}"/>
                    <!-- (VV-030, 99GEMS, Hounsfield range) -->
                                        <fo:table-cell>
                                            <fo:block text-align="center">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-030' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </fo:table-cell>
                    <!-- (VV-008, 99GEMS, Name) -->
                                        <fo:table-cell>
                                            <xsl:variable name="name" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-008' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                            <xsl:variable name="nameHasContent">
                                                <xsl:call-template name="hasContent">
                                                    <xsl:with-param name="pItems" select="$name"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:if test="$nameHasContent = 'true'">
                                            <fo:block hyphenate="true" language="{$lang}" text-align="center">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="$name"/>
                                                </xsl:call-template>
                                            </fo:block>
                                            </xsl:if>
                                        </fo:table-cell>
                    <!-- (G-D705, SNM3, Volume) -->
                                        <fo:table-cell padding-right="1pt">
                                            <fo:block text-align="right">
                                                <xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                                                </xsl:call-template>
                                            </fo:block>
                                        </fo:table-cell>
                    <!-- (VV-031, 99GEMS, Percent of total volume) -->
                                        <fo:table-cell>
                                            <fo:block text-align="right">
                                                (<xsl:call-template name="addValue">
                                                    <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-031' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
                                                </xsl:call-template>)
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </xsl:for-each>
                    <!-- Sum up segment volumes. -->
                                <xsl:variable name="volumes" select="$statistics/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'G-D705' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
                                <fo:table-row>
                                    <fo:table-cell/>
                                    <fo:table-cell/>
                                    <fo:table-cell/>
                                    <fo:table-cell>
                                        <fo:block text-align="center" font-weight="bold">
                                            <xsl:value-of select="$messagecatalog/LBL_TOTAL/msg[@lang = $lang]"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell>
                                        <fo:block text-align="right" font-weight="bold">
                                            <xsl:call-template name="formatNumericValue">
                                                <xsl:with-param name="pNum" select="sum($volumes/MeasuredValueSequence/Item/NumericValue)"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="concat(' ', $volumes/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue)"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell/>
                                </fo:table-row>
                            </fo:table-body>
                        </fo:table>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addVVGeneralImages
    Description:    Adds General Images.
    Parameters:
        pItem    :  (VV-024, 99GEMS, General Images) content items
        pPosition:  Position of content item in the content sequence.
-->
<xsl:template name="addVVGeneralImages"> <xsl:param name="pItem"/>
                                         <xsl:param name="pPosition"/>

    <fo:table table-layout="fixed" width="100%" space-after="4pt">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <fo:table-row keep-with-next="always">
                <fo:table-cell>
<!-- (VV-008, 99GEMS, Name) -->
                    <fo:block id="{concat($pItem/ConceptNameCodeSequence/Item/CodeMeaning, $pPosition)}" space-before="4pt" space-after="4pt" font-weight="bold" font-size="{$heading1FontSize}pt" color="#9999CC">
                        <xsl:call-template name="addContainerName">
                            <xsl:with-param name="pItem" select="$pItem"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
<!-- (CAPTURE, DCM, Image Capture) items -->
            <xsl:call-template name="addImageCaptures2">
                <xsl:with-param name="pImages" select="$pItem/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
            </xsl:call-template>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addImageCaptures2
    Description:    Adds image captures based on manual / automatic template setting.
    Parameters:
        pImages   :  Image Capture node-set.
        pN        :  # of columns images displayed across.
-->
<xsl:template name="addImageCaptures2"> <xsl:param name="pImages"/>
                                        <xsl:param name="pN" select="$imgColumns"/>
                                        <xsl:param name="pWithName" select="'true'"/>
                                        <xsl:param name="pWithComment" select="'true'"/>

<!-- Automatic images -->
    <xsl:variable name="automatic" select="$pImages[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D231' and (ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED or ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT)]"/>
    <xsl:if test="$automatic and $tp/Images/@automatic = 'true'">
        <xsl:call-template name="addNImageCaptures">
            <xsl:with-param name="pImages" select="$automatic"/>
            <xsl:with-param name="pN" select="$pN"/>
            <xsl:with-param name="pWithName" select="$pWithName"/>
            <xsl:with-param name="pWithComment" select="$pWithComment"/>
        </xsl:call-template>
    </xsl:if>
<!-- Manual images -->
    <xsl:variable name="manual" select="$pImages[ContentSequence/Item/ConceptCodeSequence/Item/CodeValue = 'G-D221' and (ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED or ContentSequence/Item/ConceptCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT)]"/>
    <xsl:if test="$manual and $tp/Images/@manual = 'true'">
        <xsl:call-template name="addNImageCaptures">
            <xsl:with-param name="pImages" select="$manual"/>
            <xsl:with-param name="pN" select="$pN"/>
            <xsl:with-param name="pWithName" select="$pWithName"/>
            <xsl:with-param name="pWithComment" select="$pWithComment"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="addNImageCaptures"> <xsl:param name="pImages"/>
                                        <xsl:param name="pN" select="$imgColumns"/>
                                        <xsl:param name="pWithName" select="'true'"/>
                                        <xsl:param name="pWithComment" select="'true'"/>

    <xsl:if test="$pImages">
        <xsl:variable name="firstNImages" select="$pImages[position() &lt;= $pN]"/>
        <fo:table-row>
            <fo:table-cell>
                <fo:table table-layout="fixed" width="100%">
                    <xsl:call-template name="addProportionalTableColumn">
                        <xsl:with-param name="pN" select="$pN"/>
                    </xsl:call-template>
                    <fo:table-body>
                        <fo:table-row>
                            <xsl:if test="$tp/FixedOutput/Orientation = 'Portrait'">
                                <xsl:attribute name="keep-together">always</xsl:attribute>
                            </xsl:if>
                            <xsl:for-each select="$firstNImages">
                                <fo:table-cell>
                                    <xsl:call-template name="addImageCapture">
                                        <xsl:with-param name="pImage" select="current()"/>
                                        <xsl:with-param name="pWithName" select="$pWithName"/>
                                        <xsl:with-param name="pWithComment" select="$pWithComment"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </xsl:for-each>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:table-cell>
        </fo:table-row>
        <xsl:variable name="remainingImages" select="$pImages[position() &gt; $pN]"/>
        <xsl:if test="count($remainingImages) != 0">
            <xsl:call-template name="addNImageCaptures">
                <xsl:with-param name="pImages" select="$remainingImages"/>
                <xsl:with-param name="pN" select="$pN"/>
                <xsl:with-param name="pWithName" select="$pWithName"/>
                <xsl:with-param name="pWithComment" select="$pWithComment"/>
            </xsl:call-template>
        </xsl:if>
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
        <fo:block hyphenate="true" language="{$lang}" text-align="center" background-color="#{$P2}">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$name"/>
            </xsl:call-template>
            <xsl:if test="$type and $name/TextValue != $type/TextValue">
                <xsl:text> - </xsl:text>
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$type"/>
                </xsl:call-template>
            </xsl:if>
        </fo:block>
    </xsl:if>
<!-- Image -->
    <fo:block text-align="center">
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$pImage/ContentSequence/Item[ValueType_IMAGE]"/>
        </xsl:call-template>
    </fo:block>
<!-- (121106, DCM, Comment) -->
    <xsl:variable name="comment" select="$pImage/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121106' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:variable name="commentHasContent">
        <xsl:call-template name="hasContent">
            <xsl:with-param name="pItems" select="$comment"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$pWithComment = 'true' and $commentHasContent = 'true'">
        <fo:block hyphenate="true" language="{$lang}" text-align="center" space-after="4pt">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$comment"/>
            </xsl:call-template>
        </fo:block>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
