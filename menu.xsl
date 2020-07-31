<?xml version="1.0"?>
<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output omit-xml-declaration="yes"/>

  <xsl:param name="publication"/>
  <xsl:param name="document"/>
  <xsl:param name="pct"/>
  <xsl:param name="non-applic"/>
  <xsl:param name="units"/>
  <xsl:param name="unit-format"/>
  <xsl:param name="comments"/>
  <xsl:param name="changes"/>

  <xsl:variable name="assigns" select="document($pct)//assign"/>

  <xsl:template name="add-option">
    <xsl:param name="label"/>
    <xsl:param name="value"/>
    <xsl:param name="selected"/>
    <option value="{$value}">
      <xsl:if test="$selected">
        <xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$label"/>
    </option>
  </xsl:template>

  <xsl:template match="properties">
    <table>
      <tr>
        <td title="Publication">Publication: </td>
        <td>
          <input type="text" name="publication" size="26" value="{$publication}"/>
        </td>
        <td title="Document">Document: </td>
        <td>
          <input type="text" name="document" size="41" value="{$document}"/>
        </td>
        <xsl:apply-templates select="object/property">
          <xsl:sort select="@type" order="descending"/>
          <xsl:sort select="@ident"/>
        </xsl:apply-templates>
        <xsl:if test="$non-applic">
          <td title="Whether to hide non-applicable content, or show it grayed-out">Non-applicable content: </td>
          <td>
            <select name="non-applic">
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Hide</xsl:with-param>
                <xsl:with-param name="value">hide</xsl:with-param>
                <xsl:with-param name="selected" select="$non-applic = 'hide'"/>
              </xsl:call-template>
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Show</xsl:with-param>
                <xsl:with-param name="value">show</xsl:with-param>
                <xsl:with-param name="selected" select="$non-applic = 'show'"/>
              </xsl:call-template>
            </select>
          </td>
        </xsl:if>
        <xsl:if test="$units">
          <td title="Convert units to this standard">Units: </td>
          <td>
            <select name="units">
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Imperial</xsl:with-param>
                <xsl:with-param name="value">imperial</xsl:with-param>
                <xsl:with-param name="selected" select="$units = 'imperial'"/>
              </xsl:call-template>
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">SI</xsl:with-param>
                <xsl:with-param name="value">SI</xsl:with-param>
                <xsl:with-param name="selected" select="$units = 'SI'"/>
              </xsl:call-template>
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">US</xsl:with-param>
                <xsl:with-param name="value">US</xsl:with-param>
                <xsl:with-param name="selected" select="$units = 'US'"/>
              </xsl:call-template>
            </select>
          </td>
        </xsl:if>
        <xsl:if test="$unit-format">
          <td title="Display units with this format">Unit format: </td>
          <td>
            <select name="unit-format">
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Imperial</xsl:with-param>
                <xsl:with-param name="value">imperial</xsl:with-param>
                <xsl:with-param name="selected" select="$unit-format = 'imperial'"/>
              </xsl:call-template>
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">SI</xsl:with-param>
                <xsl:with-param name="value">SI</xsl:with-param>
                <xsl:with-param name="selected" select="$unit-format = 'SI'"/>
              </xsl:call-template>
            </select>
          </td>
        </xsl:if>
        <xsl:if test="$comments">
          <td title="Show XML comments">Comments: </td>
          <td>
            <select name="comments">
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Hide</xsl:with-param>
                <xsl:with-param name="value">hide</xsl:with-param>
                <xsl:with-param name="selected" select="$comments = 'hide'"/>
              </xsl:call-template>
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Show</xsl:with-param>
                <xsl:with-param name="value">show</xsl:with-param>
                <xsl:with-param name="selected" select="$comments = 'show'"/>
              </xsl:call-template>
            </select>
          </td>
        </xsl:if>
        <xsl:if test="$changes">
          <td title="Show change marks">Changes: </td>
          <td>
            <select name="changes">
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Hide</xsl:with-param>
                <xsl:with-param name="value">hide</xsl:with-param>
                <xsl:with-param name="selected" select="$changes = 'hide'"/>
              </xsl:call-template>
              <xsl:call-template name="add-option">
                <xsl:with-param name="label">Show</xsl:with-param>
                <xsl:with-param name="value">show</xsl:with-param>
                <xsl:with-param name="selected" select="$changes = 'show'"/>
              </xsl:call-template>
            </select>
          </td>
        </xsl:if>
        <td>
          <input type="submit" value="Open"/>
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="property">
    <xsl:variable name="ident" select="@ident"/>
    <xsl:variable name="type" select="@type"/>
    <xsl:variable name="assign" select="$assigns[@applicPropertyIdent=$ident and @applicPropertyType=$type]"/>
    <td>
      <xsl:attribute name="title">
        <xsl:value-of select="descr"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="displayName">
          <xsl:value-of select="displayName"/>
        </xsl:when>
        <xsl:when test="name">
          <xsl:value-of select="name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ident"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>:</xsl:text>
    </td>
    <td>
      <xsl:choose>
        <xsl:when test="value">
          <select name="{$ident}:{$type}">
            <option/>
            <xsl:for-each select="value">
              <xsl:call-template name="add-option">
                <xsl:with-param name="label" select="."/>
                <xsl:with-param name="value" select="."/>
                <xsl:with-param name="selected" select="$assign/@applicPropertyValue = ."/>
              </xsl:call-template>
            </xsl:for-each>
          </select>
        </xsl:when>
        <xsl:otherwise>
          <input type="text" name="{$ident}:{$type}" value="{$assign/@applicPropertyValue}"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </xsl:template>

</xsl:transform>
