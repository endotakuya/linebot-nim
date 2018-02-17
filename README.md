# linebot-nim

## envfile

```.env
AUTHORIZATION_KEY=""
```

## Usage

Run server.

```
$ nim c -r -d:ssl app.nim
```

And, start ngrok.
```
$ ngrok http 8080
```

`Webhook URL` is `https://xxxxxxx.ngrok.io/webhook`.
