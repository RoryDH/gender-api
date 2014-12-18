require 'json'
require 'sinatra'
require 'gender_detector'
gd = GenderDetector.new(case_sensitive: false)
GENDER_FORMAT = {
  male:          'm',
  mostly_male:   'm',
  female:        'f',
  mostly_female: 'f',
  andy:          'n'
}

def req_json  
  return @req_json if @req_json
  request.body.rewind
  @req_json = JSON.parse(request.body.read)
end

def error(s)
  { error: s }
end

get '/' do
  "Rory's gender server. Time: #{Time.now}. Uses https://github.com/bmuller/gender_detector"
end

post '/bulk' do
  names = req_json['names']
  return error('Invalid Request') unless names
  
  gender_map = {}
  names.each do |name|
    gender_map[name] = GENDER_FORMAT[gd.get_gender(name, :ireland)]
  end

  {
    names: gender_map
  }.to_json
end
