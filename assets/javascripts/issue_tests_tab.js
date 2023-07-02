console.log("my_plugin.js");

function my_plugin() {
  let { issue_id: issueId, issue_tests: issueTests } = issueData

  // function getRemoteTab(name, remote_url, url, load_always) {
  let name = 'test_results'
  remote_url = `/my_plugin/${issueId}/tab/test_results`;
  url = `/issues/${issueId}?tab=test_results`;
  // Tab'ın başlığını oluşturup sekmelerin yanına yerleştirelim
  let $tabTestResultHeader = $("<a />", {
    id: "tab-test_results",
    class: "",
    onclick: `getRemoteTab('${name}', '${remote_url}', '${url}'); return false;`,
    href: `/issues/${issueId}?tab=test_results`,
    text: "Test Results"
  });

  let $history = $("#history")
  let $history_ul = $history.find("div.tabs ul")
  $("<li>").html($tabTestResultHeader).appendTo($history_ul)

  // Testleri SELECT2 içinde gösterelim
  let $selectTests = $('<select />', {
    multiple: 'multiple',
    class: 'form-control',
    id: 'test_name_input',
    style: 'width: 400px;',
    'data-minimum-results-for-search': 'Infinity'
  });

  let $tabContentTests = $('<div>', {
    id: 'tab-content-test_results',
    class: 'tab-content',
    title: 'Test results will be displayed in this section',
    style: 'display: none;'
  })
  $tabContentTests.html($selectTests).appendTo($history);

  function testleriGetir() {
    $.get(`/my_plugin/tests/issues/${issueId}`).then(
      tests => {
        window.$selectTests = $('#test_name_input').select2({
          tags: true,
          multiple: true,
          minimumInputLength: 1,
          data: tests,
          ajax: {
            // url: 'https://api.myjson.com/bins/444cr',
            url: '/my_plugin/tests',
            width: '100%',
            dataType: 'json',
            delay: 250,
            data: function (params) {
              return {
                q: params.term, // arama terimini gönderin
                page: params.page
              };
            },
            createSearchChoice: function (term) {
              return false;
            },
            noResults: function () {
              return 'No results found'
            },
            searching: function () {
              return 'Searching…'
            },
            processResults: function (data, params) {
              console.log(`>>> tests data: ${data} >>> params: ${params}`);
              // sonuçları dönüştürün ve select2 formatına uygun hale getirin
              if (data && Array.isArray(data) && data.length == 0) {
                results = []
              } else {
                results = data.map(function (d) { return { id: d, text: d } })
              }

              return {
                results,
                pagination: {
                  more: (params.page * 30) < data.total_count
                }
              };
            },
            cache: true
          }
        });

        window.$selectTests.on('select2:select', function (e) {
          console.log('>>> Seçildi');
          console.log(e);
          var data = e.params.data;
          console.log(data);
          $.post(`/my_plugin/issues/1/tests/${data.id}`, {}).done(r => { alert(`Test eklendi: ${r}`); });
        });

        window.$selectTests.on('select2:unselect', function (e) {
          console.log('>>> Silindi');
          console.log(e);
          var data = e.params.data;
          console.log(data);
          $.ajax({
            url: `/my_plugin/issues/1/tests/${data.id}`,
            type: 'DELETE',
            success: function (result) {
              alert('Kayıt Silindi!');
            }
          });
        });

        window.$selectTests.val(tests).trigger('change.select2');
      })
  }

  if (typeof $.fn.select2 === 'undefined') {
    // select2 kütüphanesi yüklü değil, yükleyin
    var link = document.createElement('link');
    link.href = 'https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/css/select2.min.css';
    link.rel = 'stylesheet';
    link.type = 'text/css';
    document.head.appendChild(link);

    var script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js';
    document.head.appendChild(script);
    script.onload = testleriGetir;
  } else {
    testleriGetir();
  }

}

$(document).ready(function () {
  my_plugin();
});


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

