<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2005 GE Healthcare

    SECT_HTM.XSL   : Rules for adding report sections to HTML:
                     - Header (logo, name, address),
                     - Patient demographics (name, weight, etc.)
                     - Observation context
                     - Physician signatures

    Author          :   Attila RACZ
    Last modified on:   Jan 12, 2005
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<!-- ####################################################################################################
    Template:       processSections
    Description:    Process report and template sections.
-->
<xsl:template name="processSections">
    <xsl:if test="$clinicalUse = 'false'">
        <h1 style="text-align: center; font-weight: bold; color: #FF0000;">
            <xsl:value-of select="$messagecatalog/MSG_NOT_FOR_CLINICAL_USE/msg[@lang = $lang]"/>
        </h1>
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
                <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $curSectionPos)}"/>
                <xsl:call-template name="addHeaderSections">
                    <xsl:with-param name="pSection" select="current()"/>
                    <xsl:with-param name="pPosition" select="position()"/>
                </xsl:call-template>
            </xsl:when>
<!-- Patient Demographics -->
            <xsl:when test="@type = 'PATIENT_DEMOGRAPHICS'">
                <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $curSectionPos)}"/>
                <xsl:call-template name="addPDSections">
                    <xsl:with-param name="pPDSection" select="current()"/>
                    <xsl:with-param name="pPosition" select="position()"/>
                </xsl:call-template>
            </xsl:when>
<!-- Predecessor Documents -->
            <xsl:when test="@type = 'PREDECESSOR_DOCUMENTS'">
                <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $curSectionPos)}"/>
                <xsl:call-template name="addPredecessorDocuments">
                    <xsl:with-param name="pSection" select="current()"/>
                    <xsl:with-param name="pPosition" select="position()"/>
                </xsl:call-template>
            </xsl:when>
<!-- Generic Message -->
            <xsl:when test="@type = 'GENERIC_MESSAGE'">
                <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $curSectionPos)}"/>
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
                <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), position())}"/>
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
                <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $curSectionPos)}"/>
    <!-- Add Diagram where the Title is @name -->
                <xsl:call-template name="addDiagram">
                    <xsl:with-param name="pDiagram" select="$tp/Diagrams/Diagram[@id = current()/@id]"/>
                </xsl:call-template>
            </xsl:when>
<!-- Physician signature -->
            <xsl:when test="@type = 'PHYSICIAN_SIGNATURES'">
                <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $curSectionPos)}"/>
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
                        <xsl:call-template name="addContentItem">
                            <xsl:with-param name="pItem" select="$itemWithPos"/>
                            <xsl:with-param name="pPosition" select="$curSectionPos"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
        <!-- Select position in $itemsWithCode of current Section node among the sections with the same code and scheme.
             If there are more sections with the same code and scheme in the template than in the SR they are displayed repeatedly (using mod for position calculation). -->
                        <xsl:variable name="curSameSectionPos" select="count(preceding-sibling::Section[@code = current()/@code and @scheme = current()/@scheme]) mod $itemsWithCodeNo + 1"/>
                        <xsl:variable name="itemWithPos" select="$itemsWithCode[position() = $curSameSectionPos]"/>
                        <xsl:call-template name="addContentItem">
                            <xsl:with-param name="pItem" select="$itemWithPos"/>
                            <xsl:with-param name="pPosition" select="$curSectionPos"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       processReportSections
    Description:    Process report sections.
    Parameters:
        pCurSectionPos :
-->
<xsl:template name="processReportSections"> <xsl:param name="pCurSectionPos"/>

    <xsl:for-each select="$DICOM/ContentSequence/Item">
        <xsl:choose>
            <xsl:when test="current()/ConceptNameCodeSequence/Item/CodeValue = '121025' and current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM">
                <!-- Patient Demographics are added by addPDSections template. -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="addContentItem">
                    <xsl:with-param name="pItem" select="current()"/>
                    <xsl:with-param name="pPosition" select="concat($pCurSectionPos, position())"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
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
        <h1 style="text-align: center; font-weight: bold; color: #FF0000;">
            <xsl:value-of select="$messagecatalog/MSG_PATIENT_IDENTIFICATION_MISSING/msg[@lang = $lang]"/>
        </h1>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addHeaderSections
    Description:    Add header sections to the report in the order specified by template.
    Parameters:
        pSection    : Current Section node with @type = 'HEADER'
        pPosition   : Position of pSection
-->
<xsl:template name="addHeaderSections"> <xsl:param name="pSection"/>
                                        <xsl:param name="pPosition"/>

    <xsl:for-each select="$pSection/Section">
        <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $pPosition)}"/>
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
                <xsl:call-template name="addPhysicians"/>
            </xsl:when>
<!-- Report Title -->
            <xsl:when test="@type = 'REPORT_TITLE'">
                <xsl:call-template name="addReportTitle"/>
            </xsl:when>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- Add hospital logo to the header. -->
<xsl:template name="addHospitalLogo2HTML">
    <xsl:variable name="logo" select="$tp/Header/Hospital/Logo"/>
    <xsl:if test="$logo != ''">
        <div style="text-align: {$logo/@align}; font-family: {$tp/Font/@type}">
            <img src="{concat('../IMAGE/', $logo)}" alt="Hospital logo">
                <xsl:if test="$logo/@width and $logo/@width != '' and $logo/@height and $logo/@height != ''">
                    <xsl:attribute name="style">
                        <xsl:value-of select="concat('width: ', $logo/@width * $logo/@scale, 'px; height: ', $logo/@height * $logo/@scale, 'px;')"/>
                    </xsl:attribute>
                </xsl:if>
            </img>
        </div>
    </xsl:if>
</xsl:template>

