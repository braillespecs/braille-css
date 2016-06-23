<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:_xsl="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="xsl xs _xsl"
                version="2.0">
	
	<xsl:namespace-alias stylesheet-prefix="_xsl" result-prefix="xsl"/>
	
	<xsl:param name="xprocspec-test" as="xs:string" required="yes"/>
	
	<xsl:output method="xml" encoding="UTF-8" name="xml"/>
	<xsl:output method="text" encoding="UTF-8" name="text"/>
	
	<xsl:template match="/">
		<xsl:variable name="index">
			<xsl:apply-templates select="/*"/>
		</xsl:variable>
		<xsl:sequence select="$index"/>
		<xsl:result-document href="{$xprocspec-test}" format="xml">
			<x:description>
				<x:script>
					<p:declare-step type="pxi:css-inline-and-format" name="main" version="1.0">
						<p:input port="source"/>
						<p:output port="liblouis-result" primary="false">
							<p:pipe step="louis-format" port="result"/>
						</p:output>
						<p:output port="dotify-result" primary="false">
							<p:pipe step="dotify-format" port="result"/>
						</p:output>
						<p:option name="stylesheet" required="false" select="''"/>
						<p:option name="temp-dir" required="true"/>
						<p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
						<p:import href="http://www.daisy.org/pipeline/modules/braille/common-utils/library.xpl"/>
						<css:inline name="css-inline">
							<p:with-option name="default-stylesheet" select="$stylesheet"/>
						</css:inline>
						<px:transform query="(input:css)(output:pef)(formatter:liblouis)(translator:bypass)" name="louis-format">
							<p:with-option name="temp-dir" select="$temp-dir"/>
						</px:transform>
						<p:sink/>
						<px:transform query="(input:css)(output:pef)(formatter:dotify)(translator:bypass)" name="dotify-format">
							<p:input port="source">
								<p:pipe step="css-inline" port="result"/>
							</p:input>
							<p:with-option name="temp-dir" select="$temp-dir"/>
						</px:transform>
						<p:sink/>
					</p:declare-step>
				</x:script>
				<xsl:for-each select="$index//div[pxi:with-class(., 'code code-pef')]">
					<x:scenario label="{@id}">
						<x:call step="pxi:css-inline-and-format">
							<xsl:variable name="xml" select="preceding::div[pxi:with-class(., 'code code-xml')][1]"/>
							<x:input port="source">
								<x:document type="file" href="{$xml/@id}"/>
							</x:input>
							<xsl:variable name="css" select="preceding::div[pxi:with-class(., 'code code-css')]
							                                 intersect $xml/following::*
							                                 except preceding::div[pxi:with-class(., 'code code-pef')][1]/preceding::*"/>
							<xsl:if test="exists($css)">
								<x:option name="stylesheet" select="'{string-join($css/@id, ' ')}'"/>
							</xsl:if>
							<x:option name="temp-dir" select="$temp-dir"/>
						</x:call>
						<x:context label="liblouis-result">
							<x:document type="port" port="liblouis-result"/>
						</x:context>
						<x:expect label="liblouis-result" type="custom" href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl" step="x:pef-compare">
							<x:document type="file" href="{@id}"/>
						</x:expect>
						<x:context label="dotify-result">
							<x:document type="port" port="dotify-result"/>
						</x:context>
						<x:expect label="dotify-result" type="custom" href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl" step="x:pef-compare">
							<x:document type="file" href="{@id}"/>
						</x:expect>
					</x:scenario>
				</xsl:for-each>
			</x:description>
		</xsl:result-document>
		<xsl:for-each select="$index//div[pxi:with-class(., 'code')]">
			<xsl:result-document href="{resolve-uri(@id, $xprocspec-test)}" format="text">
				<xsl:value-of select="string(pre)"/>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="div[pxi:with-class(., 'code code-xml') and not(@id)]">
		<xsl:copy>
			<xsl:attribute name="id" select="concat('xml_', 1 + count(preceding::div[pxi:with-class(., 'code code-xml') and not(@id)]), '.xml')"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="div[pxi:with-class(., 'code code-css') and not(@id)]">
		<xsl:copy>
			<xsl:attribute name="id" select="concat('css_', 1 + count(preceding::div[pxi:with-class(., 'code code-css') and not(@id)]), '.css')"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="div[pxi:with-class(., 'code code-pef') and not(@id)]">
		<xsl:copy>
			<xsl:attribute name="id" select="concat('pef_', 1 + count(preceding::div[pxi:with-class(., 'code code-pef') and not(@id)]), '.pef')"/>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:function name="pxi:with-class" as="xs:boolean">
		<xsl:param name="element" as="element()"/>
		<xsl:param name="class" as="xs:string"/>
		<xsl:sequence select="every $c in tokenize(normalize-space($class), ' ')
		                      satisfies tokenize(normalize-space($element/@class), ' ')=$c"/>
	</xsl:function>
	
</xsl:stylesheet>
