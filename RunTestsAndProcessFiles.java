import java.io.File;
import java.net.URI;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltTransformer;

import org.junit.Before;
import org.junit.Test;

/**
 * This class also used to convert the examples to XProcSpec tests and
 * include the test results in the specification. If you want to
 * restore this functionality have a look at the Git history. */
public class RunTestsAndProcessFiles {
	
	private File baseDir;
	private XsltCompiler compiler;
	
	@Test
	public void run() throws Exception {
		if ("".equals("${source}") || "".equals("${target}"))
			throw new RuntimeException("source or target not specified");
		baseDir = new File(new File(this.getClass().getResource("/").toURI()), "../..");
		Processor processor = new Processor(false);
		compiler = processor.newXsltCompiler();
		Source source = new StreamSource(new File(baseDir, "${source}"));
		File target = new File(baseDir, "${target}");
		XdmNode tmp;
		tmp = combineSources(source);
		new Serializer(target).serializeNode(tmp);
	}
	
	// TODO: use XProc's p:xinclude
	private XdmNode combineSources(Source source) throws SaxonApiException {
		XsltTransformer transformer = compiler.compile(new StreamSource(new File(baseDir, "combine-sources.xsl"))).load();
		XdmDestination dest = new XdmDestination();
		transformer.setSource(source);
		transformer.setDestination(dest);
		transformer.transform();
		
		// FIXME: index.getXdmNode() should have the same base URI as index!
		return dest.getXdmNode();
	}
}
