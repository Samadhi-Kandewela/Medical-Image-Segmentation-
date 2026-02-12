<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2004 GE Healthcare

    SECT_FO.XSL     : Rules for adding report sections to FO:
                      - Header (logo, name, address),
                      - Patient demographics (name, weight, etc.)
                      - Observation context
                      - Physician signatures

    Author          :   Attila RACZ
    Last modified on:   Dec 20, 2004
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:fox="http://xml.apache.org/fop/extensions">

<!-- ####################################################################################################
    Template:       addBookmarks
    Description:    Add bookmarks to PDF sections.
-->
<xsl:template name="addBookmarks">
    <xsl:for-each select="$tp/Sections/Section">
        <xsl:variable name="curSectionPos" select="position()"/>
        <xsl:choose>
<!-- SR content in the original order -->
            <xsl:when test="@name = 'LBL_SRSECTIONS'">
                <xsl:for-each select="$DICOM/ContentSequence/Item">
                    <xsl:if test="(not(current()/ValueType_TEXT) or current()/TextValue != '') and RelationshipType = 'CONTAINS'">
                        <xsl:variable name="destID" select="concat(translate(current()/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), $curSectionPos, position())"/>
                        <fox:outline internal-destination="{$destID}">
                            <fox:label><xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeMeaning"/></fox:label>
                        </fox:outline>
                        <fox:destination internal-destination="{$destID}"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
<!-- One specified SR ContentItem -->
            <xsl:when test="@code">
    <!-- Select content items with this code and scheme. -->
                <xsl:variable name="itemsWithCode" select="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = current()/@code and ConceptNameCodeSequence/Item/CodingSchemeDesignator = current()/@scheme]"/>
    <!-- Count content items with this code and scheme. -->
                <xsl:variable name="itemsWithCodeNo" select="count($itemsWithCode)"/>
    <!-- Select position in $itemsWithCode of current Section node among the sections with the same code and scheme.
         If there are more sections with the same code and scheme in the template than in the SR they are displayed repeatedly (using mod for position calculation). -->
                <xsl:variable name="curSameSectionPos" select="count(preceding-sibling::Section[@code = current()/@code and @scheme = current()/@scheme]) mod $itemsWithCodeNo + 1"/>
                <xsl:variable name="itemWithPos" select="$itemsWithCode[position() = $curSameSectionPos]"/>
                <xsl:if test="$itemWithPos and (not($itemWithPos/ValueType_TEXT) or $itemWithPos/TextValue != '') and $itemWithPos/RelationshipType = 'CONTAINS'">
                    <xsl:variable name="destID" select="concat(translate($itemWithPos/ConceptNameCodeSequence/Item/CodeMeaning, $INVALID_NAME_CHARS, ''), position())"/>
                    <fox:outline internal-destination="{$destID}">
                        <fox:label><xsl:value-of select="$itemWithPos/ConceptNameCodeSequence/Item/CodeMeaning"/></fox:label>
                    </fox:outline>
                    <fox:destination internal-destination="{$destID}"/>
                </xsl:if>
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
    Template:       addBookmark
    Description:    Add bookmark for the specified section and its subsections if exist.
-->
<xsl:template name="addBookmark"> <xsl:param name="pSection"/> <xsl:param name="pSectionPos"/>
    <xsl:variable name="destID" select="concat($pSection/@name, $pSectionPos)"/>
    <fox:outline internal-destination="{$destID}">
        <xsl:choose>
            <xsl:when test="$pSection/@type = 'GENERIC_MESSAGE'">
                <xsl:call-template name="addBookmarkLabel">
                    <xsl:with-param name="pName" select="concat($messagecatalog/LBL_MESSAGE/msg[@lang = $lang], ' - ', $pSection/@name)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pSection/@type = 'DIAGRAM'">
                <xsl:call-template name="addBookmarkLabel">
                    <xsl:with-param name="pName" select="concat($messagecatalog/LBL_DIAGRAM/msg[@lang = $lang], ' - ', $pSection/@name)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="addBookmarkLabel">
                    <xsl:with-param name="pName" select="$pSection/@name"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="$pSection/Section">
            <xsl:variable name="subdestID" select="concat(current()/@name, $pSectionPos)"/>
            <fox:outline internal-destination="{$subdestID}">
                <xsl:call-template name="addBookmarkLabel">
                    <xsl:with-param name="pName" select="current()/@name"/>
                </xsl:call-template>
            </fox:outline>
            <fox:destination internal-destination="{$subdestID}"/>
        </xsl:for-each>
    </fox:outline>
    <fox:destination internal-destination="{$destID}"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       addBookmarkLabel
    Description:    Read localized section names for bookmark labels.
-->
<xsl:template name="addBookmarkLabel"> <xsl:param name="pName"/>
    <xsl:variable name="labelMsg" select="$messagecatalog/*[local-name() = $pName]"/>
    <fox:label>
        <xsl:choose>
            <xsl:when test="$labelMsg">
                <xsl:value-of select="$labelMsg/msg[@lang = $lang]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pName"/>
            </xsl:otherwise>
        </xsl:choose>
    </fox:label>
</xsl:template>

<!-- ####################################################################################################
    Template:       processSections
    Description:    Process report and template sections.
-->
<xsl:template name="processSections">

    <fo:flow flow-name="xsl-region-body">
        <xsl:if test="$clinicalUse = 'false'">
            <fo:block text-align="center" font-weight="bold" font-size="{$titleFontSize}pt" color="#FF0000" space-before="12pt" space-after="12pt">
                <xsl:value-of select="$messagecatalog/MSG_NOT_FOR_CLINICAL_USE/msg[@lang = $lang]"/>
            </fo:block>
        </xsl:if>
        <xsl:call-template name="addMissingIdentificationWarning">
            <xsl:with-param name="pSection" select="$tp/Sections/Section[@type = 'PATIENT_DEMOGRAPHICS']"/>
            <xsl:with-param name="pIdentification" select="$tp/Demographics/Identification"/>
        </xsl:call-template>

        <xsl:for-each select="$tp/Sections/Section">
            <xsl:variable name="curSection" select="current()"/>
            <xsl:variable name="curSectionPos" select="position()"/>
            <xsl:choose>
<!-- Header -->
                <xsl:when test="@type = 'HEADER'">
                    <xsl:call-template name="addHeaderSections">
                        <xsl:with-param name="pSection" select="current()"/>
                        <xsl:with-param name="pPosition" select="position()"/>
                    </xsl:call-template>
                </xsl:when>
<!-- Patient Demographics -->
                <xsl:when test="@type = 'PATIENT_DEMOGRAPHICS'">
                    <xsl:call-template name="addPDSections">
                        <xsl:with-param name="pPDSection" select="current()"/>
                        <xsl:with-param name="pPosition" select="position()"/>
                    </xsl:call-template>
                </xsl:when>
