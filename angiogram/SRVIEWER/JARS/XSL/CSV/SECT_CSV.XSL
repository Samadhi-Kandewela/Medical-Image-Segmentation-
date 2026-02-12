<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2007 GE Healthcare

    SECT_CSV.XSL - Rules for adding report sections to CSV transformation.
    @author raczatt
    @date Jul 11, 2007
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- ####################################################################################################
    Template:       processSections
    Description:    Process report and template sections.
-->
<xsl:template name="processSections">
    <xsl:if test="$clinicalUse = 'false'">
        <xsl:value-of select="$messagecatalog/MSG_NOT_FOR_CLINICAL_USE/msg[@lang = $lang]"/>
        <xsl:value-of select="$LF"/>
        <xsl:value-of select="$LF"/>
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
<!-- Predecessor Documents -->
            <xsl:when test="@type = 'PREDECESSOR_DOCUMENTS'">
            </xsl:when>
<!-- Generic Message -->
            <xsl:when test="@type = 'GENERIC_MESSAGE'">
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
            </xsl:when>
<!-- Diagram -->
            <xsl:when test="@type = 'DIAGRAM'">
            </xsl:when>
<!-- Physician signature -->
            <xsl:when test="@type = 'PHYSICIAN_SIGNATURES'">
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
-->
<xsl:template name="processReportSections">

    <xsl:value-of select="$LF"/>
    <xsl:for-each select="$DICOM/ContentSequence/Item[RelationshipType = 'CONTAINS']">
        <xsl:call-template name="addContentItem">
            <xsl:with-param name="pItem" select="current()"/>
            <xsl:with-param name="pPosition" select="position()"/>
        </xsl:call-template>
        <xsl:value-of select="$LF"/>
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
        <xsl:value-of select="$messagecatalog/MSG_PATIENT_IDENTIFICATION_MISSING/msg[@lang = $lang]"/>
        <xsl:value-of select="$LF"/>
        <xsl:value-of select="$LF"/>
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
        <a name="{concat(translate(@name, ' ', ''), $pPosition)}"/>
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

<!-- ####################################################################################################
    Template:       addLogoNameAddress
    Description:    Add hospital logo name and address to the report.
-->
<xsl:template name="addLogoNameAddress">
</xsl:template>

<!-- ####################################################################################################
    Template:       addPhysicians
    Description:    Add physicians.
-->
<xsl:template name="addPhysicians">
</xsl:template>

<!-- ####################################################################################################
    Template:       addReportTitle
    Description:    Add title of the report.
-->
<xsl:template name="addReportTitle">
    <xsl:value-of select="$LF"/>
    <xsl:value-of select="$DICOM/ConceptNameCodeSequence/Item/CodeMeaning"/>
    <xsl:value-of select="$LF"/><xsl:value-of select="$LF"/><xsl:value-of select="$LF"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDSections
    Description:    Add patient information to the report in the order specified by template.
-->
<xsl:template name="addPDSections"> <xsl:param name="pPDSection"/>
                                    <xsl:param name="pPosition"/>

    <xsl:for-each select="$pPDSection/Section">
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
        <xsl:call-template name="addNPDemographics">
            <xsl:with-param name="pPDItems" select="$pPDItems"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
        <xsl:value-of select="$LF"/>
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
    <xsl:for-each select="$firstNPDFields">
        <xsl:variable name="fieldMsg" select="$messagecatalog/*[local-name() = current()/@name]"/>
        <xsl:value-of select="$fieldMsg/msg[@lang = $lang]"/><xsl:text>:,</xsl:text>
        <xsl:text>"</xsl:text>
        <xsl:call-template name="addPDValue">
            <xsl:with-param name="pPDItem" select="current()"/>
        </xsl:call-template>
        <xsl:text>",,</xsl:text>
    </xsl:for-each>
    <xsl:value-of select="$LF"/>
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
    Template:       addPDMedicalHistory
    Description:    Add patient demographics: Medical History.
-->
<xsl:template name="addPDMedicalHistory">
    <xsl:call-template name="addPDemographics">
        <xsl:with-param name="pPDItems" select="$tp/Demographics/MedicalHistory/Item[@add = 'true']"/>
    </xsl:call-template>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPDPhysicianInfo
    Description:    Add patient demographics: Physician Info.
-->
<xsl:template name="addPDPhysicianInfo">
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
        <xsl:if test="$tpCompFlag/@add = 'true'">
            <xsl:value-of select="$messagecatalog/LBL_COMPLETION_FLAG/msg[@lang = $lang]"/><xsl:text>:,</xsl:text>
            <xsl:value-of select="$DICOM/CompletionFlag"/><xsl:text>,,</xsl:text>
        </xsl:if>
<!-- Verification Flag -->
        <xsl:if test="$tpVerifFlag/@add = 'true'">
            <xsl:value-of select="$messagecatalog/LBL_VERIFICATION_FLAG/msg[@lang = $lang]"/><xsl:text>:,</xsl:text>
            <xsl:value-of select="$DICOM/VerificationFlag"/>
        </xsl:if>
        <xsl:value-of select="$LF"/>
    </xsl:if>
    <xsl:value-of select="$LF"/>
</xsl:template>

<!-- ####################################################################################################
    Template:       addGenericMessage
    Description:    Add Generic Message section from the template to the report.
-->
<xsl:template name="addGenericMessage"> <xsl:param name="pGenericMessage"/>
    <xsl:if test="$pGenericMessage/Add">
        <xsl:value-of select="$pGenericMessage/Title"/>
        <xsl:value-of select="$LF"/>
        <xsl:value-of select="$pGenericMessage/Text"/>
        <xsl:value-of select="$LF"/>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>