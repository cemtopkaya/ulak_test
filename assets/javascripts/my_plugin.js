$(document).ready(function () {
    console.log("my_plugin.js");
    var $history = $("#history")
    var $ul = $history.find("div.tabs ul")
    // var $li = $("<li><a id=\"tab-test_results\" class=\"selected\" onclick=\"getRemoteTab('test_results', '/issues/1448/tab/cem_entries', '/issues/1448?tab=test_results'); return false;\" href=\"/issues/1448?tab=test_results\">Test Results</a></li>")
    $("<li>").html(
        $("<a />", {
            id: "tab-test_results",
            class: "",
            onclick: "getRemoteTab('test_results', '/my_plugin/1448', '/issues/1448?tab=test_results'); return false;",
            href: "/issues/1448?tab=test_results",
            text: "Test Results"
        })
    ).appendTo($ul)

    $('<div>', {
        id: 'tab-content-test_results',
        class: 'tab-content',
        title: 'Test results will be displayed in this section',
        style: 'display: none;'
    }).html('test sonuçları içerik').appendTo($history);
})

function cem() {
    var topmenu = document.getElementById("top-menu");
    var divdark = document.createElement("div");
    divdark.id = "dark";
    var adivdark = document.createElement("a");
    adivdark.innerText = "dark mode";
    adivdark.href = "";
    divdark.appendChild(adivdark);
    topmenu.insertBefore(divdark, topmenu.firstChild)
    adivdark.onclick = clickdarkmode;
    try {
        var ulmobil = document.querySelectorAll('#wrapper .js-profile-menu ul')[0];
        var lidark = document.createElement("li");
        var alidark = document.createElement("a");
        alidark.innerText = "dark mode";
        alidark.href = "";
        lidark.appendChild(alidark);
        ulmobil.appendChild(lidark);
        alidark.onclick = clickdarkmode;
    } catch (e) { }
    let initdark = getCookie(getCookieName());
    if (initdark == "on") {
        clickdarkmode();
    }
}

