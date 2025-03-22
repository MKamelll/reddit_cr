require "json"
require "base64"
require "http"
require "dotenv"

class Auth
  def initialize(@user_name : String, @password : String, @client_id : String, @client_secret : String)
    @credentials = Base64.strict_encode("#{@client_id}:#{@client_secret}")
    @headers = HTTP::Headers {
      "Content-Type" => "application/x-www-form-urlencoded",
      "Authorization" => "Basic #{@credentials}",
      "User-Agent" => "CrystalBot:1.0 (by /u/#{@user_name})"
    }
  end

  def authorize
    url =  "https://www.reddit.com/api/v1/access_token"
    form = {
      "grant_type" => "password",
      "username" => @user_name,
      "password" => @password
    }
    return HTTP::Client.post(url, headers: @headers, form: form)
  end
end

class Client
  def initialize(@access_token : String, @user_name : String)
    @headers = HTTP::Headers{
      "User-Agent" => "CrystalBot:1.0 (by /u/#{@user_name})",
      "Authorization" => "Bearer #{@access_token}"
    }
  end

  def get(url : String)
    return HTTP::Client.get(url, headers: @headers)
  end
end

class Account
  def initialize(@red : Reddit)
    @me_url = "#{@red.base_url}/api/v1/me"
    @prefs_url = "#{@red.base_url}/prefs"
  end

  def me
    return @red.client.get(@me_url)
  end

  def my_blocked_users
    url = "#{@me_url}/blocked"
    return @red.client.get(url)
  end

  def my_friends
    url = "#{@me_url}/friends"
    return @red.client.get(url)
  end

  def my_prefs
    url = "#{@me_url}/prefs"
    return @red.client.get(url)
  end

  def my_trophies
    url = "#{@me_url}/trophies"
    return @red.client.get(url)
  end

  def my_prefs_blocked
    url = "#{@prefs_url}/blocked"
    return @red.client.get(url)
  end

  def my_prefs_friends
    url = "#{@prefs_url}/friends"
    return @red.client.get(url)
  end

  def my_prefs_messaging
    url = "#{@prefs}/messaging"
    return @red.client.get(url)
  end

  def my_prefs_trusted
    url = "#{@prefs}/trusted"
    return @red.client.get(url)
  end

  def my_karma
    url = "#{@me_url}/karma"
    return @red.client.get(url)
  end

  def about_user(id : String)
    url = "#{@red.base_url}/user/#{id}/about"
    return @red.client.get(url)
  end

  def subreddits_subscribed
    url = "#{@red.base_url}/subreddits/mine/subscriber"
    return @red.client.get(url)
  end

  def subreddits_where_i_am_approved_user
    url = "#{@red.base_url}/subreddits/mine/contributor"
    return @red.client.get(url)
  end

  def subreddits_where_i_am_moderator
    url = "#{@red.base_url}/subreddits/mine/moderator"
    return @red.client.get(url)
  end
end

class Subreddit
  def initialize(@red : Reddit, @name : String)
    @base_subreddit_url = "#{@red.base_url}/r/#{@name}"
  end

  def about
    url = "#{@base_subreddit_url}/about"
    return @red.client.get(url)
  end
end

class Reddit
  property client
  property base_url = "https://oauth.reddit.com"
  def initialize(@client : Client)
  end
end

def main
  Dotenv.load
  client_id = ENV["client_id"]
  client_secret = ENV["client_secret"]
  user_name = ENV["user_name"]
  password = ENV["password"]
  access_token = ENV["access_token"]


  #auth = Auth.new(user_name: user_name, password: password, client_id: client_id, client_secret: client_secret)
  #puts auth.authorize.body

  client = Client.new(access_token: access_token, user_name: user_name)
  red = Reddit.new(client)
  acc = Account.new(red)
  bitcoin = Subreddit.new(red, "bitcoin")
  puts bitcoin.about.body

end

main()
