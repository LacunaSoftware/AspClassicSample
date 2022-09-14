<%

Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
httpRequest.Open "GET", "http://localhost:7282/", False
httpRequest.SetRequestHeader "Content-Type", "application/json"
httpRequest.Send()

postResponse = httpRequest.ResponseText

%>
<!DOCTYPE html>
<header>
  <meta charset="UTF-8">
  <title>ASP classic sample</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-gH2yIJqKdNHPEq0n4Mqa/HGKIhSkIHeL5AyhkYV8i59U5AR6csBvApHHNl/vI1Bx" crossorigin="anonymous" />
</header>
<body>
  <div class="container">
    <h1 class="pt-md-5">Authentication sample with ASP classic</h1>
    <form id ="form" action="authentication-complete.asp" method="post">
      <input type="hidden" id="signature" name="signature" value="">
      <input type="hidden" id="nonce" name="nonce" value="">
      <input type="hidden" id="certificate" name="certificate" value="">
      <input type="hidden" id="digestAlgorithm" name="digestAlgorithm" value="">
      <input id="response" type="hidden" name="response" value='<% Response.Write postResponse %>'>
      <div class="row pt-md-2">
        <div class="col">
          <div class="input-group mb-3">
            <select class="form-select" id="certificateSelect"></select>
            <button id="refreshBtn" class="btn btn-outline-secondary" type="button">Refresh</button>
          <button class="btn btn-primary" id="authenticationBtn" type="button">
            Authenticate
          </button>
        </div>
        <div class="pt-md-4"></div>
        <div class="form-floating">
          <textarea class="w-100 form-control bg-light" style="font-family: monospace; height: 500px;" id="logPanel"
          readonly></textarea>
        </div>
      </div>
    </form>
  </div>
  <script type="text/javascript" src="https://cdn.lacunasoftware.com/libs/web-pki/lacuna-web-pki-2.15.2.min.js"
  integrity="sha256-1YBmFfdb8pfq/5ibjis2jYVr7IaEmPokuTH7Ejbx9OE=" crossorigin="anonymous"></script>
  <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/js/bootstrap.bundle.min.js"
  integrity="sha384-A3rJD856KowSb7dwlZdYEkO39Gagi7vIsF0jrRAoQmDKKtQBHUuLZ9AsSv4jD4Xa"
  crossorigin="anonymous"></script>

  <script>
    var url = "https://localhost:7282/";
    var pki = new LacunaWebPKI();

    function start() {
      log("Initializing component ...");
      pki.init({
        ready: onWebPkiReady,
        defaultError: onWebPkiError,
      });
    }

    function onWebPkiReady() {
      log("Component ready, listing certificates ...");
      loadCertificates();
    }

    function loadCertificates() {
      pki.listCertificates().success(function (certs) {
        log(certs.length + " certificates found.");
        var select = $("#certificateSelect");
        select.find('option').remove();
        $.each(certs, function () {
          select.append(
            $("<option />")
              .val(this.thumbprint)
              .text(this.subjectName + " (issued by " + this.issuerName + ")")
          );
        });
      });
    }

    function authenticate() {
        var response = JSON.parse($("#response").val());
        console.log(response);
        var state = {};
        state.nonce = response.nonce;
        state.digestAlgorithm = response.digestAlgorithm;
         readCertificateContent(state)
        .then(signNonce)
        .then(finalizeAuthenticationProcess);
    }

    function readCertificateContent(state) {
      return new Promise(function (resolve) {
        var selectedCertThumb = $("#certificateSelect").val();
        log("Reading certificate " + selectedCertThumb);

        pki.readCertificate(selectedCertThumb).success(function (certEncoded) {
          state.certEncoded = certEncoded;
          resolve(state);
        });
      });
    }

    function signNonce(state) {
      return new Promise(function (resolve) {
        var selectedCertThumb = $("#certificateSelect").val();
        log("Signing nonce " + state.nonce + " with certificate " + selectedCertThumb + "using the digest algorithm " + state.digestAlgorithm);

        pki.signData({
          thumbprint: selectedCertThumb,
          data: state.nonce,
          digestAlgorithm: state.digestAlgorithm,
        }).success(function (signature) {
          state.signature = signature;
          resolve(state);
        });
      });
    }

    function finalizeAuthenticationProcess(state) {

        $("#nonce").val(state.nonce);
        $("#signature").val(state.signature);
        $("#certificate").val(state.certEncoded);
        $("#digestAlgorithm").val(state.digestAlgorithm);
        $("#form").submit();
    }

    function log(message) {
      $("#logPanel").append("---------------------------------------------------------\n");
      $("#logPanel").append(message + "\n");
      if (window.console) {
        window.console.log(message);
      }
    }

    function onWebPkiError(message, error, origin) {
      if (console) {
        console.log(
          "An error has occurred on the signature browser component: " +
          message,
          error
        );
      }
      alert(
        "An error has occured on the signature browser component: " + message
      );
    }

    $(function () {
      $("#authenticationBtn").click(authenticate);
      $("#refreshBtn").click(loadCertificates)
      start();
    });
  </script>
  </row>
