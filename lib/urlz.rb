require 'English'
require 'simpleidn'
require 'rack'
require 'awesome_print'


class Urlz
  REGEXP = %r{
    \A
    (?<protocol>https?://)
    (?:
      (?<domain>[^/:]+)
      (?<port>:\d+)
      |
      (?<domain>[^/?]+)
    )
    (?<path>.*)
    \Z
  }x

  def initialize url
    @url = url
  end

  def to_s
    @url
  end

  def assign params
    fixed_params = params.each_with_object({}) do |(key, value), memo|
      memo[key.to_s] = value
    end
    new_params = current_params.merge fixed_params

    chain(
      @url.split('?').first + '?' + to_query(new_params)
    )
  end

  def [] param
    current_params[param.to_s]
  end

  def without_protocol
    chain '//' + without_http.to_s
  end

  def with_protocol
    if protocol? @url
      self
    else
      with_http
    end
  end

  def with_http
    chain @url.gsub(%r{\A// | \A(?!https?://)}mix, 'http://')
  end

  def without_http
    chain @url.sub(%r{\A(?:https?:)?//}, '')
  end

  def domain
    chain without_http.to_s.gsub(%r{/.*|\?.*}, '')
  end

  def cut_www
    chain @url.sub(%r{\A(https?://)?www\.}, '\1')
  end

  def punycode
    string = @url.sub(REGEXP) do
      domain = SimpleIDN.to_ascii($LAST_MATCH_INFO[:domain]) +
        ($LAST_MATCH_INFO[:port] || '')

      $LAST_MATCH_INFO[:protocol] + domain + $LAST_MATCH_INFO[:path]
    end

    chain string
  end

  def depunycode
    chain depunycode_parts @url
  end

private

  def chain string
    Urlz.new string
  end

  def current_params
    url = @url.gsub('{', '%7B').gsub('}', '%7D').gsub('|', '%7C')
    @current_params ||= Rack::Utils.parse_query(URI(URI.escape(url)).query)
  end

  def protocol? string
    string.start_with? 'https://', 'http://'
  end

  def to_query params
    params.map do |key, value|
      check_param! key, value
      "#{key}=#{value}"
    end * '&'
  end

  def check_param! key, value
    unless value.nil? || value.is_a?(String) || value.is_a?(Symbol) ||
        value.is_a?(Numeric)
      value_text = value.respond_to?(:to_json) ? value.to_json : value.to_s
      raise ArgumentError, "#{key}=#{value_text}"
    end
  end

  def depunycode_parts string
    segments = (string[-1] == '/' ? "#{string} " : string).split('/')
    domain_index = protocol?(string) ? 2 : 0
    segments[domain_index] = depunycode_part segments[domain_index]
    segments.join('/').strip
  end

  def depunycode_part string
    if string.include? ':'
      parts = string.split ':'
      parts[0] = depunycode_part parts[0]
      parts.join ':'
    else
      SimpleIDN.to_unicode string
    end

  rescue SimpleIDN::ConversionError
    string
  end
end