<!-- Add hospital address to the header. -->
<xsl:template name="addHospitalAddress2HTML"> <xsl:param name="pAlign"/> <xsl:param name="pName"/> <xsl:param name="pAddress"/>
    <xsl:variable name="nameMsg" select="$messagecatalog/*[local-name() = $pName]"/>
    <xsl:variable name="addressMsg" select="$messagecatalog/*[local-name() = $pAddress]"/>
    <div style="text-align: {$pAlign}; font-family: {$tp/Font/@type}">
        <b>
        <xsl:choose>
            <xsl:when test="$nameMsg">
                <xsl:value-of select="$nameMsg/msg[@lang = $lang]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$pName"/>
            </xsl:otherwise>
        </xsl:choose>
        </b>
        <br/>
        <xsl:choose>
            <xsl:when test="$addressMsg">
                <xsl:value-of select="$addressMsg/msg[@lang = $lang]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="break2NewLine">
                    <xsl:with-param name="pText" select="$pAddress"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPhysicians
    Description:    Add physicians.
-->
<xsl:template name="addPhysicians">
    <xsl:if test="$tp/Physicians/Physician/AddToReport">
        <table cellpadding="2" cellspacing="2" width="100%"  border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <xsl:for-each select="$tp/Physicians/Physician">
                <tr><td align="{$tp/Physicians/@align}">
                <xsl:if test="current()/AddToReport">
                    <xsl:value-of select="concat(current()/FirstName, ' ', current()/LastName)"/>
                </xsl:if>
                 </td></tr>
            </xsl:for-each>
         </table>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addReportTitle
    Description:    Add title of the report.
-->
<xsl:template name="addReportTitle">
    <h1 style="text-align: center; font-weight: bold;">
        <xsl:value-of select="$DICOM/ConceptNameCodeSequence/Item/CodeMeaning"/>
    </h1>
</xsl:template>

<!-- ####################################################################################################
    Template:       addLogoNameAddress
    Description:    Add hospital logo name and address to the report.
-->
<xsl:template name="addLogoNameAddress">
    <xsl:variable name="hospitalLogoAlignment" select="$tp/Header/Hospital/Logo/@align"/>
    <xsl:variable name="hospitalAddressAlignment" select="$tp/Header/Hospital/Name/@align"/>
    <xsl:choose>
<!-- Logo and hospital info aligned to the same position : display them in separate lines. -->
        <xsl:when test="$hospitalLogoAlignment = $hospitalAddressAlignment">
    <!-- Hospital logo -->
            <xsl:if test="$hospitalLogoAlignment != 'hide'">
                <xsl:call-template name="addHospitalLogo2HTML"/>
            </xsl:if>
    <!-- Hospital name and address -->
            <xsl:if test="$hospitalAddressAlignment != 'hide'">
                <xsl:call-template name="addHospitalAddress2HTML">
                    <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                    <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                    <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:when>
<!-- Logo and hospital info are aligned to different position : display them on the same horizontal line. -->
        <xsl:otherwise>
            <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
                <tr>
                    <xsl:choose>
                        <xsl:when test="$hospitalLogoAlignment = 'hide'">
                            <td style="text-align:left;">
                                <xsl:call-template name="addHospitalAddress2HTML">
                                    <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                    <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                    <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                </xsl:call-template>
                            </td>
                        </xsl:when>
                        <xsl:when test="$hospitalAddressAlignment = 'hide'">
                            <td style="text-align:left;">
                                <xsl:call-template name="addHospitalLogo2HTML"/>
                            </td>
                        </xsl:when>
                        <xsl:when test="$hospitalLogoAlignment = 'left'">
                            <td style="text-align:left;">
                                <xsl:call-template name="addHospitalLogo2HTML"/>
                            </td>
                            <td style="text-align:left;" colspan="2">
                                <xsl:call-template name="addHospitalAddress2HTML">
                                    <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                    <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                    <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                </xsl:call-template>
                            </td>
                        </xsl:when>
                        <xsl:when test="$hospitalLogoAlignment = 'center'">
                            <td style="text-align:left; width: 33%;">
                                <xsl:if test="$hospitalAddressAlignment = 'left'">
                                    <xsl:call-template name="addHospitalAddress2HTML">
                                        <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                        <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                        <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </td>
                            <td style="text-align:left; width: 34%;">
                                <xsl:call-template name="addHospitalLogo2HTML"/>
                            </td>
                            <td style="text-align:left; width: 33%;">
                                <xsl:if test="$hospitalAddressAlignment = 'right'">
                                    <xsl:call-template name="addHospitalAddress2HTML">
                                        <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                        <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                        <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </td>
                        </xsl:when>
                        <xsl:when test="$hospitalLogoAlignment = 'right'">
                            <td style="text-align:left;">
                                <xsl:if test="$hospitalAddressAlignment = 'left'">
                                    <xsl:attribute name="colspan">2</xsl:attribute>
                                    <xsl:call-template name="addHospitalAddress2HTML">
                                        <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                        <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                        <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </td>
                            <xsl:if test="$hospitalAddressAlignment = 'center'">
                            <td style="text-align:left;">
                                <xsl:call-template name="addHospitalAddress2HTML">
                                    <xsl:with-param name="pAlign" select="$hospitalAddressAlignment"/>
                                    <xsl:with-param name="pName" select="$tp/Header/Hospital/Name"/>
                                    <xsl:with-param name="pAddress" select="$tp/Header/Hospital/Address"/>
                                </xsl:call-template>
                            </td>
                            </xsl:if>
                            <td style="text-align:left;">
                                <xsl:call-template name="addHospitalLogo2HTML"/>
                            </td>
                        </xsl:when>
                    </xsl:choose>
                </tr>
            </table>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDSections
    Description:    Add patient information to the report in the order specified by template.
