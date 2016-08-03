/*
 * create PEF previews from PEF code blocks
 */
insertPEFs = function() {
    var parser = new DOMParser();
    $(".code-pef").each(function(i, block) {
      var pef = parser.parseFromString(block.textContent, "application/x-pef+xml").documentElement;
      /* remove head and body because they are causing trouble */
      $(pef).children("head").remove();
      $(pef).children("body").children("volume").each(function(i, volume) {
        var vCols = parseInt(volume.getAttribute("cols"));
        var vRows = parseInt(volume.getAttribute("rows"));
        var vRowgap = parseInt(volume.getAttribute("rowgap"));
        $(volume).children().each(function(i, section) {
          var sCols = vCols;
          if (section.hasAttribute("cols"))
            sCols = parseInt(section.getAttribute("cols"));
          var sRows = vRows;
          if (section.hasAttribute("rows"))
            sRows = parseInt(section.getAttribute("rows"));
          var sRowgap = vRowgap;
          if (section.hasAttribute("rowgap"))
            sRowgap = parseInt(section.getAttribute("rowgap"));
          $(section).children().each(function(i, page) {
            var pRowgap = sRowgap;
            if (page.hasAttribute("rowgap"))
              pRowgap = parseInt(page.getAttribute("rowgap"));
            var dotLines = 0;
            $(page).children().each(function(i, row) {
              var rRowgap = pRowgap;
              if (row.hasAttribute("rowgap"))
                rRowgap = parseInt(row.getAttribute("rowgap"));
              else
                row.setAttribute("rowgap", "" + rRowgap);
              var text = row.textContent;
              for (var j = text.length; j < sCols; j++) text += "\u2800";
              $(row).text(text);
              dotLines += 4;
              dotLines += rRowgap;
            });
            for (var i = Math.ceil(dotLines/4); i < sRows; i++) {
              var text = "";
              for (var j = text.length; j < sCols; j++) text += "\u2800";
              $("<row>" + text + "</row>").appendTo(page);
            }
          });
        })
      });
      // unwrap doesn't work
      $(pef).children("body").children("volume").detach().appendTo($(pef));
      $(pef).children("body").remove();
      $(pef).appendTo(block);
    });
}

/*
 * expand shortened links and add title attributes
 */
expandLinks = function() {
    var biblio = respecConfig.biblio;
    var re = /^(.+)#(([A-Za-z]|\{\})([A-Za-z0-9_:\.\-]|\{\})*)?$/i;
    $("a").each(function(i, a) {
      var title; {
        if (a.hasAttribute("title")) {
          title = a.getAttribute("title");
          if (title == "{}") {
            title = $(a).text().replace(/\s+/g, " ");
            a.setAttribute("title", title);
          }
        }
      }
      var href = a.getAttribute("href");
      var match = href.match(re);
      if (match) {
        if (a.classList.contains("dfn")) {
          a.classList.remove("dfn");
          if (match[1] == "BRAILLECSS")
            a.classList.add("internalDFN");
          else
            a.classList.add("externalDFN");
        }
        var biblioEntry = biblio[match[1]];
        while (biblioEntry && biblioEntry["aliasOf"])
          biblioEntry = biblio[biblioEntry["aliasOf"]];
        if (biblioEntry) {
          href = biblioEntry["href"];
          if (match[2]) {
            var fragment = match[2]; {
              if (match[2].indexOf("{}") != -1) {
                if (!title) {
                  title = $(a).text().replace(/\s+/g, " ");
                  a.setAttribute("title", title);
                }
                fragment = match[2].replace("{}", title.replace(/\s+/g, "-"));
              } else
                fragment = match[2];
            }
            href = href + "#" + fragment;
          }
          a.setAttribute("href", href);
        }
      }
    });
}

/*
 * create self-links on headings and dfn
 */
createSelfLinks = function() {
    $("*[role='heading'] > .secno").wrapInner(function() {
      return "<a class='self-link' href='#" + this.parentNode.getAttribute("id") + "'></a>";
    });
    $("*[role='heading'].issue-title, dfn").wrapInner(function() {
      return "<a class='self-link' href='#" + this.getAttribute("id") + "'></a>";
    });
}

/*
 * Add links "This version", "Latest version" and "Previous
 * version". ReSpec doesn't do this when the respecStatus variable is
 * set to "unofficial".
 */
completeVersionSection = function() {
  makeLink = function(href) {
    return "<a href=\"" + href + "\">" + href + "</a>";
  };
  dateToTag = function(date) {
    var yyyy = date.getFullYear();
    var mm = date.getMonth() + 1;
    if (mm < 10)
      mm = "0" + mm;
    var dd = date.getDate();
    if (dd < 10)
      dd = "0" + dd;
    return "" + yyyy + mm + dd;
  };
  var versionInfo = "";
  var thisURI; {
    switch (respecConfig.origSpecStatus) {
    case "unofficial":
      if (Array.isArray(respecConfig.baseURI))
        thisURI = respecConfig.baseURI[0] + dateToTag(respecConfig.publishDate) + "/" + respecConfig.baseURI[1];
      else
          thisURI = respecConfig.baseURI + dateToTag(respecConfig.publishDate);
      break;
    case "unofficial-ED":
      thisURI = respecConfig.edDraftURI;
      $("#respecHeader > dl > *:first-child").remove(); // remove "Latest editor's draft"
      $("#respecHeader > dl > *:first-child").remove();
    }
    if (thisURI)
      versionInfo += ("<dt>This version</dt><dd>" + makeLink(thisURI) + "</dd>");
  }
  var latestURI; {
    if ("latestURI" in respecConfig)
      latestURI = respecConfig.latestURI;
    else if (Array.isArray(respecConfig.baseURI))
      latestURI = respecConfig.baseURI[0] + respecConfig.baseURI[1];
    else
      latestURI = respecConfig.baseURI;
  }
  switch (respecConfig.origSpecStatus) {
  case "unofficial":
    versionInfo += ("<dt>Latest version</dt>" + "<dd>" + makeLink(latestURI) + "</dd>");
    break;
  case "unofficial-ED":
    versionInfo += ("<dt>Latest published version</dt>" + "<dd>" + makeLink(latestURI) + "</dd>");
  }
  if (respecConfig.origSpecStatus == "unofficial") {
    if ("previousPublishDate" in respecConfig) {
      var prevURI; {
        if (Array.isArray(respecConfig.baseURI))
          prevURI = respecConfig.baseURI[0] + dateToTag(respecConfig.previousPublishDate) + "/" + respecConfig.baseURI[1];
        else
          prevURI = respecConfig.baseURI + dateToTag(respecConfig.previousPublishDate);
      }
      versionInfo += ("<dt>Previous version</dt><dd>" + makeLink(prevURI) + "</dd>");
    }
  }
  $("#respecHeader > dl").prepend(versionInfo);
}

/*
 *
 */
postProcessing = function() {
  respecEvents.sub("start-all", function() {
    respecConfig.origSpecStatus = respecConfig.specStatus;
    if (respecConfig.specStatus == "unofficial-ED") {
      respecConfig.specStatus = "unofficial";
    }
  });
  respecEvents.sub("end-all", insertPEFs);
  respecEvents.sub("end-all", expandLinks);
  respecEvents.sub("end-all", createSelfLinks);
  respecEvents.sub("end-all", completeVersionSection);
  respecEvents.sub("end-all", function() {
    $("a.css-propname").removeClass("css-propname").wrap("<span class='css-propname'/>");
    $("a.css-propval").removeClass("css-propval").wrap("<span class='css-propval'/>");
  });
}
