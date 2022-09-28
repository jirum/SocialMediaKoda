class IpGeolocationService
  attr_reader :url, :key

  def initialize
    @url = "https://api.ipgeolocation.io/"
    @key = "babf6d8580604905b662e076596e029d"
  end

  def get_location(ip)
    request_url = "#{url}/ipgeo?apiKey=#{key}&ip=#{ip}"
    response = RestClient.get(request_url)
    JSON.parse(response.body)
  end
end