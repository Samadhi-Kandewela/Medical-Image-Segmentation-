<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- ####################################################################################################
    Copyright (c) 2002-2008 GE Healthcare

    FUNC.XSL    :   XSLT rules for SR to HTML transformation for Functool reports.
    @author raczatt
    @date Apr 16, 2008
-->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="GEN_HTM.XSL"/>
<xsl:include href="FUNC_HTM.XSL"/>
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

    <xsl:variable name="nodeMeaning" select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>
    <a name="{concat(translate($nodeMeaning, $INVALID_NAME_CHARS, ''), $pPosition)}"/>
    <xsl:if test="$nodeMeaning!='Best Illustrations' or position()=6">
        <h2><xsl:value-of select="$nodeMeaning"/></h2>
    </xsl:if>

    <!-- add value of different Value Types except CONTAINER -->
    <xsl:if test="not($pItem/ValueType_CONTAINER)">
        <xsl:call-template name="addValue">
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
    </xsl:if>

    <!-- process ContentSequence if exists -->
    <xsl:if test="$pItem/ContentSequence">
        <xsl:variable name="main_heading" select="$pItem/ConceptNameCodeSequence/Item/CodeMeaning"/>

        <!-- process 'Best Illustrations' Separartely to get a customized look -->
        <xsl:choose>
        <xsl:when test="$main_heading='Best Illustrations'">
               <xsl:call-template name="addBestIllustrations">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
        <xsl:call-template name="addContent">
            <xsl:with-param name="pLevel" select="0"/>
            <xsl:with-param name="pCurrent" select="$pItem"/>
        </xsl:call-template>
        </xsl:otherwise>
        </xsl:choose>

    </xsl:if>
</xsl:template>

