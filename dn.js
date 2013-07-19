function init(player, offset, set_offset, video_url, audio_url) {
    // set up toggle functionality
    $("#"+player).after("<button id='toggle'>Switch to " +
                        (prefersVideo() ? "audio" : "video") + "</button>");
    $("#toggle").click(function () {
        window.localStorage["dn-prefers-video"] = !prefersVideo();
        location.reload();
    });

    // put player on the page
    if (canPlayVideo() && prefersVideo()) {
        $("#"+player).html("<video id='player' width='320' height='180' controls src='" +
                           video_url + "'></video>");
    } else {
        $("#"+player).html("<audio id='player' width='320' controls src='" +
                           audio_url + "'></audio>");
    }

    // seek / start the player, if applicable
    if (isDesktopChrome()) {
        $("#player").one("canplay", function () {
            var player = this;
            if (offset != 0) {
                player.currentTime = offset;
            }
            player.play();
            window.setInterval(update_time(set_offset), 1000);
        });
    } else if (isiOS() || isAndroidChrome()) {
        // iOS doesn't let you seek till much later... and won't let you start automatically,
        // so calling play() is pointless
	$("#player").one("canplaythrough",function () {
	    $("#player").one("progress", function () {
		if (offset != 0) {
                    $("#player")[0].currentTime = offset;
                }
                window.setInterval(update_time(set_offset), 1000);
	    });
	});   
    } else {
        $("#player").after("<h3>As of now, the player does not support your browser.</h3>");
    }
}

// the function that grabs the time and updates it, if needed
function update_time(setter) {
    return function () {
        var player = $("#player")[0];
        if (!player.paused) {
            // a transaction is a function from unit to value, hence the extra call
            execF(execF(setter, player.currentTime), null)
        }
    };
}

// browser detection / preference storage

function canPlayVideo() {
    var v = document.createElement('video');
    return (v.canPlayType && v.canPlayType('video/mp4').replace(/no/, ''));
}

function prefersVideo() {
    return (!window.localStorage["dn-prefers-video"] || window.localStorage["dn-prefers-video"] == "true");
}

function isiOS() {
    var ua = navigator.userAgent.toLowerCase();
    return (ua.match(/(ipad|iphone|ipod)/) !== null);
}

function isDesktopChrome () {
    var ua = navigator.userAgent.toLowerCase();
    return (ua.match(/chrome/) !== null) && (ua.match(/mobile/) == null);
}

function isAndroidChrome () {
    var ua = navigator.userAgent.toLowerCase();
    return (ua.match(/chrome/) !== null) && (ua.match(/android/) !== null);
}
