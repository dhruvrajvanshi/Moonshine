struct ParameterHash
  # ParameterHash is a hash that stores an array
  # of strings mapped to each key
  # To get the first value, call [] or fetch
  # To get the array, call fetchAll
  def initialize
    @hash = {"" => [] of String} of String => Array(String)
  end

  def []=(key, value : String)
    self[key] = [value]
  end

  def [](key)
    fetch key
  end

  def []?(key)
    @hash[key]?
  end

  def add(key, value : String)
    existing = @hash[key]?
    if existing
      existing << value
    else
      @hash[key] = [value]
    end
    self
  end

  def fetch(key)
    values = @hash[key]?
    raise Exceptions::KeyNotFound.new(key) unless values
    values[0]
  end

  def fetch(key, default)
    begin
      val = fetch(key)
    rescue Exceptions::KeyNotFound
      val = default
    end
    val
  end

  def has_key?(key)
    @hash.has_key? key
  end

  def empty?
    @hash.empty?
  end

  def fetchAll(key)
    @hash[key]
  end

  def get?(key)
    @hash[key]?
  end

  def to_s(io : IO)
    io << "Moonshine::Http::ParameterHash"
    @hash.to_s(io)
  end

  forward_missing_to @hash
end