<!-- Patient Demographics -->
                <xsl:when test="@type = 'PAGE_BREAK'">
                    <fo:block break-before="page"/>
                </xsl:when>
<!-- Generic Messages -->
                <xsl:when test="@type = 'GENERIC_MESSAGE'">
    <!-- Add Generic Message where the Title is @name -->
                    <xsl:call-template name="addGenericMessage">
                        <xsl:with-param name="pGenericMessage" select="$tp/GenericMessages/GenericMessage[@id = current()/@id]"/>
                    </xsl:call-template>
                </xsl:when>
<!-- SR content in the original order -->
                <xsl:when test="@name = 'LBL_SRSECTIONS'">
                    <xsl:call-template name="processReportSections">
                        <xsl:with-param name="pCurSectionPos" select="$curSectionPos"/>
                    </xsl:call-template>
                </xsl:when>
<!-- Images only organized into N columns. -->
                <xsl:when test="@name = 'LBL_IMAGES_ONLY'">
                    <fo:block id="{concat(translate(@name, ' ', ''), position())}"/>
                <!-- (CAPTURE, 99GEMS, Image Capture) -->
                    <xsl:variable name="imageCaptures" select="$DICOM/ContentSequence//Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                    <xsl:choose>
                        <xsl:when test="$imageCaptures">
                            <xsl:call-template name="addImages">
                                <xsl:with-param name="pImages" select="$imageCaptures"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="addImages">
                                <xsl:with-param name="pImages" select="$DICOM/ContentSequence//Item[ValueType_IMAGE or ValueType = 'IMAGE']"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
<!-- Diagram -->
                <xsl:when test="@type = 'DIAGRAM'">
    <!-- Add Diagram where the Title is @name -->
                    <xsl:call-template name="addDiagram">
                        <xsl:with-param name="pDiagram" select="$tp/Diagrams/Diagram[@id = current()/@id]"/>
                    </xsl:call-template>
                </xsl:when>
<!-- Physician signature -->
                <xsl:when test="@type = 'PHYSICIAN_SIGNATURES'">
                    <xsl:call-template name="addPhysicianSignature"/>
                </xsl:when>
<!-- One specified SR ContentItem -->
                <xsl:when test="@code">
    <!-- Select content items with this code and scheme. -->
                    <xsl:variable name="itemsWithCode" select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS' and ConceptNameCodeSequence/Item/CodeValue = current()/@code and ConceptNameCodeSequence/Item/CodingSchemeDesignator = current()/@scheme]"/>
    <!-- Count content items with this code and scheme. -->
                    <xsl:variable name="itemsWithCodeNo" select="count($itemsWithCode)"/>
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
                            <xsl:if test="$itemWithPos and (not($itemWithPos/ValueType_TEXT) or $itemWithPos/TextValue != '')">
                                <xsl:call-template name="addContentItem">
                                    <xsl:with-param name="pItem" select="$itemWithPos"/>
                                    <xsl:with-param name="pPosition" select="$curSectionPos"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
        <!-- Select position in $itemsWithCode of current Section node among the sections with the same code and scheme.
             If there are more sections with the same code and scheme in the template than in the SR they are displayed repeatedly (using mod for position calculation). -->
                            <xsl:variable name="curSameSectionPos" select="count(preceding-sibling::Section[@code = current()/@code and @scheme = current()/@scheme]) mod $itemsWithCodeNo + 1"/>
                            <xsl:variable name="itemWithPos" select="$itemsWithCode[position() = $curSameSectionPos]"/>
                            <xsl:if test="$itemWithPos and (not($itemWithPos/ValueType_TEXT) or $itemWithPos/TextValue != '')">
                                <xsl:call-template name="addContentItem">
                                    <xsl:with-param name="pItem" select="$itemWithPos"/>
                                    <xsl:with-param name="pPosition" select="$curSectionPos"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    <!-- Dummy fo:block to avoid "org.apache.fop.apps.FOPException: fo:flow must contain block-level children" error. -->
        <fo:block/>
    </fo:flow>
</xsl:template>

<!-- ####################################################################################################
    Template:       processReportSections
    Description:    Process report sections.
    Parameters:
        pCurSectionPos :
-->
<xsl:template name="processReportSections"> <xsl:param name="pCurSectionPos"/>
    <xsl:for-each select="$DICOM/ContentSequence/Item">
<!-- Ignore section if it is an empty TEXT item. -->
        <xsl:if test="not(current()/ValueType_TEXT) or current()/TextValue != ''">
            <xsl:call-template name="addContentItem">
                <xsl:with-param name="pItem" select="current()"/>
                <xsl:with-param name="pPosition" select="concat($pCurSectionPos, position())"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addMissingIdentificationWarning
    Description:    Add warning that patient identification is missing from the report.
    Parameters:
        pSection        : Current Section node with @type = 'PATIENT_DEMOGRAPHICS'
        pIdentification : Patient Identification fields
-->
<xsl:template name="addMissingIdentificationWarning"> <xsl:param name="pSection"/>
                                                      <xsl:param name="pIdentification"/>
    <xsl:variable name="isMissing">
        <xsl:choose>
            <xsl:when test="$pSection and $pSection/Section[@type = 'IDENTIFICATION']">
                <xsl:choose>
                    <xsl:when test="$pIdentification/Item[@add = 'true' and @name='LBL_PATIENTID'] and $pIdentification/Item[@add = 'true' and @name='LBL_NAME'] and $pIdentification/Item[@add = 'true' and @name='LBL_BIRTHDATE'] and $pIdentification/Item[@add = 'true' and @name='LBL_SEX']">false</xsl:when>
                    <xsl:otherwise>true</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>true</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="$isMissing = 'true'">
        <fo:block text-align="center" font-weight="bold" font-size="{$titleFontSize}pt" color="#FF0000" space-before="12pt" space-after="12pt">
            <xsl:value-of select="$messagecatalog/MSG_PATIENT_IDENTIFICATION_MISSING/msg[@lang = $lang]"/>
        </fo:block>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addHeaderSections
    Description:    Add header sections to the report in the order specified by template.
    Parameters:
        pSection    : Current Section node with @type = 'HEADER'
        pPosition   : Position of pSection
-->
<xsl:template name="addHeaderSections">
    <xsl:param name="pSection"/>
    <xsl:param name="pPosition"/>

    <fo:block id="{concat($pSection/@name, $pPosition)}"/>
    <xsl:for-each select="$pSection/Section">
        <xsl:choose>
<!-- Hospital Logo / Name / Address -->
            <xsl:when test="@type = 'LOGO_NAME_ADDRESS'">
                <xsl:call-template name="addLogoNameAddress">
                    <xsl:with-param name="pSection" select="$pSection"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