-->
<xsl:template name="addPDSections"> <xsl:param name="pPDSection"/>
                                    <xsl:param name="pPosition"/>

    <xsl:for-each select="$pPDSection/Section">
        <a name="{concat(translate(@name, $INVALID_NAME_CHARS, ''), $pPosition)}"/>
        <xsl:choose>
<!-- Identification -->
            <xsl:when test="@type = 'IDENTIFICATION' and count($tp/Demographics/Identification/Item[@add = 'true']) &gt; 0">
                <xsl:call-template name="addPDIdentification"/>
            </xsl:when>
<!-- Medical History -->
            <xsl:when test="@type = 'MEDICAL_HISTORY' and count($tp/Demographics/MedicalHistory/Item[@add = 'true']) &gt; 0">
                <xsl:call-template name="addPDMedicalHistory"/>
            </xsl:when>
<!-- Physician Info -->
            <xsl:when test="@type = 'PHYSICIAN_INFO' and count($tp/Demographics/PhysicianInfo/Item[@add = 'true']) &gt; 0">
                <xsl:call-template name="addPDPhysicianInfo"/>
            </xsl:when>
        </xsl:choose>
    </xsl:for-each>
    <xsl:call-template name="addCompletionVerification"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDemographics
    Description:    Add patient demographics.
        pPDItems  :  Patient demographics items in the template.
        pN        :  # of columns patient demographics are displayed across.
-->
<xsl:template name="addPDemographics"> <xsl:param name="pPDItems"/>
                                       <xsl:param name="pN" select="$demographicsColumns"/>

    <xsl:if test="$pPDItems">
        <table style="width: 100%; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <xsl:if test="$rendering = 'xls'">
                <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="addNPDemographics">
                <xsl:with-param name="pPDItems" select="$pPDItems"/>
                <xsl:with-param name="pN" select="$pN"/>
            </xsl:call-template>
        </table>
        <hr/>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNPDemographics
    Description:    Recursively adds patient demographics organized into N columns.
    Parameters:
        pPDItems  :  Patient demographics items in the template.
        pN        :  # of columns patient demographics are displayed across.
-->
<xsl:template name="addNPDemographics"> <xsl:param name="pPDItems"/>
                                        <xsl:param name="pN" select="$demographicsColumns"/>

    <xsl:variable name="firstNPDFields" select="$pPDItems[position() &lt;= $pN]"/>
    <tr>
        <xsl:for-each select="$firstNPDFields">
            <td style="width: 20%; font-weight: bold">
                <xsl:variable name="fieldMsg" select="$messagecatalog/*[local-name() = current()/@name]"/>
                <xsl:value-of select="$fieldMsg/msg[@lang = $lang]"/>:
            </td>
            <td style="width: 30%;">
                <xsl:text> </xsl:text>
                <xsl:call-template name="addPDValue">
                    <xsl:with-param name="pPDItem" select="current()"/>
                </xsl:call-template>
            </td>
        </xsl:for-each>
        <!--xsl:call-template name="addEmptyCells">
            <xsl:with-param name="pTotalCols" select="2*$pN"/>
            <xsl:with-param name="pN" select="$pN - count($firstNPDFields)"/>
        </xsl:call-template-->
    </tr>
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
-->
<xsl:template name="addPDIdentification">
    <xsl:call-template name="addPDemographics">
        <xsl:with-param name="pPDItems" select="$tp/Demographics/Identification/Item[@add = 'true' and @name != 'LBL_COMPLETION_FLAG' and @name != 'LBL_VERIFICATION_FLAG']"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDIdentification
    Description:    Add patient demographics: Identification.
-->
<xsl:template name="addPDIdentification2">
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

    <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <xsl:if test="$tpPatientID/@add = 'true' or $tpEthnicGrp/@add = 'true'">
    <tr>
<!-- Patient ID -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpPatientID/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_PATIENTID/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpPatientID/@add = 'true'">
                <xsl:value-of select="$DICOM/PatientID"/>
            </xsl:if>
        </td>
<!-- Ethnic Group -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpEthnicGrp/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_ETHNIC_GROUP/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpEthnicGrp/@add = 'true'">
                <xsl:choose>
                    <xsl:when test="$DICOM/@mode = 'ed' and (not($DICOM/EthnicGroup) or $DICOM/EthnicGroup = '')">
                        <input type="text" id="{@id}" name="EthnicGroup" size="16" maxlength="16" value="{$DICOM/EthnicGroup}" onBlur="validateChar(this)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$DICOM/EthnicGroup"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="$tpPatientName/@add = 'true' or $tpStudyDate/@add = 'true'">
    <tr>
<!-- Patient Name -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpPatientName/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_NAME/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpPatientName/@add = 'true'">
                <xsl:call-template name="formatPersonName">
                    <xsl:with-param name="PName" select="$DICOM/PatientName"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- Examdate -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpStudyDate/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_STUDYDATE/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpStudyDate/@add = 'true'">
                <xsl:call-template name="addDateAndTime">
                    <xsl:with-param name="pDate" select="$DICOM/StudyDate"/>
                    <xsl:with-param name="pTime" select="$DICOM/StudyTime"/>
                </xsl:call-template>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="$tpBirthdate/@add = 'true' or $tpStudyID/@add = 'true'">
    <tr>
<!-- Birthdate -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpBirthdate/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_BIRTHDATE/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpBirthdate/@add = 'true'">
                <xsl:value-of select="$DICOM/PatientBirthDate"/>
            </xsl:if>
        </td>
<!-- Exam No. -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpStudyID/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_STUDYID/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpStudyID/@add = 'true'">
                <xsl:value-of select="$DICOM/StudyID"/>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="$tpAge/@add = 'true' or $tpAccessionNum/@add = 'true'">
    <tr>
