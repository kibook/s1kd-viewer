<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:param name="ident"/>
  <xsl:param name="type"/>
  <xsl:param name="value"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="product">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="assign[not(@applicPropertyIdent = $ident and @applicPropertyType = $type)]"/>
      <xsl:if test="$value != ''">
        <assign applicPropertyIdent="{$ident}" applicPropertyType="{$type}" applicPropertyValue="{$value}"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

</xsl:transform>
