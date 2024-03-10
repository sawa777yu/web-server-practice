require 'socket'

puts("=== サーバー起動 ===")

begin
  # socketを生成
  server_socket = TCPServer.new("localhost", 8080)

  # 外部からの接続を待ち、接続があったらコネクションを確立する
  puts("=== クライアントからの接続を待ちます ===")
  client_socket, address = server_socket.accept()
  puts("=== クライアントとの接続が完了しました remote_address: #{address} ===")

  # クライアントから送られてきたデータを取得する
  request = client_socket.recv(4096)

  # クライアントから送られてきたデータをファイルに書き出す
  file = File.open("server_recv.txt", "w")
  file.write(request)

  # 返事は特に返さず、通信を終了させる
  client_socket.close()

ensure
  puts("=== サーバー停止 ===")
end