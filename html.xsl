<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:str="http://exslt.org/strings"
  xmlns:exsl="http://exslt.org/common"
  version="1.0">

  <xsl:param name="publication"/>
  <xsl:param name="document"/>
  <xsl:param name="non-applic"/>
  <xsl:param name="units"/>
  <xsl:param name="unit-format"/>
  <xsl:param name="pct"/>
  <xsl:param name="comments"/>
  <xsl:param name="changes"/>
  <xsl:param name="tools-cir"/>
  <xsl:param name="supplies-cir"/>
  <xsl:param name="parts-cir"/>

  <xsl:variable name="assigns" select="document($pct)//assign"/>

  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:output omit-xml-declaration="yes"/>

  <xsl:template match="@id">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dmTitle">
    <xsl:apply-templates select="techName"/>
    <xsl:if test="infoName">
      <xsl:text> - </xsl:text>
      <xsl:apply-templates select="infoName"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="pmTitle">
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::shortPmTitle">
      <xsl:text> - </xsl:text>
      <xsl:apply-templates select="following-sibling::shortPmTitle"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="content">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="identAndStatusSection">
    <xsl:variable name="ident" select="dmAddress/dmIdent|pmAddress/pmIdent"/>
    <xsl:variable name="address-items" select="dmAddress/dmAddressItems|pmAddress/pmAddressItems"/>
    <xsl:variable name="status" select="dmStatus|pmStatus"/>
    <table>
      <tr>
        <td style="font-weight: bold;">Issue:</td>
        <td>
          <xsl:apply-templates select="$ident/issueInfo"/>
        </td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Issue date:</td>
        <td>
          <xsl:apply-templates select="$address-items/issueDate"/>
        </td>
      </tr>
      <tr>
        <td style="font-weight: bold;">Security:</td>
        <td>
          <xsl:apply-templates select="$status/security"/>
        </td>
      </tr>
      <xsl:if test="$status/sourceDmIdent">
        <tr>
          <td style="font-weight: bold;">Source DM:</td>
          <td>
            <xsl:apply-templates select="$status/sourceDmIdent"/>
          </td>
        </tr>
      </xsl:if>
      <tr>
        <td style="font-weight: bold;">Applicability:</td>
        <td>
          <xsl:value-of select="$status/applic/displayText/simplePara"/>
        </td>
      </tr>
    </table>
    <h1>
      <xsl:apply-templates select="$address-items/dmTitle|$address-items/pmTitle"/>
    </h1>
  </xsl:template>

  <xsl:template match="issueDate">
    <xsl:value-of select="@year"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@month"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@day"/>
  </xsl:template>

  <xsl:template match="issueInfo">
    <xsl:value-of select="@issueNumber"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@inWork"/>
  </xsl:template>

  <xsl:template match="security">
    <xsl:choose>
      <xsl:when test="@securityClassification = '01'">Unclassified</xsl:when>
      <xsl:otherwise>
        <xsl:text>Classified: </xsl:text>
        <xsl:value-of select="@securityClassification"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sourceDmIdent">
    <xsl:variable name="dmc">
      <xsl:apply-templates select="dmCode"/>
    </xsl:variable>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="create-link">
          <xsl:with-param name="document" select="$dmc"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="$dmc"/>
    </a>
  </xsl:template>

  <xsl:template match="refs"/>

  <xsl:template match="mainProcedure">
    <table>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="proceduralStep">
    <xsl:apply-templates select="@applicRefId" mode="tabular">
      <xsl:with-param name="colspan">2</xsl:with-param>
    </xsl:apply-templates>
    <tr>
      <xsl:call-template name="common-attrs"/>
      <td style="vertical-align: top; padding-bottom: 0.5em; padding-right: 0.5em; font-weight: bold;">
        <xsl:number level="multiple"/>
        <xsl:text>.</xsl:text>
      </td>
      <td style="vertical-align: top; padding-bottom: 0.5em;">
        <xsl:apply-templates select="title|warning|caution|note|circuitBreakerDescrGroup|para|table|caption|comment()"/>
        <xsl:if test="proceduralStep">
          <table>
            <xsl:apply-templates select="proceduralStep"/>
          </table>
        </xsl:if>
        <xsl:apply-templates select="figure"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="levelledPara">
    <table>
      <xsl:apply-templates select="@applicRefId" mode="tabular">
        <xsl:with-param name="colspan">2</xsl:with-param>
      </xsl:apply-templates>
      <tr>
        <xsl:call-template name="common-attrs"/>
        <td style="vertical-align: top; padding-bottom: 0.5em; padding-right: 0.5em; font-weight: bold;">
          <xsl:number level="multiple"/>
          <xsl:text>.</xsl:text>
        </td>
        <td style="vertical-align: top; padding-bottom: 0.5em;">
          <xsl:apply-templates select="*[not(self::levelledPara)]|comment()"/>
          <xsl:if test="levelledPara">
            <table>
              <xsl:apply-templates select="levelledPara"/>
            </table>
          </xsl:if>
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="@applicRefId">
    <xsl:variable name="id" select="."/>
    <b style="color: blue;">
      <xsl:apply-templates select="//applic[@id = $id]"/>
    </b>
  </xsl:template>

  <xsl:template match="@applicRefId" mode="tabular">
    <xsl:param name="colspan">1</xsl:param>
    <xsl:variable name="id" select="."/>
    <tr>
      <xsl:if test="parent::*/processing-instruction('notApplicable')">
        <xsl:attribute name="style">opacity: 25%;</xsl:attribute>
      </xsl:if>
      <td colspan="{$colspan}">
        <b style="color: blue;">
          <xsl:apply-templates select="//applic[@id = $id]"/>
        </b>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="applic">
    <div>
      <xsl:text>Applicable to: </xsl:text>
      <xsl:value-of select="displayText/simplePara"/>
    </div>
  </xsl:template>

  <xsl:template match="para">
    <div>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">margin-bottom: 8pt;</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="@applicRefId"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="randomList">
    <ul>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="sequentialList">
    <ol>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>

  <xsl:template match="listItem">
    <li>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates select="@applicRefId"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="verbatimText">
    <span>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">font-family: monospace</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="verbatimText[@verbatimStyle = 'vs11' or @verbatimStyle = 'vs23' or @verbatimStyle = 'vs24']">
    <pre>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>

  <xsl:template match="emphasis">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <xsl:template match="note">
    <div>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">padding-bottom: 8pt</xsl:with-param>
      </xsl:call-template>
      <div>
        <b>NOTE</b>
      </div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="notePara">
    <div>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">margin-left: 1em</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="externalPubRef">
    <a href="{@xlink:href}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="externalPubRefIdent">
    <xsl:choose>
      <xsl:when test="externalPubCode and externalPubTitle">
        <xsl:apply-templates select="externalPubCode"/>
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="externalPubTitle"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="externalPubCode|externalPubTitle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="internalRef">
    <xsl:variable name="id" select="@internalRefId"/>
    <xsl:variable name="target" select="//*[@id = $id]"/>
    <xsl:choose>
      <xsl:when test="$target">
        <a href="#{$id}">
          <xsl:apply-templates select="$target" mode="xref"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span style="color: red; font-weight: bold;">INVALID</span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="figure" mode="xref">
    <xsl:text>Fig </xsl:text>
    <xsl:apply-templates select="." mode="number"/>
  </xsl:template>

  <xsl:template match="table" mode="xref">
    <xsl:text>Table </xsl:text>
    <xsl:apply-templates select="." mode="number"/>
  </xsl:template>

  <xsl:template match="table" mode="number">
    <xsl:number count="table" level="any"/>
  </xsl:template>

  <xsl:template match="supportEquipDescr|supplyDescr|spareDescr" mode="xref">
    <xsl:apply-templates select="comment()"/>
    <xsl:choose>
      <xsl:when test="shortName">
        <xsl:apply-templates select="shortName"/>
      </xsl:when>
      <xsl:when test="name">
        <xsl:apply-templates select="name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="identNumber"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="levelledPara" mode="xref">
    <xsl:text>Para </xsl:text>
    <xsl:number level="multiple"/>
  </xsl:template>

  <xsl:template match="proceduralStep" mode="xref">
    <xsl:text>Step </xsl:text>
    <xsl:number level="multiple"/>
  </xsl:template>

  <xsl:template match="title">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <xsl:template match="dmRef">
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="create-link">
          <xsl:with-param name="document">
            <xsl:apply-templates select="dmRefIdent/dmCode"/>
          </xsl:with-param>
          <xsl:with-param name="anchor" select="@referredFragment"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="dmRefAddressItems/dmTitle"/>
    </a>
  </xsl:template>

  <xsl:template match="dmCode">
    <xsl:value-of select="@modelIdentCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@systemDiffCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@systemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@subSystemCode"/>
    <xsl:value-of select="@subSubSystemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@assyCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@disassyCode"/>
    <xsl:value-of select="@disassyCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@infoCode"/>
    <xsl:value-of select="@infoCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@itemLocationCode"/>
    <xsl:if test="@learnCode">
      <xsl:text>-</xsl:text>
      <xsl:value-of select="@learnCode"/>
      <xsl:value-of select="@learnEventCode"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="table">
    <div>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">margin-bottom: 1em;</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="@applicRefId"/>
      <div style="font-weight: bold; margin-bottom: 0.5em;">
        <xsl:text>Table </xsl:text>
        <xsl:apply-templates select="." mode="number"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="title"/>
      </div>
      <xsl:apply-templates select="tgroup|graphic"/>
    </div>
  </xsl:template>

  <xsl:template match="table/title">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tgroup">
    <table>
      <xsl:attribute name="style">
        <xsl:text>border-collapse: collapse;</xsl:text>
        <xsl:if test="parent::table/@pgwide = 1">width: 100%;</xsl:if>
        <xsl:choose>
          <xsl:when test="parent::table/@frame = 'topbot'">border-top: solid 1px black; border-bottom: solid 1px black;</xsl:when>
          <xsl:when test="parent::table/@frame = 'sides'">border-left: solid 1px black; border-right: solid 1px black;</xsl:when>
          <xsl:when test="parent::table/@frame = 'top'">border-top: solid 1px black;</xsl:when>
          <xsl:when test="parent::table/@frame = 'bottom'">border-bottom: solid 1px black;</xsl:when>
          <xsl:when test="parent::table/@frame = 'none'"/>
          <xsl:otherwise>border: solid 1px black;</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="thead|tbody">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="row">
    <xsl:apply-templates select="@applicRefId" mode="tabular">
      <xsl:with-param name="colspan" select="ancestor::tgroup/@cols"/>
    </xsl:apply-templates>
    <tr>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <xsl:template match="entry">
    <td>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">
          <xsl:if test="following-sibling::entry or not(preceding-sibling::entry)">
            <xsl:variable name="colsep" select="ancestor::*/@colsep[last()]"/>
            <xsl:if test="not($colsep) or $colsep = 1">border-right: solid 1px black;</xsl:if>
          </xsl:if>
          <xsl:if test="parent::row/following-sibling::row or not(parent::row/preceding-sibling::row)">
            <xsl:variable name="rowsep" select="ancestor::*/@rowsep[last()]"/>
            <xsl:if test="not($rowsep) or $rowsep = 1">border-bottom: solid 1px black;</xsl:if>
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template match="graphic">
    <xsl:variable name="uri" select="translate(unparsed-entity-uri(@infoEntityIdent), $upper, $lower)"/>
    <div>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">margin-bottom: 1em</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="@applicRefId"/>
      <xsl:choose>
        <xsl:when test="contains($uri, 'mp4')">
          <video controls="controls" style="max-width: 75%;">
            <source type="video/mp4" src="graphic.cgi?icn={@infoEntityIdent}"/>
          </video>
        </xsl:when>
        <xsl:when test="contains($uri, 'x3d')">
          <X3D xmlns="http://www.web3d.org/specifications/x3dnamespace" width="640px" height="480px">
            <Scene>
              <Inline url="graphic.cgi?icn={@infoEntityIdent}"/>
            </Scene>
          </X3D>
        </xsl:when>
        <xsl:otherwise>
          <img style="max-width: 75%;">
            <xsl:attribute name="src">
              <xsl:text>graphic.cgi?icn=</xsl:text>
              <xsl:value-of select="@infoEntityIdent"/>
            </xsl:attribute>
          </img>
        </xsl:otherwise>
      </xsl:choose>
      <div style="font-weight: bold;">
        <xsl:text>Fig </xsl:text>
        <xsl:apply-templates select="parent::figure" mode="number"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="parent::figure/title"/>
        <xsl:if test="preceding-sibling::graphic|following-sibling::graphic">
          <xsl:text> (Sheet </xsl:text>
          <xsl:number count="graphic" level="single"/>
          <xsl:text> of </xsl:text>
          <xsl:value-of select="count(parent::figure/graphic)"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="symbol">
    <img>
      <xsl:attribute name="src">
        <xsl:text>graphic.cgi?icn=</xsl:text>
        <xsl:value-of select="@infoEntityIdent"/>
      </xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template match="referencedApplicGroup"/>

  <xsl:template match="figure">
    <xsl:apply-templates select="comment()"/>
    <div>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates select="@applicRefId"/>
      <xsl:apply-templates select="graphic"/>
    </div>
  </xsl:template>

  <xsl:template match="mainProcedure/figure">
    <xsl:apply-templates select="@applicRefId" mode="tabular">
      <xsl:with-param name="colspan">2</xsl:with-param>
    </xsl:apply-templates>
    <xsl:apply-templates select="comment()"/>
    <tr>
      <xsl:call-template name="common-attrs"/>
      <td/>
      <td>
        <div>
          <xsl:apply-templates select="graphic"/>
        </div>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="figure" mode="number">
    <xsl:number level="any"/>
  </xsl:template>

  <xsl:template match="figure/title">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="definitionList">
    <table class="definition-list">
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="definitionListItem">
    <tr>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <xsl:template match="listItemTerm|listItemDefinition">
    <td>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template match="supportEquipDescrGroup|supplyDescrGroup|spareDescrGroup">
    <div>
      <h2>
        <xsl:choose>
          <xsl:when test="self::supportEquipDescrGroup">Support equipment</xsl:when>
          <xsl:when test="self::supplyDescrGroup">Consumables, materials and expendables</xsl:when>
          <xsl:when test="self::spareDescrGroup">Spares</xsl:when>
        </xsl:choose>
      </h2>
      <table class="prelim-rqmts-table">
        <tr>
          <th>Name</th>
          <th>Identification</th>
          <th>Quantity</th>
          <th>Remarks</th>
        </tr>
        <xsl:apply-templates/>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="supportEquipDescr|supplyDescr|spareDescr">
    <xsl:apply-templates select="@applicRefId" mode="tabular">
      <xsl:with-param name="colspan">4</xsl:with-param>
    </xsl:apply-templates>
    <tr>
      <xsl:call-template name="common-attrs"/>
      <td style="padding-right: 1em;">
        <xsl:apply-templates select="name"/>
      </td>
      <td>
        <xsl:apply-templates select="identNumber" mode="cir-link"/>
        <xsl:apply-templates select="natoStockNumber" mode="block"/>
      </td>
      <td>
        <xsl:apply-templates select="reqQuantity"/>
      </td>
      <td>
        <xsl:apply-templates select="remarks"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="safetyRqmts">
    <div>
      <h2>Safety conditions</h2>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="warning">
    <xsl:apply-templates select="@applicRefId"/>
    <div>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">font-weight: bold; border: solid 5px red; padding: 1em;</xsl:with-param>
      </xsl:call-template>
      <div>WARNING</div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="caution">
    <xsl:apply-templates select="@applicRefId"/>
    <div>
      <xsl:call-template name="common-attrs">
        <xsl:with-param name="style">font-weight: bold; border: solid 5px yellow; padding: 1em;</xsl:with-param>
      </xsl:call-template>
      <div>CAUTION</div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="warningAndCautionPara">
    <p>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template name="identNumber">
    <xsl:text>Part No. </xsl:text>
    <xsl:apply-templates select="manufacturerCode"/>
    <xsl:if test="partAndSerialNumber">
      <xsl:text>/</xsl:text>
      <xsl:apply-templates select="partAndSerialNumber"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="identNumber">
    <xsl:call-template name="identNumber"/>
  </xsl:template>

  <xsl:template match="supportEquipDescr/identNumber" mode="cir-link">
    <div>
      <xsl:choose>
        <xsl:when test="$tools-cir">
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="create-link">
                <xsl:with-param name="document" select="$tools-cir"/>
                <xsl:with-param name="anchor">
                  <xsl:value-of select="manufacturerCode"/>
                  <xsl:text>_</xsl:text>
                  <xsl:value-of select="partAndSerialNumber/partNumber"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:call-template name="identNumber"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="identNumber"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="supplyDescr/identNumber" mode="cir-link">
    <div>
      <xsl:choose>
        <xsl:when test="$supplies-cir">
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="create-link">
                <xsl:with-param name="document" select="$supplies-cir"/>
                <xsl:with-param name="anchor">
                  <xsl:value-of select="partAndSerialNumber/partNumber"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:call-template name="identNumber"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="identNumber"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="spareDescr/identNumber" mode="cir-link">
    <div>
      <xsl:choose>
        <xsl:when test="$parts-cir">
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="create-link">
                <xsl:with-param name="document" select="$parts-cir"/>
                <xsl:with-param name="anchor">
                  <xsl:value-of select="manufacturerCode"/>
                  <xsl:text>_</xsl:text>
                  <xsl:value-of select="partAndSerialNumber/partNumber"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:call-template name="identNumber"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="identNumber"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="create-link">
    <xsl:param name="document"/>
    <xsl:param name="anchor"/>
    <xsl:text>view.cgi?</xsl:text>
    <xsl:choose>
      <xsl:when test="$publication and $document">
        <xsl:text>publication=</xsl:text>
        <xsl:value-of select="$publication"/>
        <xsl:text>&amp;document=</xsl:text>
        <xsl:value-of select="$document"/>
      </xsl:when>
      <xsl:when test="$document">
        <xsl:text>document=</xsl:text>
        <xsl:value-of select="$document"/>
      </xsl:when>
      <xsl:when test="$publication">
        <xsl:text>document=</xsl:text>
        <xsl:value-of select="$publication"/>
      </xsl:when>
    </xsl:choose>
    <xsl:for-each select="exsl:node-set($assigns)">
      <xsl:text>&amp;</xsl:text>
      <xsl:value-of select="@applicPropertyIdent"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="@applicPropertyType"/>
      <xsl:text>=</xsl:text>
      <xsl:value-of select="@applicPropertyValue"/>
    </xsl:for-each>
    <xsl:if test="$non-applic">&amp;non-applic=<xsl:value-of select="$non-applic"/></xsl:if>
    <xsl:if test="$units">&amp;units=<xsl:value-of select="$units"/></xsl:if>
    <xsl:if test="$unit-format">&amp;unit-format=<xsl:value-of select="$unit-format"/></xsl:if>
    <xsl:if test="$comments">&amp;comments=<xsl:value-of select="$comments"/></xsl:if>
    <xsl:if test="$changes">&amp;changes=<xsl:value-of select="$changes"/></xsl:if>
    <xsl:if test="$anchor">#<xsl:value-of select="$anchor"/></xsl:if>
  </xsl:template>

  <xsl:template match="natoStockNumber">
    <xsl:text>NSN </xsl:text>
    <xsl:choose>
      <xsl:when test="fullNatoStockNumber">
        <xsl:value-of select="fullNatoStockNumber"/>
      </xsl:when>
      <xsl:when test="@natoSupplyClass and @natoCodificationBureau and @natoItemIdentNumberCore">
        <xsl:value-of select="@natoSupplyClass"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@natoCodificationBureau"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(@natoItemIdentNumberCore, 1, 3)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(@natoItemIdentNumberCore, 4, 4)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring(., 1, 4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(., 5, 2)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(., 7, 3)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(., 10, 4)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="common-attrs">
    <xsl:param name="style"/>
    <xsl:apply-templates select="@id"/>
    <xsl:attribute name="style">
      <xsl:if test="$changes = 'show' and @changeMark = 1">
        <xsl:text>background-color:</xsl:text>
        <xsl:choose>
          <xsl:when test="@changeType = 'add'">green</xsl:when>
          <xsl:when test="@changeType = 'modify'">yellow</xsl:when>
          <xsl:when test="@changeType = 'delete'">red</xsl:when>
          <xsl:otherwise>green</xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:text>;</xsl:text>
      <xsl:if test="processing-instruction('notApplicable')">
        <xsl:text>opacity: 25%;</xsl:text>
      </xsl:if>
      <xsl:value-of select="$style"/>
    </xsl:attribute>
    <xsl:if test="$changes = 'show' and @reasonForUpdateRefIds">
      <xsl:variable name="rfus" select="//reasonForUpdate"/>
      <xsl:attribute name="title">
        <xsl:for-each select="str:tokenize(@reasonForUpdateRefIds, ' ')">
          <xsl:variable name="id">
            <xsl:value-of select="."/>
          </xsl:variable>
          <xsl:value-of select="$rfus[@id = $id]/simplePara"/>
          <xsl:if test="position() != last()">&#10;</xsl:if>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="acronym">
    <xsl:apply-templates select="comment()"/>
    <abbr>
      <xsl:attribute name="title">
        <xsl:apply-templates select="acronymDefinition"/>
      </xsl:attribute>
      <xsl:apply-templates select="acronymTerm"/>
    </abbr>
  </xsl:template>

  <xsl:template match="acronymTerm|acronymDefinition">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="acronymTerm[@internalRefId]">
    <xsl:variable name="internalRefId" select="@internalRefId"/>
    <xsl:variable name="acronymDefinition" select="//acronymDefinition[@id = $internalRefId]"/>
    <abbr>
      <xsl:attribute name="title">
        <xsl:apply-templates select="$acronymDefinition"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>

  <xsl:template match="pm/content">
    <ul>
      <xsl:for-each select="pmEntry">
        <li>
          <xsl:apply-templates select="."/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="pmEntry">
    <span style="font-weight: bold;">
      <xsl:apply-templates select="pmEntryTitle"/>
    </span>
    <xsl:if test="pmEntry|dmRef">
      <ul>
        <xsl:for-each select="pmEntry|dmRef">
          <li>
            <xsl:if test="self::dmRef">
              <xsl:variable name="dmc">
                <xsl:apply-templates select="dmRefIdent/dmCode"/>
              </xsl:variable>
              <xsl:if test="$document = $dmc">
                <xsl:attribute name="style">font-weight: bold;</xsl:attribute>
              </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="."/>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="simplePara">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="listItem" mode="xref">
    <xsl:text>Step </xsl:text>
    <xsl:number count="listItem" level="multiple"/>
  </xsl:template>

  <xsl:template match="*" mode="block">
    <div>
      <xsl:apply-templates select="."/>
    </div>
  </xsl:template>

  <xsl:template match="partSpec">
    <div>
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <h2>
        <xsl:apply-templates select="partIdent"/>
      </h2>
      <xsl:apply-templates select="itemIdentData"/>
    </div>
  </xsl:template>

  <xsl:template match="toolSpec">
    <div>
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <h2>
        <xsl:apply-templates select="toolIdent"/>
      </h2>
      <xsl:apply-templates select="itemIdentData|toolAlts"/>
    </div>
  </xsl:template>

  <xsl:template match="supplySpec">
    <div>
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <h2>
        <xsl:apply-templates select="supplyIdent"/>
      </h2>
      <xsl:apply-templates select="name|shortName" mode="block"/>
    </div>
  </xsl:template>

  <xsl:template match="partIdent">
    <xsl:text>Part </xsl:text>
    <xsl:value-of select="@manufacturerCodeValue"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="@partNumberValue"/>
  </xsl:template>

  <xsl:template match="toolRepository">
    <xsl:apply-templates select="toolSpec">
      <xsl:sort select="toolIdent/@toolNumber"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="toolSpec" mode="id">
    <xsl:value-of select="toolIdent/@manufacturerCodeValue"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="toolIdent/@toolNumber"/>
  </xsl:template>

  <xsl:template match="partSpec" mode="id">
    <xsl:value-of select="partIdent/@manufacturerCodeValue"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="partIdent/@partNumberValue"/>
  </xsl:template>

  <xsl:template match="supplySpec" mode="id">
    <xsl:value-of select="supplyIdent/@supplyNumber"/>
  </xsl:template>

  <xsl:template match="toolIdent">
    <xsl:text>Tool </xsl:text>
    <xsl:value-of select="@manufacturerCodeValue"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="@toolNumber"/>
  </xsl:template>

  <xsl:template match="supplyIdent">
    <xsl:text>Supply </xsl:text>
    <xsl:value-of select="@supplyNumber"/>
  </xsl:template>

  <xsl:template match="itemIdentData">
    <h3>Item Ident Data</h3>
    <xsl:apply-templates select="*" mode="block"/>
  </xsl:template>

  <xsl:template match="descrForPart" mode="block">
    <div>
      <span style="font-weight: bold;">Description:</span>
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="shortName" mode="block">
    <div>
      <span style="font-weight: bold;">Short name:</span>
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="toolAlts">
    <h3>Tool alternatives</h3>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tool">
    <h4>Tool</h4>
    <xsl:apply-templates select="*" mode="block"/>
  </xsl:template>

  <xsl:template match="changeInline">
    <span>
      <xsl:call-template name="common-attrs"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:if test="$comments = 'show'">
      <span style="background-color: powderblue; font-weight: normal; font-style: italic;">
        <xsl:text>&lt;!-- </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> --&gt;</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="contextRules">
    <div>
      <h2>
        <xsl:text>Rules for </xsl:text>
        <xsl:choose>
          <xsl:when test="@rulesContext">
            <xsl:value-of select="@rulesContext"/>
          </xsl:when>
          <xsl:otherwise>all schemas</xsl:otherwise>
        </xsl:choose>
      </h2>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="structureObjectRuleGroup">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="structureObjectRule">
    <div style="padding: 1em; border-top: 2px solid black;">
      <h3>
        <xsl:value-of select="objectUse"/>
      </h3>
      <div>
        <span style="font-weight: bold;">
          <xsl:apply-templates select="objectPath/@allowedObjectFlag"/>
          <xsl:text>: </xsl:text>
        </span>
        <xsl:value-of select="objectPath"/>
      </div>
      <xsl:if test="objectValue">
        <div>
          <h4>Allowed values:</h4>
          <table class="prelim-rqmts-table">
            <tr>
              <th>Value</th>
              <th>Description</th>
            </tr>
            <xsl:apply-templates select="objectValue"/>
          </table>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="@allowedObjectFlag">
    <xsl:choose>
      <xsl:when test=". = '0'">Prohibited</xsl:when>
      <xsl:when test=". = '1'">Required</xsl:when>
      <xsl:otherwise>Allowed</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="objectValue">
    <tr>
      <td>
        <xsl:value-of select="@valueAllowed"/>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
