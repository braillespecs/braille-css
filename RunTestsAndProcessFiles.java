import java.io.File;
import java.net.URI;
import java.util.Hashtable;
import java.util.Map;
import javax.inject.Inject;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltTransformer;

import org.daisy.maven.xproc.api.XProcEngine;
import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.XProcTransform;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.xprocspecBundles;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.options.MavenArtifactProvisionOption;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;

import org.osgi.framework.BundleContext;

import org.slf4j.Logger;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class RunTestsAndProcessFiles {
	
	@Configuration
	public Option[] config() {
		return options(
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/logback.xml"),
			systemProperty("org.daisy.pipeline.xproc.configuration").value(PathUtils.getBaseDir() + "/config-calabash.xml"),
			systemProperty("com.xmlcalabash.config.user").value(""),
			domTraversalPackage(),
			logbackBundles(),
			felixDeclarativeServices(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.pef-tools").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			mavenBundle().groupId("org.unbescape").artifactId("unbescape").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-css").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.common").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.translator.impl").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.formatter.impl").versionAsInProject(),
			brailleModule("liblouis-core"),
			brailleModule("liblouis-saxon"),
			brailleModule("liblouis-calabash"),
			brailleModule("liblouis-utils"),
			brailleModule("liblouis-formatter"),
			brailleModule("dotify-core"),
			brailleModule("dotify-saxon"),
			brailleModule("dotify-calabash"),
			brailleModule("dotify-utils"),
			brailleModule("dotify-formatter"),
			brailleModule("css-core"),
			brailleModule("css-calabash"),
			brailleModule("css-utils"),
			brailleModule("pef-core"),
			brailleModule("pef-calabash"),
			brailleModule("pef-saxon"),
			brailleModule("pef-utils"),
			brailleModule("common-utils"),
			forThisPlatform(brailleModule("liblouis-native")),
			pipelineModule("file-utils"),
			pipelineModule("common-utils"),
			pipelineModule("html-utils"),
			pipelineModule("zip-utils"),
			pipelineModule("mediatype-utils"),
			pipelineModule("fileset-utils"),
			xprocspecBundles(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("saxon-adapter").versionAsInProject(),
			junitBundles()
		);
	}
	
	@Inject
	private BundleContext context;
	
	@Before
	public void registerBypassBlockTransformProvider() {
		BypassBlockTransform.Provider provider = new BypassBlockTransform.Provider();
		Hashtable<String,Object> properties = new Hashtable<String,Object>();
		context.registerService(CSSBlockTransform.Provider.class.getName(), provider, properties);
		context.registerService(XProcTransform.Provider.class.getName(), provider, properties);
	}
	
	private static class BypassBlockTransform extends AbstractTransform implements CSSBlockTransform, XProcTransform {
		private final URI href = asURI(new File(new File(PathUtils.getBaseDir()), "identity.xpl"));
		public Tuple3<URI,javax.xml.namespace.QName,Map<String,String>> asXProc() {
			return new Tuple3<URI,javax.xml.namespace.QName,Map<String,String>>(href, null, null);
		}
		private static final Iterable<BypassBlockTransform> instance = Optional.of(new BypassBlockTransform()).asSet();
		private static final Iterable<BypassBlockTransform> empty = Optional.<BypassBlockTransform>absent().asSet();
		public static class Provider implements CSSBlockTransform.Provider<BypassBlockTransform>, XProcTransform.Provider<BypassBlockTransform> {
			public Iterable<BypassBlockTransform> get(String query) {
				return query.equals("(translator:bypass)") ? instance : empty;
			}
			public Transform.Provider<BypassBlockTransform> withContext(Logger context) {
				return this;
			}
		}
	}
	
	@Inject
	private XProcSpecRunner runner;
	
	@Inject
	private Processor processor;
	
	@Inject
	private XProcEngine engine;
	
	private File baseDir;
	private File xprocspecTest;
	private File xprocspecReport;
	private XsltCompiler compiler;
	
	@Test
	public void run() throws Exception {
		if ("".equals("${source}") || "".equals("${target}"))
			throw new RuntimeException("source or target not specified");
		baseDir = new File(PathUtils.getBaseDir());
		xprocspecTest = new File(baseDir, "target/generated-test-sources/test.xprocspec");
		xprocspecReport = new File(baseDir, "target/xprocspec-reports/test.html");
		compiler = processor.newXsltCompiler();
		Source source = new StreamSource(new File(baseDir, "${source}"));
		File target = new File(baseDir, "${target}");
		XdmNode tmp;
		tmp = combineSources(source);
		if (!${my.skipTests}) {
			tmp = extractTests(tmp.asSource());
			runTests();
			tmp = includeTestResults(tmp.asSource()); }
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
	
	private XdmNode extractTests(Source source) throws SaxonApiException {
		XsltTransformer transformer = compiler.compile(new StreamSource(new File(baseDir, "extract-tests.xsl"))).load();
		XdmDestination dest = new XdmDestination();
		transformer.setSource(source);
		transformer.setDestination(dest);
		transformer.setParameter(new QName("xprocspec-test"), new XdmAtomicValue(xprocspecTest.toURI()));
		transformer.transform();
		return dest.getXdmNode();
	}
	
	private void runTests() {
		runner.run(ImmutableMap.of("test", xprocspecTest),
		           new File(xprocspecReport.getParent()),
		           new File(baseDir, "target/surefire-reports"),
		           new File(baseDir, "target/xprocspec"),
		           null,
		           new XProcSpecRunner.Reporter.DefaultReporter());
	}
	
	private XdmNode includeTestResults(Source source) throws SaxonApiException {
		XsltTransformer transformer = compiler.compile(new StreamSource(new File(baseDir, "include-test-results.xsl"))).load();
		XdmDestination dest = new XdmDestination();
		transformer.setSource(source);
		transformer.setDestination(dest);
		transformer.setParameter(new QName("xprocspec-report"), new XdmAtomicValue(xprocspecReport.toURI()));
		transformer.transform();
		return dest.getXdmNode();
	}
}
