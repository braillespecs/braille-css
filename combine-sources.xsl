<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                exclude-result-prefixes="xsl xi"
                version="2.0">
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="script[@id='respec']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="src" select="resolve-uri(@src, base-uri(/*))"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="xi:include">
		<xsl:apply-templates select="document(@href)/*" />
	</xsl:template>
	
</xsl:stylesheet>