<!-- Physician List -->
            <xsl:when test="@type = 'PHYSICIAN_LIST'">
                <xsl:call-template name="addPhysicians">
                    <xsl:with-param name="pSection" select="$pSection"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
<!-- Report Title -->
            <xsl:when test="@type = 'REPORT_TITLE'">
                <xsl:call-template name="addReportTitle">
                    <xsl:with-param name="pSection" select="$pSection"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!--
    Templates to add hospital information to FO based report.
-->
<xsl:template name="addHospitalLogo2FO">
    <xsl:variable name="logo" select="$tp/Header/Hospital/Logo"/>
    <xsl:if test="$logo != ''">
        <fo:block text-align="{$logo/@align}">
            <fo:external-graphic src="{concat('../IMAGE/', $logo)}">
                <xsl:if test="$logo/@width and $logo/@width != '' and $logo/@height and $logo/@height != ''">
                    <xsl:variable name="heightInPageUnit">
                        <xsl:call-template name="caluclateSizeInPageUnit">
                            <xsl:with-param name="pSize" select="$logo/@height"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="widthInPageUnit">
                        <xsl:call-template name="caluclateSizeInPageUnit">
                            <xsl:with-param name="pSize" select="$logo/@width"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$heightInPageUnit &gt; $innerPageHeight * $LARGE_IMAGE_RATE">
                            <xsl:attribute name="height">
                                <xsl:value-of select="concat($innerPageHeight * $LARGE_IMAGE_RATE * $logo/@scale, $pageUnit)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$logo/@scale != 1.0">
                            <xsl:attribute name="height">
                                <xsl:value-of select="concat($heightInPageUnit * $logo/@scale, $pageUnit)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </fo:external-graphic>
        </fo:block>
    </xsl:if>
</xsl:template>

<xsl:template name="addHospitalAddress2FO"> <xsl:param name="pAlign"/> <xsl:param name="pName"/> <xsl:param name="pAddress"/>
    <xsl:variable name="nameMsg" select="$messagecatalog/*[local-name() = $pName]"/>
    <xsl:variable name="addressMsg" select="$messagecatalog/*[local-name() = $pAddress]"/>
    <fo:block text-align="{$pAlign}" font-weight="bold">
        <xsl:choose>
            <xsl:when test="$nameMsg">
                <xsl:value-of select="$nameMsg/msg[@lang = $lang]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pName"/>
            </xsl:otherwise>
        </xsl:choose>
    </fo:block>
    <xsl:choose>
        <xsl:when test="$addressMsg">
            <fo:block text-align="{$pAlign}">
                <xsl:value-of select="$addressMsg/msg[@lang = $lang]"/>
            </fo:block>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="break2NewLine">
                <xsl:with-param name="pAlign" select="$pAlign"/>
                <xsl:with-param name="pText" select="$pAddress"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPhysicians
    Description:    Add physicians.
-->
<!-- Workaround for the alignment of a whole table inside a block -->
<xsl:template name="addPhysicians"> <xsl:param name="pSection"/>
                                    <xsl:param name="pPosition"/>

    <fo:block id="{concat($pSection/Section[@type = 'PHYSICIAN_LIST']/@name, $pPosition)}">
        <xsl:variable name="physicianAlignment" select="$tp/Physicians/@align"/>
        <xsl:for-each select="$tp/Physicians/Physician">
            <xsl:if test="current()/AddToReport">
                <fo:block hyphenate="true" language="{$lang}" text-align="{$physicianAlignment}">
                    <xsl:value-of select="concat(current()/FirstName, ' ', current()/LastName)"/>
                </fo:block>
            </xsl:if>
        </xsl:for-each>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addReportTitle
    Description:    Add title of the report.
-->
<xsl:template name="addReportTitle"> <xsl:param name="pSection"/>
                                     <xsl:param name="pPosition"/>

    <fo:block id="{concat($pSection/Section[@type = 'REPORT_TITLE']/@name, $pPosition)}" text-align="center" font-weight="bold" font-size="{$titleFontSize}pt" space-before="12pt" space-after="12pt">
        <xsl:value-of select="$DICOM/ConceptNameCodeSequence/Item/CodeMeaning"/>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addLogoNameAddress
    Description:    Add hospital logo name and address to the report.
-->
<xsl:template name="addLogoNameAddress"> <xsl:param name="pSection"/>
                                         <xsl:param name="pPosition"/>

    <xsl:variable name="hospitalLogoAlignment" select="$tp/Header/Hospital/Logo/@align"/>
    <xsl:variable name="hospitalAddressAlignment" select="$tp/Header/Hospital/Name/@align"/>
    <fo:block id="{concat($pSection/Section[@type = 'LOGO_NAME_ADDRESS']/@name, $pPosition)}">
        <xsl:choose>
    <!-- Logo and hospital info aligned to the same position : display them in separate lines. -->
            <xsl:when test="$hospitalLogoAlignment = $hospitalAddressAlignment">
        <!-- Hospital logo -->
                <xsl:if test="$hospitalLogoAlignment != 'hide'">
                    <xsl:call-template name="addHospitalLogo2FO"/>
                </xsl:if>
        <!-- Hospital name and address -->
                <xsl:if test="$hospitalAddressAlignment != 'hide'">
                    <xsl:call-template name="addHospitalAddress2FO">
                        <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                        <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                        <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
