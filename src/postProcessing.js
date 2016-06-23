/*
 * create PEF previews from PEF code blocks
 */
insertPEFs = function() {
  respecEvents.sub("end-all", function() {
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
  });
}
/*
 * expand shortened links
 */
expandLinks = function() {
  respecEvents.sub("end-all", function() {
    var biblio = respecConfig.biblio;
    var re = /^(.+)#([A-Za-z][A-Za-z0-9_:\.\-]*)?$/i;
    $("a").each(function(i, a) {
      var href = a.getAttribute("href");
      var match = href.match(re);
      if (match) {
        var biblioEntry = biblio[match[1]];
        while (biblioEntry && biblioEntry["aliasOf"])
          biblioEntry = biblio[biblioEntry["aliasOf"]];
        if (biblioEntry) {
          href = biblioEntry["href"];
          if (match[2])
            href = href + "#" + match[2]
          a.setAttribute("href", href);
        }
      }
    });
  });
}
/*
 * create self-links on headings and dfn
 */
createSelfLinks = function() {
  respecEvents.sub("end-all", function() {
    $("*[role='heading'] > .secno").wrapInner(function() {
      return "<a class='self-link' href='#" + this.parentNode.getAttribute("id") + "'></a>";
    });
    $("*[role='heading'].issue-title, dfn").wrapInner(function() {
      return "<a class='self-link' href='#" + this.getAttribute("id") + "'></a>";
    });
  });
}
/*
 *
 */
postProcessing = function() {
  insertPEFs();
  expandLinks();
  createSelfLinks();
  respecEvents.sub("end-all", function() {
    $("a.css-propname").removeClass("css-propname").wrap("<span class='css-propname'/>");
    $("a.css-propval").removeClass("css-propval").wrap("<span class='css-propval'/>");
  });
}
