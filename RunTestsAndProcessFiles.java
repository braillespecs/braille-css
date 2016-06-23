import java.io.File;
import java.net.URI;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.inject.Inject;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import static com.google.common.collect.Iterables.size;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltTransformer;

import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.maven.xproc.api.XProcEngine;
import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.CSSStyledText;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackClassic;
import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.mavenBundlesWithDependencies;
import static org.daisy.pipeline.pax.exam.Options.xprocspec;

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
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;

import org.osgi.framework.BundleContext;

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
			felixDeclarativeServices(),
			junitBundles(),
			mavenBundlesWithDependencies(
				brailleModule("css-utils"),
				brailleModule("pef-utils"),
				brailleModule("common-utils"),
				brailleModule("liblouis-utils"),
				brailleModule("liblouis-native").forThisPlatform(),
				brailleModule("liblouis-formatter"),
				brailleModule("dotify-utils"),
				brailleModule("dotify-formatter"),
				// logging
				logbackClassic(),
				mavenBundle("org.slf4j:jul-to-slf4j:?"),
				mavenBundle("org.daisy.pipeline:logging-activator:?"),
				// xprocspec
				xprocspec(),
				mavenBundle("org.daisy.maven:xproc-engine-daisy-pipeline:?"),
				// xslt
				mavenBundle("org.daisy.pipeline:saxon-adapter:?").versionAsInProject())
		);
	}
	
	@Inject
	private BundleContext context;
	
	@Before
	public void registerBypassTranslatorProvider() {
		BypassTranslator.Provider provider = new BypassTranslator.Provider();
		Hashtable<String,Object> properties = new Hashtable<String,Object>();
		context.registerService(BrailleTranslatorProvider.class.getName(), provider, properties);
		context.registerService(TransformProvider.class.getName(), provider, properties);
	}
	
	private static class BypassTranslator extends AbstractBrailleTranslator {
		
		private final static Pattern NUMBER = Pattern.compile("[0-9]+");
		private final static String NUMSIGN = "\u283c";
		private final static String[] DIGIT_TABLE = new String[]{
			"\u281a","\u2801","\u2803","\u2809","\u2819","\u2811","\u280b","\u281b","\u2813","\u280a"};
		
		private static String translateNumbers(String text) {
			Matcher m = NUMBER.matcher(text);
			int idx = 0;
			StringBuilder sb = new StringBuilder();
			for (; m.find(); idx = m.end()) {
				sb.append(text.substring(idx, m.start()));
				sb.append(translateNaturalNumber(Integer.parseInt(m.group()))); }
			if (idx == 0)
				return text;
			sb.append(text.substring(idx));
			return sb.toString();
		}
		
		private static String translateNaturalNumber(int number) {
			StringBuilder sb = new StringBuilder();
			sb.append(NUMSIGN);
			if (number == 0)
				sb.append(DIGIT_TABLE[0]);
			while (number > 0) {
				sb.insert(1, DIGIT_TABLE[number % 10]);
				number = number / 10; }
			return sb.toString();
		}
		
		private String transform(String text, SimpleInlineStyle style) {
			if (style != null && !style.isEmpty())
				throw new RuntimeException("style not supported: " + style);
			return translateNumbers(text);
		}
		
		@Override
		public FromStyledTextToBraille fromStyledTextToBraille() {
			return fromStyledTextToBraille;
		}
		
		private final FromStyledTextToBraille fromStyledTextToBraille = new FromStyledTextToBraille() {
			public java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText) {
				int size = size(styledText);
				String[] braille = new String[size];
				int i = 0;
				for (CSSStyledText t : styledText)
					braille[i++] = BypassTranslator.this.transform(t.getText(), t.getStyle());
				return Arrays.asList(braille);
			}
		};
		
		private final static XProc xproc = new XProc(asURI(new File(new File(PathUtils.getBaseDir()), "bypass.xpl")), null, null);
		
		public XProc asXProc() {
			return xproc;
		}
		
		public static class Provider extends AbstractTransformProvider<BypassTranslator> implements BrailleTranslatorProvider<BypassTranslator> {
			private static final Iterable<BypassTranslator> instance = Iterables.of(new BypassTranslator());
			private static final Iterable<BypassTranslator> empty = Iterables.<BypassTranslator>empty();
			private final static List<String> supportedInput = ImmutableList.of("css","text-css");
			private final static List<String> supportedOutput = ImmutableList.of("css","braille");
			public Iterable<BypassTranslator> _get(Query query) {
				final MutableQuery q = mutableQuery(query);
				for (Feature f : q.removeAll("input"))
					if (!supportedInput.contains(f.getValue().get()))
						return empty;
				for (Feature f : q.removeAll("output"))
					if (!supportedOutput.contains(f.getValue().get()))
						return empty;
				if (q.containsKey("translator")) {
					if ("bypass".equals(q.removeOnly("translator").getValue().get()))
						if (q.isEmpty())
							return instance; }
				return empty;
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
