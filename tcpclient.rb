require 'socket'

puts("=== クライアントを起動します ===")

begin
  # socketを生成しサーバーと接続する
  puts("=== サーバーと接続します ===")
  client_socket = TCPSocket.open("localhost",80)
  puts("=== サーバーとの接続が完了しました ===")

  # サーバーに送信するリクエストを、ファイルから取得する
  sendFile = File.open("client_send.txt", "r")
  request = sendFile.read()

  # サーバーへリクエストを送信する
  client_socket.send(request,0)

  # サーバーからレスポンスが送られてくるのを待ち、取得する
  response = client_socket.recv(4096)

  # レスポンスの内容を、ファイルに書き出す
  recvFile = File.open("client_recv.txt", "w")
  recvFile.write(response)

  # 通信を終了させる
  client_socket.close()

ensure
  puts("=== クライアントを停止します。 ===")
end