<!-- ####################################################################################################
    Template:       addContent
    Description:    Add content in a TABLE rows with recursion (except for "Best illustrations"
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->

<xsl:template name="addContent"> <xsl:param name="pLevel"/>
                                 <xsl:param name="pCurrent"/>

    <xsl:for-each select="$pCurrent/ContentSequence/Item">
        <xsl:variable name="sub_heading" select="ConceptNameCodeSequence/Item/CodeMeaning"/>
    
        <xsl:choose>
            <xsl:when test="$sub_heading = 'Description'">
                <TABLE width="100%" border="0">
                <TR>
                    <TD align="right">
                    <xsl:variable name="fontSize">
                        <xsl:choose>
                            <!-- Empty if no font size is specififed in the template. -->
                            <xsl:when test="$tp/Font/@size = ''"/>
                            <!-- Calculating font size based on template font size and recursion level. -->
                            <xsl:when test="($tp/Font/@size - ($pLevel * 2)) &gt; 6">
                                <xsl:value-of select="$tp/Font/@size - ($pLevel * 2)"/>
                            </xsl:when>
                            <!-- Smallest font is 6pt. -->
                            <xsl:otherwise>6</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
            
            
                    <TABLE border="0" cols="1" width="{100 - ($pLevel * 5)}%" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
                    <TR>
                        <TD valign="top">
                                <!-- value of the particular item  -->
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </TD>
                    </TR>
                    </TABLE>
            
                    <!-- process additional elements within the description node -->
                    <xsl:if test="current()/ContentSequence/Item">
                        <xsl:call-template name="addContent">
                            <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                            <xsl:with-param name="pCurrent" select="current()"/>
                        </xsl:call-template>
                    </xsl:if>
                    </TD>
                </TR>
                </TABLE>
            </xsl:when>
            <xsl:otherwise>
                <TABLE width="100%" border="0">
                <TR>
                    <TD align="right">
                    <xsl:variable name="fontSize">
                        <xsl:choose>
                            <!-- Empty if no font size is specififed in the template. -->
                            <xsl:when test="$tp/Font/@size = ''"/>
                            <!-- Calculating font size based on template font size and recursion level. -->
                            <xsl:when test="($tp/Font/@size - ($pLevel * 2)) &gt; 6">
                                <xsl:value-of select="$tp/Font/@size - ($pLevel * 2)"/>
                            </xsl:when>
                            <!-- Smallest font is 6pt. -->
                            <xsl:otherwise>6</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
            
            
                    <TABLE border="0" cols="2" width="{100 - ($pLevel * 5)}%" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
                    <TR>
                        <!-- take 30% of blank space to this column -->
                        <TD valign="top" width="30%">
                                <!-- heading text in bold -->
                            <B><xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/></B>
                        </TD>
                        <TD valign="top">
                                <!-- value of the particular item  -->
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </TD>
                    </TR>
                    </TABLE>
            
                    <xsl:if test="current()/ContentSequence/Item">
                        <xsl:call-template name="addContent">
                            <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                            <xsl:with-param name="pCurrent" select="current()"/>
                        </xsl:call-template>
                    </xsl:if>
                    </TD>
                </TR>
                </TABLE>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>

</xsl:template>


<!-- ####################################################################################################
    Template:       addBestIllustrations
    Description:    Add content of "Best Illustrations" in a custommized way.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->
<xsl:template name="addBestIllustrations"> <xsl:param name="pLevel"/>
                                           <xsl:param name="pCurrent"/>
                                           <xsl:param name="pNum" select="0"/>

    <!-- Process sub-headings within 'Best Illustrations' -->
    <xsl:for-each select="$pCurrent/ContentSequence/Item">
        <xsl:variable name="sub_heading" select="ConceptNameCodeSequence/Item/CodeMeaning"/>
    
        <xsl:choose>
        <!-- Customize 'Location' tag -->
            <xsl:when test="$sub_heading = 'Location'">
            <TABLE width="100%" border="0">
            <TR>
                <TD align="right">
                <xsl:variable name="fontSize">
                    <xsl:choose>
                        <!-- Empty if no font size is specififed in the template. -->
                        <xsl:when test="$tp/Font/@size = ''"/>
                        <!-- Calculating font size based on template font size and recursion level. -->
                        <xsl:when test="($tp/Font/@size - ($pLevel * 2)) &gt; 6">
                            <xsl:value-of select="$tp/Font/@size - ($pLevel * 2)"/>
                        </xsl:when>
                        <!-- Smallest font is 6pt. -->
                        <xsl:otherwise>6</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
        
        
                <TABLE border="0" cols="2" width="{100 - ($pLevel * 5)}%" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
                <TR>
                    <TD valign="top">
                        <B><xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/></B>
                        <B>: </B>
                    </TD>
                    <TD valign="top" width="100%">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()"/>
                        </xsl:call-template>
                    </TD>
                </TR>
                </TABLE>
        
                <xsl:if test="current()/ContentSequence/Item">
                    <xsl:call-template name="addBestIllustrations">
                        <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                        <xsl:with-param name="pCurrent" select="current()"/>
                    </xsl:call-template>
                </xsl:if>
                </TD>
            </TR>
            </TABLE>
            </xsl:when>
        </xsl:choose>
    </xsl:for-each>

    <!-- Customize 'Image Capture' tag -->
    <xsl:call-template name="ImageCapture">
         <xsl:with-param name="pLevel" select="$pLevel"/>
        <xsl:with-param name="pCurrent" select="$pCurrent"/>
    </xsl:call-template>


    <xsl:for-each select="$pCurrent/ContentSequence/Item">
    <xsl:variable name="sub_heading" select="ConceptNameCodeSequence/Item/CodeMeaning"/>

    <xsl:choose>
        <!-- Customize 'Description' tag -->
        <xsl:when test="$sub_heading = 'Description'">
            <TABLE width="100%" border="0">
            <TR>
                <TD align="right">
                <xsl:variable name="fontSize">
                    <xsl:choose>
                        <!-- Empty if no font size is specififed in the template. -->
                        <xsl:when test="$tp/Font/@size = ''"/>
                        <!-- Calculating font size based on template font size and recursion level. -->
                        <xsl:when test="($tp/Font/@size - ($pLevel * 2)) &gt; 6">
                            <xsl:value-of select="$tp/Font/@size - ($pLevel * 2)"/>
                        </xsl:when>
                                <!-- Smallest font is 6pt. -->
                        <xsl:otherwise>6</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
        
        
                <TABLE border="0" cols="1" width="{100 - ($pLevel * 5)}%" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
                <TR>
                    <TD valign="top">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()"/>
                        </xsl:call-template>
                    </TD>
                </TR>
                </TABLE>
        
                <xsl:if test="current()/ContentSequence/Item">
                    <xsl:call-template name="addBestIllustrations">
                        <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                        <xsl:with-param name="pCurrent" select="current()"/>
                    </xsl:call-template>
                </xsl:if>
                </TD>
            </TR>
            </TABLE>
       </xsl:when>
    
       <!-- process all other sub-headings -->
       <xsl:when test="$sub_heading != 'Image Capture' and $sub_heading != 'Location'">
            <TABLE width="100%" border="0">
            <TR>
                <TD align="right">
                <xsl:variable name="fontSize">
                    <xsl:choose>
                        <!-- Empty if no font size is specififed in the template. -->
                        <xsl:when test="$tp/Font/@size = ''"/>
                        <!-- Calculating font size based on template font size and recursion level. -->
                        <xsl:when test="($tp/Font/@size - ($pLevel * 2)) &gt; 6">
                            <xsl:value-of select="$tp/Font/@size - ($pLevel * 2)"/>
                        </xsl:when>
                        <!-- Smallest font is 6pt. -->
                        <xsl:otherwise>6</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
        
                <TABLE border="0" cols="2" width="{100 - ($pLevel * 5)}%" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
                <TR>
                    <TD valign="top" width="30%">
                        <B><xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/></B>
                    </TD>
                    <TD valign="top">
                        <xsl:call-template name="addValue">
                            <xsl:with-param name="pCurrent" select="current()"/>
                        </xsl:call-template>
                    </TD>
                </TR>
                </TABLE>
        
                <xsl:if test="current()/ContentSequence/Item">
                    <xsl:call-template name="addBestIllustrations">
                        <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                        <xsl:with-param name="pCurrent" select="current()"/>
                    </xsl:call-template>
                </xsl:if>
                </TD>
            </TR>
            </TABLE>
        </xsl:when>
    </xsl:choose>

    </xsl:for-each>

</xsl:template>

<!-- ####################################################################################################
    Template:       ImageCapture
    Description:    Add 'Image Capture related information
-->
<xsl:template name="ImageCapture"> <xsl:param name="pLevel"/>
                                   <xsl:param name="pCurrent"/>

    <xsl:variable name="image_set" select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeValue = 'CAPTURE' and ConceptNameCodeSequence/Item/CodingSchemeDesignator = $CSD_DICOM]"/>
    <xsl:variable name="numOfImages" select="2"/>

    <TABLE border="0" width="100%">
    <TR>
        <TD align="left">
            <xsl:variable name="fontSize">
               <xsl:choose>
                    <!-- Empty if no font size is specififed in the template-->
                    <xsl:when test="$tp/Font/@size = ''"/>
                    <!-- Calculating font size based on template font size and recursion level. -->
                    <xsl:when test="($tp/Font/@size - ($pLevel * 2)) &gt; 6">
                            <xsl:value-of select="$tp/Font/@size - ($pLevel * 2)"/>
                    </xsl:when>
                    <!-- Smallest font is 6pt. -->
                    <xsl:otherwise>6</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
    
            <TABLE border="0" width="100%" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
            <TR>
                <TABLE border="0" width="100%" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
                        <xsl:call-template name="addNImagesFunc">
                                <xsl:with-param name="pImages" select="$image_set"/>
                                <xsl:with-param name="pN" select="$numOfImages"/>
                        </xsl:call-template>
        
                </TABLE>
            </TR>
            </TABLE>
        </TD>
    </TR>
    </TABLE>

           <!-- process "Roi group" within "Image Capture" blocks -->
    <xsl:for-each select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeMeaning = 'Image Capture']">
    <TABLE border="0" width="100%">
    <TR>
        <TD align="left">
            <TABLE border="0" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
            <xsl:variable name="image_capture" select="current()/ContentSequence/Item"/>
            <xsl:if test="$image_capture/ValueType_IMAGE and $image_capture/ConceptNameCodeSequence/Item/CodeMeaning = 'Roi Group'">
                <xsl:if test="$image_capture/ContentSequence/Item/ConceptNameCodeSequence/Item/CodeMeaning='Name'">
                    <TR>
                        <TD valign="middle">
                            <B>
                            <xsl:choose>
                                <xsl:when test="$image_capture/ContentSequence/Item/ValueType_NUM">
                                    <xsl:call-template name="addNumValue">
                                        <xsl:with-param name="pCurrent" select="$image_capture/ContentSequence/Item"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="addValue">
                                        <xsl:with-param name="pCurrent" select="$image_capture/ContentSequence/Item"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                            </B>
                        </TD>
                    </TR>
                </xsl:if>
    
                <!-- add 'Roi Group' -->
                <xsl:for-each select="$image_capture">
                    <xsl:if test="ConceptNameCodeSequence/Item/CodeMeaning = 'Roi Group'">
                        <TR>
                            <TD align="left" valign="middle">
                                <xsl:call-template name="addRoiGroup">
                                    <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                    <xsl:with-param name="pCurrent" select="current()"/>
                                </xsl:call-template>
                            </TD>
                        </TR>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            </TABLE>
        </TD>
    </TR>
    </TABLE>
    </xsl:for-each>

