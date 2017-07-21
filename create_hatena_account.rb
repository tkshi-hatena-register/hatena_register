Encoding.default_external = Encoding::UTF_8 # windows対応

require 'csv'
require 'selenium-webdriver'
require 'kconv'

proxy_list = CSV.read("proxies.csv")

i = 0
proxy_list.each do |row|
  PROXY = "#{row[0]}:#{row[1]}"
  proxy = Selenium::WebDriver::Proxy.new(
    :http     => PROXY,
    :ftp      => PROXY,
    :ssl      => PROXY,
    :no_proxy => nil
  )

  caps = Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => proxy)

  driver2 = Selenium::WebDriver.for :chrome ,:desired_capabilities => caps

  driver2.navigate.to("https://10minutemail.com/10MinuteMail/index.html?dswid=9418")

  email = driver2.find_element(:id, 'mailAddress').attribute("value")

  driver = Selenium::WebDriver.for :chrome ,:desired_capabilities => caps
  driver.navigate.to("https://www.hatena.ne.jp/register?via=200125")

  vowel = ["a", "i", "u", "e", "o"]
  consonant = ["a", "i", "u", "e", "o", "k", "s", "t", "n", "h", "m", "r", "w"]
  symbol = ["_", "", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ]

  user_id = consonant.sample + vowel.sample + consonant.sample + vowel.sample + consonant.sample + vowel.sample +
            symbol.sample + consonant.sample + vowel.sample + consonant.sample + vowel.sample

  password = Time.now.strftime('p%m%d%H%M%S')

  driver.find_element(:id, 'username-input').send_keys(user_id)
  driver.find_element(:id, 'password-input').send_keys(password)
  driver.find_element(:id, 'mail-input').send_keys(email)
  driver.find_element(:xpath, '//*[@id="magazine"]/div[1]/label').click

  wait = Selenium::WebDriver::Wait.new(:timeout => 10000) # seconds
  wait.until {driver.find_element(:id, 'back-button').displayed?}
  driver.find_element(:id, 'submit-button').click

  wait.until {driver2.find_element(:class, 'inc-mail-subject').displayed?}

  driver2.find_element(:class, 'inc-mail-subject').click

  wait.until {driver2.find_element(:partial_link_text, 'http://www.hatena.ne.jp/r?k=').displayed?}
  driver2.find_element(:partial_link_text, 'http://www.hatena.ne.jp/r?k=').click
  wait.until {driver2.page_source.include?("はてなIDの登録が完了しました")}

  unless FileTest.exist?("result.csv")
    File.open("result.csv","w") do |file|
    end
  end

  CSV.open("result.csv","a") do |file|
    file << [user_id, password, row[0], row[1]]
  end

  table = CSV.table("proxies.csv", headers: false)
  table[i].push("done")
  i += 1

  CSV.open("proxies.csv", "w") do |file|
    table.each do |line|
      file << line
    end
  end
  driver.close
  driver2.close
end
