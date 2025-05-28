from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    print("-----------------------------------------------------")
    print("Request URL:", flow.request.url)
    print("Request Headers:", flow.request.headers)
    print("Request Body:", flow.request.get_text())

def response(flow: http.HTTPFlow) -> None:
    print("Response Status Code:", flow.response.status_code)
    print("Response Headers:", flow.response.headers)
    print("Response Body:", flow.response.get_text())
    print("-----------------------------------------------------")