function respecConfig(config) {
	respecConfig = {
		specStatus: "unofficial",
		publishDate: "2018-10-31",
		previousPublishDate: "2016-12-01",
		editors: [{
			name:   "Bert Frees",
			mailto: "bertfrees@gmail.com",
			url:    "http://github.com/bertfrees" }],
		additionalCopyrightHolders: "Copyright © 2014-2018 Bert Frees",
		otherLinks: [{
			key: "Feedback",
			data: [{
				value: "https://github.com/braillespecs/braille-css/issues",
				href: "https://github.com/braillespecs/braille-css/issues" }]}],
		specrefUrl: "http://specref:5000",
		localBiblio: localBiblio
	}
	for (var attr in config)
		respecConfig[attr] = config[attr];
}


