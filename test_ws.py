import asyncio
import websockets
import json

async def test_ws():
    uri = "ws://127.0.0.1:9293/ws"
    async with websockets.connect(uri) as websocket:
        # We need to send {"scaleId": 0, "message": "{\"Req\":\"get_license\",\"ReqData\":\"\"}"}
        # Wait, the structure from Flutter is {"scaleId": [0...], "message": ...}?
        # Let's check how the go backend parses it.
        # h.recvWsClientMsg: json.Unmarshal(userMessage, &data); scaleId := new(big.Int).SetBytes(data["scaleId"]).Int64()
        # It's easier to just send exactly what Flutter sends.
        # Let's send {"scaleId": [0], "message": b"{\"Req\":\"get_license\",\"ReqData\":\"\"}"}
        # Wait, in json it's a list of bytes or base64?
        # A simpler way: we can just check the logcat since the flutter app ALREADY sends "get_license" when you click the menu!
        pass

asyncio.get_event_loop().run_until_complete(test_ws())
