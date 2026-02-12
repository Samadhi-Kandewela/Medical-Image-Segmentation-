
function showImageByUID(uid) {
    if (navigator.appName == "Microsoft Internet Explorer") {
        parent.rptToolFrame.document.ReportingToolApplet.showImageByUID(uid);
    }

    if (navigator.appName == "Mozilla" || navigator.appName == "Netscape") {
        parent.rptToolFrame.document.embeds['ReportingToolApplet'].showImageByUID(uid);
    }
}

function showSRByUID(uid) {
    if (navigator.appName == "Microsoft Internet Explorer") {
        parent.rptToolFrame.document.ReportingToolApplet.showSRByUID(uid);
    }

    if (navigator.appName == "Mozilla" || navigator.appName == "Netscape") {
        parent.rptToolFrame.document.embeds['ReportingToolApplet'].showSRByUID(uid);
    }
}

function reportFrameLoaded_firefox() {
    parent.rptToolFrame.document.embeds['ReportingToolApplet'].reportFrameLoaded = true;
}

// On Firefox, notify ReportingToolApplet when loading of this frame is
// finished. This is a workaround for fast switching between HTML and PDF
// format bug.
if (navigator.userAgent.indexOf('Firefox/') >= 0) {
    parent.rptToolFrame.document.embeds['ReportingToolApplet'].userAgent = navigator.userAgent;

    window.onload = reportFrameLoaded_firefox;
}

