<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="1.1" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	exclude-result-prefixes="fo">

<xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>

<!-- ATTRIBUTE SETS (like css...) -->

<!-- tables -->
<xsl:attribute-set name="bordered">
	<xsl:attribute name="border-bottom-style">solid</xsl:attribute>
	<xsl:attribute name="border-bottom-color">#999999</xsl:attribute>
	<xsl:attribute name="border-bottom-width">0.5pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="tc" use-attribute-sets="bordered">
	<xsl:attribute name="background-color">#F0F0F0</xsl:attribute>
	<xsl:attribute name="padding-left">4pt</xsl:attribute>
	<xsl:attribute name="padding-bottom">2pt</xsl:attribute>
</xsl:attribute-set>

<!-- normal text -->
<xsl:attribute-set name="normal">
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="color">#000000</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="bold">
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<!-- heading text -->
<xsl:attribute-set name="title">
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="color">#000000</xsl:attribute>
	<xsl:attribute name="space-before">10pt</xsl:attribute>
	<xsl:attribute name="space-after">5pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="titleh1" use-attribute-sets="title">
	<xsl:attribute name="font-size">16pt</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="titleh2" use-attribute-sets="title">
	<xsl:attribute name="font-size">14pt</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="titleh3" use-attribute-sets="title">
	<xsl:attribute name="font-size">12pt</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<!-- start processing the content -->
<xsl:template match="/report">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
		<fo:layout-master-set>
			<fo:simple-page-master master-name="page" page-height="29.7cm" page-width="21cm" margin-top="20pt" margin-bottom="20pt" margin-left="20pt" margin-right="20pt">
				<fo:region-body margin-top="80pt" margin-bottom="40pt" margin-left="0pt" margin-right="0pt" />
				<fo:region-before />
				<fo:region-after />
			</fo:simple-page-master>
		</fo:layout-master-set>
		<fo:page-sequence master-reference="page">

			<!-- PAGE HEADER -->
			<fo:static-content flow-name="xsl-region-before">
				<fo:block-container height="80pt" width="420pt" top="0pt" left="0pt" position="absolute">
					<fo:block font-family="Arial" color="#535353" font-size="20pt" font-weight="normal">
						<xsl:value-of select="head/title" />
					</fo:block>
					<fo:block font-family="Arial" color="#535353" font-size="12pt">
						<xsl:value-of select="head/date" />
					</fo:block>
				</fo:block-container>
				<fo:block-container height="80pt" width="170pt" top="0pt" left="480pt" position="absolute">
					<fo:block font-family="Verdana" color="#BDE451" font-size="16pt" font-weight="normal">
						<xsl:text>eGyűlés</xsl:text>
					</fo:block>
					<fo:block font-family="Verdana" color="#535353" font-size="12pt" font-weight="normal">
						<xsl:text>by Netlock</xsl:text>
					</fo:block>
				</fo:block-container>
			</fo:static-content>

			<!-- PAGE FOOTER -->
			<fo:static-content flow-name="xsl-region-after">
				<fo:block-container height="20pt" width="480pt" top="0pt" left="0pt" position="absolute">
					<fo:block text-align="right" color="#535353" font-size="10pt">
						<fo:page-number /><xsl:text> / </xsl:text>
						<fo:page-number-citation ref-id="last-page" />
					</fo:block>
				</fo:block-container>
			</fo:static-content>

			<!-- BODY -->
			<fo:flow flow-name="xsl-region-body">
				<xsl:apply-templates select="body/*" />
				<fo:block id="last-page" />
			</fo:flow>

		</fo:page-sequence>
	</fo:root>
</xsl:template>

<!-- headings -->
<xsl:template match="h1">
	<fo:block xsl:use-attribute-sets="titleh1"><xsl:value-of select="current()" /></fo:block>
</xsl:template>
<xsl:template match="h2">
	<fo:block xsl:use-attribute-sets="titleh2"><xsl:value-of select="current()" /></fo:block>
</xsl:template>
<xsl:template match="h3|h4|h5|h6">
	<fo:block xsl:use-attribute-sets="titleh3"><xsl:value-of select="current()" /></fo:block>
</xsl:template>

<!-- paragraphs, text formats (bold, etc) -->
<xsl:template match="p">
	<fo:block xsl:use-attribute-sets="normal" space-before="10pt">
		<xsl:apply-templates />
	</fo:block>
</xsl:template>

<xsl:template match="br">
	<fo:block />
</xsl:template>

<xsl:template match="strong|b">
	<fo:inline xsl:use-attribute-sets="bold">
		<xsl:apply-templates />
	</fo:inline>
</xsl:template>

<xsl:template match="u">
	<fo:inline text-decoration="underline">
		<xsl:apply-templates />
	</fo:inline>
</xsl:template>

<!-- lists -->
<xsl:template match="ul|ol">
	<fo:list-block space-before="10pt" provisional-distance-between-starts="20pt" provisional-label-separation="10pt">
		<xsl:apply-templates select="li" />
	</fo:list-block>
</xsl:template>

<xsl:template match="li">
	<fo:list-item>
		<fo:list-item-label end-indent="label-end()"><fo:block>*</fo:block></fo:list-item-label>
		<fo:list-item-body start-indent="body-start()">
			<fo:block xsl:use-attribute-sets="normal"><xsl:apply-templates /></fo:block>
		</fo:list-item-body>
	</fo:list-item>
</xsl:template>

<!-- table -->
<xsl:template match="table">
	<fo:table xsl:use-attribute-sets="bordered">
		<xsl:apply-templates select="tbody|thead" />
	</fo:table>
</xsl:template>
		
<xsl:template match="tbody">
	<fo:table-body>
		<xsl:apply-templates select="tr" />
	</fo:table-body>
</xsl:template>
		
<xsl:template match="tr">
	<fo:table-row>
		<xsl:apply-templates select="th|td" />
	</fo:table-row>
</xsl:template>

<xsl:template match="th|td">
	<fo:table-cell xsl:use-attribute-sets="tc">
		<fo:block xsl:use-attribute-sets="normal"><xsl:apply-templates /></fo:block>
	</fo:table-cell>
</xsl:template>


<!-- anything else - red warning -->
<xsl:template match="*">
	<fo:block color="#ff0000"><xsl:value-of select="current()" /></fo:block>
</xsl:template>

</xsl:stylesheet>