</xsl:template>

<!-- ####################################################################################################
    Template:       addRoiGroup
    Description:    Add roi Group within 'Image Capture' in a TABLE.
    Parameters:
        pLevel   :  Level of recursion
        pCurrent :  The current node of processing
-->
<xsl:template name="addRoiGroup"> <xsl:param name="pLevel"/>
                                  <xsl:param name="pCurrent"/>

    <xsl:variable name="colWidth">250</xsl:variable>

        <!-- if there are childs within Roi Group for Rois draw a seperate table -->
        <xsl:if test="$pCurrent/ContentSequence/Item">
        <!-- add columns and data -->
        <!-- draw the table columns only once -->
        <TABLE border="1" width="100%" cellpadding="2" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
        <xsl:for-each select="$pCurrent/ContentSequence/Item[ConceptNameCodeSequence/Item/CodeMeaning='Roi']">
                <xsl:variable name="roi_pos" select="position()"/>
                <xsl:if test="$roi_pos=1">
                <TR>
                        <xsl:for-each select="current()/ContentSequence/Item">

                        <TD align="center" valign="middle" width="{$colWidth}">
                                <B><xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/></B>
                        </TD>
                        </xsl:for-each>
                </TR>
                </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="$pCurrent/ContentSequence/Item">
            <TR>
                <xsl:for-each select="current()/ContentSequence/Item">
                <TD align="center" valign="middle" width="{$colWidth}">
                    <xsl:choose>
                        <xsl:when test="current()/ValueType_NUM">
                            <xsl:call-template name="addNumValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="addValue">
                                <xsl:with-param name="pCurrent" select="current()"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </TD>
                </xsl:for-each>
            </TR>
        </xsl:for-each>
        </TABLE>
        </xsl:if><!-- if there are childs within Roi Group -->