<!-- Logo and hospital info are aligned to different position : display them on the same horizontal line. -->
            <xsl:otherwise>
    <!-- Table with 3 equal width columns -->
                <fo:table table-layout="fixed" width="100%">
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-column column-width="proportional-column-width(1)"/>
                <fo:table-body>
                    <fo:table-row padding-before="10pt" padding-after="10pt" padding-top="10pt" padding-bottom="10pt">
                        <xsl:choose>
                            <xsl:when test="$hospitalLogoAlignment = 'hide'">
                                <fo:table-cell number-columns-spanned="3">
                                    <xsl:call-template name="addHospitalAddress2FO">
                                        <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                        <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                        <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </xsl:when>
                            <xsl:when test="$hospitalAddressAlignment = 'hide'">
                                <fo:table-cell number-columns-spanned="3">
                                    <xsl:call-template name="addHospitalLogo2FO"/>
                                </fo:table-cell>
                            </xsl:when>
                            <xsl:when test="$hospitalLogoAlignment = 'left'">
                                <fo:table-cell>
                                    <xsl:call-template name="addHospitalLogo2FO"/>
                                </fo:table-cell>
                                <fo:table-cell number-columns-spanned="2">
                                    <xsl:call-template name="addHospitalAddress2FO">
                                        <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                        <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                        <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                            </xsl:when>
                            <xsl:when test="$hospitalLogoAlignment = 'center'">
                                <fo:table-cell>
                                    <xsl:if test="$hospitalAddressAlignment = 'left'">
                                        <xsl:call-template name="addHospitalAddress2FO">
                                            <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                            <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                            <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:call-template name="addHospitalLogo2FO"/>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:if test="$hospitalAddressAlignment = 'right'">
                                        <xsl:call-template name="addHospitalAddress2FO">
                                            <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                            <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                            <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </fo:table-cell>
                            </xsl:when>
                            <xsl:when test="$hospitalLogoAlignment = 'right'">
                                <fo:table-cell>
                                    <xsl:if test="$hospitalAddressAlignment = 'left'">
                                        <xsl:attribute name="number-columns-spanned">2</xsl:attribute>
                                        <xsl:call-template name="addHospitalAddress2FO">
                                            <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                            <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                            <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </fo:table-cell>
                                <xsl:if test="$hospitalAddressAlignment = 'center'">
                                <fo:table-cell>
                                    <xsl:call-template name="addHospitalAddress2FO">
                                        <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                        <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                        <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                    </xsl:call-template>
                                </fo:table-cell>
                                </xsl:if>
                                <fo:table-cell>
                                    <xsl:call-template name="addHospitalLogo2FO"/>
                                </fo:table-cell>
                            </xsl:when>
                        </xsl:choose>
                    </fo:table-row>
                </fo:table-body>
                </fo:table>
            </xsl:otherwise>
        </xsl:choose>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addFooter
    Description:    Add footer to the report.
-->
<xsl:template name="addFooter">
    <fo:static-content flow-name="xsl-region-after">
        <fo:block text-align="left" font-family="{$tp/Font/@type}" font-size="{$footerFontSize}pt">
<!-- Table with 3 equal width columns between two margin sized empty columns -->
            <fo:table table-layout="fixed" width="100%">
            <fo:table-column column-width="proportional-column-width({$leftMargin})"/>
            <fo:table-column column-width="proportional-column-width({$oneThirdColWidth})"/>
            <fo:table-column column-width="proportional-column-width({$oneThirdColWidth})"/>
            <fo:table-column column-width="proportional-column-width({$oneThirdColWidth})"/>
            <fo:table-column column-width="proportional-column-width({$rightMargin})"/>
            <fo:table-body>
                <fo:table-row padding-before="10pt" padding-after="10pt" padding-top="10pt" padding-bottom="10pt">
                    <fo:table-cell/>
<!-- Patient Name and ID -->
                    <fo:table-cell>
                        <fo:block text-align="left" hyphenate="true" language="{$lang}">
                            <xsl:if test="$tp/FixedOutput/Footer/PatientName">
                                <xsl:call-template name="formatPersonName">
                                    <xsl:with-param name="PName" select="$DICOM/PatientName"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="$tp/FixedOutput/Footer/PatientID and $DICOM/PatientID and $DICOM/PatientID != ''">
                                (<xsl:value-of select="$DICOM/PatientID"/>)
                            </xsl:if>
                        </fo:block>
                    </fo:table-cell>
<!-- Page Number -->
                    <fo:table-cell>
                        <fo:block text-align="center">
                            <xsl:if test="$tp/FixedOutput/Footer/PageNumber">
                                - <fo:page-number/> -
                            </xsl:if>
                        </fo:block>
                    </fo:table-cell>
<!-- DateTime -->
                    <fo:table-cell>
                        <fo:block text-align="right">
                            <xsl:if test="$tp/FixedOutput/Footer/CurrentDateTime">
                                <xsl:call-template name="addDateAndTime">
                                    <xsl:with-param name="pDate" select="substring-before($DICOM/@dateTime, ' ')"/>
                                    <xsl:with-param name="pTime" select="substring-after($DICOM/@dateTime, ' ')"/>
                                </xsl:call-template>
                            </xsl:if>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell/>
                </fo:table-row>
            </fo:table-body>
            </fo:table>
        </fo:block>
    </fo:static-content>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDSections
    Description:    Add patient information to the report in the order specified by template.
    Parameters:
        pPDSection  : Current Section node with @type = 'PATIENT_DEMOGRAPHICS'
        pPosition   : Position of pPDSection
-->
<xsl:template name="addPDSections"> <xsl:param name="pPDSection"/>
                                    <xsl:param name="pPosition"/>

    <fo:block id="{concat($pPDSection/@name, $pPosition)}"/>
    <xsl:for-each select="$pPDSection/Section">
        <xsl:choose>
<!-- Identification -->
            <xsl:when test="@type = 'IDENTIFICATION' and count($tp/Demographics/Identification/Item[@add = 'true']) &gt; 0">
                <xsl:call-template name="addPDIdentification">
                    <xsl:with-param name="pPDSection" select="$pPDSection"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
<!-- Medical History -->
            <xsl:when test="@type = 'MEDICAL_HISTORY' and count($tp/Demographics/MedicalHistory/Item[@add = 'true']) &gt; 0">
                <xsl:call-template name="addPDMedicalHistory">
                    <xsl:with-param name="pPDSection" select="$pPDSection"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
<!-- Physician Info -->
            <xsl:when test="@type = 'PHYSICIAN_INFO' and count($tp/Demographics/PhysicianInfo/Item[@add = 'true']) &gt; 0">
                <xsl:call-template name="addPDPhysicianInfo">
                    <xsl:with-param name="pPDSection" select="$pPDSection"/>
                    <xsl:with-param name="pPosition" select="$pPosition"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:for-each>
    <xsl:call-template name="addCompletionVerification"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDemographics
    Description:    Add patient demographics.
        pPDItems  :  Patient demographics.
        pN        :  # of columns patient demographics are displayed across.
-->
<xsl:template name="addPDemographics"> <xsl:param name="pPDSection"/>
                                       <xsl:param name="pPosition"/>
                                       <xsl:param name="pPDItems"/>
                                       <xsl:param name="pPDType"/>
                                       <xsl:param name="pN" select="$demographicsColumns"/>

    <xsl:if test="$pPDItems">
        <fo:block id="{concat($pPDSection/Section[@type = $pPDType]/@name, $pPosition)}">
            <fo:table table-layout="fixed" width="100%">
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-column column-width="proportional-column-width(2)"/>
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-column column-width="proportional-column-width(2)"/>
            <fo:table-body>
                <xsl:call-template name="addNPDemographics">
                    <xsl:with-param name="pPDItems" select="$pPDItems"/>
                    <xsl:with-param name="pN" select="$pN"/>
                </xsl:call-template>
            </fo:table-body>
            </fo:table>
            <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
        </fo:block>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNPDemographics
    Description:    Recursively adds patient demographics organized into N columns.
    Parameters:
        pPDItems  :  Patient demographics.
        pN        :  # of columns patient demographics are displayed across.
