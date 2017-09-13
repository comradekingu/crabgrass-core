require 'openssl'
require 'net/smtp'

Net::SMTP.class_eval do
  private

  def do_start(helodomain, user, secret, authtype)
    raise IOError, 'SMTP session already started' if @started
    check_auth_args user, secret, authtype if user or secret

    sock = timeout(@open_timeout) { TCPSocket.open(@address, @port) }
    @socket = Net::InternetMessageIO.new(sock)
    @socket.read_timeout = 60 # @read_timeout

    check_response(critical { recv_response })
    do_helo(helodomain)

    if starttls
      raise 'openssl library not installed' unless defined?(OpenSSL)
      ssl = OpenSSL::SSL::SSLSocket.new(sock)
      ssl.sync_close = true
      ssl.connect
      @socket = Net::InternetMessageIO.new(ssl)
      @socket.read_timeout = 60 # @read_timeout
      do_helo(helodomain)
    end

    authenticate user, secret, authtype if user
    @started = true
  ensure
    unless @started
      # authentication failed, cancel connection.
      @socket.close if !@started and @socket and !@socket.closed?
      @socket = nil
    end
  end

  def do_helo(helodomain)
    if @esmtp
      ehlo helodomain
    else
      helo helodomain
    end
  rescue Net::ProtocolError
    if @esmtp
      @esmtp = false
      @error_occured = false
      retry
    end
    raise
  end

  def starttls
    begin
      getok('STARTTLS')
    rescue
      return false
    end
    true
  end

  def quit
    getok('QUIT')
  rescue EOFError
  end
end