<!-- Age -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpAge/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_AGE/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpAge/@add = 'true'">
                <xsl:call-template name="addAgeText">
                    <xsl:with-param name="pAge" select="$DICOM/PatientAge"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- Accession Number -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpAccessionNum/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_ACCESSION_NUMBER/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpAccessionNum/@add = 'true'">
                <xsl:value-of select="$DICOM/AccessionNumber"/>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="$tpSex/@add = 'true' or $tpContentDate/@add = 'true'">
    <tr>
<!-- Sex -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpSex/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_SEX/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpSex/@add = 'true'">
                <xsl:call-template name="addSexText">
                    <xsl:with-param name="PSex" select="$DICOM/PatientSex"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- Content Date and Time -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpContentDate/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_CONTENT_DATE/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpContentDate/@add = 'true'">
                <xsl:call-template name="addDateAndTime">
                    <xsl:with-param name="pDate" select="$DICOM/ContentDate"/>
                    <xsl:with-param name="pTime" select="$DICOM/ContentTime"/>
                </xsl:call-template>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
<!-- Requester Procedure Description -->
    <xsl:if test="$tpRequestedProcDesc/@add = 'true'">
    <tr>
        <td style="width: 20%; font-weight: bold">
            <xsl:value-of select="$messagecatalog/LBL_REQUESTED_PROC_DESC/msg[@lang = $lang]"/>:
        </td>
        <td style="width: 30%;">
            <xsl:value-of select="$DICOM/ReferencedRequestSequence/Item/RequestedProcedureDescription"/>
        </td>
    </tr>   
    </xsl:if>
    </table>
    <xsl:if test="$tpPatientID/@add = 'true' or $tpEthnicGrp/@add = 'true' or $tpPatientName/@add = 'true' or $tpStudyDate/@add = 'true' or $tpBirthdate/@add = 'true' or $tpStudyID/@add = 'true' or $tpAge/@add = 'true' or $tpAccessionNum/@add = 'true' or $tpSex/@add = 'true' or $tpContentDate/@add = 'true'">
        <hr/>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDMedicalHistory
    Description:    Add patient demographics: Medical History.
-->
<xsl:template name="addPDMedicalHistory2">
    <xsl:call-template name="addPDemographics">
        <xsl:with-param name="pPDItems" select="$tp/Demographics/MedicalHistory/Item[@add = 'true']"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDMedicalHistory
    Description:    Add patient demographics: Medical History.
-->
<xsl:template name="addPDMedicalHistory">
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

    <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <xsl:if test="$rendering = 'xls'">
        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
    </xsl:if>
    <xsl:if test="$tpWeight/@add = 'true' or $tpBSA/@add = 'true'">
    <tr>
<!-- Weight -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpWeight/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_WEIGHT/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpWeight/@add = 'true'">
                <xsl:call-template name="addWeight2HTML">
                    <xsl:with-param name="pWeight" select="$DICOM/PatientWeight"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- Body Surface Area -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpBSA/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_BODY_SURFACE_AREA/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpBSA/@add = 'true'">
                <xsl:call-template name="addBSA"/>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="$tpHeight/@add = 'true' or $tpBMI/@add = 'true'">
    <tr>
<!-- Height -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpHeight/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_HEIGHT/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpHeight/@add = 'true'">
                <xsl:call-template name="addHeight2HTML">
                    <xsl:with-param name="pHeight" select="$DICOM/PatientSize"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- Body Mass Index -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpBMI/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_BODY_MASS_INDEX/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpBMI/@add = 'true'">
                <xsl:call-template name="addBMI"/>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="($smoking and $tpSmoking/@add = 'true') or ($overweight and $tpOverweight/@add = 'true')">
    <tr>
<!-- (S-32000, SNM3, Smoker) -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpSmoking/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_SMOKING/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpSmoking/@add = 'true'">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$smoking"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- (F-02A18, SNM3, Overweight) -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpOverweight/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_OVERWEIGHT/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpOverweight/@add = 'true'">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$overweight"/>
                </xsl:call-template>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="($diabetes and $tpDiabetes/@add = 'true') or ($cholesterol and $tpCholesterol/@add = 'true')">
    <tr>
<!-- (VV-050, 99GEMS, Diabetes) -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpDiabetes/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_DIABETES/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpDiabetes/@add = 'true'">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$diabetes"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- (F-63980, SNM3, Cholesterol) -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpCholesterol/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_CHOLESTEROL/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpCholesterol/@add = 'true'">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$cholesterol"/>
                </xsl:call-template>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    </table>
    <xsl:if test="$tpWeight/@add = 'true' or $tpBSA/@add = 'true' or $tpHeight/@add = 'true' or $tpBMI/@add = 'true' or ($smoking and $tpSmoking/@add = 'true') or ($overweight and $tpOverweight/@add = 'true') or ($diabetes and $tpDiabetes/@add = 'true') or ($cholesterol and $tpCholesterol/@add = 'true')">
        <hr/>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDPhysicianInfo
    Description:    Add patient demographics: Physician Info.
-->
<xsl:template name="addPDPhysicianInfo">
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
    
    <xsl:if test="($radiologist and $tpRadiologist/@add = 'true') or ($orderingPhysician and $tpOrdPhys/@add = 'true') or ($cardiologist and $tpCardiologist/@add = 'true') or ($referringPhysician and $tpRefPhys/@add = 'true')">
    <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <xsl:if test="$rendering = 'xls'">
        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
    </xsl:if>
    <xsl:if test="($radiologist and $tpRadiologist/@add = 'true') or ($orderingPhysician and $tpOrdPhys/@add = 'true')">
    <tr>
