require 'socket'

puts("=== サーバー起動 ===")

begin
  # socketを生成
  server_socket = TCPServer.new("localhost", 8080)

  # 外部からの接続を待ち、接続があったらコネクションを確立する
  puts("=== クライアントからの接続を待ちます ===")
  client_socket, address = server_socket.accept
  puts("=== クライアントとの接続が完了しました remote_address: #{address} ===")

  # クライアントから送られてきたデータを取得する
  request = client_socket.recv(4096)

  # クライアントから送られてきたデータをファイルに書き出す
  recvFile = File.open("server_recv.txt", "w")
  recvFile.write(request)

  # レスポンスボディを生成
  response_body = "<html><body><h1>It works!</h1></body></html>"

  # レスポンスラインを生成
  response_line = "HTTP/1.1 200 OK\r\n"
  # レスポンスヘッダーを生成
  response_header = ""
  response_header += "Date: #{Time.now.strftime('%a, %d %b %Y %H:%M:%S GMT')}\r\n"
  response_header += "Host: HenaServer/0.1\r\n"
  response_header += "Content-Length: #{response_body.encode.length}\r\n"
  response_header += "Connection: Close\r\n"
  response_header += "Content-Type: text/html\r\n"

  # ヘッダーとボディを空行でくっつけた上でbytesに変換し、レスポンス全体を生成する
  response = (response_line + response_header + "\r\n" + response_body).encode

  # クライアントへレスポンス
  client_socket.send(response, 0)

  # 通信を終了させる
  client_socket.close

ensure
  puts("=== サーバー停止 ===")
end