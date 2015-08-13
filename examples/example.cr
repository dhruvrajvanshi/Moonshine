require "../src/moonshine"
include Moonshine::Base
include Moonshine::Utils::Shortcuts


viewcount = 0

app = App.new
app.define do

  get "/", do |request|
    viewcount += 1
    html = "
      <html>
        <body>
          <h1>It worked!</h1>
          <hr>
          This page has been visited #{viewcount} times.
        </body>
      </html>
    "
    ok(html)
  end

  get "/api", do |request|
    res = ok("{\"name\": \"moonshine\"}")
    res.headers["Content-type"] = "text/json"
    res
  end
end
app.run()