<!-- (J-06170, SNM3, Radiologist) -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpRadiologist/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_RADIOLOGIST/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpRadiologist/@add = 'true'">
                <xsl:choose>
                    <xsl:when test="$DICOM/@mode = 'ed' and $radiologist/TextValue = ''">
                        <input type="text" id="{$radiologist/@id}" name="TextValue" title="Family^Given^Middle^Prefix^Suffix" size="16" value="{$radiologist/TextValue}" onBlur="validateChar(this)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--xsl:call-template name="formatPersonName">
                            <xsl:with-param name="PName" select="$DICOM/ReferringPhysiciansName"/>
                        </xsl:call-template-->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$radiologist"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </td>
<!-- (J-0016E, SNM3, Doctor) -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpOrdPhys/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_ORDERING_PHYSICIAN/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpOrdPhys/@add = 'true'">
                <xsl:choose>
                    <xsl:when test="$DICOM/@mode = 'ed' and $orderingPhysician/TextValue = ''">
                        <input type="text" id="{$orderingPhysician/@id}" name="TextValue" title="Family^Given^Middle^Prefix^Suffix" size="16" value="{$orderingPhysician/TextValue}" onBlur="validateChar(this)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--xsl:call-template name="formatPersonName">
                            <xsl:with-param name="PName" select="$DICOM/OrderingPhysiciansName"/>
                        </xsl:call-template-->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="$orderingPhysician"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
    <xsl:if test="($cardiologist and $tpCardiologist/@add = 'true') or ($referringPhysician and $tpRefPhys/@add = 'true')">
    <tr>
<!-- (J-0612B, SNM3, Cardiologist) -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpCardiologist/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_CARDIOLOGIST/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpCardiologist/@add = 'true'">
                <xsl:call-template name="addValue">
                    <xsl:with-param name="pCurrent" select="$cardiologist"/>
                </xsl:call-template>
            </xsl:if>
        </td>
<!-- (0008,0090): Referring Physician -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpRefPhys/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_REFERRING_PHYSICIAN/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpRefPhys/@add = 'true'">
                <xsl:choose>
                    <xsl:when test="$DICOM/@mode = 'ed' and $referringPhysician = ''">
                        <input type="text" id="{$referringPhysician/@id}" name="ReferringPhysiciansName" title="Family^Given^Middle^Prefix^Suffix" size="16" value="{$referringPhysician}" onBlur="validateChar(this)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="formatPersonName">
                            <xsl:with-param name="PName" select="$referringPhysician"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </td>
    </tr>
    </xsl:if>
<!-- (0008,0090): Performed Procedure Code Sequence -->
    <xsl:if test="$perfProcCodeSeq/@add = 'true'">
    <tr>
        <td style="width: 20%; font-weight: bold">
            <xsl:value-of select="$messagecatalog/LBL_PERFORMED_PROC_CODE_SEQ/msg[@lang = $lang]"/>:
        </td>
        <td style="width: 30%;">
            <xsl:value-of select="$DICOM/PerformedProcedureCodeSequence/Item/CodeMeaning"/>
        </td>
    </tr>
    </xsl:if>
    </table>
    <hr/>
    </xsl:if>
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
    <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <xsl:if test="$rendering = 'xls'">
        <xsl:attribute name="x:str" namespace="urn:schemas-microsoft-com:office:excel"></xsl:attribute>
    </xsl:if>
    <tr>
<!-- Completion Flag -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpCompFlag/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_COMPLETION_FLAG/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpCompFlag/@add = 'true'">
                <xsl:choose>
                    <xsl:when test="$DICOM/@mode = 'ed'">
                        <xsl:call-template name="addSelect">
                            <xsl:with-param name="PGroup">LBL_COMPLETION_FLAG</xsl:with-param>
                            <xsl:with-param name="PName">CompletionFlag</xsl:with-param>
                            <xsl:with-param name="PSelection" select="$DICOM/CompletionFlag"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$DICOM/CompletionFlag"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </td>
<!-- Verification Flag -->
        <td style="width: 20%; font-weight: bold">
            <xsl:if test="$tpVerifFlag/@add = 'true'">
                <xsl:value-of select="$messagecatalog/LBL_VERIFICATION_FLAG/msg[@lang = $lang]"/>:
            </xsl:if>
        </td>
        <td style="width: 30%;">
            <xsl:if test="$tpVerifFlag/@add = 'true'">
                <xsl:value-of select="$DICOM/VerificationFlag"/>
            </xsl:if>
        </td>
    </tr>
    <xsl:if test="$tpVerifFlag/@add = 'true' and $DICOM/VerificationFlag = 'VERIFIED'">
        <tr>
            <td style="width: 20%; font-weight: bold"/>
            <td style="width: 30%;"/>
            <td style="width: 20%; font-weight: bold">
                <xsl:value-of select="$messagecatalog/LBL_VERIFYING_OBSERVER/msg[@lang = $lang]"/>:
            </td>
            <td style="width: 30%;">
                <xsl:value-of select="$DICOM/VerifyingObserverSequence/Item/VerifyingObserverName"/>
            </td>
        </tr>
        <tr>
            <td style="width: 20%; font-weight: bold"/>
            <td style="width: 30%;"/>
            <td style="width: 20%; font-weight: bold">
                <xsl:value-of select="$messagecatalog/LBL_VERIFYING_ORGANIZATION/msg[@lang = $lang]"/>:
            </td>
            <td style="width: 30%;">
                <xsl:value-of select="$DICOM/VerifyingObserverSequence/Item/VerifyingOrganization"/>
            </td>
        </tr>
        <tr>
            <td style="width: 20%; font-weight: bold"/>
            <td style="width: 30%;"/>
            <td style="width: 20%; font-weight: bold">
                <xsl:value-of select="$messagecatalog/LBL_VERIFICATION_DATETIME/msg[@lang = $lang]"/>:
            </td>
            <td>
                <xsl:call-template name="formatDateTime">
                    <xsl:with-param name="pDTime" select="$DICOM/VerifyingObserverSequence/Item/VerificationDateTime"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:if>
    </table>
    <hr/>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPredecessorDocuments
    Description:    Add Predecessor Documents section from the template to the report.
