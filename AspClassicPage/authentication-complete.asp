<script runat="server" language="JScript" src="json2.js"></script>
<%

Dim data, httpRequest, postResponse


signature  = request.form("signature")
nonce = request.form("nonce")
certificate = request.form("certificate")
digestAlgorithm = request.form("digestAlgorithm")



req = ""
req = req & "{"
req = req & Chr(34) & "signature"  &  Chr(34) & ":" & Chr(34) & signature & Chr(34) & ","
req = req & Chr(34) & "nonce"  &  Chr(34) & ":" &  Chr(34) & nonce & Chr(34) & ","
req = req & Chr(34) & "certificate"  &  Chr(34) & ":" & Chr(34) & certificate & Chr(34) & ","
req = req & Chr(34) & "digestAlgorithm"  &  Chr(34) & ":" &  Chr(34) & digestAlgorithm & Chr(34)
req = req & "}"


Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
httpRequest.Open "POST", "https://localhost:7282/", False
httpRequest.SetRequestHeader "Content-Type", "application/json"
httpRequest.Send req

Set responseJson = JSON.parse(httpRequest.responseText)


%>
<!DOCTYPE html>
<header>
  <meta charset="UTF-8">
  <title>ASP classic sample</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-gH2yIJqKdNHPEq0n4Mqa/HGKIhSkIHeL5AyhkYV8i59U5AR6csBvApHHNl/vI1Bx" crossorigin="anonymous" />
</header>
<div class="container text-center col-md-4">
<h3 class="pt-md-5">Authentication Information</h3>
    <div class="card text-center">
        <ul class="list-group list-group-flush">
          <li class="list-group-item"><% Response.Write responseJson.subjectName %></li>
          <li class="list-group-item"><% Response.Write responseJson.cpf %></li>
        </ul>
      </div>
</div>

