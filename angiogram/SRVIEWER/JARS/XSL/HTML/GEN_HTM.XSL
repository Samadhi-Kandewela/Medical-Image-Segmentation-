<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2005 GE Healthcare

    GEN_HTM.XSL     :   Generic and commonly used XSLT temaplates for HTML output.

    Author          :   Attila RACZ
    Last modified on:   Jan 12, 2005
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../GEN.XSL"/>


<!-- ####################################################################################################
    Template:       addHTMLHead
    Description:    Adds <head> to HTML page.
-->
<xsl:template name="addHTMLHead">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title>
            <xsl:call-template name="addHTMLTitle"/>
        </title>
        <style type="text/css">
            h2 {color: #9999CC}
        </style>
        <xsl:call-template name="addJavaScript"/>
    </head>
</xsl:template>

<!-- ####################################################################################################
    Template:       addHTMLBody
    Description:    Adds <body> to HTML page.
-->
<xsl:template name="addHTMLBody">
    <body style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
        <xsl:choose>
            <xsl:when test="$DICOM/@mode = 'ed'">
                <form name="form1">
                <!-- Store patient identification and SOP Instance UID fields to check consistency when submitting edited report. -->
                    <input type="hidden" id="PatientName" name="PatientName" value="{$DICOM/PatientName}"/>
                    <input type="hidden" id="PatientID" name="PatientID" value="{$DICOM/PatientID}"/>
                    <input type="hidden" id="PatientBirthDate" name="PatientBirthDate" value="{$DICOM/PatientBirthDate}"/>
                    <input type="hidden" id="PatientSex" name="PatientSex" value="{$DICOM/PatientSex}"/>
                    <input type="hidden" id="SOPInstanceUID" name="SOPInstanceUID" value="{$DICOM/SOPInstanceUID}"/>
                    <xsl:call-template name="processSections"/>
                    <input style="display: none;" type="button" name="Submit" value="{$messagecatalog/LBL_SAVE/msg[@lang = $lang]}" onclick='submitOnClick()'></input> <!-- dummy save button; for ReportGenerator-->
                </form>
                <!-- For empty questionnaires no save button shall be displayed. -->
                <xsl:if test="$DICOM/StudyInstanceUID and $DICOM/StudyInstanceUID != ''">
            <!-- layer for Save button -->
                    <div style="position:fixed; top:95%; left:95%;" title="{$messagecatalog/LBL_SAVE/msg[@lang = $lang]}">
                        <input type="image" src="../IMAGE/SAVE.GIF" name="Submit" value="{$messagecatalog/LBL_SAVE/msg[@lang = $lang]}" onclick="submitOnClick()"/>
                    </div>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processSections"/>
            </xsl:otherwise>
        </xsl:choose>
    </body>
</xsl:template>

<!-- ####################################################################################################
    Template:       addHTMLTitle
    Description:    Adds title to HTML page.
-->
<xsl:template name="addHTMLTitle">
    <xsl:value-of select="$DICOM/ConceptNameCodeSequence/Item/CodeMeaning"/>
    <xsl:if test="$DICOM/PatientName and $DICOM/PatientName != ''">
        <xsl:text> - </xsl:text>
        <xsl:call-template name="formatPersonName">
            <xsl:with-param name="PName" select="$DICOM/PatientName"/>
        </xsl:call-template>
    </xsl:if>
    <xsl:if test="($DICOM/PatientID and $DICOM/PatientID != '') or ($DICOM/PatientSex and $DICOM/PatientSex != '')">
        <xsl:text> (#</xsl:text>
        <xsl:value-of select="$DICOM/PatientID"/>
        <xsl:text>, </xsl:text>
        <xsl:call-template name="addSexText">
            <xsl:with-param name="PSex" select="$DICOM/PatientSex"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addRadio
    Description:    Add RADIO BUTTON controls (to HTML FORM)
    Parameters:
        PGroup      : Data group
        PName       : Name of the RADIO BUTTON control
        PSelection  : The selected value
-->
<xsl:template name="addRadio"> <xsl:param name="PGroup"/> <xsl:param name="PName"/>
                               <xsl:param name="PSelection"/> <xsl:param name="pID"/>
                               <xsl:param name="pWrap" select="'false'"/>

    <xsl:for-each select="$messagecatalog/*[name() = $PGroup]/item/msg[@lang = $lang]">
        <xsl:choose>
            <xsl:when test="$pWrap = 'true'">
                <div>
                <xsl:call-template name="addRadioButton">
                    <xsl:with-param name="pValue" select="current()"/>
                    <xsl:with-param name="PName" select="$PName"/>
                    <xsl:with-param name="PSelection" select="$PSelection"/>
                    <xsl:with-param name="pID" select="$pID"/>
                    <xsl:with-param name="pWrap" select="$pWrap"/>
                </xsl:call-template>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="addRadioButton">
                    <xsl:with-param name="pValue" select="current()"/>
                    <xsl:with-param name="PName" select="$PName"/>
                    <xsl:with-param name="PSelection" select="$PSelection"/>
                    <xsl:with-param name="pID" select="$pID"/>
                    <xsl:with-param name="pWrap" select="$pWrap"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- ####################################################################################################
    Template:       addRadioButton
    Description:    Add RADIO BUTTON control (to HTML FORM)
    Parameters:
        pValue      : value
        PName       : Name of the RADIO BUTTON control
        PSelection  : The selected value
-->
<xsl:template name="addRadioButton"> <xsl:param name="pValue"/> <xsl:param name="PName"/>
                                     <xsl:param name="PSelection"/> <xsl:param name="pID"/>

    <input type="radio" id="{$pID}" name="{$PName}" value="{$pValue}">
        <xsl:if test="$PSelection = $pValue">
            <xsl:attribute name="checked">checked</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="."/>
    </input>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNRadioButton
    Description:    Recursively adds RADIO BUTTON controls (to HTML FORM) organized into N columns.
    Parameters:
        pValue      : value
        PName       : Name of the RADIO BUTTON control
        PSelection  : The selected value
-->
<xsl:template name="addNRadioButton"> <xsl:param name="pItems"/> <xsl:param name="PName"/>
                                      <xsl:param name="PSelection"/> <xsl:param name="pID"/>
                                      <xsl:param name="pN"/>

    <xsl:variable name="firstNItem" select="$pItems[position() &lt;= $pN]"/>
    <tr>
    <xsl:for-each select="$firstNItem">
        <td style="vertical-align: top;">
            <input type="radio" id="{$pID}" name="{$PName}" value="{current()/msg[@lang = $lang]}">
                <xsl:if test="$PSelection = current()/msg[@lang = $lang]">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="current()/msg[@lang = $lang]"/>
            </input>
        </td>
    </xsl:for-each>
    </tr>
    <xsl:variable name="remainingItems" select="$pItems[position() &gt; $pN]"/>
<!-- Recursive call for remaining items. -->
    <xsl:if test="count($remainingItems) != 0">
        <xsl:call-template name="addNRadioButton">
            <xsl:with-param name="pItems" select="$remainingItems"/>
            <xsl:with-param name="PName" select="$PName"/>
            <xsl:with-param name="PSelection" select="$PSelection"/>
            <xsl:with-param name="pID" select="$pID"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNCheckBox
    Description:    Recursively adds CHECK BOX controls (to HTML FORM) organized into N columns.
    Parameters:
        pValue      : value
        PName       : Name of the CHECK BOX control
        PSelection  : The selected value
-->
<xsl:template name="addNCheckBox"> <xsl:param name="pItems"/> <xsl:param name="PName"/>
                                   <xsl:param name="PSelection"/> <xsl:param name="pID"/>
                                   <xsl:param name="pN"/>

    <xsl:variable name="firstNItem" select="$pItems[position() &lt;= $pN]"/>
    <tr>
    <xsl:for-each select="$firstNItem">
        <td style="vertical-align: top;">
            <input type="checkbox" id="{$pID}" name="{$PName}" value="{current()/msg[@lang = $lang]}">
                <xsl:if test="contains($PSelection, current()/msg[@lang = $lang])">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="current()/msg[@lang = $lang]"/>
            </input>
        </td>
    </xsl:for-each>
    </tr>
    <xsl:variable name="remainingItems" select="$pItems[position() &gt; $pN]"/>
<!-- Recursive call for remaining items. -->
    <xsl:if test="count($remainingItems) != 0">
        <xsl:call-template name="addNCheckBox">
            <xsl:with-param name="pItems" select="$remainingItems"/>
            <xsl:with-param name="PName" select="$PName"/>
            <xsl:with-param name="PSelection" select="$PSelection"/>
            <xsl:with-param name="pID" select="$pID"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addSelect
    Description:    Add select control (to HTML FORM)
    Parameters:
        PGroup      : Data group
        PName       : Name of the select control
        PSelection  : The selected value
-->
<xsl:template name="addSelect"> <xsl:param name="PGroup"/> <xsl:param name="PName"/>
                                <xsl:param name="PSelection"/> <xsl:param name="PID"/>
                                <xsl:param name="POnChange"/>

    <select name="{$PName}" id="{$PID}">
        <xsl:if test="$POnChange">
            <xsl:attribute name="onchange"><xsl:value-of select="$POnChange"/>(this)</xsl:attribute>
        </xsl:if>
        <xsl:for-each select="$messagecatalog/*[name() = $PGroup]/item/msg[@lang = $lang]">
            <option value="{.}">
                <xsl:if test="$PSelection = .">
                    <xsl:attribute name="selected"/>
                </xsl:if>
                <xsl:value-of select="."/>
            </option>
        </xsl:for-each>
    </select>
</xsl:template>

<!-- ####################################################################################################
    Template:       addHeight2HTML
    Description:    Add height and convert from SI to English based on template.
    Parameters:
        pWeight : Value of height
-->
<xsl:template name="addHeight2HTML"> <xsl:param name="pHeight"/>
    <xsl:choose>
        <xsl:when test="$DICOM/@mode = 'ed' and (not($pHeight) or $pHeight = '')">
            <xsl:choose>
                <xsl:when test="$tp/UnitsOfMeasurement/@name = 'EN'">
                    <xsl:variable name="heightInFt">
                        <xsl:if test="$pHeight !=''">
                            <xsl:value-of select="round($pHeight * $RATE_m_ft)"/>
                        </xsl:if>
                    </xsl:variable>
                    <input type="text" id="PatientSize" name="PatientSize" size="8" value="{$heightInFt}" onFocus="store(value)" onKeyUp="validateNum(this)"/> ft
                </xsl:when>
                <xsl:otherwise>
                    <input type="text" id="PatientSize" name="PatientSize" size="8" value="{$pHeight}" onFocus="store(value)" onKeyUp="validateNum(this)"/> m
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="addHeight">
                <xsl:with-param name="pHeight" select="$pHeight"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addWeight2HTML
    Description:    Add weight and convert from SI to English based on template.
    Parameters:
        pWeight : Value of weight
-->
<xsl:template name="addWeight2HTML"> <xsl:param name="pWeight"/>
    <xsl:choose>
        <xsl:when test="$DICOM/@mode = 'ed' and (not($pWeight) or $pWeight = '')">
            <xsl:choose>
                <xsl:when test="$tp/UnitsOfMeasurement/@name = 'EN'">
                    <xsl:variable name="weightInLbs">
                        <xsl:if test="$pWeight !=''">
                            <xsl:value-of select="round($pWeight * $RATE_kg_lb)"/>
                        </xsl:if>
                    </xsl:variable>
                    <input type="text" id="PatientWeight" name="PatientWeight" size="8" value="{$weightInLbs}" onFocus="store(value)" onKeyUp="validateNum(this)"/> lb
                </xsl:when>
                <xsl:otherwise>
                    <input type="text" id="PatientWeight" name="PatientWeight" size="8" value="{$pWeight}" onFocus="store(value)" onKeyUp="validateNum(this)"/> kg
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="addWeight">
                <xsl:with-param name="pWeight" select="$pWeight"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addEthnicGroup
    Description:    Adds Body Surface Area.
    Parameters:
-->
<xsl:template name="addEthnicGroup">
    <xsl:choose>
        <xsl:when test="$DICOM/@mode = 'ed' and (not($DICOM/EthnicGroup) or $DICOM/EthnicGroup = '')">
            <input type="text" id="{@id}" name="EthnicGroup" size="16" maxlength="16" value="{$DICOM/EthnicGroup}" onBlur="validateChar(this)"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$DICOM/EthnicGroup"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addBSA
    Description:    Adds Body Surface Area.
    Parameters:
        pWeight : Value of weight
        pHeight : Value of height
-->
<xsl:template name="addBSA"> <xsl:param name="pWeight" select="$DICOM/PatientWeight"/>
                             <xsl:param name="pHeight" select="$DICOM/PatientSize"/>
    <xsl:if test="$pWeight != '' and $pHeight != ''">
        <span title="BSA = 0.20247 x Height(m)^0.725 x Weight(kg)^0.425">
        <xsl:call-template name="calculateBSA">
            <xsl:with-param name="pWeight" select="$pWeight"/>
            <xsl:with-param name="pHeight" select="$pHeight"/>
        </xsl:call-template>
        </span>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addBMI
    Description:    Adds Body Mass Index.
    Parameters:
        pWeight : Value of weight
        pHeight : Value of height
-->
<xsl:template name="addBMI"> <xsl:param name="pWeight" select="$DICOM/PatientWeight"/>
                             <xsl:param name="pHeight" select="$DICOM/PatientSize"/>
    <xsl:if test="$pWeight != '' and $pHeight != ''">
        <span title="BMI = Weight(kg) / Height(m)^2">
        <xsl:call-template name="calculateBMI">
            <xsl:with-param name="pWeight" select="$pWeight"/>
            <xsl:with-param name="pHeight" select="$pHeight"/>
        </xsl:call-template>
        </span>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addJavaScript
    Description:    Add JavaScript functions.
-->
<xsl:template name="addJavaScript">
    <xsl:if test="$DICOM/@mode = 'ed'">
    <script type="text/javascript">
        var MSG_FILL_VERIFIER = "<xsl:value-of select="$messagecatalog/MSG_FILL_VERIFIER/msg[@lang = $lang]"/>";
        var MSG_LEAVE_BLANK = "<xsl:value-of select="$messagecatalog/MSG_LEAVE_BLANK/msg[@lang = $lang]"/>"
        var MSG_WRONG_DATE_FORMAT = "<xsl:value-of select="$messagecatalog/MSG_WRONG_DATE_FORMAT/msg[@lang = $lang]"/>"
        var LBL_SAVE = "<xsl:value-of select="$messagecatalog/LBL_SAVE/msg[@lang = $lang]"/>"
    </script>
    <script type="text/javascript" src="../IMAGE/EDIT.JS">
<!-- Add content to <script> tag to avoid Element Minimization which doesn't display in IE6. -->
        <xsl:text> </xsl:text>
    </script>
    </xsl:if>

    <script type="text/javascript" src="../IMAGE/GEN.JS">
<!-- Add content to <script> tag to avoid Element Minimization which doesn't display in IE6. -->
        <xsl:text> </xsl:text>
    </script>
</xsl:template>

<!-- ####################################################################################################
    Template:       break2NewLine
    Description:    Break down $pNewLineSeparator separated string and add <br/>.
    Parameters:
        pText 	:  Text to break down.
        pNewLineSeparator	: new line character
-->
<xsl:template name="break2NewLine">
    <xsl:param name="pText"/>
    <xsl:param name="pNewLineSeparator" select="$NewLineSeparator"/>

    <xsl:choose>
        <xsl:when test="contains($pText, $pNewLineSeparator)">
            <xsl:value-of select="substring-before($pText, $pNewLineSeparator)"/>
            <br/>
            <xsl:call-template name="break2NewLine">
                <xsl:with-param name="pText" select="substring-after($pText, $pNewLineSeparator)"/>
                <xsl:with-param name="pNewLineSeparator" select="$pNewLineSeparator"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$pText"/>
            <br/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addValue
    Description:    Add the value of content item depending on the value type to HTML.
    Parameters:
        pCurrent :  The current node of processing
        pUnit    :  Enumerated values: cv: Code Value, cm: Code Meaning of Measurement Units Code Sequence, none: don't add unit.
-->

<xsl:template name="addValue"> <xsl:param name="pCurrent"/>
                               <xsl:param name="pIsEditable" select="'true'"/>
                               <xsl:param name="pMultiLine" select="'true'"/>
                               <xsl:param name="pUnit" select="'cv'"/>
                               <xsl:param name="pPattern" select="$numberFormat"/>

    <xsl:choose>
        <xsl:when test="$pCurrent/ValueType_TEXT or $pCurrent/ValueType = 'TEXT'">
            <span title="{$pCurrent/ConceptNameCodeSequence/Item/CodeMeaning}">
                <xsl:choose>
                    <xsl:when test="$DICOM/@mode = 'ed' and $pIsEditable = 'true'">
                        <xsl:choose>
                            <xsl:when test="$pMultiLine = 'true'">
                                <textarea wrap="hard" style="width: 100%;" id="{$pCurrent/@id}" name="TextValue" rows="{ceiling(string-length($pCurrent/TextValue) div 80) + 1}" onBlur="validateChar(this)">
                                    <xsl:value-of select="$pCurrent/TextValue"/>
                                    <xsl:text> </xsl:text>
                                </textarea>
                            </xsl:when>
                            <xsl:otherwise>
                                <input type="text" id="{$pCurrent/@id}" name="TextValue" size="24" value="{$pCurrent/TextValue}" onBlur="validateChar(this)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="contains($pCurrent/TextValue, $LF)">
                                <xsl:call-template name="break2NewLine">
                                    <xsl:with-param name="pText" select="$pCurrent/TextValue"/>
                                    <xsl:with-param name="pNewLineSeparator" select="$LF"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$pCurrent/TextValue"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_CODE or $pCurrent/ValueType = 'CODE'">
            <xsl:call-template name="addCODEValue">
                <xsl:with-param name="pCurrent" select="$pCurrent"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_NUM or $pCurrent/ValueType = 'NUM'">
            <xsl:call-template name="addNUMValue">
                <xsl:with-param name="pCurrent" select="$pCurrent"/>
                <xsl:with-param name="pPattern" select="$pPattern"/>
                <xsl:with-param name="pUnit" select="$pUnit"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_PNAME or $pCurrent/ValueType = 'PNAME'">
            <xsl:choose>
                <xsl:when test="$DICOM/@mode = 'ed' and $pIsEditable = 'true' and $pCurrent/PersonName = ''">
                    <input type="text" id="{$pCurrent/@id}" name="PersonName" title="Family^Given^Middle^Prefix^Suffix" size="{string-length($pCurrent/PersonName) + 1}" value="{$pCurrent/PersonName}" maxlength="64" onBlur="validateChar(this)"/>
                </xsl:when>
                <xsl:otherwise>
                    <span title="{$pCurrent/PersonName}">
                        <xsl:call-template name="formatPersonName">
                            <xsl:with-param name="PName" select="$pCurrent/PersonName"/>
                        </xsl:call-template>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_DATE or $pCurrent/ValueType = 'DATE'">
            <xsl:call-template name="addDATEValue">
                <xsl:with-param name="pCurrent" select="$pCurrent"/>
                <xsl:with-param name="pIsEditable" select="$pIsEditable"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_TIME or $pCurrent/ValueType = 'TIME'">
            <span title="{concat($pCurrent/Time, ' (', $DICOM/@timeFormat, ')')}">
                <xsl:call-template name="formatTime">
                    <xsl:with-param name="pTime" select="$pCurrent/Time"/>
                </xsl:call-template>
            </span>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_DATETIME or $pCurrent/ValueType = 'DATETIME'">
            <span title="{concat($pCurrent/DateTime, ' (', $DICOM/@dateFormat, ', ', $DICOM/@timeFormat, ')')}">
                <xsl:call-template name="formatDateTime">
                    <xsl:with-param name="pDTime" select="$pCurrent/DateTime"/>
                </xsl:call-template>
            </span>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_UIDREF or $pCurrent/ValueType = 'UIDREF'">
            <xsl:value-of select="$pCurrent/UID"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_COMPOSITE or $pCurrent/ValueType = 'COMPOSITE'">
            <xsl:value-of select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID"/>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_IMAGE or $pCurrent/ValueType = 'IMAGE'">
            <xsl:call-template name="addImage">
                <xsl:with-param name="pSOPClassUID" select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPClassUID"/>
                <xsl:with-param name="pSOPInstUID" select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID"/>
                <xsl:with-param name="pIconImageSeq" select="$pCurrent/ReferencedSOPSequence/Item/IconImageSequence"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$pCurrent/ValueType_WAVEFORM or $pCurrent/ValueType = 'WAVEFORM'">
            <xsl:value-of select="$pCurrent/ReferencedSOPSequence/Item/ReferencedSOPInstanceUID"/>
        </xsl:when>
    </xsl:choose>

</xsl:template>

<!-- ####################################################################################################
    Template:       addCODEValue
    Description:    Adds Code Meaning and "(CV, CSD, CM)" in tooltip.
    Parameters:
        pCurrent :  CODE content item
-->
<xsl:template name="addCODEValue"> <xsl:param name="pCurrent"/>
    <span title="{concat('(', $pCurrent/ConceptCodeSequence/Item/CodeValue, ', ', $pCurrent/ConceptCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/ConceptCodeSequence/Item/CodeMeaning, ')')}">
        <xsl:value-of select="$pCurrent/ConceptCodeSequence/Item/CodeMeaning"/>
    </span>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNUMValue
    Description:    Adds Code Meaning and "(CV, CSD, CM)" in tooltip.
    Parameters:
        pCurrent :  NUM content item
-->
<xsl:template name="addNUMValue">
    <xsl:param name="pCurrent"/>
    <xsl:param name="pPattern"/>
    <xsl:param name="pUnit"/>

    <span title="{concat('(', $pCurrent/ConceptNameCodeSequence/Item/CodeValue, ', ', $pCurrent/ConceptNameCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/ConceptNameCodeSequence/Item/CodeMeaning, '): ', $pCurrent/MeasuredValueSequence/Item/NumericValue, ' ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue)}">
        <xsl:call-template name="formatNumericValue">
            <xsl:with-param name="pNum" select="$pCurrent/MeasuredValueSequence/Item/NumericValue"/>
            <xsl:with-param name="pPattern" select="$pPattern"/>
        </xsl:call-template>
    </span>
    <xsl:if test="$pUnit = 'cv' or $pUnit = 'cm'">
        <span title="{concat('(', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodingSchemeDesignator, ', ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning, ')')}">
            <xsl:choose>
                <xsl:when test="$pUnit = 'cv'">
                    <xsl:if test="$pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue != '1'">
                        <xsl:value-of select="concat(' ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeValue)"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$pUnit = 'cm'">
                    <xsl:value-of select="concat(' ', $pCurrent/MeasuredValueSequence/Item/MeasurementUnitsCodeSequence/Item/CodeMeaning)"/>
                </xsl:when>
            </xsl:choose>
        </span>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addDATEValue
    Description:    Adds DATE item formatting its value to YYYY-MM-DD.
    Parameters:
        pCurrent :  DATE content item
-->
<xsl:template name="addDATEValue"> <xsl:param name="pCurrent"/>
                                   <xsl:param name="pIsEditable" select="'true'"/>
    <xsl:variable name="date">
        <xsl:call-template name="toXSDdate">
            <xsl:with-param name="pDate" select="$pCurrent/Date"/>
        </xsl:call-template>
    </xsl:variable>
    <span title="{concat($pCurrent/Date, ' (', $DICOM/@dateFormat, ')')}">
        <xsl:call-template name="formatDate">
            <xsl:with-param name="pDate" select="$date"/>
        </xsl:call-template>
    </span>
</xsl:template>

<xsl:template name="addImage"> <xsl:param name="pSOPClassUID"/> <xsl:param name="pSOPInstUID"/> <xsl:param name="pIconImageSeq"/>
    <a>
    <xsl:attribute name="href">javascript:showImageByUID('<xsl:value-of select="$pSOPInstUID"/>')</xsl:attribute>
    <xsl:attribute name="title">
        <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = $pSOPClassUID]/@abbrev"/>
    </xsl:attribute>
    <img>
    <xsl:attribute name="alt">
        <xsl:value-of select="$messagecatalog/SOPClasses/SOPClass[@uid = $pSOPClassUID]/@abbrev"/>
    </xsl:attribute>
    <xsl:choose>
        <xsl:when test="$pIconImageSeq">
            <xsl:attribute name="src">
                <xsl:value-of select="concat('../IMAGE/', $pSOPInstUID, '_ico.png')"/>
            </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
            <xsl:attribute name="src">
                <xsl:value-of select="concat('../IMAGE/', $pSOPInstUID, '.jpg')"/>
            </xsl:attribute>
            <xsl:if test="$tp/Images/HTMLImageSize/@original != 'true'">
                <xsl:attribute name="width">
                    <xsl:value-of select="concat($tp/Images/HTMLImageSize, $tp/Images/HTMLImageSize/@unit)"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
    </img>
    </a>
</xsl:template>

<!-- ####################################################################################################
    Template:       addPatientQuestions
    Description:    Adds Patient Questions.
    Parameters:
        pItem    :  (PQ-0110, 99GEMS, Patient Questions) content item
-->
<xsl:template name="addPatientQuestions"> <xsl:param name="pItem"/>

    <table width="100%" style="border-collapse: collapse; border-style: solid; border-width: thin; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
        <xsl:for-each select="$pItem/ContentSequence/Item">
        <xsl:variable name="answer" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'PQ-0130' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_GEMS]"/>
        <tr>
            <td style="width: 50%; border-style: solid; border-width: thin; font-weight: bold;">
                <xsl:choose>
                    <xsl:when test="current()/ValueType_CODE or current()/ValueType = 'CODE'">
    <!-- Display the (121051, DCM, Equivalent meaning of value) child. -->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = '121051' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
    <!-- Keep for older questionnaires that were saved as TEXT items with code in the concept name e.g.: (PQ-1000, 99GEMS, LBL_REASON_FOR_EXAM) -->
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()"/>
                            <xsl:with-param name="pIsEditable" select="'false'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td style="width: 50%; border-style: solid; border-width: thin;">
            <xsl:variable name="cv">
                <xsl:choose>
                    <xsl:when test="current()/ValueType_CODE or current()/ValueType = 'CODE'">
                        <xsl:value-of select="current()/ConceptCodeSequence/Item/CodeValue"/>
                    </xsl:when>
                    <xsl:otherwise>
    <!-- Keep for older questionnaires that were saved as TEXT items with code in the concept name e.g.: (PQ-1000, 99GEMS, LBL_REASON_FOR_EXAM) -->
                        <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodeValue"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="csd">
                <xsl:choose>
                    <xsl:when test="current()/ValueType_CODE or current()/ValueType = 'CODE'">
                        <xsl:value-of select="current()/ConceptCodeSequence/Item/CodingSchemeDesignator"/>
                    </xsl:when>
                    <xsl:otherwise>
    <!-- Keep for older questionnaires that were saved as TEXT items with code in the concept name e.g.: (PQ-1000, 99GEMS, LBL_REASON_FOR_EXAM) -->
                        <xsl:value-of select="current()/ConceptNameCodeSequence/Item/CodingSchemeDesignator"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
    <!-- (PQ-1000, 99GEMS, Reason for exam) -->
    <!-- (PQ-1010, 99GEMS, Pre-exam comments) -->
                <xsl:when test="$csd = $CSD_GEMS and ($cv = 'PQ-1000' or $cv = 'PQ-1010')">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$answer"/>
                        <xsl:with-param name="pMultiLine" select="'true'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1020, 99GEMS, Currently smoking cigarettes) -->
    <!-- (PQ-1100, 99GEMS, Has patient ever used smokeless tobacco products?) -->
    <!-- (PQ-1140, 99GEMS, Do/did patient's parents smoke?) -->
    <!-- (PQ-1150, 99GEMS, Does patient's spouse smoke?) -->
    <!-- (PQ-1230, 99GEMS, Has the patient ever been told that he/she had an abnormal chest x-ray?) -->
    <!-- (PQ-1250, 99GEMS, Has patient ever had a positive skin test for tuberculosis?) -->
    <!-- (PQ-1270, 99GEMS, Does the patient have a history of chronic or frequent bronchitis?) -->
    <!-- (PQ-1280, 99GEMS, Does the patient have a chronic smoker's cough?) -->
    <!-- (PQ-1290, 99GEMS, Has the patient had a fungal infection of the lungs?) -->
    <!-- (PQ-1300, 99GEMS, Has the patient ever been diagnosed with emphysema?) -->
                <xsl:when test="$csd = $CSD_GEMS and ($cv = 'PQ-1020' or $cv = 'PQ-1100' or $cv = 'PQ-1140' or $cv = 'PQ-1150' or $cv = 'PQ-1230' or $cv = 'PQ-1250' or $cv = 'PQ-1270' or $cv = 'PQ-1280' or $cv = 'PQ-1290' or $cv = 'PQ-1300')">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_BOOL</xsl:with-param>
                        <xsl:with-param name="pType" select="'radio'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1050, 99GEMS, How many times has patient tried to quit smoking?) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1050'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_SMOKING_QUIT_TRIAL_NR</xsl:with-param>
                        <xsl:with-param name="pType" select="'radio'"/>
                        <xsl:with-param name="pN" select="'6'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1060, 99GEMS, How many pack(s) a day has the patient smoked?) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1060'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_PACKS_PER_DAY</xsl:with-param>
                        <xsl:with-param name="pType" select="'radio'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1090, 99GEMS, Select other tobacco products used) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1090'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_OTHER_TOBACCO_USED</xsl:with-param>
                        <xsl:with-param name="pType" select="'checkbox'"/>
                        <xsl:with-param name="pN" select="'4'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1110, 99GEMS, Has patient been exposed to significant second-hand smoke in his/her home?) -->
    <!-- (PQ-1120, 99GEMS, Has patient been exposed to significant second-hand smoke in his/her workplace?) -->
    <!-- (PQ-1130, 99GEMS, Has patient been exposed to significant second-hand smoke in social settings?) -->
    <!-- (PQ-1160, 99GEMS, Has patient ever worked with asbestos?) -->
    <!-- (PQ-1170, 99GEMS, Has patient ever worked in a shipyard or with pipe insulation?) -->
    <!-- (PQ-1180, 99GEMS, Has patient ever worked with heavy metals such as lead, arsenic, or mercury?) -->
    <!-- (PQ-1190, 99GEMS, Has patient ever worked in a mine?) -->
    <!-- (PQ-1200, 99GEMS, Has patient had significant exposure to radon gas?) -->
                <xsl:when test="$csd = $CSD_GEMS and ($cv = 'PQ-1110' or $cv = 'PQ-1120' or $cv = 'PQ-1130' or $cv = 'PQ-1160' or $cv = 'PQ-1170' or $cv = 'PQ-1180' or $cv = 'PQ-1190' or $cv = 'PQ-1200')">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_SECOND_HAND_SMOKE</xsl:with-param>
                        <xsl:with-param name="pType" select="'radio'"/>
                        <xsl:with-param name="pN" select="'4'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1240, 99GEMS, If so, what was the diagnosis?) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1240'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_ABNORMAL_CHEST_X-RAY_DIAG</xsl:with-param>
                        <xsl:with-param name="pType" select="'checkbox'"/>
                        <xsl:with-param name="pN" select="'4'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1260, 99GEMS, Does patient have a history of asthma?) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1260'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_ASTHMA_HISTORY</xsl:with-param>
                        <xsl:with-param name="pType" select="'radio'"/>
                        <xsl:with-param name="pN" select="'4'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1320, 99GEMS, Conditions for which the patient has seen a health care provider or taken medication in the past five years) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1320'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_CONDITIONS</xsl:with-param>
                        <xsl:with-param name="pType" select="'checkbox'"/>
                        <xsl:with-param name="pN" select="'3'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-1330, 99GEMS, Current living location) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-1330'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_CURRENT_LIVING_LOCATION</xsl:with-param>
                        <xsl:with-param name="pType" select="'radio'"/>
                        <xsl:with-param name="pN" select="'3'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-2000, 99GEMS, Cancer diagnosis) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-2000'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_CANCER_DIAGNOSIS</xsl:with-param>
                        <xsl:with-param name="pType" select="'select'"/>
                        <xsl:with-param name="pN" select="'3'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (G-F150, SRT, T category) -->
                <xsl:when test="$csd = $CSD_SNOMED_RT and $cv = 'G-F150'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_T_CATEGORY</xsl:with-param>
                        <xsl:with-param name="pType" select="'select'"/>
                        <xsl:with-param name="pN" select="'5'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (R-40030, SRT, N category) -->
                <xsl:when test="$csd = $CSD_SNOMED_RT and $cv = 'R-40030'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_N_CATEGORY</xsl:with-param>
                        <xsl:with-param name="pType" select="'select'"/>
                        <xsl:with-param name="pN" select="'5'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (R-40031, SRT, M category) -->
                <xsl:when test="$csd = $CSD_SNOMED_RT and $cv = 'R-40031'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_M_CATEGORY</xsl:with-param>
                        <xsl:with-param name="pType" select="'select'"/>
                        <xsl:with-param name="pN" select="'5'"/>
                    </xsl:call-template>
                </xsl:when>
    <!-- (PQ-2020, 99GEMS, Stage grouping) -->
                <xsl:when test="$csd = $CSD_GEMS and $cv = 'PQ-2020'">
                    <xsl:call-template name="addAnswer">
                        <xsl:with-param name="pAnswer" select="$answer"/>
                        <xsl:with-param name="pGroup">LBL_STAGE_GROUPING</xsl:with-param>
                        <xsl:with-param name="pType" select="'select'"/>
                        <xsl:with-param name="pN" select="'5'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
    <!-- (PQ-0120, 99GEMS, Question) custom questions are displayed with multi-line control while others are displayed with single-line control. -->
                    <xsl:variable name="isMultiLine">
                        <xsl:choose>
                            <xsl:when test="$csd = $CSD_GEMS and ($cv = 'PQ-0120' or $cv = 'PQ-2010' or $cv = 'PQ-2030' or $cv = 'PQ-2040' or $cv = 'PQ-2050' or $cv = 'PQ-2060' or $cv = 'PQ-2070' or $cv = 'PQ-2080')">true</xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$answer"/>
                        <xsl:with-param name="pMultiLine" select="$isMultiLine"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            </td>
        </tr>
        </xsl:for-each>
    </table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addAnswer
    Description:    Adds answer with radio buttons in edit mode.
    Parameters:
        pAnswer    :  (PQ-0130, 99GEMS, Answer) content item
-->
<xsl:template name="addAnswer"> <xsl:param name="pAnswer"/>
                                <xsl:param name="pGroup"/>
                                <xsl:param name="pType"/>
                                <xsl:param name="pN" select="'3'"/>

    <xsl:variable name="items" select="$messagecatalog/*[name() = $pGroup]/item"/>
    <xsl:choose>
        <xsl:when test="$DICOM/@mode = 'ed'">
            <xsl:if test="$items">
                <table style="width: 100%; border-style: none; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
                    <xsl:choose>
                        <xsl:when test="$pType = 'radio'">
                            <xsl:call-template name="addNRadioButton">
                                <xsl:with-param name="pItems" select="$items"/>
                                <xsl:with-param name="PName" select="concat('TextValue', $pAnswer/@id)"/>
                                <xsl:with-param name="PSelection" select="$pAnswer/TextValue"/>
                                <xsl:with-param name="pID" select="$pAnswer/@id"/>
                                <xsl:with-param name="pN" select="$pN"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$pType = 'checkbox'">
                            <xsl:call-template name="addNCheckBox">
                                <xsl:with-param name="pItems" select="$items"/>
                                <xsl:with-param name="PName" select="concat('TextValue', $pAnswer/@id)"/>
                                <xsl:with-param name="PSelection" select="$pAnswer/TextValue"/>
                                <xsl:with-param name="pID" select="$pAnswer/@id"/>
                                <xsl:with-param name="pN" select="$pN"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$pType = 'select'">
                            <tr>
                                <td>
                                    <xsl:call-template name="addSelect">
                                        <xsl:with-param name="PGroup" select="$pGroup"/>
                                        <xsl:with-param name="PName" select="concat('TextValue', $pAnswer/@id)"/>
                                        <xsl:with-param name="PSelection" select="$pAnswer/TextValue"/>
                                        <xsl:with-param name="PID" select="$pAnswer/@id"/>
                                    </xsl:call-template>
                                </td>
                            </tr>
                        </xsl:when>
                    </xsl:choose>
                </table>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$DICOM/StudyInstanceUID and $DICOM/StudyInstanceUID != ''">
                    <xsl:call-template name="addValue">
                        <xsl:with-param name="pCurrent" select="$pAnswer"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$items">
                        <table style="width: 100%; border-style: none; font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
                            <xsl:call-template name="addNAnswers">
                                <xsl:with-param name="pItems" select="$items"/>
                                <xsl:with-param name="pN" select="$pN"/>
                            </xsl:call-template>
                        </table>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNAnswers
    Description:    Recursively adds answers organized into N columns.
    Parameters:
        pItems      : Possible answers.
        pN          : # of columns
-->
<xsl:template name="addNAnswers"> <xsl:param name="pItems"/> <xsl:param name="pN"/>

    <xsl:variable name="firstNItem" select="$pItems[position() &lt;= $pN]"/>
    <tr>
    <xsl:for-each select="$firstNItem">
        <td style="vertical-align: top;">
            <xsl:choose>
                <xsl:when test="current()/msg[@lang = $lang]">
                    <xsl:value-of select="current()/msg[@lang = $lang]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="current()/msg[@lang = 'en']"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:for-each>
    </tr>

    <xsl:variable name="remainingItems" select="$pItems[position() &gt; $pN]"/>
<!-- Recursive call for remaining items. -->
    <xsl:if test="count($remainingItems) != 0">
        <xsl:call-template name="addNAnswers">
            <xsl:with-param name="pItems" select="$remainingItems"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addItemWithGeneric
    Description:    Add content item to report with generic tree traversal.
    Parameters:
        pItem    :  Content item to add.
-->
<xsl:template name="addItemWithGeneric"> <xsl:param name="pItem"/>

<!-- Add value of different Value Types except CONTAINER. -->
    <xsl:if test="not($pItem/ValueType_CONTAINER) or ($pItem/ValueType and $pItem/ValueType != 'CONTAINER')">
        <xsl:call-template name="addItemContent">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
    </xsl:if>

<!-- Process nested ContentSequences. -->
    <xsl:if test="$pItem/ContentSequence">
        <xsl:call-template name="addRecursiveContent">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addRecursiveContent
    Description:    Add content in table rows with recursion.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->
<xsl:template name="addRecursiveContent"> <xsl:param name="pLevel"/> <xsl:param name="pCurrent"/>

    <table width="100%" border="0">
    <xsl:for-each select="$pCurrent/ContentSequence/Item">
    <tr>
        <td align="right">
        <xsl:call-template name="addItemContent">
            <xsl:with-param name="pLevel" select="$pLevel"/>
            <xsl:with-param name="pCurrent" select="current()"/>
        </xsl:call-template>
        <xsl:if test="current()/ContentSequence/Item">
            <xsl:call-template name="addRecursiveContent">
                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                <xsl:with-param name="pCurrent" select="current()"/>
            </xsl:call-template>
        </xsl:if>
        </td>
    </tr>
    </xsl:for-each>
    </table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addItemContent
    Description:    Add content in table row.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->
<xsl:template name="addItemContent"> <xsl:param name="pLevel"/>
                                     <xsl:param name="pCurrent"/>

    <!-- COL_REDUCE_FACTOR is float value in 0..1 range. Here need to convert to %. -->
    <table border="0" width="{100 - ($pLevel * $COL_REDUCE_FACTOR * 100)}%" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
    <tr>
        <td style="width: 30%; text-align:left; vertical-align: top;">
        <!--xsl:if test="RelationshipType != 'CONTAINS'">
            <i><xsl:value-of select="RelationshipType"/>:</i>
            <xsl:text> </xsl:text>
        </xsl:if-->
            <b><xsl:value-of select="$pCurrent/ConceptNameCodeSequence/Item/CodeMeaning"/></b>
        </td>
        <td style="text-align:left; vertical-align: top;">
            <xsl:call-template name="addValue">
                <xsl:with-param name="pCurrent" select="$pCurrent"/>
            </xsl:call-template>
        </td>
    </tr>
    </table>
</xsl:template>

<!-- ####################################################################################################
    Template:       addImages
    Description:    Adds Image captures organized into a table of N columns.
    Parameters:
        pImages   :  IMAGE content items.
        pN        :  # of columns images displayed across.
-->
<xsl:template name="addImages">
    <xsl:param name="pImages"/>
    <xsl:param name="pN" select="$imgColumns"/>
    <xsl:param name="pWithName" select="'true'"/>
    <xsl:param name="pWithComment" select="'true'"/>

    <xsl:if test="$pImages">
        <table width="100%" border="0" style="font-family: {$tp/Font/@type}; font-size: {$tp/Font/@size}pt">
            <xsl:call-template name="addNImages">
                <xsl:with-param name="pImages" select="$pImages"/>
                <xsl:with-param name="pN" select="$pN"/>
                <xsl:with-param name="pWithName" select="$pWithName"/>
                <xsl:with-param name="pWithComment" select="$pWithComment"/>
            </xsl:call-template>
        </table>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addNImages
    Description:    Recursively adds images organized into N columns.
    Parameters:
        pImages   :  IMAGE content items.
        pN        :  # of columns images displayed across.
-->
<xsl:template name="addNImages">
    <xsl:param name="pImages"/>
    <xsl:param name="pN" select="$imgColumns"/>
    <xsl:param name="pWithName" select="'true'"/>
    <xsl:param name="pWithComment" select="'true'"/>

    <xsl:variable name="firstNImages" select="$pImages[position() &lt;= $pN]"/>
    <tr>
        <xsl:for-each select="$firstNImages">
            <td style="width: {100 div $pN}%; text-align: center">
                <xsl:call-template name="addImageCapture">
                    <xsl:with-param name="pImage" select="current()"/>
                    <xsl:with-param name="pWithName" select="$pWithName"/>
                    <xsl:with-param name="pWithComment" select="$pWithComment"/>
                </xsl:call-template>
            </td>
        </xsl:for-each>
        <xsl:call-template name="addEmptyCells">
            <xsl:with-param name="pTotalCols" select="$pN"/>
            <xsl:with-param name="pN" select="$pN - count($firstNImages)"/>
        </xsl:call-template>
    </tr>
    <xsl:variable name="remainingImages" select="$pImages[position() &gt; $pN]"/>
    <xsl:if test="count($remainingImages) != 0">
        <xsl:call-template name="addNImages">
            <xsl:with-param name="pImages" select="$remainingImages"/>
            <xsl:with-param name="pN" select="$pN"/>
            <xsl:with-param name="pWithName" select="$pWithName"/>
            <xsl:with-param name="pWithComment" select="$pWithComment"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addImageCapture
    Description:    Add one image optionally with name and comment.
    Parameters:
        pImage   :  Image item.
-->
<xsl:template name="addImageCapture"> <xsl:param name="pImage"/>
                                      <xsl:param name="pWithName" select="'true'"/>
                                      <xsl:param name="pWithComment" select="'true'"/>
<!-- Image -->
    <xsl:call-template name="addValue">
        <xsl:with-param name="pCurrent" select="$pImage"/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="addEmptyCells"> <xsl:param name="pTotalCols"/>
                                    <xsl:param name="pN"/>
    <xsl:if test="$pN &gt; 0">
        <td style="width: {100 div $pTotalCols}%; text-align: center"/>
        <xsl:if test="$pN &gt; 1">
            <xsl:call-template name="addEmptyCells">
                <xsl:with-param name="pTotalCols" select="$pTotalCols"/>
                <xsl:with-param name="pN" select="$pN - 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