-->
<xsl:template name="addPredecessorDocuments">
    <xsl:param name="pSection"/>
    <xsl:param name="pPosition"/>

    <xsl:if test="$DICOM/PredecessorDocumentsSequence/Item">
        <h2>
            <xsl:value-of select="$messagecatalog/LBL_PREDECESSOR_DOCUMENTS/msg[@lang = $lang]"/>
        </h2>
        <xsl:for-each select="$DICOM/PredecessorDocumentsSequence/Item//ReferencedSOPSequence/Item">
            <xsl:choose>
                <xsl:when test="$DICOM/@mode = 'ed'">
                    <img src="../IMAGE/HTMRPT64.GIF">
                    <xsl:attribute name="alt">
                        <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = current()/ReferencedSOPClassUID]/@abbrev"/>
                    </xsl:attribute>
                    </img>
                </xsl:when>
                <xsl:otherwise>
                    <a>
                    <xsl:attribute name="href">javascript:showSRByUID('<xsl:value-of select="current()/ReferencedSOPInstanceUID"/>')</xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = current()/ReferencedSOPClassUID]/@abbrev"/>
                    </xsl:attribute>
                    <img src="../IMAGE/HTMRPT64.GIF">
                    <xsl:attribute name="alt">
                        <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = current()/ReferencedSOPClassUID]/@abbrev"/>
                    </xsl:attribute>
                    </img>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <hr/>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addGenericMessage
    Description:    Add Generic Message section from the template to the report.
-->
<xsl:template name="addGenericMessage"> <xsl:param name="pGenericMessage"/>
    <xsl:if test="$pGenericMessage/Add">
        <h2><xsl:value-of select="$pGenericMessage/Title"/></h2>
        <p title="{concat($messagecatalog/LBL_MESSAGE/msg[@lang = $lang], ' - ', $pGenericMessage/Title)}">
        <xsl:call-template name="break2NewLine">
            <xsl:with-param name="pText" select="$pGenericMessage/Text"/>
        </xsl:call-template>
        </p>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addDiagram
    Description:    Add Diagram section from the template to the report.
-->
<xsl:template name="addDiagram"> <xsl:param name="pDiagram"/>
    <xsl:if test="$pDiagram/Add">
        <p style="text-align: {$tp/Diagrams/@align}; font-weight: bold">
            <xsl:value-of select="$pDiagram/Title"/>
        </p>
        <div style="text-align: {$tp/Diagrams/@align}; font-family: {$tp/Font/@type}" title="{concat($messagecatalog/LBL_DIAGRAM/msg[@lang = $lang], ' - ', $pDiagram/Title)}">
            <img src="{concat('../IMAGE/', $pDiagram/File)}" alt="{$pDiagram/Title}"/>
        </div>
        <p style="text-align: {$tp/Diagrams/@align};">
        <xsl:call-template name="break2NewLine">
            <xsl:with-param name="pText" select="$pDiagram/Disclaimer"/>
        </xsl:call-template>
        </p>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPhysicianSignature
    Description:    Add physician signatures.
-->
<xsl:template name="addPhysicianSignature">
    <xsl:if test="$tp/Physicians/Physician/AddSignature">
        <table cellpadding="2" cellspacing="2" style="width: 100%; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
        <tr><td style="text-align: center; vertical-align: top;">
        <table align="{$tp/Physicians/@align}" style="width: 33%; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <xsl:for-each select="$tp/Physicians/Physician">
                <xsl:if test="current()/AddSignature">
                    <tr>
                        <td style="text-align: center; vertical-align: top;">
                            <xsl:choose>
                                <xsl:when test="current()/Signature and current()/Signature != ''">
                                    <img src="{concat('../IMAGE/', current()/Signature)}" alt="{concat(current()/FirstName, ' ', current()/LastName)}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <br/><br/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                    <tr><td style="text-align: center; vertical-align: top;"><hr noshade="noshade"/></td></tr>
                    <tr>
                        <td style="text-align: center; vertical-align: top;">
                            <xsl:value-of select="concat(current()/FirstName, ' ', current()/LastName)"/>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
        </td></tr>
        </table>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addObservationContext
    Description:    Add Observation context to the report.
-->
<xsl:template name="addObservationContext">
    <!--h2 style="font-family: {$tp/Font/@type}">Observation Context</h2-->

<!-- ====================================================================================================
    Observer context
-->
    <xsl:if test="count($DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121005]) &gt; 0">
    <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <caption style="font-size: larger"><b>Observer Context</b></caption>
    <tr>
        <th>Observer Type</th>
        <th>Observer Identifying Attributes</th>
    </tr>

<!--
    Person observers
-->
    <xsl:if test="count($DICOM/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 121006]) &gt; 0">
    <tr>
        <td align="center"><xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../CodeValue = '121006']"/></td>
        <td>
            <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <tr>
                <th style="font-size: smaller">Name</th>
                <th style="font-size: smaller">Organization Name</th>
                <th style="font-size: smaller">Role in the Organization</th>
                <th style="font-size: smaller">Role in the Procedure</th>
            </tr>
<!-- Process each Person Observer -->
            <xsl:for-each select="$DICOM/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 121006]">
            <tr>
