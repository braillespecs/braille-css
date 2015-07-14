<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                exclude-result-prefixes="#all"
                version="2.0">
	
	<xsl:param name="xprocspec-report" as="xs:string" required="yes"/>
	
	<xsl:variable name="xprocspec-report-doc" select="doc($xprocspec-report)"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="div[pxi:with-class(., 'code pef')]">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:variable name="id" select="@id"/>
			<xsl:variable name="liblouis-passed" as="xs:boolean"
			              select="contains(normalize-space(
			                        $xprocspec-report-doc//html:th[@class='scenario-label' and string()=$id]
			                          /following::html:th[@class='context-label' and string()='liblouis-result'][1]
			                          /following-sibling::html:th[1]),
			                        'pending:0 / failed:0 / errors:0')"/>
			<xsl:variable name="dotify-passed" as="xs:boolean"
			              select="contains(normalize-space(
			                        $xprocspec-report-doc//html:th[@class='scenario-label' and string()=$id]
			                          /following::html:th[@class='context-label' and string()='dotify-result'][1]
			                          /following-sibling::html:th[1]),
			                        'pending:0 / failed:0 / errors:0')"/>
			<div class="test test-liblouis {if ($liblouis-passed) then 'test-passed' else 'test-failed'}"
			     title="Liblouis test {if ($liblouis-passed) then 'passed' else 'failed'}"/>
			<div class="test test-dotify {if ($dotify-passed) then 'test-passed' else 'test-failed'}"
			     title="Dotify test {if ($dotify-passed) then 'passed' else 'failed'}"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:function name="pxi:with-class" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		<xsl:param name="class" as="xs:string"/>
		<xsl:sequence select="every $c in tokenize(normalize-space($class), ' ')
		                      satisfies tokenize(normalize-space($element/@class), ' ')=$c"/>
	</xsl:function>

</xsl:stylesheet>
