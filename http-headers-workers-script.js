let securityHeaders = {
  "Content-Security-Policy" : "default-src 'self'; style-src 'self' fonts.googleapis.com use.fontawesome.com; font-src 'self' fonts.gstatic.com use.fontawesome.com; script-src 'self' https://www.google-analytics.com https://ajax.cloudflare.com https://static.cloudflareinsights.com; img-src 'self' https://www.google-analytics.com; upgrade-insecure-requests; report-uri https://twmartincodes.report-uri.com/r/d/csp/enforce;",
  "Feature-Policy" : "accelerometer 'none'; camera 'none'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; payment 'none'; usb 'none'",
  "Strict-Transport-Security" : "max-age=31536000",
  "X-Xss-Protection" : "1; mode=block; report=https://twmartincodes.report-uri.com/r/d/xss/enforce",
  "X-Frame-Options" : "DENY",
  "X-Content-Type-Options" : "nosniff",
  "Referrer-Policy" : "strict-origin-when-cross-origin",
  "Report-To" : "{'group':'default','max_age':31536000,'endpoints':[{'url':'https://twmartincodes.report-uri.com/a/d/g'}],'include_subdomains':true}",
  "NEL" : "{'report_to':'default','max_age':31536000,'include_subdomains':true}"
}

let sanitiseHeaders = {
  "Server" : "cloud",
}

let removeHeaders = [
  "x-amz-id-2",
  "x-amz-request-id"
]

addEventListener('fetch', event => {
  event.respondWith(addHeaders(event.request))
})

async function addHeaders(req) {
  let response = await fetch(req)
  let newHdrs = new Headers(response.headers)

  if (newHdrs.has("Content-Type") && !newHdrs.get("Content-Type").includes("text/html")) {
    return new Response(response.body , {
        status: response.status,
        statusText: response.statusText,
        headers: newHdrs
    })
  }

  Object.keys(securityHeaders).map(function(name, index) {
    newHdrs.set(name, securityHeaders[name]);
  })

  Object.keys(sanitiseHeaders).map(function(name, index) {
    newHdrs.set(name, sanitiseHeaders[name]);
  })

  removeHeaders.forEach(function(name){
    newHdrs.delete(name)
  })

  return new Response(response.body , {
    status: response.status,
    statusText: response.statusText,
    headers: newHdrs
  })
}