<!-- Person Observer Name, Req: M -->
                <td align="center" style="font-size: smaller">
                    <xsl:call-template name="formatPersonName">
                        <xsl:with-param name="PName" select="following-sibling::Item/PersonName[../ConceptNameCodeSequence/Item/CodeValue = 121008 and generate-id(../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121006][1]) = generate-id(current())]"/>
                    </xsl:call-template>
                </td>
<!-- Person Observer's Organization Name, Req: U, Def: Institution Name (0008,0080) -->
                <td align="center" style="font-size: smaller">
                    <xsl:choose>
                        <xsl:when test="following-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = 121009 and generate-id(preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121006][1]) = generate-id(current())]">
                            <xsl:value-of select="following-sibling::Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = 121009 and generate-id(../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121006][1]) = generate-id(current())]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/InstitutionName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Person Observer's Role in the Organization, Req: U -->
                <td align="center" style="font-size: smaller">
                    <xsl:value-of select="following-sibling::Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = 121010 and generate-id(../../../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121006][1]) = generate-id(current())]"/>
                </td>
<!-- Person Observer's Role in the Procedure, Req: U -->
                <td align="center" style="font-size: smaller">
                    <xsl:value-of select="following-sibling::Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = 121011 and generate-id(../../../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121006][1]) = generate-id(current())]"/>
                </td>
            </tr>
            </xsl:for-each>
            </table>
        </td>
    </tr>
    </xsl:if>

<!--
    Device observers
-->
    <xsl:if test="count($DICOM/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 121007]) &gt; 0">
    <tr>
        <td><xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../CodeValue = '121007']"/></td>
        <td>
            <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <tr>
                <th style="font-size: smaller">Name</th>
                <th style="font-size: smaller">Manufacturer</th>
                <th style="font-size: smaller">Model Name</th>
                <th style="font-size: smaller">Serial Number</th>
            </tr>
<!-- Process each Device Observer -->
            <xsl:for-each select="$DICOM/ContentSequence/Item[ConceptCodeSequence/Item/CodeValue = 121007]">
            <tr>
<!-- Device Observer Name, Req: U, Def: Station Name (0008,1010) -->
                <td align="center" style="font-size: smaller">
                    <xsl:choose>
                        <xsl:when test="following-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = 121013 and generate-id(preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]">
                            <xsl:value-of select="following-sibling::Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = 121013 and generate-id(../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/StationName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Device Observer Manufacturer, Req: U, Def: Manufacturer (0008,0070) -->
                <td align="center" style="font-size: smaller">
                    <xsl:choose>
                        <xsl:when test="following-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = 121014 and generate-id(preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]">
                            <xsl:value-of select="following-sibling::Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = 121014 and generate-id(../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/Manufacturer"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Device Observer Model Name, Req: U, Def: Manufacturer's Model Name (0008,1090) -->
                <td align="center" style="font-size: smaller">
                    <xsl:choose>
                        <xsl:when test="following-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = 121015 and generate-id(preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]">
                            <xsl:value-of select="following-sibling::Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = 121015 and generate-id(../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/ManufacturersModelName"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Device Observer Serial Number, Req: U, Def: Device Serial Number (0018,1000) -->
                <td align="center" style="font-size: smaller">
                    <xsl:choose>
                        <xsl:when test="following-sibling::Item[ConceptNameCodeSequence/Item/CodeValue = 121016 and generate-id(preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]">
                            <xsl:value-of select="following-sibling::Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = 121016 and generate-id(../preceding-sibling::Item[ConceptCodeSequence/Item/CodeValue = 121007][1]) = generate-id(current())]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/DeviceSerialNumber"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            </xsl:for-each>
            </table>
        </td>
    </tr>
    </xsl:if>
    </table>
    <br/>
    </xsl:if>

<!-- ====================================================================================================
    Procedure context
-->
    <xsl:if test="count($DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue &gt;= 121018 and ConceptNameCodeSequence/Item/CodeValue &lt;= 121023]) &gt; 0">
    <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <caption style="font-size: larger"><b>Procedure Context</b></caption>
    <tr>
        <th>Study Instance UID</th>
        <th>Accession Number</th>
    </tr>
    <tr>
<!-- Procedure Study Instance UID, Req: U, Def: StudyInstanceUID (0020,000d) -->
        <td align="center">
            <xsl:choose>
                <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121018]">
                    <xsl:value-of select="$DICOM/ContentSequence/Item/UID[../ConceptNameCodeSequence/Item/CodeValue = '121018']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$DICOM/StudyInstanceUID"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
<!-- Procedure Accession Number, Req: U, Def: Accession Number (0008,0050) -->
        <td align="center">
            <xsl:choose>
                <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121022]">
                    <xsl:value-of select="$DICOM/ContentSequence/Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = '121022']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$DICOM/AccessionNumber"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
    </table>
    <br/>
    </xsl:if>

<!-- ====================================================================================================
    Subject context
-->
    <xsl:if test="count($DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121024]) &gt; 0">
    <table width="100%" border="1" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <caption style="font-size: larger"><b>Subject Context: <xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = '121024']"/></b></caption>
    <xsl:choose>
<!--
    Patient subject
-->
        <xsl:when test="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeValue[../../../ConceptNameCodeSequence/Item/CodeValue = '121024'] = '121025'">
            <tr>
                <th>Name</th>
                <th>ID</th>
                <th>Birth Date</th>
                <th>Sex</th>
                <th>Age</th>
                <th>Species</th>
            </tr>
            <tr>