-->
<xsl:template name="addNPDemographics"> <xsl:param name="pPDItems"/>
                                        <xsl:param name="pN" select="$demographicsColumns"/>

    <xsl:variable name="firstNPDFields" select="$pPDItems[position() &lt;= $pN]"/>
    <fo:table-row keep-together="always">
        <xsl:for-each select="$firstNPDFields">
            <fo:table-cell>
                <xsl:variable name="fieldMsg" select="$messagecatalog/*[local-name() = current()/@name]"/>
                <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                    <xsl:value-of select="$fieldMsg/msg[@lang = $lang]"/>:
                </fo:block>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                    <xsl:call-template name="addPDValue">
                        <xsl:with-param name="pPDItem" select="current()"/>
                    </xsl:call-template>
                </fo:block>
            </fo:table-cell>
        </xsl:for-each>
    </fo:table-row>
    <xsl:variable name="remainingPDFields" select="$pPDItems[position() &gt; $pN]"/>
    <xsl:if test="count($remainingPDFields) != 0">
        <xsl:call-template name="addNPDemographics">
            <xsl:with-param name="pPDItems" select="$remainingPDFields"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDIdentification
    Description:    Add patient demographics: Identification.
    Parameters:
        pPDSection  : Current Section node with @type = 'PATIENT_DEMOGRAPHICS'
        pPosition   : Position of pPDSection
-->
<xsl:template name="addPDIdentification"> <xsl:param name="pPDSection"/>
                                          <xsl:param name="pPosition"/>

    <xsl:call-template name="addPDemographics">
        <xsl:with-param name="pPDSection" select="$pPDSection"/>
        <xsl:with-param name="pPosition" select="$pPosition"/>
        <xsl:with-param name="pPDItems" select="$tp/Demographics/Identification/Item[@add = 'true' and @name != 'LBL_COMPLETION_FLAG' and @name != 'LBL_VERIFICATION_FLAG']"/>
        <xsl:with-param name="pPDType" select="'IDENTIFICATION'"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDIdentification
    Description:    Add patient demographics: Identification.
    Parameters:
        pPDSection  : Current Section node with @type = 'PATIENT_DEMOGRAPHICS'
        pPosition   : Position of pPDSection
-->
<xsl:template name="addPDIdentification2">
    <xsl:param name="pPDSection"/>
    <xsl:param name="pPosition"/>

    <xsl:variable name="tpPDIdentification" select="$tp/Demographics/Identification"/>
    <xsl:variable name="tpPatientID" select="$tpPDIdentification/Item[@name = 'LBL_PATIENTID']"/>
    <xsl:variable name="tpEthnicGrp" select="$tpPDIdentification/Item[@name = 'LBL_ETHNIC_GROUP']"/>
    <xsl:variable name="tpPatientName" select="$tpPDIdentification/Item[@name = 'LBL_NAME']"/>
    <xsl:variable name="tpStudyDate" select="$tpPDIdentification/Item[@name = 'LBL_STUDYDATE']"/>
    <xsl:variable name="tpBirthdate" select="$tpPDIdentification/Item[@name = 'LBL_BIRTHDATE']"/>
    <xsl:variable name="tpStudyID" select="$tpPDIdentification/Item[@name = 'LBL_STUDYID']"/>
    <xsl:variable name="tpAge" select="$tpPDIdentification/Item[@name = 'LBL_AGE']"/>
    <xsl:variable name="tpAccessionNum" select="$tpPDIdentification/Item[@name = 'LBL_ACCESSION_NUMBER']"/>
    <xsl:variable name="tpSex" select="$tpPDIdentification/Item[@name = 'LBL_SEX']"/>
    <xsl:variable name="tpContentDate" select="$tpPDIdentification/Item[@name = 'LBL_CONTENT_DATE']"/>
    <xsl:variable name="tpRequestedProcDesc" select="$tpPDIdentification/Item[@name = 'LBL_REQUESTED_PROC_DESC']"/>

    <fo:block id="{concat($pPDSection/Section[@type = 'IDENTIFICATION']/@name, $pPosition)}">
<!-- Table with 1/3 and 2/3 width columns -->
        <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
            <fo:table-body>
                <xsl:if test="$tpPatientID/@add = 'true' or $tpEthnicGrp/@add = 'true'">
                <fo:table-row keep-together="always">
<!-- Patient ID -->
                    <fo:table-cell>
                        <xsl:if test="$tpPatientID/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_PATIENTID/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpPatientID/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/PatientID"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Ethnic Group -->
                    <fo:table-cell>
                        <xsl:if test="$tpEthnicGrp/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_ETHNIC_GROUP/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpEthnicGrp/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/EthnicGroup"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="$tpPatientName/@add = 'true' or $tpStudyDate/@add = 'true'">
                <fo:table-row keep-together="always">
<!-- Name -->
                    <fo:table-cell>
                        <xsl:if test="$tpPatientName/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_NAME/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpPatientName/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="formatPersonName">
                                    <xsl:with-param name="PName" select="$DICOM/PatientName"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Examdate -->
                    <fo:table-cell>
                        <xsl:if test="$tpStudyDate/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_STUDYDATE/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpStudyDate/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addDateAndTime">
                                    <xsl:with-param name="pDate" select="$DICOM/StudyDate"/>
                                    <xsl:with-param name="pTime" select="$DICOM/StudyTime"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="$tpBirthdate/@add = 'true' or $tpStudyID/@add = 'true'">
                <fo:table-row keep-together="always">
<!-- Birthdate -->
                    <fo:table-cell>
                        <xsl:if test="$tpBirthdate/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_BIRTHDATE/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpBirthdate/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/PatientBirthDate"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Exam No. -->
                    <fo:table-cell>
                        <xsl:if test="$tpStudyID/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_STUDYID/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpStudyID/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/StudyID"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="$tpAge/@add = 'true' or $tpAccessionNum/@add = 'true'">
                <fo:table-row keep-together="always">
<!-- Age -->
                    <fo:table-cell>
                        <xsl:if test="$tpAge/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_AGE/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpAge/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addAgeText">
                                    <xsl:with-param name="pAge" select="$DICOM/PatientAge"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Accession Number -->
                    <fo:table-cell>
                        <xsl:if test="$tpAccessionNum/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_ACCESSION_NUMBER/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpAccessionNum/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/AccessionNumber"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="$tpSex/@add = 'true' or $tpContentDate/@add = 'true'">
                <fo:table-row keep-together="always">
<!-- Sex -->
                    <fo:table-cell>
                        <xsl:if test="$tpSex/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_SEX/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpSex/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addSexText">
                                    <xsl:with-param name="PSex" select="$DICOM/PatientSex"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Content Date and Time -->
                    <fo:table-cell>
                        <xsl:if test="$tpContentDate/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_CONTENT_DATE/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpContentDate/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addDateAndTime">
                                    <xsl:with-param name="pDate" select="$DICOM/ContentDate"/>
                                    <xsl:with-param name="pTime" select="$DICOM/ContentTime"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
