require 'socket'

# 実行ファイルのあるディレクトリ
BASE_DIR = Dir.pwd
# 静的配信するファイルを置くディレクトリ
$STATIC_ROOT = File.join(BASE_DIR, "static")
# 拡張子とMIME Typeの対応
$MIME_TYPES = {
  "html": "text/html",
  "css": "text/css",
  "png": "image/png",
  "jpg": "image/jpg",
  "gif": "image/gif",
}

puts("=== サーバー起動 ===")

begin
  # socketを生成
  server_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
  # # socketをlocalhostのポート8080番に割り当てる
  sockaddr = Socket.sockaddr_in(8080, "0.0.0.0")
  server_socket.bind(sockaddr)
  server_socket.listen(10)

  while true
    # 外部からの接続を待ち、接続があったらコネクションを確立する
    puts("=== クライアントからの接続を待ちます ===")
    client_socket, address = server_socket.accept
    puts("=== クライアントとの接続が完了しました remote_address: #{address.ip_unpack} ===")

    begin
      # クライアントから送られてきたデータを取得する
      request = client_socket.recv(4096)

      # クライアントから送られてきたデータをファイルに書き出す
      recvFile = File.open("server_recv.txt", "w")
      recvFile.write(request)

      # リクエスト全体を
      # 1. リクエストライン(1行目)
      # 2. リクエストヘッダー(2行目〜空行)
      # 3. リクエストボディ(空行〜)
      # にパースする
      request_line, remain = request.split(/\r\n/,2)
      request_header, request_body = remain.split(/\r\n\r\n/)

      # リクエストラインをパースする
      method, path, http_version = request_line.split(" ")

      # pathの先頭の/を削除し、相対パスにしておく
      relative_path = path.delete_prefix("/")
      # ファイルのpathを取得
      static_file_path = File.join($STATIC_ROOT, relative_path)

      # ファイルからレスポンスボディを生成
      begin
        responseFile = File.open(static_file_path, "r")
        response_body = responseFile.read()
        # レスポンスラインを生成
        response_line = "HTTP/1.1 200 OK\r\n"
      rescue SystemCallError
        response_body = "<html><body><h1>404 Not Found</h1></body></html>"
        response_line = "HTTP/1.1 404 Not Found\r\n"
      end

      # ヘッダー生成のためにContent-Typeを取得しておく
      # pathから拡張子を取得
      if path.include? "."
        ext = path.split(".", 2)[-1]
      else
        ext = ""
      end
      # 拡張子からMIME Typeを取得
      # 対応していない拡張子の場合はoctet-streamとする
      content_type = $MIME_TYPES.fetch(ext.to_sym, "application/octet-stream")

      # レスポンスヘッダーを生成
      response_header = ""
      response_header += "Date: #{Time.now.strftime('%a, %d %b %Y %H:%M:%S GMT')}\r\n"
      response_header += "Host: HenaServer/0.1\r\n"
      response_header += "Content-Length: #{response_body.encode.length}\r\n"
      response_header += "Connection: Close\r\n"
      response_header += "Content-Type: #{content_type}\r\n"

      # レスポンス全体を生成する
      response = (response_line + response_header + "\r\n").encode + response_body

      # クライアントへレスポンス
      client_socket.send(response, 0)
    rescue Exception => e
      # リクエストの処理中に例外が発生した場合はコンソールにエラーログを出力し、
      # 処理を続行する
      puts("=== リクエストの処理中にエラーが発生しました ===")
      puts(e)
    ensure
      # 通信を終了させる
      client_socket.close
    end
  end
ensure
  puts("=== サーバー停止 ===")
end