<!-- Subject Name, Req: MC, Def: Patient Name (0010,0010) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121029]">
                            <xsl:call-template name="formatPersonName">
                                <xsl:with-param name="PName" select="$DICOM/ContentSequence/Item/PersonName[../ConceptNameCodeSequence/Item/CodeValue = '121029']"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="formatPersonName">
                                <xsl:with-param name="PName" select="$DICOM/PatientName"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Subject ID, Req: MC, Def: Patient ID (0010,0020) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121030]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = '121030']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/PatientID"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Subject Birth Date, Req: U, Def: Patient Birth Date (0010,0030) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121031]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/Date[../ConceptNameCodeSequence/Item/CodeValue = '121031']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="formatDate">
                                <xsl:with-param name="pDate" select="$DICOM/PatientBirthDate"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Subject Sex, Req: U, Def: Patient Sex (0010,0040) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121032]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = '121032']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="addSexText">
                                <xsl:with-param name="PSex" select="$DICOM/PatientSex"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Subject Age, Req: U, Def: Patient Age (0010,1010) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121033]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/MeasuredValueSequence/Item/NumericValue[../../../ConceptNameCodeSequence/Item/CodeValue = '121033']"/>
                            <xsl:value-of select="concat(' ', $DICOM/ContentSequence/Item/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning[../../../../../ConceptNameCodeSequence/Item/CodeValue = '121033'])"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/PatientAge"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Subject Species, Req: MC, Def: (L-85B00, SNM3, homo sapiens) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121034]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = '121034']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>homo sapiens</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:when>
<!--
    Fetus subject
-->
        <xsl:when test="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeValue[../../../ConceptNameCodeSequence/Item/CodeValue = '121024'] = '121026'">
            <tr>
                <th>Mother</th>
                <th>ID</th>
                <th>Number</th>
                <th>Number of Fetuses</th>
            </tr>
            <tr>
                <td align="center">
                <xsl:call-template name="formatPersonName">
                    <xsl:with-param name="PName" select="$DICOM/ContentSequence/Item/PersonName[../ConceptNameCodeSequence/Item/CodeValue = '121036']"/>
                </xsl:call-template>
                </td>
                <td align="center"><xsl:value-of select="$DICOM/ContentSequence/Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = '121030']"/></td>
                <td align="center"><xsl:value-of select="$DICOM/ContentSequence/Item/MeasuredValueSequence/Item/NumericValue[../../../ConceptNameCodeSequence/Item/CodeValue = '121037']"/></td>
                <td align="center"><xsl:value-of select="$DICOM/ContentSequence/Item/MeasuredValueSequence/Item/NumericValue[../../../ConceptNameCodeSequence/Item/CodeValue = '121038']"/></td>
            </tr>
        </xsl:when>
<!--
    Specimen subject
-->
        <xsl:when test="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeValue[../../../ConceptNameCodeSequence/Item/CodeValue = '121024'] = '121027'">
            <tr>
                <th>Accession Number</th>
                <th>Patient Context</th>
                <th>ID</th>
                <th>Type</th>
            </tr>
            <tr>
<!-- Specimen Accession Number, Req: U, Def: Specimen Accession Number (0040,050a) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121040]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = '121040']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$DICOM/SpecimenAccessionNumber"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Patient Subject Context -->
                <td align="center">
                <table width="100%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
                <tr>
                    <th style="font-size: smaller">Name</th>
                    <th style="font-size: smaller">ID</th>
                    <th style="font-size: smaller">Birth Date</th>
                    <th style="font-size: smaller">Sex</th>
                    <th style="font-size: smaller">Age</th>
                    <th style="font-size: smaller">Species</th>
                </tr>
                <tr>
                    <td align="center" style="font-size: smaller">
                        <xsl:call-template name="formatPersonName">
                            <xsl:with-param name="PName" select="$DICOM/ContentSequence/Item/PersonName[../ConceptNameCodeSequence/Item/CodeValue = '121029']"/>
                        </xsl:call-template>
                    </td>
                    <td align="center" style="font-size: smaller"><xsl:value-of select="$DICOM/ContentSequence/Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = '121030']"/></td>
                    <td align="center" style="font-size: smaller"><xsl:value-of select="$DICOM/ContentSequence/Item/Date[../ConceptNameCodeSequence/Item/CodeValue = '121031']"/></td>
                    <td align="center" style="font-size: smaller"><xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = '121032']"/></td>
                    <td align="center" style="font-size: smaller"><xsl:value-of select="$DICOM/ContentSequence/Item/MeasuredValueSequence/Item/NumericValue[../../../ConceptNameCodeSequence/Item/CodeValue = '121033']"/></td>
                    <td align="center" style="font-size: smaller"><xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = '121034']"/></td>
                </tr>
                </table>
                </td>
<!-- Specimen Identifier, Req: U, Def: Specimen Identifier (0040,0551) if a single item is present in Specimen Sequence (0040,0550) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121041]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/TextValue[../ConceptNameCodeSequence/Item/CodeValue = '121041']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="count($DICOM/SpecimenSequence/Item) = 1">
                                <xsl:value-of select="$DICOM/SpecimenSequence/Item/SpecimenIdentifier"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
<!-- Specimen Type, Req: U, Def: Specimen Type Code Sequence (0040,059a) value if a single item is present in Specimen Sequence (0040,0550) -->
                <td align="center">
                    <xsl:choose>
                        <xsl:when test="$DICOM/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 121042]">
                            <xsl:value-of select="$DICOM/ContentSequence/Item/ConceptCodeSequence/Item/CodeMeaning[../../../ConceptNameCodeSequence/Item/CodeValue = '121042']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="count($DICOM/SpecimenSequence/Item) = 1">
                                <xsl:value-of select="$DICOM/SpecimenSequence/Item/SpecimenTypeCodeSequence/Item/CodeMeaning"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:when>
    </xsl:choose>
    </table>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