<!-- Requester Procedure Description -->
                <xsl:if test="$tpRequestedProcDesc/@add = 'true'">
                    <fo:table-row keep-together="always">
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_REQUESTED_PROC_DESC/msg[@lang = $lang]"/>:
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/ReferencedRequestSequence/Item/RequestedProcedureDescription"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>   
                </xsl:if>
            </fo:table-body>
        </fo:table>
        <xsl:if test="$tpPatientID/@add = 'true' or $tpEthnicGrp/@add = 'true' or $tpPatientName/@add = 'true' or $tpStudyDate/@add = 'true' or $tpBirthdate/@add = 'true' or $tpStudyID/@add = 'true' or $tpAge/@add = 'true' or $tpAccessionNum/@add = 'true' or $tpSex/@add = 'true' or $tpContentDate/@add = 'true'">
            <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
        </xsl:if>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDMedicalHistory
    Description:    Add patient demographics: Medical History.
    Parameters:
        pPDSection  : Current Section node with @type = 'PATIENT_DEMOGRAPHICS'
        pPosition   : Position of pPDSection
-->
<xsl:template name="addPDMedicalHistory2"> <xsl:param name="pPDSection"/>
                                          <xsl:param name="pPosition"/>

    <xsl:call-template name="addPDemographics">
        <xsl:with-param name="pPDSection" select="$pPDSection"/>
        <xsl:with-param name="pPosition" select="$pPosition"/>
        <xsl:with-param name="pPDItems" select="$tp/Demographics/MedicalHistory/Item[@add = 'true']"/>
        <xsl:with-param name="pPDType" select="'MEDICAL_HISTORY'"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDMedicalHistory
    Description:    Add patient demographics: Medical History.
    Parameters:
        pPDSection  : Current Section node with @type = 'PATIENT_DEMOGRAPHICS'
        pPosition   : Position of pPDSection
-->
<xsl:template name="addPDMedicalHistory"> <xsl:param name="pPDSection"/>
                                           <xsl:param name="pPosition"/>

    <xsl:variable name="tpPDMedicalHistory" select="$tp/Demographics/MedicalHistory"/>
    <xsl:variable name="tpWeight" select="$tpPDMedicalHistory/Item[@name = 'LBL_WEIGHT']"/>
    <xsl:variable name="tpBSA" select="$tpPDMedicalHistory/Item[@name = 'LBL_BODY_SURFACE_AREA']"/>
    <xsl:variable name="tpHeight" select="$tpPDMedicalHistory/Item[@name = 'LBL_HEIGHT']"/>
    <xsl:variable name="tpBMI" select="$tpPDMedicalHistory/Item[@name = 'LBL_BODY_MASS_INDEX']"/>
    <xsl:variable name="tpSmoking" select="$tpPDMedicalHistory/Item[@name = 'LBL_SMOKING']"/>
    <xsl:variable name="tpOverweight" select="$tpPDMedicalHistory/Item[@name = 'LBL_OVERWEIGHT']"/>
    <xsl:variable name="tpDiabetes" select="$tpPDMedicalHistory/Item[@name = 'LBL_DIABETES']"/>
    <xsl:variable name="tpCholesterol" select="$tpPDMedicalHistory/Item[@name = 'LBL_CHOLESTEROL']"/>
    <xsl:variable name="smoking" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'S-32000' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="overweight" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'F-02A18' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="diabetes" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'VV-050' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
    <xsl:variable name="cholesterol" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'F-63980' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>

    <fo:block id="{concat($pPDSection/Section[@type = 'MEDICAL_HISTORY']/@name, $pPosition)}">
<!-- Table with 1/3 and 2/3 width columns -->
        <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
            <fo:table-body>
                <xsl:if test="$tpWeight/@add = 'true' or $tpBSA/@add = 'true'">
                <fo:table-row keep-together="always">
<!-- Weight -->
                    <fo:table-cell>
                        <xsl:if test="$tpWeight/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_WEIGHT/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpWeight/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addWeight">
                                    <xsl:with-param name="pWeight" select="$DICOM/PatientWeight"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Body Surface Area -->
                    <fo:table-cell>
                        <xsl:if test="$tpBSA/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_BODY_SURFACE_AREA/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpBSA/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addBSA"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="$tpHeight/@add = 'true' or $tpBMI/@add = 'true'">
                <fo:table-row keep-together="always">
<!-- Height -->
                    <fo:table-cell>
                        <xsl:if test="$tpHeight/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_HEIGHT/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpHeight/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addHeight">
                                    <xsl:with-param name="pHeight" select="$DICOM/PatientSize"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Body Mass Index -->
                    <fo:table-cell>
                        <xsl:if test="$tpBMI/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_BODY_MASS_INDEX/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpBMI/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addBMI"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="($smoking and $tpSmoking/@add = 'true') or ($overweight and $tpOverweight/@add = 'true')">
                <fo:table-row keep-together="always">
<!-- (S-32000, SNM3, Smoker) -->
                    <fo:table-cell>
                        <xsl:if test="$tpSmoking/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_SMOKING/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpSmoking/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$smoking"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- (F-02A18, SNM3, Overweight) -->
                    <fo:table-cell>
                        <xsl:if test="$tpOverweight/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_OVERWEIGHT/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpOverweight/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$overweight"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="($diabetes and $tpDiabetes/@add = 'true') or ($cholesterol and $tpCholesterol/@add = 'true')">
                <fo:table-row keep-together="always">
<!-- (VV-050, 99GEMS, Diabetes) -->
                    <fo:table-cell>
                        <xsl:if test="$tpDiabetes/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_DIABETES/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpDiabetes/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$diabetes"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- (F-63980, SNM3, Cholesterol) -->
                    <fo:table-cell>
                        <xsl:if test="$tpCholesterol/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_CHOLESTEROL/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpCholesterol/@add = 'true'">
                            <fo:block space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$cholesterol"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
            </fo:table-body>
        </fo:table>
        <xsl:if test="$tpWeight/@add = 'true' or $tpBSA/@add = 'true' or $tpHeight/@add = 'true' or $tpBMI/@add = 'true' or ($smoking and $tpSmoking/@add = 'true') or ($overweight and $tpOverweight/@add = 'true') or ($diabetes and $tpDiabetes/@add = 'true') or ($cholesterol and $tpCholesterol/@add = 'true')">
            <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
        </xsl:if>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDPhysicianInfo
    Description:    Add patient demographics: Physician Info.
    Parameters:
        pPDSection  : Current Section node with @type = 'PATIENT_DEMOGRAPHICS'
        pPosition   : Position of pPDSection
