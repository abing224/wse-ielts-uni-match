$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:3000/")
$listener.Start()
Write-Host "WSE Pathway Web Server listening on http://localhost:3000/"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $rawPath = $request.Url.LocalPath
        if ($rawPath -eq "/") { $rawPath = "/index.html" }
        $relPath = $rawPath.TrimStart('/')
        
        # Resolve path relative to the directory containing this script
        $localPath = Join-Path $PSScriptRoot $relPath
        
        if (Test-Path $localPath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($localPath)
            $response.ContentLength64 = $bytes.Length
            if ($localPath.EndsWith(".html")) {
                $response.ContentType = "text/html; charset=utf-8"
            } elseif ($localPath.EndsWith(".css")) {
                $response.ContentType = "text/css"
            } elseif ($localPath.EndsWith(".js")) {
                $response.ContentType = "application/javascript"
            } elseif ($localPath.EndsWith(".png")) {
                $response.ContentType = "image/png"
            } elseif ($localPath.EndsWith(".jpg") -or $localPath.EndsWith(".jpeg")) {
                $response.ContentType = "image/jpeg"
            }
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
