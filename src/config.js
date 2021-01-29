function respecConfig(config) {
	respecConfig = {
		specStatus: "unofficial",
		publishDate: "2021-01-29",
		previousPublishDate: "2018-10-31",
		previousMaturity: "unofficial",
		editors: [{
			name:   "Bert Frees",
			mailto: "bertfrees@gmail.com",
			url:    "http://github.com/bertfrees" }],
		additionalCopyrightHolders: "Copyright © 2014-2021 Bert Frees",
		otherLinks: [{
			key: "Feedback",
			data: [{
				value: "https://github.com/braillespecs/braille-css/issues",
				href: "https://github.com/braillespecs/braille-css/issues" }]}],
		specrefUrl: "${SPECREF_URL}",
		localBiblio: localBiblio
	}
	for (var attr in config)
		respecConfig[attr] = config[attr];
}