-->
<xsl:template name="addPDPhysicianInfo">
    <xsl:param name="pPDSection"/>
    <xsl:param name="pPosition"/>

    <xsl:variable name="tpPDPhysicianInfo" select="$tp/Demographics/PhysicianInfo"/>
    <xsl:variable name="tpRadiologist" select="$tpPDPhysicianInfo/Item[@name = 'LBL_RADIOLOGIST']"/>
    <xsl:variable name="tpOrdPhys" select="$tpPDPhysicianInfo/Item[@name = 'LBL_ORDERING_PHYSICIAN']"/>
    <xsl:variable name="tpCardiologist" select="$tpPDPhysicianInfo/Item[@name = 'LBL_CARDIOLOGIST']"/>
    <xsl:variable name="tpRefPhys" select="$tpPDPhysicianInfo/Item[@name = 'LBL_REFERRING_PHYSICIAN']"/>
    <xsl:variable name="radiologist" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'J-06170' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="orderingPhysician" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'J-0016E' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED]"/>
    <xsl:variable name="cardiologist" select="$DICOM//Item[ConceptNameCodeSequence/Item/CodeValue = 'J-0612B' and (ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED or ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_SNOMED_RT)]"/>
    <xsl:variable name="referringPhysician" select="$DICOM/ReferringPhysiciansName"/>
    <xsl:variable name="perfProcCodeSeq" select="$tpPDPhysicianInfo/Item[@name = 'LBL_PERFORMED_PROC_CODE_SEQ']"/>

    <fo:block id="{concat($pPDSection/Section[@type = 'PHYSICIAN_INFO']/@name, $pPosition)}">
<!-- Table with 1/3 and 2/3 width columns -->
        <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
            <fo:table-body>
                <xsl:if test="($radiologist and $tpRadiologist/@add = 'true') or ($orderingPhysician and $tpOrdPhys/@add = 'true')">
                <fo:table-row keep-together="always">
<!-- (J-06170, SNM3, Radiologist) -->
                    <fo:table-cell>
                        <xsl:if test="$tpRadiologist/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_RADIOLOGIST/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$radiologist and $tpRadiologist/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$radiologist"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- (J-0016E, SNM3, Doctor) -->
                    <fo:table-cell>
                        <xsl:if test="$tpOrdPhys/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_ORDERING_PHYSICIAN/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$orderingPhysician and $tpOrdPhys/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="addValue">
                                    <xsl:with-param name="pCurrent" select="$orderingPhysician"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
                <xsl:if test="($cardiologist and $tpCardiologist/@add = 'true') or ($referringPhysician and $tpRefPhys/@add = 'true')">
                <fo:table-row keep-together="always">
<!-- (J-0612B, SNM3, Cardiologist) -->
                    <fo:table-cell>
                        <xsl:if test="$tpCardiologist/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_CARDIOLOGIST/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$cardiologist and $tpCardiologist/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:variable name="hasContent">
                                    <xsl:call-template name="hasContent">
                                        <xsl:with-param name="pItems" select="$cardiologist"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:if test="$hasContent = 'true'">
                                    <xsl:call-template name="addValue">
                                        <xsl:with-param name="pCurrent" select="$cardiologist"/>
                                    </xsl:call-template>
                                </xsl:if>    
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- (0008,0090): Referring Physician -->
                    <fo:table-cell>
                        <xsl:if test="$tpRefPhys/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_REFERRING_PHYSICIAN/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$referringPhysician and $tpRefPhys/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="formatPersonName">
                                    <xsl:with-param name="PName" select="$referringPhysician"/>
                                </xsl:call-template>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
<!-- (0040,A372): Performed Procedure Code Sequence -->
                <xsl:if test="$perfProcCodeSeq/@add = 'true'">
                <fo:table-row keep-together="always">
                    <fo:table-cell>
                        <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                            <xsl:value-of select="$messagecatalog/LBL_PERFORMED_PROC_CODE_SEQ/msg[@lang = $lang]"/>:
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                            <xsl:value-of select="$DICOM/PerformedProcedureCodeSequence/Item/CodeMeaning"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                </xsl:if>
            </fo:table-body>
        </fo:table>
        <xsl:if test="($radiologist and $tpRadiologist/@add = 'true') or ($orderingPhysician and $tpOrdPhys/@add = 'true') or ($cardiologist and $tpCardiologist/@add = 'true') or ($referringPhysician and $tpRefPhys/@add = 'true')">
            <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
        </xsl:if>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addCompletionVerification
    Description:    Add Completion Flag and Verification Flag.
-->
<xsl:template name="addCompletionVerification">
    <xsl:variable name="tpPDIdentification" select="$tp/Demographics/Identification"/>
    <xsl:variable name="tpCompFlag" select="$tpPDIdentification/Item[@name = 'LBL_COMPLETION_FLAG']"/>
    <xsl:variable name="tpVerifFlag" select="$tpPDIdentification/Item[@name = 'LBL_VERIFICATION_FLAG']"/>
    <xsl:if test="$tpCompFlag/@add = 'true' or $tpVerifFlag/@add = 'true'">
    <fo:block>
<!-- Table with 1/3 and 2/3 width columns -->
        <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(2)"/>
            <fo:table-body>
                <fo:table-row keep-together="always">
<!-- Completion Flag -->
                    <fo:table-cell>
                        <xsl:if test="$tpCompFlag/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_COMPLETION_FLAG/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpCompFlag/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/CompletionFlag"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
<!-- Verification Flag -->
                    <fo:table-cell>
                        <xsl:if test="$tpVerifFlag/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_VERIFICATION_FLAG/msg[@lang = $lang]"/>:
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tpVerifFlag/@add = 'true'">
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/VerificationFlag"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:if test="$tpVerifFlag/@add = 'true' and $DICOM/VerificationFlag = 'VERIFIED'">
                    <fo:table-row keep-together="always">
                        <fo:table-cell/>
                        <fo:table-cell/>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_VERIFYING_OBSERVER/msg[@lang = $lang]"/>:
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/VerifyingObserverSequence/Item/VerifyingObserverName"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-together="always">
                        <fo:table-cell/>
                        <fo:table-cell/>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_VERIFYING_ORGANIZATION/msg[@lang = $lang]"/>:
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$DICOM/VerifyingObserverSequence/Item/VerifyingOrganization"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row keep-together="always">
                        <fo:table-cell/>
                        <fo:table-cell/>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" font-weight="bold" space-before="1pt" space-after="1pt">
                                <xsl:value-of select="$messagecatalog/LBL_VERIFICATION_DATETIME/msg[@lang = $lang]"/>:
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block hyphenate="true" language="{$lang}" space-before="1pt" space-after="1pt">
                                <xsl:call-template name="formatDateTime">
                                    <xsl:with-param name="pDTime" select="$DICOM/VerifyingObserverSequence/Item/VerificationDateTime"/>
                                </xsl:call-template>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
            </fo:table-body>
        </fo:table>
        <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
    </fo:block>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addGenericMessage
    Description:    Add Generic Message section from the template to the report.
