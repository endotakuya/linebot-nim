import asynchttpserver, asyncdispatch, json, httpclient, hmac, base64
import dotenv, os

let env = initDotEnv()
env.load()

const
  lineApiMessageReplyEndpoint = "https://api.line.me/v2/bot/message/reply"

proc callback(req: Request) {.async.} =
  if req.url.path == "/webhook":
    echo "Request body: ", req.body

    # Verification of signature
    let signature = req.headers.getOrDefault(key = "x-line-signature")
    let hash = hmac_sha256(key = getEnv("LINE_CHANNEL_SECRET"), data = req.body)
    if signature != encode(s = hash):
      await req.respond(Http404, "Not Found")

    let events = parseJson(req.body)["events"]
    for event in events:
      if event["type"].str == "message":
        let client = newHttpClient()
        client.headers = newHttpHeaders({
          "Content-Type": "application/json",
          "Authorization": "Bearer " & getEnv("AUTHORIZATION_KEY")
        })
        let body = %*{
          "replyToken": event["replyToken"],
          "messages": [{
            "type": "text",
            "text": event["message"]["text"]
          }]
        }
        let response = client.request(lineApiMessageReplyEndpoint,
                                      httpMethod = HttpPost,
                                      body = $body)
        echo response.status
      else:
        echo "Type is not 'message'"
    await req.respond(Http200, "", nil)
  else:
    await req.respond(Http404, "Not Found")

# Run server
var server = newAsyncHttpServer()
waitFor server.serve(Port(8080), callback)