</xsl:template>

<!-- ####################################################################################################
    Template:       addNImagesFunc
    Description:    Recursively adds Image captures organized into N columns.
    Parameters:
        pImages   :  Image Capture node-set.
        pN        :  # of columns images displayed across.
-->
<xsl:template name="addNImagesFunc"> <xsl:param name="pImages"/>
                                     <xsl:param name="pN"/>

    <xsl:variable name="firstNImages" select="$pImages[position() &lt;= $pN]"/>
    <TR>
        <xsl:for-each select="$firstNImages">
            <TD style="width: {100 div $pN}%; text-align: left" valign="top">
                <TABLE border="0" style="font-family: {$tp/Font/@type}; font-size: {$fontSize}pt">
                <xsl:for-each select="current()/ContentSequence/Item">
                    <xsl:variable name="child_tag_name" select="ConceptNameCodeSequence/Item/CodeMeaning"/>
                    <xsl:choose>
                        <!-- add image -->
                        <xsl:when test="current()/ValueType_IMAGE">
                            <TR>
                            <!-- print the value of image name -->
                                <TD align="center" valign="top" width="350px">
                                    <B><xsl:value-of select="ConceptNameCodeSequence/Item/CodeMeaning"/></B>
                                </TD>
                            </TR>
                            <TR>
                                <TD valign="top">
                                    <xsl:call-template name="addImageValue">
                                            <xsl:with-param name="pCurrent" select="current()"/>
                                    </xsl:call-template>
                                </TD>
                            </TR>
                        </xsl:when>
                        <xsl:when test="$child_tag_name='Description'">
                            <TR>
                                <TD valign="top" width="350px">
                                    <xsl:call-template name="addValue">
                                            <xsl:with-param name="pCurrent" select="current()"/>
                                    </xsl:call-template>
                                </TD>
                            </TR>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                </TABLE>
            </TD>
        </xsl:for-each>
    </TR>
    <xsl:variable name="remainingImages" select="$pImages[position() &gt; $pN]"/>
    <xsl:if test="count($remainingImages) != 0">
        <xsl:call-template name="addNImagesFunc">
            <xsl:with-param name="pImages" select="$remainingImages"/>
            <xsl:with-param name="pN" select="$pN"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