-->
<xsl:template name="addGenericMessage"> <xsl:param name="pGenericMessage"/>
    <xsl:if test="$pGenericMessage/Add">
        <fo:block id="{concat($pGenericMessage/Title, position())}" font-weight="bold" font-size="{$heading1FontSize}pt" space-before="4pt" space-after="4pt" color="#9999CC">
            <xsl:value-of select="$pGenericMessage/Title"/>
        </fo:block>
        <xsl:call-template name="break2NewLine">
            <xsl:with-param name="pAlign">left</xsl:with-param>
            <xsl:with-param name="pText" select="$pGenericMessage/Text"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addDiagrams
    Description:    Add Diagram section from the template to the report.
-->
<xsl:template name="addDiagram"> <xsl:param name="pDiagram"/>
    <fo:block id="{concat($pDiagram/Title, position())}" space-before="4pt" space-after="4pt">
        <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <xsl:if test="$pDiagram/Add">
                <fo:table-row keep-together="always">
                <fo:table-cell>
                    <fo:block text-align="{$tp/Diagrams/@align}" font-weight="bold">
                        <xsl:value-of select="$pDiagram/Title"/>
                    </fo:block>
                    <fo:block text-align="{$tp/Diagrams/@align}">
                        <xsl:call-template name="addExtGraphic">
                            <xsl:with-param name="pExtGraphic" select="$pDiagram/File"/>
                        </xsl:call-template>
                    </fo:block>
                    <fo:block>
                        <xsl:call-template name="break2NewLine">
                            <xsl:with-param name="pAlign" select="$tp/Diagrams/@align"/>
                            <xsl:with-param name="pText" select="$pDiagram/Disclaimer"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
                </fo:table-row>
            </xsl:if>
        </fo:table-body>
        </fo:table>
    </fo:block>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPhysicianSignature
    Description:    Add physician signatures.
-->
<!-- Workaround for the alignment of a whole table inside a block -->
<xsl:template name="addPhysicianSignature">
    <fo:block id="{concat($tp/Sections/Section[@type = 'PHYSICIAN_SIGNATURES']/@name, position())}" text-align="{$tp/Physicians/@align}" space-before="4pt" space-after="4pt">
<!-- Table with 3 equal width columns -->
        <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-column column-width="proportional-column-width(1)"/>
        <fo:table-body>
            <xsl:for-each select="$tp/Physicians/Physician">
                <xsl:if test="current()/AddSignature">
                    <xsl:variable name="emptySignatureSpace" select="'24pt'"/>
<!-- Signature -->
                    <fo:table-row>
                    <fo:table-cell>
                        <xsl:if test="$tp/Physicians/@align = 'left'">
                            <fo:block text-align="center">
                                <xsl:choose>
                                    <xsl:when test="current()/Signature and current()/Signature != ''">
                                        <xsl:call-template name="addExtGraphic">
                                            <xsl:with-param name="pExtGraphic" select="current()/Signature"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="space-after"><xsl:value-of select="$emptySignatureSpace"/></xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tp/Physicians/@align = 'center'">
                            <fo:block text-align="center">
                                <xsl:choose>
                                    <xsl:when test="current()/Signature and current()/Signature != ''">
                                        <xsl:call-template name="addExtGraphic">
                                            <xsl:with-param name="pExtGraphic" select="current()/Signature"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="space-after"><xsl:value-of select="$emptySignatureSpace"/></xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tp/Physicians/@align = 'right'">
                            <fo:block text-align="center">
                                <xsl:choose>
                                    <xsl:when test="current()/Signature and current()/Signature != ''">
                                        <xsl:call-template name="addExtGraphic">
                                            <xsl:with-param name="pExtGraphic" select="current()/Signature"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="space-after"><xsl:value-of select="$emptySignatureSpace"/></xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    </fo:table-row>
<!-- Horizontal line and Physician's Name -->
                    <fo:table-row keep-with-previous="always">
                    <fo:table-cell>
                        <xsl:if test="$tp/Physicians/@align = 'left'">
                            <xsl:attribute name="border-top-style">solid</xsl:attribute>
                            <fo:block hyphenate="true" language="{$lang}" text-align="center" space-after="4pt">
                                <xsl:value-of select="concat(current()/FirstName, ' ', current()/LastName)"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tp/Physicians/@align = 'center'">
                            <xsl:attribute name="border-top-style">solid</xsl:attribute>
                            <fo:block hyphenate="true" language="{$lang}" text-align="center" space-after="4pt">
                                <xsl:value-of select="concat(current()/FirstName, ' ', current()/LastName)"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    <fo:table-cell>
                        <xsl:if test="$tp/Physicians/@align = 'right'">
                            <xsl:attribute name="border-top-style">solid</xsl:attribute>
                            <fo:block hyphenate="true" language="{$lang}" text-align="center" space-after="4pt">
                                <xsl:value-of select="concat(current()/FirstName, ' ', current()/LastName)"/>
                            </fo:block>
                        </xsl:if>
                    </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
            </xsl:for-each>
        </fo:table-body>
        </fo:table>
    </fo:block>
</xsl:template>

<xsl:template name="addExtGraphic"> <xsl:param name="pExtGraphic"/>
    <xsl:choose>
        <xsl:when test="$pExtGraphic and $pExtGraphic != ''">
            <fo:external-graphic src="{concat('../IMAGE/', $pExtGraphic)}">
                <xsl:if test="$pExtGraphic/@width and $pExtGraphic/@width != '' and $pExtGraphic/@height and $pExtGraphic/@height != ''">
                    <xsl:variable name="heightInPageUnit">
                        <xsl:call-template name="caluclateSizeInPageUnit">
                            <xsl:with-param name="pSize" select="$pExtGraphic/@height"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$heightInPageUnit &gt; $innerPageHeight * $LARGE_IMAGE_RATE">
                            <xsl:attribute name="height">
                                <xsl:value-of select="concat($innerPageHeight * $LARGE_IMAGE_RATE, $pageUnit)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </fo:external-graphic>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addObservationContext
    Description:    Add Observation context to the report.
-->
<xsl:template name="addObservationContext">
    <!--fo:block id="Observation Context" font-weight="bold" font-size="{$heading1FontSize}pt" space-before="12pt" space-after="12pt" color="#9999CC">
        Observation Context
    </fo:block-->
</xsl:template>

</xsl:stylesheet>
