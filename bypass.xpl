<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline type="pxi:bypass"
            xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
            xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
            xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal">
	
	<p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
	
	<css:parse-properties properties="display"/>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="bypass.xsl"/>
		</p:input>
	</p:xslt>
	
</p:pipeline>
